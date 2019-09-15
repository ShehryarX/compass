const express = require("express");
const graph = require("fbgraph");
const moment = require("moment");
const findAPI = require("./find");

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


const date = moment(Date.now()).format('YYYY-MM-DD')
const c_date = Date.parse(date)

app.get("/place", function(req, res) {
    const {
        text
    } = req.query;

    res.send(findAPI.textToLocation(text))
})

app.get("/user_events", function(req, res) {
    const {
        user_id,
        access_token,
        lat,
        lon
    } = req.query;

    const geolocation = {
        lat: Number(lat),
        lon: Number(lon)
    }
    const center = geolocation

    graph.setAccessToken(access_token);

    graph.get(`${user_id}?fields=id,events`, function(err, graph_res) {
        var events_array = graph_res.events.data.filter((e) => {
            return verifyEvent(e, center)
        })
        res.send(events_array)
    })

});

async function verifyEvent(e, geo) {
    const radius = 10000
    const start_time = e.start_time.split('T')[0]
    if (e.end_time === undefined) {
        return false
    }
    const end_time = e.end_time.split('T')[0]
    const e_date = Date.parse(start_time)
    const e_date_end = Date.parse(end_time)
    const fiveDays = 1000 * 60 * 60 * 24 * 5;

    if ((e_date - c_date) > fiveDays || ((e_date < c_date) && (e_date_end < c_date))) return false

    let lat, lng;
    if (e.place.location === undefined) {
        const response = await findAPI.textToLongLat(e.place.name);
        lat = response.lat;
        lng = response.lng;

    } else {
        lat = e.place.location.latitude
        lng = e.place.location.longitude
    }
    const event_loc = {
        lat: lat,
        lon: lng
    }
    return gl.insideCircle(event_loc, geo, radius)
}

let event_dict = {}

const friendEvents = (personId, isUser, geo) => new Promise(resolve => {
    graph.get(`${personId}/events/?fields=id,name,place,attending_count,about,cover,description,end_time,start_time,type`, async function(err, res) {
        if (res.data !== undefined) {
            for (let i = 0; i < res.data.length; i++) {
                const event = res.data[i]
                if (!(await (verifyEvent(event, geo)))) continue
                id = event.id
                if (event_dict[id] && !(isUser)) {
                    event_dict[id].total_friends += 1
                    event_dict[id].friends.push(personId)
                } else if (isUser) {
                    event_dict[id] = {
                        total_friends: 0,
                        friends: [],
                        details: event
                    }
                } else {
                    event_dict[id] = {
                        total_friends: 1,
                        friends: [personId],
                        details: event
                    }
                }
            }

        }
        resolve()
    })
})

app.get("/friends_events", async function(req, res) {
    const {
        user_id,
        access_token,
        lat,
        lon
    } = req.query;

    graph.setAccessToken(access_token);

    const geolocation = {
        lat: Number(lat),
        lon: Number(lon)
    }
    const center = geolocation
    event_dict = {}
    await new Promise(async(resolve, reject) => {
        graph.get(`${user_id}?fields=id,friends`, async function(err, graph_res) {
            await friendEvents(user_id, true, center);
            for (let i = 0; i < graph_res.friends.data.length; i++) {
                await friendEvents(graph_res.friends.data[i].id, false, center);
            }
            resolve();

        })
    });

    new_dict = await fixDict(event_dict)

    return res.status(200).json(new_dict);
});

let new_dict = {}

function isHappeningNow(info) {
    start_time = Date.parse(info.start_time.split('T')[0])
    end_time = Date.parse(info.start_time.split('T')[0])
    curr_time = c_date
    if ((curr_time < end_time) && (curr_time > start_time)) return true
    return false
}

async function generateLocation(info) {
    if (info.place.location) {
        return {
            street: info.place.location.street,
            lat: info.place.location.latitude,
            long: info.place.location.longitude,
        }
    }
    location = await findAPI.textToLocation(info.place.name)
    return location
}

async function fixDict(event_dict) {
    for (var key in event_dict) {
        if (event_dict.hasOwnProperty(key)) {
            const data = event_dict[key]
            const info = data.details
            const event_piece = {
                name: info.name,
                description: info.description,
                attending_count: info.attending_count,
                cover_image: info.cover.source,
                start_time: info.start_time.split('T')[0],
                end_time: info.end_time.split('T')[0],
                happening_now: isHappeningNow(info),
                total_friends_going: data.total_friends,
                mutual_friends: data.friends,
                venue_name: info.place.name,
                location: await generateLocation(info)
            }
            new_dict[key] = event_piece
        }
    }
    return new_dict
}

var port = process.env.PORT || 3000;
app.listen(port, function() {
    console.log("Express server listening on port %d", port);
});