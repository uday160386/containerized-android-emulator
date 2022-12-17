# Base image
# ---------------------------------------------------------------------- #
FROM ubuntu:20.04
FROM node:14.21.2
ENV DEBIAN_FRONTEND noninteractive
RUN echo "${TZ}" > /etc/timezone
# Author
# ---------------------------------------------------------------------- #
LABEL maintainer ""
ENV DOCKER_ANDROID_DISPLAY_NAME emulator-android-29

# Update apt-get
RUN apt-get update
RUN apt-get dist-upgrade -y

# support multiarch: i386 architecture
# install essential tools
# Install required packages
RUN dpkg --add-architecture i386 && \
    apt-get install -y \
    autoconf \
    build-essential \
    gcc \
    git \
    groff \
    libc6-dev \
    libgmp-dev \
    libmpc-dev \
    libmpfr-dev \
    libxslt-dev \
    libxml2-dev \
    m4 \
    make \
    ncurses-dev \
    ocaml \
    pkg-config \
    rsync \
    software-properties-common \
    unzip \
    wget \
    zip \
    zlib1g-dev \
    x11vnc \
    jq \
    --no-install-recommends

# Install Java
RUN apt-add-repository ppa:openjdk-r/ppa
RUN apt-get -y install openjdk-8-jdk

# Clean Up Apt-get
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean

# download and install Android SDK
# Android SDK version
ENV ANDROID_SDK_VERSION=6609375 
# Configuring Android API level
ENV ANDROID_API_LEVEL=29
# Configuring Android Build tool level
ARG ANDROID_BUILD_TOOLS_LEVEL=30.0.2

ENV ANDROID_SDK_ROOT /opt/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip && \
    unzip *tools*linux*.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    rm *tools*linux*.zip

# set the environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${KOTLIN_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator
ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap

ENV LD_LIBRARY_PATH ${ANDROID_SDK_ROOT}/emulator/lib64:${ANDROID_SDK_ROOT}/emulator/lib64/qt/lib
ENV QTWEBENGINE_DISABLE_SANDBOX 1

# accept the license agreements of the SDK components
RUN echo y | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses
RUN echo y | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "emulator"
RUN echo y | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platform-tools"
RUN echo y | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platforms;android-${ANDROID_API_LEVEL}"
RUN echo y | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "build-tools;${ANDROID_BUILD_TOOLS_LEVEL}"

RUN mkdir -p ${ANDROID_SDK_ROOT}/ma/android-emulator
COPY /scripts/run_emulators.sh ${ANDROID_SDK_ROOT}/ma/android-emulator
RUN chmod -R 765 ${ANDROID_SDK_ROOT}/ma/android-emulator/run_emulators.sh
COPY /scripts/connect_emulators_tosgrid.sh ${ANDROID_SDK_ROOT}/ma/android-emulator
RUN chmod -R 765 ${ANDROID_SDK_ROOT}/ma/android-emulator/connect_emulators_tosgrid.sh
# Install Appium
RUN mkdir /opt/appium \
  && cd /opt/appium \
  && npm install appium@latest \
  && ln -s /opt/appium/node_modules/.bin/appium /usr/bin/appium

# Expose appium server, if more than one emulator is running then need to ru appium with unique port and bootstrap port 
EXPOSE 4723
EXPOSE 4725

# Expose android emulator with tcp connection
EXPOSE 5557
EXPOSE 5559

CMD ["sh", "-c", "tail -f /dev/null"]
