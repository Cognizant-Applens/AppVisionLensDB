-- ============================================================================ 
-- Author:           441778 
-- Create date:      26/12/2019
-- Description:      SP for Get Values For RuleExtraction
-- Test:             EXEC [ML].[GetValuesForRuleExtraction] 10337
-- ============================================================================
CREATE PROCEDURE [ML].[GetValuesForRuleExtraction] --10337
  @ProjectID BIGINT
AS 
 BEGIN 
 SET NOCOUNT ON

DECLARE @FromDate DATE 
 DECLARE @ToDate DATE


	SET @FromDate = (SELECT MIN(FromDate)FROM ML.ConfigurationProgress(NOLOCK) WHERE ProjectID = @ProjectID AND IsMLSentOrReceived = 'Received') 
	SET @ToDate = (SELECT MAX(ToDate)FROM ML.ConfigurationProgress(NOLOCK) WHERE ProjectID = @ProjectID AND IsMLSentOrReceived = 'Received') 

	SELECT DISTINCT IsOptionalField,
	DebtAttributeId AS DebtAttribute,
	@FromDate AS FromDate,
	@ToDate AS ToDate
	FROM ML.ConfigurationProgress(NOLOCK) WHERE ProjectID = @ProjectID and IsMLSentOrReceived = 'Received' 
 SET NOCOUNT OFF
  END
