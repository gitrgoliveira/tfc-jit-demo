FROM hashicorp/tfc-agent:latest

# Create the hooks directory and change the owner
RUN mkdir /home/tfc-agent/.tfc-agent
ADD --chown=tfc-agent:tfc-agent hooks /home/tfc-agent/.tfc-agent/hooks

USER root

# Create a directory we will later save our identity token to
RUN mkdir /.aws-workload
RUN chown -R tfc-agent:tfc-agent /.aws-workload

USER tfc-agent
