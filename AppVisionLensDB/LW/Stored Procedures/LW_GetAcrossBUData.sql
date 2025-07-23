/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [LW].[LW_GetAcrossBUData]
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

SELECT [BUName],SUM([TotalRulesCount]) AS TotalRules,
        SUM(OverriddenRulesCount) AS OverriddenRules
		FROM [LW].[RuleStatistics] WITH (NOLOCK) WHERE DeliveryBidFlag = @Flag
		 AND DeliveryOnpremiseInd = 'd' AND ISACTIVE = 1 GROUP BY [BUName];

SELECT [BUName],SUM(AutoclassifiedTicketCount) AS AutoClassifiedTicket,
        SUM(ManualclassifiedTicketCount) AS ManualClassifiedTicket
		FROM [LW].[RuleStatistics] WITH (NOLOCK)
		WHERE DeliveryBidFlag = @Flag AND [IsActive] = 1 AND DeliveryOnpremiseInd = 'd' GROUP BY [BUName];

SELECT TOP(5) rule_usage.[TimesApplied],rule_transaction.[RecordID],master_rules.[DescWorkPattern],
	   master_rules.[DescWorkSubPattern],master_rules.[ResolutionWorkPattern],
       master_rules.[ResolutionWorkSubPattern],master_rules.[CauseCode],master_rules.[ResolutionCode],
	   master_rules.[DebtClassification],master_rules.[AvoidableFlag],
	   DATEDIFF(day,rule_transaction.[CreatedDate], GETDATE()) AS RuleAge,
	   rule_transaction.[AccountName] AS RuleSource,rule_transaction.[AccountID],
	   rule_transaction.[BUName],rule_transaction.[RuleLevel],
	   rule_transaction.[RuleStatusInd],master_rules.[ResidualDebt]
       FROM [LW].[RuleTransaction] rule_transaction WITH (NOLOCK) INNER JOIN 
	   [MAS].[ML_RulesMaster] master_rules
	   ON rule_transaction.[RuleID] = master_rules.[RuleID]
	   INNER JOIN [LW].[RuleUsage] rule_usage
       ON rule_transaction.[RecordID] = rule_usage.[TransRecordID]
       WHERE CONVERT(date,rule_transaction.[CreatedDate]) BETWEEN @start_date AND @end_date
	   AND rule_transaction.[RuleStatusInd] = 1 AND rule_transaction.[IsOveridden] = 0 AND 
	    rule_usage.[TimesApplied] > 0 ORDER BY rule_usage.[TimesApplied] DESC ;

SELECT rule_usage.[TimesApplied],rule_transaction.[RecordID],master_rules.[DescWorkPattern],
	   master_rules.[DescWorkSubPattern],master_rules.[ResolutionWorkPattern],
       master_rules.[ResolutionWorkSubPattern],master_rules.[CauseCode],master_rules.[ResolutionCode],
	   master_rules.[DebtClassification],master_rules.[AvoidableFlag],
	   DATEDIFF(day,rule_transaction.[CreatedDate], GETDATE()) AS RuleAge,
	   rule_transaction.[AccountName] AS RuleSource,rule_transaction.[AccountID],
	   rule_transaction.[BUName],rule_transaction.[RuleLevel],
	   rule_transaction.[RuleStatusInd],master_rules.[ResidualDebt]
       FROM [LW].[RuleTransaction] rule_transaction  WITH (NOLOCK) INNER JOIN 
	   [MAS].[ML_RulesMaster] master_rules
	   ON rule_transaction.[RuleID] = master_rules.[RuleID]
	   INNER JOIN [LW].[RuleUsage] rule_usage
       ON rule_transaction.[RecordID] = rule_usage.[TransRecordID]
	   --group by rule_transaction.[BUName], rule_usage.TIMES_APPLIED
	    WHERE CONVERT(date,rule_transaction.[CreatedDate]) BETWEEN @start_date AND @end_date
		AND rule_transaction.[RuleStatusInd] = 1 AND rule_transaction.[IsOveridden] = 0 AND
		rule_usage.[TimesApplied] > 0
       ORDER BY rule_transaction.[BUName],rule_usage.[TimesApplied] DESC;

END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

              SELECT @ErrorMessage = ERROR_MESSAGE()

              --INSERT Error    
              EXEC AVL_InsertError  '[LW].[LW_GetAcrossBUData]'
							,@ErrorMessage
							,''
							,0
END CATCH
END