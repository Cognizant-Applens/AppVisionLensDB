CREATE FUNCTION [AVL].[GetBlendedRateByProjectSupportTypeId](@ProjectId BIGINT, @SupportTypeId INT)
RETURNS NUMERIC(10,2)
AS 
BEGIN	
	RETURN (SELECT TOP 1 BlendedRate FROM [AVL].[Debt_BlendedRateCardDetails](NOLOCK)
	WHERE IsDeleted=0 AND ProjectId = @ProjectId AND IsAppOrInfra=@SupportTypeId
	ORDER BY BlendedRateId DESC);
END