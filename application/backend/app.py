import os
import boto3
import json
import psycopg2

def get_db_credentials(env):
    """Retrieve database credentials from SSM Parameter Store for the given environment."""
    ssm = boto3.client('ssm')
    parameter_name = f'/myapp/{env}/db_credentials'
    
    try:
        param = ssm.get_parameter(Name=parameter_name, WithDecryption=True)
        credentials = json.loads(param['Parameter']['Value'])
        return credentials
    except Exception as e:
        print(f"Error retrieving credentials: {e}")
        return None

def main():
    # Determine the environment (default to 'dev' if not set)
    env = os.getenv("ENVIRONMENT", "dev")
    
    # Retrieve credentials
    credentials = get_db_credentials(env)
    
    if credentials is None:
        print("Failed to retrieve database credentials.")
        return

    # Connect to PostgreSQL RDS
    try:
        conn = psycopg2.connect(
            dbname=credentials['dbname'],  # Use environment-specific dbname
            user=credentials['username'],
            password=credentials['password'],
            host=credentials['host'],  # RDS endpoint should also be stored in SSM
            port="5432"
        )

        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        db_version = cursor.fetchone()

        print(f"Connected to database version: {db_version[0]}")

        cursor.close()
        conn.close()
    
    except Exception as e:
        print(f"Database connection error: {e}")

if __name__ == "__main__":
    main()
