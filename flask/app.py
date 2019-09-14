from flask import Flask
import json
import requests

app = Flask(__name__)

base_url = "https://graph.facebook.com/"
token = 'EAAFdFfQwBlwBADY9zDLeei8RLG3ZAqPktQhwWDjkVoOOtt0XYKTPZCjfgEXAZC4WJvAXdnJ5tIqUi2aStjBIuS83mYzZBAQ8bWGYTSsnfBQxNEeiEC6NPhk0NXhWey0tbPZAFF8BVJTNk91NdfyrC6R1gRQZBZAikcwq5Ukob3TKsGdV0A18ss4S8lRWIr1p63pSsIlbYghlg2wJfwQvcle'

@app.route("/user/<int:user_id>")
def user(user_id):
    fieldsUrl = "fields=id,name,likes,friends,groups,location,hometown,gender,age_range,address,events"
    url = base_url + str(user_id) + "?" + fieldsUrl + "&access_token=" + token
    return requests.get(url).content


@app.route("/event/<int:event_id>")
def event(event_id):
    fieldsUrl = "?fields=id,name,category,decsription,parent_group,roles"
    url = base_url + str(event_id) + fieldsUrl + "&access_token=" + token
    print(url)
    return requests.get(url).content

if __name__ == "__main__":
    app.run()
