FROM ruby:2.2.0
# Added installation
RUN apt-get update -qq && apt-get install -y 	build-essential 	libpq-dev 	nodejs

# Make dir inside conteiner
RUN mkdir /app
WORKDIR /app

ADD ./app/Gemfile /app/Gemfile
ADD ./app/Gemfile.lock /app/Gemfile.lock
RUN bundle install
ADD ./app /app
