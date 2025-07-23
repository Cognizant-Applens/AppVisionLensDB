/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [LW].[LW_GetRulesCountStrategic]

@Flag VARCHAR(20)

AS

BEGIN

SET NOCOUNT ON;

BEGIN TRY

DECLARE @start_date VARCHAR(50);
DECLARE @end_date VARCHAR(50);

SET @start_date = (CONVERT(VARCHAR(10),DATEADD(month, -6, DATEADD(day, 1 - day(GETDATE()), GETDATE())),
               120));
SET @end_date = CONVERT(VARCHAR(10),DATEADD(month, 0, DATEADD(day, 1 - day(GETDATE()), GETDATE())),
               120);

SELECT COUNT(rule_transaction.[RecordID]) AS DormantRulesCount FROM [LW].[RuleTransaction] rule_transaction
	   WITH (NOLOCK) INNER JOIN [LW].[RuleUsage] rule_usage
       ON rule_transaction.[RecordID] = rule_usage.[TransRecordID]
       WHERE rule_transaction.[CreatedDate] BETWEEN @start_date AND @end_date
	   AND rule_usage.[IsDormant] = 1  AND [DeliveryOnpremiseInd] != 'b';

SELECT [RecordID],[RuleStatusInd],[IsOveridden] FROM [LW].[RuleTransaction] WITH (NOLOCK) WHERE
[CreatedDate] BETWEEN @start_date AND @end_date AND [DeliveryOnpremiseInd] != 'b' AND RuleStatusInd  IS NOT NULL;   

END TRY

BEGIN CATCH

DECLARE @ErrorMessage VARCHAR(MAX);

              SELECT @ErrorMessage = ERROR_MESSAGE()

              --INSERT Error    
             
			   EXEC AVL_InsertError  '[LW].[LW_GetRulesCountStrategic]',@ErrorMessage, '' ,0

END CATCH

END