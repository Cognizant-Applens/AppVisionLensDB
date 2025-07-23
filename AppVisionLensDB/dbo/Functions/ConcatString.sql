CREATE FUNCTION [dbo].[ConcatString]
(
	@string varchar(50)
)
RETURNS  Varchar(8000)
AS
BEGIN
		DECLARE @concatString Varchar(8000)	
		SELECT @concatString = COALESCE(@concatString + ', ', '') + ST.SolutionTypeName 
		FROM dbo.[StringSplit](@string,',') S join AVL.TK_MAS_SolutionType ST on ST.SolutionTypeID=S.Item
		RETURN @concatString

END