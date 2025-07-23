

CREATE FUNCTION [AVL].[Technology] (@ProjectId BIGINT)
RETURNS NVARCHAR(MAX) AS
BEGIN

   
DECLARE @Technology NVARCHAR(MAX);
SELECT @Technology = COALESCE(@Technology  +  ',' + LTRIM(RTRIM([Technology])),LTRIM(RTRIM([Technology]))) 
FROM [dbo].[OPLMasterdata] PAV
WHERE [ESA_Project_ID] = @ProjectId

Declare @data nvarchar(max) = @Technology
Declare @finalstring nvarchar(max) = ''
select @finalstring = @finalstring + value + ',' from string_split(@data,',')
GROUP BY value


RETURN @finalstring




END



