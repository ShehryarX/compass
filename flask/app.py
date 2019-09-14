from flask import Flask
import json
import requests

app = Flask(__name__)

base_url = "https://graph.facebook.com/"
token = 'EAAFdFfQwBlwBAKrX9v287MrjT41XQ7sFxxBuZAVCuGlPImpBvKZCYVa6GBWgLtInbF5QRYCWp6AfRSeUy9nAjFZAvCnpRSSqwf0xfN6iCZAf35IJ8rQ7GDgYwBLeLdsdXjaFE4hNzzN5siaiao81Q6v6kkIHZCTr8S7EY2uCeS2ZBaUQ2biAMrF2gXJbvcWyXp92EWqp4G3vI6wn3bbNEP'

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
