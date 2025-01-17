## NIVELL 1 ## Goda Sruogyte
# Exercici 1:
#A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen. Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

    -- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );


    -- Creamos la tabla transaction
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
describe company;
SELECT * FROM transactions.company;

describe transaction;
SELECT * FROM transactions.transaction;


## EXERCICI 2 
# Utilitzant JOIN realitzaràs les següents consultes: 
-- 1. Llistat dels països que estan fent compres.
select distinct country as Paisos_fent_compres
from transactions.transaction
inner join transactions.company on transaction.company_id = company.id
where declined = 0;
-- encara que el resultat no ens canviï, apliquem el filtre declined=0 ja que entenem que una compra es considera a partir de que la transacció està acceptada.




-- 2. Des de quants països es realitzen les compres.
select count(distinct country) as Conteo_paisos
from transaction
inner join company on transaction.company_id = company.id
where declined = 0;
-- aquí apliquem també el filtre de la columna declined perquè s'entén que realitzar una compra és quan 
-- la transacció està realizada. En cas que el públic ens demani que considerem totes les transaccions (acceptades o no) doncs li llevem el filtre de declined.


-- 3. Identifica la companyia amb la mitjana més gran de vendes.
select company_name, avg(amount) media
from transaction
inner join company on transaction.company_id =company.id
where declined=0
group by company_name
order by media desc
limit 1;
-- Seleccionem la mitjana de cada empresa. En un principi tenia en ment l'empresa amb la mitjana més alta amb comparació de la mitjana general de totes les empreses. 
-- apliquem el filtre de transacció acceptada i ordenem per la mitjana de forma descendent perquè primer ens apareguin les quantitats més altes. 
-- Per últim filtrem amb el limit 1 ja que l'enunciat sols ens demana el nom d'una empresa. El codi ens retorna que el resultat és: Eget Ipsum Ltd i la 
-- seva mitjana més gran de vendes és 481.860.

-- no fer cas: ## where amount > (select avg(amount) from transaction where declined=0) where declined=0 group by amount desc limit 1;    ##
 
 select avg(amount) from transaction where declined=0; 




# Exercici 3 
-- Utilitzant només subconsultes (sense utilitzar JOIN):
-- 1. Mostra totes les transaccions realitzades per empreses d'Alemanya
-- versión correcta:
select *
from transaction
where company_id in (select id from company where country = 'Germany');


-- para comprobar que el resultado es correcto, primero verificamos cuáles son las empresas alemanas y sus id (que vamos a encontrar también en el resultado final)
SELECT id, company_name 
FROM company
WHERE country = 'Germany';
-- a continuació, verifiquem que efectivament els ids son els mateixos eliminant duplicats:
select distinct company_id
from transaction
where company_id in (select id from company where country = 'Germany');



-- 2.Llista de les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions
select company_name, amount
from transaction
join company on transaction.company_id=company.id
where amount > (select avg(amount) from transaction)
order by amount desc;
-- llevar el join i els duplicats
select distinct company_name
from transaction
join company on transaction.company_id=company.id
where amount > (select avg(amount) from transaction)
order by company_name; -- 70 rows, busquem que el resultat ens done un llistat de 70 empreses. Llevem el join


select avg(amount) from transaction; -- 256.735520
-- 2.Llista de les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions
-- resultat correcte:
select company_name
from company
where id in (select company_id from transaction
				where amount> (select avg(amount) from transaction)
                )
order by company_name;

-- ¿Què necessitem? llistat nom de 70 empreses, fem la subconsulta amb el filtre where perquè necessitem treure l'avg de
-- l'amount que es troba en la taula transactions a diferència dels noms de les empreses que es troben en la t company.


-- 3. Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

select company_name
from company
where id not in (select company_id from transaction) and id is not null;

## NIVELL 2##
# Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

select date(timestamp), sum(amount) as TotalVendes
from transaction
where declined =0
group by date(timestamp)
order by TotalVendes desc
limit 5;

select timestamp, sum(amount) as TotalVendes
from transaction
where declined =0
group by timestamp
order by TotalVendes desc
limit 5;
-- sin el operador date() sale con la hora exacta pero no se agrupa por día sino que por hora y día.



## Exercici 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
select country, avg(amount) as mitja
from transaction
join company on transaction.company_id=company.id
where declined=0
group by country
order by mitja desc;


## Exercici 3
-- En la teua empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la 
-- companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
-- 1.Mostra el llistat aplicant JOIN i subconsultes
select *
from transaction
join company on transaction.company_id=company.id
where  country = (select country from company where company_name ='Non Institute');


-- 2.Mostra el llistat aplicant solament subconsultes
select *
from transaction
where company_id in (select id from company where country in (select country from company where company_name = 'Non Institute'));



## SQL NIVELL 3
## Exercici 1:
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions 
-- amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliold de 2021 i 13 de març del 2002. 
-- Ordena els resultats de major a menor quantitat.

select company_name, phone, country, date(timestamp), amount
from transaction
join company on transaction.company_id=company.id
where amount between 100 and 200
and date(timestamp) in ('2021-04-29', '2021-07-20', '2022-03-13')
order by amount desc;

## where timestamp in ('2021-04-29', '2021-07-20', '2022-03-13'); con este filtro no nos aparece ningún resultado ya que deberíamos especificar también la hora. Utilizamos por ende la función date() para que identifique lo que pedimos.



-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el 
-- departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
SELECT * FROM transactions.company;
SELECT * FROM transactions.transaction;

select company_name as c, count(c.id) as TransTotales, 
					   case 
						when count(c.id) > 4 then "Més de 4 transaccions"
						when count(c.id) < 4 then "Menys de 4 transaccions"
						else "4 transaccions"
						end as Trans
from company as c
join transaction as t on c.id=t.company_id  
group by c.company_name, c.id
order by TransTotales desc;

-- al principio no me funcionaba porque el id era ambiguo hasta que le he puesto alias de las tablas en todos los apartados y me ha dado el resultado!



