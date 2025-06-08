if ! docker info > /dev/null 2>&1; then
    echo "This script uses docker, and it isn't running - please start docker and try again!"
    exit 1
fi

echo "Adding deploy timestamp to environments.prod.ts..."
sed -i "s/buildTimestamp: '[0-9]*'/buildTimestamp: '$(date +%s%3N)'/g" ../../src/environments/environment.prod.ts

echo "Building Docker Image..."
./docker-build-image.sh

echo "Saving Docker Image as a TAR file..."
docker image save coming-soon:latest -o ../images/coming-soon.tar

echo "Copying TAR file to AWS..."
scp -i ../secrets/tims-analytics-v2.pem ../images/coming-soon.tar ec2-user@ec2-54-174-219-218.compute-1.amazonaws.com:~/temp/.
