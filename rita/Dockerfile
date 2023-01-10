FROM ubuntu:20.04

COPY ./scripts/install.sh /

COPY ./scripts/cronjob.sh /

RUN chmod +x install.sh

RUN chmod 0644 cronjob.sh

RUN chmod +x cronjob.sh

RUN apt-get update && apt-get install cron -y

RUN crontab -l | { cat; echo "* * * * * /cronjob.sh"; } | crontab -

RUN /install.sh --disable-zeek --disable-mongo

CMD cron && bash