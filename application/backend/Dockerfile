# Use a slim version of Python 3.8 as the base image
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the application code into the container
COPY app.py .

# Install required packages
RUN pip install boto3 pg8000

# Command to run the application
CMD ["python", "app.py"]
