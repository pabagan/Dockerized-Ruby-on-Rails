FROM ruby:2.3
# Added installation
RUN apt-get update -qq && apt-get install -y 	build-essential 	libpq-dev 	nodejs

# Make dir inside conteiner
RUN mkdir /app
WORKDIR /app

# Unit test
RUN gem install rspec
RUN gem install rspec-its
RUN gem install capybara
RUN gem install poltergeist

ADD ./app/Gemfile /app/Gemfile
ADD ./app/Gemfile.lock /app/Gemfile.lock
RUN bundle install
ADD ./app /app
