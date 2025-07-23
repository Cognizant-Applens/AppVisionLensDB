/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
    
CREATE PROCEDURE [LW].[LW_GetOverriddenRules]       
@flag VARCHAR(50),      
@RuleLevel VARCHAR(50),      
@AccountId BIGINT,      
@BUID BIGINT      
      
AS      
      
BEGIN      
      
SET NOCOUNT ON;      
      
BEGIN TRY      
IF(@flag = 'Delivery')      
BEGIN      
SELECT  rule_transaction.[RecordID],  
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
		master_rules.[ResidualDebt],      
        rule_transaction.[NewRuleReferanceID]      
        FROM [LW].[RuleTransaction] rule_transaction WITH (NOLOCK) INNER JOIN       
        [MAS].[ML_RulesMaster] master_rules      
        ON rule_transaction.[RuleID] = master_rules.[RuleID] WHERE       
        rule_transaction.[AccountID] = @AccountId      
        AND rule_transaction.[BUID] = @BUID AND       
        rule_transaction.[RuleLevel] = @RuleLevel AND rule_transaction.[IsOveridden] = 1;      
      
SELECT  rule_transaction.[RecordID],  
		master_rules.[DescWorkPattern],      
        master_rules.[DescWorkSubPattern],  
		master_rules.[ResolutionWorkPattern],      
        master_rules.[ResolutionWorkSubPattern],  
		master_rules.[CauseCode],  
		master_rules.[ResolutionCode],      
        master_rules.[DebtClassification],  
		master_rules.[AvoidableFlag],      
        DATEDIFF(day,rule_transaction.[CreatedDate] , GETDATE()) AS RuleAge,      
        rule_transaction.[AccountName] AS RuleSource,master_rules.[ResidualDebt],      
        rule_transaction.[NewRuleReferanceID]      
        FROM [LW].[RuleTransaction] rule_transaction  WITH (NOLOCK) INNER JOIN       
        [MAS].[ML_RulesMaster] master_rules      
        ON rule_transaction.[RuleID] = master_rules.[RuleID] WHERE       
        rule_transaction.[AccountID] = @AccountId      
        AND rule_transaction.[BUID] = @BUID AND       
        rule_transaction.[RuleLevel] = @RuleLevel AND rule_transaction.[RuleStatusInd] = 1;      
END      
ELSE if (@flag ='Commercial')    
BEGIN      
SELECT rule_transaction.[RecordID],  
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
       rule_transaction.RuleReferanceID AS NewRuleReferanceID,rule_transaction.[AccountName] AS RuleSource,    
       master_rules.DebtType,    
       master_rules.DealScope    
	   FROM [BID].[RuleTransaction] rule_transaction WITH (NOLOCK)  INNER JOIN           
       [BID].[RulesMaster] master_rules          
       ON rule_transaction.[RuleID] = master_rules.[RuleID] WHERE          
       rule_transaction.[AccountID] IS NULL          
       AND rule_transaction.[BUID] = @BUID          
       AND rule_transaction.[RuleLevel] = @RuleLevel AND RuleStatusInd = 4 and rule_transaction.IsDeleted=0 and master_rules.IsDeleted=0;        
      
SELECT rule_transaction.[RecordID],  
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
    rule_transaction.RuleReferanceID AS NewRuleReferanceID,rule_transaction.[AccountName] AS RuleSource,    
    master_rules.DebtType,    
    master_rules.DealScope    
    FROM [BID].[RuleTransaction] rule_transaction WITH (NOLOCK)  INNER JOIN           
    [BID].[RulesMaster] master_rules          
    ON rule_transaction.[RuleID] = master_rules.[RuleID] WHERE          
    rule_transaction.[AccountID] IS NULL          
    AND rule_transaction.[BUID] = @BUID          
    AND rule_transaction.[RuleLevel] = @RuleLevel AND RuleStatusInd = 1 and rule_transaction.IsDeleted=0 and master_rules.IsDeleted=0;      
END      
END TRY      
BEGIN CATCH      
DECLARE @ErrorMessage VARCHAR(MAX);      
      
              SELECT @ErrorMessage = ERROR_MESSAGE()      
      
              --INSERT Error          
              EXEC AVL_InsertError  '[LW].[LW_GetOverriddenRules]'      
       ,@ErrorMessage      
       ,''      
       ,0      
END CATCH      
END