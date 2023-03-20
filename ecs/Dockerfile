FROM ruby:2.7.7
ENV LANG C.UTF-8
RUN apt-get update -qq && apt-get -y upgrade && apt-get install -y build-essential libpq-dev

RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && apt-get install -y nodejs

RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt-get update && apt-get install -y yarn

WORKDIR /myapp
ADD Gemfile* ./
RUN bundle install
RUN yarn install --check-files
RUN bundle exec rails assets:precompile
ADD . ./

# Nginxと通信を行うための準備
RUN mkdir -p tmp/sockets tmp/pids

VOLUME /myapp/public
VOLUME /myapp/tmp
