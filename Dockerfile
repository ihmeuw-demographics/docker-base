FROM rocker/geospatial:4.0.3

# set default umask
RUN echo "umask 002" >> /etc/bash.bashrc
# use version specific `Rprofile.site` to fix Rstudio umask
RUN echo "Sys.umask(2)" >> /usr/local/lib/R/etc/Rprofile.site


# install system level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    dos2unix \
    libpython3-dev \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*


# change default python to python3
RUN echo "alias python=python3" >> /etc/bash.bashrc

# install pip dependencies
RUN python3 -m pip --no-cache-dir install --upgrade \
  pip \
  setuptools
# install public python dependencies
RUN python3 -m pip --no-cache-dir install --upgrade \
  emmodel \
  pymc3 \
  PyPDF2 \
  pyyaml \
  regmod \
  rpy2
# fix rpy2 per solution here https://github.com/darribas/gds_env/issues/2 with path to `libR.so`
ENV LD_LIBRARY_PATH=/usr/local/lib/R/lib/:${LD_LIBRARY_PATH}


# install other packages (alphanumeric order)
RUN install2.r --error --deps TRUE \
    argparse \
    arm \
    arrow \
    bench \
    config \
    demogR \
    devtools \
    fs \
    ggrepel \
    HMDHFDplus \
    janitor \
    openxlsx \
    pacman \
    pkgdown \
    pscl \
    profvis \
    readstata13 \
    remotes \
    rjson \
    visNetwork \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds


# install tmb related packages
RUN install2.r --error --deps TRUE \
    Matrix \
    TMB \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
RUN R -e "remotes::install_github('mlysy/TMBtools', dependencies = TRUE)"


# install rstan related packages
# based off of Dockerfile from https://hub.docker.com/r/jrnold/rstan/dockerfile
RUN install2.r --error --deps TRUE \
    rstan \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Global site-wide config -- neeeded for building packages
RUN mkdir -p $HOME/.R/ \
    && echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -flto -ffat-lto-objects  -Wno-unused-local-typedefs \n" >> $HOME/.R/Makevars

# Config for rstudio user
RUN mkdir -p $HOME/.R/ \
    && echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -flto -ffat-lto-objects  -Wno-unused-local-typedefs -Wno-ignored-attributes -Wno-deprecated-declarations\n" >> $HOME/.R/Makevars \
    && echo "rstan::rstan_options(auto_write = TRUE)\n" >> /home/rstudio/.Rprofile \
    && echo "options(mc.cores = parallel::detectCores())\n" >> /home/rstudio/.Rprofile

# Install rstan
RUN install2.r --error --deps TRUE \
    rstan \
    loo \
    bayesplot \
    rstanarm \
    rstantools \
    shinystan \
    ggmcmc \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds


# install base 'ihmeuw-demographics' R packages from github
RUN installGithub.r --deps TRUE \
    ihmeuw-demographics/demUtils \
    ihmeuw-demographics/hierarchyUtils \
    ihmeuw-demographics/demCore \
    ihmeuw-demographics/demViz \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# install 'ihmeuw-demographics/popMethods' R package from github while ignoring warning about not overwriting Makevars file
RUN export R_REMOTES_NO_ERRORS_FROM_WARNINGS=true \
    && installGithub.r \
    ihmeuw-demographics/popMethods \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

