--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.account (
    companycode integer NOT NULL,
    custssn character(9) NOT NULL,
    accountname character varying(18),
    workaddress1 character varying(18),
    workaddress2 character varying(18),
    workcity character varying(18),
    workstate character varying(2),
    workzip numeric(5,0)
);


ALTER TABLE public.account OWNER TO cam;

--
-- Name: accountassociate; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.accountassociate (
    companycode integer NOT NULL,
    sitecode integer NOT NULL,
    custssn character(9) NOT NULL,
    associatessn character(18) NOT NULL,
    startdate character(18)
);


ALTER TABLE public.accountassociate OWNER TO cam;

--
-- Name: associate; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.associate (
    associatessn character(18) NOT NULL,
    associatedob date,
    associatesuffix character varying(2),
    associatemiddleinitial character(1),
    associatelastname character varying(18),
    associatefirstname character varying(18),
    hiredate date
);


ALTER TABLE public.associate OWNER TO cam;

--
-- Name: billingaccount; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.billingaccount (
    companycode integer NOT NULL,
    custssn character(9) NOT NULL,
    bacctid integer NOT NULL,
    bacctname character varying(18),
    billingaddress1 character varying(18),
    billingaddress2 character varying(18),
    billingcity character varying(18),
    billingstate character(2),
    billingzip numeric(5,0),
    taxidnumber integer,
    onlinebillingflag bit(1)
);


ALTER TABLE public.billingaccount OWNER TO cam;

--
-- Name: claim; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.claim (
    claimnumber character(18) NOT NULL,
    claimdate date,
    settlementdate date,
    claimamount numeric
);


ALTER TABLE public.claim OWNER TO cam;

--
-- Name: claimant; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.claimant (
    claimnumber character(18) NOT NULL,
    lineofbusiness character(18) NOT NULL,
    seriesname character(18) NOT NULL,
    planname character(18) NOT NULL,
    contractnumber integer NOT NULL,
    custssn character(9)
);


ALTER TABLE public.claimant OWNER TO cam;

--
-- Name: companycode; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.companycode (
    companycode integer NOT NULL,
    companyname character(18)
);


ALTER TABLE public.companycode OWNER TO cam;

--
-- Name: managercontract; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.managercontract (
    sitecode integer NOT NULL,
    companycode integer NOT NULL,
    issuedate character(18),
    contracttype character(18),
    contractsigndate date,
    contractprocessdate date
);


ALTER TABLE public.managercontract OWNER TO cam;

--
-- Name: company_mgr_contract; Type: VIEW; Schema: public; Owner: cam
--

CREATE VIEW public.company_mgr_contract AS
 SELECT c.companyname,
    d.sitecode,
    d.contracttype,
    d.contractsigndate
   FROM public.companycode c,
    public.managercontract d
  WHERE (c.companycode = d.companycode);


ALTER TABLE public.company_mgr_contract OWNER TO cam;

--
-- Name: contract; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.contract (
    lineofbusiness character(18) NOT NULL,
    seriesname character(18) NOT NULL,
    planname character(18) NOT NULL,
    contractnumber integer NOT NULL,
    activitystatus character(18),
    billingmethod character(18),
    companycode integer,
    custssn character(9)
);


ALTER TABLE public.contract OWNER TO cam;

--
-- Name: contractbenefit; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.contractbenefit (
    lineofbusiness character(18) NOT NULL,
    seriesname character(18) NOT NULL,
    planname character(18) NOT NULL,
    contractnumber integer NOT NULL,
    ridername character(18) NOT NULL,
    benefitname character varying(18) NOT NULL,
    benefitstartdate date
);


ALTER TABLE public.contractbenefit OWNER TO cam;

--
-- Name: contractpremium; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.contractpremium (
    lineofbusiness character(18) NOT NULL,
    seriesname character(18) NOT NULL,
    planname character(18) NOT NULL,
    contractnumber integer NOT NULL,
    ridername character(18) NOT NULL,
    benefitname character varying(18) NOT NULL,
    premiumid integer NOT NULL,
    annualpremiumcost numeric
);


ALTER TABLE public.contractpremium OWNER TO cam;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.customer (
    custssn character(9) NOT NULL,
    custdob date,
    custmiddleinitial character varying(20),
    custfirstname character varying(20),
    custlastname character varying(20),
    custemailaddress character varying(20),
    gender character(1)
);


ALTER TABLE public.customer OWNER TO cam;

--
-- Name: customeraddress; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.customeraddress (
    custssn character(9) NOT NULL,
    addressnickname character varying(20) NOT NULL,
    custzip numeric(5,0),
    custstate character(2),
    custcity character varying(20),
    custaddress2 character varying(20),
    custaddress1 character varying(20)
);


ALTER TABLE public.customeraddress OWNER TO cam;

--
-- Name: cust_address_info; Type: VIEW; Schema: public; Owner: cam
--

CREATE VIEW public.cust_address_info AS
 SELECT c.custssn,
    c.custfirstname,
    c.custlastname,
    a.custaddress1,
    a.custaddress2,
    a.custcity,
    a.custstate,
    a.custzip
   FROM public.customer c,
    public.customeraddress a
  WHERE (c.custssn = a.custssn);


ALTER TABLE public.cust_address_info OWNER TO cam;

--
-- Name: cust_contracts; Type: VIEW; Schema: public; Owner: cam
--

CREATE VIEW public.cust_contracts AS
 SELECT c.custssn,
    c.custfirstname,
    c.custlastname,
    d.companycode,
    d.companyname,
    e.planname,
    e.contractnumber,
    e.activitystatus
   FROM public.customer c,
    public.companycode d,
    public.contract e
  WHERE ((c.custssn = e.custssn) AND (d.companycode = e.companycode));


ALTER TABLE public.cust_contracts OWNER TO cam;

--
-- Name: cust_details; Type: VIEW; Schema: public; Owner: cam
--

CREATE VIEW public.cust_details AS
 SELECT c.custfirstname,
    c.custlastname,
    c.custssn,
    d.companyname,
    d.companycode
   FROM public.customer c,
    public.companycode d,
    public.account a
  WHERE ((a.custssn = c.custssn) AND (d.companycode = a.companycode));


ALTER TABLE public.cust_details OWNER TO cam;

--
-- Name: customerrelation; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.customerrelation (
    relationssn character(9) NOT NULL,
    custssn character(9) NOT NULL,
    relationfirstname character varying(20),
    relationlastname character varying(20),
    relationmiddleinitial character varying(20),
    relationsuffix character varying(20),
    relationdob date,
    relationtocustomer character varying(20)
);


ALTER TABLE public.customerrelation OWNER TO cam;

--
-- Name: experiment; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.experiment (
    lineofbusiness character(18) NOT NULL,
    experiment_name character varying(18) NOT NULL,
    url character varying(100)
);


ALTER TABLE public.experiment OWNER TO cam;

--
-- Name: invoice; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.invoice (
    companycode integer NOT NULL,
    custssn character(9) NOT NULL,
    bacctid integer NOT NULL,
    lineofbusiness character(18),
    seriesname character(18),
    planname character(18),
    contractnumber integer,
    invoiceid character(18) NOT NULL
);


ALTER TABLE public.invoice OWNER TO cam;

--
-- Name: premium_mgmtcontract; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.premium_mgmtcontract (
    sitecode integer NOT NULL,
    lineofbusiness character(18) NOT NULL,
    seriesname character(18) NOT NULL,
    planname character(18) NOT NULL,
    contractnumber integer NOT NULL,
    ridername character(18) NOT NULL,
    companycode integer NOT NULL,
    benefitname character varying(18) NOT NULL,
    premiumid integer NOT NULL,
    amount character(18),
    commissionrate character(18)
);


ALTER TABLE public.premium_mgmtcontract OWNER TO cam;

--
-- Name: product; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.product (
    lineofbusiness character(18) NOT NULL,
    description character(18)
);


ALTER TABLE public.product OWNER TO cam;

--
-- Name: productplan; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.productplan (
    lineofbusiness character(18) NOT NULL,
    seriesname character(18) NOT NULL,
    planname character(18) NOT NULL,
    plancode character(18),
    description character(18),
    benefit character(18)
);


ALTER TABLE public.productplan OWNER TO cam;

--
-- Name: productrider; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.productrider (
    lineofbusiness character(18) NOT NULL,
    ridername character(18) NOT NULL,
    seriesname character(18) NOT NULL,
    planname character(18) NOT NULL,
    description character(18),
    annualizedpremium character(18)
);


ALTER TABLE public.productrider OWNER TO cam;

--
-- Name: productseries; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.productseries (
    lineofbusiness character(18) NOT NULL,
    seriesname character(18) NOT NULL,
    description character(18)
);


ALTER TABLE public.productseries OWNER TO cam;

--
-- Name: quote; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.quote (
    quotenumber integer NOT NULL,
    custssn character(9) NOT NULL,
    quotecost integer NOT NULL,
    planname character(18) NOT NULL
);


ALTER TABLE public.quote OWNER TO cam;

--
-- Name: riskdata; Type: TABLE; Schema: public; Owner: cam
--

CREATE TABLE public.riskdata (
    datasetname character varying(18) NOT NULL,
    url character varying(100),
    lineofbusiness character(18) NOT NULL
);


ALTER TABLE public.riskdata OWNER TO cam;

--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.account (companycode, custssn, accountname, workaddress1, workaddress2, workcity, workstate, workzip) FROM stdin;
1	630292676	Mansell-BBT	55 21st St	Floor 8	Green Lake	NM	54321
2	853768165	Newing-WF	988 Brown Ave.		Dongshui	ME	33333
3	643341733	Nowell-SM	19 Spice Pl	Floor 12	Kuantan	MI	44444
1	123456789	BBT	999 Foo St.	Apt 1	Excelsior	MN	55331
5	222222222	CILE	999 foo way	apt 1000	Boston	MA	45444
\.


--
-- Data for Name: accountassociate; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.accountassociate (companycode, sitecode, custssn, associatessn, startdate) FROM stdin;
\.


--
-- Data for Name: associate; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.associate (associatessn, associatedob, associatesuffix, associatemiddleinitial, associatelastname, associatefirstname, hiredate) FROM stdin;
999887777         	1990-12-31	Jr	K	Dick	Phillip	2018-04-15
666554444         	1994-05-05		E	Zoe	Kravitz	2020-08-20
333221111         	1998-05-05		X	Joe	Green	2021-09-21
\.


--
-- Data for Name: billingaccount; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.billingaccount (companycode, custssn, bacctid, bacctname, billingaddress1, billingaddress2, billingcity, billingstate, billingzip, taxidnumber, onlinebillingflag) FROM stdin;
\.


--
-- Data for Name: claim; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.claim (claimnumber, claimdate, settlementdate, claimamount) FROM stdin;
1                 	2022-04-14	2022-07-10	10000
2                 	2022-05-12	2022-08-01	25000
\.


--
-- Data for Name: claimant; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.claimant (claimnumber, lineofbusiness, seriesname, planname, contractnumber, custssn) FROM stdin;
1                 	Health            	Basic             	HealthEssential   	1	630292676
2                 	Health            	Premium           	HealthElite       	2	853768165
\.


--
-- Data for Name: companycode; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.companycode (companycode, companyname) FROM stdin;
1	BigBox Toys       
2	Wholesome Foods   
3	Superfast Motors  
4	Airborne Airlines 
5	Chemicals Inc.    
6	Software Co.      
\.


--
-- Data for Name: contract; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.contract (lineofbusiness, seriesname, planname, contractnumber, activitystatus, billingmethod, companycode, custssn) FROM stdin;
Health            	Basic             	HealthEssential   	1	Active            	Online            	1	630292676
Health            	Premium           	HealthElite       	2	Active            	Mail              	2	853768165
Health            	Premium           	HealthElite       	3	Active            	Online            	1	123456789
Life              	Premium           	LifeElite         	4	Active            	Online            	5	222222222
\.


--
-- Data for Name: contractbenefit; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.contractbenefit (lineofbusiness, seriesname, planname, contractnumber, ridername, benefitname, benefitstartdate) FROM stdin;
\.


--
-- Data for Name: contractpremium; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.contractpremium (lineofbusiness, seriesname, planname, contractnumber, ridername, benefitname, premiumid, annualpremiumcost) FROM stdin;
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.customer (custssn, custdob, custmiddleinitial, custfirstname, custlastname, custemailaddress, gender) FROM stdin;
630292676	1965-06-03	F	Etan	Mansell	emansell9@ovh.net	M
793998457	1983-02-10	F	Julieta	Suckling	jsuckling2@wikia.com	F
853768165	1990-12-18	M	Marice	Newing	mnewing3@ca.gov	F
643341733	1981-04-02	M	Nowell	Gannaway	ngannaway4@cdc.gov	M
336120162	1989-05-24	F	Lion	Biggs	lbiggs5@prlog.org	M
634459990	1998-09-13	M	Fonsie	Lorie	florie7@alibaba.com	M
680461513	1977-08-01	F	Claudianus	Suttill	csuttill8@ca.gov	M
155861209	1972-08-01	F	Reuben	Bunch	rbunch9@furl.net	M
999887777	1991-12-31	S	Cameron	S	foo@bar.com	M
123456789	1970-01-01	D	Foo	D	foo@bar.com	M
222222222	2003-10-04	B	Bobby	B	balogna@bobby.com	F
111111111	1960-01-01	A	Bob	Brown	bob@brown.com	M
\.


--
-- Data for Name: customeraddress; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.customeraddress (custssn, addressnickname, custzip, custstate, custcity, custaddress2, custaddress1) FROM stdin;
630292676	Home	11111	NY	Palampal	7	37392 Melvin Point
853768165	Apt	33333	ME	Dongshui	1	4725 Lunder Way
643341733	Home	44444	MI	Kuantan	79	508 Vahlen Way
336120162	Home	55555	OK	Krajan	46	89675 Vidon Junction
634459990	Home	66666	NY	El Cardo	2885	50678 Dahle Road
680461513	Apt	77777	ME	Jongīyeh	9	2 Towne Avenue
155861209	Home	88888	IL	Bancar	5688	582 Novick Center
793998457	Home	22222	MN	Zhenghu	5	735 Blue Street
\.


--
-- Data for Name: customerrelation; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.customerrelation (relationssn, custssn, relationfirstname, relationlastname, relationmiddleinitial, relationsuffix, relationdob, relationtocustomer) FROM stdin;
131504028	630292676	Marena	Hempshall	F	II	2003-12-19	Child
345197787	853768165	Junie	Calderhead	R	Sr	1961-04-04	Spouse
638198406	643341733	Kakalina	Stoddard	H	III	1994-07-29	Spouse
286393000	336120162	Deedee	Heistermann	\N	Jr	1967-04-06	Spouse
700916831	634459990	Sherlocke	Dodle	E	Sr	2009-12-07	Child
797241650	680461513	Orrin	Baversor	D	Jr	1970-01-12	Spouse
764192502	155861209	Jaquelyn	Adamovicz	C	Jr	2009-03-01	Child
743435926	793998457	Janella	Shard	X	III	2000-05-22	Child
\.


--
-- Data for Name: experiment; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.experiment (lineofbusiness, experiment_name, url) FROM stdin;
MonkeyPox         	Viability Test	https://foo.bar.com
\.


--
-- Data for Name: invoice; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.invoice (companycode, custssn, bacctid, lineofbusiness, seriesname, planname, contractnumber, invoiceid) FROM stdin;
\.


--
-- Data for Name: managercontract; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.managercontract (sitecode, companycode, issuedate, contracttype, contractsigndate, contractprocessdate) FROM stdin;
1	1	0                 	Corporate         	1986-12-14	1986-12-28
2	2	0                 	Corporate         	1986-12-14	1986-12-28
3	3	0                 	Corporate         	1986-12-14	1986-12-28
4	4	0                 	Corporate         	1986-12-14	1986-12-28
5	5	0                 	Corporate         	1986-12-14	1986-12-28
6	6	0                 	Corporate         	1986-12-14	1986-12-28
\.


--
-- Data for Name: premium_mgmtcontract; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.premium_mgmtcontract (sitecode, lineofbusiness, seriesname, planname, contractnumber, ridername, companycode, benefitname, premiumid, amount, commissionrate) FROM stdin;
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.product (lineofbusiness, description) FROM stdin;
Life              	Life Insurance    
Health            	Health Insurance  
MonkeyPox         	MonkeyPox Ins.    
\.


--
-- Data for Name: productplan; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.productplan (lineofbusiness, seriesname, planname, plancode, description, benefit) FROM stdin;
Health            	Basic             	HealthEssential   	2                 	Essential Coverage	Basic             
Life              	Basic             	LifeEssential     	1                 	Essential Coverage	Basic             
Life              	Premium           	LifeElite         	4                 	Premium Coverage  	Premium           
Health            	Premium           	HealthElite       	3                 	Premium Coverage  	Premium           
\.


--
-- Data for Name: productrider; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.productrider (lineofbusiness, ridername, seriesname, planname, description, annualizedpremium) FROM stdin;
Health            	HE Rider          	Basic             	HealthEssential   	Rider for HE      	1000              
Life              	LE Rider          	Basic             	LifeEssential     	Rider for LE      	120               
Health            	HElite Rider      	Premium           	HealthElite       	Rider for HElite  	3000              
Life              	LElite Rider      	Premium           	LifeElite         	Rider for LElite  	360               
\.


--
-- Data for Name: productseries; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.productseries (lineofbusiness, seriesname, description) FROM stdin;
Health            	Basic             	Basic Health Ins  
Health            	Premium           	Premium Health Ins
Life              	Basic             	Basic Life Ins    
Life              	Premium           	Premium Life Ins  
\.


--
-- Data for Name: quote; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.quote (quotenumber, custssn, quotecost, planname) FROM stdin;
1	123456789	3000	HealthElite       
2	222222222	360	LifeElite         
3	111111111	1500	HealthEssential   
4	111111111	4500	HealthElite       
\.


--
-- Data for Name: riskdata; Type: TABLE DATA; Schema: public; Owner: cam
--

COPY public.riskdata (datasetname, url, lineofbusiness) FROM stdin;
Cancer Data	https://bar.baz.com	Life              
Heart Disease Data	https://bar.baz.com	Health            
\.


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (companycode, custssn);


--
-- Name: accountassociate accountassociate_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.accountassociate
    ADD CONSTRAINT accountassociate_pkey PRIMARY KEY (companycode, sitecode, custssn, associatessn);


--
-- Name: associate associate_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.associate
    ADD CONSTRAINT associate_pkey PRIMARY KEY (associatessn);


--
-- Name: billingaccount billingaccount_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.billingaccount
    ADD CONSTRAINT billingaccount_pkey PRIMARY KEY (companycode, custssn, bacctid);


--
-- Name: claim claim_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.claim
    ADD CONSTRAINT claim_pkey PRIMARY KEY (claimnumber);


--
-- Name: claimant claimant_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.claimant
    ADD CONSTRAINT claimant_pkey PRIMARY KEY (claimnumber, lineofbusiness, seriesname, planname, contractnumber);


--
-- Name: companycode companycode_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.companycode
    ADD CONSTRAINT companycode_pkey PRIMARY KEY (companycode);


--
-- Name: contract contract_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.contract
    ADD CONSTRAINT contract_pkey PRIMARY KEY (lineofbusiness, seriesname, planname, contractnumber);


--
-- Name: contractbenefit contractbenefit_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.contractbenefit
    ADD CONSTRAINT contractbenefit_pkey PRIMARY KEY (lineofbusiness, seriesname, planname, contractnumber, ridername, benefitname);


--
-- Name: contractpremium contractpremium_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.contractpremium
    ADD CONSTRAINT contractpremium_pkey PRIMARY KEY (lineofbusiness, seriesname, planname, contractnumber, ridername, benefitname, premiumid);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (custssn);


--
-- Name: customeraddress customeraddress_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.customeraddress
    ADD CONSTRAINT customeraddress_pkey PRIMARY KEY (custssn, addressnickname);


--
-- Name: customerrelation customerrelation_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.customerrelation
    ADD CONSTRAINT customerrelation_pkey PRIMARY KEY (relationssn, custssn);


--
-- Name: experiment experiement_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT experiement_pkey PRIMARY KEY (lineofbusiness, experiment_name);


--
-- Name: invoice invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_pkey PRIMARY KEY (companycode, custssn, bacctid, invoiceid);


--
-- Name: managercontract managercontract_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.managercontract
    ADD CONSTRAINT managercontract_pkey PRIMARY KEY (sitecode, companycode);


--
-- Name: premium_mgmtcontract premium_mgmtcontract_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.premium_mgmtcontract
    ADD CONSTRAINT premium_mgmtcontract_pkey PRIMARY KEY (sitecode, lineofbusiness, seriesname, planname, contractnumber, ridername, companycode, benefitname, premiumid);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (lineofbusiness);


--
-- Name: productplan productplan_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.productplan
    ADD CONSTRAINT productplan_pkey PRIMARY KEY (lineofbusiness, seriesname, planname);


--
-- Name: productrider productrider_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.productrider
    ADD CONSTRAINT productrider_pkey PRIMARY KEY (lineofbusiness, ridername, seriesname, planname);


--
-- Name: productseries productseries_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.productseries
    ADD CONSTRAINT productseries_pkey PRIMARY KEY (lineofbusiness, seriesname);


--
-- Name: quote quote_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.quote
    ADD CONSTRAINT quote_pkey PRIMARY KEY (quotenumber, custssn, planname);


--
-- Name: riskdata riskdata_pkey; Type: CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.riskdata
    ADD CONSTRAINT riskdata_pkey PRIMARY KEY (datasetname, lineofbusiness);


--
-- Name: associate_ssn; Type: INDEX; Schema: public; Owner: cam
--

CREATE INDEX associate_ssn ON public.associate USING btree (associatessn);


--
-- Name: company_code; Type: INDEX; Schema: public; Owner: cam
--

CREATE INDEX company_code ON public.companycode USING btree (companycode);


--
-- Name: cust_ssns; Type: INDEX; Schema: public; Owner: cam
--

CREATE INDEX cust_ssns ON public.customer USING btree (custssn);


--
-- Name: plan_cost; Type: INDEX; Schema: public; Owner: cam
--

CREATE INDEX plan_cost ON public.productrider USING btree (planname, annualizedpremium);


--
-- Name: productplan r_10; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.productplan
    ADD CONSTRAINT r_10 FOREIGN KEY (lineofbusiness, seriesname) REFERENCES public.productseries(lineofbusiness, seriesname);


--
-- Name: productrider r_11; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.productrider
    ADD CONSTRAINT r_11 FOREIGN KEY (lineofbusiness, seriesname, planname) REFERENCES public.productplan(lineofbusiness, seriesname, planname);


--
-- Name: contract r_12; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.contract
    ADD CONSTRAINT r_12 FOREIGN KEY (lineofbusiness, seriesname, planname) REFERENCES public.productplan(lineofbusiness, seriesname, planname);


--
-- Name: contractbenefit r_13; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.contractbenefit
    ADD CONSTRAINT r_13 FOREIGN KEY (lineofbusiness, seriesname, planname, contractnumber) REFERENCES public.contract(lineofbusiness, seriesname, planname, contractnumber);


--
-- Name: contractbenefit r_14; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.contractbenefit
    ADD CONSTRAINT r_14 FOREIGN KEY (lineofbusiness, ridername, seriesname, planname) REFERENCES public.productrider(lineofbusiness, ridername, seriesname, planname);


--
-- Name: contractpremium r_15; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.contractpremium
    ADD CONSTRAINT r_15 FOREIGN KEY (lineofbusiness, seriesname, planname, contractnumber, ridername, benefitname) REFERENCES public.contractbenefit(lineofbusiness, seriesname, planname, contractnumber, ridername, benefitname);


--
-- Name: contract r_24; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.contract
    ADD CONSTRAINT r_24 FOREIGN KEY (companycode, custssn) REFERENCES public.account(companycode, custssn);


--
-- Name: riskdata r_26; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.riskdata
    ADD CONSTRAINT r_26 FOREIGN KEY (lineofbusiness) REFERENCES public.product(lineofbusiness);


--
-- Name: experiment r_27; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT r_27 FOREIGN KEY (lineofbusiness) REFERENCES public.product(lineofbusiness);


--
-- Name: account r_30; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT r_30 FOREIGN KEY (companycode) REFERENCES public.companycode(companycode);


--
-- Name: claimant r_31; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.claimant
    ADD CONSTRAINT r_31 FOREIGN KEY (claimnumber) REFERENCES public.claim(claimnumber);


--
-- Name: claimant r_32; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.claimant
    ADD CONSTRAINT r_32 FOREIGN KEY (lineofbusiness, seriesname, planname, contractnumber) REFERENCES public.contract(lineofbusiness, seriesname, planname, contractnumber);


--
-- Name: claimant r_33; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.claimant
    ADD CONSTRAINT r_33 FOREIGN KEY (custssn) REFERENCES public.customer(custssn);


--
-- Name: invoice r_38; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT r_38 FOREIGN KEY (companycode, custssn, bacctid) REFERENCES public.billingaccount(companycode, custssn, bacctid);


--
-- Name: invoice r_39; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT r_39 FOREIGN KEY (lineofbusiness, seriesname, planname, contractnumber) REFERENCES public.contract(lineofbusiness, seriesname, planname, contractnumber);


--
-- Name: customerrelation r_4; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.customerrelation
    ADD CONSTRAINT r_4 FOREIGN KEY (custssn) REFERENCES public.customer(custssn);


--
-- Name: invoice r_40; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT r_40 FOREIGN KEY (custssn) REFERENCES public.customer(custssn);


--
-- Name: accountassociate r_41; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.accountassociate
    ADD CONSTRAINT r_41 FOREIGN KEY (companycode, custssn) REFERENCES public.account(companycode, custssn);


--
-- Name: accountassociate r_44; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.accountassociate
    ADD CONSTRAINT r_44 FOREIGN KEY (sitecode, companycode) REFERENCES public.managercontract(sitecode, companycode);


--
-- Name: premium_mgmtcontract r_46; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.premium_mgmtcontract
    ADD CONSTRAINT r_46 FOREIGN KEY (sitecode, companycode) REFERENCES public.managercontract(sitecode, companycode);


--
-- Name: premium_mgmtcontract r_47; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.premium_mgmtcontract
    ADD CONSTRAINT r_47 FOREIGN KEY (lineofbusiness, seriesname, planname, contractnumber, ridername, benefitname, premiumid) REFERENCES public.contractpremium(lineofbusiness, seriesname, planname, contractnumber, ridername, benefitname, premiumid);


--
-- Name: accountassociate r_48; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.accountassociate
    ADD CONSTRAINT r_48 FOREIGN KEY (associatessn) REFERENCES public.associate(associatessn);


--
-- Name: account r_49; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT r_49 FOREIGN KEY (custssn) REFERENCES public.customer(custssn);


--
-- Name: customeraddress r_5; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.customeraddress
    ADD CONSTRAINT r_5 FOREIGN KEY (custssn) REFERENCES public.customer(custssn);


--
-- Name: managercontract r_50; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.managercontract
    ADD CONSTRAINT r_50 FOREIGN KEY (companycode) REFERENCES public.companycode(companycode);


--
-- Name: billingaccount r_51; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.billingaccount
    ADD CONSTRAINT r_51 FOREIGN KEY (companycode, custssn) REFERENCES public.account(companycode, custssn);


--
-- Name: quote r_52; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.quote
    ADD CONSTRAINT r_52 FOREIGN KEY (custssn) REFERENCES public.customer(custssn);


--
-- Name: productseries r_9; Type: FK CONSTRAINT; Schema: public; Owner: cam
--

ALTER TABLE ONLY public.productseries
    ADD CONSTRAINT r_9 FOREIGN KEY (lineofbusiness) REFERENCES public.product(lineofbusiness);


--
-- PostgreSQL database dump complete
--

