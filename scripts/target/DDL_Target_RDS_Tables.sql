############################### (LKP)  phone_number_type  ##############################################

DROP TABLE IF EXISTS phone_number_type;
 
create table phone_number_type (
  phone_number_type_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  type VARCHAR(128) NOT NULL,
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(128) NOT NULL DEFAULT "aspendbuser",
  updated timestamp,
  updated_by VARCHAR(128)
);

ALTER TABLE phone_number_type AUTO_INCREMENT = 51;

insert into phone_number_type (type)
values 
('phone_home'),
('phone_cell');

select  * from phone_number_type;

############################### (LKP) email_type  ##############################################

DROP TABLE IF EXISTS email_type;

create table email_type (
  email_type_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  type VARCHAR(128) NOT NULL,
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(128) NOT NULL DEFAULT "aspendbuser",
  updated timestamp,
  updated_by VARCHAR(128)
);

ALTER TABLE email_type AUTO_INCREMENT = 71;

insert into email_type (type)
values 
('email_work'),
('email_personal');

select  * from email_type;


############################### (LKP) role_profile_type  ##############################################

DROP TABLE IF EXISTS role_profile_type;

create table role_profile_type (
  role_profile_type_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  type VARCHAR(128) NOT NULL,
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(128) NOT NULL DEFAULT "aspendbuser",
  updated timestamp,
  updated_by VARCHAR(128)
);

ALTER TABLE role_profile_type AUTO_INCREMENT = 91;

insert into role_profile_type (type)
values 
('borrower'),
('co-borrower');

select  * from role_profile_type;

###############################  user_profile  ##############################################

DROP TABLE IF EXISTS user_profile;

create table user_profile (
#  user_profile_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  user_profile_id VARCHAR(128) PRIMARY KEY NOT NULL,   ## same as borrower_id in source, it will not be an AUTO_INCREMENT field and will be varchar(129) and NOT INT
  first_name VARCHAR(128) NOT NULL,
  last_name VARCHAR(128) NOT NULL,
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(128) NOT NULL DEFAULT "aspendbuser",
  updated timestamp,
  updated_by VARCHAR(128)
);

insert into user_profile (user_profile_id, first_name, last_name)
SELECT id, SUBSTR(FULL_NAME,1,(LOCATE(' ',FULL_NAME)))  AS FIRST_NAME, SUBSTR(FULL_NAME,(LOCATE(' ',FULL_NAME)))  AS LAST_NAME from borrower;

select  * from user_profile; 

#SELECT full_name, SUBSTR(FULL_NAME,1,(LOCATE(' ',FULL_NAME)))  AS FIRSTTNAME, SUBSTR(FULL_NAME,(LOCATE(' ',FULL_NAME)))  AS LASTNAME from borrower
#where full_name IN ('Ailis Degli Antoni','Celestyna De la Eglise');

#LAST_NAME consists of mis=ddle name and last name


##################################  user  ##################################################

DROP TABLE IF EXISTS user;

create table user (
  user_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  user_profile_id VARCHAR(128) NOT NULL,  #varchar(128) not int  #FK will this be NULLABLE? IS FK always nullable?
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(128) NOT NULL DEFAULT "aspendbuser",
  updated timestamp,
  updated_by VARCHAR(128),
  FOREIGN KEY (user_profile_id) REFERENCES user_profile(user_profile_id)
);

ALTER TABLE user AUTO_INCREMENT = 1;

insert into user (user_profile_id)
SELECT user_profile_id from user_profile;

select  * from user; 


##################################  role_profile  ##################################################

DROP TABLE IF EXISTS role_profile;

create table role_profile (
  role_profile_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  user_id int,
  role_profile_type_id int,
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(128) NOT NULL DEFAULT "aspendbuser",
  updated timestamp,
  updated_by VARCHAR(128),
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  FOREIGN KEY (role_profile_type_id) REFERENCES role_profile_type(role_profile_type_id)
);

ALTER TABLE role_profile AUTO_INCREMENT = 5001;

insert into role_profile (user_id,role_profile_type_id)
select u.user_id, rpt.role_profile_type_id 
from role_profiles rp
join user u on rp.borrower_id=u.user_profile_id
join role_profile_type rpt on rp.role_profile=rpt.type;

select  * from role_profile; 


#user and role_profile should have 1:1 relation


##################################  phone_number  ##################################################


DROP TABLE IF EXISTS phone_number;

create table phone_number (
  phone_number_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  role_profile_id int,
  phone_number_type_id int,
  value VARCHAR(20) NOT NULL,
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(128) NOT NULL DEFAULT "aspendbuser",
  updated timestamp,
  updated_by VARCHAR(128),
  FOREIGN KEY (role_profile_id) REFERENCES role_profile(role_profile_id),
  FOREIGN KEY (phone_number_type_id) REFERENCES phone_number_type(phone_number_type_id)
);


insert into phone_number (role_profile_id,phone_number_type_id,value)
select rp.role_profile_id, pnt.phone_number_type_id, sub_phone.value from
(
select id, phone_home as value, 'phone_home' as type from borrower where phone_home != '' 
union
select id, phone_cell as value, 'phone_cell' as type from borrower where phone_cell != ''
) sub_phone
join user u on sub_phone.id = u.user_profile_id
join role_profile rp on u.user_id=rp.user_id 
join phone_number_type pnt on sub_phone.type=pnt.type 
order by role_profile_id;

select  * from phone_number; 


##################################  address  ##################################################

DROP TABLE IF EXISTS address;

create table address (
  address_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  role_profile_id int,
  street VARCHAR(128),
  city VARCHAR(128) NOT NULL,
  state VARCHAR(128) NOT NULL,
  zip_code VARCHAR(128) NOT NULL,
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(128) NOT NULL DEFAULT "aspendbuser",
  updated timestamp,
  updated_by VARCHAR(128),
  FOREIGN KEY (role_profile_id) REFERENCES role_profile(role_profile_id)
);

insert into address (role_profile_id,street,city,state,zip_code)
select role_profile_id,street,city,state,zip_code 
from borrower b
join user u on b.id = u.user_profile_id
join role_profile rp on u.user_id=rp.user_id;

select  * from address; 


##################################  email  ##################################################

DROP TABLE IF EXISTS email;

create table email (
  email_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  role_profile_id int,
  email_type_id int,
  value VARCHAR(128) NOT NULL,  #changed value to varchar 128 since email can be long
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(128) NOT NULL DEFAULT "aspendbuser",
  updated timestamp,
  updated_by VARCHAR(128),
  FOREIGN KEY (role_profile_id) REFERENCES role_profile(role_profile_id),
  FOREIGN KEY (email_type_id) REFERENCES email_type(email_type_id)
);

insert into email (role_profile_id, email_type_id, value)
select role_profile_id, email_type_id, value from
(
select id, email as value, 
case 
	when right(email,3)='com' then 'email_personal' 
	when email != '' then 'email_work'
	else '' end as type
from borrower) b
join user u on b.id = u.user_profile_id
join role_profile rp on u.user_id=rp.user_id
join email_type et on et.type = b.type;

select  * from email; 

#Note: 683 records are loaded in email table since 683 borrowers have emails. 

##################################  END  ##################################################
