                  
                  
                  
CREATE  Procedure [dbo].[Data_Quality_Report]                                     
                    
AS                    
                    
BEGIN                      
         
          
DECLARE @CurrentDate DATE = GETDATE();
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
declare @MonthlyStartdate  DATE;
declare @NextRefreshdate date;


set @MonthlyStartdate= (select StartDate  from  dbo.DQR_Data_History    WHERE ID = 2 )

-- First day of current month
DECLARE @FirstOfCurrentMonth DATE = DATEFROMPARTS(YEAR(@CurrentDate), MONTH(@CurrentDate), 1);

-- Get weekday of CurrentDate
DECLARE @Weekday INT = DATEPART(WEEKDAY, @CurrentDate);

-- Last Friday before current date
DECLARE @LastFriday DATE = DATEADD(DAY, -CASE 
    WHEN @Weekday = 6 THEN 7
    WHEN @Weekday > 6 THEN @Weekday - 6
    ELSE 7 - (6 - @Weekday)
END, @CurrentDate);

IF DAY(@CurrentDate) between 1 and 4

BEGIN

    SET @StartDate = DATEADD(MONTH, -1, @FirstOfCurrentMonth);

    SET @EndDate = EOMONTH(@StartDate);

END

ELSE if DAY(@CurrentDate) >5

BEGIN

    -- Otherwise → pull current month till last Friday

    SET @StartDate = @FirstOfCurrentMonth;

    SET @EndDate = @LastFriday;
	 

END


else if DAY(@CurrentDate) =5 and day(@MonthlyStartdate) != DAY(GETDATE())  and  DATENAME(WEEKDAY, @CurrentDate)  in ('Tuesday','Thursday')

begin


   UPDATE dbo.DQR_Data_History  
    SET  StartDate = Getdate() ,  
        Modifieddate = Getdate()  
    WHERE ID = 2 ;

	Return;

end

else

begin

    SET @StartDate = DATEADD(MONTH, -1, @FirstOfCurrentMonth);

    SET @EndDate = EOMONTH(@StartDate);

UPDATE dbo.DQR_Data_History  
    SET  StartDate = Getdate() ,  
        EndDate = Getdate(),
		Modifieddate = Getdate()  
    WHERE ID = 2 ;

end


if  DAY(@CurrentDate) =5
begin
if DATENAME(WEEKDAY, @CurrentDate)  in ('Wednesday')
set @NextRefreshdate=DATEADD(DAY, 1, GETDATE());
else if DATENAME(WEEKDAY, @CurrentDate)  in ('Friday')
set @NextRefreshdate=DATEADD(DAY, 4, GETDATE());
else if DATENAME(WEEKDAY, @CurrentDate)  in ('Saturday')
set @NextRefreshdate=DATEADD(DAY, 3, GETDATE());
else if DATENAME(WEEKDAY, @CurrentDate)  in ('Sunday')
set @NextRefreshdate=DATEADD(DAY, 2, GETDATE());
else if DATENAME(WEEKDAY, @CurrentDate)  in ('Monday')
set @NextRefreshdate=DATEADD(DAY, 1, GETDATE());
end

if  DAY(@CurrentDate) =4
Begin
if  DATENAME(WEEKDAY, @CurrentDate)  in ('Tuesday')
set @NextRefreshdate=DATEADD(DAY, 1, GETDATE());
else if  DATENAME(WEEKDAY, @CurrentDate)  in ('Thursday')
set @NextRefreshdate=DATEADD(DAY, 1, GETDATE());
end

if  DAY(@CurrentDate) !=4 and DAY(@CurrentDate) !=5
begin 
if  DATENAME(WEEKDAY, @CurrentDate)  in ('Tuesday')
set @NextRefreshdate=DATEADD(DAY, 2, GETDATE());
else if DATENAME(WEEKDAY, @CurrentDate)  in ('Thursday')
set @NextRefreshdate=DATEADD(DAY, 5, GETDATE());
end


-- Final output
SELECT @StartDate AS StartDate, @EndDate AS EndDate;           
    --------------------------------------------
	  UPDATE dbo.DQR_Data_History  
    SET StartDate = @StartDate,  
        EndDate = @EndDate,  
        Modifieddate = Getdate()  
    WHERE ID = 1 ; 

	UPDATE dbo.DQR_Data_History  
    SET  StartDate = @NextRefreshdate ,  
		Modifieddate = Getdate()  
    WHERE ID = 3 ;

  --------------------------------------------------------------------                  
    SET XACT_ABORT ON;                            
                            
 DECLARE @Date datetime = GetDate();                              
 DECLARE @UserName varchar(100) = 'System';                              
 DECLARE @JobName VARCHAR(100)= 'DQR_ProjectLevel';                              
 DECLARE @JobStatusSuccess VARCHAR(100)='Success';                              
 DECLARE @JobStatusFail VARCHAR(100)='Failed';                              
 DECLARE @JobStatusInProgress VARCHAR(100)='InProgress';                           
                       
 DECLARE @LastSuccessDate datetime;                              
 DECLARE @JobId int;                              
 DECLARE @JobStatusId int;                              
 SELECT @JobId = JobID FROM MAS.JobMaster WHERE JobName = @JobName;                     
                  
                  
                     
                         
 DECLARE @MailSubject NVARCHAR(500);                          
 DECLARE @MailBody  NVARCHAR(MAX);                            
 DECLARE @MailContent NVARCHAR(500);                        
 DECLARE @ScriptName  NVARCHAR(100)                        
                              
 SELECT @LastSuccessDate =MAX(StartDateTime) FROM MAS.JobStatus WHERE JobId = @JobId AND JobStatus = @JobStatusSuccess AND IsDeleted = 0;                              
                              
 INSERT INTO MAS.JobStatus (JobId, StartDateTime, EndDateTime, JobStatus, JobRunDate, IsDeleted, CreatedBy, CreatedDate)                               
        VALUES(@JobId, @Date, @Date, @JobStatusInProgress, @Date, 0, @UserName, @Date);                              
 SET @JobStatusId= SCOPE_IDENTITY();                      
                  
                             
 BEGIN TRY                            
 BEGIN TRANSACTION                      
  ---------------------------------------------------------------------------------   
  
SELECT * into #mas_projectmaster
FROM [AVL].mas_projectmaster(NOLOCK) 
WHERE IsDeleted='0' 

--To find status column for eligible project                  
IF OBJECT_ID('tempdb..#ProjectStatus') IS NOT NULL DROP TABLE #ProjectStatus;                  
                  
CREATE TABLE #ProjectStatus(                  
ESAProjectId NVARCHAR(50),                  
Status  NVARCHAR(100))                  
              
insert into #ProjectStatus                  
select DISTINCT ESAProjectId, 'Not onboarded' AS Status                  
from AVL.MAS_ProjectMaster(nolock) pm                  
join ESA.Projects(nolock) p on p.ID=pm.EsaProjectID                  
join avl.customer(nolock) c on c.customerid = pm.customerid                  
where pm.IsCoginzant = 1 and pm.isdeleted = 0                  
and c.isdeleted = 0 and c.iscognizant= 1 and DATEADD(MINUTE,30,DATEADD(HOUR,5,p.ProjectEndDate ))>= DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))                  
                  
IF OBJECT_ID('tempdb..#Exempted') IS NOT NULL DROP TABLE #Exempted;                  
           
SELECT A.AccessLevelID as AccessLevelID                  
,'Applens Onboarding' AS IsApplensExempt                  
,A.RequesterComments                  
,CASE                   
WHEN B.ID IS NULL  THEN 1                  
  ELSE B.ID                  
  END AS ReasonID                  
 ,CASE                   
  WHEN B.ID IS NULL                  
   THEN 'Others'                  
  ELSE Reason                  
  END AS Reason                  
  Into #Exempted                  
FROM [$(SmartGovernanceDB)].[dbo].ApplensExemptionDetails A                  
LEFT JOIN [$(SmartGovernanceDB)].[dbo].ModuleExemptionDetails(NOLOCK) ME ON ME.ApplensExemptionID = A.ID                  
LEFT JOIN [$(SmartGovernanceDB)].[dbo].ExemptionActivityLog EA ON A.AccessLevelID = EA.AccessLevelID                  
 AND EA.ID = (                  
  SELECT MAX(ID)                  
  FROM [$(SmartGovernanceDB)].[dbo].[ExemptionActivityLog]                  
 WHERE AccessLevelID = A.AccessLevelID                  
   AND IsDeleted = 0                  
   AND OptedFor = 'Exemption' AND Status = 'Approved' AND (ModuleID = '1' OR ModuleID = '4')                  
  )                  
LEFT JOIN [$(SmartGovernanceDB)].[MAS].[ExemptionReason] B ON B.ID = (                  
  CASE                   
   WHEN A.ReasonID IS NULL                  
    OR A.ReasonID = 0                  
    THEN EA.ReasonID                  
   ELSE A.ReasonID                  
   END                  
  )                  
 AND (B.ModuleID = '1' OR B.ModuleID = '4')                  
WHERE (A.OptedFor = 'Exemption'  AND A.Status = 'Approved' AND A.CurrentlyExempted = 1 AND A.IsDeleted = 0)                   
OR (ME.ModuleID = 4 AND ME.OptedFor = 'Exemption' AND ME.Status = 'Approved' AND ME.CurrentlyExempted = 1 AND ME.IsDeleted = 0)                  
                  
--select * from #Exempted                  
IF OBJECT_ID('tempdb..#onboarded') IS NOT NULL DROP TABLE #onboarded;                  
                  
select distinct ESAProjectId                   
into #onboarded                  
from avl.prj_configurationProgress cp                  
join AVL.Mas_ProjectMaster pm on pm.ProjectId = cp.ProjectId                  
join avl.customer c on c.customerid = pm.customerid and c.isdeleted = 0                  
where ScreenId = 4 and CompletionPercentage = 100 and cp.Isdeleted = 0 and pm.isdeleted = 0 and c.iscognizant = 1                  
                  
--select * from #onboarded                  
 DELETE FROM #onboarded WHERE ESAProjectID IN (SELECT AccessLevelId FROM #Exempted)                  
                  
UPDATE APL SET APL.Status = 'Exempted'                  
FROM #ProjectStatus APL                   
JOIN #Exempted E on APL.ESAProjectId = E.AccessLevelID                  
                    
UPDATE APL SET APL.Status = 'Onboarded'                  
FROM #ProjectStatus APL                   
JOIN #Onboarded OB on APL.ESAProjectId = OB.EsaProjectId                  
                  
                  
--select * from #ProjectStatus                   
                  
----------------------------------------------------------------------------------------------                  
                  
Merge into   dbo.[DQR Benchmark]  AS DQ                  
Using (select distinct ProjectOwningUnit from  dbo.DQR_oplmasterdata) AS BE                  
ON  (DQ.Project_Owning_Unit=BE.ProjectOwningUnit)                  
WHEN NOT MATCHED THEN                  
INSERT (Project_Owning_Unit,Avg_Ticket_Productivity) Values (ProjectOwningUnit,'68');                  
                  
--select * from  dbo.[DQR Benchmark] where Project_Owning_Unit='ADM Central'                  
          
                  
---------------------------------------------------------                  
DELETE FROM [dbo].[Benchmark_Eligible_Project_List]         
WHERE MONTH([Month])=month(@Startdate) and year(month)=year(@Startdate)                  
-----------------------------------------------------------------------                     


 
 SELECT * into #ADM_OplMasterData_Base1 FROM dbo.DQR_oplmasterdata(NOLOCK) 
WHERE  FinalScope='In Scope' AND [3x3 Matrix] NOT IN  ('[0,0]' ,'[1,1]')                       
AND Archetype='Enhancement and support'              
and WorkCategory like '%Support%' and  WorkCategory not in  ('Infra Support')              
and PracticeArea in ('ADM','EPS','AIA','Digital Engineering','DX Digital Experience')    


INSERT INTO [dbo].[Benchmark_Eligible_Project_List] (              
[Month],              
[ESA_Project_ID],              
[ESA_Project_Name],              
[Mainspring_Project_ID],              
[Execution_Project_Name],              
[ESA_PM_NAME],              
[ESA_PM_ID],              
[Archetype_Cluster],              
[Archetype],              
[Work_Category],              
[Parent_Account],              
[Practice_Area_PBI],              
[Project_Owning_Unit],              
[Industry_Segment],              
[Vertical],              
[Market],              
[Market_Unit],              
[Updated_BU],              
[Updated_SBU],              
[ESA_Project_Country],              
[Project_Owner_ESA_PM_department],              
[Project_Owner_Name],              
[Project_Owner_Id],              
[Delivery_Excellence_POC],              
[Final_Scope],              
[Total_FTE],              
[_3x3_Matrix],              
[Project_Type],              
[Avg_Ticket_Productivity_2023_benchmark],              
[Status],[CreatedDate],[CreatedBy])               
select A.Createddate  as Month,A.ESAProjectID as ESA_Project_iD,A.ESAProjectName AS ESA_Project_Name,Null as  Mainspring_Project_ID,Null as Execution_Project_Name,A.ESA_PM_name,A.ESA_PM_ID,              
A.ArchetypeCluster AS Archetype_Cluster,A.Archetype,A.WorkCategory AS Work_Category,A.ParentAccountName AS Parent_Account,A.Practicearea AS Practice_Area_PBI,              
A.ProjectOwningUnit AS Project_Owning_Unit,A.IndustrySegment AS Industry_Segment,A.Vertical,A.Market,A.MarketUnit AS Market_Unit ,A.BU AS Updated_BU,F.SBU_Delivery as Updated_SBU,A.ESAProjectCountry AS ESA_Project_Country,              
A.[ProjectOwner_ESA_PM_department],A.[ProjectOwnerName] AS [Project_Owner_Name],              
A.[ProjectOwnerId] AS [Project_Owner_Id],A.DeliveryExcellencePOC as Delivery_Excellence_POC,A.FinalScope as Final_Scope,A.TotalFTE as Total_FTE,A.[3x3 Matrix] ,A.[ESA Project Type],              
D.Avg_Ticket_Productivity as [Avg_Ticket_Productivity_2023_benchmark] ,C.Status,GETDATE() ,'DQR Job' as [Createdby]              
--into  #temp1              
from              
#ADM_OplMasterData_Base1 A               
LEFT JOIN #ProjectStatus C on C.esaprojectid=A.ESAProjectID              
left join avl.MAS_ProjectMaster E on E.EsaProjectID=A.ESAProjectID              
LEFT JOIN AVL.Customer G ON G.CustomerID=E.CustomerID              
LEFT JOIN  [dbo].[GeoMapping] F ON F.ESA_AccountID=G.ESA_AccountID    and A.Client_Practice=F.Client_Practice          
left join  dbo.[DQR Benchmark] D ON D.Project_Owning_Unit=A.ProjectOwningUnit         
WHERE((C.Status = 'Onboarded') OR (C.Status <> 'Onboarded' AND TRY_CONVERT(float, TotalFTE) >= 5.0))        


SELECT * into #ADM_OplMasterData_Base2 
FROM dbo.DQR_oplmasterdata(NOLOCK) 
WHERE  FinalScope='In Scope' AND [3x3 Matrix] NOT IN  ('[0,0]' ,'[1,1]')                       
AND Archetype='Enhancement and support'              
and WorkCategory ='Engineering and Manufacturing Applications Management and Support' 
and WorkCategory not in  ('Infra Support')              
and PracticeArea in ('IOT')  


            
INSERT INTO [dbo].[Benchmark_Eligible_Project_List] (              
[Month],              
[ESA_Project_ID],              
[ESA_Project_Name],              
[Mainspring_Project_ID],              
[Execution_Project_Name],              
[ESA_PM_NAME],              
[ESA_PM_ID],         
[Archetype_Cluster],              
[Archetype],              
[Work_Category],              
[Parent_Account],              
[Practice_Area_PBI],              
[Project_Owning_Unit],              
[Industry_Segment],              
[Vertical],              
[Market],              
[Market_Unit],              
[Updated_BU],              
[Updated_SBU],              
[ESA_Project_Country],              
[Project_Owner_ESA_PM_department],              
[Project_Owner_Name],              
[Project_Owner_Id],              
[Delivery_Excellence_POC],              
[Final_Scope],              
[Total_FTE],              
[_3x3_Matrix],              
[Project_Type],              
[Avg_Ticket_Productivity_2023_benchmark],              
[Status],[CreatedDate],[CreatedBy])               
select A.Createddate  as Month,A.ESAProjectID as ESA_Project_iD,A.ESAProjectName AS ESA_Project_Name,Null as  Mainspring_Project_ID,Null as Execution_Project_Name,A.ESA_PM_name,A.ESA_PM_ID,              
A.ArchetypeCluster AS Archetype_Cluster,A.Archetype,A.WorkCategory AS Work_Category,A.ParentAccountName AS Parent_Account,A.Practicearea AS Practice_Area_PBI,              
A.ProjectOwningUnit AS Project_Owning_Unit,A.IndustrySegment AS Industry_Segment,A.Vertical,A.Market,A.MarketUnit AS Market_Unit ,A.BU AS Updated_BU,F.SBU_Delivery as Updated_SBU,A.ESAProjectCountry AS ESA_Project_Country,              
A.[ProjectOwner_ESA_PM_department],A.[ProjectOwnerName] AS [Project_Owner_Name],              
A.[ProjectOwnerId] AS [Project_Owner_Id],A.DeliveryExcellencePOC as Delivery_Excellence_POC,A.FinalScope as Final_Scope,A.TotalFTE as Total_FTE,A.[3x3 Matrix] ,A.[ESA Project Type],              
D.Avg_Ticket_Productivity as [Avg_Ticket_Productivity_2023_benchmark] ,C.Status,GETDATE() ,'DQR Job' as [Createdby]              
--into  #temp1              
from              
#ADM_OplMasterData_Base2 A               
LEFT JOIN #ProjectStatus C on C.esaprojectid=A.ESAProjectID              
left join avl.MAS_ProjectMaster E on E.EsaProjectID=A.ESAProjectID              
LEFT JOIN AVL.Customer G ON G.CustomerID=E.CustomerID              
LEFT JOIN  [dbo].[GeoMapping] F ON F.ESA_AccountID=G.ESA_AccountID  and A.Client_Practice=F.Client_Practice            
left join  dbo.[DQR Benchmark] D ON D.Project_Owning_Unit=A.ProjectOwningUnit              
WHERE((C.Status = 'Onboarded') OR (C.Status <> 'Onboarded' AND TRY_CONVERT(float, TotalFTE) >= 5.0))        
       
            
             
              
              
              
Update   [dbo].[Benchmark_Eligible_Project_List] set Practice_Area_PBI='DE/DX' where Practice_Area_PBI in ('Digital Engineering','DX Digital Experience')                  
                  
  IF OBJECT_ID('tempdb..#Applens_Dashboard_Project_List') IS NOT NULL DROP TABLE #Applens_Dashboard_Project_List;                  
                  
CREATE TABLE  #Applens_Dashboard_Project_List(                  
[Month] [nvarchar](max) NULL,[ESA_Project_ID] [nvarchar](250) NULL,[ESA_Project_Name] [nvarchar](250) NULL,                  
[Mainspring_Project_ID] [nvarchar](250) NULL,[Execution_Project_Name] [nvarchar](250) NULL,[ESA_PM_NAME] [nvarchar](250) NULL,                  
[ESA_PM_ID] [nvarchar](250) NULL,[Archetype_Cluster] [nvarchar](250) NULL,[Archetype] [nvarchar](250) NULL,                  
[Work_Category] [nvarchar](250) NULL,[Parent_Account] [nvarchar](250) NULL,[Practice_Area_PBI] [nvarchar](250) NULL,                  
[Project_Owning_Unit] [nvarchar](250) NULL,[Industry_Segment] [nvarchar](250) NULL,[Vertical] [nvarchar](250) NULL,                  
[Market] [nvarchar](250) NULL,[Market_Unit] [nvarchar](250) NULL,[Updated_BU] [nvarchar](250) NULL,[Updated_SBU] [nvarchar](250) NULL,                  
[ESA_Project_Country] [nvarchar](250) NULL,[Project_Owner_ESA_PM_department] [nvarchar](250) NULL,[Project_Owner_Name] [nvarchar](250) NULL,                  
[Project_Owner_Id] [nvarchar](250) NULL,[Delivery_Excellence_POC] [nvarchar](250) NULL,[Final_Scope] [nvarchar](250) NULL,                  
[Total_FTE] [float] NULL,[_3x3_Matrix] [nvarchar](250) NULL,[Project_Type] [nvarchar](250) NULL,[Avg_Ticket_Productivity_2023_benchmark] [tinyint] NULL,                  
[Status] [nvarchar](250) NULL,[CreatedDate] Datetime ,[CreatedBy] NVARCHAR (50) NULL,                    
)                  
----------------------------------------------------------------------------------- 

SELECT * into #ProjectAssociates
FROM [ESA].[ProjectAssociates](NOLOCK) 
WHERE  PROJECTID IN ( SELECT DISTINCT ESA_Project_ID FROM 
[dbo].[Benchmark_Eligible_Project_List](NOLOCK)
WHERE [Month] BETWEEN @StartDate AND DATEADD(MINUTE, 30, DATEADD(HOUR, 5, GETDATE()))) 

-- Active users: SA - Associates
IF OBJECT_ID('tempdb..#Activeuserslist') IS NOT NULL 
    DROP TABLE #Activeuserslist;

SELECT DISTINCT 
    B.PROJECTID,
    ISNULL(B.ASSOCIATEID, C.ASSOCIATEID) AS AssociateID,
    C.AssociateName,
    B.Dept_Name,
    C.Designation,
    CASE 
        WHEN PATINDEX('%[0-9]%', SUBSTRING(C.Grade, 2, 2)) > 0 
        THEN TRY_CONVERT(CHAR, SUBSTRING(C.Grade, 2, 2))
        ELSE NULL
    END AS Grade
INTO #Activeuserslist
FROM #ProjectAssociates (NOLOCK) B
LEFT JOIN [ESA].[Associates] (NOLOCK) C 
    ON C.ASSOCIATEID = B.ASSOCIATEID
WHERE 
    PATINDEX('%[^0-9]%', SUBSTRING(C.Grade, 2, 2)) = 0
    AND TRY_CONVERT(INT, SUBSTRING(C.Grade, 2, 2)) > 50;


              
-- Drop temporary table if it exists
IF OBJECT_ID('tempdb..#NonESAUsers') IS NOT NULL 
    DROP TABLE #NonESAUsers;

-- Select distinct non-ESA authorized users not in the active users list
SELECT DISTINCT  
    A.ESAProjectID, 
    B.Employeeid, 
    B.isnonesaauthorized,
    B.Employeename 
INTO #NonESAUsers 
FROM avl.mas_loginmaster (NOLOCK) B 
JOIN avl.mas_projectmaster (NOLOCK) A ON B.ProjectID = A.ProjectID 
WHERE 
    B.isnonesaauthorized = '1' AND
    B.isdeleted = '0' AND
    NOT EXISTS (
        SELECT 1 
        FROM #Activeuserslist D 
        WHERE D.ASSOCIATEID = B.Employeeid 
          AND D.PROJECTID = A.ESAProjectID
    );

-- Drop temporary table if it exists
IF OBJECT_ID('tempdb..#allocatedassociates') IS NOT NULL 
    DROP TABLE #allocatedassociates;

-- Select allocated associates from eligible project list and active users
SELECT 
    D.Associateid,
    D.Associatename,
    A.Esa_project_id,
    D.Dept_Name,
    D.Designation,
    D.Grade 
INTO #allocatedassociates 
FROM [dbo].[Benchmark_Eligible_Project_List] (NOLOCK) A 
JOIN #Activeuserslist D ON D.PROJECTID = A.ESA_Project_ID;
              
              
IF OBJECT_ID('tempdb..#nonesaassociates') IS NOT NULL DROP TABLE #nonesaassociates;   

SELECT Employeeid,A.Esa_project_id,c.Employeename  into #nonesaassociates FROM            
[dbo].[Benchmark_Eligible_Project_List](NOLOCK) A            
left join #NonESAUsers c on c.ESAProjectID=a.ESA_Project_ID   

IF OBJECT_ID('tempdb..#FilteredAssociates') IS NOT NULL DROP TABLE #FilteredAssociates;      

--active SA- associates ,Nonesaallocation users                 
SELECT      COALESCE(a.Associateid, b.Employeeid) AS AssociateID,            
COALESCE(a.Associatename, b.Employeename ) AS AssociateName,           
COALESCE(a.Esa_project_id, b.Esa_project_id) AS PROJECTID,    A.Dept_Name,      A.Designation,a.Grade           
into #FilteredAssociates             
FROM #allocatedassociates a FULL OUTER JOIN #nonesaassociates b  
ON a.Esa_project_id = b.Esa_project_id AND a.Associateid = b.Employeeid                  
-----------------------------------------------------------------------------------------------------------                  
INSERT INTO #Applens_Dashboard_Project_List                  
(                  
[Month],[ESA_Project_ID],[ESA_Project_Name],[Mainspring_Project_ID],[Execution_Project_Name],[ESA_PM_NAME],[ESA_PM_ID],                  
[Archetype_Cluster],[Archetype],[Work_Category],[Parent_Account],[Practice_Area_PBI],[Project_Owning_Unit],[Industry_Segment],                  
[Vertical],[Market],[Market_Unit],[Updated_BU],[Updated_SBU],[ESA_Project_Country],[Project_Owner_ESA_PM_department],                  
[Project_Owner_Name],[Project_Owner_Id],[Delivery_Excellence_POC],[Final_Scope],[Total_FTE],[_3x3_Matrix],[Project_Type],                  
[Avg_Ticket_Productivity_2023_benchmark],[Status],[CreatedDate],[CreatedBy]                  
)                  
SELECT format(DATEADD(month, DATEDIFF(month, 0, Month), 0),'MM-yyyy') as Month,ESA_Project_ID,                  
ESA_Project_Name,Mainspring_Project_ID,Execution_Project_Name,ESA_PM_NAME,ESA_PM_ID,Archetype_Cluster,Archetype,Work_Category,                  
Parent_Account,Practice_Area_PBI,Project_Owning_Unit,Industry_Segment,Vertical,Market,Market_Unit,                  
Updated_BU,Updated_SBU,ESA_Project_Country,Project_Owner_ESA_PM_department,Project_Owner_Name,Project_Owner_Id,Delivery_Excellence_POC,                  
Final_Scope,Total_FTE,_3x3_Matrix,Project_Type,Avg_Ticket_Productivity_2023_benchmark,status,[CreatedDate],[CreatedBy]                  
--into #Applens_Dashboard_Project_List                  
FROM  [dbo].[Benchmark_Eligible_Project_List](NOLOCK)      
 WHERE CONVERT(DATE,MONTH) >= @Startdate        



select * into #ApplensCurrentMonthTimesheet 
from [AVL].[TM_PRJ_Timesheet](NOLOCK)
where TimesheetDate between @Startdate and @Enddate  


SELECT * into #TimesheetDetail
FROM [AVL].[TM_TRN_TimesheetDetail](NOLOCK) 
WHERE IsDeleted='0'and SERVICEID IN (1,3,4,7,10,11)  

---------------------------------------------------------------------------------------------------------                  
-----Total MPS Effort from Applens                  
  IF OBJECT_ID('tempdb..#ApplensTimesheetdetail') IS NOT NULL DROP TABLE #ApplensTimesheetdetail;                  
  IF OBJECT_ID('tempdb..#Total_MPS_Effort_From_Applens') IS NOT NULL DROP TABLE #Total_MPS_Effort_From_Applens;                  
                  
                  
select distinct C.EsaProjectID ,A.ProjectId,sum(B.Hours) as  Total_MPS_Effort_From_Applens,                  
format(DATEADD(month, DATEDIFF(month, 0, TimesheetDate), 0),'MM-yyyy') AS Month                  
INTO #ApplensTimesheetdetail                  
from #ApplensCurrentMonthTimesheet (NOLOCK) A                  
LEFT JOIN #TimesheetDetail(NOLOCK) B ON A.PROJECTID=B.PROJECTID AND A.TimesheetId=B.TimesheetId                  
lEFT join #mas_projectmaster(NOLOCK) C ON C.ProjectID=B.ProjectId                  
left join avl.mas_loginmaster(nolock) D on D.ProjectID=C.projectid and A.Submitterid=D.UserID  --AND D.Isdeleted='0'                  
WHERE D.employeeid in (select AssociateID from #FilteredAssociates  WHERE PROJECTID=C.ESAPROJECTID)    
group by C.EsaProjectID,A.ProjectId,DATEADD(month, DATEDIFF(month, 0, A.TimesheetDate), 0)                  
order by Month desc                  
                  

                  
SELECT ADP.ESA_Project_ID,ADP.MONTH,ATD.Total_MPS_Effort_From_Applens                   
INTO #Total_MPS_Effort_From_Applens                  
FROM #Applens_Dashboard_Project_List ADP LEFT JOIN #ApplensTimesheetdetail ATD                  
ON ADP.ESA_Project_ID=ATD.EsaProjectID AND ADP.MONTH=ATD.Month                  
                  
                  
                  
   
                  
-------------------------------------------------------------------------------------------------------------------------------                  
 
SELECT * into #TimesheetDetail_All
FROM DiscoverEDS.EDS.[TimesheetDetail_All](NOLOCK) 
WHERE TIMESHEETSUBMISSIONDATE BETWEEN @Startdate AND @Enddate
and activitydescription in  ('Problem Management','Incident Management','Service Request Management','Org Change Management','Change & Release Management')   


--Total MPS Effort from ESA                  
  IF OBJECT_ID('tempdb..#EDSTimesheetdetail') IS NOT NULL DROP TABLE #EDSTimesheetdetail;                  
  IF OBJECT_ID('tempdb..#Total_MPS_Effort_from_ESA') IS NOT NULL DROP TABLE #Total_MPS_Effort_from_ESA;                  
                  
                  
select format(DATEADD(month, DATEDIFF(month, 0, B.timesheetsubmissiondate), 0),'MM-yyyy') as Month,                  
ESAProjectid,ProjectName,Activitycode,ActivityDescription,Hours,Submitterid,Timesheetstatus,Submitterdate                  
into #EDSTimesheetdetail                  
from #Applens_Dashboard_Project_List A  
LEFT join #TimesheetDetail_All B                  
ON A.ESA_Project_ID=B.ESAPROJECTID AND A.Month=format(DATEADD(month, DATEDIFF(month, 0, B.timesheetsubmissiondate), 0),'MM-yyyy')                  
WHERE  B.Submitterid in (select AssociateID from #FilteredAssociates WHERE PROJECTID=A.ESA_Project_ID)                  
                  
                  
                  
select distinct ESAProjectid,Month,SUM(HOURS) AS Total_MPS_Effort_from_ESA                  
INTO #Total_MPS_Effort_from_ESA                  
from  #EDSTimesheetdetail B                  
GROUP BY  ESAProjectid,Month                  
                  
                  

----------------------------------------------------------------------------------------------------------------                  
                  
--Effort Deviation                  
                  
--drop table #Effort_Deviation                  
IF OBJECT_ID('tempdb..#Effort_Deviation') IS NOT NULL DROP TABLE #Effort_Deviation;                  
create table #Effort_Deviation                  
(                  
ESAPROJECTID nvarchar(250) NULL,                  
[Month] nvarchar(250) NULL,                  
Total_MPS_Effort_From_Applens nvarchar(250) NULL,                  
Total_MPS_Effort_From_ESA nvarchar(250) NULL,                  
Effort_Deviation nvarchar(250) NULL,                  
)                  
                  
INSERT INTO #Effort_Deviation(ESAPROJECTID,Month,Total_MPS_Effort_From_Applens,Total_MPS_Effort_From_ESA,Effort_Deviation)                  
            
SELECT                   
    MA.ESA_Project_ID AS ESAProjectID,                 
    MA.[Month],                  
    ISNULL(TRY_CONVERT(DECIMAL(11, 2), MA.Total_MPS_Effort_From_Applens), 0) AS Total_MPS_Effort_From_Applens,                  
    ISNULL(TRY_CONVERT(DECIMAL(11, 2), ME.Total_MPS_Effort_From_ESA), 0) AS Total_MPS_Effort_From_ESA,                  
    FORMAT(                  
    CASE     WHEN ISNULL(TRY_CONVERT(DECIMAL(11, 2), MA.Total_MPS_Effort_From_Applens), 0) = 0       AND ISNULL(TRY_CONVERT(DECIMAL(11, 2), ME.Total_MPS_Effort_From_ESA), 0) = 0     THEN 0 -- If both efforts are 0, deviation should be 0                   
 
 WHEN MA.Total_MPS_Effort_From_Applens IS NULL        OR ISNULL(TRY_CONVERT(DECIMAL(11, 2), MA.Total_MPS_Effort_From_Applens), 0) = 0        AND ISNULL(TRY_CONVERT(DECIMAL(11, 2), ME.Total_MPS_Effort_From_ESA), 0) > 0      THEN 100                 
-- If Applens effort is missing OR 0, but ESA effort is non-zero, deviation should be 100                   
            ELSE ISNULL(                  
                CAST(           
                    (ISNULL(TRY_CONVERT(DECIMAL(11, 2), MA.Total_MPS_Effort_From_Applens), 0)                   
                    - ISNULL(TRY_CONVERT(DECIMAL(11, 2), ME.Total_MPS_Effort_From_ESA), 0))                   
                AS DECIMAL(11, 2)) /                   
                NULLIF(ISNULL(TRY_CONVERT(DECIMAL(11, 2), MA.Total_MPS_Effort_From_Applens), 0), 0),                   
            0)                   
        END, 'N2') AS Effort_Deviation                  
FROM                   
    #Total_MPS_Effort_From_Applens MA                   
    FULL OUTER JOIN #Total_MPS_Effort_From_ESA ME                  
    ON MA.ESA_Project_ID = ME.ESAProjectID                   
    AND MA.[Month] = ME.[Month]                   
GROUP BY                    
    MA.ESA_Project_ID,                   
    MA.[Month],                  
    MA.Total_MPS_Effort_From_Applens,                  
    ME.Total_MPS_Effort_From_ESA;                  
                  
                  
                  
----------------------------------------------------------------------------------------------------------                  
    SELECT * into #TicketDetail
FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) 
WHERE SERVICEID IN (1,3,4,7,10,11) 
and DATEADD(MINUTE,30,DATEADD(HOUR,5,OpenDateTime)) BETWEEN @StartDate AND @EndDate                  
AND ISDELETED='0' 

----Total Volume from 6 Services in Applens                  
                  
  IF OBJECT_ID('tempdb..#Volume') IS NOT NULL DROP TABLE #Volume;                  
                  
select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0,DATEADD(MINUTE,30,DATEADD(HOUR,5,A.OpenDateTime))), 0),'MM-yyyy') AS Month ,COUNT(Ticketid) AS Volume                  
into #Volume                  
from #TicketDetail(NOLOCK) A                  
LEFT JOIN #mas_projectmaster(NOLOCK) B ON A.PROJECTID=B.PROJECTID                              
GROUP BY B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE,30,DATEADD(HOUR,5,A.OpenDateTime))), 0),'MM-yyyy')                  
ORDER BY MONTH DESC                  
                  
                  
------------------------------------------------------------------------------------------------------------                  
    
--Expected Volume                  
                  
  IF OBJECT_ID('tempdb..#Avgtktprod') IS NOT NULL DROP TABLE #Avgtktprod;                  
                  
    IF OBJECT_ID('tempdb..#Expected_Volume') IS NOT NULL DROP TABLE #Expected_Volume;                  
                  
                  
select AD.ESA_PROJECT_ID,AD.MONTH,ISNULL(ME.Total_MPS_Effort_From_ESA,0) AS Total_MPS_Effort_From_ESA,AD.Avg_Ticket_Productivity_2023_benchmark,                  
coalesce(AD.Avg_Ticket_Productivity_2023_benchmark, max(AD.Avg_Ticket_Productivity_2023_benchmark) over (partition by ESA_PROJECT_ID)) AS Avgtktprod                  
INTO #Avgtktprod                  
from #Applens_Dashboard_Project_List AD full outer join #Total_MPS_Effort_from_ESA ME                  
ON AD.ESA_Project_ID=ME.ESAProjectID AND AD.MONTH=ME.MONTH                   
--WHERE AD.month BETWEEN '2024-01-01' AND '2024-01-31'                  
GROUP BY  AD.ESA_Project_ID,AD.MONTH,ME.Total_MPS_Effort_From_ESA,AD.Avg_Ticket_Productivity_2023_benchmark                  
                  
                  
                  
select AD.ESA_PROJECT_ID,AD.MONTH, AD.Total_MPS_Effort_From_ESA,AD.Avgtktprod ,                  
cast(isnull(ME.Total_MPS_Effort_From_ESA*Avgtktprod/180.0,0) as decimal(11,1)) AS Expected_Volume                   
into #Expected_Volume                  
from #Avgtktprod AD                  
 full outer join #Total_MPS_Effort_from_ESA ME                  
ON AD.ESA_Project_ID=ME.ESAProjectID AND AD.MONTH=ME.MONTH                   
                  
                  
                  
---------------------------------------------------------------------------------------------------------------                  
                  
--Volume Deviation                  
                  
  IF OBJECT_ID('tempdb..#Volume_Deviation') IS NOT NULL DROP TABLE #Volume_Deviation;                  
                  
                  
create table #Volume_Deviation                
(                  
ESA_PROJECT_ID nvarchar(250),                  
MONTH nvarchar(250)Null,                  
Volume nvarchar(250)null,                  
Expected_Volume decimal(11,2)null,                  
Volume_Deviation decimal(11,2)null                  
)                  
                  
insert into #Volume_Deviation(ESA_PROJECT_ID,MONTH,Volume,Expected_Volume,Volume_Deviation)                  
                  
                  
SELECT                   
    EV.ESA_PROJECT_ID,                  
    EV.MONTH,                  
    ISNULL(vol.Volume, 0) AS Volume,                  
    ISNULL(EV.Expected_Volume, 0) AS Expected_Volume,                  
    CASE                   
        WHEN ISNULL(vol.Volume, 0) = 0 AND ISNULL(EV.Expected_Volume, 0) = 0                   
        THEN 0  -- Both volumes are 0 ? Deviation should be 0                  
        WHEN ISNULL(vol.Volume, 0) = 0 AND ISNULL(EV.Expected_Volume, 0) > 0                   
        THEN 100 -- Volume is missing, but Expected_Volume has data ? Deviation should be 100                  
              ELSE ISNULL(                  
            CAST(                  
                (ISNULL(vol.Volume, 0) - ISNULL(EV.Expected_Volume, 0))                   
                / NULLIF(ISNULL(vol.Volume, 0), 0)                   
            AS DECIMAL(11,2)), 0)                   
   END AS Volume_Deviation                  
FROM #Volume vol                  
FULL OUTER JOIN #Expected_Volume EV                  
ON vol.ESAProjectID = EV.ESA_Project_ID                   
AND vol.MONTH = EV.MONTH                   
                  
                  
----------------------------------------------------------------------                  
                  
--Tickets with Zero effort      

SELECT * into #TicketDetail1
FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) 
WHERE DATEADD(MINUTE,30,DATEADD(HOUR,5,Opendatetime)) BETWEEN @StartDate AND @EndDate and Efforttilldate<=0 and DARTStatusID in (8,9)                  
AND ISDELETED='0' 
                  
  IF OBJECT_ID('tempdb..#TicketswithZeroEffort') IS NOT NULL DROP TABLE #TicketswithZeroEffort;                  
                  
select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE,30,DATEADD(HOUR,5,C.Opendatetime))), 0),'MM-yyyy') AS Month ,COUNT(DISTINCT C.Ticketid) as Tickets_with_ZeroEffort                  
into #TicketswithZeroEffort                  
from #Applens_Dashboard_Project_List A                  
LEFT JOIN #mas_projectmaster(NOLOCK) B ON A.ESA_PROJECT_ID=B.ESAPROJECTID                  
left join #TicketDetail1(NOLOCK) C ON B.PROJECTID=C.PROJECTID                                                     
GROUP BY B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE,30,DATEADD(HOUR,5,C.Opendatetime))), 0),'MM-yyyy')                  
   
         
----------------------------------------------------------------------------------                  
  IF OBJECT_ID('tempdb..#AgeingTickets') IS NOT NULL DROP TABLE #AgeingTickets;                  
                  
--Tickets open beyond 30 days    

SELECT * into #TicketDetail2
FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) 
where DATEDIFF(day, DATEADD(MINUTE,30,DATEADD(HOUR,5,OpenDateTime)), DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))) >30  and dartstatusid not in (5,8,9) and  OpenDateTime < @StartDate                   


                  
select B.ESAPROJECTID,                  
COUNT(DISTINCT C.Ticketid) as Ageing_Tickets                  
into #AgeingTickets                  
from #Applens_Dashboard_Project_List A                  
LEFT JOIN AVL.MAS_PROJECTMASTER(NOLOCK) B ON A.ESA_PROJECT_ID=B.ESAPROJECTID                  
left join #TicketDetail2(NOLOCK) C ON B.PROJECTID=C.PROJECTID                  
group by  B.ESAPROJECTID                  
                  
                  
-------------------------------------------------------------------------------------------------                  
                  
---Umbrella tickets created with > 100 hours                  
                  
                  
  IF OBJECT_ID('tempdb..#UnknownIncidentsgreaterthan100Hours') IS NOT NULL DROP TABLE #UnknownIncidentsgreaterthan100Hours;                  
                  
 
 SELECT * into #TicketDetail3
FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) 
where Efforttilldate>100 and serviceid in (4,10) and  DATEADD(MINUTE,30,DATEADD(HOUR,5,OpenDateTime))BETWEEN @StartDate AND @EndDate                  



select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE,30,DATEADD(HOUR,5,C.OpenDateTime))), 0),'MM-yyyy') AS Month ,COUNT(DISTINCT C.Ticketid) as Unknown_Incidents_greater_than_100Hours                  
into #UnknownIncidentsgreaterthan100Hours                  
from #Applens_Dashboard_Project_List A                  
LEFT JOIN AVL.MAS_PROJECTMASTER(NOLOCK) B ON A.ESA_PROJECT_ID=B.ESAPROJECTID                  
left join #TicketDetail3(NOLOCK) C ON B.PROJECTID=C.PROJECTID                  
group by  B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE,30,DATEADD(HOUR,5,C.OpenDateTime))), 0),'MM-yyyy')                  
                  
                  
--Known Incidents  or Standard SR with > 50 hours                  
                  
  IF OBJECT_ID('tempdb..#KnownIncidentsgreaterthan50Hours') IS NOT NULL DROP TABLE #KnownIncidentsgreaterthan50Hours;                  
   
   SELECT * into #TicketDetail4
FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) 
where Efforttilldate>50 and serviceid in (1,7) and  DATEADD(MINUTE,30,DATEADD(HOUR,5,OpenDateTime)) BETWEEN @StartDate AND @EndDate                  


select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE,30,DATEADD(HOUR,5,C.OpenDateTime))), 0),'MM-yyyy') AS Month ,COUNT(DISTINCT C.Ticketid) as KnownIncidents_greaterthan_50Hours                  
into #KnownIncidentsgreaterthan50Hours                  
from #Applens_Dashboard_Project_List A                  
LEFT JOIN AVL.MAS_PROJECTMASTER(NOLOCK) B ON A.ESA_PROJECT_ID=B.ESAPROJECTID                  
left join #TicketDetail4(NOLOCK) C ON B.PROJECTID=C.PROJECTID                  
group by  B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE,30,DATEADD(HOUR,5,C.OpenDateTime))), 0),'MM-yyyy')                  
                  
---Unknown Incidents or Adhoc SR with effort < 1/2 hour                  
                  
  IF OBJECT_ID('tempdb..#UNKnownIncidents_lessthan_HalfHours') IS NOT NULL DROP TABLE #UNKnownIncidents_lessthan_HalfHours;                  
                  
  
  SELECT * into #TicketDetail5
FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) 
where Efforttilldate<0.5 and serviceid in (4,10) and DATEADD(MINUTE,30,DATEADD(HOUR,5, OpenDateTime)) BETWEEN @StartDate AND @EndDate  --and esaprojectid='1000296355'                  


select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE,30,DATEADD(HOUR,5,C.OpenDateTime))), 0),'MM-yyyy') AS Month ,COUNT(DISTINCT C.Ticketid) as UNKnownIncidents_lessthan_HalfHours                  
into #UNKnownIncidents_lessthan_HalfHours                  
from #Applens_Dashboard_Project_List A                  
LEFT JOIN AVL.MAS_PROJECTMASTER(NOLOCK) B ON A.ESA_PROJECT_ID=B.ESAPROJECTID                  
left join #TicketDetail5(NOLOCK) C ON B.PROJECTID=C.PROJECTID                  
group by  B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE,30,DATEADD(HOUR,5,C.OpenDateTime))), 0),'MM-yyyy')                  
  
                  
---------------------------------------------------------------------------------                  
                  
---ISMO team submitting against tickets <> Known Inc / Standard SR                  
                  
  IF OBJECT_ID('tempdb..#ISMOAssociatesSubmittedTickets') IS NOT NULL DROP TABLE #ISMOAssociatesSubmittedTickets;                  

SELECT * into #TimesheetDetail1
FROM [AVL].[TM_TRN_TimesheetDetail](NOLOCK) 
WHERE SERVICEID Not IN (1,7)  

SELECT * into #projectassociates1
FROM esa.projectassociates(NOLOCK) 
where Dept_name='ADM AVM ISmO' 

                  
select distinct B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.Timesheetdate), 0),'MM-yyyy') AS Month ,count(Distinct E.Ticketid) as Ismo_Associate_Timesheet                  
into #ISMOAssociatesSubmittedTickets                  
from #Applens_Dashboard_Project_List(NOLOCK) A                  
LEFT JOIN AVL.MAS_PROJECTMASTER(NOLOCK) B ON B.ESAPROJECTID=A.ESA_PROJECT_ID                  
left join #ApplensCurrentMonthTimesheet(NOLOCK) C ON B.PROJECTID=C.PROJECTID                  
LEFT JOIN #TimesheetDetail1(NOLOCK) E ON E.TIMESHEETID=C.TIMESHEETID AND E.ISNONTICKET=0                  
left join avl.mas_loginmaster F ON F.USERID=C.SUBMITTERID AND F.PROJECTID=B.PROJECTID                  
Left join #projectassociates1(NOLOCK) D on D.projectid=A.ESA_PROJECT_ID AND D.ASSOCIATEID=F.Employeeid                  
where F.employeeid in  (select AssociateID from #FilteredAssociates)                                    
group by B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0,  C.Timesheetdate), 0),'MM-yyyy')                   
     
	 

--DROP TABLE #ISMOAssociatesSubmittedTickets                  
--DIFFERENCE                  
  IF OBJECT_ID('tempdb..#OverallTicketingdata') IS NOT NULL DROP TABLE #OverallTicketingdata;                  
                  
SELECT AD.ESA_Project_ID,AD.Month,ISNULL(TE.Tickets_with_ZeroEffort,0) AS Tickets_with_ZeroEffort ,                  
ISNULL(AG.Ageing_Tickets,0) AS Ageing_Tickets,ISNULL(UH.Unknown_Incidents_greater_than_100Hours,0) AS Unknown_Incidents_greater_than_100Hours,                  
ISNULL(KI.KnownIncidents_greaterthan_50Hours,0) AS KnownIncidents_greaterthan_50Hours,ISNULL(UI.UNKnownIncidents_lessthan_HalfHours,0) AS UNKnownIncidents_lessthan_HalfHours,                  
ISNULL(IA.Ismo_Associate_Timesheet,0) AS Ismo_Associate_Timesheet                  
into #OverallTicketingdata                  
from #Applens_Dashboard_Project_List AD                  
LEFT JOIN #TicketswithZeroEffort TE ON AD.ESA_PROJECT_ID=TE.ESAPROJECTID AND AD.MONTH=TE.MONTH                  
LEFT join #AgeingTickets AG ON AG.ESAPROJECTID =AD.ESA_PROJECT_ID --and AD.Month=AG.Month                  
LEFT join #UnknownIncidentsgreaterthan100Hours UH ON UH.ESAPROJECTID=AD.ESA_PROJECT_ID and UH.Month=AD.month                  
LEFT join #KnownIncidentsgreaterthan50Hours KI ON KI.ESAPROJECTID=AD.ESA_PROJECT_ID and KI.Month=AD.Month                  
LEFT join #UNKnownIncidents_lessthan_HalfHours UI ON UI.ESAPROJECTID=AD.ESA_PROJECT_ID AND UI.Month=AD.Month                  
LEFT join #ISMOAssociatesSubmittedTickets IA ON IA.ESAPROJECTID=AD.ESA_PROJECT_ID AND IA.MONTH=AD.MONTH                  
                  
                  
  IF OBJECT_ID('tempdb..#OverallDifference') IS NOT NULL DROP TABLE #OverallDifference;                  
                  
                  
 SELECT ESA_Project_ID,Month,                  
 (SUM(Tickets_with_ZeroEffort)+sum(Ageing_Tickets+Unknown_Incidents_greater_than_100Hours)+sum(KnownIncidents_greaterthan_50Hours)                  
 +sum(UNKnownIncidents_lessthan_HalfHours)+sum(Ismo_Associate_Timesheet)) AS DIfferences                   
 INTO #OverallDifference                  
 from #OverallTicketingdata                  
 group by ESA_Project_ID,Month                  
                  
  --drop table #OverallDifference                  
                  
 ----Total Ticket Volume usable for Benchmarking                  
                  
                  
   IF OBJECT_ID('tempdb..#totalticketvolume') IS NOT NULL DROP TABLE #totalticketvolume;                  
                  
 SELECT V.ESAPROJECTID,V.MONTH,V.VOLUME-OD.DIfferences  as Total_TicketVolume                   
 into #totalticketvolume                   
 FROM #Volume V JOIN #OverallDifference OD ON V.ESAPROJECTID=OD.ESA_Project_ID AND V.MONTH=OD.MONTH                  
                
 
 SELECT * into #TimesheetDetailActive
FROM [AVL].[TM_TRN_TimesheetDetail](NOLOCK) 
WHERE IsDeleted='0'
                  
--Total Applens Effort                  
   IF OBJECT_ID('tempdb..#Total_Applens_Effort') IS NOT NULL DROP TABLE #Total_Applens_Effort;                  
                  
select distinct C.EsaProjectID ,A.ProjectId,sum(B.Hours) as  Total_Applens_Effort,                  
format(DATEADD(month, DATEDIFF(month, 0, TimesheetDate), 0),'MM-yyyy') AS Month                  
INTO #Total_Applens_Effort                  
from #ApplensCurrentMonthTimesheet(NOLOCK) A                  
LEFT JOIN #TimesheetDetailActive (NOLOCK) B ON A.PROJECTID=B.PROJECTID AND A.TimesheetId=B.TimesheetId                  
lEFT join #mas_projectmaster(NOLOCK) C ON C.ProjectID=B.ProjectId                  
left join  avl.mas_loginmaster(nolock) D on D.ProjectID=C.projectid and A.Submitterid=D.UserID  --AND D.Isdeleted='0'                  
WHERE  D.employeeid in  (select AssociateID from #FilteredAssociates WHERE PROJECTID=C.ESAPROJECTID)                                      
group by C.EsaProjectID,A.ProjectId,DATEADD(month, DATEDIFF(month, 0, A.TimesheetDate), 0)                  
order by Month desc                  
                  
--Total ESA Effort                  
   IF OBJECT_ID('tempdb..#Total_ESA_Effort') IS NOT NULL DROP TABLE #Total_ESA_Effort;                  
   
   SELECT * into #TimesheetDetail_All2
FROM DiscoverEDS.EDS.[TimesheetDetail_All](NOLOCK) 
WHERE TIMESHEETSUBMISSIONDATE BETWEEN @Startdate AND @Enddate

select distinct A.ESA_Project_ID,format(DATEADD(month, DATEDIFF(month, 0, B.TimesheetsubmissionDate), 0),'MM-yyyy') AS Month,SUM(B.HOURS) AS Total_ESA_Effort                  
INTO #Total_ESA_Effort                  
from #Applens_Dashboard_Project_List A  
LEFT join #TimesheetDetail_All2  B                  
ON A.ESA_Project_ID=B.esaprojectid AND A.Month=format(DATEADD(month, DATEDIFF(month, 0, B.TimesheetsubmissionDate), 0),'MM-yyyy')                  
WHERE B.Submitterid in  (select AssociateID from #FilteredAssociates WHERE PROJECTID=A.ESA_Project_ID)                  
GROUP BY  A.ESA_Project_ID,format(DATEADD(month, DATEDIFF(month, 0, B.TimesheetsubmissionDate), 0),'MM-yyyy')                  
                
IF OBJECT_ID('tempdb..#DataQualityReports') IS NOT NULL DROP TABLE #DataQualityReports;                  
                
                  
CREATE TABLE #DataQualityReports(                  
[Month] [nvarchar](max) NULL,[ESA_Project_ID] [nvarchar](250) NULL,[ESA_Project_Name] [nvarchar](250) NULL,                  
[Mainspring_Project_ID] [nvarchar](250) NULL,[Execution_Project_Name] [nvarchar](250) NULL,[ESA_PM_NAME] [nvarchar](250) NULL,                  
[ESA_PM_ID] [nvarchar](250) NULL,[Archetype_Cluster] [nvarchar](250) NULL,[Archetype] [nvarchar](250) NULL,                  
[Work_Category] [nvarchar](250) NULL,[Parent_Account] [nvarchar](250) NULL,[Practice_Area_PBI] [nvarchar](250) NULL,                  
[Project_Owning_Unit] [nvarchar](250) NULL,[Industry_Segment] [nvarchar](250) NULL,[Vertical] [nvarchar](250) NULL,                  
[Market] [nvarchar](250) NULL,[Market_Unit] [nvarchar](250) NULL,[Updated_BU] [nvarchar](250) NULL,[Updated_SBU] [nvarchar](250) NULL,                  
[ESA_Project_Country] [nvarchar](250) NULL,[Project_Owner_ESA_PM_department] [nvarchar](250) NULL,[Project_Owner_Name] [nvarchar](250) NULL,                  
[Project_Owner_Id] [nvarchar](250) NULL,[Delivery_Excellence_POC] [nvarchar](250) NULL,[Final_Scope] [nvarchar](250) NULL,                  
[Total_FTE] [float] NULL,[_3x3_Matrix] [nvarchar](250) NULL,[Project_Type] [nvarchar](250) NULL,                  
[Avgtktprod] [tinyint] NULL,[Status] [nvarchar](250) NULL,[Total_MPS_Effort_From_Applens] [decimal](12, 2) NULL,                  
[Total_MPS_Effort_From_ESA] [decimal](12, 2) NULL,[Total_Applens_Effort] [decimal](12, 2) NULL,[Total_ESA_Effort] [decimal](12, 2) NULL,                  
[Effort_Deviation] [decimal](10, 2) NULL,[Volume] [decimal](10, 2) NULL,[Expected_Volume] [decimal](10, 2) NULL,                  
[Volume_Deviation] [decimal](10, 2) NULL,[Total_TicketVolume] [decimal](10, 2) NULL,[Tickets_with_ZeroEffort] [decimal](10, 2) NULL,                  
[Ageing_Tickets] [decimal](10, 2) NULL,[Unknown_Incidents_greater_than_100Hours] [decimal](10, 2) NULL,                  
[KnownIncidents_greaterthan_50Hours] [decimal](10, 2) NULL,[UNKnownIncidents_lessthan_HalfHours] [decimal](10, 2) NULL,          [Ismo_Associate_Timesheet] [decimal](10, 2) NULL,[Differencess] [decimal](10, 2) NULL,                  
[CreatedDate] Datetime,[CreatedBy] NVARCHAR (50),                   
)                  
                  
            
--TRUNCATE table [dbo].[DataQualityReports]                 
                  
Insert into #DataQualityReports                  
(                  
[ESA_Project_ID],[Month],[ESA_Project_Name],[Mainspring_Project_ID],[Execution_Project_Name],[ESA_PM_NAME],[ESA_PM_ID],                  
[Archetype_Cluster],[Archetype],[Work_Category],[Parent_Account],[Practice_Area_PBI],[Project_Owning_Unit],                  
[Industry_Segment],[Vertical],[Market],[Market_Unit],[Updated_BU],[Updated_SBU],[ESA_Project_Country],                  
[Project_Owner_ESA_PM_department],[Project_Owner_Name],[Project_Owner_Id],[Delivery_Excellence_POC],[Final_Scope],[Total_FTE],                  
[_3x3_Matrix],[Project_Type],[Status],[Total_MPS_Effort_From_Applens],[Total_MPS_Effort_From_ESA],[Total_Applens_Effort],                  
[Total_ESA_Effort],[Effort_Deviation],[Volume],[Avgtktprod],[Expected_Volume],[Volume_Deviation],                  
[Total_TicketVolume],[Tickets_with_ZeroEffort],[Ageing_Tickets],[Unknown_Incidents_greater_than_100Hours],[KnownIncidents_greaterthan_50Hours],[UNKnownIncidents_lessthan_HalfHours],                  
[Ismo_Associate_Timesheet],[Differencess],[CreatedDate],[CreatedBy]                  
                  
)                  
                  
select distinct * from (                  
select distinct                  
isnull(ADP.ESA_Project_ID,0) as ESA_Project_ID ,                  
ADP.Month  AS Month,                  
isnull(ADP.ESA_Project_Name,0) as ESA_Project_Name,                  
isnull(ADP.Mainspring_Project_ID,'') as Mainspring_Project_ID,                  
isnull(ADP.Execution_Project_Name,'') as Execution_Project_Name,                  
isnull(ADP.ESA_PM_NAME,0) as ESA_PM_NAME,                  
isnull(ADP.ESA_PM_ID,0) as ESA_PM_ID,                  
isnull(ADP.Archetype_Cluster,0) as Archetype_Cluster,                  
isnull(ADP.Archetype,0) as Archetype,                  
isnull(ADP.Work_Category,0) as Work_Category,                  
isnull(ADP.Parent_Account,0) as Parent_Account,                  
ADP.Practice_Area_PBI,                  
isnull(ADP.Project_Owning_Unit,0) as Project_Owning_Unit,                  
isnull(ADP.Industry_Segment,0) as Industry_Segment,                  
isnull(ADP.Vertical,0) as Vertical,                  
ADP.[Market],                  
ADP.[Market_Unit],                  
isnull(ADP.Updated_BU,0) as Updated_BU,            
isnull(ADP.Updated_SBU,0) as Updated_SBU,                  
isnull(ADP.ESA_Project_Country,0) as ESA_Project_Country,                  
isnull(ADP.Project_Owner_ESA_PM_department,0) as Project_Owner_ESA_PM_department,                  
isnull(ADP.Project_Owner_Name,0) as Project_Owner_Name,                  
isnull(ADP.Project_Owner_Id,0) as Project_Owner_Id,                  
isnull(ADP.Delivery_Excellence_POC,0) as Delivery_Excellence_POC,                  
isnull(ADP.Final_Scope,0) as Final_Scope,                  
isnull(ADP.Total_FTE,0) as Total_FTE,                  
isnull(ADP._3x3_Matrix,0) AS '3x3 Matrix',                  
isnull(ADP.Project_Type,0) as Project_Type,                  
isnull(ADP.status,0) as status,                  
isnull(AE.Total_MPS_Effort_From_Applens,0) as Total_MPS_Effort_From_Applens,                  
isnull(MP.Total_MPS_Effort_From_ESA,0) as Total_MPS_Effort_From_ESA,                  
isnull(TAE.Total_Applens_Effort,0) as Total_Applens_Effort,                  
isnull(TEE.Total_ESA_Effort,0) as Total_ESA_Effort,                  
ISNULL(REPLACE(ED.Effort_Deviation, ',', ''), 0) AS Effort_Deviation,                   
isnull(Vol.Volume,0) as Volume,                  
AGP.[Avgtktprod],                  
isnull(ev.Expected_Volume,0) as Expected_Volume,                  
isnull(VD.Volume_Deviation,0) as Volume_Deviation,                  
isnull(TTV.Total_TicketVolume,0) as Total_TicketVolume,                  
isnull(ZE.Tickets_with_ZeroEffort,0) as Tickets_with_ZeroEffort,                  
isnull(AG.Ageing_Tickets,0) as Ageing_Tickets,                  
isnull(UI.Unknown_Incidents_greater_than_100Hours,0) as Unknown_Incidents_greater_than_100Hours,                  
isnull(KI.KnownIncidents_greaterthan_50Hours,0) as KnownIncidents_greaterthan_50Hours,                  
isnull(UIH.UNKnownIncidents_lessthan_HalfHours,0) as UNKnownIncidents_lessthan_HalfHours,            
isnull(IA.Ismo_Associate_Timesheet,0) as Ismo_Associate_Timesheet,                  
isnull(OT.DIfferences,0) as DIfferences,                  
ADP.[CreatedDate],                  
ADP.[CreatedBy]                  
--EVC.Compliance                  
from #Applens_Dashboard_Project_List ADP                   
LEFT JOIN #Total_MPS_Effort_From_Applens AE ON  ADP.ESA_Project_ID=AE.ESA_Project_ID AND ADP.Month=AE.Month                  
LEFT JOIN #Total_MPS_Effort_from_ESA MP ON MP.ESAProjectID=ADP.ESA_Project_ID AND MP.MONTH=ADP.MONTH             
left join #Total_Applens_Effort tae on tae.esaprojectid=ADP.ESA_Project_ID and tae.month=ADP.MONTH                  
left join #Total_ESA_Effort tee on tee.ESA_Project_ID=ADP.ESA_Project_ID and tee.month=ADP.month                  
LEFT JOIN #Effort_Deviation ED ON ED.ESAProjectID=ADP.ESA_Project_ID AND ED.MONTH=ADP.MONTH                  
LEFT JOIN #Volume Vol on Vol.esaprojectid=ADP.ESA_Project_ID AND VOL.MONTH=ADP.MONTH                  
LEFT join #Avgtktprod AGP ON AGP.ESA_PROJECT_ID=ADP.ESA_Project_ID  AND AGP.MONTh=ADP.MONTH                  
left JOIN #Expected_Volume EV on EV.ESA_Project_ID=ADP.ESA_PROJECT_ID AND EV.MONTh=ADP.MONTH                  
LEFT JOIN #Volume_deviation vd on vd.ESA_Project_ID=ADP.ESA_Project_ID and vd.month=ADP.month                  
left join #totalticketvolume ttv on ttv.esaprojectid=ADP.ESA_Project_ID and ttv.month=ADP.month                  
left join #TicketswithZeroEffort ze on ze.esaprojectid=ADP.ESA_Project_ID and ze.month=ADP.month                  
left join #AgeingTickets ag on ag.esaprojectid=ADP.ESA_Project_ID --and ag.month=ADP.month                  
left join #UnknownIncidentsgreaterthan100Hours ui on ui.esaprojectid=ADP.ESA_Project_ID and ui.month=ADP.month                  
left join #KnownIncidentsgreaterthan50Hours ki on ki.esaprojectid=ADP.ESA_Project_ID and ki.month=ADP.month                  
left join #UNKnownIncidents_lessthan_HalfHours uih on uih.esaprojectid=ADP.ESA_Project_ID and uih.month=ADP.month                  
left join #ISMOAssociatesSubmittedTickets IA on ia.esaprojectid=ADP.ESA_Project_ID and ia.month=ADP.month                  
left join #OverallDifference  ot on ot.ESA_Project_ID=ADP.ESA_Project_ID and ot.month=ADP.month                  
) AS T where T.Month is not null                   
                  
--select * from #Applens_Dashboard_Project_List where month= '08-2024'                  
--DECLARE @Job_Month nvarchar(10)                  
--set @Job_Month=format(DATEADD(month, DATEDIFF(month, 0, @StartDate), 0),'MM-yyyy')                  
--Delete from   #DataQualityReports where month!= @Job_Month                  
                  
--select * from #DataQualityReports  where month= '08-2024'                  
delete A from  [dbo].[DataQualityReports] A where exists(select distinct Month from #DataQualityReports B WHERE A.MONTH=B.MONTH)                  
                  
          
                  
Insert into [dbo].[DataQualityReports]                 
(                  
[ESA_Project_ID],[Month],[ESA_Project_Name],[Mainspring_Project_ID],[Execution_Project_Name],[ESA_PM_NAME],                  
[ESA_PM_ID],[Archetype_Cluster],[Archetype],[Work_Category],[Parent_Account],[Practice_Area_PBI],[Project_Owning_Unit],                  
[Industry_Segment],[Vertical],[Market],[Market_Unit],[Updated_BU],[Updated_SBU],[ESA_Project_Country],                  
[Project_Owner_ESA_PM_department],[Project_Owner_Name],[Project_Owner_Id],[Delivery_Excellence_POC],[Final_Scope],[Total_FTE],                  
[_3x3_Matrix],[Project_Type],[Status],[Total_MPS_Effort_From_Applens],[Total_MPS_Effort_From_ESA],                  
[Total_Applens_Effort],[Total_ESA_Effort],[Effort_Deviation],[Volume],[Avgtktprod],[Expected_Volume],[Volume_Deviation],                  
[Total_TicketVolume],[Tickets_with_ZeroEffort],[Ageing_Tickets],[Unknown_Incidents_greater_than_100Hours],[KnownIncidents_greaterthan_50Hours],                  
[UNKnownIncidents_lessthan_HalfHours],[Ismo_Associate_Timesheet],[Differencess],[CreatedDate],[CreatedBy]                  
)                  
                  
SELECT distinct [ESA_Project_ID],                  
[Month],                  
ISNULL(DR.[ESA_Project_Name],0) AS [ESA_Project_Name],                  
isnull(DR.Mainspring_Project_ID,'') as [Mainspring_Project_ID],                  
isnull(DR.Execution_Project_Name,'') as[Execution_Project_Name],                  
ISNULL(DR.[ESA_PM_NAME],0) AS [ESA_PM_NAME],                  
ISNULL(DR.[ESA_PM_ID],0) AS [ESA_PM_ID],                  
ISNULL(DR.[Archetype_Cluster],0) AS [Archetype_Cluster],                  
ISNULL(DR.[Archetype],0) AS [Archetype],                  
ISNULL(DR.[Work_Category],0) AS [Work_Category],                  
ISNULL(DR.[Parent_Account],0) AS [Parent_Account],                  
DR.Practice_Area_PBI,                  
ISNULL(DR.[Project_Owning_Unit],0) AS [Project_Owning_Unit],                  
ISNULL(DR.[Industry_Segment],0) AS [Industry_Segment],                  
ISNULL(DR.[Vertical],0) AS [Vertical],                  
DR.[Market],                  
DR.[Market_Unit],                  
ISNULL(DR.[Updated_BU],0) AS [Updated_BU],                
ISNULL(DR.[Updated_SBU],0) AS [Updated_SBU],                  
ISNULL(DR.[ESA_Project_Country],0) AS [ESA_Project_Country],                  
ISNULL(DR.[Project_Owner_ESA_PM_department],0) AS [Project_Owner_ESA_PM_department],                  
ISNULL(DR.[Project_Owner_Name],0) AS [Project_Owner_Name],                  
ISNULL(DR.[Project_Owner_Id],0) AS [Project_Owner_Id],                  
ISNULL(DR.[Delivery_Excellence_POC],0) AS [Delivery_Excellence_POC],                  
ISNULL(DR.[Final_Scope],0) AS [Final_Scope],                  
ISNULL(DR.[Total_FTE],0) AS [Total_FTE],                  
ISNULL(DR.[_3x3_Matrix],0) AS [_3x3_Matrix],                  
ISNULL(DR.[Project_Type],0) AS [Project_Type],                  
ISNULL(DR.[Status],0) AS [Status],                  
ISNULL(DR.[Total_MPS_Effort_From_Applens],0) AS [Total_MPS_Effort_From_Applens],                  
ISNULL(DR.[Total_MPS_Effort_From_ESA],0) AS [Total_MPS_Effort_From_ESA],                  
ISNULL(DR.[Total_Applens_Effort],0) AS [Total_Applens_Effort],                  
ISNULL(DR.[Total_ESA_Effort],0) AS [Total_ESA_Effort],                  
ISNULL(DR.[Effort_Deviation],0) AS [Effort_Deviation],                  
ISNULL(DR.[Volume],0) AS [Volume],                  
ISNULL(DR.[Avgtktprod],0) AS [Avg_Ticket_Productivity_2023_benchmark],                  
ISNULL(DR.[Expected_Volume],0) AS [Expected_Volume],                  
ISNULL(DR.[Volume_Deviation],0) AS [Volume_Deviation],                  
ISNULL(DR.[Total_TicketVolume],0) AS [Total_TicketVolume],                  
ISNULL(DR.[Tickets_with_ZeroEffort],0) AS [Tickets_with_ZeroEffort],                  
ISNULL(DR.[Ageing_Tickets],0) AS [Ageing_Tickets],                  
ISNULL(DR.[Unknown_Incidents_greater_than_100Hours],0) AS [Unknown_Incidents_greater_than_100Hours],                  
ISNULL(DR.[KnownIncidents_greaterthan_50Hours],0) AS [KnownIncidents_greaterthan_50Hours],                  
ISNULL(DR.[UNKnownIncidents_lessthan_HalfHours],0) AS [Ismo_Associate_Timesheet],                  
isnull(DR.[Ismo_Associate_Timesheet],0) AS [Ismo_Associate_Timesheet],                  
Isnull(DR.Differencess,0) as Differencess,                  
GETDATE(),'DQR Job'                  
FROM #DataQualityReports DR
--WHERE not  EXISTS (                  
--select * from [dbo].[DataQualityReports] ADPL WHERE DR.MONTH =ADPL. Month and DR.Esa_Project_ID=ADPL.ESA_PROJECT_ID );                  
      

delete from [dbo].[DataQualityReports] where month='07-2025' and PRACTICE_AREA_PBI='IOT'
and esa_project_id in (

'1000423428',
'1000439796',
'1000446870',
'1000447800',
'1000450016',
'1000450391',
'1000451360'
)
  

--drop table [dbo].[DataQualityReports_NewRequirement] 
--select  * into [dbo].[DataQualityReports_NewRequirement]
--from [dbo].[DataQualityReports] 
    
--select  * from  [dbo].[DataQualityReports] 
  
                
   COMMIT TRANSACTION                              
                              
  UPDATE MAS.JobStatus Set JobStatus = @JobStatusSuccess, EndDateTime = GETDATE() WHERE ID = @JobStatusId                      
                      
 SELECT @MailSubject = CONCAT(@@servername, ':  DQR_ProjectLevel Job Success Notification')                           
                          
SET @MailContent = 'DQR_ProjectLevel job has been completed successfully.'                            
                        
SELECT @MailBody =  [dbo].[fn_FmtEmailBody_Message](@MailContent)                        
                        
EXEC [AVL].[SendDBEmail] @To = 'AVMDARTL2@cognizant.com',                        
 @From='ApplensSupport@cognizant.com',                  
@subject = @MailSubject,                        
@body = @MailBody                    
                  
 END TRY                    
  BEGIN CATCH                    
  Print 'Error'                              
  IF (XACT_STATE()) = -1                                
  BEGIN                                
   ROLLBACK TRANSACTION;                                
  END;                                
  IF (XACT_STATE()) = 1                                
  BEGIN                
   COMMIT TRANSACTION;                          
  END;                              
  UPDATE MAS.JobStatus Set JobStatus = @JobStatusFail, EndDateTime = GETDATE() WHERE ID = @JobStatusId                       
                    
                              
  DECLARE @HostName NVARCHAR(50);                              
  DECLARE @Associate NVARCHAR(50);                              
  DECLARE @ErrorCode NVARCHAR(50);                              
  DECLARE @ErrorMessage NVARCHAR(MAX);                              
  DECLARE @ModuleName VARCHAR(30)='DQR_ProjectLevel';                              
  DECLARE @DbName VARCHAR(30)='AppVisionLens';                              
  DECLARE @getdate  DATETIME=GETDATE();                              
  DECLARE @DbObjName VARCHAR(50)=(OBJECT_NAME(@@PROCID));                              
  SET @HostName=(SELECT HOST_NAME());                              
  SET @Associate=(SELECT SUSER_NAME());                              
  SET @ErrorCode=(SELECT ERROR_NUMBER());                              
  SET @ErrorMessage=(SELECT ERROR_MESSAGE());                              
                              
                              
  EXEC AppVisionLensLogging.[dbo].[InsertLog] 'Critical','ERROR',@HostName,@Associate,@getdate,NULL,'SQL',                              
             @ModuleName,@JobName,@DbName,@DbObjName,@@SPID,@ErrorCode,@ErrorMessage,                              
           @JobStatusFail,NULL,NULL                         
                        
DECLARE @MailSubject_NoData NVARCHAR(500);                          
DECLARE @MailBody_NoData NVARCHAR(MAX);                            
DECLARE @MailContent_NoData NVARCHAR(500);                        
                        
SELECT @MailSubject_NoData = CONCAT(@@servername, ':  DQR_ProjectLevel Job Notification')                           
                        
SET @MailContent_NoData = 'DQR_ProjectLevel job failed and data did not refresh'                        
                        
SELECT @MailBody_NoData =  [dbo].[fn_FmtEmailBody_Message](@MailContent_NoData)                        
                        
EXEC [AVL].[SendDBEmail] @To = 'AVMDARTL2@cognizant.com',                   
 @From='ApplensSupport@cognizant.com',                  
@subject = @MailSubject_NoData,                        
@body = @MailBody_NoData                          
                        
                  
--truncate table   [dbo].[Benchmark_Eligible_Project_List]                  
                  
                  
  drop table #Applens_Dashboard_Project_List                  
    drop table #EDSTimesheetdetail                  
 DROP TABLE #OverallDifference                  
  DROP TABLE #ApplensTimesheetdetail                  
  drop table #Total_MPS_Effort_From_Applens                  
  drop table #Total_MPS_Effort_from_ESA                  
  drop table #Effort_Deviation                  
  drop table #Volume                  
  drop table #Expected_Volume                  
  drop table #Volume_deviation                  
  drop table #TicketswithZeroEffort                  
  drop table #AgeingTickets                  
  drop table #UnknownIncidentsgreaterthan100Hours                  
  drop table #KnownIncidentsgreaterthan50Hours                  
  drop table #UNKnownIncidents_lessthan_HalfHours                  
  drop table #ISMOAssociatesSubmittedTickets                  
  drop table #OverallTicketingdata                  
  drop table #totalticketvolume                  
  drop table #Total_Applens_Effort                  
  drop table #Total_ESA_Effort                  
  DROP TABLE #Avgtktprod   
  drop table #ApplensCurrentMonthTimesheet
                    
                  
  END CATCH                       
                        
END 