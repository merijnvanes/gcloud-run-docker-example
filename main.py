import os
from flask import Flask


app = Flask(__name__)


@app.route("/")
def hello_world():
    return "Hello world!"


if __name__ == "__main__":
    # The port is set to default 8080. The PORT environment 
    # variable is used to override the default.
    app.run(
        debug=True,
        host="0.0.0.0",
        port=int(os.environ.get("PORT", 8080))
    )
