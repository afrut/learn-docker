FROM ubuntu:22.04
RUN apt update
RUN apt install -y openjdk-17-jre-headless
RUN apt install -y python3 python3-pip
RUN pip3 install dnspython==2.1.0
RUN pip3 install confluent-kafka==2.1.0
RUN pip3 install apache-beam[gcp]==2.45.0