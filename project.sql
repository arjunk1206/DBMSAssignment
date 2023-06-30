create table users (
     aid number primary key,
     uname varchar(20),
     age number,
     door# varchar(10),
     street varchar(10),
     city varchar(10),
     state varchar(10),
     pincode number 
);


create table user_cred (
    aid number primary key,
    userid number,
    password varchar(20)
);

create table usercred (
    userid varchar(10) primary key,
    password varchar(20)
);


create table phone_no (
    aid number primary key,
    phone number
);

create table tenant (
    aid number primary key,
    num_prop_rented number
);

create table owner (
    aid number primary key,
    num_prop_listed number
);

create table property (
    pid number primary key,
    owner_id number,
    av_till date,
    av_from date,
    locality varchar(20),
    numfloors number,
    address varchar(20),
    year_construction number,
    total_area number,
    plinth_area number
);


CREATE TABLE Registers(
owner_id number,
pid NUMBER NOT NULL PRIMARY KEY,
listdate DATE,
deposit NUMBER,
CONSTRAINT fk_pid FOREIGN KEY (pid) REFERENCES property (pid))

create table RENTS ( 
	tenantID number,
	pid number,
	StartDate date,a
	EndDate date,
	AgencyComm number,
	RentPerMonth number,
	HikePercent number,
	constraint FK_Rents1 foreign key (tenantID) references tenant(aid),
	constraint FK_Rents2 foreign key (pid) references property(pid),
	constraint PK_Rents primary key (TenantID,PID) );

create table PROPERTY_HISTORY(
    pid number NOT NULL FOREIGN KEY references property(pid),
    tenantID number NOT NULL FOREIGN KEY references TENANT(aid),
    startdate date NOT NULL,
    rentpermonth number,
    agencycomm number,
    hike_perc number,
    CONSTRAINT PK_PROP_HIST PRIMARY KEY (pid,tenantID,startdate),
);



create table PROPERTY_HISTORY(
    pid number NOT NULL FOREIGN KEY references PROPERTY(pid),
    tenantID number NOT NULL FOREIGN KEY references TENANT(aid),
    startdate date NOT NULL,
    rentpermonth number,
    agencycomm number,
    hike_perc number,
    CONSTRAINT PK_PROP_HIST PRIMARY KEY (pid,tenantID,startdate),
);

alter table property add available varchar(3);



CREATE TABLE RESIDENTIAL(
        PID number  PRIMARY KEY NOT NULL ,
        ptype varchar(10) NOT NULL,
        num_bedrooms number NOT NULL,
        FOREIGN KEY (PID)
        REFERENCES property(PID)
);

create table PROPERTY_HISTORY(
    pid number NOT NULL,
    tenantID number NOT NULL,
    startdate date NOT NULL,
    rentpermonth number,
    agencycomm number,
    hike_perc number,
    CONSTRAINT PK_PROP_HIST PRIMARY KEY (pid,tenantID,startdate),
    FOREIGN KEY (pid) references PROPERTY(pid),
    FOREIGN KEY (tenantID) references users(aid)
);

create table COMMERCIAL(
    pid number,
    ptype varchar(10),
    FOREIGN KEY (pid) references PROPERTY(pid)
);

Select * from users;
Select * from user_cred;
Select * from phone_no;
Select * from tenant;
Select * from owner;
Select * from property;
Select * from registers;
Select * from rents;
Select * from PROPERTY_HISTORY;
Select * from COMMERCIAL;
Select * from RESIDENTIAL;
Select * from rents;
Select * from rents;

drop TABLE users;
drop TABLE user_cred;
drop TABLE phone_no;
drop TABLE tenant;
drop TABLE owner;
drop TABLE property;
drop TABLE registers;
drop TABLE rents;
drop TABLE PROPERTY_HISTORY;
drop TABLE COMMERCIAL;
drop TABLE RESIDENTIAL;

create user C###dada identified by dada default tablespace users temporary tablespace temp;


C###dbadmin
also name of schema

INSERT INTO users (aid, uname, age, door#, street, city, state, pincode) VALUES
(1, 'Amit Kumar', 32, 'B-101', 'MG Road', 'Bangalore', 'Karnataka', 560001),
(2, 'Sneha Sharma', 28, 'C-102', 'Saket', 'New Delhi', 'Delhi', 110017),
(3, 'Rajesh Patel', 35, 'A-201', 'LBS Marg', 'Mumbai', 'Maharashtra', 400086),
(4, 'Manoj Singh', 41, 'D-401', 'Kondhwa', 'Pune', 'Maharashtra', 411048),
(5, 'Priya Sharma', 26, 'E-301', 'Sector 22', 'Noida', 'Uttar Pradesh', 201301);


GRANT SELECT ON property TO C###manager;
c###man1
C###user1

CREATE OR REPLACE TRIGGER insert_registers
AFTER INSERT ON property
BEGIN
  EXECUTE IMMEDIATE 'GRANT C###owner TO ' || USER;
  --INSERT INTO user_roles (uname, role) VALUES (USER,'owner');
END;
/

CREATE OR REPLACE TRIGGER insert_tenants
AFTER INSERT ON RENTS
BEGIN
  --EXECUTE IMMEDIATE 'GRANT C###tenant TO ' || USER;
  INSERT INTO user_roles (uname, role) VALUES (USER,'tenant');
END;
/
CREATE OR REPLACE TRIGGER insert_registers1
AFTER INSERT ON property
BEGIN
  EXECUTE IMMEDIATE 'GRANT C###owner TO ' || USER;
  INSERT INTO user_roles (uname, role) VALUES (USER,'owner');
END;
/

CREATE OR REPLACE TRIGGER insert_tenants1
AFTER INSERT ON RENTS
BEGIN
  --EXECUTE IMMEDIATE 'GRANT C###tenant TO ' || USER;
  INSERT INTO user_roles (uname, role) VALUES (USER,'tenant');
END;
/

INSERT INTO users VALUES (6, 'u1', 25, 'A-101', 'M Street', 'Mumbai', 'Maharashtra', 400001);

INSERT INTO property VALUES (6, 6, SYSDATE, SYSDATE+365, 'South Delhi', 3, 'A-101, Green Park', 2020, 2500, 2000);

GRANT DELETE ON C###dbadmin.property TO C###u1 WHERE pid = (SELECT pid FROM property WHERE owner_id = (SELECT owner_id FROM users WHERE uname = 'u1'));


CREATE OR REPLACE TRIGGER property_trigger
AFTER INSERT ON property
FOR EACH ROW
DECLARE
  ptype varchar(20);
BEGIN
  -- Get the ptype value from the inserted row
  SELECT ptype INTO ptype FROM property WHERE pid = :NEW.pid;
  
  -- Create a new table for commercial properties
  IF ptype = 'commercial' THEN
    EXECUTE IMMEDIATE 'CREATE TABLE commercial_properties (pid NUMBER PRIMARY KEY, owner_id NUMBER, av_till DATE, av_from DATE, locality VARCHAR(20), numfloors NUMBER, address VARCHAR(20), year_construction NUMBER, total_area NUMBER, plinth_area NUMBER)';
    EXECUTE IMMEDIATE 'INSERT INTO commercial_properties SELECT * FROM property WHERE pid = :NEW.pid';
  END IF;
  
  -- Create a new table for residential properties
  IF ptype = 'residential' THEN
    EXECUTE IMMEDIATE 'CREATE TABLE residential_properties (pid NUMBER PRIMARY KEY, owner_id NUMBER, av_till DATE, av_from DATE, locality VARCHAR(20), numfloors NUMBER, address VARCHAR(20), year_construction NUMBER, total_area NUMBER, plinth_area NUMBER)';
    EXECUTE IMMEDIATE 'INSERT INTO residential_properties SELECT * FROM property WHERE pid = :NEW.pid';
  END IF;
  
END;
/

CREATE OR REPLACE TRIGGER property_insert_trigger
AFTER INSERT ON property
FOR EACH ROW
BEGIN
    IF :NEW.ptype = 'commercial' THEN
        INSERT INTO commercial (pid, ptype) VALUES (:NEW.pid, :NEW.ptype);
    ELSIF :NEW.ptype = 'residential' THEN
        INSERT INTO residential (pid, ptype, num_bedrooms) VALUES (:NEW.pid, :NEW.ptype, 0);
    END IF;
END;
/


    create user C###m1 identified by m1 default tablespace users temporary tablespace temp;


    CREATE OR REPLACE PROCEDURE grant_role_to_user(
    p_username IN VARCHAR2,
    p_role IN VARCHAR2
) AS
BEGIN
    -- Grant the role to the user
    EXECUTE IMMEDIATE 'GRANT ' || p_role || ' TO ' || p_username;

    -- Insert the user and role into the user_roles table
    INSERT INTO user_roles (uname, role) VALUES (p_username, p_role);
    

END;

CREATE OR REPLACE PROCEDURE add_rent(
    uid IN NUMBER,
    pid IN NUMBER,
    start_date IN DATE,
    end_date IN DATE,
    agency_comm IN NUMBER,
    rent_per_month IN NUMBER,
    hike_percent IN NUMBER
)
AS
BEGIN
    INSERT INTO RENTS (tenantID, pid, StartDate, EndDate, AgencyComm, RentPerMonth, HikePercent)
    VALUES (uid, pid, start_date, end_date, agency_comm, rent_per_month, hike_percent);
    INSERT INTO PROPERTY_HISTORY (tenantID, pid, StartDate, EndDate, AgencyComm, RentPerMonth, hike_perc)
    VALUES (uid, pid, start_date, end_date, agency_comm, rent_per_month, hike_percent);
        
END;
/

    
    create table PROPERTY_HISTORY(
    tenantID number NOT NULL,
    pid number NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL,
    agencycomm number,
    rentpermonth number, 
    hike_perc number,
    CONSTRAINT PK_PROP_HIST PRIMARY KEY (pid,tenantID,startdate),
    FOREIGN KEY (pid) references PROPERTY(pid),
    FOREIGN KEY (tenantID) references users(aid)
);


CREATE OR REPLACE TRIGGER insert_registers
AFTER INSERT ON property
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  EXECUTE IMMEDIATE 'GRANT C###owner TO ' || USER;
  INSERT INTO user_roles (uname, role) VALUES (USER,'owner');
  COMMIT;
END;
/

CREATE OR REPLACE TRIGGER insert_tenants
AFTER INSERT ON rents
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  EXECUTE IMMEDIATE 'GRANT C###tenant TO ' || USER;
  INSERT INTO user_roles (uname, role) VALUES (USER,'tenant');
  COMMIT;
END;
/

INSERT INTO RENTS VALUES (5, 4, '01-JAN-24', '01-MAY-23', 5, 12000, 6);