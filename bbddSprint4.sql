### SPRINT 4 Goda Sruogyte
# Nivell 1
###Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb 
-- un esquema d'estrella que contingui, 
-- almenys 4 taules de les quals puguis realitzar les següents consultes:

create database sprint4;
use sprint4;
create table if not exists companies (
	company_id varchar(15) not null primary key,
    company_name varchar(255),
    phone varchar(15),
    email varchar(100),
    country varchar(100),
    website varchar(150)
);

SHOW GLOBAL VARIABLES LIKE 'local_infile'; -- off
SET GLOBAL local_infile=1;
load data local infile 'C:/Users/godas/Documents/Barcelona Activa/arxius/companies.csv'
into table companies
fields terminated by ','
enclosed by'"'
lines terminated by '\r\n'
ignore 1 rows;

SHOW VARIABLES LIKE "secure_file_priv";

create table if not exists credit_cards (
	id varchar(20) not null primary key,
    user_id varchar(4),
    iban varchar(50),
    pan varchar(50),
    pin varchar(10),
    cvv varchar(10),
    track1 varchar(255),
    track2 varchar(255),
    expiring_date varchar(20)
);
 load data local infile 'C:/Users/godas/Documents/Barcelona Activa/arxius/credit_cards.csv'
 into table credit_cards
 fields terminated by ','
 enclosed by '"'
 lines terminated by '\n'
 ignore 1 rows;
 
 create table if not exists products (
	id varchar(10) not null primary key,
    product_name varchar(100),
    price varchar(100),
    colour varchar(50), 
    weight float,
    warehouse_id varchar(10)
   );
   
   load data local infile 'C:/Users/godas/Documents/Barcelona Activa/arxius/products.csv'
   into table products
   fields terminated by ','
   enclosed by '"'
   lines terminated by '\n'
   ignore 1 rows;


create table if not exists users (
	id varchar(10) not null primary key,
    name varchar(20),
    surname varchar(50),
    phone varchar(15),
    email varchar(100),
    birth_date varchar(20),
    country varchar(100),
    city varchar (50),
    postal_code varchar(20),
    address varchar(100)
);

load data local infile 'C:/Users/godas/Documents/Barcelona Activa/arxius/users_usa.csv'
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;


load data local infile 'C:/Users/godas/Documents/Barcelona Activa/arxius/users_uk.csv'
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;



load data local infile 'C:/Users/godas/Documents/Barcelona Activa/arxius/users_ca.csv'
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;



create table if not exists transactions (
	id varchar(50) primary key,
    card_id varchar(20) references credit_cards(id),
    business_id varchar(15) references companies(company_id),
    timestamp timestamp,
    amount decimal (10,2),
    declined boolean,
    product_ids varchar(30),
    user_id varchar(10) references users(id),
    lat varchar(50),
    longitude varchar(50),
    
    foreign key (card_id) references credit_cards(id),
    foreign key (business_id) references companies(company_id),
    foreign key (user_id) references users(id)
);

load data local infile 'C:/Users/godas/Documents/Barcelona Activa/arxius/transactions.csv'
into table transactions
fields terminated by ';'
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

drop table transactions;
drop table users;
-- esto lo he usado porque me daba problema y volví a cargar los datos.



###Exercici 1
#Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
select id
from users
where id in (select user_id from transactions 
group by user_id
having count(*) > 30);
-- 4 rows: 267, 272, 275, 92
select id, name, surname, country
from users
where id in (select user_id from transactions 
group by user_id
having count(*) > 30);

##Exercici 2. 
#Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
select c.iban, c.user_id, cc.company_name, avg(amount) as Media
from transactions t
join credit_cards c on t.card_id=c.id
join companies cc on t.business_id=cc.company_id
where company_name = 'Donec Ltd'
group by c.iban, c.user_id, cc.company_name
order by Media;

### Nivell 2
#Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últmes tres transaccions van ser declinades i genera la següent consulta:
##Exercici 1
#Quantes targetes estan actives?
create table Actives_Cards as
select card_id, declined from
(select id, card_id, timestamp, declined,
	row_number() over(partition by card_id order by timestamp desc)	as ultims_popularity
from transactions) as pop 
where ultims_popularity <=3
and not exists (select 1 from (
	select card_id, declined,
	row_number() over(partition by card_id order by timestamp desc)	as ultims_popularity
from transactions) as pop2 
where pop2.card_id = pop.card_id and ultims_popularity <=3 
and pop2.declined=0);

/*select user_id, count(credit_cards.id) as ids
from credit_cards
where id in (select card_id from transactions 
where declined =1
group by card_id
having count(card_id) > 3)
group by user_id;*/

select *
from credit_cards
where id not in ( select credit_card_id from declinadas2 ); -- 188rows nada q ver con lo q me pide el enunciado

/*select columnes transaction, row number() over(partition by from transaction);
select id, card_id, timestamp
from transactions
order by timestamp desc;
-- columna de rownumber:*/

-- provem:
select id, card_id, timestamp,
	row_number() over(order by card_id desc)	as ultims_popularity
from transactions;
-- provem el rank, vist en video:
select id, card_id, timestamp,
	row_number() over(order by card_id desc)	as ultims_popularity,
    rank() over(order by card_id desc)	as ultims_popularity_r,
    dense_rank() over(order by card_id desc)	as ultims_popularity_dr
from transactions;

-- top 3
select card_id, declined from
(select id, card_id, timestamp, declined,
	row_number() over(partition by card_id order by timestamp desc)	as ultims_popularity
from transactions) as pop 
where ultims_popularity <=3;


## Nivell 3
# Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
-- tenint en compte que des de transaction tens products_ids. Genera la següent consulta:

# Exercici 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

/*create table transactions_productos select * from transactions t
where CONCAT(',', product_ids, ',') like '%,1,%' ; 22 rows on els ids comencen amb 1*/
drop table transactions_productos;



    