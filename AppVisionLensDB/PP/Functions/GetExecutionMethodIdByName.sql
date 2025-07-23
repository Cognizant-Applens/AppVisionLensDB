CREATE FUNCTION [PP].[GetExecutionMethodIdByName](@ExecutionName NVARCHAR(100))
RETURNS INT
BEGIN
RETURN(SELECT TOP 1 AttributeValueID FROM MAS.PPAttributeValues PAV WITH(NOLOCK) INNER JOIN 
					MAS.PPAttributes PA WITH(NOLOCK) ON PAV.AttributeID = PA.AttributeID
					WHERE PA.AttributeName = 'ExecutionMethod' 
					AND PAV.AttributeValueName LIKE '%'+@ExecutionName+'%'
					AND PAV.IsDeleted = 0 AND PA.IsDeleted = 0)
END