/***************************************************************************            
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET            
*Copyright [2018] – [2021] Cognizant. All rights reserved.            
*NOTICE: This unpublished material is proprietary to Cognizant and            
*its suppliers, if any. The methods, techniques and technical            
  concepts herein are considered Cognizant confidential and/or trade secret information.             
              
*This material may be covered by U.S. and/or foreign patents or patent applications.             
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.            
***************************************************************************/            
            
CREATE Proc [AVL].[Effort_GetHiddenFieldsForTM] -- '880352','7097',0               
@EmployeeID nvarchar(1000)=null,                  
@CustomerID BIGINT=NULL,    
@IsCG BIT=0  
AS                  
BEGIN                  
SET NOCOUNT ON;                  
BEGIN TRY                  
            
update avl.mas_loginmaster set EmployeeId=TRIM(EmployeeId) where EmployeeId=@EmployeeId and IsDeleted=0            
            
SELECT DISTINCT                   
ISNULL(LM.UserID,0) as UserID,                  
LM.ProjectID,                  
TZM.TZoneName AS UserTimeZone,                   
case when Cust.Timezoneid is null then null                  
when Cust.Timezoneid is not null then (select TZoneName from AVL.MAS_TimeZoneMaster (NOLOCK) where Timezoneid= Cust.Timezoneid)                    
end  as CustomerTimeZone,                  
PM.ProjectName,SW.IsApplensAsALM,EsaProjectID, 0 AS IsExempted              
into #ProjectDetails            
from AVL.MAS_LoginMaster(NOLOCK) LM                  
join AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.ProjectID=LM.ProjectID                   
join AVL.Customer(NOLOCK) Cust on LM.CustomerID=Cust.CustomerID                   
left JOIN PP.ScopeOfWork(NOLOCK) SW ON SW.ProjectID = LM.ProjectID AND ISNULL(SW.IsDeleted,0)=0                  
LEFT join AVL.RoleMaster(NOLOCK) RM on LM.RoleID=RM.RoleID                  
LEFT join AVL.MAS_TimeZoneMaster(NOLOCK) TZM on LM.TimeZoneId=TZM.TimeZoneID                  
left join  [AVL].[MAP_ProjectConfig](NOLOCK) PC ON TZM.TimeZoneId=PC.TimeZoneID                  
where LM.EmployeeID=@EmployeeID AND LM.IsDeleted = 0                   
and LM.CustomerID=@CustomerID                   
            
 IF(@IsCG=1)    
 BEGIN    
  SELECT  PD.EsaProjectId,MAX(ID) AS ID            
  into #temp1            
  FROM [AVL].[ExemptionActivityLog] (NOLOCK) EAL            
  JOIN #ProjectDetails (NOLOCK) PD            
  ON PD.EsaProjectId = EAL.AccessLevelID and EAL.IsDeleted = 0             
  WHERE ModuleID =1             
  GROUP BY PD.EsaProjectId            
  UNION            
  SELECT  PD.EsaProjectId,MAX(ID)             
  FROM [AVL].[ExemptionActivityLog] (NOLOCK) EAL            
  JOIN #ProjectDetails (NOLOCK) PD            
  ON PD.EsaProjectId = EAL.AccessLevelID and EAL.IsDeleted = 0             
  WHERE ModuleID =4            
  GROUP BY PD.EsaProjectId            
            
            
  SELECT  PD.EsaProjectId,ModuleID,EAL.[Status], EAL.OptedFor            
  into #ExemptedProjectList            
  FROM [AVL].[ExemptionActivityLog] (NOLOCK) EAL            
  JOIN #temp1 (NOLOCK) PD            
  ON PD.EsaProjectId = EAL.AccessLevelID             
  AND PD.ID = EAL.ID AND EAL.IsDeleted = 0             
            
            
  select distinct EsaProjectId ,            
  CASE WHEN (ModuleId = 1 AND ((OptedFor='Exemption' AND [Status]='Approved')             
    OR(OptedFor='Revoke' AND [Status]='Rejected')            
    OR(OptedFor='Revoke' AND [Status]='Submitted')))  THEN 1             
    ELSE  0 END            
    AS [IsExempted]            
    INTO #Module1Project            
  from #ExemptedProjectList E            
  WHERE ModuleId = 1            
            
            
            
  select distinct e.EsaProjectId ,            
  CASE WHEN (ModuleId = 4 AND ((OptedFor='Exemption' AND [Status]='Approved')             
    OR(OptedFor='Revoke' AND [Status]='Rejected')            
    OR(OptedFor='Revoke' AND [Status]='Submitted')))  THEN 1             
    ELSE  0 END            
    AS [IsExempted]            
    into  #Module4Project            
  from #ExemptedProjectList E            
  left join #Module1Project m1 on e.esaprojectid = m1.esaprojectid            
  WHERE ModuleId = 4 or m1.isexempted = 0            
           
  Select * into #ModuleProject FROM          
  (select * from #Module1Project  where isexempted = 1           
  UNION             
  select * from #Module4Project) M          
          
            
          
   --update query          
   Update #ProjectDetails set IsExempted=MP.IsExempted          
   FROM  #ModuleProject MP JOIN #ProjectDetails PD ON MP.EsaProjectId=PD.EsaProjectId          
   WHERE MP.IsExempted=1       
       
DROP TABLE #ModuleProject      
 DROP TABLE #Module4Project      
 DROP TABLE #Module1Project      
 DROP TABLE #ExemptedProjectList      
 DROP TABLE #temp1      
      
    
END    
          
 SELECT * FROM #ProjectDetails          
       
 DROP TABLE #ProjectDetails      
     
           
            
select DISTINCT                  
cust.CustomerID as CustomerID,                  
Cust.CustomerName as CustomerName,                  
RTRIM(LTRIM(LM.EmployeeID)) as EmployeeID,                  
Cust.IsEffortConfigured as IsEffortConfigured,                  
RTRIM(LTRIM(ISNULL(LM.EmployeeName,''))) as EmployeeName,                  
Cust.IsCognizant as IsCognizant,                  
0 as IsDebtEngineEnabled,                  
Cust.IsDaily as IsDaily,                  
--TZM.HourDifference as HourDifference,                  
ISNULL(RM.RoleName,'') as RoleName,                  
case when Cust.IsEncryptionEnabled is null then 0                  
when Cust.IsEncryptionEnabled is not null then 1                   
end  as IsEncryptionEnabled,                  
--                  
ISNULL(Cust.TimeZoneId,32) AS CustomerTimeZoneID,                  
TZM.TZoneName AS CustomerTimeZoneName                  
from AVL.MAS_LoginMaster(NOLOCK) LM                  
join AVL.Customer(NOLOCK) Cust on LM.CustomerID=Cust.CustomerID                   
LEFT join AVL.RoleMaster(NOLOCK) RM on LM.RoleID=RM.RoleID                  
LEFT join AVL.MAS_TimeZoneMaster(NOLOCK) TZM on  ISNULL(Cust.TimeZoneId,32)=TZM.TimeZoneID                  
where LM.EmployeeID=@EmployeeID and LM.IsDeleted=0                   
AND LM.CustomerID=@CustomerID                  
--and RM.IsActive=1                  
                  
SELECT  PM.ProjectID,PAV.AttributeValueID AS Scope,PPA.AttributeValueName AS ScopeName                  
FROM PP.ProjectAttributeValues(NOLOCK) PAV                  
join AVL.MAS_ProjectMaster(NOLOCK) PM                  
ON PM.ProjectID = PAV.ProjectID AND PAV.IsDeleted = 0 AND PM.IsDeleted = 0                  
JOIN AVL.MAS_LoginMaster(NOLOCK) LM                  
ON LM.ProjectID = PM.ProjectID AND LM.IsDeleted = 0               
left Join [MAS].[PPAttributeValues] (NOLOCK) PPA ON PAV.AttributeValueID=PPA.AttributeValueID              
WHERE  PAV.AttributeID = 1 and pm.CustomerID = @CustomerID AND LM.EmployeeID = @EmployeeID  or LM.TSApproverID = @EmployeeID             
GROUP BY PM.ProjectID,PAV.AttributeValueID,PPA.AttributeValueName                  
              
              
SELECT PP.ProjectId,TileId,TileProgressPercentage             
FROM PP.ProjectProfilingTileProgress(NOLOCK) PP            
JOIN AVL.MAS_ProjectMaster PM (NOLOCK)            
ON PM.ProjectId = PP.ProjectId AND PM.IsDeleted = 0 AND PP.IsDeleted = 0            
WHERE CustomerId = @CustomerId AND TileId in (5,10)             
            
SELECT DISTINCT ProjectID,CustomerID,HcmSupervisorID             
FROM  AVL.MAS_LoginMaster(NOLOCK) WHERE CustomerID=@CustomerID and isdeleted=0 and HcmSupervisorID IS NOT NULL             
            
END TRY                     
BEGIN CATCH             
                  
  DECLARE @ErrorMessage VARCHAR(MAX);                  
                  
  SELECT @ErrorMessage = ERROR_MESSAGE()                  
                  
  --INSERT Error                      
  EXEC AVL_InsertError '[AVL].[Effort_GetHiddenFieldsForTM]', @ErrorMessage, @EmployeeID,0                  
        
 END CATCH             
 SET NOCOUNT OFF;            
END
