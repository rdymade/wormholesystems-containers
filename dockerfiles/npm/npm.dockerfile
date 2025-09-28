FROM node:latest

WORKDIR /var/www/html

RUN npm install -g vue-tsc

ENTRYPOINT ["npm"]