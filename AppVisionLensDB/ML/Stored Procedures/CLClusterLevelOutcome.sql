            
            
            
CREATE PROCEDURE [ML].[CLClusterLevelOutcome]  --[ML].[CLClusterLevelOutcome] 1288,0,'2024-12-16','2024-12-22',0                      
(@TransactionId bigint,                      
@IsManual bit,                      
@FromDate nvarchar(50),                        
@ToDate nvarchar(50),      
@Supporttypeid int)                        
AS                        
BEGIN                        
                         
 SET NOCOUNT ON;                        
                        
                        
   ---------------- ClusterLevelOutcome -------------------------                             
IF OBJECT_ID(N'tempdb..#ClusterLevel') IS NOT NULL                              
BEGIN DROP TABLE #ClusterLevel END                           
  CREATE TABLE #ClusterLevel(                            
[Application Name / Tower Name] varchar(max),                            
[Issue Description Cluster Id] int,                            
[Issue Description Cluster] varchar(max),                             
[Resolution Provided Cluster Id] int,                             
[Resolution Provided Cluster] varchar(max),                            
[AssignmentGroupID] varchar(max),                            
[KEDBAvailableIndicatorMapID] varchar(max),                            
[ReleaseTypeMapID] varchar(max),                            
[TicketTypeMapID] varchar(max),                                                                        
[TicketSourceMapID] varchar(max),                           
[Categorical fields] varchar(max),                           
[Classified By] varchar(max),                            
[Debt Classification] varchar(50),                            
[Avoidable Flag] varchar(max),                             
[Residual Debt] varchar(max),                         
[Pattern] varchar(max),                          
[ApplicationID] int                          
)                        
                        
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
      
       
IF(@IsManual = 1)                        
BEGIN       
 IF @Supporttypeid = 1                                                    
 BEGIN      
 INSERT INTO #ClusterLevel                     
 SELECT  APP.ApplicationName AS 'Application Name / Tower Name', TKV.ClusterID_Desc AS [Issue Description Cluster Id],                         
 TKV.modified_description AS [Issue Description Cluster], TKV.ClusterID_Resolution As [Resolution Provided Cluster Id], TKV.modified_resolution AS [Resolution Provided Cluster],                      
 TKD.AssignmentGroup AS AssignmentGroupID,KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                                 
 TS.SourceName AS TicketSourceMapID,'', 'User' as 'Classified By', --TKV.CreatedBy As 'Classified By',                                         
 DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                      
 CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern] ,TKV.ApplicationID                      
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
 WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0  and ISNULL(TKV.IsCLReviewCompleted,0) <> 1                                                                   
 AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1                        
 and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)                
 AND ISNULL(TKV.DebtClassificationId,0)=0              
 AND ISNULL(TKV.AvoidableFlagID,0)=0              
 AND ISNULL(TKV.ResidualDebtID,0)=0              
 --AND ISNULL(DEBT.DebtClassificationName,'')<>'' AND ISNULL(AVD.AvoidableFlagName,'')<>'' AND ISNULL(RED.ResidualDebtName,'')<>''                
 AND (TKV.TicketType not in ('LT002','LT003','LT005') OR         
 (TKV.TicketType='LT003' AND ISNULL(TKV.IsCLReviewCompleted,0)=0))        
 AND CAST(TKV.CLJobRunDate AS Date) between  @FromDate and @ToDate                 
 order by TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]            
 END      
 ELSE      
 BEGIN      
 INSERT INTO #ClusterLevel                     
 SELECT  APP.TowerName AS 'Application Name / Tower Name', TKV.ClusterID_Desc AS [Issue Description Cluster Id],                         
 TKV.modified_description AS [Issue Description Cluster], TKV.ClusterID_Resolution As [Resolution Provided Cluster Id], TKV.modified_resolution AS [Resolution Provided Cluster],                 
 TKD.AssignmentGroup AS AssignmentGroupID,KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                                    
 TS.SourceName AS TicketSourceMapID,'', 'User' as 'Classified By', --TKV.CreatedBy As 'Classified By',                                         
 DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                      
 CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern] ,TKV.TowerId as ApplicationID                      
 FROM ML.TRN_ClusteringTicketValidation_infra(NOLOCK) TKV                                                                       
 INNER JOIN AVL.[InfraTowerDetailsTransaction](NOLOCK) APP ON TKV.TowerId = APP.InfraTowerTransactionID                                              
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
 WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0  and ISNULL(TKV.IsCLReviewCompleted,0) <> 1                                                                   
 AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsDeleted = 0                        
 and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)                
 AND ISNULL(TKV.DebtClassificationId,0)=0              
 AND ISNULL(TKV.AvoidableFlagID,0)=0              
 AND ISNULL(TKV.ResidualDebtID,0)=0              
 --AND ISNULL(DEBT.DebtClassificationName,'')<>'' AND ISNULL(AVD.AvoidableFlagName,'')<>'' AND ISNULL(RED.ResidualDebtName,'')<>''                
 AND (TKV.TicketType not in ('LT002','LT003','LT005') OR         
 (TKV.TicketType='LT003' AND ISNULL(TKV.IsCLReviewCompleted,0)=0))        
 AND CAST(TKV.CLJobRunDate AS Date) between  @FromDate and @ToDate                 
 order by TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]    
 END      
END                        
                        
ELSE                        
BEGIN        
 IF @Supporttypeid = 1              
 BEGIN      
INSERT INTO #ClusterLevel                           
 SELECT  APP.ApplicationName AS 'Application Name / Tower Name', TKV.ClusterID_Desc AS [Issue Description Cluster Id],                               
CASE WHEN TKV.modified_description='nan' then TKV.DescriptionText ELSE TKV.modified_description END  AS [Issue Description Cluster],                                  
TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],        
CASE WHEN (ISNULL(TKV.modified_resolution,'')='' OR TKV.modified_resolution = 'nan') then TKD.ResolutionRemarks ELSE TKV.modified_resolution END  AS [Resolution Provided Cluster],                                  
TKD.AssignmentGroup AS AssignmentGroupID,KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                                          
TS.SourceName AS TicketSourceMapID,'', 'User' as 'Classified By', --TKV.CreatedBy As 'Classified By',                                               
DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                           
CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern] ,TKV.ApplicationID                            
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
WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0 and ISNULL(TKV.IsCLReviewCompleted,0) <> 1                                                                         
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1                              
and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)                
AND (TKV.TicketType not in ('LT002','LT003') OR (TKV.TicketType='LT003' AND ISNULL(TKV.IsCLReviewCompleted,0)=0))           
AND ISNULL(TKV.DebtClassificationId,0)<>0                    
AND ISNULL(TKV.AvoidableFlagID,0)<>0                    
AND ISNULL(TKV.ResidualDebtID,0)<>0                    
AND CAST(TKV.CLJobRunDate AS Date) between  @FromDate and @ToDate                        
order by TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]         
END      
ELSE      
BEGIN    
INSERT INTO #ClusterLevel                           
 SELECT  APP.TowerName AS 'Application Name / Tower Name', TKV.ClusterID_Desc AS [Issue Description Cluster Id],                               
CASE WHEN TKV.modified_description='nan' then TKV.DescriptionText ELSE TKV.modified_description END  AS [Issue Description Cluster],                                  
TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],        
CASE WHEN (ISNULL(TKV.modified_resolution,'')='' OR TKV.modified_resolution = 'nan') then TKD.ResolutionRemarks ELSE TKV.modified_resolution END  AS [Resolution Provided Cluster],                                  
TKD.AssignmentGroup AS AssignmentGroupID,KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                                                          
TS.SourceName AS TicketSourceMapID,'', 'User' as 'Classified By', --TKV.CreatedBy As 'Classified By',                                               
DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                           
CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern] ,TKV.TowerId AS ApplicationID                            
FROM ML.TRN_ClusteringTicketValidation_infra(NOLOCK) TKV                                                                       
INNER JOIN AVL.[InfraTowerDetailsTransaction](NOLOCK) APP ON TKV.TowerId = APP.InfraTowerTransactionID                                              
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
WHERE TKV.MLTransactionId = @TransactionID  AND TKV.IsDeleted = 0 and ISNULL(TKV.IsCLReviewCompleted,0) <> 1                                                                   
AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsDeleted = 0                            
and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)                
AND (TKV.TicketType not in ('LT002','LT003') OR (TKV.TicketType='LT003' AND ISNULL(TKV.IsCLReviewCompleted,0)=0))           
AND ISNULL(TKV.DebtClassificationId,0)<>0                    
AND ISNULL(TKV.AvoidableFlagID,0)<>0                    
AND ISNULL(TKV.ResidualDebtID,0)<>0                    
AND CAST(TKV.CLJobRunDate AS Date) between  @FromDate and @ToDate                        
order by TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]        
END      
END    
  
                        
IF OBJECT_ID(N'tempdb..#ClusterLevelGroup') IS NOT NULL                              
BEGIN DROP TABLE #ClusterLevelGroup END                             
select IDENTITY(INT,1,1) AS ID,[Issue Description Cluster Id], [Resolution Provided Cluster Id] , count(Pattern) as CntPattern into #ClusterLevelGroup                            
from #ClusterLevel group by [Issue Description Cluster Id], [Resolution Provided Cluster Id]                            
                            
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
THEN 'System' ELSE 'User' END AS [Classified By],                            
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
THEN 'System' ELSE 'User' END AS [Classified By],                              
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
Pattern varchar(max)                        
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
THEN 'System' ELSE 'User' END AS [Classified By],                             
Cl.[Debt Classification],                            
Cl.[Avoidable Flag],                             
Cl.[Residual Debt],  Cl.ApplicationId                             
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
THEN 'System' ELSE 'User' END AS [Classified By],                             
Cl.[Debt Classification],                            
Cl.[Avoidable Flag],                             
Cl.[Residual Debt],Cl.ApplicationId                             
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
THEN 'System' ELSE 'User' END AS [Classified By],                             
Cl.[Debt Classification],                            
Cl.[Avoidable Flag],                             
Cl.[Residual Debt],   Cl.ApplicationId                            
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
THEN 'System' ELSE 'User' END AS [Classified By],                             
Cl.[Debt Classification],                            
Cl.[Avoidable Flag],                             
Cl.[Residual Debt],  Cl.ApplicationId                            
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
                        
IF(@IsManual = 0)                        
BEGIN      
    
   ---------------- ClusterLevelOutcome -------------------------                             
IF OBJECT_ID(N'tempdb..#MLOverRiddenClusterLevel') IS NOT NULL                              
BEGIN DROP TABLE #MLOverRiddenClusterLevel END                           
CREATE TABLE #MLOverRiddenClusterLevel(                            
[Application Name / Tower Name] varchar(max),                            
[Issue Description Cluster Id] int,                            
[Issue Description Cluster] varchar(max),                             
[Resolution Provided Cluster Id] int,                             
[Resolution Provided Cluster] varchar(max),                            
[AssignmentGroupID] varchar(max),                            
[KEDBAvailableIndicatorMapID] varchar(max),                            
[ReleaseTypeMapID] varchar(max),                            
[TicketTypeMapID] varchar(max),                                                                        
[TicketSourceMapID] varchar(max),                           
[Categorical fields] varchar(max),                           
[Classified By] varchar(max),                            
[Debt Classification] varchar(50),                            
[Avoidable Flag] varchar(max),                             
[Residual Debt] varchar(max),                         
[Pattern] varchar(max),                          
[ApplicationID] int                          
)      
    
IF OBJECT_ID(N'tempdb..#OverALLTicketLevelCluster') IS NOT NULL                              
BEGIN DROP TABLE #OverALLTicketLevelCluster END      
CREATE TABLE #OverALLTicketLevelCluster(        
[Issue Description Cluster Id] int,    
[Resolution Provided Cluster Id] int,    
[Debt Classification] varchar(50),                            
[Avoidable Flag] varchar(max),                             
[Residual Debt] varchar(max),                         
[Pattern] varchar(max),     
)      
    
    
 IF @Supporttypeid = 1     
 BEGIN    
 INSERT INTO #MLOverRiddenClusterLevel     
 SELECT  APP.ApplicationName AS 'Application Name / Tower Name', TKV.ClusterID_Desc AS [Issue Description Cluster Id],                               
 CASE WHEN TKV.Description_Keys_Tokens='nan' then TKV.DescriptionText ELSE TKV.Description_Keys_Tokens END  AS [Issue Description Cluster],                                    
 TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],        
 CASE WHEN (ISNULL(TKV.Resolution_Keys_Tokens,'')='' OR TKV.Resolution_Keys_Tokens = 'nan') then TKD.ResolutionRemarks ELSE TKV.Resolution_Keys_Tokens END  AS [Resolution Provided Cluster],                                  
 TKD.AssignmentGroup AS AssignmentGroupID,KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                    
 TS.SourceName AS TicketSourceMapID,'' AS [Categorical fields],'User' as 'Classified By', --TKV.CreatedBy As 'Classified By',                                               
 DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                            
 CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern] ,TKV.ApplicationID AS ApplicationID                                              
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
 WHERE TKV.MLTransactionId = @TransactionId  AND TKV.IsDeleted = 0 and ISNULL(TKV.IsCLReviewCompleted,0) <> 1                                                                          
 AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1                              
 and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)              
 AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1           
 AND ISNULL(TKV.DebtClassificationId,0)<>0          
 AND ISNULL(TKV.AvoidableFlagID,0)<>0          
 AND ISNULL(TKV.ResidualDebtID,0)<>0          
 AND (TKV.TicketType not in ('LT002','LT003') OR (TKV.TicketType='LT003' AND ISNULL(TKV.IsCLReviewCompleted,0)=0))           
 AND CAST(TKV.CLJobRunDate AS Date) between  @FromDate and @ToDate                       
 order by TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]                         
                        
 INSERT into #OverALLTicketLevelCluster     
 Select TKV.ClusterID_Desc AS [Issue Description Cluster Id],TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],                                             
 DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                            
 CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern]                         
 FROM ML.TRN_ClusteringTicketValidation_app(NOLOCK) TKV                        
 INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) APP ON TKV.ApplicationID = APP.ApplicationID                         
 INNER JOIN  AVL.TK_TRN_Ticketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                                      
 LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON TKV.DebtClassificationID = DEBT.DebtClassificationID                                                                   
 LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = TKV.ResidualDebtID                                                                            
 LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = TKV.AvoidableFlagID                        
 where MLTransactionId = @TransactionId and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)                         
 AND TKV.IsDeleted = 0  AND TKD.IsDeleted = 0 AND APP.IsActive = 1                         
 AND ISNULL(DEBT.DebtClassificationName,'')<>'' AND ISNULL(AVD.AvoidableFlagName,'')<>'' AND ISNULL(RED.ResidualDebtName,'')<>''       
END    
ELSE    
BEGIN    
 INSERT INTO #MLOverRiddenClusterLevel     
 SELECT  APP.TowerName AS 'Application Name / Tower Name', TKV.ClusterID_Desc AS [Issue Description Cluster Id],                               
 CASE WHEN TKV.Description_Keys_Tokens='nan' then TKV.DescriptionText ELSE TKV.Description_Keys_Tokens END  AS [Issue Description Cluster],                                    
 TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],        
 CASE WHEN (ISNULL(TKV.Resolution_Keys_Tokens,'')='' OR TKV.Resolution_Keys_Tokens = 'nan') then TKD.ResolutionRemarks ELSE TKV.Resolution_Keys_Tokens END  AS [Resolution Provided Cluster],                         
 TKD.AssignmentGroup AS AssignmentGroupID,KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,RLT.ReleaseTypeName AS ReleaseTypeMapID,TTM.TicketType AS TicketTypeMapID,                                    
 TS.SourceName AS TicketSourceMapID,'' AS [Categorical fields],'User' as 'Classified By', --TKV.CreatedBy As 'Classified By',                                               
 DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                            
 CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern] ,TKV.TowerId as ApplicationID                        
 FROM ML.TRN_ClusteringTicketValidation_infra(NOLOCK) TKV                                                                         
 INNER JOIN AVL.[InfraTowerDetailsTransaction](NOLOCK) APP ON TKV.TowerId = APP.InfraTowerTransactionID                                                
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
 WHERE TKV.MLTransactionId = @TransactionId  AND TKV.IsDeleted = 0 and ISNULL(TKV.IsCLReviewCompleted,0) <> 1                                                                          
 AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsDeleted = 0                              
 and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)              
 AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsDeleted = 0           
 AND ISNULL(TKV.DebtClassificationId,0)<>0          
 AND ISNULL(TKV.AvoidableFlagID,0)<>0          
 AND ISNULL(TKV.ResidualDebtID,0)<>0          
 AND (TKV.TicketType not in ('LT002','LT003') OR (TKV.TicketType='LT003' AND ISNULL(TKV.IsCLReviewCompleted,0)=0))           
 AND CAST(TKV.CLJobRunDate AS Date) between  @FromDate and @ToDate                       
 order by TKV.[ClusterID_Desc], TKV.[ClusterID_Resolution]                         
                        
 INSERT into #OverALLTicketLevelCluster     
 Select TKV.ClusterID_Desc AS [Issue Description Cluster Id],TKV.ClusterID_Resolution As [Resolution Provided Cluster Id],                                             
 DEBT.DebtClassificationName AS [Debt Classification],AVD.AvoidableFlagName AS [Avoidable Flag], RED.ResidualDebtName AS [Residual Debt],                            
 CONCAT(ISNUll(DEBT.DebtClassificationName,0),'-',ISNULL(AVD.AvoidableFlagName,0),'-',ISNull(RED.ResidualDebtName,0)) as [Pattern]                         
 FROM ML.TRN_ClusteringTicketValidation_infra(NOLOCK) TKV                                                                         
 INNER JOIN AVL.[InfraTowerDetailsTransaction](NOLOCK) APP ON TKV.TowerId = APP.InfraTowerTransactionID            
 INNER JOIN  AVL.TK_TRN_InfraTicketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId                                     
 LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON TKV.DebtClassificationID = DEBT.DebtClassificationID                                                                   
 LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = TKV.ResidualDebtID                                                                            
 LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = TKV.AvoidableFlagID                        
 where MLTransactionId = @TransactionId and NOT(TKV.ClusterID_Desc = 0 and TKV.ClusterID_Resolution = 0)                         
 AND TKV.IsDeleted = 0  AND TKD.IsDeleted = 0 AND APP.IsDeleted = 0                         
 AND ISNULL(DEBT.DebtClassificationName,'')<>'' AND ISNULL(AVD.AvoidableFlagName,'')<>'' AND ISNULL(RED.ResidualDebtName,'')<>''      
END    
    
    
    
    
    
    
                        
IF((Select Count(*) from #MLOverRiddenClusterLevel) > 0)                        
BEGIN                        
IF OBJECT_ID(N'tempdb..#MLOverRiddenClusterLevelGroup') IS NOT NULL                              
BEGIN DROP TABLE #MLOverRiddenClusterLevelGroup END                             
Select IDENTITY(INT,1,1) AS ID,[Issue Description Cluster Id], [Resolution Provided Cluster Id] , count(Pattern) as CntPattern into #MLOverRiddenClusterLevelGroup                            
from #MLOverRiddenClusterLevel group by [Issue Description Cluster Id], [Resolution Provided Cluster Id]                         
                        
DECLARE @MLOverRiddencurrent_id INT;                            
SELECT @MLOverRiddencurrent_id = (select MIN(Id) FROM #MLOverRiddenClusterLevelGroup)                    
                            
WHILE @MLOverRiddencurrent_id <= (select MAX(Id) FROM #MLOverRiddenClusterLevelGroup)                            
BEGIN                        
                        
DECLARE @MLOverRiddenDesc_id INT;                            
DECLARE @MLOverRiddenRes_id INT;                            
SELECT @MLOverRiddenDesc_id = (select [Issue Description Cluster Id] FROM #MLOverRiddenClusterLevelGroup where id = @MLOverRiddencurrent_id)                            
SELECT @MLOverRiddenRes_id = (select [Resolution Provided Cluster Id] FROM #MLOverRiddenClusterLevelGroup where id = @MLOverRiddencurrent_id)                        
                        
IF OBJECT_ID(N'tempdb..#OverALLTicketLevelClusterGroup') IS NOT NULL                              
BEGIN DROP TABLE #OverALLTicketLevelClusterGroup END                        
select count([Pattern]) as CntPattern, Pattern into #OverALLTicketLevelClusterGroup                        
from #OverALLTicketLevelCluster where [Issue Description Cluster Id] = @MLOverRiddenDesc_id and [Resolution Provided Cluster Id] = @MLOverRiddenRes_id group by Pattern                        
                        
IF OBJECT_ID(N'tempdb..#OverALLTicketLevelClusterPattern') IS NOT NULL                              
BEGIN DROP TABLE #OverALLTicketLevelClusterPattern END                             
select distinct CntPattern into #OverALLTicketLevelClusterPattern from #OverALLTicketLevelClusterGroup                            
                            
IF ((select count(*) from #OverALLTicketLevelClusterPattern) > 1)                            
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
THEN 'System' ELSE 'User' END AS [Classified By],                             
Cl.[Debt Classification],                            
Cl.[Avoidable Flag],                             
Cl.[Residual Debt],  Cl.ApplicationId                             
from #MLOverRiddenClusterLevel Cl where [Issue Description Cluster Id] = @MLOverRiddenDesc_id and [Resolution Provided Cluster Id] = @MLOverRiddenRes_id                            
and Pattern = (select Top 1 Pattern from #OverALLTicketLevelClusterGroup Order by CntPattern desc)                            
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
THEN 'System' ELSE 'User' END AS [Classified By],                             
Cl.[Debt Classification],                            
Cl.[Avoidable Flag],                             
Cl.[Residual Debt],  Cl.ApplicationId                             
from #MLOverRiddenClusterLevel Cl where [Issue Description Cluster Id] = @MLOverRiddenDesc_id and [Resolution Provided Cluster Id] = @MLOverRiddenRes_id                            
and Pattern = (select Top 1 Pattern from #OverALLTicketLevelClusterGroup)                            
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
                        
                        
SELECT @MLOverRiddencurrent_id = (select MIN(Id) FROM #MLOverRiddenClusterLevelGroup WHERE Id > @MLOverRiddencurrent_id)                         
END                        
                        
END                        
END                        
                         
                         
Select DISTINCT [Application Name / Tower Name],[Issue Description Cluster Id],                            
[Issue Description Cluster],[Resolution Provided Cluster Id],[Resolution Provided Cluster],                            
[AssignmentGroupID],[KEDBAvailableIndicatorMapID],[ReleaseTypeMapID],                            
[TicketTypeMapID],[TicketSourceMapID],[Categorical fields],                          
[Classified By],[Debt Classification],[Avoidable Flag],[Residual Debt],ApplicationID from #ClusterOutcome             
--WHERE (@IsManual = 1 AND ISNULL([Debt Classification],'') = '' AND ISNULL([Avoidable Flag],'') = '' AND ISNULL([Residual Debt],'')='') OR  @IsManual = 0 -- Issue Fix            
ORDER BY [Application Name / Tower Name],[Issue Description Cluster Id],[Resolution Provided Cluster Id]                        
                          
END 