/*
 * File: outputs.tf
 * Project: 01-kms
 * Created Date: Wednesday June 26th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Wednesday June 26th 2019 5:18:23 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




output "generic-kms-key-id"{
    value = aws_kms_key.generic-kms-key.key_id
}

output "generic-kms-key-arn"{
    value = aws_kms_key.generic-kms-key.arn
}

output "generic-kms-alias-arn"{
    value = aws_kms_alias.generic-kms-alias.arn
}
