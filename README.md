# Timegrid Dockerfile

## Building an image

    $ git clone https://github.com/timegridio/dockerfiles.git
    
    $ cd dockerfiles

	# docker build -t timegrid .

> Build may take a few minutes.

## Running your local timegrid image

    # docker run -p8000:8000 -v ~/timegrid/:/var/www/timegrid timegrid:latest

Change `~/timegrid/` to your timegrid codebase path in your host machine.

You should be ready to browse `http://localhost:8000` with your fresh timegrid install.

## Running tests in your container

    # docker ps

Grab the running `CONTAINER_ID` and replace it in:

    # docker exec -it CONTAINER_ID bash

Once you are logged-in, run the tests:

    $ phpunit

## Stopping the container

    # docker stop CONTAINER_ID

## Authors

  * Timegrid Dockerfile is maintained by [Pablo E. González](https://github.com/PeGa) and [Ariel Vallese](https://github.com/alariva/)
