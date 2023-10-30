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
// const rl = readline.createInterface({
// 	input: process.stdin,
// });

client.on("connect", () => {
	client.subscribe(`things/${THING_NAME}/test`, (err) => {
		if (!err) {
			console.log("Connected");
			// rl.on("line", (data) => {
			// 	client.publish(`things/${THING_NAME}/test`, JSON.stringify({vitals: data}));
			// });
			const oxygen = [98, 88, 94];
			const pulseRate  = [65, 94, 100];
			const temperature = [95, 98, 103];
			for (let i=0; i<3; i++) {
				o2 = oxygen[i];
				pr  =  pulseRate[i];
				t =  temperature[i];
				setTimeout(() => {
					console.log("Sending message", i)
					client.publish(`things/${THING_NAME}/test`, JSON.stringify({
						"thingId": opt.clientId,
						"Oxygen": o2,
						"PulseRate": pr,
						"Temperature": t,
					}));
				  }, 1000*i);
			}
		}
	});
});

// client.on("message", (topic, message) => {
// 	console.log("[Message received]: " + JSON.stringify(JSON.parse(message.toString()).current.state, undefined, 2));
// });