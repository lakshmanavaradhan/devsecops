FROM node:hydrogen-slim
###there no need for multistage build

COPY ip_reverse /opt/
WORKDIR /opt/ip_reverse
RUN apt-get update && \
    apt-get upgrade zlib1g && \
    npm install
CMD ["npm", "run", "start"]
