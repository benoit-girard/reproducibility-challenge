FROM lpenz/debian-lenny-i386

LABEL maintainer="Arnaud Legrand <arnaud.legrand@imag.fr>"

# Software dependencies
RUN apt-get update \
	&& apt-get install -y --force-yes gcc g++ make wget unzip subversion patch \
	   less libqt3-mt libqt3-headers libqt3-mt-dev qt3-dev-tools 

# Code dowloading and assembly dependencies
RUN apt-get update \
 	&& apt-get install -y --force-yes wget unzip subversion patch less

# Downloading GTNetS
RUN cd /root; svn checkout svn://scm.gforge.inria.fr/svn/simgrid/contrib/trunk/GTNetS/
# Downloading SimGrid
RUN cd /root; wget https://gforge.inria.fr/frs/download.php/file/21430/simgrid-3.3.tar.gz

# Building GTNetS
RUN cd /root/GTNetS/; unzip gtnets-current.zip ; tar zxvf gtnets-current-patch.tgz
RUN cd /root/GTNetS/gtnets-current; cat ../00*.patch | patch -p1
RUN cd /root/GTNetS/gtnets-current; ln -sf Makefile.linux Makefile && make depend && make opt

# Installing GTNetS
RUN cd /root/GTNetS/gtnets-current/ && \
    mkdir -p /root/usr/lib/ &&         \
    ln -sf `pwd`/libgtsim-opt.so /root/usr/lib/libgtnets.so && \
    ln -sf `pwd`/libgtsim-opt.so /usr/lib/libgtnets.so &&      \
    mkdir -p /root/usr/include/ &&    \
    cp -fr SRC/*.h /root/usr/include/

# Building SimGrid
RUN cd /root/ && tar zxf simgrid-3.3.tar.gz
RUN cd /root/simgrid-3.3/ && \
    ./configure --with-gtnets=/root/usr/ && \
    export LD_LIBRARY_PATH=/root/usr/lib/libgtnets.so && \
    ldconfig && \
    make

RUN apt-get clean
