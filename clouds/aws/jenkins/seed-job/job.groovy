/*
 * File: job.groovy
 * Project: seed-job
 * Created Date: Thursday August 8th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Thursday August 8th 2019 12:08:47 am
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
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
        config << envConfig
    }
    // println("Config: ${config}")
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
            if(!properties['infra'].containsKey(key)) {
                throw Exception("missing key 'env': ${key}")
                err = true
            }
        }
    }
   return err
}

def createInfraDeploymentJob = { build, env, config ->
    try{
        println "Adding infra job for Env: ${env}"
        
        def infraProj = []

        config[env]['infra']['tf_proj'].each { mod, prop ->
            // expects prop['tf_folder'] to be of format:
            // 'submodule/security/clouds/aws/tf-templates/'

            def ma = (prop['tf_folder'] =~ /^submodule\/(.+?)\/.*/ )
            infraProj << ma[0][1]
        }
        infraProj.unique()
        // println "Infra Proj is ${infraProj}"

        pipelineJob("${env}-aws-infra-deployer"){
            definition{
                cpsScm {
                    lightweight(true)
                    scm {
                        git {
                            remote {
                                url(config[env]['infra']['git_url'])
                                credentials(config[env]['infra']['credentials_id'])
                            }
                            branches(config[env]['infra']['git_branch'])
                        }
                    }
                    scriptPath(config[env]['infra']['jenkins_file'])
                }
            }
            parameters {

                stringParam('sitEnv', env, 'SIT environment name')
                stringParam('tfVersion', config[env]['tf_version'], 'Terraform version to use')
                stringParam('gitUrl', config[env]['infra']['git_url'], 'Git URL')
                stringParam('gitBranch', config[env]['infra']['git_branch'], 'Git Branch')
                stringParam('gitCredentials', config[env]['infra']['credentials_id'], 'Credentials Id for Worker')

                stringParam('devopsBucket', config[env]['devops_bucket'], 'S3 Devops Bucket')
                stringParam('devopsBucketRegion', config[env]['devops_bucket_region'], 'S3 Devops Bucket AWS Region')
                booleanParam('skipInput', false, 'Skip input confirmation - true for automated ci/cd jobs')
                stringParam('tfPlanArgs','', 'Extra args for Terraform  plan')
                stringParam('infraModules','', 'Extra args for Terraform  plan')

                activeChoiceParam('ProjDeployType') {
                    description('Deploy just selective modules or all modules')
                    choiceType('RADIO')
                    groovyScript {
                        script('["selective:selected", "all"]')
                        fallbackScript('"selective"')
                    }
                } 

                activeChoiceReactiveParam('infraProjs') {
                    description('Terraform modules to add or destroy')
                    filterable()
                    choiceType('MULTI_SELECT')
                    groovyScript {
                        script('''
                            if (ProjDeployType.equals('all')) {
                                return ''' + infraProj.collect{'"' + it + ':selected"'} + '''
                            }
                            else {
                                return ''' + infraProj.collect{'"' + it + '"'} + '''
                            }
                            '''
                        )
                        fallbackScript('"kms"')
                    }
                    referencedParameter('ProjDeployType')
                }

                activeChoiceParam('infraAction') {
                    description('Modify environment or destroy')
                    filterable()
                    choiceType('SINGLE_SELECT')
                    groovyScript {
                        script('["create_or_update:selected", "destroy"]')
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

def createProvisioningJob  = { build, env, config ->

    println "Adding Provisioning job for Env: ${env}"

    freeStyleJob("${env}-provision-deployer"){
        concurrentBuild()
        label(env)
        authenticationToken('JasdfaR01sR1m0HquQx0tNHISzuIPXPFC7rSdFaQQjyNQ')
        description "Implements ansible playbook on the server calling this job for ${env}"
        logRotator(numToKeep = 100)

        scm {
            git {
                remote {
                    url(config[env]['provision']['git_url'])
                    credentials(config[env]['provision']['credentials_id'])
                }
                branches(config[env]['provision']['git_branch'])
            }
        }

        parameters {
            stringParam("ENV", env, "Sit Envronment")
            stringParam("AWS_REGION", config[env]['aws_region'], "Primary region.")
            stringParam("SERVICE_TAG", "redis-egress", "Service to run ansible playbook for")
            stringParam("INSTANCE_IP", "", "Instance IP address to deploy playbook to")
            stringParam("GIT_SHA", "", "GIT SHA for CI/CD apps")
        }

        steps {
            shell("""
            #!/bin/bash
            set -e
            set -x
            export DEST_DIR=/tmp/\${SERVICE_TAG}
            # export ANSIBLE_KEEP_REMOTE_FILES=1
            export GIT_SHA_ARG=''

            if [[ -z "\${INSTANCE_IP// }" ]]; then
                echo "Received no Instance IP, exiting"
                exit 1
            fi

            if [[ ! -z "\${GIT_SHA// }" ]]; then
                echo "GIT_SHA not empty"
                GIT_SHA_ARG="--extra-vars service_git_sha=\${GIT_SHA}"
            fi

            ansible --version
            echo "Deploying playbook on >>> Instance IP: \${INSTANCE_IP} ENV: \${ENV}; AWS_REGION: \${AWS_REGION}; SERVICE_TAG: \${SERVICE_TAG}"
            ansible-playbook --verbose --tags default \
                 --inventory \${INSTANCE_IP}, \
                 --extra-vars env=\${ENV} \
                 --extra-vars aws_region=\${AWS_REGION} \
                 \$GIT_SHA_ARG \
                 \${SERVICE_TAG}.yaml
            """)
        }
    }
}

def createAppDeploymentJob = { build, env, config ->
    try{
        println "Adding application deployment job for Env: ${config[env]['app_config']['tf_module'].keySet()}"
        pipelineJob("${env}-app-deployer"){
            authenticationToken('Ix24qTcXgwTcJvt9MUYA2qw11MbXTaTlDN3K4GqMI9FgB')
            definition{
                cpsScm {
                    lightweight(false)
                    scm {
                        git {
                            remote {
                                url(config[env]['app_config']['git_url'])
                                credentials(config[env]['app_config']['credentials_id'])
                            }
                            branches(config[env]['app_config']['git_branch'])
                        }
                    }
                    scriptPath(config[env]['app_config']['jenkins_file'])
                }
            }
            parameters {

                stringParam('sitEnv', env, 'SIT environment name')
                stringParam('tfVersion', config[env]['tf_version'], 'Terraform version to use')
                stringParam('gitCredentials', config[env]['app_config']['credentials_id'], 'Credentials Id for Worker')
                stringParam('commonTag', config[env]['app_config']['common_tag'], 'Common tags for core apps')

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

                activeChoiceReactiveParam('appModules') {
                    description('Apps to Build and Deploy')
                    filterable()
                    choiceType('MULTI_SELECT')
                    groovyScript {
                        script('''
                            if (AppDeployType.equals('all')) {
                                return ''' + config[env]['app_config']['tf_module'].keySet().collect{'"' + it + ':selected"'} + '''
                            }
                            else {
                                return '''+ config[env]['app_config']['tf_module'].keySet().collect{'"' + it + '"'} + '''
                            }
                            '''
                        )
                        fallbackScript('"smartech"')
                    }
                    referencedParameter('AppDeployType')
                }

                activeChoiceParam('infraAction') {
                    description('Modify environment or destroy')
                    filterable()
                    choiceType('SINGLE_SELECT')
                    groovyScript {
                        script('["create_or_update:selected", "destroy"]')
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
def configFolder = build.workspace.toString() + '/clouds/aws/jenkins/seed-job/config'
def jobFilters = ['aws-infra-deployer', 'provision-deployer', 'app-deployer']
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


envsToAdd.each { env ->
    createInfraDeploymentJob(build, env, config)
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
    deleteDeploymentJob(job)
    del_count++
}

if (del_count > 0){
    println "\ndel_count: ${del_count} jobs deleted successfully.\n"
}
jenkins.save()
println "\nScript successfully completed.\n"
