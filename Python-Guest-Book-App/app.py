from flask import Flask, request, redirect
import redis

app = Flask(__name__)

r = redis.Redis(
    host='redis',
    port=6379,
    decode_responses=True
)

@app.route('/')
def home():
    messages = r.lrange("messages", 0, -1)
    html = """
    <h1>Guestbook Application</h1>

    <form action='/add' method='post'>
        <input type='text' name='message'>
        <button type='submit'>Submit</button>
    </form>

    <hr>
    """

    for msg in messages:
        html += f"<p>{msg}</p>"

    return html

@app.route('/add', methods=['POST'])
def add():
    message = request.form.get('message')
    r.rpush('messages', message)
    return redirect('/')

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)