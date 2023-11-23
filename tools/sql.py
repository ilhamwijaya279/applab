import pymysql

# Database connection parameters
db_config = {
    'host': '192.168.56.14',
    'user': 'admin',
    'password': 'Admin123!@#',
    'database': 'users'
}

try:
    # Establish a connection to the database
    connection = pymysql.connect(**db_config)

    with connection.cursor() as cursor:
        # Check if the 'users' table exists
        table_name = 'users'
        cursor.execute(f"SHOW TABLES LIKE '{table_name}'")

        if cursor.fetchone():
            print(f"The '{table_name}' table exists in the '{db_config['database']}' database.")
        else:
            print(f"The '{table_name}' table does not exist in the '{db_config['database']}' database.")

except pymysql.Error as e:
    print(f"Error: {e}")

finally:
    # Close the database connection
    if 'connection' in locals() and connection.open:
        connection.close()
        print("Connection closed")
