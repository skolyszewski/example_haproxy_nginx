# A containerized, loadbalanced webserver

The project can provision and configure a following environment:
* a VM in a cloud (AWS) with all required resources
* two containerized webserver instances on that VM, both serving different content
* a loadbalancer, routing the requests to the webservers with equal weights
* the service exposed on the Internet, via HTTP

Before running, configure AWS credentials.
Then, all you have to do is to run use terraform, and the environment should be ready in
a couple of minutes.
