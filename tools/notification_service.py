import pika

# RabbitMQ connection details
rabbitmq_credentials = pika.PlainCredentials('guest', 'Iw00100110!')
connection = pika.BlockingConnection(pika.ConnectionParameters('192.168.56.13', credentials=rabbitmq_credentials))
channel = connection.channel()

exchange_name = 'notifExchange'
queue_name = 'notifQueue'


def callback(ch, method, properties, body):
    print(f"Received: {body}")

channel.basic_consume(queue=queue_name, on_message_callback=callback, auto_ack=True)
print("Waiting for messages...")
channel.start_consuming()
