# Quizhoot

-**Quizhoot** is an app that allows users to create flashcards, games, and classrooms to help them learn new words. This project is built using **Flutter**.

# Video for How To Run Flutter App in VSCode Android Emulator

Link: https://youtu.be/EhGW4UYpKSE?si=NW1FzKU-CqD5uIrg

## Getting Started

-Follow the steps below to get the project up and running on your local machine.
## Installation and Setup

### 1. Clone the Repository
Clone the project repository from GitHub:
```bash
git clone https://github.com/phlippos/Quizhoot.git
```

### 2. Create a Virtual Environment
Set up a virtual environment for the project:
```bash
python -m venv quizhoot
```

Activate the virtual environment:
- **Linux/Mac**:
  ```bash
  source quizhoot/bin/activate
  ```
- **Windows**:
  ```bash
  quizhoot\Scripts\activate
  ```

### 3. Install Dependencies
Install the required Python packages:
```bash
pip install -r requirements.txt
```

### 4. Install MySQL
- Download and install MySQL Server: [MySQL Server](https://dev.mysql.com/downloads/mysql/)
- (Optional) Download MySQL Workbench: [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)

### 5. Set Up the Database
Start the MySQL server and create a new database:
```sql
CREATE DATABASE quizhoot;
```

Update the `DATABASES` configuration in `myproject/settings.py`:
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'quizhoot',  
        'USER': 'root',  # Replace with your username
        'PASSWORD': 'yourpassword',  # Replace with your password
        'HOST': 'localhost',  
        'PORT': '3306',  
    }
}
```

### 6. Migrations
Before running the server, clear old migration files to avoid conflicts:
- Navigate to `Quizhoot/quizhootv1/quizhoot/migrations` and delete all `.py` files (except `__init__.py`).
- Delete the contents of the `__pycache__` folder (except `__init__.cpython`).

Run the following commands to apply migrations and create a superuser:
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```

### 7. Run the Server
Start the server using Daphne:
```bash
daphne -b 127.0.0.1 -p 8000 quizhootv1.asgi:application
```

### Prerequisites

- You should have "Git" installed.
- You should have "Android Studio" or "Android Studio Ladybug" installed.
- You need an IDE preferably "VS Code", or "IntelliJ IDEA" to work on the project.
- You should have the "Flutter SDK" installed.

### Installation

1. **Clone the Project**:

- Clone the repository to your local machine.

  ```bash
  git https://github.com/phlippos/Quizhoot.git
  ```

- Navigate into the project directory
  ```bash
  cd QuizHootProject
  ```

2. **Install Dependencies**

- Ensure you have the Flutter SDK installed and set up correctly.

- Run the following command to install the required Flutter packages:
  ```bash
  flutter pub get
  ```

3. **Start the Android Emulator**

- Open the Android emulator in Android Studio or VS Code.

4. **Run the Project**

- To run the project on the emulator or connected device, use the following command:
  ```bash
  flutter run
  ```
