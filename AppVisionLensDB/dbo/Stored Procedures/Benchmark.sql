
create procedure dbo.Benchmark
as
begin

select distinct Associateid,ProjectId,Dept_Name into #ProjectAssociateallocation from esa.projectassociates(Nolock)

select DISTINCT PM.ESAPROJECTID into #DataQualityReports from AVL.PRJ_ConfigurationProgress A
join Avl.MAS_ProjectMaster PM ON A.ProjectID=PM.ProjectID
where screenID=4 and CompletionPercentage=100 and A.Isdeleted=0 and PM.IsDeleted=0
----------------------------------------------------------------------------

select distinct B.Ticketid,C.EsaProjectID, D.EmployeeID,D.employeename,A.ProjectId,Ser.ServiceName,
sum(B.Hours) as  Efforttilldate,A.TimesheetDate,TktDtl.[OpenDateTime],TktDtl.[Closeddate] ,
SerLvl.[ServiceLevelID]            
,TktDtl.IsPartiallyAutomated             
,SerType.[ServiceTypeName]                      
,SerLvl.[ServiceLevelName] ,TktDtl.CompletedDateTime,TMDTSID.DARTStatusName ,CC.CauseCode           
,RC.ResolutionCode  ,TechGrp.[BenchTech_Id] Technology 
,AppAgeCat.BenchAppAgeID AS ApplicationAge             
,SAPCls.[SAPClassification_Id] AS SAPClassification  ,ATMPM.[PriorityName] ,AppDtl.ApplicationTypename ApplicationTypename         
,CONVERT(NVARCHAR(100),REPLACE(AppDtl.[PrimaryTechnologyName], CHAR(9), '')) AS [PrimaryTechnologyName]  
,CONVERT(NVARCHAR(50),REPLACE(bu.BusinessUnitName, CHAR(9), '')) AS [BUNAME],  
AppDtl.BusinessCriticalityName BusinessCriticalityName ,DeptGrp.[BenchDept_Id] AS AssociateDept  ,PA.Dept_Name      
  ,'2025' as [Year]     
,'05' as [Month] 
 into #ticketleveldata         
from [AVL].[TM_PRJ_Timesheet](NOLOCK) A
LEFT JOIN [AVL].[TM_TRN_TimesheetDetail](NOLOCK) B ON A.PROJECTID=B.PROJECTID AND A.TimesheetId=B.TimesheetId and b.isdeleted=0
lEFT join [AVL].mas_projectmaster(NOLOCK) C ON C.ProjectID=B.ProjectId -- AND C.IsDeleted='0' 
left join  avl.mas_loginmaster(nolock) D on D.ProjectID=C.projectid and A.Submitterid=D.UserID  --AND D.Isdeleted='0'
LEFT JOIN [AVL].[TK_TRN_TicketDetail](NOLOCK) TktDtl  ON TktDtl.TimeTickerID = B.TimeTickerID AND TktDtl.PROJECTID=D.ProjectID       
LEFT JOIN [AVL].[TK_MAS_Service] Ser  (NOLOCK) ON Ser.ServiceID = TktDtl.ServiceID             
LEFT JOIN [AVL].[TK_MAS_ServiceType] SerType  (NOLOCK) ON SerType.[ServiceTypeID] = Ser.[ServiceType]        
LEFT JOIN [AVL].[MAS_ServiceLevel] SerLvl  (NOLOCK) ON SerLvl.[ServiceLevelID] = Ser.ServiceLevelID  
LEFT JOIN [AVL].[TK_MAS_DARTTicketStatus](NOLOCK) TMDTSID on TktDtl.DARTStatusID=TMDTSID.DARTStatusID 
LEFT JOIN [AVL].[DEBT_MAP_CauseCode](NOLOCK) CC on TktDtl.CauseCodeMapID=CC.CauseID     
LEFT JOIN[AVL].[DEBT_MAP_ResolutionCode](NOLOCK) RC on TktDtl.ResolutionCodeMapID=RC.ResolutionID 
LEFT JOIN avl.Customer AC   (NOLOCK) ON AC.CustomerID=C.CustomerID     
LEFT JOIN [dbo].[VW_Applens_AccountLevelApplicationDetails] AccApp  (NOLOCK) ON AccApp.ESA_AccountID = AC.ESA_AccountId AND AccApp.ApplicationID = TktDtl.ApplicationID          
LEFT JOIN [dbo].[VW_Applens_ApplicationAttributes] AppDtl  (NOLOCK) ON AppDtl.ESA_AccountID = AccApp.ESA_AccountID AND AppDtl.ApplicationID = AccApp.ApplicationID            
LEFT JOIN [BM].[map_Bench_Tech] TechGrp   (NOLOCK) ON TechGrp.[PrimaryTechnology_Id] = AppDtl.[PrimaryTechnologyID]         
LEFT JOIN [BM].[map_Bench_AppAge] AppAgeCat  (NOLOCK) ON AppAgeCat.[AppAge] = DATEDIFF(YEAR,AppDtl.[ApplicationCommisionDate],GETDATE())                
LEFT JOIN [BM].[Map_Bench_SAPClassification] SAPCls  (NOLOCK) ON SAPCls.[Application_name] = AppDtl.[ApplicationName]        
LEFT JOIN [AVL].[TK_MAP_PriorityMapping] ATMPM  (NOLOCK) ON TktDtl.PriorityMapID=ATMPM.PriorityIDMapID 
left join #ProjectAssociateallocation  PA  (NOLOCK) on  D.employeeid=PA.Associateid AND PA.PROJECTID=C.ESAPROJECTID
LEFT JOIN [BM].[map_Bench_Dept] DeptGrp  (NOLOCK) ON DeptGrp.[Department] = PA.Dept_Name          
LEFT JOIN [MAS].[BusinessUnits] bu ON bu.BusinessUnitID = AC.BusinessUnitID and bu.IsDeleted = 0 

WHERE ser.servicename is not null
--B.SERVICEID IN (1,3,4,7,10,11) 
and 
A.TimesheetDate between '2025-05-01' AND '2025-05-31' 
--and A.Createddatetime between '2025-01-01' AND '2025-02-05' 
--and C.Esaprojectid in ('1000217732') 
group by C.EsaProjectID,D.EmployeeID,D.employeename,A.ProjectId,ser.serviceName,C.Esaprojectid,B.Ticketid,
A.TimesheetDate,TktDtl.[OpenDateTime],TktDtl.[Closeddate],SerLvl.[ServiceLevelID]            
,TktDtl.IsPartiallyAutomated,SerType.[ServiceTypeName],SerLvl.[ServiceLevelName] ,TktDtl.CompletedDateTime,TMDTSID.DARTStatusName 
,CC.CauseCode           
,RC.ResolutionCode  ,TechGrp.[BenchTech_Id],AppAgeCat.BenchAppAgeID   ,SAPCls.[SAPClassification_Id] ,ATMPM.[PriorityName] 
,AppDtl.ApplicationTypename ,CONVERT(NVARCHAR(100),REPLACE(AppDtl.[PrimaryTechnologyName], CHAR(9), ''))  
,CONVERT(NVARCHAR(50),REPLACE(bu.BusinessUnitName, CHAR(9), '')),  
AppDtl.BusinessCriticalityName ,DeptGrp.[BenchDept_Id] ,PA.Dept_Name   


select B.* from  #DataQualityReports A LEFT JOIN #ticketleveldata B ON A.ESAPROJECTID=B.ESAPROJECTID
WHERE B.ESAPROJECTID IS NOT NULL AND b.Efforttilldate>0
          

		  DROP TABLE #ticketleveldata
		  DROP TABLE #ProjectAssociateallocation
		  DROP TABLE #DataQualityReports 

end

