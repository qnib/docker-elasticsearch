###### ES
# A docker image that includes
# - elasticsearch 
FROM qnib/java8

ADD etc/yum.repos.d/elasticsearch.repo /etc/yum.repos.d/
RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

# elasticsearch
RUN yum install -y elasticsearch
ADD etc/supervisord.d/elasticsearch.ini /etc/supervisord.d/elasticsearch.ini
ADD opt/qnib/bin/start_elasticsearch.sh /opt/qnib/bin/
ADD etc/consul.d/check_elasticsearch.json /etc/consul.d/
ADD etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/
ENV ES_CLUSTER_NAME qnib2015
EXPOSE 9200
VOLUME ["/var/lib/elasticsearch"]
