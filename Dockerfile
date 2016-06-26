FROM ruby:2.2.0
# Added installation
RUN apt-get update -qq && apt-get install -y \
	build-essential \
	libpq-dev \
	nodejs

# Make dir inside conteiner
RUN mkdir /myapp
WORKDIR /myapp

ADD ./app/Gemfile /myapp/Gemfile
ADD ./app/Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD ./app /myapp