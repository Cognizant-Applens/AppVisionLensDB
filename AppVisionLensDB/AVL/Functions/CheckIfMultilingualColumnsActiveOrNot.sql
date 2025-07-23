CREATE FUNCTION AVL.CheckIfMultilingualColumnsActiveOrNot (@ProjectId BIGINT, @ColumnId INT,@IsActive INT)
RETURNS BIT
AS 
BEGIN
	DECLARE @Result BIT
	IF EXISTS(SELECT top 1 MCP.ColumnID FROM AVL.MAS_MultilingualColumnMaster MCM WITH (NOLOCK) 
	JOIN AVL.PRJ_MultilingualColumnMapping MCP WITH(NOLOCK) ON MCM.ColumnID=MCP.ColumnID
	WHERE MCM.IsActive=1 AND MCP.IsActive = @IsActive AND MCP.ColumnID =@ColumnId AND MCP.ProjectID=@ProjectId)
	BEGIN
		SET @Result = 1
	END
	ELSE
	BEGIN
		SET @Result = 0
	END
	RETURN @Result;
END