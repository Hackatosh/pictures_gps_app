from flask import Flask, json, request, jsonify, render_template

LOCATION_STOLEN={"userId1":[0.0, 0.0, 0.0]}
LOCATION_STOLEN_LIST=[{'userId': "Doudou", "exifInfos":[0.0, 0.0, 0.0]}]

app = Flask(__name__)

@app.route("/")
def hello():
    return render_template("result.html")

@app.route('/newInfoStolen', methods = ['POST'])
def api_message():
    if 'application/json' in request.headers['Content-Type']:
        content = request.json
        print(content)
        userId = content["userId"]
        LOCATION_STOLEN_LIST.append(content)
        if userId is not None :
            if userId not in LOCATION_STOLEN.keys() :
                LOCATION_STOLEN[userId]=[]
            LOCATION_STOLEN[userId].append(content["exifInfos"])
        else:
            print("incorrect Json file")
        print("new location_stolen : {}".format(LOCATION_STOLEN))
        return "location_stolen : {}".format(LOCATION_STOLEN)

@app.route('/getStolenInfo', methods=['GET'])
def get_stolen_info():
    return jsonify({'results': LOCATION_STOLEN_LIST})