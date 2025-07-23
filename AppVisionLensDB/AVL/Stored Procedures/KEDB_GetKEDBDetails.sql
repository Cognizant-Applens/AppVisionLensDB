CREATE PROCEDURE [AVL].[KEDB_GetKEDBDetails]
@ProjectID VARCHAR(50)
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
SELECT (select distinct ThresholdCount from [AVL].[DEBT_MAS_HealProjectThresholdMaster] where ProjectId = @ProjectID AND IsDeleted=0) as ThresholdCount,
(Select distinct PA.attributevaluename from mas.ppattributevalues PA
inner join [PP].[BestPractices] BPS
on PA.AttributeValueID =BPS.KEDBOwnedId and BPS.projectid = @ProjectID AND BPS.IsDeleted=0) as AttributeName
END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
SELECT @ErrorMessage = ERROR_MESSAGE()
--INSERT Error
EXEC AVL_InsertError 'AVL.KEDB_GetKEDBDetails', @ErrorMessage, @ProjectID,0

END CATCH
END
