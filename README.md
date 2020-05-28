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

First, provision the VM with `terraform`. Since we're using ssh keys generated on the fly,
you can copy the private part by running `terraform output ssh_private_key > <path>`.
We'll use that key for with ansible by adding `--private-key <path>` flag
to `ansible-playbook` command. Obviously, you can add the identity instead.
To run the ansible, just use
`ansible-playbook -i server.aws_ec2.yaml provision.yaml -u ubuntu --private-key <path>`
