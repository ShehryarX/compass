from flask import Flask
import json
import requests
from bs4 import BeautifulSoup

app = Flask(__name__)

base_url = "https://graph.facebook.com/"
token = 'EAAFdFfQwBlwBAItz3fkvfRsCoL4yIARQeaijZCHU0SdNbSXOx3SmuwDBNxtqtWFqBJEeetx3GYmzosm6vZAQfvniiSHdXa4ukjUiIqyctFb8DT3WrZBECILu0dmfKMdCZCIENUKb5hBktI6LzZCfXUtf2rjFnJxciAZAOh69TCS4TH67KNdzFKWu8RYHidP2APgYyNbE0DoZCxwB5Xad6Om'

@app.route("/user/<int:user_id>")
def user(user_id):
    fieldsUrl = "fields=id,name,likes,friends,groups,location,hometown,gender,age_range,address,events"
    url = base_url + str(user_id) + "?" + fieldsUrl + "&access_token=" + token
    return requests.get(url).content



@app.route("/likes/<int:user_id>")
def likes(user_id):
    fieldsUrl = "/likes?fields=name,category,events,about"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    return requests.get(url).content

@app.route("/events/<int:user_id>")
def events(user_id):
    fieldsUrl = "/events?fields=name,category,place,attending_count,about"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    return requests.get(url).content


if __name__ == "__main__":
    app.run()
