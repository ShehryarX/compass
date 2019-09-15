from flask import Flask
import json
import requests

app = Flask(__name__)

base_url = "https://graph.facebook.com/"
token = 'EAAFdFfQwBlwBALEJDj8Afa9BJEZCI3NWuW6hcdMvUNZABUzSrW6uajnPtkMOCEawowWN3voJp12ZCCKTaTZBNioAeuvfg3R25jShPKjii5K5oyKCnb2XCuxptckNUMj7n0i4GCJAvEeC9HtHWaRXNesPrqY9TLblAneJfG3pLvewaoX64dGIdzuR8WCZAprwd8bVeV3obRgoH6WJwI3Oy'

@app.route("/user/<int:user_id>")
def user(user_id):
    fieldsUrl = "fields=id,name,likes,friends,groups,location,hometown,gender,age_range,address,events"
    url = base_url + str(user_id) + "?" + fieldsUrl + "&access_token=" + token
    return requests.get(url).content

@app.route("/likes/<int:user_id>")
def likes(user_id):
    fieldsUrl = "/likes?fields=id,name,category,price_range&limit=100"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    return requests.get(url).content

@app.route("/events/<int:user_id>")
def events(user_id):
    fieldsUrl = "/events?fields=name,category,place,attending_count,about"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    return requests.get(url).content


if __name__ == "__main__":
    app.run()
