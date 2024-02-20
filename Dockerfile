FROM node:lts-slim
###there no need for multistage build
COPY ip_reverse /opt/
WORKDIR /opt/ip_reverse
RUN npm install
CMD ["npm", "run", "start"]
