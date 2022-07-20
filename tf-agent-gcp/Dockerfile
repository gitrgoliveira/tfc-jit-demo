FROM hashicorp/tfc-agent:latest
 
RUN mkdir /home/tfc-agent/.tfc-agent
ADD --chown=tfc-agent:tfc-agent hooks /home/tfc-agent/.tfc-agent/hooks
 
USER root
RUN mkdir /.gcp-workload
RUN chown -R tfc-agent:tfc-agent /.gcp-workload
 
USER tfc-agent
 
ENV GOOGLE_APPLICATION_CREDENTIALS=/.gcp-workload/app-credentials