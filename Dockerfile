FROM ruby:2.5.3-alpine

ENV RAILS_ENV production

# Install and update all dependencies (os, ruby)
WORKDIR /usr/src/app
# =============================================
# System layer

# Will invalidate cache as soon a the Gemfile changes
COPY Gemfile Gemfile.lock /usr/src/app/

# * Setup system
# * Install Ruby dependencies
RUN apk add --update \
    build-base \
    netcat-openbsd \
    git \
    nodejs \
    postgresql-dev \
    mysql-dev \
    tzdata \
    curl-dev \
    yarn \
 && rm -rf /var/cache/apk/* \
 && bundle config --global frozen 1 \
 && bundle install --without test development --jobs 2 \
 && gem install foreman

# ========================================================
# Application layer

# Copy application code
COPY . /usr/src/app

# * Generate the docs
# * Make files OpenShift conformant
RUN chgrp -R 0 /usr/src/app \
 && chmod -R g=u /usr/src/app

RUN bundle exec rake assets:precompile

# Startup
CMD ["bin/docker-start"]
