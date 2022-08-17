import sqlalchemy as db
from sqlalchemy.orm import declarative_base, sessionmaker

DB_URL = "postgresql://postgres@localhost:5432/dbms"

Base = declarative_base()


class Customer(Base):
    __tablename__ = "customer"

    custssn = db.Column(db.String, primary_key=True)
    custdob = db.Column(db.Date)
    custmiddleinitial = db.Column(db.String)
    custfirstname = db.Column(db.String)
    custlastname = db.Column(db.String)
    custemailaddress = db.Column(db.String)
    gender = db.Column(db.String)


class ProductRider(Base):
    __tablename__ = "productrider"

    ridername = db.Column(db.String, primary_key=True)
    lineofbusiness = db.Column(db.String, primary_key=True)
    planname = db.Column(db.String, primary_key=True)
    seriesname = db.Column(db.String, primary_key=True)
    description = db.Column(db.String)
    annualizedpremium = db.Column(db.Integer)


class Quote(Base):
    __tablename__ = "quote"

    quotenumber = db.Column(db.Integer, primary_key=True)
    custssn = db.Column(db.String, primary_key=True)
    planname = db.Column(db.String, primary_key=True)
    quotecost = db.Column(db.Integer)


class Account(Base):
    __tablename__ = "account"

    companycode = db.Column(db.Integer, primary_key=True)
    custssn = db.Column(db.String, primary_key=True)
    accountname = db.Column(db.String)
    workaddress1 = db.Column(db.String)
    workaddress2 = db.Column(db.String)
    workcity = db.Column(db.String)
    workstate = db.Column(db.String)
    workzip = db.Column(db.Integer)


class ProductPlan(Base):
    __tablename__ = "productplan"

    lineofbusiness = db.Column(db.String, primary_key=True)
    planname = db.Column(db.String, primary_key=True)
    seriesname = db.Column(db.String, primary_key=True)
    plancode = db.Column(db.Integer)
    description = db.Column(db.String)
    benefit = db.Column(db.String)


class Contract(Base):
    __tablename__ = "contract"

    lineofbusiness = db.Column(db.String, primary_key=True)
    seriesname = db.Column(db.String, primary_key=True)
    planname = db.Column(db.String, primary_key=True)
    contractnumber = db.Column(db.Integer, primary_key=True)
    activitystatus = db.Column(db.String)
    billingmethod = db.Column(db.String)
    companycode = db.Column(db.Integer)
    custssn = db.Column(db.String)


def get_session(url: str = DB_URL):
    engine = db.create_engine(url)
    Session = sessionmaker(bind=engine)
    return Session()


def customer_exists(ssn: str, session):
    ssns = [i.custssn for i in session.query(Customer).order_by(Customer.custssn)]
    return ssn in ssns


def get_customer(ssn: str, session) -> Customer:
    for customer in session.query(Customer).filter_by(custssn=ssn):
        if customer:
            return customer

    raise Exception(f"Customer for {ssn} not found!")


def get_product_rider(planname: str, session) -> ProductRider:
    for rider in session.query(ProductRider).filter_by(planname=planname):
        if rider:
            return rider

    raise Exception(f"Rider for {planname} not found!")


def get_quote_by_ssn_and_plan(ssn: str, planname: str, session) -> Quote:
    for quote in session.query(Quote).filter_by(custssn=ssn, planname=planname):
        if quote:
            return quote

    raise Exception(f"Quote for {ssn} not found!")


def add_quote(ssn: str, cost: int, planname: str, session):
    try:
        existing_quote = get_quote_by_ssn_and_plan(ssn, planname, session)
    except:
        existing_quote = None

    if existing_quote:
        existing_quote.cost = cost
        session.commit()
        return

    quote_id = len([q for q in session.query(Quote)]) + 1
    new_quote = Quote(
        quotenumber=quote_id, custssn=ssn, quotecost=cost, planname=planname
    )
    session.add(new_quote)
    session.commit()


def get_product_plan_from_name(plan_name: str, session) -> ProductPlan:
    for pp in session.query(ProductPlan).filter_by(planname=plan_name):
        if pp:
            return pp


def get_account(company_code: int, ssn: str, session):
    for account in session.query(Account).filter_by(
        companycode=company_code, custssn=ssn
    ):
        if account:
            return account


def add_account_and_contract(
    company_code: int,
    cust_ssn: str,
    account_name: str,
    address_1: str,
    address_2: str,
    city: str,
    state: str,
    zip: str,
    plan_name: str,
    session,
):

    if not get_account(company_code, cust_ssn, session):
        new_account = Account(
            companycode=company_code,
            custssn=cust_ssn,
            accountname=account_name,
            workaddress1=address_1,
            workaddress2=address_2,
            workcity=city,
            workstate=state,
            workzip=zip,
        )

        session.add(new_account)
        session.commit()

    pp = get_product_plan_from_name(plan_name, session)

    contract_id = len([i for i in session.query(Contract)]) + 1

    new_contract = Contract(
        lineofbusiness=pp.lineofbusiness,
        seriesname=pp.seriesname,
        planname=pp.planname,
        contractnumber=contract_id,
        activitystatus="Active",
        billingmethod="Online",
        companycode=company_code,
        custssn=cust_ssn,
    )

    session.add(new_contract)
    session.commit()
