# agent/main.py

from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/", methods=["GET"])
def home():
    return jsonify({"status": "Emo AI Pro Python Agent Running"})

@app.route("/run", methods=["POST"])
def run():
    data = request.json or {}
    return jsonify({
        "status": "ok",
        "received": data
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
