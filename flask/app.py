from flask import Flask
import json
import requests

app = Flask(__name__)


@app.route("/<int:user_id>")
def func(user_id):
    base_url = "https://graph.facebook.com/"
    token = 'EAAchvkxiC3gBAPvKlOX2vvSafBM9HlnufNcd501XPxliJ3TTX3YjSDfgEv8JjiHPH4yfVNoXgvDCX0lufiGJSdjsINoFnZBHkk4wq4vkT2dSCbPpo4zRRydkdFZCy3LHTyrAweXOovH3ET06MfseGDuFsZANhZBlV9Fxe11pGN9XjJ1fpl0SZAVFhNSMKCC9J4huZCCaJo7QZDZD'
    fieldsUrl = "fields=id,name,likes,friends,groups,location,hometown,gender,age_range,address,businesses,events"
    url = base_url + str(user_id) + "?" + fieldsUrl + "&access_token=" + token
    print(url)
    return requests.get(url).content


if __name__ == "__main__":
    app.run()
