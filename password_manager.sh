#!/bin/bash

# File to store encrypted credentials
CREDENTIALS_FILE="credentials.enc"

# Temporary decrypted file
TEMP_FILE="credentials.tmp"

# Master password for encryption/decryption
MASTER_PASSWORD=""

# Function to load the master password
load_master_password() {
  if [[ -z "$MASTER_PASSWORD" ]]; then
    read -s -p "Enter master password: " MASTER_PASSWORD
    echo
  fi
}

# Function to decrypt the credentials file
decrypt_credentials() {
  if [[ -f "$CREDENTIALS_FILE" ]]; then
    openssl aes-256-cbc -d -in "$CREDENTIALS_FILE" -out "$TEMP_FILE" -k "$MASTER_PASSWORD" 2>/dev/null
    if [[ $? -ne 0 ]]; then
      echo "Error: Incorrect master password or corrupted file."
      exit 1
    fi
  else
    touch "$TEMP_FILE"
  fi
}

# Function to encrypt the credentials file
encrypt_credentials() {
  openssl aes-256-cbc -e -in "$TEMP_FILE" -out "$CREDENTIALS_FILE" -k "$MASTER_PASSWORD" 2>/dev/null
  rm -f "$TEMP_FILE"
}

# Function to add a new credential
add_credential() {
  read -p "Enter service name: " service
  read -p "Enter user ID: " user_id
  read -s -p "Enter password: " password
  echo
  decrypt_credentials
  echo "$service|$user_id|$password" >> "$TEMP_FILE"
  echo "Credential added successfully!"
  encrypt_credentials
}

# Function to retrieve a credential
retrieve_credential() {
  read -p "Enter service name: " service
  decrypt_credentials
  result=$(grep -i "^$service|" "$TEMP_FILE")
  if [[ -z "$result" ]]; then
    echo "No credentials found for service: $service"
  else
    user_id=$(echo "$result" | awk -F "|" '{print $2}')
    password=$(echo "$result" | awk -F "|" '{print $3}')
    echo "User ID: $user_id"
    echo "Password: $password"
  fi
  encrypt_credentials
}

# Function to list all stored services
list_services() {
  decrypt_credentials
  echo "Stored Services:"
  awk -F "|" '{print NR ". " $1}' "$TEMP_FILE"
  encrypt_credentials
}

# Function to delete a credential
delete_credential() {
  read -p "Enter service name to delete: " service
  decrypt_credentials
  sed -i "/^$service|/d" "$TEMP_FILE"
  echo "Credential deleted (if it existed)."
  encrypt_credentials
}

# Function to display the menu
show_menu() {
  echo "--------------------------------------"
  echo "       Password Manager"
  echo "--------------------------------------"
  echo "1. Add a new credential"
  echo "2. Retrieve a credential"
  echo "3. List all stored services"
  echo "4. Delete a credential"
  echo "5. Exit"
  echo "--------------------------------------"
}

# Main program loop
while true; do
  load_master_password
  show_menu
  read -p "Choose an option (1-5): " choice
  case $choice in
    1)
      add_credential
      ;;
    2)
      retrieve_credential
      ;;
    3)
      list_services
      ;;
    4)
      delete_credential
      ;;
    5)
      echo "Goodbye! Stay secure!"
      break
      ;;
    *)
      echo "Invalid choice. Please choose a number between 1 and 5."
      ;;
  esac
  echo
done

