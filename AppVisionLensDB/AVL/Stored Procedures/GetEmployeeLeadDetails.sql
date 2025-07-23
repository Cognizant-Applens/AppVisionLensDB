-- Author      : Shobana  
-- Create date : 12 Feb 2020  
-- Description : Procedure to Get Employee Lead Details               
-- Test        : [AVL].[GetEmployeeLeadDetails] 1188,'674078'  
-- Revision    :  
-- Revised By  :  
-- =========================================================================================  
CREATE PROCEDURE [AVL].[GetEmployeeLeadDetails]    
(     
@ProjectID BIGINT,  
@EmployeeID NVARCHAR(50)       
)        
AS        
BEGIN
SET NOCOUNT ON;
 BEGIN TRY         
        
SELECT LM.ProjectID, LM.TSApproverID   
INTO #ProjectLeadDetails   
FROM AVL.MAS_LoginMaster(NOLOCK) LM        
INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM   
ON LM.ProjectID=PM.ProjectID        
WHERE LM.EmployeeID=@EmployeeID AND LM.ProjectID=@ProjectID AND LM.IsDeleted=0 AND PM.IsDeleted=0     
  
SELECT PM.ProjectID,EP.ProjectManagerID   
INTO #ProjectManagerDetails  
FROM AVL.MAS_ProjectMaster(NOLOCK) PM  
LEFT JOIN ESA.Projects(NOLOCK) EP  
ON EP.ID = PM.EsaProjectID  
WHERE PM.ProjectID = @ProjectID AND PM.IsDeleted = 0  
  
  
SELECT PD.ProjectID,EmployeeName AS TSApproverName   
INTO #ProjectApproverDetails  
FROM AVL.MAS_LoginMaster LM (NOLOCK)   
JOIN #ProjectLeadDetails(NOLOCK) PD  
ON PD.TSApproverID = LM.EmployeeID    
AND LM.ProjectID=@ProjectID  
  
  
SELECT PD.ProjectID,EmployeeName AS ManagerName  
INTO #ProjectManagerNameDetails  
FROM AVL.MAS_LoginMaster LM (NOLOCK)   
JOIN #ProjectManagerDetails(NOLOCK) PD  
ON PD.ProjectManagerID = LM.EmployeeID    
AND LM.ProjectID=@ProjectID  
  
  
SELECT PD.ProjectID,   
CASE WHEN (ISNULL(PD.TSApproverID,'') = '' OR ISNULL(PAD.TSApproverName,'') = '') THEN ''   
ELSE CONCAT(PD.TSApproverID,' - ',PAD.TSApproverName) END  AS TSApprover,  
CASE WHEN (ISNULL(PM.ProjectManagerID,'') = ''  OR ISNULL(PMD.ManagerName,'') = '') THEN ''   
ELSE CONCAT(PM.ProjectManagerID,' - ',PMD.ManagerName) END  AS Manager  
INTO #UserIconDetails  
FROM #ProjectLeadDetails PD (NOLOCK) 
LEFT JOIN #ProjectManagerDetails PM (NOLOCK)
    ON PM.ProjectID =PD.ProjectID  
LEFT JOIN  #ProjectApproverDetails PAD (NOLOCK)  
ON PAD.ProjectID = PD.ProjectID  
LEFT JOIN  #ProjectManagerNameDetails PMD (NOLOCK)  
ON PMD.ProjectID = PD.ProjectID  
  
SELECT DISTINCT PM.ProjectID, UM.EmployeeID    
INTO #AdminDetails   
FROM AVL.UserRoleMapping UM (NOLOCK)       
INNER JOIN AVL.MAS_LoginMaster LM (NOLOCK)  
ON UM.AccessLevelID=LM.ProjectID        
INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK)   
ON LM.ProjectID=PM.ProjectID        
WHERE LM.EmployeeID=@EmployeeID AND LM.ProjectID=@ProjectID AND LM.IsDeleted=0        
AND PM.IsDeleted=0 AND UM.IsActive=1 AND UM.AccessLevelSourceID=4 AND UM.RoleID in (6,7)        
      
  
    SELECT DISTINCT ProjectID, EmployeeIDs   
INTO #AdminList      
    FROM #AdminDetails v1 (NOLOCK)     
CROSS APPLY ( SELECT TOP 5 EmployeeID + ', '       
    FROM #AdminDetails v2 (NOLOCK)      
    WHERE v2.ProjectID = v1.ProjectID   
ORDER BY v2.EmployeeID      
    FOR XML PATH('') )  D ( EmployeeIDs )      
    
    IF EXISTS (SELECT 1 FROM #AdminList(NOLOCK))  
BEGIN  
SELECT ISNULL(UD.TSApprover,'') AS ProjectTSApprover,ISNULL(UD.Manager,'') AS ProjectManager ,  
CASE WHEN RIGHT(RTRIM(EmployeeIDs),1) = ',' THEN SUBSTRING(RTRIM(EmployeeIDs),1,LEN(RTRIM(EmployeeIDs))-1)    
ELSE EmployeeIDs END AS ProjectAdmin    
FROM #AdminList AS AL (NOLOCK)   
LEFT JOIN  #UserIconDetails UD (NOLOCK)   
ON UD.ProjectID=AL.ProjectID    
END  
ELSE  
BEGIN  
SELECT ISNULL(UD.TSApprover,'') AS ProjectTSApprover,ISNULL(UD.Manager,'') AS ProjectManager ,''  AS ProjectAdmin   
FROM #UserIconDetails UD (NOLOCK)  
END  
    
DROP TABLE #ProjectLeadDetails      
DROP TABLE #UserIconDetails  
DROP TABLE #ProjectApproverDetails      
DROP TABLE #AdminDetails  
DROP TABLE #ProjectManagerDetails  
DROP TABLE #ProjectManagerNameDetails  
DROP TABLE #AdminList  
  
 END TRY        
        
BEGIN CATCH  
DECLARE @ErrorMessage VARCHAR(MAX);        
SELECT @ErrorMessage = ERROR_MESSAGE()        
EXEC AVL_InsertError 'GetEmployeeLeadDetails', @ErrorMessage, @ProjectID, @EmployeeID         
END CATCH    
SET NOCOUNT OFF;
END
