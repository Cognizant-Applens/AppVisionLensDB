/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		Divya
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [MS].[DailyMetricFeed_Phase2]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
--step 1) clear the old data and get the new data from view 
--Truncate Table  [MS].[MetricMasterDailyDump]
Truncate Table  [MS].[MetricstagingDailyDump]
Truncate Table [MS].[MetricMasterDailyDump_Ticketsummary]
Truncate Table  [MS].[MetricstagingDailyDump_Outbound]
Truncate Table [MS].[MetricMasterDailyDump_Ticketsummary_Outbound]

-- Newwly added code Begin
TRUNCATE TABLE MS.MetricstagingDailyDump_ProjectSpecific
TRUNCATE TABLE MS.MetricMasterDailyDump_Ticketsummary_ProjectSpecific
TRUNCATE TABLE MS.MetricstagingDailyDump_Outbound_ProjectSpecific
TRUNCATE TABLE MS.MetricMasterDailyDump_Ticketsummary_Outbound_ProjectSpecific

-- Newwly added code End

----SSIS--

--Truncate Table [MS].[CTS_AVM_PROJECTPRIORITY_VIEW]
--Truncate Table [MS].[CTS_AVM_PROJECTSUPPORTCATEGORY_VIEW]
--Truncate Table [MS].[CTS_AVM_PTLS_LANGUAGE_MAPPING_VIEW]
--Truncate Table [MS].[MPS_STAGING_TABLE_EFORM_VIEW]

--INSERT INTO [MS].[CTS_AVM_PROJECTPRIORITY_VIEW]
--select *  from [CTSC00698426801].[Swiftalm].SwiftALM.CTS_AVM_PROJECTPRIORITY_VIEW

--INSERT INTO [MS].[CTS_AVM_PROJECTSUPPORTCATEGORY_VIEW]
--select *   from [CTSC00698426801].[Swiftalm].SwiftALM.CTS_AVM_PROJECTSUPPORTCATEGORY_VIEW

--INSERT INTO [MS].[CTS_AVM_PTLS_LANGUAGE_MAPPING_VIEW]
--select *   from [CTSC00698426801].[Swiftalm].SwiftALM.CTS_AVM_PTLS_LANGUAGE_MAPPING_VIEW 


--INSERT INTO [MS].[MPS_STAGING_TABLE_EFORM_VIEW]
--select * FROM [CTSC00698426801].[Swiftalm].Swiftalm.MPS_STAGING_TABLE_EFORM_VIEW

------
--INSERT INTO [MS].[MetricMasterDailyDump]
--select * FROM [CTSC00698426801].[Swiftalm].[Swiftalm].[CTS_AVM_MPS_METRICS_REG_VIEW]



INSERT INTO   [MS].[MetricstagingDailyDump]
select * FROM [MS].[MPS_STAGING_TABLE_EFORM_VIEW] Where  DN_MANDATORY in('Standard','Custom') 
AND DN_UNIQUEKEY is not null 
--and DN_PROJECTID IN(SELECT EsaProjectID FROM AVL.MAS_ProjectMaster WHERE ISNULL(IsMigratedFromDART,0) IN(1,2)) 
AND DN_METRICNAME is not null AND DN_METRICNAME <> 'Load Factor'

INSERT INTO  [MS].[MetricMasterDailyDump_Ticketsummary]
select * FROM [MS].[MPS_STAGING_TABLE_EFORM_VIEW] Where  DN_MANDATORY in('Ticket Summary') 
AND DN_UNIQUEKEY is not null 
--and DN_PROJECTID IN(SELECT EsaProjectID FROM AVL.MAS_ProjectMaster WHERE ISNULL(IsMigratedFromDART,0)  IN(1,2))
 AND DN_METRICNAME is not null AND DN_METRICNAME <> 'Load Factor'

INSERT INTO   [MS].[MetricstagingDailyDump_Outbound]
select * FROM [MS].[MPS_STAGING_TABLE_EFORM_VIEW] Where  DN_MANDATORY in('Standard','Custom') 
AND DN_UNIQUEKEY is not null 
--and DN_PROJECTID IN(SELECT EsaProjectID FROM AVL.MAS_ProjectMaster WHERE ISNULL(IsMigratedFromDART,0) IN(1,2))
 AND DN_METRICNAME is not null AND DN_METRICNAME <> 'Load Factor'

INSERT INTO  [MS].[MetricMasterDailyDump_Ticketsummary_Outbound]
select * FROM [MS].[MPS_STAGING_TABLE_EFORM_VIEW] Where  DN_MANDATORY in('Ticket Summary') 
AND DN_UNIQUEKEY is not null 
--and DN_PROJECTID IN(SELECT EsaProjectID FROM AVL.MAS_ProjectMaster WHERE ISNULL(IsMigratedFromDART,0)  IN(1,2))
 AND DN_METRICNAME is not null AND DN_METRICNAME <> 'Load Factor'

-- Newly added Loadfactor Begin


INSERT INTO   [MS].MetricstagingDailyDump_ProjectSpecific
select * FROM [MS].MPS_STAGING_TABLE_EFORM_VIEW Where  DN_MANDATORY in('Standard','Custom') 
AND DN_METRICNAME ='Load Factor' 
--and DN_PROJECTID IN(SELECT EsaProjectID FROM AVL.MAS_ProjectMaster WHERE ISNULL(IsMigratedFromDART,0)  IN(1,2)) 

INSERT INTO  [MS].MetricMasterDailyDump_Ticketsummary_ProjectSpecific
select * FROM [MS].MPS_STAGING_TABLE_EFORM_VIEW Where  DN_MANDATORY in('Ticket Summary') 
AND DN_METRICNAME ='Load Factor' 
 --and DN_PROJECTID IN(SELECT EsaProjectID FROM AVL.MAS_ProjectMaster WHERE ISNULL(IsMigratedFromDART,0)  IN(1,2)) 

INSERT INTO   [MS].MetricstagingDailyDump_Outbound_ProjectSpecific
select * FROM [MS].MPS_STAGING_TABLE_EFORM_VIEW Where  DN_MANDATORY in('Standard','Custom')
AND DN_METRICNAME ='Load Factor'  
--and DN_PROJECTID IN(SELECT EsaProjectID FROM AVL.MAS_ProjectMaster WHERE ISNULL(IsMigratedFromDART,0)  IN(1,2))  

INSERT INTO  [MS].MetricMasterDailyDump_Ticketsummary_Outbound_ProjectSpecific
select * FROM [MS].MPS_STAGING_TABLE_EFORM_VIEW Where  DN_MANDATORY in('Ticket Summary')
 AND DN_METRICNAME ='Load Factor' 
--and DN_PROJECTID IN(SELECT EsaProjectID FROM AVL.MAS_ProjectMaster WHERE ISNULL(IsMigratedFromDART,0)  IN(1,2)) 

-- Newly added Loadfactor End



Update [MS].[MetricstagingDailyDump]
set DN_UOM='No.' where DN_METRICNAME='Custom Metric_Productivity'

Update [MS].[MetricstagingDailyDump_Outbound]
set DN_UOM='No.' where DN_METRICNAME='Custom Metric_Productivity'

UPDATE [MS].[MetricMasterDailyDump]
SET METRICNAME = REPLACE(METRICNAME,CHAR(160),CHAR(32))
WHERE METRICNAME like('%' +  CHAR(160) +'%')

UPDATE [MS].[MetricstagingDailyDump]
SET DN_METRICNAME = REPLACE(DN_METRICNAME,CHAR(160),CHAR(32))
WHERE DN_METRICNAME like('%' +  CHAR(160) +'%')

UPDATE [MS].[MetricMasterDailyDump_Ticketsummary]
SET DN_METRICNAME = REPLACE(DN_METRICNAME,CHAR(160),CHAR(32))
WHERE DN_METRICNAME like('%' +  CHAR(160) +'%')

UPDATE [MS].[MetricstagingDailyDump_Outbound]
SET DN_METRICNAME = REPLACE(DN_METRICNAME,CHAR(160),CHAR(32))
WHERE DN_METRICNAME like('%' +  CHAR(160) +'%')

UPDATE [MS].[MetricMasterDailyDump_Ticketsummary_Outbound]
SET DN_METRICNAME = REPLACE(DN_METRICNAME,CHAR(160),CHAR(32))
WHERE DN_METRICNAME like('%' +  CHAR(160) +'%')


UPDATE [MS].[MetricstagingMonthlyDump_Outbound]
SET DN_METRICNAME = REPLACE(DN_METRICNAME,CHAR(160),CHAR(32))
WHERE DN_METRICNAME like('%' +  CHAR(160) +'%')

UPDATE [MS].[MetricMasterMonthlyDump_Ticketsummary_Outbound]
SET DN_METRICNAME = REPLACE(DN_METRICNAME,CHAR(160),CHAR(32))
WHERE DN_METRICNAME like('%' +  CHAR(160) +'%')



 Update [MS].[MetricstagingDailyDump]
 SET DN_SUPPORTCATEGORY=NULL
 Where DN_SUPPORTCATEGORY ='NA' OR DN_SUPPORTCATEGORY ='--None--' 
 
  Update [MS].[MetricstagingDailyDump]
 SET DN_PRIORITY=NULL
 Where DN_PRIORITY ='NA' OR DN_PRIORITY ='--None--' 
  
  Update [MS].[MetricstagingDailyDump]
 SET DN_TECHNOLOGY=NULL
 Where DN_TECHNOLOGY ='NA' OR DN_TECHNOLOGY ='--None--' 
 
 
 
 Update [MS].[MetricMasterDailyDump_Ticketsummary]
 SET DN_SUPPORTCATEGORY=NULL
 Where DN_SUPPORTCATEGORY ='NA' OR DN_SUPPORTCATEGORY ='--None--' 
 
  Update [MS].[MetricMasterDailyDump_Ticketsummary]
 SET DN_PRIORITY=NULL
 Where DN_PRIORITY ='NA' OR DN_PRIORITY ='--None--' 
 


-----
----step 2) UOM Master
--select * from MAS.Mainspring_UOM_Master
--select * from [MS].[MetricMasterDailyDump]
--select * from Mainspring_MetricMasterDailyDump_Ticketsummary
--select distinct DN_METRICNAME from Mainspring_MetricstagingDailyDump where DN_MANDATORY in('Standard','Custom Metrics')
--select * from Mainspring_MetricstagingDailyDump
--select * from MAS.Mainspring_UOM_Master
INSERT into [MS].[MAS_UOM_Master]
select distinct uom,'Varchar',0 from [MS].[MetricMasterDailyDump] where uom not in (
select UOM_DESC from [MS].[MAS_UOM_Master])
---3) Metric master
INSERT INTO [MS].[MAS_Metric_Master]
select distinct LTRIM(RTRIM(DD.MetricName)),2,U.UOMID,4,0 from [MS].[MetricMasterDailyDump] DD
Inner join [MS].[MAS_UOM_Master] U ON LTRIM(RTRIM(U.UOM_DESC))=LTRIM(RTRIM(DD.UoM))
where   LTRIM(RTRIM(DD.MetricName)) not in(
select LTRIM(RTRIM(MetricName)) from [MS].[MAS_Metric_Master]
)
--Metrics Master for Custom
INSERT INTO [MS].[MAS_Metric_Master]
select distinct LTRIM(RTRIM(DD.DN_METRICNAME)),2,U.UOMID,4,0 from [MS].[MetricstagingDailyDump] DD
Inner join [MS].[MAS_UOM_Master] U ON LTRIM(RTRIM(U.UOM_DESC))=LTRIM(RTRIM(DD.DN_UOM))
where   LTRIM(RTRIM(DD.DN_METRICNAME)) not in(
select LTRIM(RTRIM(MetricName)) from [MS].[MAS_Metric_Master]
) and DD.DN_METRICNAME <> 'Percenatge of Unauthorized Licenses vs Purchased Licenses in Use'

--Code block to insert when same metric name with different uom id
INSERT INTO [MS].[MAS_Metric_Master]
select distinct LTRIM(RTRIM(DD.DN_METRICNAME)),2,U.UOMID,4,0 from [MS].[MetricstagingDailyDump] DD
Inner join [MS].[MAS_UOM_Master] U ON LTRIM(RTRIM(U.UOM_DESC))=LTRIM(RTRIM(DD.DN_UOM))
WHERE DD.DN_METRICNAME <> 'Percenatge of Unauthorized Licenses vs Purchased Licenses in Use'
EXCEPT
select  LTRIM(RTRIM(MetricName)),2,UOMID,4,0 from MS.MAS_Metric_Master
--select * from  mas.Mainspring_Metric_Master
--4) Basemeasure for standard

SELECT  A.* into #BaseMeasureMasterTemp from 
(select distinct Numerator1 AS Basemeasure from   [MS].[MetricMasterDailyDump] where Numerator1 is not null and Numerator1 <>''
UNION 
select distinct Numerator2 AS Basemeasure from   [MS].[MetricMasterDailyDump]  where Numerator2 is not null  and Numerator2 <>''
UNION
select distinct Numerator3 AS Basemeasure from   [MS].[MetricMasterDailyDump] where Numerator3 is not null  and Numerator3 <>''
UNION
select distinct Numerator4 AS Basemeasure from   [MS].[MetricMasterDailyDump] where Numerator4 is not null and Numerator4 <>''
UNION
select distinct Denominator1 AS Basemeasure from   [MS].[MetricMasterDailyDump] where Denominator1 is not null and Denominator1 <>''
UNION
select distinct Denominator2 AS Basemeasure from   [MS].[MetricMasterDailyDump] where Denominator2 is not null and Denominator2 <>''
UNION
select distinct Denominator3 AS Basemeasure from   [MS].[MetricMasterDailyDump]  where Denominator3 is not null and Denominator3 <>''
UNION
select distinct Denominator4 AS Basemeasure from   [MS].[MetricMasterDailyDump] where Denominator4 is not null and Denominator4 <>'') AS A


--drop table #BaseMeasureMasterTemp
--truncate table  MAS.Mainspring_BaseMeasure_Master
--select * from MAS.Mainspring_BaseMeasure_Master

--5) Basemeasure for Custom
insert into [MS].[MAS_BaseMeasure_Master]
select DISTINCT Ltrim(Rtrim(MD.DN_METRICNAME)),3,UOM.UOMID,0 from [MS].[MetricstagingDailyDump] MD
INNER JOIN [MS].[MAS_UOM_Master] UOM ON Ltrim(Rtrim(UOM.UOM_DESC))=MD.DN_UOM
where MD.DN_MANDATORY ='Custom' and Ltrim(Rtrim(MD.DN_METRICNAME)) not in (select Ltrim(Rtrim(BaseMeasureName)) FROM [MS].[MAS_BaseMeasure_Master])
and MD.DN_METRICNAME <> ''

insert into [MS].[MAS_BaseMeasure_Master]
select DISTINCT Ltrim(Rtrim(MD.DN_METRICNAME)),3,UOM.UOMID,0 from [MS].[MetricstagingDailyDump] MD
INNER JOIN [MS].[MAS_UOM_Master] UOM ON Ltrim(Rtrim(UOM.UOM_DESC))=MD.DN_UOM
where MD.DN_MANDATORY ='Custom' and MD.DN_METRICNAME <> ''
EXCEPT
SELECT  Ltrim(Rtrim(BaseMeasureName)),3,UOMID,0 FROM MS.MAS_BaseMeasure_Master 
--insert into MAS.Mainspring_BaseMeasure_Master
--Select Basemeasure,2,10,0 from #BaseMeasureMasterTemp MD 
--INNER JOIN MAS.Mainspring_UOM_Master UOM ON Ltrim(Rtrim(UOM.UOMID))=MD.
--where Ltrim(Rtrim(Basemeasure)) not in (Select distinct Ltrim(Rtrim(BaseMeasureName)) from MAS.Mainspring_BaseMeasure_Master)

--Newly Added for Metrics Master

-- 6)Mainspring_serviceOffering2_Master
--INSERT INTO MAS.Mainspring_serviceOffering2_Master
--select distinct Ltrim(Rtrim(DN_SERVICEOFFERINGLEVEL2)),0 from Mainspring_MetricstagingDailyDump 
--where Ltrim(Rtrim(DN_SERVICEOFFERINGLEVEL2)) not in (Select Ltrim(Rtrim(ServiceOfferingDESC)) from MAS.Mainspring_serviceOffering2_Master)

--7)Servicemapping will be done manually.since it has dependency on SPM screen anlong with category.

--8)Priority
 
INSERT INTO [MS].[MAS_Priority_Master]
select DISTINCT ltrim(rtrim([Value])) as MainspringPriorityName,0 from [MS].[CTS_AVM_PROJECTPRIORITY_VIEW]
where ltrim(rtrim([Value])) not in(select MainspringPriorityName from [MS].[MAS_Priority_Master])

 Insert into [MS].[MAP_ProjectPriority_Mapping]   
  select DISTINCT MP.ProjectCode,PM.mainspringpriorityid,0 from [MS].[CTS_AVM_PROJECTPRIORITY_VIEW] MP
 INNER JOIN [MS].[MAS_Priority_Master] PM ON PM.mainspringpriorityName=MP.Value
 EXCEPT
 Select ESAProjectID,PriorityID,0 from [MS].[MAP_ProjectPriority_Mapping]
  


 Update B 
 SET B.IsDeleted=1
FROM [MS].[MAP_ProjectPriority_Mapping] B
 INNER JOIN [MS].[CTS_AVM_PROJECTPRIORITY_VIEW] MP ON MP.ProjectCode=B.ESAProjectID

 
Update A 
SET A.IsDeleted=0
 from [MS].[MAP_ProjectPriority_Mapping]  A
INNER JOIN [MS].[CTS_AVM_PROJECTPRIORITY_VIEW] MP ON MP.ProjectCode=A.ESAProjectID
 INNER JOIN [MS].[MAS_Priority_Master] PM ON PM.mainspringpriorityName=MP.Value AND PM.MainspringPriorityID=A.PriorityID
 

 --9)SUPPORTCATEGORY
	INSERT INTO [MS].[MAS_SUPPORTCATEGORY_Master]
	select distinct LEFT (value, 200),0 from [MS].[CTS_AVM_PROJECTSUPPORTCATEGORY_VIEW]
	where ltrim(rtrim([Value])) not in(select MainspringSUPPORTCATEGORYName from [MS].[MAS_SUPPORTCATEGORY_Master])
--select * from MAS.Mainspring_SUPPORTCATEGORY_Master
--select * from MAS.Mainspring_SUPPORTCATEGORY_Master
INSERT INTO [MS].[MAP_ProjectSUPPORTCATEGORY_Mapping]
select MP.ProjectCode,PM.MainspringSUPPORTCATEGORYID,0 from [MS].[CTS_AVM_PROJECTSUPPORTCATEGORY_VIEW] MP
INNER JOIN [MS].[MAS_SUPPORTCATEGORY_Master] PM ON PM.MainspringSUPPORTCATEGORYName= LEFT (MP.Value, 200)
EXCEPT 
SELECT Esaprojectid,SUPPORTCATEGORYID,0 from [MS].[MAP_ProjectSUPPORTCATEGORY_Mapping]


Update B 
 SET B.IsDeleted=1
 FROM [MS].[MAP_ProjectSUPPORTCATEGORY_Mapping] B
 INNER JOIN [MS].[CTS_AVM_PROJECTSUPPORTCATEGORY_VIEW] MP ON MP.ProjectCode=B.ESAProjectID

 
Update A 
SET A.IsDeleted=0
 from [MS].[MAP_ProjectSUPPORTCATEGORY_Mapping] A
INNER JOIN [MS].[CTS_AVM_PROJECTSUPPORTCATEGORY_VIEW] MP ON MP.ProjectCode=A.ESAProjectID
INNER JOIN [MS].[MAS_SUPPORTCATEGORY_Master] PM ON PM.MainspringSUPPORTCATEGORYName=LEFT (MP.Value, 200)
 AND PM.MainspringSUPPORTCATEGORYID=A.SUPPORTCATEGORYID
 





--select * from [dbo].[Mainspring_CTS_CTS_AVM_PROJECTSUPPORTCATEGORY_VIEW] 
--select * from MAS.Mainspring_SUPPORTCATEGORY_Master
--10) MAS.Mainspring_TechnologyLanguage_Master



 INSERT INTO [MS].[MAS_TechnologyLanguage_Master]
select Technologyname,LanguageName,'HL',0 from [MS].[CTS_AVM_PTLS_LANGUAGE_MAPPING_VIEW] 
where ltrim(Rtrim(Technologyname))  not in(select Ltrim(Rtrim(mainspringTechnologyname)) FROM  [MS].[MAS_TechnologyLanguage_Master])


--select *  FROM [dbo].[Mainspring_CTS_AVM_PTLS_LANGUAGE_MAPPING_VIEW] 
--select *  FROM  MAS.Mainspring_TechnologyLanguage_Master

Update  [MS].[MAS_TechnologyLanguage_Master]
 set TechnologyLanguageNameShortDESC='--None--',
 mainspringTechnologyname='--None--'
 where mainspringTechnologyname in( select Technologyname from  [MS].[CTS_AVM_PTLS_LANGUAGE_MAPPING_VIEW] 
 where languagename = '--None--')


Update  [MS].[MAS_TechnologyLanguage_Master]
 set TechnologyLanguageNameShortDESC='LL',
 mainspringTechnologyname='Low Level'
 where mainspringTechnologyname in( select Technologyname from  [MS].[CTS_AVM_PTLS_LANGUAGE_MAPPING_VIEW] 
 where languagename = 'Low Level')
  
   DELETE FROM [MS].[MAS_TechnologyLanguage_Master] where MainspringTechnologyName='--None--'
  DELETE FROM [MS].[MAS_TechnologyLanguage_Master] where MainspringTechnologyName='Low Level'

-- select * from MAS.MainspringTechnologyType
--select * from  MAS.Mainspring_TechnologyLanguage_Master
--select * from MAp.Mainspring_serviceOffering2withService_Mapping

--STEP 11) Service Basemeasure Mapping

Select A.* into #ServiceBasemeasuretemp from 
(select distinct Numerator1 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName from   [MS].[MetricMasterDailyDump] where Numerator1 is not null and Numerator1 <>''
UNION 
select distinct Numerator2 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName from   [MS].[MetricMasterDailyDump]  where Numerator2 is not null  and Numerator2 <>''
UNION
select distinct Numerator3 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName from   [MS].[MetricMasterDailyDump] where Numerator3 is not null  and Numerator3 <>''
UNION
select distinct Numerator4 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName from   [MS].[MetricMasterDailyDump] where Numerator4 is not null and Numerator4 <>''
UNION
select distinct Denominator1 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName from   [MS].[MetricMasterDailyDump] where Denominator1 is not null and Denominator1 <>''
UNION
select distinct Denominator2 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName from   [MS].[MetricMasterDailyDump] where Denominator2 is not null and Denominator2 <>''
UNION
select distinct Denominator3 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName from   [MS].[MetricMasterDailyDump]  where Denominator3 is not null and Denominator3 <>''
UNION
select distinct Denominator4 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName from   [MS].[MetricMasterDailyDump] where Denominator4 is not null and Denominator4 <>''
UNION 
select DISTINCT Ltrim(Rtrim(DN_METRICNAME)) AS Basemeasure,(DN_SERVICEOFFERINGLEVEL3)AS ServiceName from [MS].[MetricstagingDailyDump] where DN_MANDATORY ='Custom'

) AS A
Order by A.ServiceName

SELECT ServiceID,ServiceName,ServiceType,ServiceLevelID,MainspringServiceName INTO #TK_MAS_Service 
FROM [AVL].[TK_MAS_Service]

UPDATE #TK_MAS_Service SET ServiceName =MainspringServiceName WHERE MainspringServiceName IS NOT NULL

select S.* into #servicemastertemp from 
(Select serviceid,servicename from #TK_MAS_Service where servicetype=4) AS S

select B.* into #basemeasureTemp FROM
(select BaseMeasureID,BaseMeasureName from [MS].[MAS_BaseMeasure_Master]) AS B

--select * from #ServiceBasemeasuretemp
--select * from #servicemastertemp
--select * from #basemeasureTemp
--select * from    [MS].[MetricMasterDailyDump]

INSERT INTO [MS].[MAP_ServiceBaseMeasure_Mapping]
select SM.ServiceID,BMT.BaseMeasureID,0 from #ServiceBasemeasuretemp BM
INNER JOIN #servicemastertemp SM ON SM.servicename=BM.servicename
INNER JOIN #basemeasureTemp BMT on BMT.BaseMeasureName=BM.Basemeasure
EXCEPT 
select BM.ServiceID, BM.BaseMeasureID,0 from [MS].[MAP_ServiceBaseMeasure_Mapping] BM
INNER JOIN #servicemastertemp SM ON SM.serviceid=BM.ServiceID
INNER JOIN #basemeasureTemp BMT on BMT.BaseMeasureID=BM.BaseMeasureID


--STEP 12) Service Metric Basemeasure Mapping

--Drop table #ServiceMetricBasemeasuretemp
Select A.* into #ServiceMetricBasemeasuretemp from 

(select distinct Numerator1 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName,Ltrim(Rtrim(MetricName)) AS MetricName ,1 AS Position from   [MS].[MetricMasterDailyDump] where Numerator1 is not null and Numerator1 <>''
UNION 
select distinct Numerator2 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName,Ltrim(Rtrim(MetricName)) AS MetricName,2 AS Position  from   [MS].[MetricMasterDailyDump]  where Numerator2 is not null  and Numerator2 <>''
UNION
select distinct Numerator3 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName,Ltrim(Rtrim(MetricName)) AS MetricName,3 AS Position  from   [MS].[MetricMasterDailyDump] where Numerator3 is not null  and Numerator3 <>''
UNION
select distinct Numerator4 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName,Ltrim(Rtrim(MetricName)) AS MetricName,4 AS Position  from   [MS].[MetricMasterDailyDump] where Numerator4 is not null and Numerator4 <>''
UNION
select distinct Denominator1 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName,Ltrim(Rtrim(MetricName)) AS MetricName,11 AS Position  from   [MS].[MetricMasterDailyDump] where Denominator1 is not null and Denominator1 <>''
UNION
select distinct Denominator2 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName,Ltrim(Rtrim(MetricName)) AS MetricName,12 AS Position  from   [MS].[MetricMasterDailyDump] where Denominator2 is not null and Denominator2 <>''
UNION
select distinct Denominator3 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName,Ltrim(Rtrim(MetricName)) AS MetricName,13 AS Position  from   [MS].[MetricMasterDailyDump]  where Denominator3 is not null and Denominator3 <>''
UNION
select distinct Denominator4 AS Basemeasure,Ltrim(Rtrim(ServiceOffering3)) AS ServiceName,Ltrim(Rtrim(MetricName)) AS MetricName,14 AS Position  from   [MS].[MetricMasterDailyDump] where Denominator4 is not null and Denominator4 <>''
UNION 
select DISTINCT Ltrim(Rtrim(DN_METRICNAME)) AS Basemeasure,(DN_SERVICEOFFERINGLEVEL3)AS ServiceName,Ltrim(Rtrim(DN_METRICNAME)) AS MetricName,21 AS Position from [MS].[MetricstagingDailyDump] where DN_MANDATORY ='Custom'

) AS A
Order by A.ServiceName,A.MetricName
--Drop table #servicemastertemp
--select * from #ServiceMetricBasemeasuretemp

--select S.* into #servicemastertemp from 
--(Select serviceid,servicename from MAS.ServiceMaster where servicetype='MPS') AS S

--drop table #basemeasurewithtypeTemp
select B.* into #basemeasurewithtypeTemp FROM
(select BaseMeasureID,BaseMeasureName,BaseMeasureTypeID from [MS].[MAS_BaseMeasure_Master]) AS B
--drop table #MetricMastertemp
select M.* into #MetricMastertemp FROM
(select MetricID,MetricName from [MS].[MAS_Metric_Master]) AS M

Insert Into  [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping]
select SM.ServiceID,MM.MetricID ,BMT.BaseMeasureID,BM.Position,0,0 from #ServiceMetricBasemeasuretemp BM
INNER JOIN #servicemastertemp SM ON Ltrim(Rtrim(SM.servicename))=Ltrim(Rtrim(BM.servicename))
INNER JOIN  #MetricMastertemp  MM ON Ltrim(Rtrim(MM.MetricName))=Ltrim(Rtrim(BM.MetricName))
INNER JOIN #basemeasurewithtypeTemp BMT on Ltrim(Rtrim(BMT.BaseMeasureName))=Ltrim(Rtrim(BM.Basemeasure))
where BM.Position=21
EXCEPT 
select BM.ServiceID,BM.MetricID,BM.BaseMeasureID,BM.PositionID,0,0 from [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping] BM
INNER JOIN #servicemastertemp SM ON SM.serviceid=BM.ServiceID
INNER JOIN  #MetricMastertemp  MM ON MM.MetricID=BM.MetricID
INNER JOIN #basemeasurewithtypeTemp BMT on BMT.BaseMeasureID=BM.BaseMeasureID
--select * from MAP.Mainspring_ServiceMetricBaseMeasureForStandardMetric_Mapping where ServiceID=1
--select SM.ServiceID,MM.MetricID ,BMT.BaseMeasureID,BM.Position,BMT.BaseMeasureTypeID,0 from #ServiceMetricBasemeasuretemp BM
--INNER JOIN #servicemastertemp SM ON Ltrim(Rtrim(SM.servicename))=Ltrim(Rtrim(BM.servicename))
--INNER JOIN  #MetricMastertemp  MM ON Ltrim(Rtrim(MM.MetricName))=Ltrim(Rtrim(BM.MetricName))
--INNER JOIN #basemeasurewithtypeTemp BMT on Ltrim(Rtrim(BMT.BaseMeasureName))=Ltrim(Rtrim(BM.Basemeasure))
--EXCEPT 
--select BM.ServiceID,BM.MetricID,BM.BaseMeasureID,BM.PositionID,BMT.BaseMeasureTypeID,0 from MAP.Mainspring_ServiceMetricBaseMeasureForStandardMetric_Mapping BM
--INNER JOIN #servicemastertemp SM ON SM.serviceid=BM.ServiceID
--INNER JOIN  #MetricMastertemp  MM ON MM.MetricID=BM.MetricID
--INNER JOIN #basemeasurewithtypeTemp BMT on BMT.BaseMeasureID=BM.BaseMeasureID
--select * from MAP.Mainspring_ServiceMetricBaseMeasureForStandardMetric_Mapping where BaseMeasureID=0
--select * from MAS.Mainspring_BaseMeasure_Master
--select * from  Mainspring_MetricstagingDailyDump
--select distinct metricname 
--select * from MAP.Mainspring_ServiceBaseMeasure_Mapping
--select * from trn.AVMDARTtoMainspring_ProjectOutBoundDataDaily



UPDATE SBM
set SBM.servicewisebasemeasuretypeID=BM.BaseMeasureTypeID
from [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping] SBM
INNER JOIN [MS].[MAS_BaseMeasure_Master] BM on BM.BaseMeasureID=SBM.BaseMeasureID  where serviceID not in(13,5,6,2,8,14,16)

Update [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping]
set servicewisebasemeasuretypeID=2
where serviceID in(13,5,6,2,8,14,16)

Update [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping]
set servicewisebasemeasuretypeID=2
where positionID in(21)

UPDATE  [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping]
set servicewisebasemeasuretypeID=1
where ServiceMetricBaseMeasureMapID=133

SELECT CustomTbl.* INTO #CustomTblTemp FROM (select SM.ServiceID,BM.BaseMeasureID,MM.MetricID,sd.DN_UNIQUEKEY from [MS].[MetricstagingDailyDump] SD
INNER JOIN [MS].[MAS_UOM_Master] UM ON LTRIM(RTRIM(UM.UOM_DESC))=LTRIM(RTRIM(SD.DN_UOM))
INNER JOIN #TK_MAS_Service SM ON SM.servicetype=4 and LTRIM(RTRIM(SM.ServiceName))=LTRIM(RTRIM(SD.DN_SERVICEOFFERINGLEVEL3))
INNER JOIN [MS].[MAS_BaseMeasure_Master] BM ON LTRIM(RTRIM(BM.BaseMeasureName))=LTRIM(RTRIM(SD.DN_METRICNAME)) AND UM.UOMID=BM.UOMID
INNER JOIN [MS].[MAS_Metric_Master] MM ON LTRIM(RTRIM(MM.MetricName))=LTRIM(RTRIM(SD.DN_METRICNAME)) and MM.MetricTypeID=2  AND UM.UOMID=MM.UOMID
WHERE DN_Mandatory='Custom') AS CustomTbl

Update [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping]
set IsDeleted=1
where positionid=21

Update A 
set A.IsDeleted=0
From [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping] A
INNER JOIN #CustomTblTemp CM ON CM.ServiceID=A.ServiceID AND CM.BaseMeasureID=A.BaseMeasureID  AND CM.MetricID=A.MetricID
WHERE A.PositionID=21


Update [MS].[MAP_ServiceBaseMeasure_Mapping]
set IsDeleted=1
where BaseMeasureID in(

select BaseMeasureID from [MS].[MAS_BaseMeasure_Master] where BaseMeasureName in(
select LTRIM(RTRIM(MetricName)) FROM [MS].[MAS_Metric_Master] WHERE MetricTypeID=2
))
 
Update M
set IsDeleted=0 
FROM  [MS].[MAP_ServiceBaseMeasure_Mapping] M
Inner JOIN  #CustomTblTemp B ON B.ServiceID=M.ServiceID AND B.BaseMeasureID=M.BaseMeasureID


--select * from  MAP.Mainspring_ServiceMetricBaseMeasureForStandardMetric_Mapping where ServiceMetricBaseMeasureMapID=133





--Step 13) project specific data on staging

--select * from MAP.Mainspring_ServiceMetricBaseMeasureForStandardMetric_Mapping
--select top 1 ESAProjectID,ProjectID,M_PRIORITYID,M_SUPPORTCATEGORY,M_TECHNOLOGY 
Select EX.* into #ExistingservicepprojectmappingTemp  from (
select  SMB.ServiceMetricBasemeasureMapID ,SM.serviceid,SM.serviceName,MM.MetricID,MM.MetricName,SMB.BaseMeasureID,BMT.BaseMeasureName
from [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping]  SMB 
INNER JOIN [MS].[MAP_ProjectStage_Mapping] PSM ON psm.ServiceMetricBasemeasureMapID=SMB.ServiceMetricBasemeasureMapID
INNER JOIN #servicemastertemp SM ON SM.serviceid=SMB.ServiceID
INNER JOIN  #MetricMastertemp  MM ON MM.MetricID=SMB.MetricID
INNER JOIN #basemeasurewithtypeTemp BMT on BMT.BaseMeasureID=SMB.BaseMeasureID) AS EX



Select EX.* into #ExistingservicepprojectmappingTempActual  from (
select  SMB.ServiceMetricBasemeasureMapID ,SM.serviceid,SM.serviceName,MM.MetricID,MM.MetricName,SMB.BaseMeasureID,BMT.BaseMeasureName
from [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping]  SMB 
--INNER JOIN MAP.Mainspring_ProjectStage_Mapping PSM ON psm.ServiceMetricBasemeasureMapID=SMB.ServiceMetricBasemeasureMapID
INNER JOIN #servicemastertemp SM ON SM.serviceid=SMB.ServiceID
INNER JOIN  #MetricMastertemp  MM ON MM.MetricID=SMB.MetricID
INNER JOIN #basemeasurewithtypeTemp BMT on BMT.BaseMeasureID=SMB.BaseMeasureID) AS EX

--select * from #ExistingservicepprojectmappingTempActual
--Here technology is HL or HL not ID
--select * from MAP.Mainspring_ProjectStage_Mapping

--
--select * from  
--update 
--Mainspring_MetricstagingDailyDump
--set DN_Uniquekey='CCC' where DN_PROJECTID='1000035237' and DN_METRICNAME='Mean Time Between Failures'
--select * from Mainspring_MetricstagingDailyDump where DN_PROJECTID='COG_001119Porject1'

--update Mainspring_MetricstagingDailyDump
--set DN_PROJECTID='1000107417'
--where DN_PROJECTID = 'COG_001119Porject1'

--update Mainspring_MetricMasterDailyDump_Ticketsummary
--set DN_PROJECTID='1000107417'
--where DN_PROJECTID = 'COG_001119Porject1'

--update TRN.AVMDARTtoMainspring_ProjectOutBoundData_Monthly
--set PROJECTID='COG_001119Porject1'
--where PROJECTID = '1000107417'

--update TRN.AVMDARTtoMainspring_ProjectOutBoundData_Monthly_TicketSummary
--set PROJECTID='COG_001119Porject1'
--where PROJECTID = '1000107417'

--update Mainspring_MetricstagingDailyDump
--set DN_PRIORITY=NULL
--where DN_PRIORITY='NA'

--update Mainspring_MetricstagingDailyDump
--set DN_SUPPORTCATEGORY=NULL
--where DN_SUPPORTCATEGORY='NA'


--update Mainspring_MetricstagingDailyDump
--set DN_TECHNOLOGY=NULL
--where DN_TECHNOLOGY='NA'

--select * from MAP.Mainspring_ProjectStage_Mapping 
--select * from map.Mainspring_ServiceMetricBaseMeasureForStandardMetric_Mapping
--select * from mas.Mainspring_Metric_Master
--select * from MAP.Mainspring_ProjectStage_Mapping 

--select * from MAP.Mainspring_ServiceMetricBaseMeasureForStandardMetric_Mapping 
--select * from Mainspring_MetricstagingDailyDump
--select * from MAP.Mainspring_ProjectStage_Mapping where ESAProjectID in('1000019604','1000020649')1000019604
Insert into [MS].[MAP_ProjectStage_Mapping] 
Select distinct MD.DN_UNIQUEKEY, MD.DN_PROJECTID AS ESAProjectID,PM.ProjectID,sp.ServiceMetricBasemeasureMapID,MPM.MainspringPriorityID,MSC.MainspringSUPPORTCATEGORYID,MD.DN_TECHNOLOGY,0,NULL,NULL
from  [MS].[MetricstagingDailyDump] MD
INNER JOIN  #ExistingservicepprojectmappingTempActual SP ON SP.servicename=MD.DN_SERVICEOFFERINGLEVEL3 and sp.metricname=Md.DN_METRICNAME
Inner Join AVL.MAS_ProjectMaster PM ON PM.EsaProjectID =MD.DN_PROJECTID and PM.IsMainSpringConfigured='Y'  
Left JOIN [MS].[MAS_Priority_Master]  MPM ON MPM.MainspringPriorityName=MD.DN_PRIORITY
Left JOIN [MS].[MAS_SUPPORTCATEGORY_Master] MSC ON MSC.MainspringSUPPORTCATEGORYName=MD.DN_SUPPORTCATEGORY
Left JOIN [MS].[MAS_TechnologyLanguage_Master] TLM ON TLM.MainspringTechnologyLanguageName=MD.DN_TECHNOLOGY
WHERE MD.DN_MANDATORY in('Custom','Standard')
EXCEPT 
Select distinct PS.UniqueName, PS.ESAProjectID,PS.ProjectID,SMB.ServiceMetricBasemeasureMapID,PS.M_PRIORITYID,Ps.M_SUPPORTCATEGORY,ps.M_TECHNOLOGY,0,NULL,NULL
 from [MS].[MAP_ProjectStage_Mapping] PS
INNER JOIN [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping]  SMB ON SMB.ServiceMetricBasemeasureMapID=ps.ServiceMetricBasemeasureMapID
INNER JOIN #ExistingservicepprojectmappingTemp SP ON SP.serviceID=SMB.ServiceID and sp.MetricID=SMB.metricid
Inner Join AVL.MAS_ProjectMaster PM ON PM.EsaProjectID = ps.ESAProjectID and PM.IsMainSpringConfigured='Y' 
Left JOIN [MS].[MAS_Priority_Master]  MPM ON MPM.MainspringPriorityID=PS.M_PRIORITYID
Left JOIN [MS].[MAS_SUPPORTCATEGORY_Master] MSC ON MSC.MainspringSUPPORTCATEGORYID=Ps.M_SUPPORTCATEGORY
Left JOIN [MS].[MAS_TechnologyLanguage_Master] TLM ON TLM.MainspringTechnologyLanguageName = ps.M_TECHNOLOGY



--select DN_UNIQUEKEY,* from Mainspring_MetricstagingDailyDump where DN_PROJECTID='1000035237'
---step 14 to update the isdeleted column =0 for available records.

Select EX.* into #ExistingservicepprojectmappingTempNew  from (
select  SMB.ServiceMetricBasemeasureMapID ,SM.serviceid,SM.serviceName,MM.MetricID,MM.MetricName,SMB.BaseMeasureID,BMT.BaseMeasureName
from [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping]  SMB 
INNER JOIN [MS].[MAP_ProjectStage_Mapping] PSM ON psm.ServiceMetricBasemeasureMapID=SMB.ServiceMetricBasemeasureMapID
INNER JOIN #servicemastertemp SM ON SM.serviceid=SMB.ServiceID
INNER JOIN  #MetricMastertemp  MM ON MM.MetricID=SMB.MetricID
INNER JOIN #basemeasurewithtypeTemp BMT on BMT.BaseMeasureID=SMB.BaseMeasureID) AS EX


Update [MS].[MAP_ProjectStage_Mapping]
Set IsDeleted=1

Select distinct MD.DN_UNIQUEKEY,Md.DN_PROJECTID AS ESAProjectID,PM.ProjectID AS ProjectID,MSC.MainspringSUPPORTCATEGORYID,MPM.MainspringPriorityID,TLM.MainspringTechnologyLanguageName
INTO #Mainspring_MetricstagingDailyDumpOldData
from  [MS].[MetricstagingDailyDump] MD
INNER JOIN #ExistingservicepprojectmappingTempNew SP ON SP.servicename=MD.DN_SERVICEOFFERINGLEVEL3 and sp.metricname=Md.DN_METRICNAME
Inner Join AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.EsaProjectID =MD.DN_PROJECTID and PM.IsMainSpringConfigured='Y'
 --AND ISNULL(PM.IsMigratedFromDART,0)IN(1,2)

Left JOIN [MS].[MAS_Priority_Master](NOLOCK)  MPM ON MPM.MainspringPriorityName=MD.DN_PRIORITY
Left JOIN [MS].[MAS_SUPPORTCATEGORY_Master](NOLOCK) MSC ON MSC.MainspringSUPPORTCATEGORYName=MD.DN_SUPPORTCATEGORY
Left JOIN [MS].[MAS_TechnologyLanguage_Master](NOLOCK) TLM ON TLM.MainspringTechnologyLanguageName=MD.DN_TECHNOLOGY
WHERE MD.DN_MANDATORY in('Custom','Standard')


Update MPM 
SET MPM.IsDeleted=0
 from  [MS].[MAP_ProjectStage_Mapping] MPM
INNER JOIN #Mainspring_MetricstagingDailyDumpOldData TMPM ON TMPM.DN_UNIQUEKEY=MPM.UniqueName AND TMPM.ESAProjectID=MPM.ESAProjectID
AND TMPM.ProjectID=MPM.ProjectID AND 
isnull(TMPM.MainspringSUPPORTCATEGORYID,0)=ISNULL(MPM.M_SUPPORTCATEGORY,0) AND ISNULL(TMPM.MainspringPriorityID,0)=ISNULL(MPM.M_PRIORITYID,0)
AND ISNULL(TMPM.MainspringTechnologyLanguageName,0)=ISNULL(MPM.M_TECHNOLOGY,0)
 

 
 DELETE FROM [MS].[MAP_ProjectStage_Mapping] WHERE IsDeleted=1
	

 
	



Update [MS].[MAP_ProjectStage_Mapping]
set IsDeleted=0
where UniqueName in(
Select distinct MD.DN_UNIQUEKEY
from  [MS].[MetricstagingDailyDump] MD
INNER JOIN #ExistingservicepprojectmappingTemp SP ON SP.servicename=MD.DN_SERVICEOFFERINGLEVEL3 and sp.metricname=Md.DN_METRICNAME
Inner Join AVL.MAS_ProjectMaster PM ON PM.EsaProjectID =MD.DN_PROJECTID and PM.IsMainSpringConfigured='Y' 
 --AND ISNULL(PM.IsMigratedFromDART,0) IN(1,2)
Left JOIN [MS].[MAS_Priority_Master]  MPM ON MPM.MainspringPriorityName=MD.DN_PRIORITY
Left JOIN [MS].[MAS_SUPPORTCATEGORY_Master] MSC ON MSC.MainspringSUPPORTCATEGORYName=MD.DN_SUPPORTCATEGORY
Left JOIN [MS].[MAS_TechnologyLanguage_Master] TLM ON TLM.MainspringTechnologyLanguageName=MD.DN_TECHNOLOGY
WHERE MD.DN_MANDATORY in('Custom','Standard'))


INSERT INTO  [MS].[MAP_ProjectStartDate_Mapping]
Select DISTINCT PM.ProjectID,MS.DN_PROJECTID,MS.DN_PROJECTSTARTDATE,0 from [MS].[MetricstagingDailyDump](NOLOCK) MS 
Inner Join AVL.MAS_ProjectMaster PM ON PM.EsaProjectID = MS.DN_PROJECTID and PM.IsMainSpringConfigured='Y'  
--AND ISNULL(PM.IsMigratedFromDART,0) IN(1,2)
Where MS.DN_PROJECTSTARTDATE is not null
Except
select ProjectID,ESAProjectID,ProjectStartDate,0 from [MS].[MAP_ProjectStartDate_Mapping]

--select * from MAP.Mainspring_ProjectStartDate_Mapping
--STep 15) Ticketsummary BaseMeasure(Value)



select S.* into #servicemasterforTicketsummarytemp from 
(Select serviceid,servicename from #TK_MAS_Service where servicetype=4) AS S
--drop table #ServiceTicketSummaryBaseMapTemp
--select * from #ServiceTicketSummaryBaseMapTemp
Select T.* INTO #ServiceTicketSummaryBaseMapTemp FROM 
(select STM.ServiceTicketBaseMapID,STM.ServiceID,SM.Servicename,STM.TicketSummaryBaseID,TSM.TicketSummaryBaseName 
from [MS].[MAP_ServiceTicketSummaryBase_Mapping] STM
Inner JOIN [MS].[MAS_TicketSummaryBase_Master] TSM ON TSM.TicketSummaryBaseID=STM.TicketSummaryBaseID
INNER JOIN #servicemasterforTicketsummarytemp SM ON SM.ServiceID=STM.ServiceID) AS T


--Select * from   Mainspring_MetricMasterDailyDump_Ticketsummary 
--Select * from map.Mainspring_TicketSummary_Stage_Mapping
INSERT INTO [MS].[MAP_TicketSummary_Stage_Mapping]
Select distinct MD.DN_UNIQUEKEY, MD.DN_PROJECTID AS ESAProjectID,PM.ProjectID,SM.ServiceID,MPM.MainspringPriorityID,MSC.MainspringSUPPORTCATEGORYID,SM.TicketSummaryBaseID,0,null,null
from  [MS].[MetricMasterDailyDump_Ticketsummary] MD
INNER JOIN #ServiceTicketSummaryBaseMapTemp SM ON SM.ServiceName=MD.DN_SERVICEOFFERINGLEVEL3
Inner Join AVL.MAS_ProjectMaster PM ON PM.EsaProjectID =MD.DN_PROJECTID and PM.IsMainSpringConfigured='Y'  
--AND ISNULL(PM.IsMigratedFromDART,0)IN(1,2)
Left JOIN [MS].[MAS_Priority_Master]  MPM ON MPM.MainspringPriorityName=MD.DN_PRIORITY
Left JOIN [MS].[MAS_SUPPORTCATEGORY_Master] MSC ON MSC.MainspringSUPPORTCATEGORYName=MD.DN_SUPPORTCATEGORY
WHERE MD.DN_MANDATORY in('Ticket Summary')
EXCEPT
Select distinct PS.UniqueName, PS.ESAProjectID,PS.ProjectID,PS.ServiceID,PS.M_PRIORITYID,Ps.M_SUPPORTCATEGORY,ps.TicketSummaryBaseID,0,NULL,NULL from 
[MS].[MAP_TicketSummary_Stage_Mapping] PS
INNER JOIN #ServiceTicketSummaryBaseMapTemp SP ON SP.serviceID=PS.ServiceID and SP.TicketSummaryBaseID=PS.TicketSummaryBaseID
Inner Join AVL.MAS_ProjectMaster PM ON PM.EsaProjectID = ps.ESAProjectID and PM.IsMainSpringConfigured='Y' 
 --AND ISNULL(PM.IsMigratedFromDART,0) IN(1,2)
Left JOIN [MS].[MAS_Priority_Master]  MPM ON MPM.MainspringPriorityID=PS.M_PRIORITYID
Left JOIN [MS].[MAS_SUPPORTCATEGORY_Master] MSC ON MSC.MainspringSUPPORTCATEGORYID=Ps.M_SUPPORTCATEGORY

--DELETE from MAP.Mainspring_TicketSummary_Stage_Mapping where ESAProjectID='5555000460'

--select * from  Mainspring_MetricMasterDailyDump_Ticketsummary

Update [MS].[MAP_TicketSummary_Stage_Mapping]
set IsDeleted=0
where UniqueName in(
Select  MD.DN_UNIQUEKEY
from  [MS].[MetricMasterDailyDump_Ticketsummary] MD
INNER JOIN #ServiceTicketSummaryBaseMapTemp SM ON SM.ServiceName=MD.DN_SERVICEOFFERINGLEVEL3
Inner Join AVL.MAS_ProjectMaster PM ON PM.EsaProjectID =MD.DN_PROJECTID and PM.IsMainSpringConfigured='Y'  
--AND ISNULL(PM.IsMigratedFromDART,0) IN(1,2)
Left JOIN [MS].[MAS_Priority_Master]  MPM ON MPM.MainspringPriorityName=MD.DN_PRIORITY
Left JOIN [MS].[MAS_SUPPORTCATEGORY_Master] MSC ON MSC.MainspringSUPPORTCATEGORYName=MD.DN_SUPPORTCATEGORY
WHERE MD.DN_MANDATORY in('Ticket Summary'))


--select * from map.Mainspring_TicketSummary_Stage_Mapping


--SELECT * from #servicemasterforTicketsummarytemp  
            Update [MS].[MAP_ProjectStage_Mapping]

				set IsDeleted=1

				where UniqueName not in(

				Select distinct DN_UNIQUEKEY

				from  [MS].[MetricstagingDailyDump]

				WHERE DN_MANDATORY in('Custom','Standard'))



				--Select distinct * from  Mainspring_MetricstagingDailyDump WHERE DN_MANDATORY in('Custom','Standard')

				--select * from [MS].[MetricMasterDailyDump]

				Update [MS].[MAP_TicketSummary_Stage_Mapping]

				set IsDeleted=1

				where UniqueName not in(

				Select  DN_UNIQUEKEY

				from  [MS].[MetricMasterDailyDump_Ticketsummary]

				WHERE DN_MANDATORY in('Ticket Summary'))




DROP Table #BaseMeasureMasterTemp
Drop table #baseMeasureTemp
Drop table #servicemastertemp
Drop Table #ServiceBasemeasuretemp
Drop Table #MetricMastertemp
DROP table #basemeasurewithtypeTemp
DROP table #ExistingservicepprojectmappingTemp
drop table #ExistingservicepprojectmappingTempActual
DROP table  #ServiceMetricBasemeasuretemp
DROP Table #servicemasterforTicketsummarytemp
drop table #ServiceTicketSummaryBaseMapTemp
DROP table #CustomTblTemp
DROP Table  #Mainspring_MetricstagingDailyDumpOldData

END
