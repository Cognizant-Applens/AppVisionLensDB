CREATE FUNCTION [AVL].[PPArcheType] (@ProjectId BIGINT)
RETURNS NVARCHAR(MAX) AS
BEGIN

   
DECLARE @PPArcheType NVARCHAR(MAX);
SELECT @PPArcheType = COALESCE(@PPArcheType  +  ',' + LTRIM(RTRIM([AttributeValueName])),LTRIM(RTRIM([AttributeValueName]))) 
from pp.scopeofwork(NOLOCK) A
join mas.PPAttributevalues(NOLOCK) B on A.ProjectTypeID = B.AttributeValueID AND A.IsDeleted = 0 and B.IsDeleted = 0
Where A.ProjectId = @ProjectId  and B.AttributeID = 4;

Declare @data nvarchar(max) = @PPArcheType
Declare @finalstring nvarchar(max) = ''
select @finalstring = @finalstring + value + ',' from string_split(@data,',')
GROUP BY value


RETURN @finalstring




END