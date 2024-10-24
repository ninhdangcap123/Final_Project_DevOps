FROM python:3.9

# Install the AWS CLI
RUN apt-get update && apt-get install -y awscli

# Copy your application code
COPY app.py /app/app.py

# Install required Python packages
RUN pip install boto3 pg8000

# Set the working directory
WORKDIR /app

# Set the command to run your app
CMD ["python", "app.py"]
