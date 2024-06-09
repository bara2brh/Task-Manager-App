# Task Manager App
This Flutter project is a task manager app that allows users to efficiently manage their tasks. Users can log in securely, view, add, edit, and delete tasks, implement pagination for fetching tasks efficiently, and persist tasks locally for data persistence. The project also includes comprehensive unit tests to ensure functionality.

# Key Features
User Authentication: Users can log in securely with their Username and Password.
Task Management: Users can view, add, edit, and delete tasks.
Pagination: Efficient pagination for fetching tasks from the server.
State Management: Implemented using the Bloc pattern for efficient state management.
Local Storage: Tasks are persisted locally using shared preferences.
#  How to Build and Run
Prerequisites
Ensure that you have Flutter installed on your development machine. You can install Flutter from here.
Steps
Clone this repository to your local machine:
bash
Copy code
git clone https://github.com/bara2brh/task-manager-app.git
Navigate to the project directory:
bash
Copy code
cd task-manager-app
Install dependencies:
bash
Copy code
flutter pub get
Run the app:
bash
Copy code
flutter run
# Design Decisions
State Management: Implemented using the Bloc pattern for its simplicity, scalability, and separation of concerns.
Pagination: Implemented server-side pagination to fetch tasks efficiently and reduce network bandwidth usage.
Local Storage: Utilized shared preferences  and sqlite for local storage due to its simplicity and ease of use.
Challenges Faced
Pagination: Implementing pagination for fetching tasks efficiently from the server posed a challenge, but it was overcome by carefully studying the documentation and implementing the required logic.
# Additional Features
Dark Mode: Implemented a dark mode feature to enhance user experience in low-light environments.
