/*
 * File: README.md
 * Project: svc
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:27:22 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.

 */



# Sequence of implementing the modules

1. kms
2. iam
3. s3
4. network
5. 

# Terraform Commands to implement the modules

## Plan 

`terraform plan -out /tmp/<mod-name>.plan -target=module.<module-name> -var-file=<environment-var-file>`

e.g.: `terraform plan -out /tmp/s3.plan -target=module.s3  -var-file=vars/svc.tfvars`

## Apply

`terraform apply "/tmp/<mod-name>.plan"`

e.g.: `terraform apply "/tmp/s3.plan"`
