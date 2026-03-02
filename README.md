## OpenCart 3.0.5.0 Dockerfile & Docker Compose

The official OpenCart repository contains a Docker configuration, but for my setup, it was unusable. I've created this repository mostly for my own testing purposes, having limited experience within the PHP ecosystem. Some attempts have been made to secure the OpenCart deployment, but this is by no means a production ready setup. Use at your own risk.

### Running OpenCart locally with Docker Compose

As an example, the `docker-compose.yml` file configures several containers:

 - MySQL-compatible database
 - nginx web server 
 - PHP-FPM backend running OpenCart (built from the Dockerfile available in this repository)

Once Docker builds and starts the all containers, OpenCart will be accessible at `http://localhost:8080`. 

#### Important Note
The provided `docker-compose.yml` is for testing purposes only. Running a database inside docker-compose is not a good idea for a production setup, unless you really know what you're doing. 

### OpenCart configuration and storage

Once OpenCart starts up for the first time, navigate to your webserver's home page to complete the required manual configuration steps. Afterward, log into the admin panel and let OpenCart perform the "Automated Move" for the storage folder. You should now restart the Docker container running OpenCart in order to make the necessary security changes (these can be seen in `entrypoint.sh`).
