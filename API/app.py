from flask import Flask, json, request, jsonify

LOCATION_STOLEN={"userId1":[0.0, 0.0, 0.0]}

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello, World!"

@app.route('/newInfoStolen', methods = ['POST'])
def api_message():
    if request.headers['Content-Type'] == 'application/json':
        content = request.json
        userId = content["userId"]
        if userId is not None :
            if userId not in LOCATION_STOLEN.keys() :
                LOCATION_STOLEN[userId]=[]
            LOCATION_STOLEN[userId].append(content["exifInfos"])
        else:
            print("incorrect Json file")
        return "location_stolen : {}".format(LOCATION_STOLEN)

@app.route('/getStolenInfo', methods=['GET'])
def get_stolen_info():
    return jsonify(LOCATION_STOLEN)