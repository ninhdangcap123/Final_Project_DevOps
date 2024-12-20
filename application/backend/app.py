import pg8000
import os
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)

def load_env_file(filepath):
    with open(filepath) as f:
        for line in f:
            # Remove whitespace and comments
            line = line.strip()
            if line and not line.startswith('#'):
                key, value = line.split('=', 1)
                os.environ[key] = value

def get_db_credentials():
    try:
        username = os.getenv('DB_USERNAME')  # Retrieve username from the environment
        password = os.getenv('DB_PASSWORD')  # Retrieve password from the environment
        
        if not username or not password:
            raise ValueError("Database credentials not found in environment variables.")
        
        logging.info('Successfully retrieved database credentials from environment.')
        return username, password
    except Exception as e:
        logging.error(f'Error retrieving credentials from environment: {e}')
        raise


def connect_to_db():
    load_env_file('output.env')  # Load environment variables from the file
    username, password = get_db_credentials()
    rds_host = os.getenv('RDS_ENDPOINT')  # Get the RDS endpoint from the environment variable
    
    connection = None  # Initialize connection to None

    try:
        # Attempt to connect to the PostgreSQL database
        connection = pg8000.connect(
            host=rds_host,
            database='postgres',  # Adjust if you have a specific database name
            user=username,
            password=password,
            timeout=10  # Set a timeout for connection
        )
        logging.info('Connected to the database.')

        # Print connection properties
        logging.info(f'Connection properties: Host={rds_host}, User={username}')

        # Get the server version using SQL
        cursor = connection.cursor()
        cursor.execute("SELECT version();")
        db_version = cursor.fetchone()[0]
        logging.info(f'Database version: {db_version}')

        # Clean up cursor
        cursor.close()

    except pg8000.OperationalError as e:
        logging.error(f'Operational error connecting to the database: {e}')
    except Exception as e:
        logging.error(f'Error connecting to the database: {e}')
    finally:
        # Ensure the connection is closed properly
        if connection:
            connection.close()
            logging.info('Database connection closed.')

if __name__ == "__main__":
    connect_to_db()
