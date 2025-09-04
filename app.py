from flask import Flask, jsonify, request

app = Flask(__name__)

# Home route
@app.route("/")
def home():
    return jsonify({"message": "Welcome to the Flask App!"})

# Example route with query params
@app.route("/greet")
def greet():
    name = request.args.get("name", "Guest")
    return jsonify({"message": f"Hello, {name}!"})

# Health check route
@app.route("/health")
def health():
    return jsonify({"status": "healthy"})

if __name__ == "__main__":
    # For local development only, use gunicorn in production
    app.run(host="0.0.0.0", port=5000, debug=True)
