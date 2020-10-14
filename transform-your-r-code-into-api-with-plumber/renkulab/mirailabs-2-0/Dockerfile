FROM registry.renkulab.io/gustavo.martinez/mirailabs2dependencies:0d14a6b

# All dependencies now pre-installed in the mirailabs2dependencies docker image

# Uncomment and adapt if code is to be included in the image
# COPY src /code/src

# Uncomment and adapt if your R or python packages require extra linux (ubuntu) software
# e.g. the following installs apt-utils and vim; each pkg on its own line, all lines
# except for the last end with backslash '\' to continue the RUN line
# 

#USER root
#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#    apt-utils \
#    ssh-keygen
#    vim
#USER ${NB_USER}

COPY entrypoint.sh /entrypoint.sh
RUN /entrypoint.sh
  
# install the R dependencies
#COPY install.R /tmp/
#RUN R -f /tmp/install.R
