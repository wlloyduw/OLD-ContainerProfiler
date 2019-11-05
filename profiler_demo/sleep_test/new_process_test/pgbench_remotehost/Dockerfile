# Install anaconda Python stack and some other useful tools
FROM ubuntu
RUN apt-get update
RUN apt-get install -y tar git curl wget dialog net-tools build-essential

# Install editors:
RUN apt-get install -y vim nano

# Install gfortran
RUN apt-get install -y gfortran

# Commands necessary for building the Container through ubuntu
RUN apt-get install -y python
RUN apt-get install -y python-pip
RUN apt-get install -y bc
RUN apt-get install -y sysbench




# Set up user jovyan so this image can be used e.g. on mybinder.org
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}



RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

USER ${NB_USER}

# Install clawpack-v5.6.0:



RUN pip install --src=/${HOME}/ --user -e git+https://github.com/clawpack/clawpack.git@v5.6.0#egg=clawpack-v5.6.0

ADD clawpack_profiling/advection_2d_blob /home/jovyan/clawpack-v5.6.0/amrclaw/examples/advection_2d_blob


ENV CLAW ${HOME}/clawpack-v5.6.0

# Put environment variables commands into .bashrc:
RUN echo 'export CLAW=${CLAW}' >> ~/.bashrc
RUN echo 'export FC=gfortran' >> ~/.bashrc
# set prompt:
RUN echo 'export PS1="jovyan $ "' >> ~/.bashrc

WORKDIR ${CLAW}
# Download the master branch of the apps repository and rename:
# (You can change `master` to a commit hash for a different version)
RUN curl -sL https://github.com/clawpack/apps/archive/master.tar.gz | tar xz
RUN mv apps-* apps

WORKDIR ${HOME}
