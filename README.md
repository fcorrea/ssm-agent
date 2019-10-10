# ssm-agent
## Introduction
The SSM agent can do a variety of different things.  For example, it can inventory the software that is running on a fleet of instances. You can also run commands against those instances.  In September 2018, SSM added support for shell access to EC2 instances without running bastion hosts or distributing SSH keys.  While it was never designed to run inside of a Docker container, I thought that doing so would be interesting experiment.  

When I started, I wanted to see whether I could get the agent to run as a Fargate task because there is currently no interactive shell access for Fargate.  I quickly discovered that the default installation for EC2 assumes that you have access to EC2 metadata which is not accessible from a Fargate task.  Fortunately, I was able to work around this issue by configuring the agent as a [hybrid instance](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-managedinstances.html). 

The next issue I encountered involved stopping and restarting the agent after configuring it to use an activation code and ID.  The agent normally runs as a systemd process, however I couldn't run systemctl without privileged access so I had to find another work around.  I eventually stumbled across a project by Guido Draheim called [docker-systemctl-replacement](https://github.com/gdraheim/docker-systemctl-replacement) that allows you to run systemd controlled containers without starting the systemd daemon.  With this I could stop and restart the agent which was all that I needed to add the Fargate task as a "managed instance".

Getting the interactive shell working was the last and final hurdle. Ordinarily the agent adds the ssm-user to the instance during the install, but when it runs in a container you have to manually add it.  Once I added the ssm-user to the container image, I was able to successfully start an interactive shell with the task. 

## Running the SSM agent
Before building the image from the Dockerfile in the repository, you will need to update the entrypoint.sh script with the SSM activation code, ID, and region.  For instructions explaining how to setup a hybrid environment including how to create an activation, see https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-managedinstances.html.

## Running the Fargate task
The repository includes a sample task definition for running the SSM agent as a Fargate task. 

## The example
Getting the agent running as a Fargate task is a great accomplishment, but it's not that useful unless you can use it to interact with other applications running in the container, e.g. NGINX or Redis.  Docker provides a couple of examples of how you can [run multiple service in a container](https://docs.docker.com/config/containers/multi-service_container/). The example [in the example directory] uses supervisord to run the SSM agent and Redis.  