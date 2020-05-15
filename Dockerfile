FROM alpine:latest

ARG SRC

WORKDIR /usr/src

COPY . .

# Install dependency packages
RUN apk update &&\
apk add bash automake libtool m4 autoconf gcc g++ musl-dev expat expat-dev make cmake python python2-dev python3-dev py-pip apr-dev apr-util-dev zip openjdk11 linux-headers &&\
apk add log4cxx --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing &&\
apk add log4cxx-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

# Build omniORB
RUN cd &&\
wget http://omniorb.sourceforge.net/snapshots/omniORB-4.2.4.tar.bz2 &&\
tar -xvf omniORB-4.2.4.tar.bz2 &&\
cd omniORB-4.2.4/ &&\
mkdir build &&\
cd build &&\
../configure &&\
make &&\
make install

# Build omniORBpy
RUN cd &&\
wget http://sourceforge.net/projects/omniorb/files/omniORBpy/omniORBpy-4.2.4/omniORBpy-4.2.4.tar.bz2/download &&\
tar -xvf download &&\
rm download &&\
cd omniORBpy-4.2.4/ &&\
mkdir build &&\
cd build &&\
../configure &&\
make &&\
make install

# Build Xerces
RUN cd &&\
wget http://apache.mirrors.hoobly.com//xerces/c/3/sources/xerces-c-3.2.3.tar.bz2 &&\
tar -xvf xerces-c-3.2.3.tar.bz2 &&\
cd xerces-c-3.2.3 &&\
./configure --disable-threads --disable-network --disable-shared CXXFLAGS=-O1 CFLAGS=-O1 &&\
cd src &&\
make

# Build XSD
RUN cd && \
wget https://www.codesynthesis.com/download/xsd/4.0/xsd-4.0.0+dep.tar.bz2 &&\
tar -xvf xsd-4.0.0\+dep.tar.bz2  &&\
cd xsd-4.0.0\+dep/ &&\
make CPPFLAGS="-fPIC -I../xerces-c-3.2.3/src" LDFLAGS="-fPIC -static -L../xerces-c-3.2.3/src/.libs" &&\
make CPPFLAGS="-fPIC -I../xerces-c-3.2.3/src" LDFLAGS="-fPIC -static -L../xerces-c-3.2.3/src/.libs" install &&\
wget -O /usr/local/include/xsd/cxx/parser/expat/elements.txx https://git.codesynthesis.com/cgit/xsd/xsd/tree/libxsd/xsd/cxx/parser/expat/elements.txx

# Build Boost
RUN cd &&\
wget https://sourceforge.net/projects/boost/files/boost/1.53.0/boost_1_53_0.tar.gz/download &&\
tar -xvf download &&\
rm download &&\
cd boost_1_53_0 &&\
./bootstrap.sh &&\
./bjam cxxflags=-fPIC cflags=-fPIC -a install || true

# Set env variables and build REDHAWK
RUN cd /usr/src &&\
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk &&\
export PATH="$JAVA_HOME/bin:${PATH}" &&\
export PYTHONPATH=/usr/local/lib/python2.7/site-packages &&\
export OSSIEHOME=/usr/local/redhawk/core &&\
export SDRROOT=/var/redhawk/sdr &&\
if [ "$SRC" = "local" ] ; then \
cd redhawk-src-2.2.6-local && yes | /bin/bash ./redhawk-install.sh ; else \
wget https://github.com/RedhawkSDR/redhawk/releases/download/2.2.6/redhawk-src-2.2.6.tar.gz &&\
tar zxvf redhawk-src-2.2.6.tar.gz &&\
cd redhawk-src-2.2.6 && yes | /bin/bash ./redhawk-install.sh; fi
