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
Once the database is installed, restore the database configuration:

```
# From inside the repository
$ psql -f ./webapp/data/db/insurance_company.sql
```

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
