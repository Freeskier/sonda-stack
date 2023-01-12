FROM nginx:latest

ARG ELASTIC_PASSWORD

ENV USERNAME "admin"
ENV PASSWORD $ELASTIC_PASSWORD

COPY ./config/nginx.conf /etc/nginx/conf.d/nginx.conf

RUN apt-get update && apt-get install apache2-utils -y

RUN mkdir /etc/apache2

RUN htpasswd -ibc /etc/apache2/.htpasswd ${USERNAME} ${PASSWORD}