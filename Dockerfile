# perfSONAR Testpoint with bbr2 test harness support

FROM perfsonar/testpoint:latest

RUN yum -y install git wget tcsh
RUN yum -y groupinstall "Development tools"

RUN mkdir /src

# get updated version of ss tool
RUN cd /src; wget https://git.kernel.org/pub/scm/network/iproute2/iproute2.git/snapshot/iproute2-5.8.0.tar.gz 
RUN cd /src; tar xvzf iproute2-5.8.0.tar.gz
RUN cd /src/iproute2-5.8.0; ./configure; make; make install
RUN ln -s /usr/sbin/ss /bin/ss

# get updated verion of mpstat that support JSON output
RUN cd /src; git clone https://github.com/sysstat/sysstat.git
RUN cd /src/sysstat; ./configure; make; make install

#get iperf3 version that does different congestion control on even/odd numbered streams
RUN cd /src; git clone -b bbr2-testing https://github.com/esnet/iperf.git
#this will install in /usr/local, and not overwrite default iperf3
RUN cd /src/iperf ; ./configure ; make; make install

#Fix problem running tcpdump in privledged container
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump; ln -s /usr/bin/tcpdump /usr/sbin/tcpdump

#get test harness
# note: this will not work untill make repo public
#RUN cd /src; git clone https://github.com/esnet/bbrv2.git
#RUN ln -s /src/bbrv2/harness/ /harness

#other stuff that you will need to do manually for your environment
#  - create test-host.csv file
#  - add crontab entry if desired (and start crond)
#  configure /etc/pscheduler/default-archives

# will this work? Might need to merge above with perfsonar/testpoint container
CMD /usr/bin/supervisord -c /etc/supervisord.conf
