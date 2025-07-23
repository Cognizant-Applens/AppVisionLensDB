      
CREATE PROCEDURE [ML].[DownloadAHTickets]            
@TransactionID BIGINT                
AS                
BEGIN                 
BEGIN TRY                 
                 
 CREATE TABLE #Columns(              
 ITSMColumn varchar(50),              
 )              
 INSERT INTO #Columns (ITSMColumn)               
 values               
 ('ApplicationName'),              
 ('TicketID'),              
 ('ClosedDate'),              
 ('TicketStatus'),              
 ('ClusterName'),              
 ('DebtClassification'),              
 ('Residualdebt'),              
 ('Avoidable'),            
 ('A_H_K')            
               
 SELECT DISTINCT APP.ApplicationName AS ApplicationName,TKV.TicketID AS TicketID,TKD.Closeddate AS ClosedDate,                
 STS.DARTStatusName AS TicketStatus,TKV.ClusterID_Desc AS ClusterName,                  
 DEBT.DebtClassificationName AS DebtClassification,                
 AVD.AvoidableFlagName AS Avoidable,              
 RED.ResidualDebtName AS Residualdebt,              
 TKD.Category AS Category,              
 TKD.Comments AS Comments,              
 TKD.FlexField1,              
 TKD.FlexField2,              
 TKD.FlexField3,              
 TKD.FlexField4,              
 TKD.RelatedTickets,              
 TKD.ResolutionRemarks,              
 TKD.TicketDescription,              
 TKD.TicketSummary,              
 AGG.AssignmentGroupTypeName AS AssignmentGroupID,              
 CC.CauseCode AS CauseCodeMapID,              
 KEDB.KEDBAvailableIndicatorName AS KEDBAvailableIndicatorMapID,              
 RLT.ReleaseTypeName AS ReleaseTypeMapID,              
 RES.ResolutionCode AS ResolutionCodeMapID,              
 TTM.TicketType AS TicketTypeMapID,              
 TS.TicketSourceName AS TicketSourceMapID,            
 'AH001' AS A_H_K            
 FROM ML.TRN_ClusteringTicketValidation_app(NOLOCK) TKV                
 INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) APP ON TKV.ApplicationID = APP.ApplicationID                
 INNER JOIN AVL.TK_TRN_Ticketdetail(NOLOCK) TKD ON TKD.TicketID = TKV.TicketID  AND TKV.ProjectId = TKD.ProjectId               
 LEFT JOIN [AVL].[MAS_AssignmentGroupType](NOLOCK) AGG ON AGG.AssignmentGroupTypeID = TKD.AssignmentGroupID                 
 INNER JOIN AVL.TK_MAS_DARTTicketStatus(NOLOCK) STS ON TKD.DARTStatusID = STS.DARTStatusID                
 LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DEBT ON TKD.DebtClassificationMapID = DEBT.DebtClassificationID               
 LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RED ON RED.ResidualDebtID = TKD.ResidualDebtMapID                
 LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AVD ON AVD.AvoidableFlagID = TKD.AvoidableFlag               
 LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON CC.CauseID = TKD.CauseCodeMapID              
 LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KEDB ON KEDB.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID              
 LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RLT ON RLT.ReleaseTypeID = TKD.ReleaseTypeMapID              
 LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RES ON RES.ResolutionID = TKD.ResolutionCodeMapID              
 LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TKD.TicketTypeMapID              
 LEFT JOIN AVL.TK_MAS_TicketSource(NOLOCK) TS ON TS.TicketSourceID = TKD.TicketSourceMapID              
 WHERE TKV.MLTransactionId = @TransactionID AND APP.IsActive = 1 AND TKV.IsDeleted = 0              
 AND TKD.IsDeleted = 0 AND TKV.IsDeleted = 0 AND APP.IsActive = 1 AND  TKV.Isselected = 1            
              
 SELECT FLM.ITSMColumn FROM ml.TRN_MLTransaction(NOLOCK) TRN                 
 INNER JOIN MAS.ML_Prerequisite_FieldMapping(NOLOCK) FLM ON FLM.FieldMappingId = TRN.IssueDefinitionId                
 WHERE TRN.TransactionId = @TransactionID                 
 UNION                 
 SELECT FLM.ITSMColumn FROM ml.TRN_MLTransaction(NOLOCK) TRN                 
 INNER JOIN MAS.ML_Prerequisite_FieldMapping(NOLOCK) FLM ON FLM.FieldMappingId = TRN.ResolutionProviderId                
 WHERE TRN.TransactionId = @TransactionID                
 UNION                 
 SELECT ITSMColumn FROM [ML].[VW_GetCategoricalFields](NOLOCK)  where mltransactionid = 17                
 UNION               
 SELECT ITSMColumn FROM #Columns              
               
 --Select name From  Tempdb.Sys.Columns Where Object_ID = Object_ID('tempdb..#temp')               
                
END TRY                
BEGIN CATCH                                            
                       
 DECLARE @ErrorMessage NVARCHAR(4000);                                                      
 DECLARE @ErrorSeverity INT;                          
 DECLARE @ErrorState INT;                                                      
                                                      
select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();                                                      
                        
   --INSERT Error                                                      
   EXEC AVL_InsertError '[ML].[DownloadAHTickets] ',@ErrorMessage ,0,0                                                               
                                                  
END CATCH                                                   
END
