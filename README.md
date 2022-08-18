# DBMS Final Project

## Setting up the database

The database used for this project is `PostgreSQL`. First, install `postgres` on the machine you're planning to run this on.

```
# Mac OS
$ brew install postgres
```

```
# Debian Linux Distributions
$ apt-get install postgres
```

```
# Red Hat Linux Distributions
$ yum install postgres
```
Once the database is installed, ensure that the Postgres is started. Below is an example of how to install on MacOS, check the [Postgres documentation](https://www.postgresql.org/docs/current/server-start.html) for other operating systems. 

```
$ brew services start postgresql
```
You may also need to create a new user:
```
# Connect to the database
$ psql postgres

# Replace 'newUser' with your desired username and password with your 'password'
postgres=# CREATE ROLE newUser WITH LOGIN PASSWORD ‘password’; 
postgres=# ALTER ROLE newUser CREATEDB;
postgres=# exit
```

Once you have an account configured, restore the database included in the repository:
```
# From inside the repository
$ psql -U <username> -f ./webapp/data/db/insurance_company.sql
```
The app assumes Postgres is running on its default port of `5432`. Make sure its using the correct port!

## Installing webapp dependencies

There are a number of third party Python libraries used in this application. You'll want to install them inside of a Python virtual environment:

```
# Make sure you're in the webapp directory
$ cd webapp/

# Set up a virtual environment
$ python3 -m venv .venv

# Activate your virtual environment
$ source .venv/bin/activate

# Update pip
$ python3 -m pip install --upgrade pip

# Install requirements
$ pip install -r requirements.txt
```

## Running Flask

This app is built using Flask. To keep things simple, run with the built-in development server.

```
# Set environment variables
$ export FLASK_APP=app
$ export FLASK_ENV=development

# Start the app
$ cd src/
$ flask run
```
Flask should attempt to start the webserver and provide a URL to access the application (usually `127.0.0.1:5000`). 
