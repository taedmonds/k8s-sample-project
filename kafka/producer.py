from kafka import KafkaProducer
import json

producer = KafkaProducer(
    bootstrap_servers="localhost:9094",
    value_serializer=lambda v: json.dumps(v).encode('utf-8'),
    api_version=(3, 8, 0),
    retries=3,
    request_timeout_ms=30000
)
producer.send('test-topic', {'message': 'Hello, Kafka from Python!'})
producer.flush()
print("Message sent!")