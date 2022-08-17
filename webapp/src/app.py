from datetime import datetime
from uuid import uuid4
import warnings

from flask import Flask, render_template, request, url_for, flash, redirect

from db import (
    Customer,
    add_account_and_contract,
    add_quote,
    get_session,
    customer_exists,
    get_customer,
    get_product_rider,
    get_quote_by_ssn_and_plan,
)
from ml import load_dataframe, train_model, SurveyData, predict, normalize_sample_data

warnings.filterwarnings("ignore")


app = Flask(__name__)
app.secret_key = "very secret key"

print("Start training model...")
MODEL = train_model(load_dataframe())
print("Finished training model")


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/signup/", methods=("GET", "POST"))
def signup():
    if request.method == "POST":
        first_name = request.form["first_name"]
        middle_initial = request.form["middle_initial"]
        last_name = request.form["last_name"]
        email_address = request.form["email_address"]
        dob = request.form["dob"]
        gender = request.form["gender"]
        ssn = request.form["ssn"].replace("-", "")

        if not first_name:
            flash("First name is required!")

        elif not middle_initial:
            flash("Middle initial is required!")

        elif not last_name:
            flash("Last name is required!")

        elif not email_address:
            flash("Email address is required!")

        elif not dob:
            flash("Date of birth is required!")

        elif not gender:
            flash("Gender is required!")

        elif not ssn:
            flash("SSN is required!")

        else:
            session = get_session()
            if customer_exists(ssn, session):
                flash("You already have an account!")
            else:
                new_customer = Customer(
                    custssn=ssn,
                    custdob=dob,
                    custmiddleinitial=middle_initial,
                    custfirstname=first_name,
                    custlastname=last_name,
                    custemailaddress=email_address,
                    gender=gender,
                )
                session.add(new_customer)
                session.commit()

            flash("Account successfully created!")

    return render_template("signup.html")


def _get_age(dob: str):
    dt_dob = datetime.strptime(dob, "%Y-%M-%d")
    # This is not exactly accurate, but good enough for demo purposes
    return (datetime.now() - dt_dob).days // 365


@app.route("/quote/", methods=("GET", "POST"))
def quote():
    if request.method == "POST":
        db_session = get_session()
        ssn = request.form["ssn"].replace("-", "")
        if not customer_exists(ssn, db_session):
            flash("You do not have an account yet! Sign up first!")
        else:
            # rider = get_product_rider(request.form['product'], db_session)
            customer = get_customer(ssn, db_session)
            age = _get_age(customer.custdob.strftime("%Y-%M-%d"))
            planname = request.form["product"].strip()
            rider = get_product_rider(planname, db_session)
            multiplier = 1
            data = SurveyData(
                age,
                customer.gender == "M",
                request.form["smoke"] == "Yes",
                request.form["fingers"] == "Yes",
                request.form["anxiety"] == "Yes",
                request.form["peer"] == "Yes",
                request.form["chronic"] == "Yes",
                request.form["fatigue"] == "Yes",
                request.form["allergies"] == "Yes",
                request.form["wheeze"] == "Yes",
                request.form["alcohol"] == "Yes",
                request.form["cough"] == "Yes",
                request.form["breath"] == "Yes",
                request.form["swallow"] == "Yes",
                request.form["chest"] == "Yes",
            )

            # Result is 1 or 0
            result = int(predict(MODEL, normalize_sample_data(data))[-1])

            # Increase prices by 50% if somebody is likely to develop lung cancer
            multiplier = result * 1.5

            cost = float(rider.annualizedpremium) * multiplier
            add_quote(ssn, cost, planname, db_session)
            quote = get_quote_by_ssn_and_plan(ssn, planname, db_session)
            flash(f"Your quote is ${quote.quotecost} annually")

    return render_template("quote.html")


@app.route("/policy/", methods=("GET", "POST"))
def policy():
    if request.method == "POST":
        db_session = get_session()

        ssn = request.form["ssn"].replace("-", "")
        product = request.form["product"].strip()
        company = request.form["company"]
        company_code = company.split("-")[0].strip()
        account_name = request.form["account_name"]
        address_1 = request.form["address_1"]
        address_2 = request.form["address_2"]
        city = request.form["city"]
        state = request.form["state"]
        zip = request.form["zip"]

        valid_quote = True

        try:
            get_quote_by_ssn_and_plan(ssn, product, db_session)
        except Exception as e:
            flash(str(e))
            valid_quote = False

        if len(state) != 2:
            flash("Use 2 character abbreviation for State!")
            valid_quote = False

        if len(zip) != 5:
            flash("Use 5 digit zip code")
            valid_quote = False

        if valid_quote:
            add_account_and_contract(
                company_code,
                ssn,
                account_name,
                address_1,
                address_2,
                city,
                state,
                zip,
                product,
                db_session,
            )

            flash("Created new account and contract!")

    return render_template("policy.html")
