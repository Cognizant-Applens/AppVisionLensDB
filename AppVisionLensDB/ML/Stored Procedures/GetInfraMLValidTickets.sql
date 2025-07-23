CREATE PROCEDURE [ML].[GetInfraMLValidTickets] --'10337','2018-12-05 00:00:00.000','2018-12-05 00:00:00.000','880352'                                                                                 
@TransactionId bigint,                                                                  
@ProjectId int,                                                                                     
@FromDate Date,                                                                                          
@ToDate Date,                                                                                  
@UserID NVARCHAR(50),                                            
@EncEnable BIT,                                            
@IsRegenerate bit                                          
AS                                                                                  
BEGIN                                                                                  
 BEGIN TRY                                                                                   
                                                                                   
SET NOCOUNT ON;                                                              
                        
                  
CREATE TABLE #Temp_TicketsToDecrypt (TicketId Varchar(200), EncryptedTicketDescription varchar(max), DecryptedTicketDescription varchar(max),                              
EncryptedSummaryDescription varchar(max), DecryptedSummaryDescription varchar(max))                              
                
DECLARE @IL_Key nvarchar(6) = 'LT002';                             
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
   TD.TicketSummary,                                    
            TD.TowerID,                                                            
   TD.TicketTypeMapID AS TicketTypeID,                                                     
            [DebtClassificationMapID] AS DebtClassificationID,                                                                                     
            AvoidableFlag             AS [AvoidableFlagID],                                                                                     
            [ResidualDebtMapID]       AS [ResidualDebtID],                                                                                     
            [CauseCodeMapID]          AS CauseCodeID,                                                                                     
            [ResolutionCodeMapID]     AS ResolutionCodeID,                                                                                          
            @UserID AS CreatedBy,                                                                                     
            Getdate() AS CreatedDate,                                                                                     
            0 AS IsDeleted,                            
   @FromDate AS FromDate,                            
   @ToDate AS ToDate                            
     FROM  [AVL].[TK_TRN_InfraTicketDetail] TD(NOLOCK)                                 
     JOIN AVL.MAS_ProjectMaster PM(NOLOCK) ON PM.ProjectID = TD.ProjectID                                                                                     
     JOIN AVL.InfraTowerDetailsTransaction AD(NOLOCK) ON TD.TowerID = AD.InfraTowerTransactionID AND AD.IsDeleted = 0                                                     
  JOIN [AVL].[InfraTowerProjectMapping](NOLOCK) IT ON TD.ProjectId=IT.ProjectId And TD.TowerId = IT.TowerId and IT.IsDeleted=0                                                
  AND IT.IsEnabled=1                                              
     WHERE  TD.ProjectID = @ProjectId                                                            
     AND ((DARTStatusID = 8 AND ClosedDate BETWEEN @FromDate AND @ToDate) OR                                                                                    
    (DARTStatusID = 9 AND CompletedDateTime BETWEEN @FromDate AND @ToDate))                                                         
  AND PM.IsDeleted = 0 and TD.Isdeleted = 0) AS CTE  

  SELECT * INTO #TempValid FROM #ML_TRN_ClusteringValidation  
  
  --Fix for deleting IL Application in regenerate  
IF(@IsRegenerate=1)  
BEGIN  
------Fix for duplicate    
DELETE CV FROM     
#TempValid CV    
JOIN  ML.TRN_ClusteringTicketValidation_Infra(NOLOCK) CTV    
ON CV.TicketId = CTV.TicketId AND CV.ProjectId = CTV.ProjectId and CTV.MLTransactionId = @TransactionId    
  
SELECT DISTINCT TowerId INTO #TempILApplication  
FROM  ML.TRN_ClusteringTicketValidation_Infra(NOLOCK) CTV WHERE CTV.MLTransactionId = @TransactionId    
AND CTV.IsSelected=1 AND CTV.Isdeleted=0  
  
DELETE CV FROM     
#TempValid CV    
JOIN  #TempILApplication(NOLOCK) CTV    
ON  CV.TowerId = CTV.TowerId   
  
END  
                                                            
 
    
IF ((Select COUNT(*) FROM ML.TRN_ClusteringTicketValidation_Infra WHERE MLTransactionID = @TransactionId) = 0 )                                                            
BEGIN                                                       
INSERT INTO ML.TRN_ClusteringTicketValidation_Infra (                                               
MLTransactionId,                                           
ProjectID,                                                                                
TicketID,                                                                                
TicketDescription,                                         
TicketSummary,                                    
TowerId,                                                                                
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
   TowerId,                                                                                
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
IF @IsRegenerate = 0                   
BEGIN                                           
DELETE FROM ML.TRN_ClusteringTicketValidation_Infra WHERE MLTransactionID = @TransactionId                                                            
                                                  
INSERT INTO ML.TRN_ClusteringTicketValidation_Infra (                                                                                 
MLTransactionId,                                                                                
ProjectID,                                                                               
TicketID,                                                                                
TicketDescription,                                      
TicketSummary,                                    
TowerId,                                                                                
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
   TowerId,                                                                                
   DebtClassificationID,                                                 
   AvoidableFlagID,                                                                                
   ResidualDebtID,                                                                                   
   CauseCodeID,                                                                                 
   ResolutionCodeID,                                                                                  
   CreatedBy,                                                                                
   CreatedDate,                                                                       
   IsDeleted,                                                  
   0,@IL_Key ,                            
   @FromDate,                            
   @ToDate                            
From #TempValid                                           
END                                          
ELSE                                              
BEGIN                                           
                         
 INSERT INTO ML.TRN_ClusteringTicketValidation_Infra (                                                                                     
MLTransactionId,                          
ProjectID,                                                                                    
TicketID,                                                                                    
TicketDescription,                                     
TicketSummary,                                    
TowerID,                                                         
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
   TowerID,                                                                                    
   DebtClassificationID,                                                                                  
   AvoidableFlagID,                                                                                    
   ResidualDebtID,                                                                                       
   CauseCodeID,                                                                                     
   ResolutionCodeID,                                                                                      
   CreatedBy,                                              
   CreatedDate,                        
IsDeleted ,                            
0,                            
0,                            
ISNULL((Select TOP 1 isSelected from ML.TRN_ClusteringTicketValidation_Infra CTV where CTV.MLTransactionId = @TransactionId and                     
 CTV.TowerID = Temp.TowerID AND (CTV.TicketType = 'LT002' OR CTV.TicketType = 'LT003')),0),                
@RE_Key,                            
@FromDate,                            
@ToDate                            
From #TempValid Temp                              
END                            
              
--IF(Select Count(*) From #ML_TRN_ClusteringValidation) >0                
--BEGIN                           
--UPDATE [ML].[ClusteringCLProjects] SET JobStatusKey='SK001',IsManual=0 WHERE TransactionId=@TransactionId                          
--END              
              
                          
END                       
 IF @EncEnable = 0                                                            
     BEGIN                                                            
     Update ML.TRN_ClusteringTicketValidation_Infra set DescriptionText= TicketDescription where MLTransactionID = @TransactionId                                                         
     END                    
                
INSERT INTO #Temp_TicketsToDecrypt                               
SELECT TicketId,TicketDescription AS EncryptedTicketDescription,'' AS DecryptedText,TicketSummary As EncryptedSummaryDescription,                                  
'' As DecryptedSummaryText  FROM #ML_TRN_ClusteringValidation                                                  
                                             
                              
IF (@IsRegenerate = 1 AND (SELECT COUNT(*) FROM  #Temp_TicketsToDecrypt)>0)          
BEGIN                              
 INSERT INTO #Temp_TicketsToDecrypt                              
 SELECT TicketId,TicketDescription AS EncryptedTicketDescription,'' AS DecryptedText,TicketSummary As EncryptedSummaryDescription,                              
 '' As DecryptedSummaryText                              
 from ML.TRN_ClusteringTicketValidation_Infra                               
 where MLTransactionId = @TransactionId and ClusterID_Desc IS NOT NULL AND IsDeleted = 0                              
END                    
                
SELECT * FROM #Temp_TicketsToDecrypt                                                                    
DROP TABLE #ML_TRN_ClusteringValidation                                                                   
                                                                  
END TRY                                  
BEGIN CATCH                                                                   
          DECLARE @ErrorMessage VARCHAR(MAX);                                                                                   
          SELECT @ErrorMessage = ERROR_MESSAGE()                                                                                   
                                                                                  
          --INSERT Error                                       
      EXEC AVL_INSERTERROR                                                                                   
            '[ML].[GetInfraMLValidTickets]',                                              
            @ErrorMessage,                                                                                   
            @ProjectId,                                                                                   
            0                                                  
      END CATCH                                                              
  END 