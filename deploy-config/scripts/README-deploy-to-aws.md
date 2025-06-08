# Deploy to AWS

## Keycloak Config
* keycloak-client: Update environment.ts and environment.local-api.ts
* keycloak-server: Ensure `issuer-uri` is proper.
* keycloak-server: Ensure `oauth.client-id` is proper (maybe?).

## Step-By-Step Deployment

Preparation and Setup:
* To deploy directly to the "dist" folder, change `angular.json -> projects -> architect -> build -> options -> outputPath` to:
    * "outputPath": "dist",

On your local machine run `/scripts/build-image-and-deploy-to-aws.sh` or:
* Start Docker Desktop
* Run the build script in package.json.
    * `npm run build`
* Run docker-build-image.sh.
    * `./docker-build-image.sh`
* Save image to .tar to move to VM (make sure the 'images' directory exists).
    * `docker image save coming-soon-client:latest -o deploy-config/images/coming-soon-client.tar`
* Copy the image file to the root directory on the AWS EC2 instance:
    * `scp -i ./deploy-config/secrets/tims-analytics.pem ./deploy-config/images/coming-soon-client.tar ec2-user@ec2-54-146-74-179.compute-1.amazonaws.com:~/temp/.`

Connect to the AWS EC2 Instance and run `/scripts/deploy-tims-analytics-image.sh` or:
* Copy the image from the root directory to the coming-soon-client directory.
    * `mv ~/temp/coming-soon-client.tar ~/docker/coming-soon-client/`
* Navigate to the coming-soon-client directory
    * `cd ~/docker/coming-soon-client`
* Stop the running Docker container.
    * `docker-compose down`
* Remove the previous image.
    * `docker rmi coming-soon-client:latest`
* Load the image into Docker
    * `docker image load -i coming-soon-client.tar`
* Update the docker-compose.yml file to reference the proper image version.
* Start the container using docker-compose:
    * `docker-compose up -d`

To "tail" the log:
* `docker logs coming-soon-client tail 100 --follow`
