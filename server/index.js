
const functions = require('firebase-functions');

export const helloWorld = functions.https.onRequest((req, resp) => {
  res.send("Hello, world!")
});