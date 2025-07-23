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
  
CREATE PROCEDURE [LW].[LW_GetRulesCount]  
@flag VARCHAR(20),  
@RuleLevel VARCHAR(20),  
@AccountId BIGINT,  
@BUID SMALLINT  
  
AS  
  
BEGIN  
SET NOCOUNT ON;  
  
BEGIN TRY  
  
IF(@flag= 'Delivery')  
BEGIN  
SELECT COUNT(rule_transaction.[RecordID]) AS DormantRulesCount FROM [LW].[RuleTransaction] rule_transaction  
    WITH (NOLOCK)  
    INNER JOIN [LW].[RuleUsage] rule_usage  
       ON rule_transaction.[RecordID] = rule_usage.[TransRecordID]  
       WHERE rule_transaction.[AccountID] = @AccountId   
    AND rule_transaction.[BUID] = @BUID   
       AND rule_transaction.[RuleLevel] = @RuleLevel AND rule_usage.[IsDormant] = 1 ;  
  
SELECT [RecordID],[RuleStatusInd],[IsOveridden] FROM [LW].[RuleTransaction]  
    WITH (NOLOCK) WHERE [AccountID] = @AccountId AND  
    [BUID] = @BUID AND [RuleLevel] = @RuleLevel AND RuleStatusInd  IS NOT NULL;  
END  
ELSE IF(@flag = 'Commercial')  
BEGIN  
SELECT COUNT(rule_transaction.[RecordID]) AS DormantRulesCount FROM [BID].[RuleTransaction] rule_transaction  
       WHERE    
    rule_transaction.[BUID] = @BUID AND rule_transaction.[AccountID]  IS NULL  
       AND rule_transaction.[RuleLevel] = @RuleLevel AND [IsDormant] = 1 and rule_transaction.IsDeleted = 0;  
  
SELECT [RecordID],[RuleStatusInd],  
       CASE WHEN [RuleStatusInd] = 4 THEN 1   
       ELSE 0  
       END AS IsOveridden FROM [BID].[RuleTransaction]  
       WHERE  [AccountID] IS NULL AND  
       [BUID] = @BUID AND [RuleLevel] = @RuleLevel AND RuleStatusInd is not null and [IsDeleted]=0;  
END  
END TRY  
BEGIN CATCH  
DECLARE @ErrorMessage VARCHAR(MAX);  
  
              SELECT @ErrorMessage = ERROR_MESSAGE()  
              --INSERT Error      
              EXEC AVL_InsertError '[LW].[LW_GetRulesCount]'  
       ,@ErrorMessage  
       ,''  
       ,0  
END CATCH  
END
