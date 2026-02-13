#!/bin/bash

# Connect to salon database and display services
PSQL="psql -X --username=postgres --dbname=salon --tuples-only -c"

# Function to display services
display_services() {
  echo "Here are our services:"
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id;" | awk '{print $1 ") " $NF}'
}

# Function to get service name by ID
get_service_name() {
  local service_id=$1
  $PSQL "SELECT name FROM services WHERE service_id = $service_id;" | xargs
}

# Display services initially
display_services

# Loop until valid service is selected
while true; do
  echo -e "\nWhat service would you like, or enter a number for our list of services?"
  read SERVICE_ID_SELECTED

  # Check if service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | xargs)
  
  if [[ -z "$SERVICE_NAME" ]]; then
    echo -e "\nI could not find that service. Here is a list of our services:"
    display_services
  else
    break
  fi
done

# Prompt for phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';" | xargs)

# If customer doesn't exist, add them
if [[ -z "$CUSTOMER_ID" ]]; then
  echo -e "\nI don't have a phone number for you. What's your name?"
  read CUSTOMER_NAME
  
  # Insert new customer
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
  
  # Get the new customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';" | xargs)
else
  # Get customer name for confirmation
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;" | xargs)
fi

# Prompt for time
echo -e "\nWhat time would you like your appointment?"
read SERVICE_TIME

# Insert appointment
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Display confirmation message
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."