ARG BASE_IMAGE=partofaplan/weblogic-base:latest
FROM ${BASE_IMAGE}

USER root

ARG WDT_VERSION=4.3.8

# Bump DNF timeout/retries to make CI builds resilient to flaky Oracle yum mirrors
RUN printf '\n# Added for CI builds\nretries=10\ntimeout=300\n' >> /etc/dnf/dnf.conf && \
    microdnf install -y unzip curl && microdnf clean all

RUN mkdir -p /u01/wdt && \
    curl -fL "https://github.com/oracle/weblogic-deploy-tooling/releases/download/release-${WDT_VERSION}/weblogic-deploy.zip" -o /tmp/weblogic-deploy.zip && \
    unzip /tmp/weblogic-deploy.zip -d /u01/wdt && \
    rm /tmp/weblogic-deploy.zip

COPY model/model.yaml /u01/wdt/models/model.yaml
COPY model/archive.zip /u01/wdt/models/archive.zip

RUN chown -R oracle:oracle /u01/wdt

USER oracle

ENV WDT_MODEL_HOME=/u01/wdt/models \
    WDT_DIR=/u01/wdt/weblogic-deploy \
    WDT_ARCHIVE_FILES=/u01/wdt/models/archive.zip \
    WDT_MODEL_FILE=model.yaml
