FROM rocker/geospatial:3.6.3

# install other packages (alphanumeric order)
RUN install2.r --error --deps TRUE \
    devtools \
    remotes \
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

