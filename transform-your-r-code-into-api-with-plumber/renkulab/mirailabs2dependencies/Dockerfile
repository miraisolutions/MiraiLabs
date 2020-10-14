FROM renku/renkulab-r:4.0.0-renku0.10.4-0.6.3
# see https://github.com/SwissDataScienceCenter/renkulab-docker
# to swap this image for the latest version available

# Uncomment and adapt if code is to be included in the image
# COPY src /code/src

# Uncomment and adapt if your R or python packages require extra linux (ubuntu) software
# e.g. the following installs apt-utils and vim; each pkg on its own line, all lines
# except for the last end with backslash '\' to continue the RUN line
#
USER root
## Install required dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ## for package sodium, dependency of plumber
  libsodium-dev \
  ## for package git2r
  zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/
USER ${NB_USER}

# Version-stable CTAN repo from the tlnet archive at texlive.info, used in the
# TinyTeX installation: chosen as the frozen snapshot of the TeXLive release
# TeXLive 2018, frozen release snapshot 2019/02/27
ENV CTAN_REPO=https://www.texlive.info/tlnet-archive/2019/02/27/tlnet

# install the R dependencies
COPY install.R /tmp/
RUN R -f /tmp/install.R
