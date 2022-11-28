/*
 * File: generic.tf
 * Project: 01-kms
 * Created Date: Wednesday June 26th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Wednesday June 26th 2019 11:30:02 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




resource "aws_kms_key" "generic-kms-key" {
  description = "This Key is used for encryption and decryption of Services in ${var.env} Environment"
  tags        = merge(
                    var.tags,
                    map(
                        "Name", "${var.env}-generic-kms-key",
                    )
                )
}

resource "aws_kms_alias" "generic-kms-alias" {
  name          = "alias/${var.env}-generic-kms-alias"
  target_key_id = aws_kms_key.generic-kms-key.key_id
}
