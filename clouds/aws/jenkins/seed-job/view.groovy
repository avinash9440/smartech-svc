/*
 * File: view.groovy
 * Project: seed-job
 * Created Date: Saturday August 3rd 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Saturday August 3rd 2019 7:55:52 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




import jenkins.*
import hudson.*
import hudson.model.*
import hudson.util.*;
import jenkins.model.Jenkins

def viewNames = [
        infra: [
            name: '01-AWS Infra Deployer',
            obj: null,
            suffix: 'aws-infra-deployer'
        ],
        provision: [
            name: '02-Provision Deployer',
            obj: null,
            suffix: 'provision-deployer'
        ],
        app: [
            name: '03-App Deployer',
            obj: null,
            suffix: 'app-deployer'
        ],
]

def jenkins = Jenkins.instance

viewNames.each{ viewType, property ->
    // println("got ${viewType} && ${property}")
    property['obj'] = hudson.model.Hudson.instance.getView(property['name'])

    if (!property['obj']){
        jenkins.addView(new ListView(property['name']))
        property['obj'] = hudson.model.Hudson.instance.getView(property['name'])
    }
}

jobInstances = jenkins.instance.getAllItems(Job.class)
//println "Size of list jobinstances is ${jobInstances.size()}"

jobInstances.each { job ->
    viewNames.each{ viewType, property ->
        //println("${viewNames} <=====> ${property}")
        if(job.fullName.endsWith(property['suffix'])){
            println "Adding job: " + job.fullName + " to the view"
            property['obj'].doAddJobToView(job.fullName)
        }
    }
};


jenkins.save()
println "\nScript successfully completed.\n"