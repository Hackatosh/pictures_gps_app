from flask import Flask, json, request

location_stolen={"userId1":[0.0, 0.0, 0.0]}

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello, World!"

@app.route('/post', methods = ['POST'])
def api_message():

    if request.headers['Content-Type'] == 'application/json':
        return "JSON Message: " + json.dumps(request.json)