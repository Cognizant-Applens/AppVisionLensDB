/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
      
 /***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
       
CREATE PROCEDURE [LW].[LW_GetTotalRules]             
@flag varchar(20),                
@RuleLevel NVARCHAR(50),                  
@AccountId BIGINT,                  
@BUID BIGINT                  
                  
AS                  
                  
BEGIN                  
                  
SET NOCOUNT ON;                  
                  
BEGIN TRY                  
IF(@flag= 'Delivery')                  
BEGIN                 
    SELECT rule_transaction.[RecordID],  
     master_rules.[DescWorkPattern],                  
     master_rules.[DescWorkSubPattern],  
     master_rules.[ResolutionWorkPattern],                  
     master_rules.[ResolutionWorkSubPattern],  
     master_rules.[CauseCode],  
     master_rules.[ResolutionCode],                  
     master_rules.[DebtClassification],  
     master_rules.[AvoidableFlag],                  
     DATEDIFF(day,rule_transaction.[CreatedDate], GETDATE()) AS RuleAge,                  
     rule_transaction.[AccountName] AS RuleSource,                  
     rule_transaction.[RuleLevel],rule_transaction.[RuleStatusInd],                  
     rule_transaction.[NewRuleReferanceID] ,rule_transaction.[IsOveridden],                  
     rule_transaction.[AccountID],                  
     LEFT(CONVERT(VARCHAR,rule_transaction.[ModifiedDate], 120), 10) AS MutedSince,                  
     master_rules.[ResidualDebt]                  
     FROM [LW].[RuleTransaction] rule_transaction WITH (NOLOCK)  INNER JOIN                   
    [MAS].[ML_RulesMaster] master_rules                  
    ON rule_transaction.[RuleID] = master_rules.[RuleID] WHERE                  
    rule_transaction.[AccountID] = ISNULL(@AccountId, rule_transaction.[AccountID])                  
    AND rule_transaction.[BUID] = ISNULL(@BUID, rule_transaction.BUID)                  
          AND rule_transaction.[RuleLevel] = @RuleLevel AND RuleStatusInd  IS NOT NULL;                  
                  
                
END                  
ELSE IF(@flag = 'Commercial')                  
BEGIN                  
    
 ;WITH cteChildRule AS      
 (      
  SELECT RT1.RuleReferanceID,MIN(RT1.RuleID) AS ChildID       
  FROM [BID].[RuleTransaction] RT1 WITH (NOLOCK)      
  JOIN [BID].[RuleTransaction] RT2 WITH (NOLOCK) ON RT1.RuleID=RT2.RuleID AND RT2.RuleStatusInd=1      
  WHERE RT1.RuleReferanceID>0 --AND RT1.[RuleStatusInd] <> 1             
  GROUP BY RT1.RuleReferanceID      
 ),      
 cteParentRule AS      
 (      
     SELECT RT.RuleReferanceID,ChildID AS RuleID,RuleID AS ParentRuleID      
     FROM [BID].[RuleTransaction] RT WITH (NOLOCK)      
     JOIN cteChildRule CTE ON RT.RuleReferanceID=CTE.RuleReferanceID AND RT.RuleID<>CTE.ChildID      
     WHERE RT.RuleReferanceID>0 AND [RuleStatusInd] <> 1          
 )      
      
 SELECT rule_transaction.[RecordID],       
     PR.ParentRuleID,      
     rule_transaction.RuleID,      
     master_rules.[DescWorkPattern],                
     master_rules.[DescWorkSubPattern],            
     master_rules.[ResolutionWorkPattern],                
     master_rules.[ResolutionWorkSubPattern],            
     master_rules.[UseCase],            
     master_rules.[SubGroup],                
     master_rules.[DebtClassification],            
     master_rules.[AvoidableFlag],               
     master_rules.[EliminationFeasibilityPercentage],            
     master_rules.[AutomationPossibility],            
     master_rules.[AutomationImplFeasibilityPercentage],                
     master_rules.[AutomationImplFeasibility],            
     master_rules.[ProposedAutomationTool],              
     master_rules.[LeftShiftPercentage],               
     DATEDIFF(day,rule_transaction.[CreatedDate], GETDATE()) AS RuleAge,              
     rule_transaction.RuleReferanceID,            
     rule_transaction.[AccountName] AS RuleSource,                
     master_rules.[DealScope],            
     master_rules.DebtType,            
     rule_transaction.[RuleLevel],            
     rule_transaction.[RuleStatusInd],              
     CASE WHEN rule_transaction.[RuleStatusInd] = 4 THEN 1               
     ELSE 0              
     END AS IsOveridden,                 
     rule_transaction.[AccountID],                    
     LEFT(CONVERT(VARCHAR,rule_transaction.[ModifiedDate], 120), 10) AS MutedSince                
     FROM [BID].[RuleTransaction] rule_transaction WITH (NOLOCK)        
     INNER JOIN [BID].[RulesMaster] master_rules ON rule_transaction.[RuleID] = master_rules.[RuleID]      
     LEFT JOIN cteParentRule PR ON rule_transaction.RuleID=PR.RuleID      
     WHERE                
     rule_transaction.[AccountID] IS NULL                
     AND rule_transaction.[BUID] = ISNULL(@buid, rule_transaction.BUID)                
     AND rule_transaction.[RuleLevel] = @RuleLevel AND RuleStatusInd is not null and rule_transaction.IsDeleted=0 and master_rules.IsDeleted=0;               
      
      
 END                
 END TRY                  
 BEGIN CATCH                  
 DECLARE @ErrorMessage VARCHAR(MAX);                  
                  
      SELECT @ErrorMessage = ERROR_MESSAGE()                  
                  
      --INSERT Error                      
      EXEC AVL_InsertError  '[LW].[LW_GetTotalRules]',@ErrorMessage, '' ,0                  
                  
 END CATCH                  
                  
END
