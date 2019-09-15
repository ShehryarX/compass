from flask import Flask, jsonify, request
import json
import requests
import user_match_algo as uma
import pandas as pd 
import numpy as np

app = Flask(__name__)

base_url = "https://graph.facebook.com/"
token = 'EAAFdFfQwBlwBAPGVy20fL7bKgan3x1agZB57u4rsFZAwHzFZCSJ7FC1R6BOfjA086IGAArwjKZANe3ZARsAGGoCv7FThlHEnUNAuMYRhmxXNb50foqp8hSC788RFUlowU8ZBcyMvhTmW7diNkpCZCp9mTkRL2PUcDzPR8BuFAscLt7UYZBZBEyj1MxWMoxS1in14ygFMlUNCTrEoZCiAbDZB7Qh'

def get_likes(user_id):
    fieldsUrl = "/likes?fields=id,name,category,price_range&limit=100"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    res = requests.get(url).json()
    likes = res['data']
    for like in likes:
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

def friends(user_id):
    fieldsUrl = "?fields=friends&limit=100"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    res = requests.get(url).json()
    data = res['friends']['data']
    friend_array = []
    for friend in data:
        friend_likes = get_likes(int(friend['id']))
        friend_array.append(friend_likes)
    return friend_array

@app.route("/events/<int:user_id>")
def events(user_id):
    fieldsUrl = "/events?fields=name,category,place,attending_count,about"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    return requests.get(url).content

@app.route("/recommendation")
def recommend():
    cat_type = request.args.get('type')
    user_id = request.args.get('user_id')
    all_friends_df = pd.DataFrame()
    for friend_pages in friends(user_id):
        for page in friend_pages:
            row = {
                'user_id' : page['user_id'],
                'category': page['category'],
                'name': page['name'],
                'id': page['id'],
                'price_range': page['price_range'] if ('price_range' in page) else np.nan
            }
            all_friends_df = all_friends_df.append(row, ignore_index=True)
    user_df = pd.DataFrame()
    for page in get_likes(user_id):
        row = {
            'category': page['category'],
            'name': page['name'],
            'id': page['id'],
            'price_range': page['price_range'] if ('price_range' in page) else np.nan
        }
        user_df = user_df.append(row, ignore_index=True)
    events_list = uma.main_function(user_id, cat_type, all_friends_df, user_df)
    return jsonify(events_list)

if __name__ == "__main__":
    app.run()
