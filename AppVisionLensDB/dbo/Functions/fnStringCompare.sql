
CREATE FUNCTION [dbo].[fnStringCompare] 
( 
    @string1 VARCHAR(MAX), 
	@string2 VARCHAR(MAX)
  
) 
RETURNS BIT AS
BEGIN 
DECLARE @output BIT
SET @output=(SELECT 
CASE
when UPPER(TRIM(@string1))=UPPER(TRIM(@string2)) then 1 else 0 end)
       RETURN  @Output 
    END 
    

