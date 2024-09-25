#  Nivell 1
## Exercici 2: Utilitzant JOIN realitzaràs les següents consultes
### Llistat dels països que estan fent compres.
SELECT DISTINCT country
FROM transaction 
JOIN company ON company.id = transaction.company_id;

### Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT country)
FROM transaction
JOIN company ON company.id = transaction.company_id;

### Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_name, ROUND(AVG(amount),2) AS average
FROM transaction
JOIN company ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY company_name
ORDER BY AVG(amount) DESC
LIMIT 1;


## Exercici 3: Utilitzant només subconsultes (sense utilitzar JOIN)
### Mostra totes les transaccions realitzades per empreses d'Alemanya.
-- Para mostrar el id de las compañias de Alemania, que usaré como filtro.
SELECT id
FROM company
WHERE country = "Germany";

-- Muestra todas las transaciones realizadas por empresas de Alemania.
SELECT *
FROM transaction
WHERE company_id IN 
	(
	SELECT id
	FROM company
	WHERE country = "Germany"
	);
    
### Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
-- Para mostrar el promedio de todas las transacciones.
SELECT AVG(amount)
FROM transaction;

-- Para mostrar el identificador de las compañias con un gasto superior al gasto medio.
SELECT DISTINCT company_id
FROM transaction
WHERE amount >
	(
    SELECT AVG(amount)
	FROM transaction
	);

-- Para mostrar la lista de las empresas con una gasto superior a la media.    
SELECT company_name
FROM company
WHERE id IN 
	(
	SELECT DISTINCT company_id
	FROM transaction
	WHERE amount >
		(
		SELECT AVG(amount)
		FROM transaction
		));

### Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
-- De esta manera puedo ver las empresas que no tienen transacciones registradas
SELECT company_name
FROM company
WHERE NOT EXISTS
	(
	SELECT DISTINCT company_id
	FROM transaction
    WHERE company.id = transaction.company_id
    );
 
 
# Nivell 2
## Exercici 1
### Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
### Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT SUM(amount) AS income, DATE(timestamp) AS date
FROM transaction
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY SUM(amount) DESC
LIMIT 5;

## Exercici 2
### Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT country, AVG(amount)
FROM transaction JOIN company ON company.id=transaction.company_id
WHERE declined = 0
GROUP BY country
ORDER BY AVG(amount) DESC;

## Exercici 3
### En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
### Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
-- Para saber el en que país se encuentra "Non Institute"
SELECT country
FROM company
WHERE company_name LIKE "Non Institute";

-- Para tener una lista de las empresas de "United_Kingdom" y su respectivo identificador
SELECT id, company_name
FROM company
WHERE country LIKE "United_Kingdom";

-- #1 Mostra el llistat aplicant JOIN i subconsultes.
SELECT transaction.*
FROM transaction JOIN company ON company.id = transaction.company_id
WHERE country LIKE 
	(
    SELECT country
	FROM company
	WHERE company_name LIKE "Non Institute"
	);
    
-- #2 Mostra el llistat aplicant solament subconsultes.
SELECT *
FROM transaction
WHERE company_id IN 
	(
    SELECT id
	FROM company
	WHERE country LIKE "United_Kingdom"
	);
    

# Nivell 3
## Exercici 1
### Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates:
### 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.
-- Para filtrar por las fechas del ejercicio
SELECT DATE(timestamp)
FROM transaction
WHERE DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13');

-- Para mostrar los resultados filtrados por fecha y cantidad
SELECT company_name, phone, country, DATE(timestamp) AS date, amount
FROM company JOIN transaction ON company.id = transaction.company_id
HAVING amount BETWEEN 100 AND 200 AND
date IN 
	(
	SELECT DATE(timestamp)
	FROM transaction
	WHERE DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
	)
ORDER BY amount DESC;


## Exercici 2
### Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi,
### per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses,
### però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
-- Creé una tabla temporal para saber el número de transaciones que tiene cada empresa
CREATE TEMPORARY TABLE trans_count
SELECT company_id, COUNT(id) AS transaction_count
FROM transaction
GROUP BY company_id;

-- Para mostrar el listado de empresas que tienen más de 4 transacciones
SELECT company_name, transaction_count,
CASE
	WHEN transaction_count > 4 THEN "Más de 4 transacciones"
	ELSE "Menos de 4 transacciones"
END AS "¿Más? o, ¿menos?"
FROM company JOIN trans_count ON company.id = trans_count.company_id
ORDER BY transaction_count DESC;