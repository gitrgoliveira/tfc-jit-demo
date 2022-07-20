#! /bin/sh
cd tf-agent-gcp
docker build --rm --no-cache -t tf-agent-gcp .

export TFC_AGENT_TOKEN=$(cat ../agent.token)

export TFC_AGENT_NAME=tf-agent-gcp

docker run -e TFC_AGENT_TOKEN -e TFC_AGENT_NAME tf-agent-gcp
