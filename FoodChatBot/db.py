import mysql.connector
def connect_to_mysql():
    try:
        # Connect to the database
        connection = mysql.connector.connect(
            host="localhost",
            user="root",
            password="Santhosh@123",
            database="pandeyji_eatery"
        )

        if connection.is_connected():
            print("Connected to MySQL database")
            return connection

    except mysql.connector.Error as e:
        print("Error connecting to MySQL database:", e)
        return None

def close_connection(connection):
    if connection:
        connection.close()
        print("Connection closed")

def main():
    # Connect to MySQL
    connection = connect_to_mysql()

    if connection:
        # Execute SQL queries or operations here
        # For example:
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM pandeyji_eatery.food_items")
        rows = cursor.fetchall()
        for row in rows:
            print(row)

        # Close the connection
        close_connection(connection)

if __name__ == "__main__":
    main()
