          
          
          
CREATE PROCEDURE [ML].[GetMLTransactionDetails]                                          
@ProjectId BIGINT,                            
@IsApp BIT                            
AS                                              
BEGIN                                                     
BEGIN TRY                               
  BEGIN TRAN                          
DECLARE @SupportTypeId int =1;                            
                            
IF @IsApp =0                            
BEGIN                            
SET @SupportTypeId = 2                            
END                            
                          
UPDATE A  SET A.SignoffDate =              
Case WHEN @SupportTypeId = 2 THEN              
PDD.MLSignOffDateInfra              
ELSE              
PDD.MLSignOffDate                   
END              
From ML.TRN_MLTransaction A                          
INNER JOIN  AVL.MAS_ProjectDebtDetails(NOLOCK) PDD ON A.ProjectID =PDD.ProjectId                          
WHERE A.AlgorithmKey='AL001'AND A.SupportTypeId =@SupportTypeId AND  A.ProjectId=@ProjectId                          
                          
DECLARE @ATransactionCount INT =(SELECT COUNT(*) FROM ML.TRN_MLTransaction(NOLOCK)                           
WHERE AlgorithmKey not in('AL001')                           
AND ProjectId=@ProjectId AND SupportTypeId =@SupportTypeId                          
AND IsActiveTransaction =1)                          
                          
UPDATE A  SET A.IsActiveTransaction =                          
CASE WHEN @ATransactionCount > 0 OR ISNULL(A.SignoffDate, '') = '' THEN                          
A.IsActiveTransaction                          
ELSE                          
1                          
END                          
From                          
ML.TRN_MLTransaction A                          
WHERE A.AlgorithmKey='AL001' AND A.SupportTypeId =@SupportTypeId                           
AND A.ProjectId=@ProjectId                          
                                 
                                          
SELECT                                            
 T.TransactionID AS TransactionID, T.SignOffDate,                                            
 A.AlgorithmName , T.Isactivetransaction , A.AlgorithmKey ,T.SupportTypeId  ,T.ScreenId ,S.RouterLink ,T.ModelAccuracy, T.JobStatusKey,            
 --CASE WHEN CCP.IsRegenerate = 0 THEN 'SK006' ELSE CCP.Jobstatuskey END AS 'RStatusKey' ,   
 CCP.Jobstatuskey AS 'RStatusKey' ,   
 ISNULL(CCP.IsRegenerate, 0) AS IsRegenerate            
FROM   ML.TRN_MLTransaction T                          
INNER JOIN MAS.MLAlgorithm A on t.AlgorithmKey = A.AlgorithmKey                          
LEFT JOIN [MAS].[MLScreens] S on T.ScreenId=S.ScreenId             
LEFT JOIN  [ML].[ClusteringCLProjects] CCP on CCP.TransactionId=T.TransactionID            
 WHERE T.ProjectId = @ProjectId AND T.SupportTypeId = @SupportTypeId AND T.IsDeleted = 0 AND A.IsDeleted = 0                                         
 ORDER BY TransactionID DESC        
       
         
 If @IsApp=1       
  Begin      
 select sum(1) as CountOfTickets from avl.Tk_trn_ticketdetail where ProjectId=@ProjectId         
 end      
 Else       
 begin      
 select sum(1) as CountOfTickets from avl.Tk_trn_infraticketdetail where ProjectId=@ProjectId      
 end         
                                             
 COMMIT TRAN                                               
END TRY                                                    
BEGIN CATCH                                                    
  ROLLBACK TRAN                                                           
  DECLARE @ErrorMessage VARCHAR(MAX);                                                  
  SELECT @ErrorMessage = ERROR_MESSAGE()                                                 
                                                           
  EXEC AVL_InsertError '[ML].[GetMLTransactionDetails]', @ErrorMessage, 0,0                                                  
                                                     END CATCH                                                     
END