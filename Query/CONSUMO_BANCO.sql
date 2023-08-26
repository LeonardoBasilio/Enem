USE Enem;
SELECT name AS NomeGrupoArquivo, size/128 AS TamanhoMB
FROM sys.master_files
WHERE database_id = DB_ID('Enem');



-- Consulta para obter o tamanho de cada tabela
SELECT 
    t.NAME AS NomeTabela,
    s.NAME AS Esquema,
    p.rows AS NumeroDeLinhas,
    SUM(a.total_pages) * 8 AS TamanhoTotalKB,
    SUM(a.used_pages) * 8 AS TamanhoUsadoKB,
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS TamanhoNaoUsadoKB
FROM 
    sys.tables t
INNER JOIN 
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
GROUP BY 
    t.NAME, s.NAME, p.rows
ORDER BY 
    TamanhoTotalKB DESC;


	DBCC SHRINKFILE (N'Enem', 6); -- Reduz o arquivo de log para 1 GB (1024 MB)
