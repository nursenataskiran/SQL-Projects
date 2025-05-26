--Yedekleme Komutu – Job Step
DECLARE @fileName NVARCHAR(200)
SET @fileName = 'C:\SQLBackups\AW_' + CONVERT(VARCHAR(20), GETDATE(), 112) + '.bak'

BACKUP DATABASE AdventureWorks2019
TO DISK = @fileName
WITH INIT, NAME = 'Daily Auto Backup';

--Yedekleme Raporlama
SELECT 
    database_name,
    backup_start_date,
    backup_finish_date,
    DATEDIFF(SECOND, backup_start_date, backup_finish_date) AS DurationSeconds,
    backup_size / 1024 / 1024 AS Size_MB,
    physical_device_name
FROM msdb.dbo.backupset b
JOIN msdb.dbo.backupmediafamily m
  ON b.media_set_id = m.media_set_id
WHERE database_name = 'AdventureWorks2019'
ORDER BY backup_finish_date DESC;
