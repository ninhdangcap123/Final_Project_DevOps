import boto3
import pg8000
import os
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)

def get_db_credentials():
    ssm = boto3.client('ssm')
    try:
        username = ssm.get_parameter(Name='/myapp/db_username', WithDecryption=False)['Parameter']['Value']
        password = ssm.get_parameter(Name='/myapp/db_password', WithDecryption=True)['Parameter']['Value']
        return username, password
    except Exception as e:
        logging.error(f'Error retrieving credentials from SSM: {e}')
        raise

def connect_to_db():
    username, password = get_db_credentials()
    rds_host = os.getenv('RDS_HOST', 'ninhnh-vti-rds-database.cfwoy6guyqmd.us-east-1.rds.amazonaws.com')
    
    try:
        connection = pg8000.connect(
            host=rds_host,
            database='postgres',  # Adjust if you have a specific database name
            user=username,
            password=password
        )
        logging.info('Connected to database.')
        
        # Get the server version using SQL
        cursor = connection.cursor()
        cursor.execute("SELECT version();")
        db_version = cursor.fetchone()[0]
        logging.info(f'Database version: {db_version}')

        # Clean up
        cursor.close()
        connection.close()
    except Exception as e:
        logging.error(f'Error connecting to the database: {e}')

if __name__ == "__main__":
    connect_to_db()
