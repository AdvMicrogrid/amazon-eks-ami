# Amazon EKS AMI Build Specification

This repository contains resources and configuration scripts for building a
custom EKS AMI with [HashiCorp Packer](https://www.packer.io/). This is based
on the [same configuration](https://github.com/awslabs/amazon-eks-ami) that
Amazon EKS uses to create the official Amazon EKS-optimized AMI.

## Differences from Official AMI

The file `CHANGELOG_AMS.md` in the project root contains the list of changes
made in this fork. The overarching aim of these changes is stability. Most
notably, this uses [Ubuntu 18.04](http://releases.ubuntu.com/18.04/)
instead of [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/).  Because
Ubuntu uses ext4 rather than xfs, it avoids the [disk corruption](https://github.com/awslabs/amazon-eks-ami/issues/51)
issue affecting the official AMI. Likewise, setting up Docker log rotation
prevents worker nodes from [failing due to full disks.](https://github.com/awslabs/amazon-eks-ami/issues/36)

## 🚀 Getting started

If you are new to Amazon EKS, we recommend that you follow
our [Getting Started](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
chapter in the Amazon EKS User Guide. If you already have a cluster, and you
want to launch a node group with your new AMI, see [Launching Amazon EKS Worker
Nodes](https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html).

## 🔢 Pre-requisites

You must have [Packer](https://www.packer.io/) version 1.8.0 or later installed on your local system.
For more information, see [Installing Packer](https://www.packer.io/docs/install/index.html)
in the Packer documentation. You must also have AWS account credentials
configured so that Packer can make calls to AWS API operations on your behalf.
For more information, see [Authentication](https://www.packer.io/docs/builders/amazon.html#specifying-amazon-credentials)
in the Packer documentation.

## 👷 Building the AMI

A Makefile is provided to build the AMI, but it is just a small wrapper around
invoking Packer directly. You can initiate the build process by running the
following command in the root of this repository:

**For a new version**

1. Take a look at the upstream for this repo and try to integrate the changes.
2. Switch the all to the version you want to build.
3. Push to the repo, the master branch will be built by Jenkins


The Makefile runs Packer with the `eks-worker-bionic.json` build specification
template and the [amazon-ebs](https://www.packer.io/docs/builders/amazon-ebs.html)
builder. An instance is launched and the Packer [Shell
Provisioner](https://www.packer.io/docs/provisioners/shell.html) runs the
`install-worker.sh` script on the instance to install software and perform other
necessary configuration tasks.  Then, Packer creates an AMI from the instance
and terminates the instance after the AMI is created.

> **Note**
> The default instance type to build this AMI does not qualify for the AWS free tier.
> You are charged for any instances created when building this AMI.

The [EKS Terraform module](https://github.com/AdvMicrogrid/terraform-aws-eks)
simplifies deployment of infrastructure for an EKS cluster.

If you are just getting started with Amazon EKS, we recommend that you follow
our [Getting Started](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
chapter in the Amazon EKS User Guide. If you already have a cluster, and you
want to launch a node group with your new AMI, see [Launching Amazon EKS Worker
Nodes](https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html)
in the Amazon EKS User Guide.

## 👩‍💻 Using the AMI

The [AMI user guide](doc/USER_GUIDE.md) has details about the AMI's internals, and the [EKS user guide](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami) explains how to use a custom AMI in a managed node group.

## 🔒 Security

For security issues or concerns, please do not open an issue or pull request on GitHub. Please report any suspected or confirmed security issues to AWS Security https://aws.amazon.com/security/vulnerability-reporting/

## ⚖️ License Summary

This sample code is made available under a modified MIT license. See the LICENSE file.
