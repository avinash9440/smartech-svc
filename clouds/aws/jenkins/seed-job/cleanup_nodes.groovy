/*
 * File: cleanup_nodes.groovy
 * Project: seed-job
 * Created Date: Saturday August 3rd 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Saturday August 3rd 2019 7:55:52 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




import hudson.model.Hudson.*
import hudson.model.Hudson.instance.*

// cleanup unresponsive slaves

for (aSlave in hudson.model.Hudson.instance.slaves) {
  println('====================');
  println('Name: ' + aSlave.name);
  println('getLabelString: ' + aSlave.getLabelString());
  println('getNumExectutors: ' + aSlave.getNumExecutors());
  println('getRemoteFS: ' + aSlave.getRemoteFS());
  println('getMode: ' + aSlave.getMode());
  println('getRootPath: ' + aSlave.getRootPath());
  println('getDescriptor: ' + aSlave.getDescriptor());
  println('getComputer: ' + aSlave.getComputer());
  println('\tcomputer.isAcceptingTasks: ' + aSlave.getComputer().isAcceptingTasks());
  println('\tcomputer.isLaunchSupported: ' + aSlave.getComputer().isLaunchSupported());
  println('\tcomputer.getConnectTime: ' + aSlave.getComputer().getConnectTime());
  println('\tcomputer.getDemandStartMilliseconds: ' + aSlave.getComputer().getDemandStartMilliseconds());
  println('\tcomputer.isOffline: ' + aSlave.getComputer().isOffline());
  println('\tcomputer.countBusy: ' + aSlave.getComputer().countBusy());
  
  if (aSlave.getComputer().isOffline()) {
    println('Shutting down node!!!!');
    aSlave.getComputer().setTemporarilyOffline(true,null);
    aSlave.getComputer().doDoDelete();
  }
  else {
    println('\tcomputer.getLog: ' + aSlave.getComputer().getLog());
    println('\tcomputer.getBuilds: ' + aSlave.getComputer().getBuilds());
  }
}