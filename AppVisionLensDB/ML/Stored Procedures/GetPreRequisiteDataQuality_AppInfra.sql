CREATE PROCEDURE [ML].[GetPreRequisiteDataQuality_AppInfra] --1,34,1                                
@IsApp bit,                                        
@TransactionId bigint,                            
@IsRegenerate bit                            
AS                                          
BEGIN                                          
  SET NOCOUNT ON;                                        
 BEGIN TRY                                          
 IF @IsApp = 1                                        
 BEGIN                         
                       
 --Select * into #CVAPP FROM(                      
 --SELECT Distinct Applicationid, IsFreeze, ISNULL(IsSelected,0) IsSelected from ML.TRN_ClusteringTicketValidation_App(nolock)                      
 --Where IsDeleted=0 AND MLTransactionID =@TransactionId )t          
       
 Select * into #CVAPP FROM(                      
 SELECT Distinct Applicationid from ML.TRN_ClusteringTicketValidation_App(nolock)                      
 Where IsDeleted=0 AND MLTransactionID =@TransactionId AND Isselected=1)t         
      
 UPDATE A SET A.Isselected=1 FROM ML.TRN_DataQuality_Outcome_App A      
 INNER JOIN #CVAPP C ON A.ApplicationId=C.ApplicationId      
 WHERE A.IsDeleted=0 AND A.MLTransactionID =@TransactionId      
        
 SELECT * INTO #TempApp FROM (                
   Select DISTINCT                                         
   DQ.DataQualityId,                                  
   DQ.MLTransactionId,                                  
   DQ.ApplicationId,                                  
   App.ApplicationName,                                
   NULL AS 'TowerId',                                 
    NULL AS 'TowerName',                                     
   DQ.TotalTickets,                                  
   (SELECT SUM(A.TotalTickets) FROM ML.TRN_DataQuality_Outcome_App A WHERE A.IsDeleted = 0                                       
   and A.ApplicationId=DQ.ApplicationID and A.MlTransactionId= DQ.MLTransactionId                                      
   Group By A.ApplicationId) SumOfTotalTicketsCount,                                  
   DQ.MetricKey,                                  
   MC.MetricName,                                  
   DQ.IsSelected,                        
   DQ.IsSelected as IsFreeze, -- Has not been used this column, need to remove it in future        
   DQ.IsTransactionExists,                                  
   DQ.TicketDescriptionCount,                                        
   DQ.DebtClassificationCount,                                  
   DQ.AvoidableFlagCount,                                  
   DQ.ResidualFlagCount,                                  
   DQ.ResolutionRemarksCount,                                  
   DQ.CauseCodeCount,                                  
   DQ.ResolutionCodeCount,                                  
   DQ.AssignmentGroupCount,                                  
   DQ.CategoryCount,                                  
   DQ.CommentsCount,                                  
   DQ.FlexField1Count,                                  
   DQ.FlexField2Count,                                  
   DQ.FlexField3Count,                                  
   DQ.FlexField4Count,                                  
   DQ.KEDBAvailableIndicatorCount,                                  
   DQ.RelatedTicketsCount,                                  
   DQ.ReleaseTypeCount,                                  
   DQ.TicketSourceCount,                                  
   DQ.TicketSummaryCount,                                  
   DQ.TicketTypeCount,                                  
   DQ.RatingKey,                                  
   Rate.RatingDesc,                  
   (Select FromDate from ML.TRN_MLTransaction where TransactionId = @TransactionId) AS FromDate,                  
   (Select ToDate from ML.TRN_MLTransaction where TransactionId = @TransactionId) AS ToDate                  
   from ML.TRN_DataQuality_Outcome_App DQ                                        
   INNER JOIN MAS.ML_MetricConfig MC ON MC.MetricKey = DQ.MetricKey AND MC.IsDeleted = 0                                        
   LEFT JOIN MAS.ML_Rating Rate ON Rate.RatingKey = DQ.RatingKey AND Rate.IsDeleted = 0                                        
   INNER JOIN AVL.APP_MAS_ApplicationDetails App ON App.ApplicationID = DQ.ApplicationId AND App.IsActive = 1                                       
   INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping] appMap ON App.ApplicationID = appMap.ApplicationID AND appMap.IsDeleted = 0                       
   --INNER JOIN #CVAPP CVA ON DQ.ApplicationId=CVA.ApplicationId                      
   WHERE DQ.MLTransactionID = @TransactionId  AND DQ.IsDeleted = 0 )a                                       
  -- ORDER BY DQ.ApplicationID DESC        
        
        
                 
  UPDATE #TempApp SET                 
   TicketDescriptionCount = 100 - case when  ISNUMERIC(TicketDescriptionCount)=1                
          then CAST(TicketDescriptionCount AS FLOAT) else 0 end,                
  DebtClassificationCount = 100 - case when  ISNUMERIC([DebtClassificationCount])=1                
          then CAST([DebtClassificationCount] AS FLOAT) else 0 end,                                  
   AvoidableFlagCount = 100 -    case when  ISNUMERIC(AvoidableFlagCount)=1                
          then CAST(AvoidableFlagCount AS FLOAT) else 0 end,                                 
    ResidualFlagCount= 100 - case when  ISNUMERIC(ResidualFlagCount)=1                
          then CAST(ResidualFlagCount AS FLOAT) else 0 end,                                  
    ResolutionRemarksCount= 100 - case when  ISNUMERIC(ResolutionRemarksCount)=1                
          then CAST(ResolutionRemarksCount AS FLOAT) else 0 end,                                  
    CauseCodeCount= 100 - case when  ISNUMERIC(CauseCodeCount)=1                
          then CAST(CauseCodeCount AS FLOAT) else 0 end,                                  
    ResolutionCodeCount= 100 - case when  ISNUMERIC(ResolutionCodeCount)=1                
          then CAST(ResolutionCodeCount AS FLOAT) else 0 end,                                  
    AssignmentGroupCount= 100 - case when  ISNUMERIC(AssignmentGroupCount)=1                
          then CAST(AssignmentGroupCount AS FLOAT) else 0 end,                                  
    CategoryCount= 100 - case when  ISNUMERIC(CategoryCount)=1                
          then CAST(CategoryCount AS FLOAT) else 0 end,                                  
    CommentsCount= 100 -  case when  ISNUMERIC(CommentsCount)=1                
          then CAST(CommentsCount AS FLOAT) else 0 end,                                  
    FlexField1Count= 100 - case when  ISNUMERIC(FlexField1Count)=1                
          then CAST(FlexField1Count AS FLOAT) else 0 end,                                  
    FlexField2Count= 100 - case when  ISNUMERIC(FlexField2Count)=1                
          then CAST(FlexField2Count AS FLOAT) else 0 end,                                  
    FlexField3Count= 100 - case when  ISNUMERIC(FlexField3Count)=1                
          then CAST(FlexField3Count AS FLOAT) else 0 end,                                  
    FlexField4Count= 100 - case when  ISNUMERIC(FlexField4Count)=1                
          then CAST(FlexField4Count AS FLOAT) else 0 end,                                  
    KEDBAvailableIndicatorCount= 100 -  case when  ISNUMERIC(KEDBAvailableIndicatorCount)=1                
          then CAST(KEDBAvailableIndicatorCount AS FLOAT) else 0 end,                                  
    RelatedTicketsCount= 100 - case when  ISNUMERIC(RelatedTicketsCount)=1                
          then CAST(RelatedTicketsCount AS FLOAT) else 0 end,                                  
    ReleaseTypeCount= 100 - case when  ISNUMERIC(ReleaseTypeCount)=1                
          then CAST(ReleaseTypeCount AS FLOAT) else 0 end,                                  
    TicketSourceCount= 100 - case when  ISNUMERIC(TicketSourceCount)=1                
      then CAST(TicketSourceCount AS FLOAT) else 0 end,                                  
    TicketSummaryCount= 100 - case when  ISNUMERIC(TicketSummaryCount)=1                
          then CAST(TicketSummaryCount AS FLOAT) else 0 end,                                  
    TicketTypeCount= 100 - case when  ISNUMERIC(TicketTypeCount)=1                
          then CAST(TicketTypeCount AS FLOAT) else 0 end                
 WHERE MetricName = 'Completeness';             
                
                
    SELECT * FROM #TempApp ORDER BY ApplicationId, MetricKey                  
                       
 --  IF @IsRegenerate=1                            
 --  BEGIN                            
 --  UPDATE [ML].TRN_DataQuality_OutCome_App SET                            
 --  IsSelected = 1                            
 --  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND ApplicationId in                            
 --  (SELECT DISTINCT ApplicationId from ML.TRN_ClusteringTicketValidation_App where MLTransactionId = @TransactionId AND IsDeleted = 0 AND isSelected = 1 )                            
 --END                     
 END                                        
 ELSE                                        
 BEGIN                       
 --Select * into #CVINFRA FROM(                      
 --SELECT Distinct TowerId, IsFreeze, ISNULL(IsSelected,0) IsSelected from ML.TRN_ClusteringTicketValidation_Infra(nolock)                      
 --Where IsDeleted=0 AND MLTransactionID =@TransactionId)t         
       
  Select * into #CVInfra FROM(                      
 SELECT Distinct TowerId from ML.TRN_ClusteringTicketValidation_Infra(nolock)                      
 Where IsDeleted=0 AND MLTransactionID =@TransactionId AND Isselected=1)t         
      
  UPDATE A SET A.Isselected=1 FROM ML.TRN_DataQuality_OutCome_Infra A      
  INNER JOIN #CVInfra C on A.TowerId=C.TowerId      
  WHERE A.IsDeleted=0 AND A.MLTransactionID =@TransactionId      
         
   SELECT * INTO #TempInfra FROM(                 
   Select                                         
   DQ.DataQualityId,                                  
   DQ.MLTransactionId,                                  
   NULL AS 'ApplicationId',                                 
   NULL AS 'ApplicationName',                   
   Infra.InfraTowerTransactionID AS 'TowerId',                                  
   Infra.TowerName,                                  
   DQ.TotalTickets,                                  
   (SELECT SUM(B.TotalTickets) FROM ML.TRN_DataQuality_OutCome_Infra B WHERE B.IsDeleted = 0                                       
   and B.TowerId=DQ.TowerID and B.MlTransactionId= DQ.MLTransactionId                                      
   Group By B.TowerId) SumOfTotalTicketsCount,                                  
   DQ.MetricKey,                                  
   MC.MetricName,                        
   DQ.IsSelected,                        
   DQ.IsSelected as IsFreeze, -- Has not been used this column, need to remove it in future        
   DQ.IsTransactionExists,  
   DQ.TicketDescriptionCount,                                  
   DQ.DebtClassificationCount,                                  
   DQ.AvoidableFlagCount,                                  
   DQ.ResidualFlagCount,                                  
   DQ.ResolutionRemarksCount,                                  
   DQ.CauseCodeCount,                                  
   DQ.ResolutionCodeCount,                                  
   DQ.AssignmentGroupCount,                                  
   DQ.CategoryCount,                                  
   DQ.CommentsCount,                                  
   DQ.FlexField1Count,                                  
   DQ.FlexField2Count,                                  
   DQ.FlexField3Count,                                  
   DQ.FlexField4Count,                                  
   DQ.KEDBAvailableIndicatorCount,                                  
   DQ.RelatedTicketsCount,                                  
   DQ.ReleaseTypeCount,                                  
   DQ.TicketSourceCount,                                  
   DQ.TicketSummaryCount,                                  
   DQ.TicketTypeCount,                                  
   DQ.RatingKey,                                  
   Rate.RatingDesc,                  
   (Select FromDate from ML.TRN_MLTransaction where TransactionId = @TransactionId) AS FromDate,                  
   (Select ToDate from ML.TRN_MLTransaction where TransactionId = @TransactionId) AS ToDate                 
   from ML.TRN_DataQuality_OutCome_Infra DQ                                        
   INNER JOIN MAS.ML_MetricConfig MC ON MC.MetricKey = DQ.MetricKey AND MC.IsDeleted = 0                                        
   LEFT JOIN MAS.ML_Rating Rate ON Rate.RatingKey = DQ.RatingKey AND Rate.IsDeleted = 0                                        
   INNER JOIN AVL.InfraTowerDetailsTransaction Infra ON Infra.InfraTowerTransactionID = DQ.TowerId AND Infra.IsDeleted = 0                         
   --INNER JOIN #CVINFRA CVA ON DQ.TowerId=CVA.TowerId                      
   WHERE DQ.MLTransactionID =@TransactionId AND DQ.IsDeleted = 0 ) a                                       
  -- ORDER BY Infra.InfraTowerTransactionID DESC                 
                
  UPDATE #TempInfra SET                 
   TicketDescriptionCount = 100 - case when  ISNUMERIC(TicketDescriptionCount)=1                
          then CAST(TicketDescriptionCount AS FLOAT) else 0 end,                
  DebtClassificationCount = 100 - case when  ISNUMERIC([DebtClassificationCount])=1                
          then CAST([DebtClassificationCount] AS FLOAT) else 0 end,                                  
   AvoidableFlagCount = 100 -    case when  ISNUMERIC(AvoidableFlagCount)=1                
          then CAST(AvoidableFlagCount AS FLOAT) else 0 end,                                 
    ResidualFlagCount= 100 - case when  ISNUMERIC(ResidualFlagCount)=1                
         then CAST(ResidualFlagCount AS FLOAT) else 0 end,                                  
    ResolutionRemarksCount= 100 - case when  ISNUMERIC(ResolutionRemarksCount)=1                
          then CAST(ResolutionRemarksCount AS FLOAT) else 0 end,                                  
    CauseCodeCount= 100 - case when  ISNUMERIC(CauseCodeCount)=1                
          then CAST(CauseCodeCount AS FLOAT) else 0 end,                                  
    ResolutionCodeCount= 100 - case when  ISNUMERIC(ResolutionCodeCount)=1                
          then CAST(ResolutionCodeCount AS FLOAT) else 0 end,                                  
    AssignmentGroupCount= 100 - case when  ISNUMERIC(AssignmentGroupCount)=1                
          then CAST(AssignmentGroupCount AS FLOAT) else 0 end,                                  
    CategoryCount= 100 - case when  ISNUMERIC(CategoryCount)=1                
          then CAST(CategoryCount AS FLOAT) else 0 end,                                  
    CommentsCount= 100 -  case when  ISNUMERIC(CommentsCount)=1                
          then CAST(CommentsCount AS FLOAT) else 0 end,                                  
    FlexField1Count= 100 - case when  ISNUMERIC(FlexField1Count)=1                
          then CAST(FlexField1Count AS FLOAT) else 0 end,                                  
    FlexField2Count= 100 - case when  ISNUMERIC(FlexField2Count)=1                
          then CAST(FlexField2Count AS FLOAT) else 0 end,                                  
    FlexField3Count= 100 - case when  ISNUMERIC(FlexField3Count)=1                
          then CAST(FlexField3Count AS FLOAT) else 0 end,                                  
    FlexField4Count= 100 - case when  ISNUMERIC(FlexField4Count)=1                
          then CAST(FlexField4Count AS FLOAT) else 0 end,                                  
    KEDBAvailableIndicatorCount= 100 -  case when  ISNUMERIC(KEDBAvailableIndicatorCount)=1                
          then CAST(KEDBAvailableIndicatorCount AS FLOAT) else 0 end,                                 
    RelatedTicketsCount= 100 - case when  ISNUMERIC(RelatedTicketsCount)=1                
          then CAST(RelatedTicketsCount AS FLOAT) else 0 end,                                  
    ReleaseTypeCount= 100 - case when  ISNUMERIC(ReleaseTypeCount)=1                
          then CAST(ReleaseTypeCount AS FLOAT) else 0 end,                                  
    TicketSourceCount= 100 - case when  ISNUMERIC(TicketSourceCount)=1                
       then CAST(TicketSourceCount AS FLOAT) else 0 end,                                  
    TicketSummaryCount= 100 - case when  ISNUMERIC(TicketSummaryCount)=1                
          then CAST(TicketSummaryCount AS FLOAT) else 0 end,                                  
    TicketTypeCount= 100 - case when  ISNUMERIC(TicketTypeCount)=1                
          then CAST(TicketTypeCount AS FLOAT) else 0 end                
 WHERE MetricName = 'Completeness';       
                
                
    SELECT * FROM #TempInfra ORDER BY TowerId, MetricKey                  
       --SELECT * FROM #TempInfra ORDER BY TowerId,MetricKey                      
--  IF @IsRegenerate=1                             
--  BEGIN                            
--   UPDATE [ML].TRN_DataQuality_OutCome_Infra SET                            
--   IsSelected = 1                            
--  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND TowerId in                            
--  (SELECT DISTINCT TowerId from ML.TRN_ClusteringTicketValidation_Infra where MLTransactionId = @TransactionId AND IsDeleted = 0 AND isSelected = 1 )                       
                        
--END                            
 END                  
                    
END TRY                     
                
 BEGIN CATCH                                          
    DECLARE @ErrorMessage VARCHAR(MAX);                                        
 SELECT @ErrorMessage = ERROR_MESSAGE()                                        
                                        
 EXEC AVL_InsertError '[ML].[GetPreRequisiteDataQuality_AppInfra]', @ErrorMessage, 0,0                                        
 END CATCH;                                          
                                          
 SET NOCOUNT OFF;                                        
END
