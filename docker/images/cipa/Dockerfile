FROM centos:centos7.6.1810


# docker module metadata
LABEL module.name="cipa"
LABEL module.version="v0.0.1"

RUN yum update -y && yum install -y git wget curl gcc gcc-gfortran gcc-c++ vim zlib-devel bzip2-devel xz-devel pcre2-devel libcurl-devel
RUN yum groupinstall -y 'Development Tools'

RUN wget -P /tmp/ -c https://cran.r-project.org/src/base/R-4/R-4.0.2.tar.gz -O - | tar -xz -C /tmp/
WORKDIR /tmp/R-4.0.2
RUN sh configure --prefix=/usr/local --with-x=no --with-readline=no
RUN make -j4
RUN make install
RUN rm -rf /tmp/*
RUN Rscript -e 'install.packages(pkgs="https://cran.r-project.org/package=cmaes&version=1.0-11", repos=NULL)'
RUN Rscript -e 'install.packages(pkgs="https://cran.r-project.org/package=deSolve&version=1.28", repos=NULL)'
RUN Rscript -e 'install.packages(pkgs="https://cran.r-project.org/package=getopt&version=1.20.3", repos=NULL)'
RUN Rscript -e 'install.packages(pkgs="https://cran.r-project.org/package=optparse&version=1.6.6", repos=NULL)'

# Create a directory to clone the repository
ARG CIPA_ROOT_DIR=/app
ENV APP_DIR=${CIPA_ROOT_DIR}
RUN mkdir ${APP_DIR}
# Clone the repository and specify the location
RUN git clone https://github.com/VCCRI/cipa_model_validation.git ${APP_DIR}/cipa
RUN rm -rf ${APP_DIR}/cipa/hERG_fitting/resutls/*

WORKDIR ${APP_DIR}/cipa/hERG_fitting/models

RUN Rscript -e 'system("R CMD SHLIB hergmod.c")'

RUN mkdir ${APP_DIR}/cipa/hERG_fitting/logs

WORKDIR ${APP_DIR}/cipa/hERG_fitting

COPY script.sh entrypoint.sh
RUN chmod +x entrypoint.sh
# ENTRYPOINT [ "./entrypoint.sh" ]