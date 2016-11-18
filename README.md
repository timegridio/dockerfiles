# Timegrid Dockerfile

## Building an image

> Estimated time: 10 min

    $ git clone https://github.com/timegridio/dockerfiles.git
    
    $ cd dockerfiles

	$ sudo docker build -t timegrid --build-arg user=$(whoami) --build-arg uid=$(id -u) .

> Coffee time!

## Running your local timegrid image

> Estimated time: just seconds

    $ sudo docker run -p8000:8000 -v ~/timegrid/:/var/www/timegrid timegrid:latest

Change `~/timegrid/` to your timegrid codebase path in your host machine.

Note that this shell will be kept busy for the time the container is up.

You should be now ready to browse `http://localhost:8000` from your host machine
 browser and meet your fresh timegrid install.

## Running tests in your container

> Estimated time: a few minutes

    $ sudo docker ps

Grab the running `CONTAINER_ID` and replace it in:

    $ sudo docker exec -it -u=$(whoami) CONTAINER_ID bash

Once you are logged-in into the container, run the tests:

    $ phpunit

## Starting the webserver

From inside the container shell:

    $ php artisan serve --host 0.0.0.0

## Stopping the container

From any new shell

    $ sudo docker stop CONTAINER_ID

## Authors

  * Timegrid Dockerfile is maintained by [Pablo E. González](https://github.com/PeGa) and [Ariel Vallese](https://github.com/alariva/)
