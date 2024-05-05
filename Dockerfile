FROM mcr.microsoft.com/mssql/server:2019-latest

# Switch to root user for access to apt-get install
USER root

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=bi@123456

RUN apt-get -y update  && \
    apt-get install -y curl && \
    apt-get install -y dos2unix


# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Bundle app source
COPY setup.sql /usr/src/app
COPY import-data.sh /usr/src/app
COPY entrypoint.sh /usr/src/app

# Convert import-data.sh to UNIX format
RUN dos2unix *

# Grant permissions for the import-data script to be executable
RUN chmod +x /usr/src/app/import-data.sh


# Switch back to mssql user and run the entrypoint script
#USER mssql
#ENTRYPOINT /bin/bash ./entrypoint.sh

FROM python:3.11-bullseye as spark-base

ARG SPARK_VERSION=3.4.3

# Install tools required by the OS
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo \
      curl \
      vim \
      unzip \
      rsync \
      openjdk-11-jdk \
      build-essential \
      software-properties-common \
      ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Setup the directories for our Spark and Hadoop installations
ENV SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

# Download and install Spark
RUN curl https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz -o spark-${SPARK_VERSION}-bin-hadoop3.tgz \
 && tar xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz --directory /opt/spark --strip-components 1 \
 && rm -rf spark-${SPARK_VERSION}-bin-hadoop3.tgz



FROM spark-base as pyspark-base

# Install python deps
COPY requirements/requirements.txt .
RUN pip3 install -r requirements.txt



FROM pyspark-base as pyspark

# Setup Spark related environment variables
ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV SPARK_MASTER="spark://spark-master:7077"
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3

# Copy the default configurations into $SPARK_HOME/conf
COPY conf/spark-defaults.conf "$SPARK_HOME/conf"

RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*

ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

# Copy appropriate entrypoint script
COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]


