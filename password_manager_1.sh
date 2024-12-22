#!/bin/bash

# File to store encrypted credentials
CREDENTIALS_FILE="credentials_1.enc"

# Temporary decrypted file
TEMP_FILE="credentials_1.tmp"

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

# Function to retrieve credentials for a service
retrieve_credential() {
  read -p "Enter service name: " service
  decrypt_credentials
  results=$(grep -i "^$service|" "$TEMP_FILE")
  if [[ -z "$results" ]]; then
    echo "No credentials found for service: $service"
  else
    echo "Credentials for service: $service"
    echo "$results" | awk -F "|" '{print NR ". User ID: " $2 ", Password: " $3}'
  fi
  encrypt_credentials
}

# Function to list all stored services
list_services() {
  decrypt_credentials
  echo "Stored Services:"
  awk -F "|" '{print NR ". " $1}' "$TEMP_FILE" | sort | uniq
  encrypt_credentials
}

# Function to delete a credential
delete_credential() {
  read -p "Enter service name to delete: " service
  decrypt_credentials
  matching_lines=$(grep -i "^$service|" "$TEMP_FILE")
  if [[ -z "$matching_lines" ]]; then
    echo "No credentials found for service: $service"
  else
    echo "Found the following entries for $service:"
    echo "$matching_lines" | awk -F "|" '{print NR ". User ID: " $2 ", Password: " $3}'
    read -p "Enter the number of the entry to delete (or 'all' to delete all): " entry
    if [[ "$entry" == "all" ]]; then
      sed -i "/^$service|/d" "$TEMP_FILE"
      echo "All credentials for $service have been deleted."
    else
      entry_line=$(echo "$matching_lines" | sed -n "${entry}p")
      sed -i "/^$(echo "$entry_line" | sed 's/[\/&]/\\&/g')/d" "$TEMP_FILE"
      echo "Selected credential deleted."
    fi
  fi
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

