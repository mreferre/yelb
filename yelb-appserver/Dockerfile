FROM bitnami/ruby:2.7.4
MAINTAINER massimo@it20.info

################## BEGIN INSTALLATION ######################

# Set the working directory to /app
WORKDIR /app

COPY *.rb ./
COPY Gemfile Gemfile
COPY modules modules

ENV LANG=en_us.UTF-8
ENV LC_ALL=C.UTF-8
ENV RACK_ENV=production

RUN gem install sinatra --no-document
RUN gem install redis --no-document
### hack to allow the setup of the pg gem (which would fail otherwise)
RUN apt-get update
RUN apt-get install libpq-dev -y
### end of hack (this would require additional research and optimization)
RUN gem install pg --no-document
### this installs the AWS SDK for DynamoDB (so that appserver can talk to DDB Vs the default Postgres/Redis)
RUN gem install aws-sdk-dynamodb pg --no-document
# Set the working directory to /
WORKDIR /
ADD startup.sh startup.sh

# Lambda adapter
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.5.1 /lambda-adapter /lambda-adapter

# Setup Lambda RIE + RIC
RUN curl -L -o /usr/bin/lambda_rie https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/v1.9/aws-lambda-rie-x86_64
RUN chmod +x /usr/bin/lambda_rie
RUN gem install aws_lambda_ric

##################### INSTALLATION END #####################

CMD ["./startup.sh"]


