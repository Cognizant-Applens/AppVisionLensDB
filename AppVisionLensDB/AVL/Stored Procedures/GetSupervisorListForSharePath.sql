CREATE PROC [AVL].[GetSupervisorListForSharePath]       
@ProjectID BIGINT=NULL      
AS      
BEGIN      
SET NOCOUNT ON;      
BEGIN TRY      
SELECT DISTINCT C.CustomerID, C.CustomerName, PM.ProjectID, PM.EsaProjectID, PM.ProjectName AS AccountName
FROM AVL.MAS_ProjectMaster (NOLOCK) PM
JOIN AVL.Customer (NOLOCK) C
ON C.CustomerID = PM.CustomerID AND C.IsDeleted = 0 AND PM.IsDeleted = 0
WHERE PM.ProjectID = @ProjectID

SELECT DISTINCT ProjectID,CustomerID,EmployeeID AS HcmSupervisorID
FROM  AVL.MAS_LoginMaster(NOLOCK) WHERE ProjectID=@ProjectID 
AND isdeleted=0 AND EmployeeID IS NOT NULL 
Union
SELECT DISTINCT ProjectID,CustomerID,HcmSupervisorID
FROM  AVL.MAS_LoginMaster(NOLOCK) WHERE ProjectID=@ProjectID
AND isdeleted=0 AND HcmSupervisorID IS NOT NULL 

END TRY         
BEGIN CATCH        
      
  DECLARE @ErrorMessage VARCHAR(MAX);      
      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
      
  --INSERT Error          
  EXEC AVL_InsertError '[AVL].[GetSupervisorListForSharePath]', @ErrorMessage, 'system',0      
        
 END CATCH 
 SET NOCOUNT OFF;
END
