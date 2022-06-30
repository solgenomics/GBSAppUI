FROM debian:bullseye
# open port 8080
#
EXPOSE 8080

# create directory layout
#

# install system dependencies
#
RUN apt-get update -y
RUN apt-get install -y git r-base python3.10 wget libcurl4 apt-utils cpanminus perl-doc vim less htop ack libslurm-perl screen lynx iputils-ping gcc g++ libc6-dev make cmake zlib1g-dev ca-certificates slurmd slurmctld munge libbz2-dev libncurses5-dev libncursesw5-dev liblzma-dev libcurl4-gnutls-dev libssl-dev
#clone GBSApp from github
RUN git clone https://github.com/bodeolukolu/GBSapp.git
#clone bcftools
RUN git clone https://github.com/samtools/bcftools.git
#clone samtools
RUN git clone --recurse-submodules https://github.com/samtools/htslib.git
#install picard
RUN wget https://github.com/broadinstitute/picard/releases/download/2.25.6/picard.jar
#install GATK
RUN wget -O GATK4.2.5.0.zip "https://github.com/broadinstitute/gatk/releases/download/4.2.5.0/gatk-4.2.5.0.zip" && \
    unzip GATK4.2.5.0.zip
#install java
RUN wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u322-b06/OpenJDK8U-jdk_x64_linux_hotspot_8u322b06.tar.gz && \
    tar -xvf OpenJDK8U-jdk_x64_linux_hotspot_8u322b06.tar.gz; rm *tar.gz
#install NextGenMap
RUN update-ca-certificates && \
    git clone https://github.com/Cibiv/NextGenMap.git && cd NextGenMap && git checkout $VERSION_ARG && mkdir -p build && cd build && cmake .. && make && cp -r ../bin/ngm-*/* /usr/bin/ && cd .. && rm -rf NextGenMap && \
    rm -rf /var/lib/apt/lists/*
#install ggplot2
RUN mkdir -p R && \
    cd ./R && \
    R -e 'install.packages("ggplot2", dependencies = TRUE, repos="http://cran.r-project.org", lib="./")'
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN mkdir /var/log/gbsappui
RUN cpanm Catalyst Catalyst::Restarter Catalyst::View::HTML::Mason
#move all dependencies to tools
RUN mkdir ./GBSapp/tools/ && \
    rm GATK* && \
    mv picard.jar ./GBSapp/tools/ && \
    mv NextGenMap ./GBSapp/tools/ && \
    mv gatk-4.2.5.0 ./GBSapp/tools/ && \
    mv R ./GBSapp/tools/ && \
    mv bcftools ./GBSapp/tools/ && \
    mv jdk8u322-b06 ./GBSapp/tools/ && \
    mv ./GBSapp/examples/config.sh ./GBSapp/examples/proj/
RUN chmod 777 /var/spool/ \
    && mkdir /var/spool/slurmstate \
    && chown slurm:slurm /var/spool/slurmstate/ \
    && ln -s /var/lib/slurm-llnl /var/lib/slurm \
    && mkdir -p /var/log/slurm
RUN bash devel/run_docker.sh
# start services when running container...
ENTRYPOINT ["/entrypoint.sh"]
