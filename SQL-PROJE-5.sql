--eksik veri kontrolü
SELECT * FROM Person.Person WHERE LastName IS NULL;
SELECT * FROM Person.EmailAddress WHERE EmailAddress NOT LIKE '%@%.%';
--veri dönüþtürme
SELECT BusinessEntityID, UPPER(FirstName) AS FirstName, UPPER(LastName) AS LastName
INTO CleanedPerson
FROM Person.Person;

--veri kalitesi raporlama
SELECT 
    (COUNT(CASE WHEN LastName = 'UNKNOWN' THEN 1 END) * 100.0) / COUNT(*) AS ErrorRate
FROM CleanedPerson;
