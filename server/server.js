const express = require("express");
const graph = require("fbgraph");

const {
    fbAuthKey
} = require("./config/keys");
const gl = require('geolocation-utils');

var app = express();
var server = require("http").createServer(app);

var conf = {
    client_id: fbAuthKey.id,
    client_secret: fbAuthKey.secret,
    scope: "email, user_about_me, user_birthday, user_location, publish_actions",
    redirect_uri: "shehryar.me"
};

var methodOverride = require("method-override");
var bodyParser = require("body-parser");
var errorHandler = require("errorhandler");

const user_id = 2505011072909984
const access_token = 'EAAFdFfQwBlwBAOWKyaoeKUsWhAnWVOS5uROF6yqJmLVy2fpz5peZB3I5f8mLW65hW6ZBtf5zs6EZBmdeFRrZCAc1FRMdMVsZA9vDBPSWrZBlyAXk5obl88N2e8thQrBUHJxRZB9ipbQtqLMmZAk9eBybI0ZChOolBkE2ZBEcSKyaMfxGR2TeuZCv7yoZCA4khBJ72BJLfdZBGFVTYbQZDZD'

let geolocation = {
    lat: 43.4767,
    lon: -80.5388
}

graph.setAccessToken(access_token);

app.get("/", function(req, res) {
    const center = geolocation
    const radius = 10000

    graph.get(`${user_id}?fields=id,events`, function(err, graph_res) {
        var events_array = graph_res.events.data.filter((e) => {
            if (e.place === undefined || e.place.location === undefined) return false
            var event_loc = {
                lat: e.place.location.latitude,
                lon: e.place.location.longitude
            }
            return gl.insideCircle(event_loc, center, radius)
        })
        res.send(events_array)
    })

});

app.get("/event_data", function(req, res) {
    const center = geolocation
    const radius = 10000

    graph.get(`${user_id}?fields=id,events`, function(err, graph_res) {
        var events_array = graph_res.events.data.filter((e) => {
            if (e.place === undefined || e.place.location === undefined) return false
            var event_loc = {
                lat: e.place.location.latitude,
                lon: e.place.location.longitude
            }
            return gl.insideCircle(event_loc, center, radius)
        })
        res.send(events_array)
    })
});

let event_dict = {}

const smth = e => new Promise(resolve => {
    graph.get(`${e.id}?fields=id,events`, function(err, friends_res) {
        friends_res.events.data.forEach((i) => {
            id = i.id
            if (event_dict[id]) {
                event_dict[id].total += 1
                event_dict[id].friends.push(e.id)
            } else {
                event_dict[id] = {
                    total: 1,
                    friends: [e.id],
                }
            }
        })
        resolve()
    })
})

app.get("/friends", async function(req, res) {
    event_dict = {}
    await new Promise((resolve, reject) => {
        graph.get(`${user_id}?fields=id,friends`, async function(err, graph_res) {
            for (let i = 0; i < graph_res.friends.data.length; i++) {
                await smth(graph_res.friends.data[i])
            }

            resolve();
        })

    });

    return res.status(200).json(event_dict);
});
var port = process.env.PORT || 3000;
app.listen(port, function() {
    console.log("Express server listening on port %d", port);
});