
--select [AVL].[ProjectScope](100148)

CREATE FUNCTION [AVL].[ProjectScope] (@ProjectId BIGINT)
RETURNS NVARCHAR(MAX) AS
BEGIN

   
DECLARE @ProjectScope NVARCHAR(MAX);
SELECT @ProjectScope = COALESCE(@ProjectScope  +  ',' + LTRIM(RTRIM([AttributeValueName])),LTRIM(RTRIM([AttributeValueName]))) 
FROM PP.ProjectAttributevalues PAV
JOIN MAS.PPAttributeValues PA
ON PAV.AttributeValueID = PA.AttributeValueID AND PAV.IsDeleted = 0 AND PA.IsDeleted = 0
WHERE  ProjectId = @ProjectId AND PAV.AttributeId = 1  and PA.Attributeid = 1
Declare @data nvarchar(max) = @ProjectScope
Declare @finalstring nvarchar(max) = ''
select @finalstring = @finalstring + value + ',' from string_split(@data,',')
GROUP BY value


RETURN @finalstring




END



