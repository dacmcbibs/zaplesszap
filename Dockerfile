FROM ubuntu

#Here some environment variables are set, which make installing Debian packages through apt completely non-interactive and make the environment fully UTF-8.

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=C.UTF-8 LANGUAGE=en_US.UTF-8
ENV FLAGS=

#Change uid & gid to match Unraid
RUN usermod -u 99 nobody && \
    usermod -g 100 nobody

# Fully updates Ubuntu, installs perl and cpanminus packages, and cleans up apt to save some space.

RUN [ "apt-get", "-q", "update" ]
RUN [ "apt-get", "-qy", "--force-yes", "upgrade" ]
RUN [ "apt-get", "-qy", "--force-yes", "dist-upgrade" ]
RUN [ "apt-get", "install", "-qy", "--force-yes", \
      "perl", \
      "build-essential", \
      "cpanminus" ] 
RUN [ "apt-get", "install", "-qy", "--force-yes", "libgd2-xpm-dev" ]
RUN [ "apt-get", "install", "-qy", "--force-yes", "libssl-dev" ]
RUN [ "apt-get", "install", "wget" ]
RUN [ "apt-get", "install", "-qy", "--force-yes", "vim" ]
RUN [ "apt-get", "install", "-qy", "--force-yes", "pkg-config" ] 
RUN [ "apt-get", "install", "-qy", "--force-yes", "cron" ]
RUN [ "apt-get", "clean" ]
RUN [ "rm", "-rf", "/var/lib/apt/lists/*", "/tmp/*", "/var/tmp/*" ]

# Uses cpanminus which makes installing CPAN modules dead simple within a Docker container to install dependencies.

RUN ["cpanm", "Proc::ProcessTable", "Data::Dumper", "HTTP::Cookies","LWP::UserAgent" ,"JSON","JSON::XS","GD","LWP::Protocol::https"]


#create zap2xml folder - This is for testing, longer term the script should live in config to not violate the authors wishes
#RUN ["mkdir", "zap2xml"]
#RUN ["cd", "zap2xml"]
#RUN ["wget", "-O", "/zap2xml/zap2xml.pl", "http://fossick.tk/?h=es8nru"]
#RUN ["chmod", "+x", "/zap2xml/zap2xml.pl"]

VOLUME /config
VOLUME /data

#Add the script file for the cron job
ADD files/scripts/ /zap2xml/scripts/
#ADD cron files
ADD files/cron/ /zap2xml/cron/
#Give both script and crontab file execution rights
RUN chmod -v +x /zap2xml/scripts/* /zap2xml/cron/*

# Setup cron job
RUN crontab /zap2xml/cron/zap-cron
RUN touch /var/log/zap.log
CMD cron && tail -f /var/log/zap.log

