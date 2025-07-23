      
      
CREATE PROCEDURE [ML].[GetClusteringOutcomeDetails] --867, 1                        
@TransactionId BIGINT,                                      
@IsApp BIT                                      
AS                                                        
BEGIN                                                               
BEGIN TRY                                         
                             
IF @IsApp =1                                     
BEGIN              
            
DECLARE @CLAppCOUNT INT = (            
SELECT COUNT(MLTRANSACTIONID) From [ML].[TRN_ClusteringTicketValidation_app](NOLOCK)             
WHERE MLTransactionId = @TransactionId AND TicketType NOT IN('LT002','LT003'))            
            
            
 SELECT * INTO #Temp FROM (                              
 SELECT TRN.ApplicationID,APP.ApplicationName,COUNT(TRN.TicketId) AS ITSMTicketCount,COUNT(NULLIF(TRN.ClusterID_Desc,0)) AS ClusteringTicketCount,                              
 COUNT(NULLIF(TRN.ClusterID_Resolution,0)) AS ClusteringResolutionCount,COUNT(DISTINCT NULLIF(TRN.ClusterID_Desc,0)) AS CCForID,                              
 COUNT(DISTINCT NULLIF(TRN.ClusterID_Resolution,0)) AS CCForRR , CAST('' AS NVARCHAR ) AS RatingKey            
 FROM [ML].[TRN_ClusteringTicketValidation_app](NOLOCK) TRN             
 INNER JOIN ML.TRN_MLTransaction MLTRN ON MLTRN.TransactionId = TRN.MLTransactionId            
 INNER JOIN [AVL].[APP_MAS_ApplicationDetails](NOLOCK) APP ON TRN.ApplicationId = APP.ApplicationId               
 inner JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) appMap ON TRN.ApplicationId = appMap.ApplicationID                  
   AND appmap.projectid =TRN.projectid AND appMap.IsDeleted=0               
 WHERE TRN.MLTransactionId = @TransactionId AND TRN.Isdeleted = 0 AND APP.IsActive = 1                  
AND (IsSelected=1 OR IsSelected = (CASE WHEN @CLAppCOUNT =0 THEN 1 ELSE 0 END))            
 GROUP BY TRN.ApplicationID,APP.ApplicationName,IsSelected            
 HAVING (COUNT(NULLIF(TRN.ClusterID_Desc,0)) >= CASE WHEN @CLAppCOUNT =0 THEN 0 ELSE 1 END) OR            
 IsSelected =1            
 ) AS T              
            
                              
 --SELECT * INTO #RatingTemp FROM (                              
 --SELECT TRN.ApplicationID,RNG.RatingKey FROM [ML].[TRN_DataQuality_Outcome_app](NOLOCK) TRN INNER JOIN [MAS].[ML_Rating](NOLOCK) RNG ON TRN.RatingKey = RNG.RatingKey                              
 --WHERE TRN.MLTransactionId = @TransactionId AND TRN.Isdeleted = 0 AND RNG.IsDeleted = 0 GROUP BY TRN.ApplicationID,RNG.RatingDesc,RNG.RatingKey ) AS A                              
                              
 --Update T SET T.RatingKey = CASE WHEN ISNULL(RT.RatingKey,'') <> '' THEN RT.RatingKey ELSE T.RatingKey END               
 --FROM #Temp T INNER JOIN #RatingTemp RT ON T.ApplicationId = RT.ApplicationID   WHERE  RT.RatingKey ='RK003'               
               
 --Update T SET T.RatingKey = CASE WHEN ISNULL(RT.RatingKey,'') <> '' THEN RT.RatingKey ELSE T.RatingKey END               
 --FROM #Temp T INNER JOIN #RatingTemp RT ON T.ApplicationId = RT.ApplicationID   WHERE  RT.RatingKey ='RK002'              
               
 --Update T SET T.RatingKey = CASE WHEN ISNULL(RT.RatingKey,'') <> '' THEN RT.RatingKey ELSE T.RatingKey END                
 --FROM #Temp T INNER JOIN #RatingTemp RT ON T.ApplicationId = RT.ApplicationID   WHERE  RT.RatingKey ='RK001'                 
           
   UPDATE T SET T.RatingKey =         
   CASE WHEN (Select Count(TicketType) FROM ML.TRN_ClusteringTicketValidation_App (NOLOCK) App        
   WHERE App.MLTransactionId=@TransactionId and App.ApplicationId=T.ApplicationId AND IsDeleted=0        
   AND App.TicketType='LT002')>0 THEN 'LT002'         
   ELSE CASE WHEN (Select Count(TicketType) FROM ML.TRN_ClusteringTicketValidation_App (NOLOCK) App        
   WHERE App.MLTransactionId=@TransactionId and App.ApplicationId=T.ApplicationId AND IsDeleted=0        
   AND App.TicketType='LT003')>0 THEN 'LT003'         
   ELSE 'LT001' END         
   END        
   FROM #Temp T            
           
           
        
 SELECT ApplicationName,ITSMTicketCount,ClusteringTicketCount,ClusteringResolutionCount,CCForID,CCForRR,RatingKey FROM #Temp                            
                              
END                                  
ELSE                                  
BEGIN                                  
  DECLARE @CLInfraCOUNT INT = (            
SELECT COUNT(MLTRANSACTIONID) From [ML].[TRN_ClusteringTicketValidation_Infra](NOLOCK)             
WHERE MLTransactionId = @TransactionId AND TicketType NOT IN('LT002','LT003'))            
            
 SELECT * INTO #TempInfra FROM (                              
 SELECT TRN.TowerId,TW.TowerName,COUNT(TRN.TicketId) AS ITSMTicketCount,COUNT(NULLIF(TRN.ClusterID_Desc,0)) AS ClusteringTicketCount,                              
 COUNT(NULLIF(TRN.ClusterID_Resolution,0)) AS ClusteringResolutionCount,COUNT(DISTINCT NULLIF(TRN.ClusterID_Desc,0)) AS CCForID,                              
 COUNT(DISTINCT NULLIF(TRN.ClusterID_Resolution,0)) AS CCForRR , CAST('' AS NVARCHAR ) AS RatingKey            
 FROM [ML].[TRN_ClusteringTicketValidation_Infra](NOLOCK) TRN             
 INNER JOIN AVL.InfraTowerDetailsTransaction (NOLOCK) TW ON TRN.TowerId = TW.InfraTowerTransactionID            
 INNER JOIN ML.TRN_MLTransaction MLTRN ON MLTRN.TransactionId = TRN.MLTransactionId            
 INNER JOIN [AVL].[InfraTowerProjectMapping](NOLOCK) IT ON TRN.ProjectId=IT.ProjectId And TRN.TowerId = IT.TowerId and IT.IsDeleted=0                  
 AND IT.IsEnabled =1                
 WHERE TRN.MLTransactionId = @TransactionId AND TRN.Isdeleted = 0 AND TW.IsDeleted = 0                   
 AND (IsSelected=1 OR IsSelected = (CASE WHEN @CLInfraCOUNT =0 THEN 1 ELSE 0 END))                           
 GROUP BY TRN.TowerId,TW.TowerName,IsSelected            
  HAVING COUNT(NULLIF(TRN.ClusterID_Desc,0)) >= CASE WHEN @CLInfraCOUNT =0 THEN 0 ELSE 1 END OR            
 IsSelected =1            
 ) AS T                               
                              
 SELECT * INTO #RatingTempInfra FROM (                              
 SELECT TRN.TowerId,RNG.RatingKey FROM [ML].[TRN_DataQuality_Outcome_Infra](NOLOCK) TRN INNER JOIN [MAS].[ML_Rating](NOLOCK) RNG ON TRN.RatingKey = RNG.RatingKey                              
 WHERE TRN.MLTransactionId = @TransactionId AND TRN.Isdeleted = 0 AND RNG.IsDeleted = 0 GROUP BY TRN.TowerId,RNG.RatingKey ) AS A                              
                              
-- Update T SET T.RatingKey = RT.RatingKey FROM #TempInfra T INNER JOIN #RatingTempInfra RT ON T.TowerId = RT.TowerId                
               
 --Update T SET T.RatingKey = CASE WHEN ISNULL(RT.RatingKey,'') <> '' THEN RT.RatingKey ELSE T.RatingKey END               
 --FROM #TempInfra T INNER JOIN #RatingTempInfra RT ON T.TowerId = RT.TowerId   WHERE  RT.RatingKey ='RK003'               
               
 --Update T SET T.RatingKey = CASE WHEN ISNULL(RT.RatingKey,'') <> '' THEN RT.RatingKey ELSE T.RatingKey END               
 --FROM #TempInfra T INNER JOIN #RatingTempInfra RT ON T.TowerId = RT.TowerId   WHERE  RT.RatingKey ='RK002'              
               
 --Update T SET T.RatingKey = CASE WHEN ISNULL(RT.RatingKey,'') <> '' THEN RT.RatingKey ELSE T.RatingKey END                
 --FROM #TempInfra T INNER JOIN #RatingTempInfra RT ON T.TowerId = RT.TowerId   WHERE  RT.RatingKey ='RK001'               
               
     UPDATE T SET T.RatingKey =         
   CASE WHEN (Select Count(TicketType) FROM ML.TRN_ClusteringTicketValidation_Infra (NOLOCK) Infra        
   WHERE Infra.MLTransactionId=@TransactionId and Infra.TowerId=T.TowerId AND IsDeleted=0        
   AND Infra.TicketType='LT002')>0 THEN 'LT002'         
   ELSE CASE WHEN (Select Count(TicketType) FROM ML.TRN_ClusteringTicketValidation_Infra (NOLOCK) Infra        
   WHERE Infra.MLTransactionId=@TransactionId and Infra.TowerId=T.TowerId AND IsDeleted=0        
   AND Infra.TicketType='LT003')>0 THEN 'LT003'         
   ELSE 'LT001' END         
   END        
   FROM #TempInfra T            
        
 SELECT TowerName ,ITSMTicketCount,ClusteringTicketCount,ClusteringResolutionCount,CCForID,CCForRR,RatingKey FROM #TempInfra                              
                              
END                                  
                                  
SELECT ModelAccuracy,ErrorPercentage,DispersionRatioPercentage,ResolutionProviderId                                  
FROM [ML].[TRN_MLTransaction] WHERE TransactionId=@TransactionId and IsDeleted=0                                 
                                
SELECT RatingDesc,RatingKey FROM MAS.ML_Rating WHERE IsDeleted = 0                                
                                  
END TRY                                                              
BEGIN CATCH                     
                                                                           
  DECLARE @ErrorMessage VARCHAR(MAX);                                          
  SELECT @ErrorMessage = ERROR_MESSAGE()                                                           
                                    
  EXEC AVL_InsertError '[ML].[GetClusteringOutcomeDetails]', @ErrorMessage, 0,0                                                            
                                         
 END CATCH                                                               
END
