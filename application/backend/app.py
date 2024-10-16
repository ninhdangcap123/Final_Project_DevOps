import boto3
import json
import psycopg2

# Retrieve credentials from SSM Parameter Store
ssm = boto3.client('ssm')
param = ssm.get_parameter(Name='/myapp/db_credentials', WithDecryption=True)
credentials = json.loads(param['Parameter']['Value'])

# Connect to PostgreSQL RDS
conn = psycopg2.connect(
    dbname="mydb",
    user=credentials['username'],
    password=credentials['password'],
    host="your-rds-endpoint",  # Replace with your RDS endpoint
    port="5432"
)

cursor = conn.cursor()
cursor.execute("SELECT version();")
db_version = cursor.fetchone()

print(f"Connected to database version: {db_version[0]}")

cursor.close()
conn.close()
