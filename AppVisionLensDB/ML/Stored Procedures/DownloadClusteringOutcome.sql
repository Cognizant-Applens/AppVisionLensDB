  
    
CREATE PROCEDURE [ML].[DownloadClusteringOutcome] -- [ML].[DownloadClusteringOutcome] 1284,1,0,0                                    
@TransactionID BIGINT ,               
@isLastUploadFile BIT,          
@EncEnable BIT,                           
@IsRegenerate BIT                           
                                            
AS                                                    
BEGIN                                                      
BEGIN TRY       
                                           
 CREATE TABLE #Columns(                                                        
 ITSMColumn varchar(50),                                                        
 )                                     
 INSERT INTO #Columns (ITSMColumn)                                                         
 values                                                         
 ('Application Name / Tower Name'), ('Ticket ID'),                                            
 ('Debt Classification'),('Avoidable Flag'),('Residual Debt'),('Issue Description Cluster'),                               
 ('Issue Description Cluster Id'),('Issue Description match %'),        
 --('Resolution Provided Cluster Id'),('Resolution Provided match %'),('Resolution Provided Cluster'),         
 ('Classified By'),('ApplicationID'),('IsEncrypt')           
           
  IF (SELECT COUNT(ResolutionProviderId) FROM ml.TRN_MLTransaction(NOLOCK)                                                    
 WHERE TransactionId =@TransactionID  AND  ResolutionProviderId IS NOT NULL) > 0                                             
 BEGIN                                            
  INSERT INTO #Columns (ITSMColumn)                                                         
 values                                                         
 ('Resolution Provided Cluster Id'),('Resolution Provided match %'),('Resolution Provided Cluster')                                         
 END             
                                          
  CREATE TABLE #ClusterColumns(                                                        
 ITSMColumn varchar(50),                                                        
 )                                     
 INSERT INTO #ClusterColumns (ITSMColumn)                                                         
 values                                                         
 ('Application Name / Tower Name'),('Issue Description Cluster Id'),('Issue Description Cluster'),          
 ('Resolution Provided Cluster Id'),('Resolution Provided Cluster'),         
 ('Classified By'),('Debt Classification'),('Avoidable Flag'),('Residual Debt'),('ApplicationID')                      
                          
                                             
 --IF (SELECT COUNT(ResolutionProviderId) FROM ml.TRN_MLTransaction(NOLOCK)                                                    
 --WHERE TransactionId =@TransactionID  AND  ResolutionProviderId IS NOT NULL) > 0                                             
 --BEGIN                                            
 -- INSERT INTO #ClusterColumns (ITSMColumn)                                                         
 --values                                                         
 --('Resolution Provided Cluster Id'),('Resolution Provided Cluster')                                         
 --END         
         
 DECLARE @Categoricalfields NVARCHAR(20)= 'Categorical fields';        
                          
 DECLARE @CLAppCount INT;        
    
                                             
 Declare @Supporttypeid int = (select Supporttypeid from ml.trn_mltransaction where transactionid = @TransactionID)              
       
 IF OBJECT_ID(N'tempdb..#TempAppDown') IS NOT NULL            
 BEGIN DROP TABLE #TempAppDown END          
 CREATE TABLE #TempAppDown(                    
  ApplicationID varchar(50),                                                        
 )       
      
 IF OBJECT_ID(N'tempdb..#TempInfraDown') IS NOT NULL            
 BEGIN DROP TABLE #TempInfraDown END          
 CREATE TABLE #TempInfraDown(                                                        
  TowerId varchar(50),                                                        
 )       
      
      
 DECLARE @IsCLORRegenerate bit;      
       
 IF EXISTS(SELECT Distinct TransactionId FROM ML.ClusteringCLProjects      
 WHERE TransactionId=@TransactionId AND Isnull(IsRegenerate,0)=0)      
 BEGIN      
 SET @IsCLORRegenerate=1;      
 END      
 ELSE      
 BEGIN      
 SET @IsCLORRegenerate=0;      
 END      
                                              
--IF @Supporttypeid = 1                                              
BEGIN        
IF(@IsRegenerate=0 OR (@IsRegenerate=1 AND @isLastUploadFile=1) OR (@IsCLORRegenerate=1 AND @isLastUploadFile=0))      
BEGIN  
IF(@Supporttypeid=1)
BEGIN
 SET @CLAppCount = (SELECT COUNT(MLTransactionID) FROM ML.TRN_ClusteringTicketValidation_App (NOLOCK)                          
WHERE MLTransactionID = @TransactionId AND TicketType NOT IN ('LT002','LT003'))   
Insert into  #TempAppDown                                        
SELECT TRN.ApplicationID                        
FROM [ML].[TRN_ClusteringTicketValidation_app](NOLOCK) TRN                         
INNER JOIN ML.TRN_MLTransaction MLTRN ON MLTRN.TransactionId = TRN.MLTransactionId                        
INNER JOIN [AVL].[APP_MAS_ApplicationDetails](NOLOCK) APP ON TRN.ApplicationId = APP.ApplicationId                           
inner JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) appMap ON TRN.ApplicationId = appMap.ApplicationID                              
AND appmap.projectid =TRN.projectid AND appMap.IsDeleted=0                           
WHERE TRN.MLTransactionId = @TransactionId AND TRN.Isdeleted = 0 AND APP.IsActive = 1                              
AND (IsSelected=1 OR IsSelected = (CASE WHEN @CLAppCOUNT =0 THEN 1 ELSE 0 END))    
AND ((TicketType<> 'LT002' AND IsCLReviewCompleted=1) OR TicketType='LT002')  
GROUP BY TRN.ApplicationID,APP.ApplicationName,IsSelected                        
HAVING (COUNT(NULLIF(TRN.ClusterID_Desc,0)) >= CASE WHEN @CLAppCOUNT =0 THEN 0 ELSE 1 END) OR                        
IsSelected =1              
END
ELSE
BEGIN      
SET @CLAppCount= (SELECT COUNT(MLTransactionID) FROM ML.TRN_ClusteringTicketValidation_Infra (NOLOCK)                          
WHERE MLTransactionID = @TransactionId AND TicketType NOT IN ('LT002','LT003'))                                              
Insert into  #TempInfraDown                                          
SELECT TRN.TowerId                        
FROM [ML].[TRN_ClusteringTicketValidation_Infra](NOLOCK) TRN                       
INNER JOIN AVL.InfraTowerDetailsTransaction (NOLOCK) TW ON TRN.TowerId = TW.InfraTowerTransactionID                      
INNER JOIN ML.TRN_MLTransaction MLTRN ON MLTRN.TransactionId = TRN.MLTransactionId                      
INNER JOIN [AVL].[InfraTowerProjectMapping](NOLOCK) IT ON TRN.ProjectId=IT.ProjectId And TRN.TowerId = IT.TowerId and IT.IsDeleted=0 AND IT.IsEnabled =1                
WHERE TRN.MLTransactionId = @TransactionId AND TRN.Isdeleted = 0 AND TW.IsDeleted = 0                             
AND (IsSelected=1 OR IsSelected = (CASE WHEN @CLAppCount =0 THEN 1 ELSE 0 END))  
AND ((TicketType<> 'LT002' AND IsCLReviewCompleted=1) OR TicketType='LT002')  
GROUP BY TRN.TowerId,TW.TowerName,IsSelected                      
HAVING COUNT(NULLIF(TRN.ClusterID_Desc,0)) >= CASE WHEN @CLAppCount =0 THEN 0 ELSE 1 END OR                      
IsSelected =1  
END
    
END      
ELSE      
BEGIN      
       
IF(@Supporttypeid=1)
BEGIN     
Insert into  #TempAppDown                                        
SELECT TRN.ApplicationID                        
FROM [ML].[TRN_ClusteringTicketValidation_app](NOLOCK) TRN                         
INNER JOIN ML.TRN_MLTransaction MLTRN ON MLTRN.TransactionId = TRN.MLTransactionId                        
INNER JOIN [AVL].[APP_MAS_ApplicationDetails](NOLOCK) APP ON TRN.ApplicationId = APP.ApplicationId                           
INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) appMap ON TRN.ApplicationId = appMap.ApplicationID                              
AND appmap.projectid =TRN.projectid AND appMap.IsDeleted=0                           
WHERE TRN.MLTransactionId = @TransactionId AND TRN.Isdeleted = 0 AND APP.IsActive = 1                              
AND IsSelected=1 and TicketType = 'LT003'                  
GROUP BY TRN.ApplicationID,APP.ApplicationName,IsSelected       
END
ELSE
BEGIN 
Insert into  #TempInfraDown                                          
SELECT TRN.TowerId                        
FROM [ML].[TRN_ClusteringTicketValidation_Infra](NOLOCK) TRN                       
INNER JOIN AVL.InfraTowerDetailsTransaction (NOLOCK) TW ON TRN.TowerId = TW.InfraTowerTransactionID                      
INNER JOIN ML.TRN_MLTransaction MLTRN ON MLTRN.TransactionId = TRN.MLTransactionId                      
INNER JOIN [AVL].[InfraTowerProjectMapping](NOLOCK) IT ON TRN.ProjectId=IT.ProjectId And TRN.TowerId = IT.TowerId and IT.IsDeleted=0 AND IT.IsEnabled =1                
WHERE TRN.MLTransactionId = @TransactionId AND TRN.Isdeleted = 0 AND TW.IsDeleted = 0                             
AND IsSelected=1 and TicketType = 'LT003'                  
GROUP BY TRN.TowerId,TW.TowerName,IsSelected   
END
END      
          
          
          
---------------- TicketLevelOutcome -------------------------          
          
   DECLARE @IsSignoff bit;  
  
   SET @IsSignoff= (SELECT CASE WHEN SignOffDate IS NOT NULL THEN 1 ELSE 0 END  
   FROM ML.TRN_MLTransaction WHERE   
   TransactionId=@TransactionId)  
         
 IF(@IsRegenerate=0 AND @isLastUploadFile=1 AND @IsSignoff=0)        
 BEGIN  
 IF(@SupporttypeId=1)
 BEGIN
 select DISTINCT APP.ApplicationName AS [Application Name / Tower Name],TKV.TicketID AS [Ticket ID],          
 TKD.TicketDescription  AS TicketDescription, TKD.ResolutionRemarks,        
DEBT.DebtClassificationName AS [Debt Classification], AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                                  
  CC.CauseCode AS CauseCodeMapID, RES.ResolutionCode AS ResolutionCodeMapID,                                          
  TKV.Description_threshold As [Issue Description match %],TKV.ClusterID_Desc As [Issue Description Cluster Id],TKV.Description_Keys_Tokens AS [Issue Description Cluster],                            
  TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],                            
  TKV.Resolution_threshold As [Resolution Provided match %],                                          
  TKV.Resolution_Keys_Tokens AS [Resolution Provided Cluster], TKV.IsOverwrite,TKD.Category AS Category,TKD.Comments AS Comments, TKD.FlexField1, TKD.FlexField2, TKD.FlexField3,                              
  TKD.FlexField4,TKD.RelatedTickets,                                  
   TKD.ResolutionRemarks,                                  
  TKD.TicketSummary,                        
  TKD.AssignmentGroup AS AssignmentGroupID,                        
  KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                      
  TS.SourceName AS TicketSourceMapID,                            
  TKV.Description_Keys_Tokens AS Description_Keys_Tokens,        
  TKV.Resolution_Keys_Tokens AS Resolution_Keys_Tokens ,AMP.IsCoginzant AS IsCognizant,           
  CASE WHEN TKV.CREATEDBY = 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 ) THEN 'System'       
  WHEN (TKV.CREATEDBY <> 'System' AND ((ISNULL(OC.DebtClassificationID,0)) <> 0      
 OR (ISNULL(OC.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(OC.ResidualDebtID,0)) <> 0 )) THEN OC.CREATEDBY      
 ELSE  '' END AS 'Classified By'           
  ,TKV.ApplicationID        
  ,CASE WHEN (T.IssueDefinitionId=9 OR  T.IssueDefinitionId=10) THEN 1 ELSE 0 END AS 'IsEncrypt'      
FROM ML.[TRN_ClusteringOutcomeUploadedData_App](NOLOCK) OC         
JOIN ML.TRN_ClusteringTicketValidation_app TKV on OC.TicketID = TKV.TicketID and OC.ProjectId = TKV.ProjectId and         
OC.ApplicationId = TKV.ApplicationId        
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) APP ON TKV.ApplicationID = APP.ApplicationID                          
INNER JOIN #TempAppDown SAPP ON APP.ApplicationId =SAPP.ApplicationId         
INNER JOIN  AVL.TK_TRN_Ticketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                         
LEFT JOIN [AVL].[MAS_AssignmentGroupType](NOLOCK) AGG ON AGG.AssignmentGroupTypeID = TKD.AssignmentGroupID                         
LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON OC.DebtClassificationID = DEBT.DebtClassificationID                                           
LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KEDB ON KEDB.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID                                            
LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = OC.ResidualDebtID                         
LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = OC.AvoidableFlagID                                    
LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON CC.CauseID = TKD.CauseCodeMapID                                   
LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RES ON RES.ResolutionID = TKD.ResolutionCodeMapID                              
LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RLT ON RLT.ReleaseTypeID = TKD.ReleaseTypeMapID                                           
LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TKD.TicketTypeMapID                                            
LEFT JOIN [AVL].[TK_MAP_SourceMapping](NOLOCK) TS ON TS.SourceIDMapID = TKD.TicketSourceMapID                             
INNER JOIN [AVL].MAS_ProjectMaster(NOLOCK) AMP ON AMP.ProjectId=TKV.ProjectId       
INNER JOIN ML.TRN_MLTransaction (NOLOCK) T ON T.TransactionID = TKV.MLTransactionId      
WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0                                                      
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1          
order by APP.ApplicationName,TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]        
END
ELSE
BEGIN
select DISTINCT APP.TowerName AS [Application Name / Tower Name],TKV.TicketID AS [Ticket ID],          
 TKD.TicketDescription  AS TicketDescription, TKD.ResolutionRemarks,        
DEBT.DebtClassificationName AS [Debt Classification], AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                                  
  CC.CauseCode AS CauseCodeMapID, RES.ResolutionCode AS ResolutionCodeMapID,                                          
  TKV.Description_threshold As [Issue Description match %],TKV.ClusterID_Desc As [Issue Description Cluster Id],TKV.Description_Keys_Tokens AS [Issue Description Cluster],                            
  TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],                            
  TKV.Resolution_threshold As [Resolution Provided match %],                                          
  TKV.Resolution_Keys_Tokens AS [Resolution Provided Cluster], TKV.IsOverwrite,TKD.Category AS Category,TKD.Comments AS Comments, TKD.FlexField1, TKD.FlexField2, TKD.FlexField3,                              
  TKD.FlexField4,TKD.RelatedTickets,                                  
   TKD.ResolutionRemarks,                                  
  TKD.TicketSummary,                        
  TKD.AssignmentGroup AS AssignmentGroupID,                        
  KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                      
  TS.SourceName AS TicketSourceMapID,                            
  TKV.Description_Keys_Tokens AS Description_Keys_Tokens,        
  TKV.Resolution_Keys_Tokens AS Resolution_Keys_Tokens ,AMP.IsCoginzant AS IsCognizant,           
  CASE WHEN TKV.CREATEDBY = 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 ) THEN 'System'       
  WHEN (TKV.CREATEDBY <> 'System' AND ((ISNULL(OC.DebtClassificationID,0)) <> 0      
 OR (ISNULL(OC.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(OC.ResidualDebtID,0)) <> 0 )) THEN OC.CREATEDBY      
 ELSE  '' END AS 'Classified By'           
  ,TKV.TowerId as ApplicationID      
  ,CASE WHEN (T.IssueDefinitionId=9 OR  T.IssueDefinitionId=10) THEN 1 ELSE 0 END AS 'IsEncrypt'      
FROM ML.[TRN_ClusteringOutcomeUploadedData_Infra](NOLOCK) OC         
JOIN ML.[TRN_ClusteringTicketValidation_infra] TKV on OC.TicketID = TKV.TicketID and OC.ProjectId = TKV.ProjectId and         
OC.TowerID = TKV.TowerId        
INNER JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) APP ON TKV.TowerId = APP.InfraTowerTransactionID                          
INNER JOIN #TempInfraDown SAPP ON APP.InfraTowerTransactionID =SAPP.TowerId        
INNER JOIN  AVL.TK_TRN_InfraTicketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                         
LEFT JOIN [AVL].[MAS_AssignmentGroupType](NOLOCK) AGG ON AGG.AssignmentGroupTypeID = TKD.AssignmentGroupID                         
LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON OC.DebtClassificationID = DEBT.DebtClassificationID                                           
LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KEDB ON KEDB.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID                                            
LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = OC.ResidualDebtID                         
LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = OC.AvoidableFlagID                                    
LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON CC.CauseID = TKD.CauseCodeMapID                                   
LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RES ON RES.ResolutionID = TKD.ResolutionCodeMapID                              
LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RLT ON RLT.ReleaseTypeID = TKD.ReleaseTypeMapID                                           
LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TKD.TicketTypeMapID                                            
LEFT JOIN [AVL].[TK_MAP_SourceMapping](NOLOCK) TS ON TS.SourceIDMapID = TKD.TicketSourceMapID                             
INNER JOIN [AVL].MAS_ProjectMaster(NOLOCK) AMP ON AMP.ProjectId=TKV.ProjectId       
INNER JOIN ML.TRN_MLTransaction (NOLOCK) T ON T.TransactionID = TKV.MLTransactionId      
WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0                                                      
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsDeleted = 0          
order by APP.TowerName,TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]                           
END
           
 END        
 ELSE        
 BEGIN  
  IF(@SupporttypeId=1)
 BEGIN
    SELECT DISTINCT APP.ApplicationName AS [Application Name / Tower Name],TKV.TicketID AS [Ticket ID],                                    
   TKD.TicketDescription  AS TicketDescription                                    
  , TKD.ResolutionRemarks,                                     
   DEBT.DebtClassificationName AS [Debt Classification],                                             
  AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                                    
  CC.CauseCode AS CauseCodeMapID, RES.ResolutionCode AS ResolutionCodeMapID,                                            
  TKV.Description_threshold As [Issue Description match %],TKV.ClusterID_Desc As [Issue Description Cluster Id],TKV.Description_Keys_Tokens AS [Issue Description Cluster],                              
  TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],                              
  TKV.Resolution_threshold As [Resolution Provided match %],                                            
  TKV.Resolution_Keys_Tokens AS [Resolution Provided Cluster], TKV.IsOverwrite,TKD.Category AS Category,TKD.Comments AS Comments, TKD.FlexField1, TKD.FlexField2, TKD.FlexField3,                                
  TKD.FlexField4,TKD.RelatedTickets,                                    
  TKD.ResolutionRemarks,                                  
  TKD.TicketSummary,                          
  TKD.AssignmentGroup AS AssignmentGroupID,                          
  KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                        
  TS.SourceName AS TicketSourceMapID,                              
  TKV.Description_Keys_Tokens AS Description_Keys_Tokens,          
  TKV.Resolution_Keys_Tokens AS Resolution_Keys_Tokens ,AMP.IsCoginzant AS IsCognizant       
  ,CASE WHEN TKV.CREATEDBY = 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 )  THEN 'System'       
  WHEN (TKV.CREATEDBY <> 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 )) THEN TKV.CREATEDBY      
 ELSE  '' END AS 'Classified By'           
  ,TKV.ApplicationID                                           
   ,CASE WHEN (T.IssueDefinitionId=9 OR  T.IssueDefinitionId=10) THEN 1 ELSE 0 END AS 'IsEncrypt'      
 FROM ML.TRN_ClusteringTicketValidation_app(NOLOCK) TKV                                                          
 INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) APP ON TKV.ApplicationID = APP.ApplicationID                            
 INNER JOIN #TempAppDown SAPP ON APP.ApplicationId =SAPP.ApplicationId                        
 INNER JOIN  AVL.TK_TRN_Ticketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                           
 LEFT JOIN [AVL].[MAS_AssignmentGroupType](NOLOCK) AGG ON AGG.AssignmentGroupTypeID = TKD.AssignmentGroupID                           
 LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON TKV.DebtClassificationID = DEBT.DebtClassificationID                                             
 LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KEDB ON KEDB.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID                                              
 LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = TKV.ResidualDebtID                                                          
 LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = TKV.AvoidableFlagID                                      
 LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON CC.CauseID = TKD.CauseCodeMapID                                     
 LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RES ON RES.ResolutionID = TKD.ResolutionCodeMapID               
 LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RLT ON RLT.ReleaseTypeID = TKD.ReleaseTypeMapID                                             
 LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TKD.TicketTypeMapID                                              
 LEFT JOIN [AVL].[TK_MAP_SourceMapping](NOLOCK) TS ON TS.SourceIDMapID = TKD.TicketSourceMapID                               
 INNER JOIN [AVL].MAS_ProjectMaster(NOLOCK) AMP ON AMP.ProjectId=TKV.ProjectId         
 INNER JOIN ML.TRN_MLTransaction (NOLOCK) T ON T.TransactionID = TKV.MLTransactionId      
 WHERE TKV.MLTransactionId =@TransactionID  AND TKV.IsDeleted = 0                                                        
 AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1     
 order by APP.ApplicationName,TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]     
 END
 ELSE
  BEGIN
    SELECT DISTINCT APP.TowerName AS [Application Name / Tower Name],TKV.TicketID AS [Ticket ID],                                    
   TKD.TicketDescription  AS TicketDescription                                    
  , TKD.ResolutionRemarks,                                     
   DEBT.DebtClassificationName AS [Debt Classification],                                             
  AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                                    
  CC.CauseCode AS CauseCodeMapID, RES.ResolutionCode AS ResolutionCodeMapID,                                            
  TKV.Description_threshold As [Issue Description match %],TKV.ClusterID_Desc As [Issue Description Cluster Id],TKV.Description_Keys_Tokens AS [Issue Description Cluster],                              
  TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],                              
  TKV.Resolution_threshold As [Resolution Provided match %],                                            
  TKV.Resolution_Keys_Tokens AS [Resolution Provided Cluster], TKV.IsOverwrite,TKD.Category AS Category,TKD.Comments AS Comments, TKD.FlexField1, TKD.FlexField2, TKD.FlexField3,                                
  TKD.FlexField4,TKD.RelatedTickets,                                    
  TKD.ResolutionRemarks,                                  
  TKD.TicketSummary,                          
  TKD.AssignmentGroup AS AssignmentGroupID,                          
  KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                        
  TS.SourceName AS TicketSourceMapID,                              
  TKV.Description_Keys_Tokens AS Description_Keys_Tokens,          
  TKV.Resolution_Keys_Tokens AS Resolution_Keys_Tokens ,AMP.IsCoginzant AS IsCognizant       
  ,CASE WHEN TKV.CREATEDBY = 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 )  THEN 'System'       
  WHEN (TKV.CREATEDBY <> 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 )) THEN TKV.CREATEDBY      
 ELSE  '' END AS 'Classified By'           
  ,TKV.TowerId as ApplicationID                                           
   ,CASE WHEN (T.IssueDefinitionId=9 OR  T.IssueDefinitionId=10) THEN 1 ELSE 0 END AS 'IsEncrypt'      
 FROM ML.[TRN_ClusteringTicketValidation_infra](NOLOCK) TKV                                                          
 INNER JOIN AVL.[InfraTowerDetailsTransaction](NOLOCK) APP ON TKV.TowerId = APP.infratowertransactionid                            
 INNER JOIN #TempInfraDown SAPP ON APP.infratowertransactionid =SAPP.TowerId                        
 INNER JOIN  AVL.TK_TRN_InfraTicketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                           
 LEFT JOIN [AVL].[MAS_AssignmentGroupType](NOLOCK) AGG ON AGG.AssignmentGroupTypeID = TKD.AssignmentGroupID                           
 LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON TKV.DebtClassificationID = DEBT.DebtClassificationID                                             
 LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KEDB ON KEDB.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID                                              
 LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = TKV.ResidualDebtID                                                          
 LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = TKV.AvoidableFlagID                                      
 LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON CC.CauseID = TKD.CauseCodeMapID                                     
 LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RES ON RES.ResolutionID = TKD.ResolutionCodeMapID               
 LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RLT ON RLT.ReleaseTypeID = TKD.ReleaseTypeMapID                                             
 LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TKD.TicketTypeMapID                                              
 LEFT JOIN [AVL].[TK_MAP_SourceMapping](NOLOCK) TS ON TS.SourceIDMapID = TKD.TicketSourceMapID                               
 INNER JOIN [AVL].MAS_ProjectMaster(NOLOCK) AMP ON AMP.ProjectId=TKV.ProjectId         
 INNER JOIN ML.TRN_MLTransaction (NOLOCK) T ON T.TransactionID = TKV.MLTransactionId      
 WHERE TKV.MLTransactionId =@TransactionID  AND TKV.IsDeleted = 0                                                        
 AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsDeleted = 0    
 order by APP.TowerName,TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]  
  END
 END
   
      
       
 END        
  ---------------- ClusterLevelOutcome -------------------------           
IF OBJECT_ID(N'tempdb..#ClusterLevel') IS NOT NULL            
BEGIN DROP TABLE #ClusterLevel END         
  CREATE TABLE #ClusterLevel(          
[Application Name / Tower Name] varchar(200),          
[Issue Description Cluster Id] int,          
[Issue Description Cluster] varchar(300),           
[Resolution Provided Cluster Id] int,           
[Resolution Provided Cluster] varchar(300),          
[AssignmentGroupID] varchar(400),          
[KEDBAvailableIndicatorMapID] varchar(100),          
[ReleaseTypeMapID] varchar(100),          
[TicketTypeMapID] varchar(500),                                                      
[TicketSourceMapID] varchar(100),         
[Categorical fields] varchar(50),         
[Classified By] varchar(100),          
[Debt Classification] varchar(50),          
[Avoidable Flag] varchar(10),           
[Residual Debt] varchar(10),       
[Pattern] varchar(300),        
[ApplicationID] int        
)          
        
           
 IF(@IsRegenerate=0 AND @isLastUploadFile=1 AND @IsSignoff=0)        
 BEGIN        
 IF(@SupporttypeId=1)
 BEGIN
 INSERT INTO #ClusterLevel         
  SELECT  APP.ApplicationName AS 'Application Name / Tower Name', TKV.ClusterID_Desc AS [Issue Description Cluster Id],             
TKV.Description_Keys_Tokens AS [Issue Description Cluster], TKV.ClusterID_Resolution As [Resolution Provided Cluster Id], TKV.Resolution_Keys_Tokens AS [Resolution Provided Cluster],          
TKD.AssignmentGroup AS AssignmentGroupID,KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                        
TS.SourceName AS TicketSourceMapID,0,      
  CASE WHEN TKV.CREATEDBY = 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 ) THEN 'System'       
  WHEN (TKV.CREATEDBY <> 'System' AND ((ISNULL(OC.DebtClassificationID,0)) <> 0      
 OR (ISNULL(OC.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(OC.ResidualDebtID,0)) <> 0 )) THEN 'User'      
 ELSE  '' END AS 'Classified By',                                   
DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],          
CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern],TKV.ApplicationID         
FROM ML.[TRN_ClusteringOutcomeUploadedData_App](NOLOCK) OC         
JOIN ML.TRN_ClusteringTicketValidation_app TKV on OC.TicketID = TKV.TicketID and OC.ProjectId = TKV.ProjectId and         
OC.ApplicationId = TKV.ApplicationId        
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) APP ON TKV.ApplicationID = APP.ApplicationID                            
INNER JOIN #TempAppDown SAPP ON APP.ApplicationId =SAPP.ApplicationId                        
INNER JOIN  AVL.TK_TRN_Ticketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                           
LEFT JOIN [AVL].[MAS_AssignmentGroupType](NOLOCK) AGG ON AGG.AssignmentGroupTypeID = TKD.AssignmentGroupID                           
LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON OC.DebtClassificationID = DEBT.DebtClassificationID                                             
LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KEDB ON KEDB.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID                                              
LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = OC.ResidualDebtID                                                          
LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = OC.AvoidableFlagID                                      
LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON CC.CauseID = TKD.CauseCodeMapID                                     
LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RES ON RES.ResolutionID = TKD.ResolutionCodeMapID                                              
LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RLT ON RLT.ReleaseTypeID = TKD.ReleaseTypeMapID                                             
LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TKD.TicketTypeMapID                                              
LEFT JOIN [AVL].[TK_MAP_SourceMapping](NOLOCK) TS ON TS.SourceIDMapID = TKD.TicketSourceMapID                               
INNER JOIN [AVL].MAS_ProjectMaster(NOLOCK) AMP ON AMP.ProjectId=TKV.ProjectId                          
WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0                                                        
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1            
and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)           
order by TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]      
 END
 ELSE
 BEGIN
   INSERT INTO #ClusterLevel         
  SELECT  APP.TowerName AS 'Application Name / Tower Name', TKV.ClusterID_Desc AS [Issue Description Cluster Id],             
TKV.Description_Keys_Tokens AS [Issue Description Cluster], TKV.ClusterID_Resolution As [Resolution Provided Cluster Id], TKV.Resolution_Keys_Tokens AS [Resolution Provided Cluster],          
TKD.AssignmentGroup AS AssignmentGroupID,KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                        
TS.SourceName AS TicketSourceMapID,0,      
  CASE WHEN TKV.CREATEDBY = 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 ) THEN 'System'       
  WHEN (TKV.CREATEDBY <> 'System' AND ((ISNULL(OC.DebtClassificationID,0)) <> 0      
 OR (ISNULL(OC.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(OC.ResidualDebtID,0)) <> 0 )) THEN 'User'      
 ELSE  '' END AS 'Classified By',                                   
DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],          
CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern],TKV.TowerId as ApplicationID         
FROM ML.[TRN_ClusteringOutcomeUploadedData_Infra](NOLOCK) OC         
JOIN ML.[TRN_ClusteringTicketValidation_infra](NOLOCK) TKV on OC.TicketID = TKV.TicketID and OC.ProjectId = TKV.ProjectId and         
OC.TowerID = TKV.TowerId        
INNER JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) APP ON TKV.TowerId = APP.infratowertransactionid                            
INNER JOIN #TempInfraDown SAPP ON APP.infratowertransactionid =SAPP.TowerId                        
INNER JOIN  AVL.TK_TRN_InfraTicketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                           
LEFT JOIN [AVL].[MAS_AssignmentGroupType](NOLOCK) AGG ON AGG.AssignmentGroupTypeID = TKD.AssignmentGroupID                           
LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON OC.DebtClassificationID = DEBT.DebtClassificationID                                             
LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KEDB ON KEDB.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID                                              
LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = OC.ResidualDebtID                                                          
LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = OC.AvoidableFlagID                                      
LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON CC.CauseID = TKD.CauseCodeMapID                                     
LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RES ON RES.ResolutionID = TKD.ResolutionCodeMapID                                              
LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RLT ON RLT.ReleaseTypeID = TKD.ReleaseTypeMapID                                             
LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TKD.TicketTypeMapID                                              
LEFT JOIN [AVL].[TK_MAP_SourceMapping](NOLOCK) TS ON TS.SourceIDMapID = TKD.TicketSourceMapID                               
INNER JOIN [AVL].MAS_ProjectMaster(NOLOCK) AMP ON AMP.ProjectId=TKV.ProjectId                          
WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0                                                        
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsDeleted = 0            
and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)           
order by TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]    
 END
   
 END        
 ELSE        
 BEGIN        
 IF(@SupporttypeId=1)   
 BEGIN
 INSERT INTO #ClusterLevel         
 SELECT  APP.ApplicationName AS 'Application Name / Tower Name', TKV.ClusterID_Desc AS [Issue Description Cluster Id],             
TKV.Description_Keys_Tokens AS [Issue Description Cluster], TKV.ClusterID_Resolution As [Resolution Provided Cluster Id], TKV.Resolution_Keys_Tokens AS [Resolution Provided Cluster],          
TKD.AssignmentGroup AS AssignmentGroupID,KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                        
TS.SourceName AS TicketSourceMapID,0,      
  CASE WHEN TKV.CREATEDBY = 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 ) THEN 'System'       
  WHEN (TKV.CREATEDBY <> 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 )) THEN 'User'      
 ELSE  '' END AS 'Classified By',      
--TKV.CreatedBy As 'Classified By',                             
DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],          
CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern] ,TKV.ApplicationID          
FROM ML.TRN_ClusteringTicketValidation_app(NOLOCK) TKV                                                          
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) APP ON TKV.ApplicationID = APP.ApplicationID                            
INNER JOIN #TempAppDown SAPP ON APP.ApplicationId =SAPP.ApplicationId                        
INNER JOIN  AVL.TK_TRN_Ticketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                           
LEFT JOIN [AVL].[MAS_AssignmentGroupType](NOLOCK) AGG ON AGG.AssignmentGroupTypeID = TKD.AssignmentGroupID                           
LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON TKV.DebtClassificationID = DEBT.DebtClassificationID                                               
LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KEDB ON KEDB.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID                                              
LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = TKV.ResidualDebtID                                                          
LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = TKV.AvoidableFlagID                                       
LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON CC.CauseID = TKD.CauseCodeMapID                                     
LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RES ON RES.ResolutionID = TKD.ResolutionCodeMapID                                              
LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RLT ON RLT.ReleaseTypeID = TKD.ReleaseTypeMapID                                             
LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TKD.TicketTypeMapID                                              
LEFT JOIN [AVL].[TK_MAP_SourceMapping](NOLOCK) TS ON TS.SourceIDMapID = TKD.TicketSourceMapID                               
INNER JOIN [AVL].MAS_ProjectMaster(NOLOCK) AMP ON AMP.ProjectId=TKV.ProjectId                          
WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0                                                        
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1            
and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)      
order by TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution] 
END
ELSE
BEGIN
 INSERT INTO #ClusterLevel         
 SELECT  APP.TowerName AS 'Application Name / Tower Name', TKV.ClusterID_Desc AS [Issue Description Cluster Id],             
TKV.Description_Keys_Tokens AS [Issue Description Cluster], TKV.ClusterID_Resolution As [Resolution Provided Cluster Id], TKV.Resolution_Keys_Tokens AS [Resolution Provided Cluster],          
TKD.AssignmentGroup AS AssignmentGroupID,KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                        
TS.SourceName AS TicketSourceMapID,0,      
  CASE WHEN TKV.CREATEDBY = 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 ) THEN 'System'       
  WHEN (TKV.CREATEDBY <> 'System' AND ((ISNULL(TKV.DebtClassificationID,0)) <> 0      
 OR (ISNULL(TKV.AvoidableFlagID,0)) <> 0       
 OR (ISNULL(TKV.ResidualDebtID,0)) <> 0 )) THEN 'User'      
 ELSE  '' END AS 'Classified By',      
--TKV.CreatedBy As 'Classified By',                             
DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],          
CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern] ,TKV. TowerId as ApplicationID          
FROM ML.[TRN_ClusteringTicketValidation_infra](NOLOCK) TKV                                                          
INNER JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) APP ON TKV.TowerId = APP.infratowertransactionid                            
INNER JOIN #TempInfraDown SAPP ON APP.infratowertransactionid =SAPP.TowerId                        
INNER JOIN  AVL.TK_TRN_InfraTicketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                           
LEFT JOIN [AVL].[MAS_AssignmentGroupType](NOLOCK) AGG ON AGG.AssignmentGroupTypeID = TKD.AssignmentGroupID                           
LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON TKV.DebtClassificationID = DEBT.DebtClassificationID                                               
LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KEDB ON KEDB.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID                                              
LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = TKV.ResidualDebtID                                                          
LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = TKV.AvoidableFlagID                                       
LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON CC.CauseID = TKD.CauseCodeMapID                                     
LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RES ON RES.ResolutionID = TKD.ResolutionCodeMapID                                              
LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RLT ON RLT.ReleaseTypeID = TKD.ReleaseTypeMapID                                             
LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TKD.TicketTypeMapID                                              
LEFT JOIN [AVL].[TK_MAP_SourceMapping](NOLOCK) TS ON TS.SourceIDMapID = TKD.TicketSourceMapID                               
INNER JOIN [AVL].MAS_ProjectMaster(NOLOCK) AMP ON AMP.ProjectId=TKV.ProjectId                          
WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0                                                        
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsDeleted = 0           
and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)      
order by TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution] 
END

 END        
          
          
IF OBJECT_ID(N'tempdb..#ClusterLevelGroup') IS NOT NULL            
BEGIN DROP TABLE #ClusterLevelGroup END           
select IDENTITY(INT,1,1) AS ID,[Issue Description Cluster Id], [Resolution Provided Cluster Id] , count(Pattern) as CntPattern into #ClusterLevelGroup          
from #ClusterLevel group by [Issue Description Cluster Id], [Resolution Provided Cluster Id]          
          
CREATE TABLE #ClusterOutcome(          
[Application Name / Tower Name] varchar(200),          
[Issue Description Cluster Id] int,          
[Issue Description Cluster] varchar(300),           
[Resolution Provided Cluster Id] int,        
[Resolution Provided Cluster] varchar(300),          
[AssignmentGroupID] varchar(400),          
[KEDBAvailableIndicatorMapID] varchar(100),          
[ReleaseTypeMapID] varchar(100),          
[TicketTypeMapID] varchar(500),                                                      
[TicketSourceMapID] varchar(100),         
[Categorical fields] varchar(50),        
[Classified By] varchar(100),          
[Debt Classification] varchar(50),          
[Avoidable Flag] varchar(10),           
[Residual Debt] varchar(10),      
ApplicationID int        
)          
          
Insert into #ClusterOutcome          
select Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],          
Cl.[Categorical fields],       
--cl.[Classified By],      
CASE WHEN (COUNT(IIF(cl.[Classified By] = 'System', 1, NULL))>COUNT(IIF(cl.[Classified By] <> 'System', 1, NULL)))         
THEN 'System'        
WHEN(COUNT(IIF(cl.[Classified By] = 'User', 1, NULL))>=COUNT(IIF(cl.[Classified By] <> 'User', 1, NULL)))       
THEN 'User'     
ELSE ''       
END AS [Classified By],          
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],       
Cl.ApplicationId        
from #ClusterLevel cl          
join #ClusterLevelGroup clg on cl.[Issue Description Cluster Id] = clg.[Issue Description Cluster Id] and           
cl.[Resolution Provided Cluster Id] = clg.[Resolution Provided Cluster Id] and clg.CntPattern = 1          
GROUP BY Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],        
Cl.[Categorical fields],        
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],          
Cl.ApplicationId        
        
DECLARE @current_id INT;          
SELECT @current_id = (select MIN(Id) FROM #ClusterLevelGroup where CntPattern > 1)          
          
WHILE @current_id <= (select MAX(Id) FROM #ClusterLevelGroup where CntPattern > 1)          
BEGIN          
          
DECLARE @Desc_id INT;          
DECLARE @Res_id INT;          
SELECT @Desc_id = (select [Issue Description Cluster Id] FROM #ClusterLevelGroup where id = @current_id)          
SELECT @Res_id = (select [Resolution Provided Cluster Id] FROM #ClusterLevelGroup where id = @current_id)           
          
IF((select count(*) from #ClusterLevel where [Issue Description Cluster Id] = @Desc_id and [Resolution Provided Cluster Id] = @Res_id and Pattern not like('%0%') ) = 1)          
BEGIN          
Insert into #ClusterOutcome          
select Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],          
Cl.[Categorical fields],        
CASE WHEN (COUNT(IIF(cl.[Classified By] = 'System', 1, NULL))>COUNT(IIF(cl.[Classified By] <> 'System', 1, NULL)))         
THEN 'System'        
WHEN(COUNT(IIF(cl.[Classified By] = 'User', 1, NULL))>=COUNT(IIF(cl.[Classified By] <> 'User', 1, NULL)))       
THEN 'User'       
ELSE ''       
END AS [Classified By],            
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],      
Cl.ApplicationId         
from #ClusterLevel Cl where [Issue Description Cluster Id] = @Desc_id and [Resolution Provided Cluster Id] = @Res_id and Pattern not like('%0%')          
GROUP BY Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],        
Cl.[Categorical fields],        
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],         
Cl.ApplicationId        
END          
          
ELSE          
BEGIN          
      
IF OBJECT_ID(N'tempdb..#ClusterGroup') IS NOT NULL            
BEGIN DROP TABLE #ClusterGroup END        
      
CREATE TABLE #ClusterGroup(      
CntPattern int,      
Pattern varchar(100)      
)      
       
Insert into #ClusterGroup       
select count([Pattern]) as CntPattern, Pattern            
from #ClusterLevel where [Issue Description Cluster Id] = @Desc_id and [Resolution Provided Cluster Id] = @Res_id and Pattern not like '%0%'  group by Pattern           
      
IF((select count(*) from #ClusterGroup) = 0)      
BEGIN      
Insert into #ClusterGroup       
select count([Pattern]) as CntPattern, Pattern         
from #ClusterLevel where [Issue Description Cluster Id] = @Desc_id and [Resolution Provided Cluster Id] = @Res_id group by Pattern      
END      
          
IF OBJECT_ID(N'tempdb..#ClusterPattern') IS NOT NULL            
BEGIN DROP TABLE #ClusterPattern END           
select distinct CntPattern into #ClusterPattern from #ClusterGroup          
          
IF ((select count(*) from #ClusterPattern) > 1)          
BEGIN          
Insert into #ClusterOutcome          
select Top 1 Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],          
Cl.[Categorical fields],        
CASE WHEN (COUNT(IIF(cl.[Classified By] = 'System', 1, NULL))>COUNT(IIF(cl.[Classified By] <> 'System', 1, NULL)))         
THEN 'System'        
WHEN(COUNT(IIF(cl.[Classified By] = 'User', 1, NULL))>=COUNT(IIF(cl.[Classified By] <> 'User', 1, NULL)))       
THEN 'User'       
ELSE ''       
END AS [Classified By],           
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],      
Cl.ApplicationId           
from #ClusterLevel Cl where [Issue Description Cluster Id] = @Desc_id and [Resolution Provided Cluster Id] = @Res_id          
and Pattern = (select Top 1 Pattern from #ClusterGroup Order by CntPattern desc)          
GROUP BY Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],        
Cl.[Categorical fields],        
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],      
Cl.ApplicationId        
END          
          
ELSE          
BEGIN          
IF OBJECT_ID(N'tempdb..#ClusterOverAllGroup') IS NOT NULL            
BEGIN DROP TABLE #ClusterOverAllGroup END           
select count(Pattern) as CntOverAllPattern,Pattern into #ClusterOverAllGroup          
from #ClusterLevel where Pattern in (select Pattern from #ClusterGroup) group by Pattern          
          
IF OBJECT_ID(N'tempdb..#ClusterOverAllPattern') IS NOT NULL            
BEGIN DROP TABLE #ClusterOverAllPattern END           
select distinct CntOverAllPattern into #ClusterOverAllPattern           
from #ClusterOverAllGroup          
          
IF ((select count(*) from #ClusterOverAllPattern) > 1)          
BEGIN          
Insert into #ClusterOutcome          
select Top 1 Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],         
Cl.[Categorical fields],        
CASE WHEN (COUNT(IIF(cl.[Classified By] = 'System', 1, NULL))>COUNT(IIF(cl.[Classified By] <> 'System', 1, NULL)))         
THEN 'System'        
WHEN(COUNT(IIF(cl.[Classified By] = 'User', 1, NULL))>=COUNT(IIF(cl.[Classified By] <> 'User', 1, NULL)))       
THEN 'User'       
ELSE ''       
END AS [Classified By],           
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],       
Cl.ApplicationId           
from #ClusterLevel Cl where [Issue Description Cluster Id] = @Desc_id and [Resolution Provided Cluster Id] = @Res_id          
and Pattern = (select Top 1 Pattern from #ClusterOverAllGroup Order by CntOverAllPattern desc)          
GROUP BY Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],        
Cl.[Categorical fields],        
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],        
Cl.ApplicationId        
END          
ELSE          
BEGIN        
      
IF((select count(*) from #ClusterLevel Cl where [Issue Description Cluster Id] = @Desc_id      
and [Resolution Provided Cluster Id] = @Res_id and Pattern not like('%0%')) > 0)      
BEGIN      
Insert into #ClusterOutcome          
select Top 1 Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],        
Cl.[Categorical fields],        
CASE WHEN (COUNT(IIF(cl.[Classified By] = 'System', 1, NULL))>COUNT(IIF(cl.[Classified By] <> 'System', 1, NULL)))         
THEN 'System'        
WHEN(COUNT(IIF(cl.[Classified By] = 'User', 1, NULL))>=COUNT(IIF(cl.[Classified By] <> 'User', 1, NULL)))       
THEN 'User'       
ELSE ''       
END AS [Classified By],           
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],       
Cl.ApplicationId          
from #ClusterLevel Cl where [Issue Description Cluster Id] = @Desc_id      
and [Resolution Provided Cluster Id] = @Res_id and Pattern not like('%0%')        
GROUP BY Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],        
Cl.[Categorical fields],        
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],      
Cl.ApplicationId       
END      
      
ELSE      
BEGIN      
Insert into #ClusterOutcome          
select Top 1 Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                                      
Cl.[TicketSourceMapID],        
Cl.[Categorical fields],        
CASE WHEN (COUNT(IIF(cl.[Classified By] = 'System', 1, NULL))>COUNT(IIF(cl.[Classified By] <> 'System', 1, NULL)))         
THEN 'System'        
WHEN(COUNT(IIF(cl.[Classified By] = 'User', 1, NULL))>=COUNT(IIF(cl.[Classified By] <> 'User', 1, NULL)))       
THEN 'User'       
ELSE ''       
END AS [Classified By],           
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],       
Cl.ApplicationId          
from #ClusterLevel Cl where [Issue Description Cluster Id] = @Desc_id      
and [Resolution Provided Cluster Id] = @Res_id  --and Pattern not like('%0%')        
GROUP BY Cl.[Application Name / Tower Name],          
Cl.[Issue Description Cluster Id],          
Cl.[Issue Description Cluster],           
Cl.[Resolution Provided Cluster Id],           
Cl.[Resolution Provided Cluster],          
Cl.[AssignmentGroupID],          
Cl.[KEDBAvailableIndicatorMapID],          
Cl.[ReleaseTypeMapID],          
Cl.[TicketTypeMapID],                                   
Cl.[TicketSourceMapID],        
Cl.[Categorical fields],        
Cl.[Debt Classification],          
Cl.[Avoidable Flag],           
Cl.[Residual Debt],       
Cl.ApplicationId        
END      
END          
END          
END          
          
SELECT @current_id = (select MIN(Id) FROM #ClusterLevelGroup WHERE Id > @current_id and CntPattern > 1)          
--drop Table #ClusterGroup          
--drop Table #ClusterPattern          
--drop Table #ClusterOverAllGroup          
--drop Table #ClusterOverAllPattern          
          
END;          
                                             

 select * into #categorical from(                                                         
  select FLM.Tk_ticketdetailcolumn As ITSMColumn , FLM.Tk_ticketdetailcolumn as DisplayColumnName                                            
 FROM [ML].[TRN_TransactionCategorical] CTG inner join ml.trn_mltransaction TRN ON CTG.MLtransactionid = TRN.transactionid                                         
 inner join MAS.ML_Prerequisite_FieldMapping FLM ON CTG.categoricalfieldid = FLM.FieldMappingId                                            
 WHERE CTG.Isdeleted = 0 AND TRN.Isdeleted = 0 AND FLM.Isdeleted = 0    and CTG.Mltransactionid=@TransactionID                                             
 ) T                                    
                                    
                               
 update  #categorical set  DisplayColumnName ='CauseCode' where DisplayColumnName='CauseCodeMapID'                                    
 update  #categorical set  DisplayColumnName ='Resolution Code' where DisplayColumnName='ResolutionCodeMapID'                                    
 update  #categorical set  DisplayColumnName ='Assignment Group' where DisplayColumnName='AssignmentGroupID'                                    
 update  #categorical set  DisplayColumnName ='KEDBAvailableIndicator' where DisplayColumnName='KEDBAvailableIndicatorMapID'                                    
 update  #categorical set  DisplayColumnName ='Release Type' where DisplayColumnName='ReleaseTypeMapID'                                    
 update  #categorical set  DisplayColumnName ='Ticket Type' where DisplayColumnName='TicketTypeMapID'                                    
 update  #categorical set  DisplayColumnName ='Ticket Source' where DisplayColumnName='TicketSourceMapID'                                    
           
 SELECT FLM.Tk_ticketdetailcolumn As ITSMColumn,'Issue Description' as DisplayColumnName FROM ml.TRN_MLTransaction(NOLOCK) TRN                                                           
INNER JOIN MAS.ML_Prerequisite_FieldMapping(NOLOCK) FLM ON FLM.FieldMappingId = TRN.IssueDefinitionId                                                          
WHERE TRN.TransactionId = @TransactionID                                                    
UNION                                                           
 SELECT FLM.Tk_ticketdetailcolumn As ITSMColumn ,'Resolution Provided' as DisplayColumnName FROM ml.TRN_MLTransaction(NOLOCK) TRN                                                           
 INNER JOIN MAS.ML_Prerequisite_FieldMapping(NOLOCK) FLM ON FLM.FieldMappingId = TRN.ResolutionProviderId                                 
 WHERE TRN.TransactionId =@TransactionID                                                      
 UNION        
 select  ITSMColumn ,  DisplayColumnName  FROM  #categorical                                     
 UNION                                                         
 SELECT ITSMColumn, ITSMColumn as DisplayColumnName FROM #Columns             
          
DECLARE @ResolutionProvider int = (SELECT COUNT(ResolutionProviderId) FROM ml.TRN_MLTransaction(NOLOCK)                                                    
 WHERE TransactionId =@TransactionID  AND  ResolutionProviderId IS NOT NULL);        
DECLARE @categorical int = (Select Count(TRN.transactionid) FROM [ML].[TRN_TransactionCategorical] CTG  inner join         
 ml.trn_mltransaction TRN ON CTG.MLtransactionid = TRN.transactionid inner join MAS.ML_Prerequisite_FieldMapping FLM ON CTG.categoricalfieldid = FLM.FieldMappingId            
 inner join [ML].[TRN_OutCome] OTC ON CTG.MLtransactionid = OTC.MLtransactionid  and FLM.FieldMappingId = OTC.Level2Id        
 WHERE CTG.Isdeleted = 0 AND TRN.Isdeleted = 0 AND FLM.Isdeleted = 0 and CTG.Mltransactionid=@TransactionID)        
        
       
  Select [Application Name / Tower Name],[Issue Description Cluster Id],          
[Issue Description Cluster],[Resolution Provided Cluster Id],[Resolution Provided Cluster],          
[AssignmentGroupID],[KEDBAvailableIndicatorMapID],[ReleaseTypeMapID],          
[TicketTypeMapID],[TicketSourceMapID],[Categorical fields],        
[Classified By],[Debt Classification],[Avoidable Flag],[Residual Debt],ApplicationID from #ClusterOutcome       
ORDER BY [Application Name / Tower Name],[Issue Description Cluster Id],[Resolution Provided Cluster Id]      
             
        
  IF OBJECT_ID(N'tempdb..#Clustercategorical') IS NOT NULL            
 BEGIN DROP TABLE #Clustercategorical END          
 select * into #Clustercategorical from ( Select TRN.transactionid,FLM.Tk_ticketdetailcolumn As ITSMColumn , FLM.Tk_ticketdetailcolumn as DisplayColumnName FROM [ML].[TRN_TransactionCategorical] CTG  inner join         
 ml.trn_mltransaction TRN ON CTG.MLtransactionid = TRN.transactionid inner join MAS.ML_Prerequisite_FieldMapping FLM ON CTG.categoricalfieldid = FLM.FieldMappingId            
 inner join [ML].[TRN_OutCome] OTC ON CTG.MLtransactionid = OTC.MLtransactionid  and FLM.FieldMappingId = OTC.Level2Id        
 WHERE CTG.Isdeleted = 0 AND TRN.Isdeleted = 0 AND FLM.Isdeleted = 0 and CTG.Mltransactionid=@TransactionID) CT          
          
update  #Clustercategorical set  DisplayColumnName ='CauseCode' where DisplayColumnName='CauseCodeMapID'                                    
 update  #Clustercategorical set  DisplayColumnName ='Resolution Code' where DisplayColumnName='ResolutionCodeMapID'                                    
 update  #Clustercategorical set  DisplayColumnName ='Assignment Group' where DisplayColumnName='AssignmentGroupID'                                    
 update  #Clustercategorical set  DisplayColumnName ='KEDBAvailableIndicator' where DisplayColumnName='KEDBAvailableIndicatorMapID'                                    
 update  #Clustercategorical set  DisplayColumnName ='Release Type' where DisplayColumnName='ReleaseTypeMapID'                                    
 update  #Clustercategorical set  DisplayColumnName ='Ticket Type' where DisplayColumnName='TicketTypeMapID'                                    
 update  #Clustercategorical set  DisplayColumnName ='Ticket Source' where DisplayColumnName='TicketSourceMapID'           
          
         
 IF((Select Count(*) from #Clustercategorical) = 0)        
 BEGIN        
 Insert into #Clustercategorical        
 Select @TransactionID,@Categoricalfields As ITSMColumn , @Categoricalfields as DisplayColumnName        
 END   
         
 select  ITSMColumn ,  DisplayColumnName  FROM  #Clustercategorical                                     
 UNION                                                         
 SELECT ITSMColumn, ITSMColumn as DisplayColumnName FROM #ClusterColumns               
           
       
select @ResolutionProvider as IsResolutioncluster,@categorical as IsCategorical, @TransactionID as TransactionId        
END TRY                                                    
BEGIN CATCH                                                                                
                                 
 DECLARE @ErrorMessage NVARCHAR(4000);                                                                                          
 DECLARE @ErrorSeverity INT;                                                                                          
 DECLARE @ErrorState INT;                                          
                                                                             
select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();                                                                              
                                                            
   --INSERT Error                                                                                          
   EXEC AVL_InsertError '[ML].[DownloadClusteringOutcome]',@ErrorMessage ,0,0                                                       
                                                                                      
END CATCH                                                                                       
END 