const functions = require('firebase-functions');

const express = require("express");
const graph = require("fbgraph");
const moment = require("moment");

const {
    fbAuthKey
} = require("./keys");
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

function verifyEvent(e, geo) {
    const radius = 10000
    const start_time = e.start_time.split('T')[0]
    const e_date = Date.parse(start_time)
    const fiveDays = 1000 * 60 * 60 * 24 * 5;
    if ((e_date - c_date) > fiveDays || e_date < c_date) return false
    if (e.place === undefined || e.place.location === undefined) return false
    var event_loc = {
        lat: e.place.location.latitude,
        lon: e.place.location.longitude
    }
    return gl.insideCircle(event_loc, geo, radius)
}

let event_dict = {}

const friendEvents = (personId, isUser, geo) => new Promise(resolve => {
    graph.get(`${personId}?fields=id,events`, function(err, res) {
        for (let i = 0; i < res.events.data.length; i++) {
            const event = res.events.data[i]
            console.log(event)
            if (!(verifyEvent(event, geo))) continue
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
        res.events.data.forEach((i) => {

        })
        resolve()
    })
})

async function getEvents(user_id, access_token, lat, lon) {

    graph.setAccessToken(access_token);

    const geolocation = {
        lat: Number(lat),
        lon: Number(lon)
    }
    const center = geolocation
    event_dict = {}
    await new Promise((resolve, reject) => {
        graph.get(`${user_id}?fields=id,friends`, async function(err, graph_res) {
            await friendEvents(user_id, true, center);
            for (let i = 0; i < graph_res.friends.data.length; i++) {
                await friendEvents(graph_res.friends.data[i].id, false, center);
            }
            resolve();
        })
    });
    return res.status(200).json(event_dict);
};

exports.wandAR = functions.https.onRequest((request, response) => {
    const {
        user_id,
        access_token,
        lat,
        lon
    } = req.query;

    const events_response = getEvents(user_id, access_token, lat, lon)

    response.send(events_response);
});