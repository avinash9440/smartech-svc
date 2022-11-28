/*
 * File: webhook-trigger.groovy
 * Project: seed-job
 * Created Date: Thursday July 9th 2020
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Thursday July 9th 2020 2:19:04 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2020 Ashay Chitnis, all rights reserved.
 */




import jenkins.*
import hudson.*
import hudson.model.*
import hudson.util.*;
import jenkins.model.Jenkins


def createWebhookTriggerJob = { build ->
    try{
        println "Adding Webhook Trigger job for all environments"
        freeStyleJob("app-webhook-trigger"){
            triggers {
                genericTrigger {
                    genericVariables {
                        genericVariable {
                            key("gitTag")
                            value("\$.ref")
                            expressionType("JSONPath")
                            regexpFilter("")
                        }
                        genericVariable {
                            key("filteredGitTag")
                            value("\$.ref")
                            expressionType("JSONPath")
                            regexpFilter('(-.*)$')
                        }
                    }
                    genericRequestVariables {
                        genericRequestVariable {
                            key("app")
                            regexpFilter("")
                        }
                    }
                    token('JasdfaR01sR1m0HquQx0tNHISzuIPXPFC7rSdFaQQjyNQ')
                    printContributedVariables(true)
                    printPostContent(true)
                    silentResponse(false)
                    regexpFilterText('')
                    regexpFilterExpression('')
                }
            }
            parameters {
                stringParam('app', '', 'Application name')
                stringParam('gitTag', '', 'Git tag')
                stringParam('filteredGitTag', '', 'Git tag')
            }
            steps {
                downstreamParameterized {
                    trigger('${filteredGitTag}-app-deployer'){
                        parameters{
                            predefinedProp('app', '${app}')
                            predefinedProp('gitTag', '${gitTag}')
                            predefinedProp('sitEnv', '${filteredGitTag}')
                        }
                    }
                }
            }
        }
    }
    catch (any) {
        println("Error creating job, Exception: ${any}")
        return false
    }
    return true
}

def build = Thread.currentThread().executable
createWebhookTriggerJob(build)
