from flask import Flask
from datetime import datetime, timezone
import socket

app = Flask(__name__)


@app.route("/")
def index():
    return {
        "application": "devops-project-2",
        "status": "running",
        "hostname": socket.gethostname(),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }


@app.route("/health")
def health():
    return {
        "status": "healthy"
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)