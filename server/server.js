const express = require("express");
const graph = require("fbgraph");

const { fbAuthKey } = require("./config/keys");

graph.setAccessToken("383823849195100|f6BhOUU5n5Kw-1e9gU1V9UZpxl8");

graph.get("Shehryar Assad", (err, res) => {
  console.log(res);
});

var authUrl = graph.getOauthUrl({
  client_id: fbAuthKey.id,
  redirect_uri: "http://www.google.com"
});

// shows dialog
res.redirect(authUrl);

// after user click, auth `code` will be set
// we'll send that and get the access token
graph.authorize(
  {
    client_id: conf.client_id,
    redirect_uri: conf.redirect_uri,
    client_secret: conf.client_secret,
    code: req.query.code
  },
  function(err, facebookRes) {
    res.redirect("/loggedIn");
  }
);
