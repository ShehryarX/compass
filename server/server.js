const express = require("express");
const graph = require("fbgraph");
const moment = require("moment");

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
const access_token = 'EAAFdFfQwBlwBAItz3fkvfRsCoL4yIARQeaijZCHU0SdNbSXOx3SmuwDBNxtqtWFqBJEeetx3GYmzosm6vZAQfvniiSHdXa4ukjUiIqyctFb8DT3WrZBECILu0dmfKMdCZCIENUKb5hBktI6LzZCfXUtf2rjFnJxciAZAOh69TCS4TH67KNdzFKWu8RYHidP2APgYyNbE0DoZCxwB5Xad6Om'
const geolocation = {
    lat: 43.4767,
    lon: -80.5388
}
const date = moment(Date.now()).format('YYYY-MM-DD')
const c_date = Date.parse(date)
const center = geolocation
const radius = 10000

graph.setAccessToken(access_token);

app.get("/", function(req, res) {

    graph.get(`${user_id}?fields=id,events`, function(err, graph_res) {

        var events_array = graph_res.events.data.filter((e) => {
            return verifyEvent(e)
        })
        res.send(events_array)
    })

});

function verifyEvent(e) {
    const start_time = e.start_time.split('T')[0]
    const e_date = Date.parse(start_time)
    const fiveDays = 1000 * 60 * 60 * 24 * 5;
    if ((e_date - c_date) > fiveDays || e_date < c_date) return false
    if (e.place === undefined || e.place.location === undefined) return false
    var event_loc = {
        lat: e.place.location.latitude,
        lon: e.place.location.longitude
    }
    return gl.insideCircle(event_loc, center, radius)
}

let event_dict = {}

const friendEvents = (personId, isUser) => new Promise(resolve => {
    graph.get(`${personId}?fields=id,events`, function(err, res) {
        for (let i = 0; i < res.events.data.length; i++) {
            const event = res.events.data[i]
            if (!(verifyEvent(event))) continue
            id = event.id
            if (event_dict[id] && !(isUser)) {
                event_dict[id].total += 1
                event_dict[id].friends.push(personId)
            } else if (isUser) {
                event_dict[id] = {
                    total: 0,
                    friends: [],
                }
            } else {
                event_dict[id] = {
                    total: 1,
                    friends: [personId],
                }
            }
        }
        res.events.data.forEach((i) => {

        })
        resolve()
    })
})

app.get("/friends", async function(req, res) {
    event_dict = {}
    await new Promise((resolve, reject) => {
        graph.get(`${user_id}?fields=id,friends`, async function(err, graph_res) {
            await friendEvents(user_id, true);
            for (let i = 0; i < graph_res.friends.data.length; i++) {
                await friendEvents(graph_res.friends.data[i].id, false);
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