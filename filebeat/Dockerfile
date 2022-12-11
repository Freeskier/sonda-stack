ARG ELK_VERSION

FROM docker.elastic.co/beats/filebeat:${ELK_VERSION}

CMD  filebeat export template > filebeat.template.json \
    cat filebeat.template.json | curl -u '${ELASTIC_USERNAME}:${ELASTIC_PASSWORD}' -XPUT 'https://elasticsearch:9200/_template/filebeat-${ELK_VERSION}' -d @- --insecure