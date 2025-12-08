from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'test-topic',
    bootstrap_servers="localhost:9094",
    auto_offset_reset='earliest',
    group_id=None,                
    value_deserializer=lambda x: json.loads(x.decode('utf-8'))
)

print("Consumer started, waiting for messages...")
for message in consumer:
    print(f"Received: {message.value}")