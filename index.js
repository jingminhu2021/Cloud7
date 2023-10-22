// import {connect} from "mqtt";
// import readline from "readline";

const mqtt = require("mqtt");
const readline = require("readline");

const {IOT_ENDPOINT, CA, CERT, KEY, THING_NAME} = process.env;
const opt = {
	host: IOT_ENDPOINT,
	protocol: "mqtt",
	clientId: THING_NAME,
	clean: true,
	key: KEY,
	cert: CERT,
	ca: CA,
	reconnectPeriod: 0,
};

const client  = mqtt.connect(opt);

client.on("error", (e) => {
	console.log(e);
	process.exit(-1);
});
const rl = readline.createInterface({
	input: process.stdin,
});

client.on("connect", () => {
	client.subscribe(`things/${THING_NAME}/test`, (err) => {
		if (!err) {
			console.log("Connected, send some messages by typing in the terminal (press enter to send)");
			rl.on("line", (data) => {
				client.publish(`things/${THING_NAME}/test`, JSON.stringify({vital: data}));
			});
		}
	});
});

// client.on("message", (topic, message) => {
// 	console.log("[Message received]: " + JSON.stringify(JSON.parse(message.toString()).current.state, undefined, 2));
// });