FROM sharpreflections/centos6-build-binutils
LABEL maintainer="dennis.brendel@sharpreflections.com"

ARG prefix=/p/hpc/psp/GammaRay
ARG version=2.11.2
WORKDIR /build/

COPY --from=sharpreflections/centos6-build-qt:qt-5.12.0_gcc-8.3.1 /p/ /p/

RUN yum -y install epel-release centos-release-scl && \
    # the repo files still point to the centos mirrorlist which is down
    sed --in-place '/mirrorlist.*/d;s,^# \(.*\)=.*,\1=http://vault.centos.org/centos/6/sclo/$basearch/sclo/,'  /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    sed --in-place '/mirrorlist.*/d;s,^#\(.*\)=.*,\1=http://vault.centos.org/centos/6/sclo/$basearch/rh/,'  /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
    yum -y install sclo-git212 cmake3 devtoolset-8 mesa-libGL-devel && \
    source /opt/rh/sclo-git212/enable  && \
    source /opt/rh/devtoolset-8/enable && \
    git clone https://github.com/KDAB/GammaRay.git --branch v$version && \
    mkdir GammaRay-build && cd GammaRay-build && \
    cmake3 ../GammaRay -DCMAKE_PREFIX_PATH=/p/hpc/psp/Qt/Qt-5.12.0-gcc-8.3.1 \
                       -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=OFF \
                       -DCMAKE_INSTALL_PREFIX=$prefix/gammaray-$version && \
    make -j $(nproc) && \
    make install && \
    rm -rf /build/* && rm -rf /p/hpc/psp/Qt && \
    yum -y history undo last && yum clean all

