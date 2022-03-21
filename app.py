#! /usr/bin/env python3

import flask
import os
import uuid
import waitress

app = flask.Flask(__name__)


@app.route("/")
def welcome():
    session_id = flask.request.cookies.get('session_id')
    if session_id:
        return flask.render_template("record.html")
    else:
        return flask.render_template("welcome.html")


@app.route("/start")
def start():
    response = flask.make_response(flask.redirect('/'))
    session_id = uuid.uuid4().hex
    response.set_cookie('session_id', session_id)
    return response


@app.route('/upload', methods=['POST'])
def upload():
    session_id = flask.request.cookies.get('session_id')
    if not session_id:
        return flask.make_response('No session', 400)
    word = flask.request.args.get('word')
    audio_data = flask.request.data
    filename = os.path.join(os.getcwd(), 'recordings', word + '-raw', session_id[:4] + uuid.uuid4().hex[:4] + ".ogg")
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, 'wb') as f:
        f.write(audio_data)
    return flask.make_response(os.path.dirname(os.path.dirname(filename)))

# CSRF protection
@app.before_request
def csrf_protect():
    if flask.request.method == "POST":
        token = flask.session['_csrf_token']
        if not token or token != flask.request.args.get('_csrf_token'):
            flask.abort(403)


def generate_csrf_token():
    if '_csrf_token' not in flask.session:
        flask.session['_csrf_token'] = uuid.uuid4().hex
    return flask.session['_csrf_token']


app.jinja_env.globals['csrf_token'] = generate_csrf_token

app.secret_key = "DEPLOYING_LOCALLY_ONLY_PLACEHOLDER"

if __name__ == "__main__":
    waitress.serve(app, host="0.0.0.0", port=8080)
