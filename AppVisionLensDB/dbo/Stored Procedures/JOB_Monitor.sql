CREATE PROCEDURE [dbo].[JOB_Monitor]
AS
BEGIN
BEGIN TRY 

SET NOCOUNT ON;

SELECT * into #temp from (
SELECT JMas.JobID,jt.Tablename,jtm.JobTableMapID as jobMapId,OBJECT_ID(jt.Tablename) as istableexist,
jt.CreatedDateColumn,
jt.ModifiedDateColumn,
GETDATE() as jobrundate,
GETDATE() as createddate,
'System' as createdby
FROM [dbo].JobTableMapping as jtm 
join [dbo].JobTableMaster as jt on jt.Tableid=jtm.TableID
join [dbo].Jobdetailsmaster as JMas on JMas.JobID =jtm.JobID
where jt.isdeleted=0 and jtm.IsDeleted=0 and JMas.IsDeleted=0 and OBJECT_ID(jt.Tablename) is not null)t 
 

insert into [dbo].JobMonitor (JobTableMapID,JobRunDate,CreatedDate,CreatedBy) 
(select jobmapid,jobrundate,createddate,createdby from #temp  as t 
WHERE NOT EXISTS 
(select * from [dbo].JobMonitor M where 
(CONVERT(VARCHAR(10),jobrundate, 101)=CONVERT(VARCHAR(10),GetDate(), 101)) and t.jobMapId =M.JobTableMapID))

select * into #temp2 from
(
select jobid,jobMapId,
'SELECT count(MT.'+ CreatedDateColumn +') FROM '+ TableName 
+' as MT Where CONVERT(VARCHAR(10),MT.'+ CreatedDateColumn +' , 101) = ''' + CONVERT(VARCHAR(10),DATEADD(DD,0,GETDATE()), 101) + '''' 
as TableQUERY,
Getdate() as JobRunDate,Tablename 
from #temp where CreatedDateColumn is not null) #temp2
--select * from #temp2

select * into #temp3 from
(
select jobid,jobMapId,
'SELECT count(MT.'+ ModifiedDateColumn +')FROM '+ TableName 
+' as MT Where CONVERT(VARCHAR(10),MT.'+ ModifiedDateColumn +', 101) = ''' + CONVERT(VARCHAR(10),DATEADD(DD,0,GETDATE()), 101) + '''' 
as TableQUERY,
Getdate() as JobRunDate,Tablename
from #temp where ModifiedDateColumn is not null) #temp3


declare @sql nvarchar(max)
SELECT @sql = ISNULL(@sql + ';
','') + 'update JM set InsertedCount=(' + TableQUERY +') from [dbo].JobMonitor as JM 
join [dbo].JobTableMapping as TM on JM.JobTableMapID=TM.JobTableMapID
join [dbo].[JobDetailsMaster]  as JMas on TM.JobID =JMas.JobID
join [dbo].JobTableMaster as JTable on TM.TableID=JTable.TableID 
where JTable.TableName='''+ TableName +''' and CONVERT(VARCHAR(10),JobRunDate, 101) = CONVERT(VARCHAR(10),DATEADD(DD,0,GETDATE()), 101)'
FROM #temp2 where TableQUERY is not null 
--print(@sql)
exec(@sql)

declare @sqlModified nvarchar(max)
SELECT @sqlModified = ISNULL(@sqlModified + ';
','') + 'update JM set UpdatedCount=(' + TableQUERY +') from [dbo].JobMonitor as JM 
join [dbo].JobTableMapping as TM on JM.JobTableMapID=TM.JobTableMapID
join [dbo].[JobDetailsMaster]  as JMas on TM.JobID =JMas.JobID
join [dbo].JobTableMaster as JTable on TM.TableID=JTable.TableID 
where JTable.TableName='''+ TableName +''' and CONVERT(VARCHAR(10),JobRunDate, 101) = CONVERT(VARCHAR(10),DATEADD(DD,0,GETDATE()), 101)'
FROM #temp3 where TableQUERY is not null 
--print(@sqlModified)
exec(@sqlModified)


select JobMonitorID,JobTableMapID,InsertedCount,UpdatedCount,JobRunDate,IsDeleted,CreatedDate,CreatedBy
,modifieddate,modifiedby from [dbo].JobMonitor

Drop table #temp
Drop table #temp2
Drop table #temp3

END TRY 
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[dbo].[SP_JOB_Monitor] ', @ErrorMessage,'1' 
    
END CATCH  
END
