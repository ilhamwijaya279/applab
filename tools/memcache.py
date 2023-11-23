from pymemcache.client.base import Client
import json

# Replace '192.168.56.12' with your Memcached server address
memcached_client = Client(('192.168.56.12', 11211))

# Specify the key you want to retrieve
key = 'users_data:1'

# Attempt to retrieve data from Memcached
data_from_cache = memcached_client.get(key)

if data_from_cache:
    # If data is in Memcached, load and print it
    user_details = json.loads(data_from_cache.decode('utf-8'))
    print('Data retrieved from Memcached:', user_details)
else:
    print('Data not found in Memcached.')
