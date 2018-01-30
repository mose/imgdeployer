FROM bitnami/ruby:2.4-master-prod
LABEL maintainer "mose <mose@mose.com>"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y libssl1.0.0

RUN gem install sinatra sinatra-contrib aws-sdk-ec2 shotgun

VOLUME /src
EXPOSE 9393

WORKDIR /src
ENTRYPOINT ["shotgun"]
