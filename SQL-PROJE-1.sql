--1.	Yavaþ Sorgularýn Tespiti
SELECT TOP 10 
    qs.total_elapsed_time / qs.execution_count AS AvgElapsedTime,
    qs.execution_count,
    SUBSTRING(st.text, (qs.statement_start_offset / 2) + 1, 
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
          ELSE qs.statement_end_offset
          END - qs.statement_start_offset) / 2) + 1) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY AvgElapsedTime DESC;

--2.	Execution Plan Analizi
SELECT       db_id() as database_id,       sm.[is_inlineable] AS InlineableScalarCount,       sm.[inline_type] AS InlineType,       COUNT_BIG(*) AS ScalarCount,        COUNT_BIG(CASE WHEN sm.[definition] LIKE '%getdate%' OR        sm.[definition] LIKE '%getutcdate%' OR        sm.[definition] LIKE '%sysdatetime%' OR       sm.[definition] LIKE '%sysutcdatetime%' OR       sm.[definition] LIKE '%sysdatetimeoffset%' OR       sm.[definition] LIKE '%CURRENT_TIMESTAMP%'       THEN 1        END) AS ScalarCountWithDate                 FROM    [sys].[objects] o       INNER JOIN    [sys].[sql_modules] sm        ON o.[object_id] = sm.[object_id]       WHERE   o.[type] = 'FN'       GROUP BY        sm.[is_inlineable],       sm.[inline_type]

--3.	Eksik Ýndeks Önerisi ve Oluþturulmasý
SELECT 
    migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS ImprovementMeasure,
    mid.statement AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY ImprovementMeasure DESC;

CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_OrderDate_SubTotal
ON Sales.SalesOrderHeader (OrderDate, SubTotal)
INCLUDE (TaxAmt, Freight);

--4.	Performans Ýyileþmesinin Gözlemlenmesi
SELECT SalesOrderID, OrderDate, SubTotal, TaxAmt, Freight
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2013-01-01' AND '2013-06-30'
  AND SubTotal > 1000;

--5.	Gereksiz indekslerin tespiti 
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.index_id,
    user_seeks, user_scans, user_lookups, user_updates
FROM sys.dm_db_index_usage_stats us
JOIN sys.indexes i ON i.object_id = us.object_id AND i.index_id = us.index_id
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
  AND user_seeks = 0 
  AND user_scans = 0 
  AND user_lookups = 0
ORDER BY user_updates DESC;
