#!/bin/bash

# File to store tasks
TODO_FILE="todo_list.txt"

# Ensure the todo file exists
touch $TODO_FILE

# Function to display the menu
show_menu() {
  echo "---------------------------"
  echo " To-Do List Manager"
  echo "---------------------------"
  echo "1. View Tasks"
  echo "2. Add Task"
  echo "3. Remove Task"
  echo "4. Exit"
  echo "---------------------------"
}

# Function to view tasks
view_tasks() {
  if [ ! -s $TODO_FILE ]; then
    echo "No tasks found! Your to-do list is empty."
  else
    echo "Your To-Do List:"
    nl -s ". " $TODO_FILE
  fi
}

# Function to add a task
add_task() {
  read -p "Enter the task description: " task
  if [ -n "$task" ]; then
    echo "$task" >> $TODO_FILE
    echo "Task added successfully!"
  else
    echo "Task cannot be empty. Try again."
  fi
}

# Function to remove a task
remove_task() {
  view_tasks
  if [ ! -s $TODO_FILE ]; then
    return
  fi

  read -p "Enter the task number to remove: " task_num
  if [[ $task_num =~ ^[0-9]+$ ]]; then
    sed -i "${task_num}d" $TODO_FILE
    echo "Task #$task_num removed successfully!"
  else
    echo "Invalid input. Please enter a valid task number."
  fi
}

# Main program loop
while true; do
  show_menu
  read -p "Choose an option (1-4): " choice
  case $choice in
    1)
      view_tasks
      ;;
    2)
      add_task
      ;;
    3)
      remove_task
      ;;
    4)
      echo "Goodbye! Have a productive day!"
      break
      ;;
    *)
      echo "Invalid option. Please choose a number between 1 and 4."
      ;;
  esac
  echo
done

