FROM rocker/geospatial:3.6.3

# set default umask
RUN echo "umask 002" >> /etc/bash.bashrc
# have Rstudio server use the default umask https://docs.rstudio.com/ide/server-pro/access-and-security.html#umask
RUN echo "server-set-umask=0" >> /etc/rstudio/rserver.conf


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
  pymc3 \
  PyPDF2 \
  rpy2


# install other packages (alphanumeric order)
RUN install2.r --error --deps TRUE \
    argparse \
    # arrow \
    config \
    devtools \
    fs \
    ggrepel \
    openxlsx \
    pacman \
    pkgdown \
    remotes \
    # install temporary development version until cran version is updated https://arrow.apache.org/docs/r/index.html
    && R -e 'install.packages("arrow", repos = "https://dl.bintray.com/ursalabs/arrow-r"); library(arrow)' \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds


# install tmb related packages
RUN install2.r --error --deps TRUE \
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

