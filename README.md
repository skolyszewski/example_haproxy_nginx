# A containerized, loadbalanced webserver

The project can provision and configure a following environment:

* a VM in a cloud (AWS) with all required resources
* two containerized webserver instances on that VM, both serving different content
* a loadbalancer, routing the requests to the webservers with equal weights
* the service exposed on the Internet, via HTTP

# Dependencies

Since this uses ansible ec2 inventory plugin, `boto3` and `botocore` packages are required.
AWS Credentials have to be configured both for `terraform` and `ansible`.
`AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID` envs work for both tools.

# Running

First, provision the VM with terraform. Since we're using ssh keys generated on the fly,
you can copy the private part by running `terraform output ssh_private_key > <path>`.
We'll use that key for with ansible by adding `--private-key <path>` flag
to `ansible-playbook` command. Obviously, you can add the identity instead.
To run the ansible, just use
`ansible-playbook -i server.aws_ec2.yaml provision.yaml -u ubuntu --private-key <path>`

# Design decisions

* The project uses AWS as it allowed me to pick it up instantly.
* SSH Keypair is generated on the fly to allow anyone to run this from scratch.
    * but because of that, the key is in the stdout;
    * and whoever is running that, has to copy that key to a file to use with ansible.
* Initially, this was meant to use terraform's `local-exec`, but:

    1) it does not scale well (it would definitely be sufficient for that case);
    2) has to be scripted around;
    3) is great for one-click provisioning, but makes it a little harder
    to tweak something after the terraform is done.

* Instead, EC2 Inventory plugin for ansible is used.
* Containerized nginx instances have some hardcoded values
(# of instances, paths). Scaling could be freed up by parametrizing
compose file and playbooks, but since this is not a requirement, it is 
as it is now.
