from flask import Flask, render_template, request
import pika
import pymysql.cursors
from pymemcache.client.base import Client
import json
from dotenv import load_dotenv
import os
import logging


app = Flask(__name__, static_url_path='/static')
load_dotenv()
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

# Memcached configuration
memcache_host = os.getenv('MEMCACHE_HOST')
memcache_port = os.getenv('MEMCACHE_PORT')
memcache_client = Client((memcache_host, memcache_port))

# Database configuration
db_config = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'db': os.getenv('DB_DB'),
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

# RabbitMQ connection details
rabbitmq_credentials = pika.PlainCredentials(os.getenv('MQ_USER'), os.getenv('MQ_PASSWORD'))
rabbitmq_parameters = pika.ConnectionParameters(os.getenv('MQ_HOST'), credentials=rabbitmq_credentials)


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/test_memcached')
def test_memcached():
    connection = pymysql.connect(**db_config)
    try:
        with connection.cursor() as cursor:
            # Fetch data from the 'users' table
            sql = 'SELECT * FROM users'
            cursor.execute(sql)
            users = cursor.fetchall()
    finally:
        connection.close()

    return render_template('testMemcached.html', users=users)

@app.route('/user_details/<int:user_id>')
def user_details(user_id):
    try:
        # Try to get user details from Memcached
        user_details_bytes = memcache_client.get(str(user_id))

        if user_details_bytes is not None:
            # Convert bytes to a dictionary
            user_details = json.loads(user_details_bytes.decode('utf-8'))
            source = "Memcache"
        else:
            # If not in Memcached, fetch details from the database
            connection = pymysql.connect(**db_config)
            try:
                with connection.cursor() as cursor:
                    # Fetch details of a specific user
                    sql = 'SELECT * FROM users WHERE id = %s'
                    cursor.execute(sql, (user_id,))
                    user_details = cursor.fetchone()

                    # Store user details in Memcached
                    memcache_client.set(str(user_id), json.dumps(user_details, ensure_ascii=False))
            finally:
                connection.close()

            source = "Database"

        if user_details:
            return render_template('userDetails.html', user_details=user_details, source=source)
        else:
            error_message = "User not found"
            return render_template('userDetails.html', source=source, error_message=error_message)

    except Exception as e:
        # Log the exception
        return render_template('userDetails.html', error_message="An error occurred")

@app.route('/test_rabbitmq')
def test_rabbitmq():
    return render_template('testRabbitmq.html')

@app.route('/send', methods=['POST'])
def send():
    connection = pika.BlockingConnection(rabbitmq_parameters)
    channel = connection.channel()

    exchange_name = 'notifExchange'
    message = request.form['message']

    channel.basic_publish(exchange=exchange_name, routing_key='', body=message)
    connection.close()

    return "OK"

        
if __name__ == '__main__':
    app.run(port=3000,host='0.0.0.0')
