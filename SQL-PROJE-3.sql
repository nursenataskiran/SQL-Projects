--SQL INJECTION TEST
DECLARE @FirstName NVARCHAR(100) = ''' OR 1=1 --';
DECLARE @sql NVARCHAR(MAX);

SET @sql = 'SELECT BusinessEntityID, FirstName, LastName 
            FROM Person.Person 
            WHERE FirstName = ''' + @FirstName + '''';

EXEC(@sql);


DECLARE @FirstName NVARCHAR(100) = ''' OR 1=1 --';
DECLARE @sql NVARCHAR(MAX);

SET @sql = 'SELECT BusinessEntityID, FirstName, LastName 
            FROM Person.Person 
            WHERE FirstName = @first';

EXEC sp_executesql @sql,
     N'@first NVARCHAR(100)',
     @first = @FirstName;

--AUDIT LOG

CREATE SERVER AUDIT KisiAudit
TO FILE (
    FILEPATH = 'C:\AuditLogs\',
    MAXSIZE = 5 MB,
    MAX_FILES = 10,
    RESERVE_DISK_SPACE = OFF
)
WITH (ON_FAILURE = CONTINUE);


ALTER SERVER AUDIT KisiAudit
WITH (STATE = ON);


USE AdventureWorks2019;
GO

CREATE DATABASE AUDIT SPECIFICATION KisiAuditSpec
FOR SERVER AUDIT KisiAudit
ADD (SELECT ON OBJECT::Person.Person BY PUBLIC),
ADD (INSERT ON OBJECT::Person.Person BY PUBLIC),
ADD (DELETE ON OBJECT::Person.Person BY PUBLIC)
WITH (STATE = ON);


SELECT TOP 1 * FROM Person.Person;

SELECT *
FROM sys.fn_get_audit_file('C:\AuditLogs\KisiAudit*.sqlaudit', NULL, NULL);