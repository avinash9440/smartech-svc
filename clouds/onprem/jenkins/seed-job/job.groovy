/*
 * File: job.groovy
 * Project: seed-job
 * Created Date: Thursday August 8th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Thursday August 8th 2019 12:08:47 am
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2020 Ashay Chitnis, all rights reserved.
 */




@Grab('org.yaml:snakeyaml:1.23')

import java.util.regex.*
import groovy.util.FileNameFinder
import groovy.io.FileType
import org.yaml.snakeyaml.Yaml

import jenkins.*
import hudson.*
import hudson.model.*
import hudson.util.*;
import jenkins.model.Jenkins

import org.jenkinsci.plugins.workflow.*

def printMsg = { msgText ->
    println("Msg: ${msgText}")
    return 0
}

def printErr = { errText ->
    System.err.&println(errText + "... Exiting!")
    return 0
}

def loadConfig = { build, configFolder ->
    
    channel = build.workspace.channel;
    def configFiles = []
    def dirObj = new FilePath(channel, configFolder)

    configFiles = dirObj.list()    

    Map config = [:]
    configFiles.each { configFile ->
        Map envConfig = [:]
        if (configFile.name.endsWith(".yaml") || configFile.name.endsWith(".yml")){
            def env_name = configFile.name.replaceFirst(~/\.[^\.]+$/, '')
            try {
                Yaml yaml = new Yaml()
                def fileText = (new FilePath(channel, configFolder + '/'+ configFile.name)).read().getText()
                envConfig = yaml.load(fileText)
            }
            catch (any) {
                println("Error loading configuration file ${configFile.name}: ${any}")
                return envConfig
            }
            //println("Env config ${envConfig}")
            config[env_name] = envConfig
        }
        else {
            println("Skipping ${configFile.name} as it doesn't end with yaml or yml extension")
        }

    }
    println("Config: ${config}")
    return config
}

// ToDo: ValidateSchema needs a better approach
def validateSchema = { config ->
    def keyNames = ['git_url', 'git_branch', 'jenkins_file']
    def err = false

    config.each { env, properties ->
        // println("Env: ${env}, Proper: ${properties}")
        keyNames.each { key ->
            //println("Env: ${env}, Proper: ${properties}, 1: ${properties.infra}, 2: ${properties['infra']}")
            // if(!properties['infra'].containsKey(key)) {
            //     throw Exception("missing key 'env': ${key}")
            //     err = true
            // }
        }
    }
   return err
}

def createProvisioningJob  = { build, env, config ->

    println "Adding Provisioning job for Env: ${env}"

    pipelineJob("${env}-provision-deployer"){
        // concurrentBuild()
        // label(env)
        description "Implements ansible playbook on the server calling this job for ${env}"
        logRotator(numToKeep = 100)
        definition{
            cpsScm {
                lightweight(false)
                scm {
                    git {
                        remote {
                            url(config[env]['provision']['git_url'])
                            credentials(config[env]['provision']['credentials_id'])
                        }
                        branches(config[env]['provision']['git_branch'])
                    }
                }
                scriptPath(config[env]['provision']['jenkins_file']['default'])                
            }
        }        
        parameters {
            stringParam("ENV", env, "Sit Envronment")
            stringParam("SERVICE_TAG", "event-logger", "Service to run ansible playbook for")
            stringParam("GIT_SHA", "", "GIT SHA for CI/CD apps")
            booleanParam("SUDO", false, "To sudo or not to sudo")
            stringParam("SUDO_USER", "root", "User used for sudo")
            stringParam("CONNECT_USER", "root", "User used for sudo")
            booleanParam("HOST_KEY_CHECKING", false, "User used for sudo")
            stringParam("ADDITIONAL_ANSIBLE_ARGS", "", "Additional ansible arguments")
            credentialsParam("HOST_CRED_ID"){
                type('com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl')
                required()
                defaultValue("")
                description("Ansible credentials id for particular app/env")
            }
            credentialsParam("VAULT_CRED_ID"){
                type('com.cloudbees.plugins.credentials.impl.SecretBytes')
                required()
                defaultValue("")
                description("Ansible vault credentials id")
            }

            activeChoiceReactiveParam("REGION") {
                description('Datacenter Region to build the application for given environment')
                filterable()
                // choiceType('MULTI_SELECT')
                choiceType('SINGLE_SELECT')
                groovyScript {
                    script( 'return ' + config[env]['provision']['region'].collect{'"' + it + '"'} )
                    fallbackScript('"all"')
                }                
            }            
        }
    }
}

def createAppDeploymentJob = { build, env, config ->
    try{
        println "Adding application deployment job for Env: ${env}"
        pipelineJob("${env}-app-deployer"){
            definition{
                cpsScm {
                    lightweight(false)
                    scm {
                        git {
                            remote {
                                url(config[env]['build_deploy_config']['git_url'])
                                credentials(config[env]['build_deploy_config']['credentials_id'])
                            }
                            branches(config[env]['build_deploy_config']['git_branch'])
                        }
                    }
                    scriptPath(config[env]['build_deploy_config']['jenkins_file'])
                }
            }
            parameters {

                stringParam('sitEnv', env, 'SIT environment name')
                stringParam('gitTag', '', 'Git tag received')
                stringParam('gitCredentials', config[env]['build_deploy_config']['credentials_id'], 'Credentials Id for Worker')
                stringParam('tagPattern', config[env]['build_deploy_config']['tag_pattern'], 'Common tags for core apps')
                stringParam('devopsBucket', config[env]['devops_bucket'], 'S3 Devops Bucket')
                stringParam('devopsBucketRegion', config[env]['devops_bucket_region'], 'S3 Devops Bucket AWS Region')
                stringParam('deployBucket', config[env]['deploy_bucket'], 'S3 Artifact Deploy Bucket')
                stringParam('deployBucketRegion', config[env]['deploy_bucket_region'], 'S3 Deploy Bucket AWS Region')
                booleanParam('skipInput', false, 'Skip input confirmation - true for automated ci/cd jobs')
                booleanParam('compileOnly', false, 'Only compile the module and do not deploy')

                activeChoiceParam('AppDeployType') {
                    description('Deploy just selective apps or all modules')
                    choiceType('RADIO')
                    groovyScript {
                        script('["selective:selected", "all"]')
                        fallbackScript('"selective"')
                    }
                }

                activeChoiceReactiveParam('app') {
                    description('Apps to Build and Deploy')
                    filterable()
                    // choiceType('MULTI_SELECT')
                    choiceType('SINGLE_SELECT')
                    groovyScript {
                        script('''
                            if (AppDeployType.equals('all')) {
                                return ''' + config[env]['build_deploy_config']['app_module'].keySet().collect{'"' + it + ':selected"'} + '''
                            }
                            else {
                                return '''+ config[env]['build_deploy_config']['app_module'].keySet().collect{'"' + it + '"'} + '''
                            }
                            '''
                        )
                        fallbackScript('"smartech"')
                    }
                    referencedParameter('AppDeployType')
                }

                activeChoiceParam('infraAction') {
                    description('Modify environment')
                    filterable()
                    choiceType('SINGLE_SELECT')
                    groovyScript {
                        script('["create_or_update:selected"]')
                        fallbackScript('"create_or_update"')
                    }
                }
            }
        }
    }
    catch (any) {
        println("Error creating job for environment: ${env}, Exception: ${any}")
        return false
    }
    return true
}

def createGitTagMergeJob = { build, env, config ->

    pipelineJob("git-tag-merger"){
        
        logRotator(numToKeep = 100)
        definition{
            cpsScm {
                lightweight(false)
                scm {
                    git {
                        remote {
                            url(config[env]['build_deploy_config']['git_url'])
                            credentials(config[env]['build_deploy_config']['credentials_id'])
                        }
                        branches(config[env]['build_deploy_config']['git_branch'])
                    }
                }
                scriptPath(config[env]['build_deploy_config']['merger_jenkins_file'])
            }
        }

        parameters {

            activeChoiceReactiveParam('app') {
                description('Apps to Build and Deploy')
                filterable()
                // choiceType('MULTI_SELECT')
                choiceType('SINGLE_SELECT')
                groovyScript {
                    script('''
                        return '''+ config[env]['build_deploy_config']['app_module'].keySet().collect{'"' + it + '"'} + '''
                        '''
                    )
                    fallbackScript('"smartech"')
                }
            }
            
            activeChoiceParam('gitBranch') {
                description('Modify environment')
                filterable()
                choiceType('SINGLE_SELECT')
                groovyScript {
                    script('["test:selected", "test", "dev1", "qa0", "qa1", "pod1" ,"sit"]')
                    fallbackScript('"test"')
                }
            }

            stringParam('tagName', '', 'Git tag to be merged into branch')
        }
    }
}

def deleteDeploymentJob = { job ->
    println "Deleting job: ${job.fullName} ..."
    try{
        job.delete()
    }
    catch(any){
        println "Error deleting job: ${job.fullName} ...${any}"
        return false
    }
    println "Successfully deleted job: ${job.fullName}"
    return true
}


def build = Thread.currentThread().executable
def jenkins = Jenkins.instance
def configFolder = build.workspace.toString() + '/clouds/onprem/jenkins/seed-job/config'
def jobFilters = ['provision-deployer', 'app-deployer']
def jobsToDelete = []

Set configuredEnvs = []
Set availableEnvs = []
Set envsToAdd = [] 
Set envsToDelete = []

Map config = loadConfig(build, configFolder)
if (!config){
    throw new Exception("Empty config map, folder: ${configFolder}")
    return false
}

def schemaError = validateSchema(config)
if (schemaError){
    throw new Exception("Incorrect config schema")
    return false
}

configuredEnvs = config.keySet()
jobInstances = jenkins.items.findAll()

jobInstances.each {
    if (it.fullName.startsWith('sit')) {
        println('Matched: ' + it.fullName)
        availableEnvs.add(it.fullName.split('-')[0])
    }
}

envsToAdd = availableEnvs.plus(configuredEnvs)
envsToDelete = availableEnvs.minus(configuredEnvs)
envsToAdd = envsToAdd.minus(envsToDelete)

println("Available environments: ${availableEnvs}")
println "Environments to add: ${envsToAdd}"
println "Environments to delete: ${envsToDelete}"

createGitTagMergeJob(build, 'dev0', config)

envsToAdd.each { env ->
    createProvisioningJob(build, env, config)
    createAppDeploymentJob(build, env, config)
}

// create jenkins jobs
jobInstances.each { job ->
    // println("Name: ${job.fullName}, envsToDelete: ${job.fullName.split('-').head()}, JobFilters:  ${job.fullName.split('-').tail().join('-')}")
    // println("Name: ${job.fullName}, envsToDelete: ${envsToDelete.contains(job.fullName.split('-').head())}, JobFilters:  ${jobFilters.contains(job.fullName.split('-').tail().join('-'))}")
    // println(job.fullName.split('-'))
    if(envsToDelete.contains(job.fullName.split('-').head()) && jobFilters.contains(job.fullName.split('-').tail().join('-'))){
        jobsToDelete.add(job)
    }
}


// delete removed jenkins jobs
int del_count = 0

jobsToDelete.each{ job ->
    println('To Delete: >>> '+job.fullName)
    // deleteDeploymentJob(job)
    del_count++
}

if (del_count > 0){
    println "\ndel_count: ${del_count} jobs deleted successfully.\n"
}
jenkins.save()
println "\nScript successfully completed.\n"
