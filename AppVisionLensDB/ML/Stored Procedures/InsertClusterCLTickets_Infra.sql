  -- =============================================                              
-- Author:  699158                             
-- Create date: <15/06/2022>                              
-- Description: <New Model Algo -Clustering job for App>                             
CREATE PROCEDURE [ML].[InsertClusterCLTickets_Infra]                                                   
AS                                                  
BEGIN                                                  
BEGIN TRY                                      
BEGIN TRAN                  
 -- SET NOCOUNT ON added to prevent extra result sets from                                                  
 -- interfering with SELECT statements.                                                  
 SET NOCOUNT ON;                                                  
                               
 -- Declaration                              
 DECLARE @CL_Key nvarchar(6) = 'LT001', @IL_Key nvarchar(6) = 'LT002',  @RE_Key  nvarchar(6) = 'LT003',                               
 @MLOverridden_Key nvarchar(6) = 'LT005' , @Manual_Key nvarchar(6) = 'LT004', @UnClassified_Key nvarchar(6) = 'LT006' ,                              
 @PendingStatusKey NVarchar(6) ='SK001'                              
                        
                        
 --Get Applicable Projects                               
 SELECT * Into #tmpClusteringCLProjects FROM (                              
 SELECT                                  
 CLP.ClusterCLID,MLTRN.TransactionId,CLP.ProjectID, MLTRN.SignOffDate, MLTRN.SupportTypeId                                
 FROM [ML].[ClusteringCLProjects] CLP                                                  
 INNER JOIN ML.TRN_MLTransaction MLTRN ON CLP.TransactionID = MLTRN.TransactionId                              
 Where CONVERT(DATE, CLP.JobRunDate) <= CONVERT(DATE, GETDATE())                   
 AND CLP.IsDeleted=0 AND MLTRN.IsDeleted=0 AND MLTRN.IsActiveTransaction=1                              
 AND MLTRN.SupportTypeId=2  AND ISNULL(CLP.IsRegenerate,0) = 0                              
 )t                              
                               
 UPDATE A Set A.JobStatusKey =@PendingStatusKey FROM [ML].[ClusteringCLProjects] A                              
 Inner JOIN #tmpClusteringCLProjects B ON A.ClusterCLID=B.ClusterCLID                              
                                
 --Create Temp table for Adding tickets                              
 Create table #CLTickets (TransactionId INT,ProjectID BIGINT,TicketID NVARCHAR(MAX),TicketDescription NVARCHAR(MAX),                                  
  TowerId BIGINT,DebtClassificationMode INT,AvoidableFlag INT,ResidualDebtMapID BIGINT,                                  
  CauseCodeMapID BIGINT,ResolutionCodeMapID BIGINT,TicketSummary NVARCHAR(MAX) ,TicketType NVARCHAR(6),                                  
  ClusterID_Desc BIGINT,ClusterID_Resolution BIGINT)                                  
                                  
 --MLOverrriden Tickets For Infra                                         
   INSERT INTO #CLTickets(TransactionId,ProjectID,TicketID,TicketDescription,TowerId,DebtClassificationMode,AvoidableFlag,                                                  
 ResidualDebtMapID,CauseCodeMapID,ResolutionCodeMapID,TD.TicketSummary,                                  
 TicketType,ClusterID_Desc,ClusterID_Resolution )                                   
 SELECT                                  
 CLP.TransactionId,ITD.ProjectID,ITD.TicketID,ITD.TicketDescription,ITD.TowerId,ITD.DebtClassificationMapID,ITD.AvoidableFlag,                                                  
 ITD.ResidualDebtMapID,ITD.CauseCodeMapID,ITD.ResolutionCodeMapID,ITD.TicketSummary,                                  
@MLOverridden_Key,0,0      
 FROM #tmpClusteringCLProjects CLP                                                 
 INNER JOIN [AVL].[TK_TRN_InfraTicketDetail] ITD ON ITD.ProjectID = CLP.ProjectId                                                  
 INNER JOIN [AVL].[TK_TRN_InfraTicketDetail_RuleID] TDR ON ITD.TimeTickerID = TDR.TimeTickerID                                                  
 where ITD.DebtClassificationMode = 2  AND ITD.IsDeleted = 0 
  AND ITD.ClosedDate is not null AND CONVERT(DATE, CLP.SignOffdate) <= CONVERT(DATE,ITD.ClosedDate) 
                        
 --Manual Debt Mode Tickets For Infra                        
 INSERT INTO #CLTickets(TransactionId,ProjectID,TicketID,TicketDescription,TowerId,DebtClassificationMode,AvoidableFlag,                                                  
 ResidualDebtMapID,CauseCodeMapID,ResolutionCodeMapID,TD.TicketSummary,                                  
 TicketType,ClusterID_Desc,ClusterID_Resolution )                   
 SELECT                                  
 CLP.TransactionId,ITD.ProjectID,ITD.TicketID,ITD.TicketDescription,ITD.TowerId,ITD.DebtClassificationMapID,ITD.AvoidableFlag,                                                  
 ITD.ResidualDebtMapID,ITD.CauseCodeMapID,ITD.ResolutionCodeMapID,ITD.TicketSummary,                                  
@Manual_Key,0,0          
 FROM #tmpClusteringCLProjects CLP                                                
 INNER JOIN [AVL].[TK_TRN_InfraTicketDetail] ITD ON ITD.ProjectID = CLP.ProjectId                                               
 where ITD.DebtClassificationMode = 5  AND ITD.IsDeleted = 0  AND ITD.ClosedDate is not null                             
 AND CONVERT(DATE, CLP.SignOffdate) <= CONVERT(DATE,ITD.ClosedDate)                            
                       
 --UnClassified Tickets For Infra                                  
 INSERT INTO #CLTickets(TransactionId,ProjectID,TicketID,TicketDescription,TowerId,DebtClassificationMode,AvoidableFlag,                                                  
 ResidualDebtMapID,CauseCodeMapID,ResolutionCodeMapID,TD.TicketSummary,                                  
 TicketType,ClusterID_Desc,ClusterID_Resolution )                                   
 SELECT DISTINCT                              
 CLP.TransactionId,ITD.ProjectID,ITD.TicketID,ITD.TicketDescription,ITD.TowerId,ITD.DebtClassificationMapID,ITD.AvoidableFlag,                                                  
 ITD.ResidualDebtMapID,ITD.CauseCodeMapID,ITD.ResolutionCodeMapID,ITD.TicketSummary,                                  
 @UnClassified_Key,NULL,NULL      
 FROM #tmpClusteringCLProjects CLP                                                
 INNER JOIN [AVL].[TK_TRN_InfraTicketDetail] ITD ON ITD.ProjectID = CLP.ProjectId                                                  
 --INNER JOIN [AVL].[TK_TRN_InfraTicketDetail_RuleID] TDR ON ITD.TimeTickerID = TDR.TimeTickerID                                    
 INNER JOIN [ML].[AutoClassificationBatchProcess] BP ON BP.TransactionIdInfra=CLP.TransactionId                                   
 INNER JOIN [ML].[TicketsforAutoClassification] AC ON AC.BatchProcessId=BP.BatchProcessId                                  
 AND CLP.SupportTypeId=AC.SupportType AND AC.ClusterID_Desc = 0 AND AC.ClusterID_Resolution = 0                            
 where AC.StatusId=17 AND BP.IsDeleted=0 AND AC.IsDeleted=0                                   
 AND ITD.IsDeleted = 0 AND ITD.ClosedDate is not null AND CONVERT(DATE, CLP.SignOffdate) <= CONVERT(DATE,ITD.ClosedDate)                               
 AND ITD.TicketID not in (Select TicketID from #CLTickets)                         
                                  
 Update CVA SET                                   
 CVA.AvoidableFlagID=temp.AvoidableFlag,                                  
 CVA.ResidualDebtID=temp.ResidualDebtMapID,                                  
 CVA.CauseCodeID=temp.CauseCodeMapID,                                  
 CVA.ResolutionCodeID=temp.ResolutionCodeMapID,                                  
 CVA.ModifiedBy='System',                                  
 CVA.ModifiedDate=GETDATE()                                  
 FROM ML.TRN_ClusteringTicketValidation_Infra CVA                                           
 INNER JOIN #CLTickets temp  ON CVA.MLTransactionId = temp.TransactionId AND CVA.ProjectId = temp.ProjectId                                          
 AND CVA.TicketID = temp.TicketID                                  
                              
                        
 DELETE temp FROM #CLTickets temp                                           
 INNER JOIN ML.TRN_ClusteringTicketValidation_Infra CVA ON CVA.MLTransactionId = temp.TransactionId AND CVA.ProjectId = temp.ProjectId                                          
 AND CVA.TicketID = temp.TicketID                                          
                                          
                              
  -- IF have any Manual Tickets Update ismanual flag as 1                               
 UPDATE CLP SET                                
 CLP.IsManual= CASE WHEN (SELECT COUNT(*) FROM #CLTickets AS MT                              
 WHERE MT.TransactionId=CLP.TransactionId AND MT.TicketType =@Manual_key)>0                                
 THEN                                 
 1                                
 ELSE                               
 0                                
 END                                
 FROM [ML].[ClusteringCLProjects] CLP                              
  WHERE CLP.SupportTypeId = 2                          
                              
 -- IF have any Manual Tickets has failed from analytical side Update ismanual flag as 1                               
   UPDATE CLP SET                                
 CLP.IsManual= CASE WHEN (                              
 SELECT COUNT(*) FROM ML.TRN_ClusteringTicketValidation_Infra AS MT                               
 WHERE MT.MlTransactionId=CLP.TransactionId AND MT.TicketType = @Manual_Key AND  MT.ClusterID_Desc IS NULL AND MT.ClusterID_Resolution IS NULL                              
 AND MT.ISDELETED =0)>0                                
 THEN                                 
 1                                
 ELSE                                
 0                                
 END                                
 FROM [ML].[ClusteringCLProjects] CLP                     
 WHERE CLP.IsManual=0  AND CLP.SupportTypeId = 2                                    
                                           
                                          
  INSERT INTO ML.TRN_ClusteringTicketValidation_Infra(MLTransactionId,ProjectID,TicketID,TicketDescription,TowerId,DebtClassificationID,AvoidableFlagID,                                                  
  ResidualDebtID,CauseCodeID,ResolutionCodeID,IsDeleted,CreatedBy,CreatedDate,isSelected,TicketSummary,TicketType,ClusterID_Desc,ClusterID_Resolution)                                                  
  SELECT TransactionId,ProjectID,TicketID,TicketDescription,TowerID,DebtClassificationMode,AvoidableFlag,                                          
  ResidualDebtMapID,CauseCodeMapID,ResolutionCodeMapID,0,'System',Getdate(),0,TicketSummary,TicketType,ClusterID_Desc,ClusterID_Resolution                                           
  FROM #CLTickets                                          
                     
  --To update isselected flag for existing application                
   UPDATE A SET                                       
  IsSelected = 1                
  FROM [ML].TRN_ClusteringTicketValidation_Infra A                 
  INNER JOIN [ML].[TRN_DataQuality_OutCome_Infra] B                
  ON A.MLTransactionId=B.MltransactionId and A.TowerId=B.TowerId                
  INNER JOIN #tmpClusteringCLProjects C ON A.MLTransactionId =C.TransactionID                
  WHERE A.IsDeleted = 0 AND  B.IsDeleted=0 AND                                    
  B.IsSelected =1                
                                  
   -- Logic - To Update the Ticket Type as "CL" to the IL Tickets with ClusterID_Desc = 0                                                          
             
  UPDATE CTVA                                                       
 SET CTVA.TicketType = @CL_Key,              
 Clusterid_desc = CASE WHEN Clusterid_desc IS NULL THEN 0 ELSE Clusterid_desc END ,              
 ClusterID_Resolution = CASE WHEN ClusterID_Resolution IS NULL THEN 0 ELSE ClusterID_Resolution END               
 FROM ML.TRN_ClusteringTicketValidation_Infra CTVA                                                      
 INNER JOIN  #tmpClusteringCLProjects CLP ON CLP.TransactionID = CTVA.MLTransactionId                                          
 WHERE ISNULL(CTVA.ClusterID_Desc,0) = 0 AND ISNULL(CTVA.ClusterID_Resolution,0) = 0 AND CTVA.TicketType in( @IL_Key,@RE_Key)        
            
 COMMIT TRAN                  
END TRY                                                  
BEGIN CATCH                           
ROLLBACK TRAN                  
 DECLARE @ErrorMessage VARCHAR(MAX);                                                  
 SELECT @ErrorMessage = ERROR_MESSAGE()                        
                                                  
 --INSERT Error                                                  
 EXEC AVL_INSERTERROR '[ML].[InsertClusterCLTickets_Infra]', @ErrorMessage,0                          
 --JOB Failure UPDATION                      
   DECLARE @JobStatusFail NVARCHAR(100)='Failed';                      
   DECLARE @JobId INT;                     
   DECLARE @JobName NVARCHAR(100)= 'New Model ALGO Clustering Job';                    
   SELECT @JobId = JobID FROM MAS.JobMaster WHERE JobName = @JobName;                    
   BEGIN                     
   UPDATE MAS.JobStatus                       
   SET  JobStatus = @JobStatusFail, EndDateTime = GETDATE()                       
   WHERE  CAST(JobRunDate as Date) = CAST(GETDATE() as Date) and JobId=@JobId                    
   END                      
                    
END CATCH                                                  
END 