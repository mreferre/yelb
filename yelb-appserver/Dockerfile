FROM bitnami/ruby:2.4.2-r1
MAINTAINER massimo@it20.info

################## BEGIN INSTALLATION ######################

# Set the working directory to /app
WORKDIR /app

COPY yelb-appserver.rb yelb-appserver.rb

ENV LANG=en_us.UTF-8
ENV LC_ALL=C.UTF-8
ENV RACK_ENV=production

RUN gem install sinatra --no-ri --no-rdoc
RUN gem install redis --no-ri --no-rdoc
### hack to allow the setup of the pg gem (which would fail otherwise)
RUN apt-get update
RUN apt-get install libpq-dev -y
### end of hack (this would require additional research and optimization)
RUN gem install pg --no-ri --no-rdoc

##################### INSTALLATION END #####################

CMD /bin/sh -c "ruby yelb-appserver.rb -o 0.0.0.0"


