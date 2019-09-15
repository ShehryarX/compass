from flask import Flask, jsonify, request
import json
import requests
import user_match_algo as uma
import pandas as pd 
import numpy as np

app = Flask(__name__)

respCache = {}

base_url = "https://graph.facebook.com/"
placeURL = 'https://maps.googleapis.com/maps/api/place/details/json'
API_KEY = 'AIzaSyB11HAsUjP68SILT9CT2paxX7br_Hlbk1g'
findURL = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'

def get_likes(user_id,token):
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

# @app.route("/likes/<int:user_id>")
# def likes(user_id):
#     return get_likes(user_id)

def friends(user_id,token):
    fieldsUrl = "?fields=friends&limit=100"
    url = base_url + str(user_id) + fieldsUrl + "&access_token=" + token
    res = requests.get(url).json()
    data = res['friends']['data']
    friend_array = []
    for friend in data:
        friend_likes = get_likes(int(friend['id']),token)
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
    token = request.args.get('token')

    if(user_id in respCache):
        return respCache[user_id]

    all_friends_df = pd.DataFrame()
    for friend_pages in friends(user_id,token):
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
    for page in get_likes(user_id,token):
        row = {
            'category': page['category'],
            'name': page['name'],
            'id': page['id'],
            'price_range': page['price_range'] if ('price_range' in page) else np.nan
        }
        user_df = user_df.append(row, ignore_index=True)
    events_list,top_friends = uma.main_function(user_id, cat_type, all_friends_df, user_df)

    recommendations_obj = []
    for place in events_list:
        res = requests.get(findURL, params = {
            'key': API_KEY,
            'input': place + " waterloo",
            'inputtype': "textquery"
        }).json()
        print(res)
        if 'candidates' not in res: continue
        if len(res['candidates']) == 0 : continue
        place_id = res['candidates'][0]['place_id']
        print(place_id)
        res2 = requests.get(placeURL, params = {
            'key': API_KEY,
            'place_id': place_id
        }).json()
        street = res2['result']['formatted_address']
        location = res2['result']['geometry']['location']
        recommendations_obj.append({
            'location': location,
            'place': place,
            'street': street,
            'friends': top_friends
        })

    respCache[user_id] = jsonify(recommendations_obj)
    return respCache[user_id]

if __name__ == "__main__":
    app.run()
