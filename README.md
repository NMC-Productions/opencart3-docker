## OpenCart 3.0.5.0 Dockerfile

The official OpenCart repository contains a Docker configuration, but for my setup, it was unusable. I've created this repository mostly for my own testing purposes, having limited experience with the Apache / PHP ecosystem. Some attempts to secure the OpenCart deployment have been made, but this is by no means a production ready setup. Use at your own risk.

### Running locally with Docker Compose

For a quick test, the `docker-compose.yml` file configures a SQL server next to the Apache web server running OpenCart. Once Docker builds and starts the containers, OpenCart will be accessible at `http://localhost:8080`. Please note that running a database inside docker-compose is not a good idea for a production setup, unless you really know what you're doing. 

### OpenCart configuration and storage

Once OpenCart starts up for the first time, navigate to your webserver's home page to complete the required manual configuration steps. Afterward, log into the admin panel and let OpenCart perform the "Automated Move" for the storage folder. You should now restart the Docker container running OpenCart in order to make the necessary security changes (these can be seen in `entrypoint.sh`).
