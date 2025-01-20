## Sprint 3, Gestió de taules ##
## NIVELL 1 ##
# Exercici 1
-- La teva tasca és dissenyar i crear una taula anomenada “credit_card” que emmagatzemi detalls crucials sobre les targetes de crèdit. 
-- La nova taula ha de ser capaç d’identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules (“transaction” i “company”). 
-- Després de crear la taula serà necessari que ingressis la informació del document denominat “dades_introduir_credit”. 
-- Recorda mostrar el diagrama i realitzar una breu descripció d’aquest.
use transactions; 
show create table company;


CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );
CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
   create table if not exists credit_card (
	id VARCHAR(15),
    iban VARCHAR(255),
	pan VARCHAR(255),
    pin int,
    cvv int,
    expiring_date varchar(15),
    primary key (id)
    );
	
    alter table transaction
    add constraint fk_credit_card_id foreign key (credit_card_id) references credit_card(id);
    -- creamos la relación entre las tablas.
    -- el tipo en el pin debería ser varchar también ya que, aunque no es el caso, si tenemos registros que empiecen con el 0 no nos lo va a contar.
    -- lo ideal sería poner después del id varchar not null, ya que es la pk.
    
    
    
    ## Exercici 2. El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. 
    -- La informació que ha de mostrar-se per a aquest regisre és: R323456312213576817699999. 
    -- Recorda mostrar que el canvi es va realitzar.
    
UPDATE credit_card 
SET 
    iban = 'R323456312213576817699999'
where id='CcU-2938';

select iban
from credit_card 
where id = ('CcU-2938');

## EXERCICI 3.
-- En la taula "transaction" ingressa un nou usuari amb la geüent informació:
show create table transaction;
INSERT INTO company (id) values ('b-9999');
insert into credit_card (id) values ('CcU-9999'); -- añadimos el id primero en la tabla company para que tenga info, luego en la credit_card

-- comprobamos que existe: 
Select * from credit_card where id = 'CcU-9999';
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES (  '1108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');
select * from transaction where user_id = 9999;

## EXERCICI 4. 
# Des de RRHH et sol·liciten eliminar la columna "pan" de la taula credit_card. Mostra el resultat.

alter table credit_Card drop column pan;
select * from credit_Card;
show create table credit_Card;

### Nivell 2 ###
## Exercici 1.
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.
delete from transaction where id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';
select *
from transaction where id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

##Exercici 2
-- La secció de màrqueting desitja tenir accès a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
# Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
-- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra. 

select company_name as Nom_Companyia, phone as Telèfon_Contacte, country as País_Residència, avg(amount) as Media_Compras
from company
left join transaction on company.id = transaction.company_id
where declined=0
group by company.id
order by Media_Compras;
-- hemos usado un left join para incluir los datos del ejercicio 3 del nivel anterior.
create view VistaMarketing as
select company_name as Nom_Companyia, phone as Telèfon_Contacte, country as País_Residència, avg(amount) as Media_Compras
from company
left join transaction on company.id = transaction.company_id
where declined=0
group by company.id
order by Media_Compras;
select * from VistaMarketing;

## Exercici 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
show create view VistaMarketing;
create or replace view VistaMarketing as
select company_name as Nom_Companyia, phone as Telèfon_Contacte, country as País_Residència, avg(amount) as Media_Compras
from company
left join transaction on company.id = transaction.company_id
where declined=0 and country = 'Germany'
group by company.id
order by Media_Compras;
select * from VistaMarketing;

### Nivell 3
## Exercici 1.
-- La setmana que ve tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip
-- va realitzar modificacions en la base de dades, però no recorda com les va realitzar.
-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama: ###

alter table company drop column website;
select * from company;
-- Creamos la tabla user con la info del archivo adjunto

CREATE INDEX idx_user_id ON transaction(user_id);
 
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)
    );
SET foreign_key_checks = 0;
SET foreign_key_checks = 1;
-- le dimos a introducir los datos del archivo adjunto.

alter table transaction add constraint fk_user_id foreign key (user_id) references user(id);

# comprobamos que está todo ok:
SELECT * FROM transactions.user;

#vemos que la tabla credit_card tiene una columna nueva "fecha actual"
alter table credit_card add fecha_actual DATE;

#aunque no sea demasiado relevante, cambiamos el numero de varchar que teníamos para que coincida con el resultado que nos pide:
alter table credit_card
modify id VARCHAR(20),
modify iban VARCHAR(50),
modify pin VARCHAR(4),
modify expiring_date VARCHAR(20);

# comprobamos
select * from credit_Card;


select user_id from transaction
where user_id is not null and user_id not in(select id from user);
-- clar apareix l'user 9999 
delete from transaction 
where user_id is not null and user_id not in (select id from user);
delete from transaction where user_id ='9999';

select * from transaction
where user_id = '9999';

alter table transaction add constraint FOREIGN KEY (user_id) REFERENCES user(id);

# cambiamos el nombre de user a data_user:
rename table user to data_user;


## Exercici 2
# L'empresa també et solicita crear una vista anomenada "InformeTecnico" qye contingui la següent informació: ###
create view InformeTecnico as
select transaction.id as ID, user.name as Nom, user.surname as Cognom, credit_card.iban as IBAN, company.company_name as Nom_Companyia
from transaction
left join company on transaction.company_id= company.id
left join user on transaction.user_id=user.id
left join credit_card on credit_card_id =credit_Card.id
order by ID;















