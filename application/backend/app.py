import boto3
import pg8000
import os
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)

def get_db_credentials():
    region_name = 'us-east-1'
    ssm = boto3.client('ssm', region_name=region_name)
    try:
        username = ssm.get_parameter(Name='/ninhnh/db_username', WithDecryption=True)['Parameter']['Value']
        password = ssm.get_parameter(Name='/ninhnh/db_password', WithDecryption=True)['Parameter']['Value']
        
        logging.info('Successfully retrieved database credentials.')
        return username, password
    except Exception as e:
        logging.error(f'Error retrieving credentials from SSM: {e}')
        raise


def connect_to_db():
    username, password = get_db_credentials()
    rds_host = os.getenv('RDS_HOST', 'terraform-20241024033946277900000002.cfwoy6guyqmd.us-east-1.rds.amazonaws.com')

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
        if 'connection' in locals() and connection:
            connection.close()
            logging.info('Database connection closed.')

if __name__ == "__main__":
    connect_to_db()
