FROM bitnami/mysql:8.4

ADD ./config/nacos/nacos-schema.sql /docker-entrypoint-initdb.d/nacos-schema.sql

# https://github.com/bitnami/containers/blob/main/bitnami/mysql/9.3/debian-12/Dockerfile
EXPOSE 3306
USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/mysql/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/mysql/run.sh" ]
