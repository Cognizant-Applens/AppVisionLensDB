CREATE FUNCTION [AVL].[NoiseElimination] (@NoiceEliminationWord varchar(max))
RETURNS varchar(max) AS
BEGIN
    
 declare @SplitWords table
 (Item varchar(1000)
 )
 insert into @SplitWords(Item)
 select Item from [dbo].[SplitString] (@NoiceEliminationWord,'') 
 delete from @SplitWords
 where Item in (select NoiseWord from AVL.NoiseWords)


 Declare @returnString varchar(1000)
SELECT @returnString = COALESCE(@returnString + ' ', '') + Item 
FROM @SplitWords


    RETURN @returnString
END