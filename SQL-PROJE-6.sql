USE AdventureWorks2019;
GO

CREATE TABLE Customers_New (
    CustomerID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100)
);


--2.	Þema Deðiþikliklerini Loglamak için Tablo Oluþturulmasý
CREATE TABLE SchemaChangeLog (
    ChangeID INT IDENTITY(1,1) PRIMARY KEY,
    EventType NVARCHAR(100),
    ObjectName NVARCHAR(100),
    TSQLCommand NVARCHAR(MAX),
    ChangeDate DATETIME DEFAULT GETDATE()
);

--3.	DDL Trigger ile Otomatik Takip
CREATE TRIGGER trg_SchemaChangeLog
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    INSERT INTO SchemaChangeLog (EventType, ObjectName, TSQLCommand)
    SELECT 
        EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')
END;

--4.	Test Tablosu ile Trigger Kontrolü
CREATE TABLE VersionControlTest (
    TestID INT,
    DummyField NVARCHAR(50)
);

--5.	Log Kayýtlarýnýn Ýncelenmesi
SELECT * FROM SchemaChangeLog ORDER BY ChangeDate DESC;

DROP TABLE VersionControlTest;

-- Log'daki CREATE komutu referans alýnarak tekrar oluþturulabilir
CREATE TABLE VersionControlTest (
    TestID INT,
    DummyField NVARCHAR(50)
);
