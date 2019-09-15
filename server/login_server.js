require("dotenv").config();

var express = require("express");
var passport = require("passport");
var Strategy = require("passport-facebook").Strategy;

var firebase = require("firebase");
var app = firebase.initializeApp({
  apiKey: "AIzaSyDA9YGHcZwUR3-eRNbwMVuuX7bKDgaqscE",
  authDomain: "wandar-85910.firebaseapp.com",
  databaseURL: "https://wandar-85910.firebaseio.com",
  projectId: "wandar-85910",
  storageBucket: "",
  messagingSenderId: "44068558569",
  appId: "1:44068558569:web:8b3e6d90408019d"
});

const { fbAuthKey } = require("./config/keys");

// Configure the Facebook strategy for use by Passport.
//
// OAuth 2.0-based strategies require a `verify` function which receives the
// credential (`accessToken`) for accessing the Facebook API on the user's
// behalf, along with the user's profile.  The function must invoke `cb`
// with a user object, which will be set at `req.user` in route handlers after
// authentication.
passport.use(
  new Strategy(
    {
      clientID: fbAuthKey.id,
      clientSecret: fbAuthKey.secret,
      callbackURL: "/return"
    },
    function(accessToken, refreshToken, profile, cb) {
      // In this example, the user's Facebook profile is supplied as the user
      // record.  In a production-quality application, the Facebook profile should
      // be associated with a user record in the application's database, which
      // allows for account linking and authentication with other identity
      // providers.
      return cb(null, profile);
    }
  )
);

// Configure Passport authenticated session persistence.
//
// In order to restore authentication state across HTTP requests, Passport needs
// to serialize users into and deserialize users out of the session.  In a
// production-quality application, this would typically be as simple as
// supplying the user ID when serializing, and querying the user record by ID
// from the database when deserializing.  However, due to the fact that this
// example does not have a database, the complete Facebook profile is serialized
// and deserialized.
passport.serializeUser(function(user, cb) {
  cb(null, user);
});

passport.deserializeUser(function(obj, cb) {
  cb(null, obj);
});

// Create a new Express application.
var app = express();

// Configure view engine to render EJS templates.
app.set("views", __dirname + "/views");
app.set("view engine", "ejs");

// Use application-level middleware for common functionality, including
// logging, parsing, and session handling.
app.use(require("morgan")("combined"));
app.use(require("cookie-parser")());
app.use(
  require("body-parser").urlencoded({
    extended: true
  })
);
app.use(
  require("express-session")({
    secret: "keyboard cat",
    resave: true,
    saveUninitialized: true
  })
);

// Initialize Passport and restore authentication state, if any, from the
// session.
app.use(passport.initialize());
app.use(passport.session());

// Define routes.
app.get("/", function(req, res) {
  res.render("home", {
    user: req.user
  });
});

app.get("/login", function(req, res) {
  res.render("login");
});

app.get(
  "/login/facebook",
  passport.authenticate("facebook", {
    scope: [
      "user_location",
      "user_likes",
      "user_events",
      "user_photos",
      "user_videos",
      "user_friends",
      "user_tagged_places",
      "user_posts",
      "user_gender",
      "user_link",
      "user_age_range",
      "email",
      "read_insights",
      "read_audience_network_insights",
      "openid",
      "pages_show_list",
      "ads_read",
      "instagram_basic",
      "public_profile"
    ]
  })
);

app.get(
  "/return",
  passport.authenticate("facebook", {
    failureRedirect: "/login"
  }),
  function(req, res) {
    res.redirect("/profile");
  }
);

app.get("/profile", require("connect-ensure-login").ensureLoggedIn(), function(
  req,
  res
) {
  const { id, displayName } = req.user;

  firebase
    .database()
    .ref("/users/" + id)
    .set({
      id: id,
      display: displayName
    });

  res.render("profile", {
    user: req.user
  });
});

app.listen(8080, () => console.log("Listening to port 8080"));
