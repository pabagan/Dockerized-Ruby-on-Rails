# Ruby on Rails with Docker
Dockerized Ruby on Rails environment build like:
* [Instructions](https://docs.docker.com/compose/rails/)

## Requirements
* [Docker Engine](https://docs.docker.com/installation/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Machine](https://docs.docker.com/machine/) (Mac and Windows only)


## Build flavour 1
You can use the image as is.
```bash
# Clone repository 
git clone https://github.com/pabagan/env-Ruby-on-Rails.git

# Build Container
docker-compose build

# or start and access Ruby on Rails container by executing
./sh/run.sh
```

## Build flavour 2
Delete all files but `build-environment.sh`. Adjust constant to build your own flavour.

```bash
# 1. Adjust environment constants at build-environment.sh
# 2. Execute build to create Docker, Gem, config
# and bash files.
./build-environment.sh

# or start and access Ruby on Rails container by executing
./sh/run.sh
```

## Start APP
If everything worked as expected you can start your container running Ruby on Rails application by executing one of these commands:
```bash
# Start container
docker-compose up
# -d run container in the background
docker-compose up -d  
# or start and access Ruby on Rails container shell
./sh/run.sh
```
Now should see Ruby on Rails wellcome page at [localhost:3000](http://localhost:3000)
