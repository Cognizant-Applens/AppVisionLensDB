/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    
CREATE PROCEDURE [AVL].[DebtClassificationModeUpdate]      
@ProjectID BIGINT,      
@TicketID Nvarchar(MAX)    
AS      
BEGIN      
SET NOCOUNT ON;      
      
---------------------------ML----------------------------------------------------------------------------------------------------------          
DECLARE @AlgorithmKey nvarchar(6);          
SET @AlgorithmKey=(SELECT TOP 1 AlgorithmKey FROM [ML].[TRN_MLTransaction] WHERE ProjectId =@ProjectID AND SupportTypeId = 1 AND IsActiveTransaction=1 AND IsDeleted=0)          
      
IF(@AlgorithmKey = 'AL001')    
BEGIN    
                UPDATE td set td.DebtClassificationMode=(CASE WHEN TD.DebtClassificationMapID=MLP.MLDebtClassificationID AND TD.AvoidableFlag=MLP.MLAvoidableFlagID      
                AND TD.ResidualDebtMapID=MLP.MLResidualFlagID AND TR.RuleID IS NOT NULL   THEN 1       
                WHEN (TD.DebtClassificationMapID<>MLP.MLDebtClassificationID OR TD.AvoidableFlag<>MLP.MLAvoidableFlagID      
                OR TD.ResidualDebtMapID<>MLP.MLResidualFlagID) AND TR.RuleID IS NOT NULL THEN 2         
                WHEN TR.RuleID IS NULL AND TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL AND TD.ResidualDebtMapID is not NULL      
                and TD.CauseCodeMapID IS  NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL THEN 5 END),TD.LastUpdatedDate=GETDATE(),TD.ModifiedBy='ML'      
      
                from AVL.TK_TRN_TicketDetail TD LEFT  JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON      
                TD.TimeTickerID=TR.TimeTickerID AND TD.IsDeleted=0       
      
                JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID=TD.ProjectID AND PM.IsDeleted=0 AND PM.IsDebtEnabled='Y'       
                JOIN AVL.MAS_ProjectDebtDetails PD ON PD.ProjectID=PM.ProjectID AND PD.IsDeleted=0 AND PD.MLSignOffDate<=GETDATE() AND PD.IsAutoClassified='Y'      
                LEFT JOIN ML.TRN_PatternValidation MLP ON MLP.ID=TR.RuleID AND MLP.ProjectID=TD.ProjectID       
                AND MLP.IsDeleted=0      
                and td.CauseCodeMapID=MLP.MLCauseCodeID and TD.ResolutionCodeMapID=MLP.MLResolutionCode      
      
                WHERE TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL AND TD.ResidualDebtMapID is not NULL      
                and TD.CauseCodeMapID IS  NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL AND TD.TicketDescription is NOT NULL      
                AND TD.IsDeleted=0       
                AND td.TicketID=@TicketID and td.ProjectID=@ProjectId      
                AND (TD.DARTStatusID=8 OR TD.DARTStatusID=9)      
                AND TD.DebtClassificationMode IS NULL      
    
                                -----------------------Manual--------------------------------------------------      
                UPDATE TD SET TD.DebtClassificationMode=5,LastUpdatedDate=GETDATE(),ModifiedBy='Manual'      
                from AVL.TK_TRN_TicketDetail TD JOIN AVL.MAS_ProjectDebtDetails PD ON       
                TD.ProjectID=PD.ProjectID       
                AND PD.IsDeleted=0 AND TD.IsDeleted=0       
                AND (TD.DARTStatusID=8 OR TD.DARTStatusID=9)      
                JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID=TD.ProjectID AND PM.IsDeleted=0 AND PM.IsDebtEnabled='Y'       
      
      
                WHERE       
                TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL AND TD.ResidualDebtMapID is not NULL      
                and TD.CauseCodeMapID IS  NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL      
                AND td.TicketID=@TicketID and td.ProjectID=@ProjectId       
                AND TD.IsDeleted=0 AND ( TD.DebtClassificationMode IS NULL)      
END       
ELSE    
BEGIN     
                UPDATE td set td.DebtClassificationMode=(CASE WHEN TD.DebtClassificationMapID=MLP.DebtClassificationID AND TD.AvoidableFlag=MLP.AvoidableFlagID      
                AND TD.ResidualDebtMapID=MLP.ResidualDebtID AND TR.ClusterID_Desc IS NOT NULL and TR.ClusterID_Resolution IS NOT NULL  THEN 1       
                WHEN (TD.DebtClassificationMapID<>MLP.DebtClassificationID OR TD.AvoidableFlag<>MLP.AvoidableFlagID      
                OR TD.ResidualDebtMapID<>MLP.ResidualDebtID) AND  TR.ClusterID_Desc IS NOT NULL and TR.ClusterID_Resolution IS NOT NULL THEN 2         
                WHEN TR.ClusterID_Desc IS NOT NULL and TR.ClusterID_Resolution IS NOT NULL AND TD.DebtClassificationMapID IS NOT NULL AND    
                TD.AvoidableFlag IS NOT NULL AND TD.ResidualDebtMapID is not NULL      
                THEN 5 END),TD.LastUpdatedDate=GETDATE(),TD.ModifiedBy='ML'      
      
                from AVL.TK_TRN_TicketDetail TD LEFT  JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON      
                TD.TimeTickerID=TR.TimeTickerID AND TD.IsDeleted=0       
      
                JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID=TD.ProjectID AND PM.IsDeleted=0 AND PM.IsDebtEnabled='Y'       
                JOIN AVL.MAS_ProjectDebtDetails PD ON PD.ProjectID=PM.ProjectID AND PD.IsDeleted=0 AND PD.MLSignOffDate<=GETDATE() AND PD.IsAutoClassified='Y'      
                LEFT JOIN [ML].[TRN_ClusteringTicketValidation_App] MLP ON (MLP.ClusterID_Desc=TR.ClusterID_Desc or MLP.ClusterID_Resolution = TR.ClusterID_Resolution)AND MLP.ProjectID=TD.ProjectID       
                AND MLP.IsDeleted=0      
      
                WHERE TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL AND TD.ResidualDebtMapID is not NULL      
    AND TD.TicketDescription is NOT NULL      
                AND TD.IsDeleted=0       
                AND td.TicketID=@TicketID and td.ProjectID=@ProjectId      
                AND (TD.DARTStatusID=8 OR TD.DARTStatusID=9)      
                AND TD.DebtClassificationMode IS NULL      
    
                  ----------------------------------Manual----------------------------------------------------------------------------------    
                  SELECT FN.ITSMColumn, FN.TK_TicketDetailColumn  INTO #columntemp        
                  FROM [ML].[TRN_MLTransaction] MT              
                  JOIN [ML].[TRN_TransactionCategorical] MD ON MD.MLTransactionId=MT.TransactionId               
                  JOIN [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=MD.CategoricalFieldId                 
                  WHERE ProjectId= @ProjectId  AND SupportTypeId=1 AND ISNULL(MT.IsActiveTransaction,0)=1              
                  UNION              
                  (SELECT FN.ITSMColumn,FN.TK_TicketDetailColumn FROM [ML].[TRN_MLTransaction] t LEFT join               
                  [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=t.IssueDefinitionId              
                  or FN.FieldMappingId=t.ResolutionProviderId                  
                  WHERE t.ProjectId= @ProjectId and SupportTypeId=1 AND ISNULL(t.IsActiveTransaction,0)=1 )          
        
        
                  DECLARE @GetQueryticketdetail NVARCHAR(MAX)        
                  DECLARE @result nvarchar(max)        
                  SET @GetQueryticketdetail=STUFF((SELECT ' ' + ' TD.' + QUOTENAME(TK_TicketDetailColumn) +' IS NOT NULL'+' AND'        
                  from #columntemp (NOLOCK)        
                  FOR XML PATH(''), TYPE        
                  ).value('.', 'NVARCHAR(MAX)')        
                  ,1,0,'')        
        
        
        
                                SET @result='UPDATE TD SET TD.DebtClassificationMode=5,LastUpdatedDate=GETDATE(),ModifiedBy=''Manual''      
                   from AVL.TK_TRN_TicketDetail TD JOIN AVL.MAS_ProjectDebtDetails PD ON       
                                TD.ProjectID=PD.ProjectID       
                                AND PD.IsDeleted=0 AND TD.IsDeleted=0       
                                AND (TD.DARTStatusID=8 OR TD.DARTStatusID=9)      
                                JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID=TD.ProjectID AND PM.IsDeleted=0 AND PM.IsDebtEnabled=''Y''      
                                WHERE '+@GetQueryticketdetail + ' td.TicketID='+QUOTENAME(@TicketID,'''')+' and td.ProjectID='+Convert(NVARCHAR(50),@ProjectID)+'       
                                AND TD.IsDeleted=0 AND TD.DebtClassificationMode IS NULL AND 
								TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL AND TD.ResidualDebtMapID is not NULL'        
    
                                EXEC sp_executesql @result;       
END    
    
    
-------------------DD--------------------------------------------------------------------------------------------------      
      
UPDATE  TD set td.DebtClassificationMode=(CASE WHEN (PDD.ID IS NOT NULL AND TD.DebtClassificationMapID=PDD.DebtClassificationID AND TD.AvoidableFlag=PDD.AvoidableFlagID      
AND TD.ResidualDebtMapID=PDD.ResidualDebtID ) THEN 3 WHEN (PDD.ID IS NOT NULL AND TD.DebtClassificationMapID<>PDD.DebtClassificationID OR      
 TD.AvoidableFlag<>PDD.AvoidableFlagID      
OR TD.ResidualDebtMapID<>PDD.ResidualDebtID )THEN 4 WHEN (PDD.ID IS  NULL AND TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL AND TD.ResidualDebtMapID is not NULL      
and TD.CauseCodeMapID IS  NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL  ) THEN 5 END),LastUpdatedDate=GETDATE(),ModifiedBy='DL'      
from AVL.TK_TRN_TicketDetail TD JOIN AVL.MAS_ProjectDebtDetails PD ON       
TD.ProjectID=PD.ProjectID       
AND PD.IsDeleted=0 AND TD.IsDeleted=0       
AND PD.IsDDAutoClassifiedDate<=GETDATE() AND PD.IsDDAutoClassified='Y'      
 and (TD.DARTStatusID=8 OR TD.DARTStatusID=9)JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID=TD.ProjectID AND PM.IsDeleted=0 AND PM.IsDebtEnabled='Y'      
LEFT JOIN AVL.Debt_MAS_ProjectDataDictionary PDD ON PDD.ProjectID=PD.ProjectID AND PD.IsDeleted=0      
AND TD.ApplicationID=PDD.ApplicationID AND PDD.CauseCodeID=TD.CauseCodeMapID      
AND PDD.ResolutionCodeID=TD.ResolutionCodeMapID      
WHERE       
TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL AND TD.ResidualDebtMapID is not NULL      
and TD.CauseCodeMapID IS  NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL       
AND td.TicketID=@TicketID and td.ProjectID=@ProjectId      
AND TD.IsDeleted=0 AND ((TD.DebtClassificationMode=5 AND TD.ModifiedBy='ML')  OR TD.DebtClassificationMode IS NULL)      
      
    
SET NOCOUNT OFF;     
END
