                                              
CREATE PROCEDURE [ML].[GetAppMLValidTickets] --'868','24940','2022-09-23 00:00:00.000','2022-09-23 00:00:00.000','880352',0,0                              
@TransactionId bigint,                                                                                      
@ProjectId int,                                                                                                         
@FromDate Date,                                                                                                              
@ToDate Date,                                                                                                      
@UserID NVARCHAR(50),                                                                
@EncEnable bit,                                                              
@IsRegenerate bit                                                              
                                                              
AS                                                                                                      
BEGIN                                                                                                      
 BEGIN TRY                                                                                                       
     BEGIN TRAN                                                                                                  
SET NOCOUNT ON;                                          
                                
CREATE TABLE #Temp_TicketsToDecrypt (TicketId Varchar(200), EncryptedTicketDescription varchar(max), DecryptedTicketDescription varchar(max),                                
EncryptedSummaryDescription varchar(max), DecryptedSummaryDescription varchar(max))                                
                                
                                      
If (@IsRegenerate=0)                                      
BEGIN                                      
UPDATE A SET                                       
A.ModelAccuracy = NULL                                             
FROM [ML].[TRN_MLTransaction] A                                                                 
Where A.TransactionId = @TransactionId                                      
END                                      
                                                
 DECLARE @IL_key nvarchar(6) = 'LT002';                                              
 DECLARE @RE_Key NVARCHAR(6) = 'LT003';                                            
 DECLARE @IsCognizant INT;                                                                                
 DECLARE @CustomerID BIGINT;                                                                                
 SET @CustomerID =(SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectId AND ISNULL(IsDeleted,0)=0)                                                                                
 SET @IsCognizant=(SELECT ISNULL(IsCognizant,0) FROM AVL.Customer(NOLOCK)  WHERE CustomerID=@CustomerID)                                                                                                                            
                                
SELECT * INTO #ML_TRN_ClusteringValidation FROM (                                                                                                    
            SELECT DISTINCT                                                                                         
   TD.ProjectID,                                                                                                      
   TD.TicketID AS TicketID,                                                                                                         
            TD.TicketDescription AS TicketDescription,                                                                                                         
            TD.ApplicationID,                                                       
   TD.TicketSummary,              
   TD.TicketTypeMapID AS TicketTypeID,                                      
            [DebtClassificationMapID] AS DebtClassificationID,                                                      
            AvoidableFlag             AS [AvoidableFlagID],                              
            [ResidualDebtMapID]       AS [ResidualDebtID],                                                                                         
            [CauseCodeMapID]          AS CauseCodeID,                                             
            [ResolutionCodeMapID]     AS ResolutionCodeID,                                                                                                   
            @UserID AS CreatedBy,                                                                                                         
        Getdate() AS CreatedDate,                                       
            0 AS IsDeleted  ,                                            
   @FromDate AS FromDate,                                            
   @ToDate AS ToDate                                            
     FROM  [AVL].[TK_TRN_TICKETDETAIL] TD(NOLOCK)                                                                                                                        
     JOIN AVL.MAS_ProjectMaster PM(NOLOCK) ON PM.ProjectID = TD.ProjectID                                                                                                         
     JOIN AVL.APP_MAS_ApplicationDetails AD(NOLOCK) ON TD.ApplicationID = AD.ApplicationID AND AD.IsActive = 1                                                                    
  JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) appMap ON AD.ApplicationID = appMap.ApplicationID                                              
  AND TD.ProjectId=appMap.ProjectId AND appMap.IsDeleted = 0                                                                    
     WHERE  TD.ProjectID = @ProjectId                                                                                                        
     AND ((DARTStatusID = 8 AND ClosedDate BETWEEN @FromDate AND @ToDate) OR                                                                                                        
     (DARTStatusID = 9 AND CompletedDateTime BETWEEN @FromDate AND @ToDate))                                                                                       
AND PM.IsDeleted = 0 and TD.Isdeleted = 0 ) AS CTE    
  
SELECT * INTO #TempValid FROM #ML_TRN_ClusteringValidation

--------Fix for duplicate  
--DELETE CV FROM   
--#TempValid CV  
--JOIN  ML.TRN_ClusteringTicketValidation_App(NOLOCK) CTV  
--ON CV.TicketId = CTV.TicketId AND CV.ProjectId = CTV.ProjectId and CTV.MLTransactionId = @TransactionId  


--Fix for deleting IL Application in regenerate
IF(@IsRegenerate=1)
BEGIN
------Fix for duplicate  
DELETE CV FROM   
#TempValid CV  
JOIN  ML.TRN_ClusteringTicketValidation_App(NOLOCK) CTV  
ON CV.TicketId = CTV.TicketId AND CV.ProjectId = CTV.ProjectId and CTV.MLTransactionId = @TransactionId  

SELECT DISTINCT ApplicationId INTO #TempILApplication
FROM  ML.TRN_ClusteringTicketValidation_App(NOLOCK) CTV WHERE CTV.MLTransactionId = @TransactionId  
AND CTV.IsSelected=1 AND CTV.Isdeleted=0

DELETE CV FROM   
#TempValid CV  
JOIN  #TempILApplication(NOLOCK) CTV  
ON  CV.ApplicationId = CTV.ApplicationId 

END
--------Fix for duplicate  
                                                
   --IF @IsCognizant = 0                                                                                
     --BEGIN                                                     
     -- DELETE  FROM #ML_TRN_ClusteringValidation                                                                                
     --END                                                                    
     --ELSE                                                                                
     --BEGIN                                                                             
     -- DELETE TV  FROM #ML_TRN_ClusteringValidation   TV                                                                                
     -- INNER JOIN AVL.TK_MAP_TicketTypeMapping TVM                                                                                
     -- ON TV.TicketTypeID=TVM.TicketTypeMappingID AND TVM.DebtConsidered ! ='Y'                                                                                
     --END                                                                                 
                                                                              
IF ((Select COUNT(*) FROM ML.TRN_ClusteringTicketValidation_App WHERE MLTransactionID = @TransactionId) = 0 )                                                                            
BEGIN                                                                            
INSERT INTO ML.TRN_ClusteringTicketValidation_App (                                     
MLTransactionId,                                                                       
ProjectID,                                                             
TicketID,                                                                                             
TicketDescription,                                                      
TicketSummary,                                                 
ApplicationID,                                                            
DebtClassificationID,                                                                                                  
AvoidableFlagID,                                                                                                    
ResidualDebtID,                                          
CauseCodeID,                      
ResolutionCodeID,                                                                                                    
CreatedBy,                                            
CreatedDate,                                                                                                    
IsDeleted,                                                                        
IsSelected,                                                
TicketType,                                            
FromDate,                                            
ToDate)                                                                                       
Select                                                                                
   @TransactionId,                                            
   ProjectID,                                                                                                      
   TicketID,                                                                                                
   TicketDescription,                                                      
   TicketSummary,                                                    
   ApplicationID,                                                 
   DebtClassificationID,                                                                                          
   AvoidableFlagID,                                                                                                    
   ResidualDebtID,                                                                                                       
   CauseCodeID,                                                                                                     
   ResolutionCodeID,                                                   
   CreatedBy,                                                                                                    
   CreatedDate,                                                                                                    
IsDeleted,                                                   
0,@IL_key,                                            
@FromDate,                                            
@ToDate                                            
From #TempValid                                                                                       
END                                                                            
ELSE                                                                            
BEGIN                                                                  
IF @IsRegenerate = 0                                                               
BEGIN                                                              
 DELETE FROM ML.TRN_ClusteringTicketValidation_App WHERE MLTransactionID = @TransactionId                                               
                                            
 INSERT INTO ML.TRN_ClusteringTicketValidation_App (                                                                                                     
MLTransactionId,                                                                                               
ProjectID,                                                                                                    
TicketID,                                                                                               
TicketDescription,                                                     
TicketSummary,                                                    
ApplicationID,                                                      
DebtClassificationID,                                                                                                  
AvoidableFlagID,                                 
ResidualDebtID,                                                                                                    
CauseCodeID,                                                                                                    
ResolutionCodeID,                                         
CreatedBy,                                                                                                    
CreatedDate,                                                                                      
IsDeleted,                                                                        
IsSelected,                                                
TicketType,                                            
FromDate,                       
ToDate)                                                                                                 
Select                                                                                                   
   @TransactionId,                                                                                
   ProjectID,                                                                       
   TicketID,                                                                                            
   TicketDescription,                                                        
   TicketSummary,                                                    
   ApplicationID,                                                                        
   DebtClassificationID,                                                                                                  
   AvoidableFlagID,                                                                                                    
   ResidualDebtID,                                                                        
   CauseCodeID,                                                                                                     
   ResolutionCodeID,                                                                                                      
   CreatedBy,                                  
   CreatedDate,                                                                                                    
IsDeleted ,                                                                        
0,@IL_Key,                                            
@FromDate,                                            
@ToDate                                            
From #TempValid                                                                   
END                                                              
ELSE                                                             
BEGIN                                                              
 --DELETE A FROM #ML_TRN_ClusteringValidation A                                             
 --INNER JOIN ML.TRN_ClusteringTicketValidation_App B ON A.ApplicationID=B.ApplicationID AND B.MLTransactionId=@TransactionId                                            
                                            
 INSERT INTO ML.TRN_ClusteringTicketValidation_App (                                                                                             
MLTransactionId,                                                                                              
ProjectID,                                                                                                    
TicketID,                                                                                                    
TicketDescription,                                                     
TicketSummary,               
ApplicationID,                                                                                                    
DebtClassificationID,                                       
AvoidableFlagID,                                                                                                    
ResidualDebtID,                                                                                          
CauseCodeID,                                                                                          
ResolutionCodeID,                                                     
CreatedBy,                                                                         
CreatedDate,                                                              
IsDeleted,                                             
ClusterID_Desc,                                            
ClusterID_Resolution,                                            
IsSelected,                                                
TicketType,                                            
FromDate,                                            
ToDate)                                                                                                 
Select                                                                                       
   @TransactionId,                                       
   ProjectID,                                                                       
   TicketID,                                                                                                    
   TicketDescription,                                                        
   TicketSummary,                                                    
   ApplicationID,                                                                                       
   DebtClassificationID,                                                                                                  
   AvoidableFlagID,                                                                           
   ResidualDebtID,                                                                  
   CauseCodeID,                                                                                                     
   ResolutionCodeID,                                                
   CreatedBy,                                                              
   CreatedDate,                                                        
IsDeleted ,                                            
NULL,                                            
NULL,                                            
ISNULL((Select TOP 1 isSelected from ML.TRN_ClusteringTicketValidation_App CTV where CTV.MLTransactionId = @TransactionId and                       
 CTV.ApplicationID = Temp.ApplicationID AND (CTV.TicketType = 'LT002' OR CTV.TicketType = 'LT003')),0),                        
@RE_Key,                                            
@FromDate,                                            
@ToDate                                            
From #TempValid Temp                                                              
END                                            
                 
--IF(Select Count(*) From #ML_TRN_ClusteringValidation) >0                
--BEGIN                
--UPDATE [ML].[ClusteringCLProjects] SET JobStatusKey='SK001', IsManual=0 WHERE TransactionId=@TransactionId                   
--END                
                                          
END                                       
                                                                
IF @EncEnable = 0                    
     BEGIN                                                                                
     Update  ML.TRN_ClusteringTicketValidation_App set DescriptionText= TicketDescription where MLTransactionID = @TransactionId                                                                     
     END                                                                 
                                          
INSERT INTO #Temp_TicketsToDecrypt                                 
SELECT TicketId,TicketDescription AS EncryptedTicketDescription,'' AS DecryptedTicketDescription,TicketSummary As EncryptedSummaryDescription,                                
'' As DecryptedSummaryDescription FROM #ML_TRN_ClusteringValidation                                
                                
IF (@IsRegenerate = 1  AND (SELECT COUNT(*) FROM  #Temp_TicketsToDecrypt)>0)                             
BEGIN                    
 INSERT INTO #Temp_TicketsToDecrypt                                
 SELECT TicketId,TicketDescription AS EncryptedTicketDescription,'' AS DecryptedTicketDescription,TicketSummary As EncryptedSummaryDescription,                                
 '' As DecryptedSummaryDescription                                
 from ML.TRN_ClusteringTicketValidation_App                                 
 where MLTransactionId = @TransactionId and ClusterID_Desc IS NOT NULL AND IsDeleted = 0                                
END                               
                            
SELECT * FROM #Temp_TicketsToDecrypt                                
                              
DROP TABLE #ML_TRN_ClusteringValidation                                                                                       
   COMMIT TRAN                                                                                   
END TRY                                                                                      
BEGIN CATCH                                                 
 ROLLBACK TRAN                                      
          DECLARE @ErrorMessage VARCHAR(MAX);                                                                                                        
          SELECT @ErrorMessage = ERROR_MESSAGE()                                                                                                       
                                                                     
          --INSERT Error                                                                       
      EXEC AVL_INSERTERROR                                                                                                       
            '[ML].[GetAppMLValidTickets]',                                                                                                       
            @ErrorMessage,                                                                                                       
            @ProjectId,                                                                                               
            0                                                                                                          
      END CATCH                                                                                                       
  END 
