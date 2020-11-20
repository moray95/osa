FROM ruby:2.7.2

ARG OSA_VERSION
RUN gem install osa -v ${OSA_VERSION}
ENTRYPOINT ["osa"]
