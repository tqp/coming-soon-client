if ! docker info > /dev/null 2>&1; then
    echo "This script uses docker, and it isn't running - please start docker and try again!"
    exit 1
fi

echo "Adding deploy timestamp to environments.prod.ts..."
sed -i "s/buildTimestamp: '[0-9]*'/buildTimestamp: '$(date +%s%3N)'/g" ../../src/environments/environment.prod.ts

echo "Building Docker Image..."
./docker-build-image-parrano.sh

echo "Saving Docker Image as a TAR file..."
docker image save gate-drinks-client:latest -o ../images/gate-drinks-client.tar

echo "Copying TAR file to Burrata..."
scp -i ~/.ssh/id_ed25519_tim -P 23022 ../images/gate-drinks-client.tar tim@tqp.synology.me:/tmp/.
