npm ci && CA=$(terraform output -raw ca) IOT_ENDPOINT=$(terraform output -raw iot_endpoint) CERT=$(terraform output -raw certA) KEY=$(terraform output -raw keyA) THING_NAME=$(terraform output -raw thing_nameA) node index.js
