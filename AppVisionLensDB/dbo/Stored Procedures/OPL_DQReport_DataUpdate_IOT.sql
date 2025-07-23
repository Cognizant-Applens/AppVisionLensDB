CREATE PROCEDURE [dbo].[OPL_DQReport_DataUpdate_IOT] 

AS

BEGIN

SELECT DISTINCT EsaProjectId,Archetype,WorkCategory,subworkcategory INTO #DistinctTemp FROM dbo.OPLDQReport_IOT 
WHERE ProjectOwningUnit LIKE 'IoT%'

--Rank 'Enhancement and Support' rows, prioritizing those with 'Support' in WorkCategory
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY EsaProjectId
           ORDER BY 
               CASE 
                   WHEN WorkCategory =  'Engineering and Manufacturing Applications Management and Support' THEN 0 
				   WHEN subworkcategory in ('Production support','Incident Management','Service Request','Problem Management','Change Management')  THEN 0
                   ELSE 1 
               END, 
               (SELECT NULL)
       ) AS rn
INTO #EnhancementRanked
FROM #DistinctTemp
WHERE Archetype = 'Enhancement and Support'
  AND EsaProjectId IN (
      SELECT EsaProjectId
      FROM #DistinctTemp
      GROUP BY EsaProjectId
      HAVING COUNT(*) >= 2 AND SUM(CASE WHEN Archetype = 'Enhancement and Support' THEN 1 ELSE 0 END) >= 1
  );

--Delete all rows for those projects except the top-ranked enhancement row
DELETE FROM #DistinctTemp
WHERE EsaProjectId IN (SELECT EsaProjectId FROM #EnhancementRanked)
AND NOT EXISTS (
    SELECT 1
    FROM #EnhancementRanked er
    WHERE #DistinctTemp.EsaProjectId = er.EsaProjectId
      AND #DistinctTemp.Archetype = er.Archetype
      AND #DistinctTemp.WorkCategory = er.WorkCategory
    AND #DistinctTemp.subworkcategory = er.subworkcategory

      AND er.rn = 1
);


--Merge all non-enhancement rows
CREATE TABLE #MergedProjects (
    EsaProjectId NVARCHAR(255),
    Archetype NVARCHAR(MAX),
    WorkCategory NVARCHAR(MAX),
	subworkcategory NVARCHAR(MAX)
);

INSERT INTO #MergedProjects (EsaProjectId, Archetype, WorkCategory,subworkcategory)
SELECT 
    EsaProjectId,
    STUFF((
        SELECT ',' + DISTINCT_Archetype
        FROM (
            SELECT DISTINCT Archetype AS DISTINCT_Archetype
            FROM #DistinctTemp AS innerT
            WHERE innerT.EsaProjectId = outerT.EsaProjectId
        ) AS DistinctArchetypes
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS Archetype,
    STUFF((
        SELECT ',' + DISTINCT_WorkCategory
        FROM (
            SELECT DISTINCT WorkCategory AS DISTINCT_WorkCategory
            FROM #DistinctTemp AS innerT
            WHERE innerT.EsaProjectId = outerT.EsaProjectId
        ) AS DistinctWorkCategories
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS WorkCategory,
		 STUFF((
        SELECT ',' + DISTINCT_subworkcategory
        FROM (
            SELECT DISTINCT subworkcategory AS DISTINCT_subworkcategory
            FROM #DistinctTemp AS innerT
            WHERE innerT.EsaProjectId = outerT.EsaProjectId
        ) AS Distinctsubworkcategories
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS subworkcategory
FROM #DistinctTemp AS outerT
WHERE EsaProjectId IN (
    SELECT EsaProjectId
    FROM dbo.OPLDQReport_IOT
    GROUP BY EsaProjectId
    HAVING COUNT(*) >= 2 AND SUM(CASE WHEN Archetype = 'Enhancement and Support' THEN 1 ELSE 0 END) = 0
)
GROUP BY EsaProjectId;

--SELECT * FROM #MergedProjects

DELETE FROM #DistinctTemp
WHERE EsaProjectId IN (SELECT EsaProjectId FROM #MergedProjects);

INSERT INTO #DistinctTemp (EsaProjectId, Archetype, WorkCategory,subworkcategory)
SELECT EsaProjectId, Archetype, WorkCategory,subworkcategory
FROM #MergedProjects;

--SELECT * FROM #DistinctTemp 

TRUNCATE TABLE dbo.OPLDQReport_IOT

INSERT INTO dbo.OPLDQReport_IOT (EsaProjectId, Main_Sub_Project_Flag, Archetype, WorkCategory,subworkcategory)
SELECT EsaProjectId, 'Execution Project', Archetype, WorkCategory,subworkcategory FROM #DistinctTemp

DROP TABLE #MergedProjects;
DROP TABLE #EnhancementRanked;
DROP TABLE #DistinctTemp;

END

