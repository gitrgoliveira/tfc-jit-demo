#! /bin/sh
cd tf-agent-vault
docker build --rm --no-cache -t tf-agent-vault .

export TFC_AGENT_TOKEN=$(cat ../agent.token)

export TFC_AGENT_NAME=tf-agent-vault

docker run -e TFC_AGENT_TOKEN -e TFC_AGENT_NAME tf-agent-vault
