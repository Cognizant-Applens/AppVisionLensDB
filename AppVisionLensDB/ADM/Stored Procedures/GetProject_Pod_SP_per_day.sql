/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ADM].[GetProject_Pod_SP_per_day] 
@BM_MONTH AS INT,
@BM_YEAR AS INT
AS
BEGIN
SET NOCOUNT ON
BEGIN TRY


IF OBJECT_ID('tempdb..#Tempvelocity') IS NOT NULL 
drop table #Tempvelocity
create table #Tempvelocity
(                    
    Projectid int ,                   
    projectname   varchar(max) null,
    ESAProjectID int,    
    Sprintdetailsid int,       
    Sprintname varchar(max) null,    
	BM_month int,
	BM_Year int,
    WorkItemDetailsId int,
	PoDid  int,
    Podname varchar(max) null,
    --podcapacity   decimal(18,2) ,										 
    velocity_committed decimal(18,2),
	Velocity_delivered decimal(18,2),
    Workitemsize decimal(18,2),
    sprint_duration      decimal(18,2) 
);


INSERT INTO #Tempvelocity(Projectid ,projectname,ESAProjectID ,Sprintdetailsid,Sprintname,
BM_month,BM_Year,
WorkItemDetailsId,
PoDid,Podname,--podcapacity,
velocity_committed,Velocity_delivered, Workitemsize,sprint_duration)
select distinct pm.projectid, pm.projectname, pm.esaprojectid,  sd.sprintdetailsid, sd.sprintname,
month(sd.sprintenddate) as 'BM_Month' ,DATEPART(YYYY, sd.sprintenddate) 'BM_Year' ,
wd.WorkItemDetailsId,
sd.PodId, pd.PODName, ---sum(usercapacity) Pod_capacity_perday, 
case 
isnumeric(Estimation_Points) WHEN 1 THEN 
convert(float,replace([Estimation_Points],',','') ) 
else 0
end as velocity_committed,
CASE
    WHEN stat.StatusId = 4  THEN 
		case 
		isnumeric(Estimation_Points) WHEN 1 THEN
		convert(float,replace([Estimation_Points],',','') ) 
		else 0
		end
    ELSE 0
END AS Velocity_delivered,
WorkItemSize,-- DATEDIFF(day, sprintstartdate, sprintenddate) Sprint_duration
   (DATEDIFF(dd, sprintstartdate, sprintenddate) + 1)
  -(DATEDIFF(wk, sprintstartdate, sprintenddate) * 2)
  -(CASE WHEN DATENAME(dw, sprintstartdate) = 'Sunday' THEN 1 ELSE 0 END)
  -(CASE WHEN DATENAME(dw, sprintenddate) = 'Saturday' THEN 1 ELSE 0 END) as Sprint_duration
from   ADM.ALM_TRN_Sprint_Details sd WITH (NOLOCK)
       join ADM.ALM_TRN_WorkItem_Details wd WITH (NOLOCK) on wd.sprintdetailsid = sd.sprintdetailsid
       join PP.ProjectAttributeValues pav WITH (NOLOCK)  on pav.projectid = sd.projectid
       join pp.Project_PODDetails pd WITH (NOLOCK)  on pd.PODDetailID = sd.PodId
      join adm.AssociateAttributes aa WITH (NOLOCK)  on aa.PODDetailID = pd.PODDetailID
       join avl.mas_projectmaster pm WITH (NOLOCK)  on pm.projectid = sd.ProjectID
       join avl.customer c WITH (NOLOCK)  on c.customerid = pm.customerid
       join avl.businessunit b WITH (NOLOCK)  on b.buid = c.BUID
       join PP.ALM_MAP_Status stat WITH (NOLOCK)  on wd.StatusMapId = stat.StatusMapId
       join PP.OperatingModel opm WITH (NOLOCK)  on pm.projectid = opm.ProjectID
          join pp.OplEsaData oed WITH (NOLOCK)  on oed.projectid = pm.ProjectID-- and projectowningunit = 'ADM'
          join dbo.OPLMasterdata omd WITH (NOLOCK) on omd.esa_project_id = pm.esaprojectid and Market_unit <> 'Internal' and omd.billability <> 'Non-Billable'
where 
pav.AttributeValueID in (5,7,8,9,10,11,12,13,14,285)
       and pm.projectid in (select distinct ProjectID from PP.ProjectAttributeValues WITH (NOLOCK) 
	   where AttributeValueID = 52) 
       and Estimation_Points not in('+','-','#','$','.')
	   and pm.isdeleted = 0	 and omd.isdeleted = 0 and oed.isdeleted = 0 and aa.isdeleted =0 and pd.isdeleted = 0
	   and sd.SprintEndDate <= DATEADD(day,-1,DATEADD(MM, DATEDIFF(MM,0,GETDATE()),0))	   
	   and month(sd.SprintEndDate) = @BM_MONTH AND Year(sd.SprintEndDate) = @BM_YEAR
group by pm.projectid, pm.projectname, pm.esaprojectid,  sd.sprintdetailsid, sd.sprintname, 
Month(sd.sprintenddate) ,DATEPART(YYYY, sd.sprintenddate) ,
wd.WorkItemDetailsId,
sd.PodId, pd.PODName,  
Estimation_Points, WorkItemSize, sprintstartdate, sprintenddate , stat.StatusId
order by pm.projectid, sd.SprintDetailsId;

IF OBJECT_ID('tempdb..#capacity') IS NOT NULL 
drop table #capacity
create table #capacity
(                    
    PoDid  int,
   podcapacity   decimal(18,2)	
)


INSERT INTO #capacity(PoDid ,podcapacity)
select aa.poddetailid , sum(isnull(usercapacity,0)) 'podcapacity'  from 
pp.Project_PODDetails pd WITH (NOLOCK)
join adm.AssociateAttributes aa WITH (NOLOCK) on pd.PODDetailID = aa.PODDetailID 
group by aa.poddetailid  


DECLARE @POD_MIN_SIZE INT
DECLARE  @POD_MAX_SIZE INT
DECLARE @SPRINT_DURATION_MAX AS INT = 20 -- 4 weeks * 5 business days
SELECT @POD_MIN_SIZE = min([Min]) from ADM.MAS_PodSize where IsDeleted = 0
SELECT @POD_MAX_SIZE = max([Max])+1 from ADM.MAS_PodSize where IsDeleted = 0


INSERT INTO ADM.Project_Sprint_TRN_SP_Velocity(
Projectid,
Sprintdetailsid,
Month,Year,PoDID,
PoDCapacity,
VelocityCommitted,
VelocityDelivered,
WorkItemSize,
SprintDuration,
BenchmarkVelocity,
NoofResources,
EachResourcesDeliverable,
EachResourcePerDayDeliverable,
Outlier)
SELECT  projectid,sprintdetailsid,BM_Month, BM_year,
tv.podid,podcapacity,
SUM(velocity_committed) AS Velocity_Committed, SUM(Velocity_delivered) AS Velocity_delivered, 
Workitemsize,Sprint_duration, CONVERT(DECIMAL(18,2),(SUM(Velocity_delivered) * Workitemsize)/8) Benchmark_Vel,
CONVERT(DECIMAL(18,2),podcapacity/ 8) Nos_Pod, 
CONVERT(DECIMAL(18,2),(SUM(Velocity_delivered) * Workitemsize)/8) / NULLIF(CONVERT(DECIMAL(18,2),(podcapacity/ 8)),0) 'Each resources deliverable',
(CONVERT(DECIMAL(18,2),(SUM(Velocity_delivered) * Workitemsize)/8) / NULLIF(CONVERT(DECIMAL(18,2),(podcapacity/ 8)),0))/ NULLIF(Sprint_duration,0)
'Each resource per day deliverable',
CASE
    WHEN (CONVERT(DECIMAL(18,2),(SUM(Velocity_delivered) * Workitemsize)/8) / NULLIF(CONVERT(DECIMAL(18,2),(podcapacity/ 8)),0))/ NULLIF(Sprint_duration,0) >=3  THEN 0
	WHEN (CONVERT(DECIMAL(18,2),(SUM(Velocity_delivered) * Workitemsize)/8) / NULLIF(CONVERT(DECIMAL(18,2),(podcapacity/ 8)),0))/ NULLIF(Sprint_duration,0) <=0  THEN 0
	WHEN CONVERT(DECIMAL(18,2),podcapacity/ 8) < @POD_MIN_SIZE  THEN 0
	WHEN CONVERT(DECIMAL(18,2),podcapacity/ 8) >= @POD_MAX_SIZE  THEN 0
	WHEN Sprint_duration > @SPRINT_DURATION_MAX  THEN 0
		ELSE 1
END AS Outlier
FROM #Tempvelocity tv WITH (NOLOCK)
JOIN #capacity c WITH (NOLOCK) ON tv.podid = c.podid
WHERE (podcapacity/ 8) IS NOT NULL 
AND velocity_committed >0  AND Velocity_delivered > 0 AND Workitemsize IS NOT NULL AND Workitemsize >0
AND Sprint_duration> 0 AND podcapacity> 0
GROUP BY  projectid, projectname, esaprojectid,  sprintdetailsid, sprintname, BM_month , BM_Year ,
WorkItemSize,Sprint_duration,tv.podid, Podname, podcapacity
ORDER BY sprintname;


SELECT  [ProjectSprintVelocityID]
      ,[ProjectID]
      ,[SprintDetailsID]
      ,[Month]
      ,[Year]
      ,[PoDID]
      ,[PoDCapacity]
      ,[VelocityCommitted]
      ,[VelocityDelivered]
      ,[WorkItemSize]
      ,[SprintDuration]
      ,[BenchmarkVelocity]
      ,[NoofResources]
      ,[EachResourcesDeliverable]
      ,[EachResourcePerDayDeliverable]
      ,[Outlier]
      ,[IsDeleted]
      ,[CreatedBy]
      ,[CreatedDate]
      ,[ModifiedBy]
      ,[ModifiedDate]
  FROM [ADM].[Project_Sprint_TRN_SP_Velocity]
  WHERE Month = @BM_MONTH AND Year=@BM_YEAR

  INSERT INTO [ADM].[User_Actual_TRN_SP_Velocity](
  [ProjectSprintVelocityID]
  ,UserID
  ,[SP_Delivered]
  )
  SELECT DISTINCT PS.[ProjectSprintVelocityID],aa.UserId,PS.[EachResourcePerDayDeliverable]
  FROM [ADM].[Project_Sprint_TRN_SP_Velocity] PS WITH (NOLOCK)
  JOIN adm.AssociateAttributes aa WITH (NOLOCK) ON PS.PODID = aa.PODDetailID
  WHERE Month = @BM_MONTH AND Year=@BM_YEAR 


END TRY

      BEGIN CATCH
          DECLARE @ErrorMessage VARCHAR(2000);
          SELECT @ErrorMessage = Error_message()
		   EXEC AVL_InsertError '[ADM].[AD_SP_Velocity_BM]', @ErrorMessage,'System',0
      END catch
  END
