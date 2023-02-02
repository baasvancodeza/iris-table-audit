ARG IMAGE=intersystemsdc/iris-community
FROM $IMAGE

USER root

WORKDIR /home/irisowner/irisdev

ARG NAMESPACE="IRISAPP"

RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /home/irisowner/irisdev
COPY . .
RUN chmod -R 777 /home/irisowner/irisdev

USER ${ISC_PACKAGE_MGRUSER}

RUN iris start IRIS && \
	iris session IRIS < iris.script && \
    iris stop IRIS quietly
