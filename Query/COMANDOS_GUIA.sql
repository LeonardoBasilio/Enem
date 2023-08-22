IF OBJECT_ID('tempdb..#TMP_SP','U') IS NOT NULL DROP TABLE #TMP_SP;

CREATE TABLE #TMP_SP (
        SPID INT,
        Status VARCHAR(MAX),
        LOGIN VARCHAR(MAX),
        HostName VARCHAR(MAX),
        BlkBy VARCHAR(MAX),
        DBName VARCHAR(MAX),
        Command VARCHAR(MAX),
        CPUTime INT,
        DiskIO INT,
        LastBatch VARCHAR(MAX),
        ProgramName VARCHAR(MAX),
        SPID_1 INT,
        REQUESTID INT
);

INSERT INTO #TMP_SP
EXEC SP_WHO2;


select * from #TMP_SP
WHERE LOGIN = 'bi_leonardobo'

 