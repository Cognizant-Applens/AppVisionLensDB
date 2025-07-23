/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [LW].[LW_GetEnrichmentTrendData]

@Flag VARCHAR(20),
@AccountId BIGINT ,
@BUID SMALLINT

AS


SET NOCOUNT ON;
BEGIN TRY
IF(@AccountId = 0)
BEGIN
	SELECT @AccountId = NULL
END
IF(@BUID = 0)
BEGIN
	SELECT @BUID = NULL
END
IF (@BUID IS NULL)    

BEGIN  
 SELECT SUM([ApprovedRulesCount]) AS ApprovedRules,
		SUM([PendingRulesCount]) AS UnapprovedRules,
		SUM([MutedRulesCount]) AS MutedRules,
		SUM([OverriddenRulesCount]) AS OverriddenRules,
		SUM([DormantRulesCount]) AS DormantRules,
		SUM([AutoclassifiedTicketCount]) AS AutoClassifiedTickets,
        SUM([ManualclassifiedTicketCount]) AS ManualClassifiedTickets,
        SUM([OverriddenTicketCount]) AS OverridenTickets,
		SUM([UnclassifiedTicketCount]) AS UnClassifiedTickets,
		SUM([DdclassifiedTicketCount]) AS DDClassifiedTickets
		FROM [LW].[RuleStatistics]  WITH (NOLOCK)
		WHERE [DeliveryBidFlag] = @Flag AND [BUID] = ISNULL(@BUID, [BUID]) 
		AND [AccountID] = ISNULL(@AccountId, [AccountID])
		AND [ISACTIVE] = 1  AND [DeliveryOnpremiseInd] != 'b';  

 SELECT  FORMAT(cast(SUBSTRING([MonthYear],5,4) + '-' + SUBSTRING([MonthYear],1,3)
		 + '-01' AS datetime),'yyyy-MM') AS MonthName,
		 [MonthYear] AS GraphMonth,	
		SUM([ApprovedRulesCount]) AS ApprovedRules,
		SUM([PendingRulesCount]) AS UnapprovedRules,
		SUM([MutedRulesCount]) AS MutedRules,
		SUM([OverriddenRulesCount]) AS OverriddenRules,
		SUM([DormantRulesCount]) AS DormantRules,
		SUM([AutoclassifiedTicketCount]) AS AutoClassifiedTickets,
        SUM([ManualclassifiedTicketCount]) AS ManualClassifiedTickets,
        SUM([OverriddenTicketCount]) AS OverridenTickets,
		SUM([UnclassifiedTicketCount]) AS UnClassifiedTickets,
		SUM([DdclassifiedTicketCount]) AS DDClassifiedTickets
		FROM [LW].[RuleStatistics]  WITH (NOLOCK)
		WHERE [DeliveryBidFlag] = @Flag AND [BUID] = ISNULL(@BUID, [BUID]) 
		AND [AccountID] = ISNULL(@AccountId, [AccountID])
		AND [ISACTIVE] = 1  AND [DeliveryOnpremiseInd] != 'b'
		GROUP BY FORMAT(cast(SUBSTRING([MonthYear],5,4) +
	    '-' + SUBSTRING([MonthYear],1,3) + '-01' AS datetime),'yyyy-MM'),[MonthYear] ORDER BY MonthName;
END

ELSE 

BEGIN
SELECT SUM([ApprovedRulesCount]) AS ApprovedRules,
		SUM([PendingRulesCount]) AS UnapprovedRules,
		SUM([MutedRulesCount]) AS MutedRules,
		SUM([OverriddenRulesCount]) AS OverriddenRules,
		SUM([DormantRulesCount]) AS DormantRules,
		SUM([AutoclassifiedTicketCount]) AS AutoClassifiedTickets,
        SUM([ManualclassifiedTicketCount]) AS ManualClassifiedTickets,
        SUM([OverriddenTicketCount]) AS OverridenTickets,
		SUM([UnclassifiedTicketCount]) AS UnClassifiedTickets,
		SUM([DdclassifiedTicketCount]) AS DDClassifiedTickets
		FROM [LW].[RuleStatistics]  WITH (NOLOCK)
		WHERE [DeliveryBidFlag] = @Flag AND [BUID] = ISNULL(@BUID, [BUID]) 
		AND [AccountID] = ISNULL(@AccountId, [AccountID])
		AND [ISACTIVE] = 1 AND [DeliveryOnpremiseInd] IN ('d','b');  

 SELECT FORMAT(cast(SUBSTRING([MonthYear],5,4) + '-' + SUBSTRING([MonthYear],1,3)
		 + '-01' AS datetime),'yyyy-MM') AS MonthName,
		 [MonthYear] AS GraphMonth,	
		SUM([ApprovedRulesCount]) AS ApprovedRules,
		SUM([PendingRulesCount]) AS UnapprovedRules,
		SUM([MutedRulesCount]) AS MutedRules,
		SUM([OverriddenRulesCount]) AS OverriddenRules,
		SUM([DormantRulesCount]) AS DormantRules,
		SUM([AutoclassifiedTicketCount]) AS AutoClassifiedTickets,
        SUM([ManualclassifiedTicketCount]) AS ManualClassifiedTickets,
        SUM([OverriddenTicketCount]) AS OverridenTickets,
		SUM([UnclassifiedTicketCount]) AS UnClassifiedTickets,
		SUM([DdclassifiedTicketCount]) AS DDClassifiedTickets
		FROM [LW].[RuleStatistics]  WITH (NOLOCK)
		WHERE [DeliveryBidFlag] = @Flag AND [BUID] = ISNULL(@BUID, [BUID]) 
		AND [AccountID] = ISNULL(@AccountId, [AccountID])
		AND [ISACTIVE] = 1 AND [DeliveryOnpremiseInd] IN ('d','b')
		GROUP BY FORMAT(cast(SUBSTRING([MonthYear],5,4) +
	    '-' + SUBSTRING([MonthYear],1,3) + '-01' AS datetime),'yyyy-MM'),[MonthYear] ORDER BY MonthName;
END

END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

              SELECT @ErrorMessage = ERROR_MESSAGE()

              --INSERT Error    
               EXEC AVL_InsertError  '[LW].[LW_GetEnrichmentTrendData]'
							,@ErrorMessage
							,''
							,0
END CATCH