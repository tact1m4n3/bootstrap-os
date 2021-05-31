FROM ubuntu:16.04

RUN apt-get update 
RUN apt-get upgrade -y
RUN apt-get install -y make
RUN apt-get install -y nasm
RUN apt-get install -y gcc libc6-i386 binutils
RUN apt-get install -y xorriso
RUN apt-get install -y grub-pc-bin
RUN apt-get install -y grub-common

VOLUME /root/env
WORKDIR /root/env