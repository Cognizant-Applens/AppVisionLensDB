CREATE PROCEDURE [dbo].[Debt_GetTicketsForAutoClassification_DD] --10337    
@BatchProcessId Bigint=NULL,     
@PROJECTID INT    
AS      
    
BEGIN      
BEGIN TRY    
BEGIN TRAN    
SET NOCOUNT ON;     
    
DECLARE @AlgorithmKey nvarchar(6);      
  SET @AlgorithmKey =ISNULL( (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@PROJECTID AND ISNULL(IsActiveTransaction,0)=1 AND IsDeleted=0 AND SupportTypeId=1),'AL002')    
      
 IF(@AlgorithmKey='AL001')        
 BEGIN      
    
SELECT [Ticket ID],[Ticket Description],ApplicationName AS ApplicationName,    
    
ApplicationID AS ApplicationID     
    
FROM AVL.TK_MLClassification_TicketUpload    
    
WHERE PROJECTID=@PROJECTID --AND EmployeeID=@CogID     
    
AND [Ticket ID] NOT IN (SELECT [TicketID] FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) TD     
JOIN AVL.MAS_ProjectDebtDetails PD (NOLOCK) ON PD.ProjectID=TD.ProjectID  WHERE TD.ProjectID=@PROJECTID AND PD.IsDDAutoClassifiedDate > TD.CreatedDate)    
AND (IsApprover=0 or IsApprover is null) and SupportType = 1    
END    
ELSE IF(@AlgorithmKey='AL002')        
  BEGIN          
  SELECT ML.[TicketId],            
   TD.[TicketDescription],            
   (SELECT TOP 1 AD.ApplicationName from [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) APM            
   Join [AVL].[APP_MAS_ApplicationDetails] AD on APM.ApplicationID = AD.ApplicationID            
   where APM.projectID = @ProjectId and APM.isdeleted = 0) as 'ApplicationName',             
   ML.[ApplicationId] AS ApplicationID             
            
  FROM ML.TicketsforAutoClassification ML JOIN ML.AutoClassificationBatchProcess AC ON ML.BatchProcessId=AC.BatchProcessId        
  JOIN [AVL].[TK_TRN_TicketDetail] TD ON ML.TicketId=TD.TicketID AND AC.ProjectId=TD.ProjectID    
            
  WHERE AC.ProjectId=@PROJECTID           
            
  AND ML.[TicketId] NOT IN (SELECT [TicketID] FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) TD             
  JOIN AVL.MAS_ProjectDebtDetails PD (NOLOCK) ON PD.ProjectID=TD.ProjectID  WHERE TD.ProjectID=@PROJECTID AND PD.IsDDAutoClassifiedDate > TD.CreatedDate 
  OR TD.DebtClassificationMode = 5) --Restrict Override the Manual tickets          
  AND (ML.ClusterID_Desc=0 OR ML.ClusterID_Desc IS NULL) AND ML.BatchProcessId=@BatchProcessId      
  AND SupportType = 1        
 END          
    
SET NOCOUNT OFF;      
COMMIT TRAN    
END TRY      
BEGIN CATCH      
    
  DECLARE @ErrorMessage VARCHAR(MAX);    
    
  SELECT @ErrorMessage = ERROR_MESSAGE()    
  ROLLBACK TRAN    
  --INSERT Error        
  EXEC AVL_InsertError 'dbo.Debt_GetTicketsForAutoClassification_DD', @ErrorMessage, 0 ,0    
      
 END CATCH      
    
END 