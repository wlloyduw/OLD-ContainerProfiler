# Install anaconda Python stack and some other useful tools
FROM ubuntu
RUN apt-get update
RUN apt-get install -y tar git curl wget dialog net-tools build-essential
Run apt-get install -y man jq bc
# Install editors:
RUN apt-get install -y vim nano

# Install gfortran
RUN apt-get install -y gfortran

# Commands necessary for building the Container through ubuntu
RUN apt-get install -y python
RUN apt-get install -y python-pip
RUN apt install python-numpy -y
RUN pip install matplotlib
ENV HOME /home/ubuntu




RUN pip install --src=$HOME/clawpack_src -e \git+https://github.com/clawpack/clawpack.git@v5.6.1#egg=clawpack-v5.6.1


ADD clawpack_profiling/advection_2d_blob /home/clawpack_src/clawpack-v5.6.1/amrclaw/examples/advection_2d_blob


ENV CLAW $HOME/clawpack_src/clawpack-v5.6.1
ENV FC gfortran

# Put environment variables commands into .bashrc:
RUN echo 'export CLAW=${CLAW}' >> ~/.bashrc
RUN echo 'export FC=gfortran' >> ~/.bashrc


WORKDIR ${CLAW}
# Download the master branch of the apps repository and rename:
# (You can change `master` to a commit hash for a different version)
RUN curl -sL https://github.com/clawpack/apps/archive/master.tar.gz | tar xz
RUN mv apps-* apps
WORKDIR ${HOME}

