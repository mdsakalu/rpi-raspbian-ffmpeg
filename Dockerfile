FROM resin/rpi-raspbian:jessie
MAINTAINER Michael Sakaluk "michaelsakaluk@gmail.com"

ENV X264_VERSION 20151004-2245-stable
ENV FFMPEG_VERSION 2.8

COPY qemu-arm-static /usr/bin/

RUN apt-get update
RUN apt-get install -y --force-yes checkinstall autoconf automake build-essential libass-dev libfreetype6-dev \
  libtheora-dev libtool libvorbis-dev pkg-config texinfo zlib1g-dev libv4l-dev wget

RUN mkdir -p /root/packages

# x264
ADD http://ftp.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-${X264_VERSION}.tar.bz2 /root/build/x264-snapshot-${X264_VERSION}.tar.bz2
WORKDIR /root/build
RUN mkdir x264 && tar xjf x264-snapshot-${X264_VERSION}.tar.bz2 -C x264 --strip-components=1
ADD ./resource/configure-x264.sh /root/build/x264/configure.sh
WORKDIR /root/build/x264
RUN chmod a+x configure.sh
RUN ./configure.sh && make -j$(nproc)
RUN echo "x264 0.$(grep '#define X264_BUILD' < x264.h | sed 's/^.* \([1-9][0-9]*\).*$/\1/')" > description-pak && \
        checkinstall -Dy --install=yes --nodoc --pkgname="x264" --pakdir="/root/packages" \
        --pkgversion="${X264_VERSION}" make -i install

# ffmpeg
ADD https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 /root/build/ffmpeg-${FFMPEG_VERSION}.tar.bz2
WORKDIR /root/build
RUN mkdir ffmpeg && tar xjf ffmpeg-${FFMPEG_VERSION}.tar.bz2 -C ffmpeg --strip-components=1
ADD ./resource/configure-ffmpeg.sh /root/build/ffmpeg/configure.sh
WORKDIR /root/build/ffmpeg
RUN chmod a+x configure.sh
RUN ./configure.sh && make -j$(nproc)
RUN echo "ffmpeg ${FFMPEG_VERSION}" > description-pak && \
        checkinstall -Dy --install=yes --nodoc --pkgname="ffmpeg" --pkgversion="${FFMPEG_VERSION}" --pakdir="/root/packages" make -i install
        
# cleanup
WORKDIR /root
RUN apt-get purge -y autoconf automake build-essential libass-dev libfreetype6-dev \
  libtheora-dev libtool libvorbis-dev pkg-config texinfo zlib1g-dev libv4l-dev wget
RUN apt-get -y --purge autoremove
RUN rm -rf /root/build
RUN rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
