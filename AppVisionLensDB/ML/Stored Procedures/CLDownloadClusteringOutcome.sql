      
          
            
CREATE PROC [ML].[CLDownloadClusteringOutcome]  --[ML].[CLDownloadClusteringOutcome] 1288,0,0,'2024-12-16','2024-12-22'                                                
@TransactionID BIGINT ,            
@EncEnable BIT,          
@IsManual BIT,          
@FromDate nvarchar(50),          
@ToDate nvarchar(50)          
          
                                                
AS                                                        
BEGIN                                                          
BEGIN TRY           
          
          
                                               
 CREATE TABLE #Columns(                                                            
 ITSMColumn varchar(max),                                                            
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
 ITSMColumn varchar(max),                                                            
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
             
 DECLARE @Categoricalfields NVARCHAR(max)= 'Categorical fields';            
                              
 DECLARE @CLAppCount INT;                              
                                                 
 Declare @Supporttypeid int = (select Supporttypeid from ml.trn_mltransaction where transactionid = @TransactionID)       
       
                         
IF OBJECT_ID(N'tempdb..#ClusterOutcome') IS NOT NULL                              
BEGIN DROP TABLE #ClusterOutcome END       
CREATE TABLE #ClusterOutcome(              
[Application Name / Tower Name] varchar(max),              
[Issue Description Cluster Id] int,              
[Issue Description Cluster] varchar(max),               
[Resolution Provided Cluster Id] int,               
[Resolution Provided Cluster] varchar(max),              
[AssignmentGroupID] varchar(400),              
[KEDBAvailableIndicatorMapID] varchar(max),              
[ReleaseTypeMapID] varchar(max),              
[TicketTypeMapID] varchar(max),                                                          
[TicketSourceMapID] varchar(max),             
[Categorical fields] varchar(max),            
[Classified By] varchar(max),              
[Debt Classification] varchar(max),              
[Avoidable Flag] varchar(max),               
[Residual Debt] varchar(max),        
ApplicationID int            
)       
                                                  
 IF @Supporttypeid = 1                                                  
 BEGIN             
                                       
 SET @CLAppCount = (SELECT COUNT(MLTransactionID) FROM ML.TRN_ClusteringTicketValidation_App (NOLOCK)                              
 WHERE MLTransactionID = @TransactionId AND TicketType NOT IN ('LT002','LT003'))                             
               
 --IF OBJECT_ID(N'tempdb..#TempAppDown') IS NOT NULL                
 --BEGIN DROP TABLE #TempAppDown END              
 --SELECT * INTO #TempAppDown FROM (                                              
 --SELECT TRN.ApplicationID                           
 --FROM [ML].[TRN_ClusteringTicketValidation_app](NOLOCK) TRN                             
 --INNER JOIN ML.TRN_MLTransaction MLTRN ON MLTRN.TransactionId = TRN.MLTransactionId                            
 --INNER JOIN [AVL].[APP_MAS_ApplicationDetails](NOLOCK) APP ON TRN.ApplicationId = APP.ApplicationId                               
 --inner JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) appMap ON TRN.ApplicationId = appMap.ApplicationID                                  
 --AND appmap.projectid =TRN.projectid AND appMap.IsDeleted=0                               
 --WHERE TRN.MLTransactionId = @TransactionId AND TRN.Isdeleted = 0 AND APP.IsActive = 1                                  
 --AND IsSelected=1 AND TicketType not in ('LT002','LT003')            
 --GROUP BY TRN.ApplicationID,APP.ApplicationName,IsSelected                            
 --) AS T                             
                  
              
              
              
---------------- TicketLevelOutcome -------------------------              
          
IF(@IsManual = 1)          
BEGIN          
SELECT DISTINCT APP.ApplicationName AS [Application Name / Tower Name],TKV.TicketID AS [Ticket ID],                                        
TKD.TicketDescription  AS TicketDescription, TKD.ResolutionRemarks,                                         
DEBT.DebtClassificationName AS [Debt Classification], AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                                        
CC.CauseCode AS CauseCodeMapID, RES.ResolutionCode AS ResolutionCodeMapID,                                                
TKV.Description_threshold As [Issue Description match %],TKV.ClusterID_Desc As [Issue Description Cluster Id],        
CASE WHEN TKV.Description_Keys_Tokens='nan' then TKV.DescriptionText ELSE TKV.Description_Keys_Tokens END  AS [Issue Description Cluster],                                  
TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],        
TKV.Resolution_threshold As [Resolution Provided match %],         
CASE WHEN (ISNULL(TKV.Resolution_Keys_Tokens,'')='' or TKV.Resolution_Keys_Tokens = 'nan')  then TKD.ResolutionRemarks ELSE TKV.Resolution_Keys_Tokens  END  AS [Resolution Provided Cluster],        
TKV.IsOverwrite,TKD.Category AS Category,TKD.Comments AS Comments, TKD.FlexField1, TKD.FlexField2, TKD.FlexField3,                           
TKD.FlexField4,TKD.RelatedTickets, TKD.ResolutionRemarks, TKD.TicketSummary,  TKD.AssignmentGroup AS AssignmentGroupID,                              
KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                            
TS.SourceName AS TicketSourceMapID,                                  
CASE WHEN TKV.Description_Keys_Tokens='nan' then TKV.DescriptionText ELSE TKV.Description_Keys_Tokens END AS Description_Keys_Tokens,              
CASE WHEN ISNULL(TKV.Resolution_Keys_Tokens,'nan')='nan' then TKD.ResolutionRemarks ELSE TKV.Resolution_Keys_Tokens END AS Resolution_Keys_Tokens,              
AMP.IsCoginzant AS IsCognizant , 'User' as 'Classified By'--TKV.CreatedBy as 'Classified By'        
,TKV.ApplicationID                                               
,CASE WHEN (T.IssueDefinitionId=9 OR  T.IssueDefinitionId=10) THEN 1 ELSE 0 END AS 'IsEncrypt'          
FROM ML.TRN_ClusteringTicketValidation_app(NOLOCK) TKV                                                              
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) APP ON TKV.ApplicationID = APP.ApplicationID                                
--INNER JOIN #TempAppDown SAPP ON APP.ApplicationId =SAPP.ApplicationId                            
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
WHERE TKV.MLTransactionId =@TransactionID  AND TKV.IsDeleted = 0 and ISNULL(TKV.IsCLReviewCompleted,0) <> 1        
and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)            
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1           
AND ISNULL(TKV.DebtClassificationId,0)=0        
AND ISNULL(TKV.AvoidableFlagID,0)=0        
AND ISNULL(TKV.ResidualDebtID,0)=0        
--AND ISNULL(DEBT.DebtClassificationName,'')<>'' AND ISNULL(AVD.AvoidableFlagName,'')<>'' AND ISNULL(RED.ResidualDebtName,'')<>''        
AND (TKV.TicketType not in ('LT002','LT003') OR (TKV.TicketType='LT003' AND ISNULL(TKV.IsCLReviewCompleted,0)=0))         
AND cast(TKV.CLJobRunDate as Date) between  @FromDate and @ToDate        
order by APP.ApplicationName,TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]           
END          
ELSE          
BEGIN          
SELECT DISTINCT APP.ApplicationName AS [Application Name / Tower Name],TKV.TicketID AS [Ticket ID],                                        
TKD.TicketDescription  AS TicketDescription, TKD.ResolutionRemarks,                                         
DEBT.DebtClassificationName AS [Debt Classification], AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                                    
CC.CauseCode AS CauseCodeMapID, RES.ResolutionCode AS ResolutionCodeMapID,                                                
TKV.Description_threshold As [Issue Description match %],TKV.ClusterID_Desc As [Issue Description Cluster Id],        
CASE WHEN TKV.Description_Keys_Tokens='nan' then TKV.DescriptionText ELSE TKV.Description_Keys_Tokens END AS [Issue Description Cluster],                                  
TKV.ClusterID_Resolution As [Resolution Provided Cluster Id], TKV.Resolution_threshold As [Resolution Provided match %],         
CASE WHEN (ISNULL(TKV.Resolution_Keys_Tokens,'')='' or TKV.Resolution_Keys_Tokens = 'nan')  then TKD.ResolutionRemarks ELSE TKV.Resolution_Keys_Tokens  END  AS [Resolution Provided Cluster],         
TKV.IsOverwrite,TKD.Category AS Category,TKD.Comments AS Comments, TKD.FlexField1, TKD.FlexField2, TKD.FlexField3,                                    
TKD.FlexField4,TKD.RelatedTickets, TKD.ResolutionRemarks, TKD.TicketSummary,  TKD.AssignmentGroup AS AssignmentGroupID,                              
KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                            
TS.SourceName AS TicketSourceMapID,                                  
CASE WHEN TKV.Description_Keys_Tokens='nan' then TKV.DescriptionText ELSE TKV.Description_Keys_Tokens END AS Description_Keys_Tokens,              
CASE WHEN TKV.Resolution_Keys_Tokens='nan' then TKD.ResolutionRemarks ELSE TKV.Resolution_Keys_Tokens END AS Resolution_Keys_Tokens,        
AMP.IsCoginzant AS IsCognizant , 'User' as 'Classified By' --TKV.CreatedBy as 'Classified By'        
,TKV.ApplicationID                                               
,CASE WHEN (T.IssueDefinitionId=9 OR  T.IssueDefinitionId=10) THEN 1 ELSE 0 END AS 'IsEncrypt'          
FROM ML.TRN_ClusteringTicketValidation_app(NOLOCK) TKV                                                              
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) APP ON TKV.ApplicationID = APP.ApplicationID                                
--INNER JOIN #TempAppDown SAPP ON APP.ApplicationId =SAPP.ApplicationId                            
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
WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0 and ISNULL(TKV.IsCLReviewCompleted,0) <> 1            
and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)            
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1         
AND ISNULL(TKV.DebtClassificationId,0)<>0        
AND ISNULL(TKV.AvoidableFlagID,0)<>0        
AND ISNULL(TKV.ResidualDebtID,0)<>0        
AND (TKV.TicketType not in ('LT002','LT003') OR (TKV.TicketType='LT003' AND ISNULL(TKV.IsCLReviewCompleted,0)=0))       
AND cast(TKV.CLJobRunDate as Date) between  @FromDate and @ToDate        
order by APP.ApplicationName,TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]           
END          
                                            
 END            
          
 ELSE                                                  
 BEGIN             
                          
          
 SET @CLAppCount= (SELECT COUNT(MLTransactionID) FROM ML.TRN_ClusteringTicketValidation_Infra (NOLOCK)                              
 WHERE MLTransactionID = @TransactionId AND TicketType NOT IN ('LT002','LT003'))                              
                          
 --SELECT * INTO #TempInfraDown FROM (                                              
 --SELECT TRN.TowerId                            
 --FROM [ML].[TRN_ClusteringTicketValidation_Infra](NOLOCK) TRN                           
 --INNER JOIN AVL.InfraTowerDetailsTransaction (NOLOCK) TW ON TRN.TowerId = TW.InfraTowerTransactionID                          
 --INNER JOIN ML.TRN_MLTransaction MLTRN ON MLTRN.TransactionId = TRN.MLTransactionId                          
 --INNER JOIN [AVL].[InfraTowerProjectMapping](NOLOCK) IT ON TRN.ProjectId=IT.ProjectId And TRN.TowerId = IT.TowerId and IT.IsDeleted=0 AND IT.IsEnabled =1                    
 --WHERE TRN.MLTransactionId = @TransactionId AND TRN.Isdeleted = 0 AND TW.IsDeleted = 0                                 
 --AND (IsSelected=1 OR IsSelected = (CASE WHEN @CLAppCount =0 THEN 1 ELSE 0 END))                            
 --GROUP BY TRN.TowerId,TW.TowerName,IsSelected                          
 -- HAVING COUNT(NULLIF(TRN.ClusterID_Desc,0)) >= CASE WHEN @CLAppCount =0 THEN 0 ELSE 1 END OR                          
 --IsSelected =1                          
 --) AS T                           
                               
 -- SELECT DISTINCT TW.TowerName AS  [Application Name / Tower Name],TKV.TicketID AS [Ticket ID],                                        
 --TKD.TicketDescription   AS TicketDescription, TKD.ResolutionRemarks,                                       
 -- DEBT.DebtClassificationName AS [Debt Classification],                                                 
 -- AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                                        
 -- CC.CauseCode AS CauseCodeMapID, RES.ResolutionCode AS ResolutionCodeMapID,TKV.ClusterID_Desc as [Issue Description Cluster Id],                                                
 -- TKV.Description_threshold As [Issue Description match %],TKV.Description_Keys_Tokens  AS [Issue Description Cluster],                                  
 --TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],                                  
 -- TKV.Resolution_threshold As [Resolution Provided match %],                                                
 -- TKV.Resolution_Keys_Tokens AS   [Resolution Provided Cluster], TKV.IsOverwrite,TKD.Category AS Category,TKD.Comments AS Comments, TKD.FlexField1, TKD.FlexField2, TKD.FlexField3,                                                            
 -- TKD.FlexField4,TKD.RelatedTickets,                                        
 --  CASE WHEN @EncEnable= 1 THEN ' ' Else TKD.ResolutionRemarks END AS ResolutionRemarks,                                        
 -- CASE WHEN @EncEnable= 1 THEN ' ' Else TKD.TicketSummary  END AS TicketSummary                                        
 -- ,TKD.AssignmentGroup AS AssignmentGroupID,                                                 
 -- KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                            
 -- TS.SourceName AS TicketSourceMapID,                                          
 -- TKV.Description_Keys_Tokens AS Description_Keys_Tokens, TKV.Resolution_Keys_Tokens AS Resolution_Keys_Tokens ,AMP.IsCoginzant AS IsCognizant                                        
 --FROM [ML].[TRN_ClusteringTicketValidation_infra](NOLOCK) TKV                                                              
 --INNER JOIN [AVL].[InfraTowerDetailsTransaction](NOLOCK) TW ON TKV.TowerId = TW.infratowertransactionid                                                              
 --INNER JOIN AVL.TK_TRN_InfraTicketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                                                 
 ----INNER JOIN #TempInfraDown SAPP ON TW.infratowertransactionid = SAPP.TowerID                            
 --LEFT JOIN [AVL].[MAS_AssignmentGroupType](NOLOCK) AGG ON AGG.AssignmentGroupTypeID = TKD.AssignmentGroupID                                                 
 --LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON TKD.DebtClassificationMapID = DEBT.DebtClassificationID                                                 
 --LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KEDB ON KEDB.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID                                                  
 --LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = TKD.ResidualDebtMapID                                                              
 --LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = TKD.AvoidableFlag                                                             
 --LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON CC.CauseID = TKD.CauseCodeMapID                    
 --LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RES ON RES.ResolutionID = TKD.ResolutionCodeMapID                                                  
 --LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RLT ON RLT.ReleaseTypeID = TKD.ReleaseTypeMapID                                                 
 --LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TKD.TicketTypeMapID                                                  
 --LEFT JOIN [AVL].[TK_MAP_SourceMapping](NOLOCK) TS ON TS.SourceIDMapID = TKD.TicketSourceMapID                              
 --INNER JOIN [AVL].MAS_ProjectMaster(NOLOCK) AMP ON AMP.ProjectId=TKV.ProjectId                              
 --WHERE TKV.MLTransactionId = @TransactionID AND  TKV.IsDeleted = 0                                           
 --AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND TW.IsDeleted = 0                               
 --AND  (TKV.Isselected = 1 OR IsSelected = (CASE WHEN @CLAppCount = 0 THEN 1 ELSE 0 END))                              
 -- AND (COUNT(NULLIF(TKV.ClusterID_Desc,0)) >= CASE WHEN @CLAppCount = 0 THEN 0  ELSE 1 END OR TKV.IsSelected = 1)        
       
      
 ---------------- TicketLevelOutcome -------------------------              
          
IF(@IsManual = 1)          
BEGIN          
SELECT DISTINCT TW.TowerName AS [Application Name / Tower Name],TKV.TicketID AS [Ticket ID],                                        
TKD.TicketDescription  AS TicketDescription, TKD.ResolutionRemarks,                                         
DEBT.DebtClassificationName AS [Debt Classification], AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                                        
CC.CauseCode AS CauseCodeMapID, RES.ResolutionCode AS ResolutionCodeMapID,               
TKV.Description_threshold As [Issue Description match %],TKV.ClusterID_Desc As [Issue Description Cluster Id],        
CASE WHEN TKV.Description_Keys_Tokens='nan' then TKV.DescriptionText ELSE TKV.Description_Keys_Tokens END AS [Issue Description Cluster],                                  
TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],        
TKV.Resolution_threshold As [Resolution Provided match %],         
CASE WHEN (ISNULL(TKV.Resolution_Keys_Tokens,'')='' or TKV.Resolution_Keys_Tokens = 'nan')  then TKD.ResolutionRemarks ELSE TKV.Resolution_Keys_Tokens  END  AS [Resolution Provided Cluster],        
TKV.IsOverwrite,TKD.Category AS Category,TKD.Comments AS Comments, TKD.FlexField1, TKD.FlexField2, TKD.FlexField3,                                    
TKD.FlexField4,TKD.RelatedTickets, TKD.ResolutionRemarks, TKD.TicketSummary,  TKD.AssignmentGroup AS AssignmentGroupID,                              
KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                            
TS.SourceName AS TicketSourceMapID,                                  
CASE WHEN TKV.Description_Keys_Tokens='nan' then TKV.DescriptionText ELSE TKV.Description_Keys_Tokens END AS Description_Keys_Tokens,              
CASE WHEN ISNULL(TKV.Resolution_Keys_Tokens,'nan')='nan' then TKD.ResolutionRemarks ELSE TKV.Resolution_Keys_Tokens END AS Resolution_Keys_Tokens,              
AMP.IsCoginzant AS IsCognizant , 'User' as 'Classified By'--TKV.CreatedBy as 'Classified By'        
,TKV.TowerId as ApplicationID                                            
,CASE WHEN (T.IssueDefinitionId=9 OR  T.IssueDefinitionId=10) THEN 1 ELSE 0 END AS 'IsEncrypt'          
FROM ML.TRN_ClusteringTicketValidation_infra(NOLOCK) TKV                                                              
INNER JOIN [AVL].[InfraTowerDetailsTransaction](NOLOCK) TW ON TKV.TowerId = TW.infratowertransactionid                             
--INNER JOIN #TempAppDown SAPP ON APP.ApplicationId =SAPP.ApplicationId                            
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
WHERE TKV.MLTransactionId =@TransactionID  AND TKV.IsDeleted = 0 and ISNULL(TKV.IsCLReviewCompleted,0) <> 1        
and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)            
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND TW.IsDeleted = 0           
AND ISNULL(TKV.DebtClassificationId,0)=0        
AND ISNULL(TKV.AvoidableFlagID,0)=0        
AND ISNULL(TKV.ResidualDebtID,0)=0        
--AND ISNULL(DEBT.DebtClassificationName,'')<>'' AND ISNULL(AVD.AvoidableFlagName,'')<>'' AND ISNULL(RED.ResidualDebtName,'')<>''        
AND (TKV.TicketType not in ('LT002','LT003') OR (TKV.TicketType='LT003' AND ISNULL(TKV.IsCLReviewCompleted,0)=0))         
AND cast(TKV.CLJobRunDate as Date) between  @FromDate and @ToDate        
order by TW.TowerName,TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]           
END          
ELSE          
BEGIN          
SELECT DISTINCT TW.TowerName AS [Application Name / Tower Name],TKV.TicketID AS [Ticket ID],                                        
TKD.TicketDescription  AS TicketDescription, TKD.ResolutionRemarks,                                         
DEBT.DebtClassificationName AS [Debt Classification], AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                                        
CC.CauseCode AS CauseCodeMapID, RES.ResolutionCode AS ResolutionCodeMapID,                                                
TKV.Description_threshold As [Issue Description match %],TKV.ClusterID_Desc As [Issue Description Cluster Id],        
CASE WHEN TKV.Description_Keys_Tokens='nan' then TKV.DescriptionText ELSE TKV.Description_Keys_Tokens END AS [Issue Description Cluster],                                  
TKV.ClusterID_Resolution As [Resolution Provided Cluster Id], TKV.Resolution_threshold As [Resolution Provided match %],         
CASE WHEN (ISNULL(TKV.Resolution_Keys_Tokens,'')='' or TKV.Resolution_Keys_Tokens = 'nan')  then TKD.ResolutionRemarks ELSE TKV.Resolution_Keys_Tokens  END  AS [Resolution Provided Cluster],         
TKV.IsOverwrite,TKD.Category AS Category,TKD.Comments AS Comments, TKD.FlexField1, TKD.FlexField2, TKD.FlexField3,                                    
TKD.FlexField4,TKD.RelatedTickets, TKD.ResolutionRemarks, TKD.TicketSummary,  TKD.AssignmentGroup AS AssignmentGroupID,                              
KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                            
TS.SourceName AS TicketSourceMapID,                                  
CASE WHEN TKV.Description_Keys_Tokens='nan' then TKV.DescriptionText ELSE TKV.Description_Keys_Tokens END AS Description_Keys_Tokens,              
CASE WHEN TKV.Resolution_Keys_Tokens='nan' then TKD.ResolutionRemarks ELSE TKV.Resolution_Keys_Tokens END AS Resolution_Keys_Tokens,        
AMP.IsCoginzant AS IsCognizant , 'User' as 'Classified By' --TKV.CreatedBy as 'Classified By'        
,TKV.TowerId as ApplicationID                                              
,CASE WHEN (T.IssueDefinitionId=9 OR  T.IssueDefinitionId=10) THEN 1 ELSE 0 END AS 'IsEncrypt'          
FROM ML.TRN_ClusteringTicketValidation_infra(NOLOCK) TKV                                                              
INNER JOIN [AVL].[InfraTowerDetailsTransaction](NOLOCK) TW ON TKV.TowerId = TW.infratowertransactionid                             
--INNER JOIN #TempAppDown SAPP ON APP.ApplicationId =SAPP.ApplicationId                            
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
WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0 and ISNULL(TKV.IsCLReviewCompleted,0) <> 1            
and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)            
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND TW.IsDeleted = 0         
AND ISNULL(TKV.DebtClassificationId,0)<>0        
AND ISNULL(TKV.AvoidableFlagID,0)<>0        
AND ISNULL(TKV.ResidualDebtID,0)<>0        
AND (TKV.TicketType not in ('LT002','LT003') OR (TKV.TicketType='LT003' AND ISNULL(TKV.IsCLReviewCompleted,0)=0))         
AND cast(TKV.CLJobRunDate as Date) between  @FromDate and @ToDate        
order by TW.TowerName,TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]           
END          
          
      
                                                
 END          
       
 ---------------- ClusterLevelOutcome -------------------------         
                        
           
INSERT INTO  #ClusterOutcome           
Exec [ML].[CLClusterLevelOutcome]  @TransactionID,@IsManual,@FromDate,@ToDate,@Supporttypeid       
      
      
                                              
  ----Ticket Level Categorical ----                                       
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
            
 --IF (@Supporttypeid = 1)          
 --BEGIN             
Select [Application Name / Tower Name],[Issue Description Cluster Id],              
[Issue Description Cluster],[Resolution Provided Cluster Id],[Resolution Provided Cluster],              
[AssignmentGroupID],[KEDBAvailableIndicatorMapID],[ReleaseTypeMapID],              
[TicketTypeMapID],[TicketSourceMapID],[Categorical fields],            
[Classified By],[Debt Classification],[Avoidable Flag],[Residual Debt],              
ApplicationID from #ClusterOutcome           
ORDER BY [Application Name / Tower Name],[Issue Description Cluster Id],[Resolution Provided Cluster Id]          
             
 ----- Cluster Level Categorical------              
  --DECLARE @TransactionID int = 985;            
  --DECLARE @Categoricalfields NVARCHAR(20)= 'Categorical fields';            
            
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
 update  #Clustercategorical set  DisplayColumnName ='Release Type' where DisplayColumnName='ReleaseTypeMapID'                                       update  #Clustercategorical set  DisplayColumnName ='Ticket Type' where DisplayColumnName='TicketTypeMapI
  
D'                                        
 update  #Clustercategorical set  DisplayColumnName ='Ticket Source' where DisplayColumnName='TicketSourceMapID'               
              
             
 IF((Select Count(*) from #Clustercategorical) = 0)            
 BEGIN            
 Insert into #Clustercategorical            
 Select @TransactionID,@Categoricalfields As ITSMColumn , @Categoricalfields as DisplayColumnName            
 END              
             
 select  ITSMColumn ,  DisplayColumnName  FROM  #Clustercategorical                                         
 UNION                                                
 SELECT ITSMColumn, ITSMColumn as DisplayColumnName FROM #ClusterColumns                   
               
                          
 --Select name From  Tempdb.Sys.Columns Where Object_ID = Object_ID('tempdb..#temp')            
          
--END            
select @ResolutionProvider as IsResolutioncluster,@categorical as IsCategorical, @TransactionID as TransactionId            
END TRY                                                        
BEGIN CATCH                                                                                    
                                     
 DECLARE @ErrorMessage NVARCHAR(4000);                                                                                              
 DECLARE @ErrorSeverity INT;                                                                                              
 DECLARE @ErrorState INT;                                              
                                                                                 
select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();                                                                                  
                                                                
   --INSERT Error                                                                                              
   EXEC AVL_InsertError '[ML].[CLDownloadClusteringOutcome]',@ErrorMessage ,0,0                                                           
                                                                                          
END CATCH                      
        
        
END 