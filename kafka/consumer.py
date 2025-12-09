from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'test-topic-1',
  bootstrap_servers="localhost:9095",
    auto_offset_reset='earliest',
    group_id=None,                
    value_deserializer=lambda x: json.loads(x.decode('utf-8')),
    security_protocol="PLAINTEXT",
)

print("Consumer started, waiting for messages...")
for message in consumer:
    print(f"Received: {message.value}")