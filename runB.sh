npm ci && CA=$(terraform output -raw ca) IOT_ENDPOINT=$(terraform output -raw iot_endpoint) CERT=$(terraform output -raw certB) KEY=$(terraform output -raw keyB) THING_NAME=$(terraform output -raw thing_nameB) node index.js
