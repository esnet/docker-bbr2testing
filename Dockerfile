# perfSONAR Testpoint with bbr2 test harness support

FROM perfsonar/testpoint:latest

RUN yum -y groupinstall "Development tools"
RUN yum -y install git wget libpcap-devel

RUN mkdir /src

# get latest version of ss tool
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

# install tstat in case it turns out to be useful
RUN cd /src; wget http://tstat.polito.it/download/tstat-3.1.1.tar.gz
RUN cd /src; tar xvzf tstat-3.1.1.tar.gz
RUN cd /src/tstat-3.1.1; ./configure;  make; make install

#Fix problem running tcpdump in privledged container
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump; ln -s /usr/bin/tcpdump /usr/sbin/tcpdump

#overwrite default perfsonar/testpoint supervisord.conf file
COPY supervisord.conf /etc/supervisord.conf
CMD /usr/bin/supervisord -c /etc/supervisord.conf
