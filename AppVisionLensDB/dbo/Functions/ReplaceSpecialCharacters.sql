CREATE FUNCTION [dbo].[ReplaceSpecialCharacters](@string VARCHAR(MAX)) RETURNS VARCHAR(500)
AS
BEGIN
IF @string is NULL
      RETURN NULL
	  ELSE
	    
	  SET @string =REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
	  (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@string,'`',' '),'~',' '),'!',' ')
	  ,'@',' '),'#',' '),'$',' '),'%', ' '),'^', ' '),'&',' '),'*',' '),'(',' '),')',' '),'_',' '),'-',' '),'+',' '),'=',' '),'{',' '),'}',' ')
	  ,'[',' '),']',' '),'\',' '),';',' '),':',' '),'<',' '),'>',' '),'?',' '),'/',' '),',',' '),'.',' '),'"',' '),'''',' '),'|',' ')
RETURN @string
END