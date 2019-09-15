from flask import Flask, jsonify
import json
import requests

app = Flask(__name__)

base_url = "https://graph.facebook.com/"
token = 'EAAFdFfQwBlwBAAz8arxpACZBossex17WMBdZCFPf3cIExfgbR4nxRZA2DuJAYhp1O6UaIXNSBKvduCIAy4O6szGLWgbmBeJAhVUVoQooMoh9486NP0xAmRbyTaHWG7EaKKgIlWWCj4ZBZCJokTL1ZBC2FDxHGTL5KxNSJkPS4A5aYuwG23az6pHwtTyC1ZCC6d9WBfdwtAprFzhy4qyAaS2'

def get_likes(user_id):
    fieldsUrl = "/likes?fields=id,name,category,price_range&limit=100"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    likes = requests.get(url).json()['data']
    for like in likes:
        print(like)
        like['user_id']  = user_id 
    return likes

@app.route("/user/<int:user_id>")
def user(user_id):
    fieldsUrl = "fields=id,name,likes,friends,groups,location,hometown,gender,age_range,address,events"
    url = base_url + str(user_id) + "?" + fieldsUrl + "&access_token=" + token
    return requests.get(url).content

@app.route("/likes/<int:user_id>")
def likes(user_id):
    return get_likes(user_id)

@app.route("/friends/<int:user_id>")
def friends(user_id):
    fieldsUrl = "?fields=friends&limit=100"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    res = requests.get(url).json()
    data = res['friends']['data']
    friend_array = []
    for friend in data:
        friend_likes = get_likes(int(friend['id']))
        friend_array.append(friend_likes)
    return jsonify(friend_array)

@app.route("/events/<int:user_id>")
def events(user_id):
    fieldsUrl = "/events?fields=name,category,place,attending_count,about"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    return requests.get(url).content


if __name__ == "__main__":
    app.run()
