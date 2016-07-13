#!/bin/bash

# To run this script delete all files but 
# this.

# Build a Docker/Ruby on Rails enviroment. 
# This shell file follows the instructions  
# given at https://docs.docker.com/compose/rails/

# Enviroment constants
RUBY_VERSION=2.3                                      # Ruby version used at Dockerfile
RAILS_APP_NAME=app			                              # Rails app name
APP_ROUTE=./$RAILS_APP_NAME                           # app folder location
SH_ROUTE=./sh                                         # sh folder location
DOCKER_ROUTE=./                                       # Dockerfiles location
DOCKER_RAILS_CONTAINER=${RAILS_APP_NAME}-RubyOnRails  # Docker container name for Ruby
DOCKER_POSTGRE_CONTAINER=${RAILS_APP_NAME}-Postgre 		# Docker container name for Postgre


# Print exit messages with 
# green
function successMsg {
  GREEN='\033[0;32m'  # Green color
  NC='\033[0m'        # No Color
  echo -e "${GREEN}$1${NC}"
}


# Create folder APP
if [ ! -d "$APP_ROUTE" ]; then
	mkdir $APP_ROUTE
  successMsg "$APP_ROUTE created."
fi


# Create folder for bash files
if [ ! -d "$SH_ROUTE" ]; then
  mkdir $SH_ROUTE
  successMsg "$SH_ROUTE created."
fi


# Create init Gemfile
cat <<EOF > $APP_ROUTE/Gemfile
source 'https://rubygems.org'
gem 'rails', '4.2.0'
EOF

# Create blank Gemfile
echo "" > "$APP_ROUTE/Gemfile.lock"

successMsg "Created Gemfile and Gemfile.log."


# Create Dockerfile
cat <<EOF > $DOCKER_ROUTE/Dockerfile
FROM ruby:$RUBY_VERSION
# Added installation
RUN apt-get update -qq && apt-get install -y \
	build-essential \
	libpq-dev \
	nodejs

# Make dir inside conteiner
RUN mkdir /$RAILS_APP_NAME
WORKDIR /$RAILS_APP_NAME

# Unit test
RUN gem install rspec
RUN gem install rspec-its
RUN gem install capybara
RUN gem install poltergeist

ADD ./$RAILS_APP_NAME/Gemfile /$RAILS_APP_NAME/Gemfile
ADD ./$RAILS_APP_NAME/Gemfile.lock /$RAILS_APP_NAME/Gemfile.lock
RUN bundle install
ADD ./$RAILS_APP_NAME /$RAILS_APP_NAME
EOF

# Create Docker Compose file
cat <<EOF > $DOCKER_ROUTE/docker-compose.yml
version: '2'
services:
  db:
    image: postgres
    container_name: $DOCKER_POSTGRE_CONTAINER
  web:
    build: .
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    container_name: $DOCKER_RAILS_CONTAINER
    volumes:
      - ./$RAILS_APP_NAME:/$RAILS_APP_NAME
    ports:
      - "3000:3000"
    depends_on:
      - db
EOF

successMsg "Created Dockerfile and docker-compose.yml at $DOCKER_ROUTE."


# Create rails APP scaffolding
sudo docker-compose run web rails new . --force --database=postgresql --skip-bundle $APP_ROUTE
# Create scaffolding sh file
cat <<EOF > $SH_ROUTE/scaffolding.sh
sudo docker-compose run web rails new . --force --database=postgresql --skip-bundle $APP_ROUTE
EOF

successMsg "Create Ruby on Rails APP scaffolding at $APP_ROUTE."

# Permisos
sudo chown -R $USER:$USER $APP_ROUTE
cat <<EOF > $SH_ROUTE/chmod.sh
sudo chown -R \$USER:\$USER $APP_ROUTE
EOF

# Update Gemfile config
sed -i "s/# gem 'therubyracer'/gem 'therubyracer'/g" $APP_ROUTE/Gemfile

# Docker Build
docker-compose build
successMsg "Docker enviroment built."

# Set DB
cat <<EOF > $APP_ROUTE/config/database.yml
development: &default
  adapter: postgresql
  encoding: unicode
  database: postgres
  pool: 5
  username: postgres
  password:
  host: db

test:
  <<: *default
  database: ${RAILS_APP_NAME}_test
EOF
successMsg "Database configuration overwritten at $APP_ROUTE/config/database.yml."

# DB Create
#cd ../ & docker-compose run web rake db:create

# Create DB shell access
cat <<EOF > $SH_ROUTE/db.sh
# To accomplish db creation docker container 
# should be running
docker-compose run web rake db:create
EOF
successMsg "Postgre DB creation shell script created. Create DB by executing ./db.sh"

# Create shell to access to Rails 
# Docker container.
cat <<EOF > $SH_ROUTE/run.sh
sudo service docker restart && docker-compose up -d && docker exec -i -t $DOCKER_RAILS_CONTAINER bash
EOF
successMsg "Log shell script created. Run and access Ruby container by executing ./start.sh"

# Allow executing created .sh(s)
chmod +x -R $SH_ROUTE/*