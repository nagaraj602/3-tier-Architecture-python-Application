from flask import Flask, render_template, request, redirect, url_for, session
import pymysql
import boto3
import json


app = Flask(__name__)
app.secret_key = "usernotes-secret-key-2026"


def get_db_credentials():
    client = boto3.client(
        "secretsmanager",
        region_name="us-east-1"
    )
    response = client.get_secret_value(
        SecretId="usernotes-rds-secret1"
    )
    secret = json.loads(
        response["SecretString"]
    )
    return secret



secret = get_db_credentials()
DB_HOST = secret["host"]
DB_USER = secret["username"]
DB_PASSWORD = secret["password"]
DB_NAME = "usernotes"




def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )




@app.route("/")
def home():
    if "username" not in session:
        return redirect(url_for("login"))


    username = session["username"]


    conn = get_connection()
    cursor = conn.cursor()


    cursor.execute(
        "SELECT note, created_at FROM notes WHERE username=%s ORDER BY created_at DESC",
        (username,)
    )


    notes = cursor.fetchall()


    cursor.close()
    conn.close()


    return render_template(
        "dashboard.html",
        username=username,
        notes=notes
    )




@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form["username"].strip()


        if username:
            session["username"] = username
            return redirect(url_for("home"))


    return render_template("login.html")




@app.route("/add-note", methods=["POST"])
def add_note():
    if "username" not in session:
        return redirect(url_for("login"))


    username = session["username"]
    note = request.form["note"].strip()


    if note:
        conn = get_connection()
        cursor = conn.cursor()


        cursor.execute(
            "INSERT INTO notes (username, note) VALUES (%s, %s)",
            (username, note)
        )


        conn.commit()


        cursor.close()
        conn.close()


    return redirect(url_for("home"))




@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))




if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9051)
