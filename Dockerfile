FROM centos/systemd

MAINTAINER "Caleb Fultz" caleb@fultz.dev

RUN yum -y install epel-release; yum update; yum -y upgrade; yum -y install nginx wget; yum clean all; systemctl enable nginx.service
RUN echo 'Done'

EXPOSE 80
EXPOSE 443

COPY nginx.conf /etc/nginx/nginx.conf

CMD ["/usr/sbin/init"]

HEALTHCHECK CMD wget -q --spider localhost
