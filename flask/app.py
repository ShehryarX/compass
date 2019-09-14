from flask import Flask
import json
import requests

app = Flask(__name__)

base_url = "https://graph.facebook.com/"
token = 'EAAFdFfQwBlwBAANy4ZA1eQHPc5ZAYOBP9pEXCrboVuLi54uwGrT7iZAQDBsGG7EB7mtCZBNTNEq3BIZCD66H9j89sgCim4UlPLSsGwRSYB14QK7d4VCCPI8sZBx3MGvJxt2cOgjIyZBEpTpMRnGrTuBHokI834oQazPij9kLvLZAObZAZAWmdrtHjDDfxehZBj516vOBmcijPqkwTJfO0sldSCX'

@app.route("/user/<int:user_id>")
def user(user_id):
    fieldsUrl = "fields=id,name,likes,friends,groups,location,hometown,gender,age_range,address,businesses,events"
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
