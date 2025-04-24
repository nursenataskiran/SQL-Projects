ALTER DATABASE AdventureWorks2019 SET RECOVERY FULL;

USE AdventureWorks2019;
INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (1, 'backup_test@example.com', NEWID(), GETDATE());

BACKUP DATABASE AdventureWorks2019
TO DISK = 'C:\Users\nurse\Documents\AdventureWorks2019_Local.bak'
WITH INIT;


INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (2, 'diff_test@example.com', NEWID(), GETDATE());

--backup al
USE master;
GO
BACKUP DATABASE AdventureWorks2019
TO DISK = 'C:\Backup\AdventureWorks2019_FULL.bak'
WITH FORMAT, INIT, NAME = 'Full Backup - AdventureWorks2019';

-- Tum veritabanindaki FKleri devre disi birak
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

-- Silme islemini yap
DELETE FROM Person.Person;

-- Tum FKleri tekrar aktif hale getir
EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL";


USE master;
GO

-- Tum ba�lant�lar� sonlandir ve veritabanini SINGLE_USER moduna al
ALTER DATABASE AdventureWorks2019 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- simdi sil
DROP DATABASE AdventureWorks2019;
----------------------
USE AdventureWorks2019;
GO

SELECT COUNT(*) FROM Person.Person;

USE master;
GO

ALTER DATABASE AdventureWorks2019 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

DROP DATABASE AdventureWorks2019;

--veri tabaninin geri getirilme islemi

RESTORE DATABASE AdventureWorks2019
FROM DISK = 'C:\Backup\AdventureWorks2019_FULL.bak'
WITH REPLACE, RECOVERY;

--gerekli kontroller
USE AdventureWorks2019;
GO

SELECT COUNT(*) AS PersonCount FROM Person.Person;
SELECT COUNT(*) AS EmailCount FROM Person.EmailAddress;
SELECT COUNT(*) AS PhoneCount FROM Person.PersonPhone;


--test veritabanının olusturulmasi
RESTORE DATABASE AdventureWorks2019_TestRestore
FROM DISK = 'C:\Backup\AdventureWorks2019_FULL.bak'
WITH MOVE 'AdventureWorks2019' 
     TO 'C:\SQLRestore\AdventureWorks2019_TestRestore.mdf',
     MOVE 'AdventureWorks2019_log' 
     TO 'C:\SQLRestore\AdventureWorks2019_TestRestore_log.ldf',
     REPLACE, RECOVERY;

--test asamasi 
USE AdventureWorks2019_TestRestore;
GO

SELECT COUNT(*) AS PersonCount FROM Person.Person;
SELECT COUNT(*) AS EmailCount FROM Person.EmailAddress;
SELECT COUNT(*) AS PhoneCount FROM Person.PersonPhone;
