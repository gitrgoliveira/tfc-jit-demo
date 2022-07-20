#! /bin/sh
cd tf-agent-aws
docker build --rm --no-cache -t tf-agent-aws .

export TFC_AGENT_TOKEN=$(cat ../agent.token)

export TFC_AGENT_NAME=tf-agent-aws

docker run -e TFC_AGENT_TOKEN -e TFC_AGENT_NAME tf-agent-aws
