CREATE FUNCTION [AVL].[CheckFlexFieldsIsMap](@ProjectId BIGINT, @ColumnId INT)
RETURNS BIT
AS 
BEGIN
	DECLARE @Result BIT
	IF EXISTS (SELECT TOP 1 HPPM.ColumnID FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping HPPM WITH (NOLOCK)
		WHERE HPPM.ProjectID = @ProjectId AND HPPM.ColumnID = @ColumnId AND HPPM.IsActive = 1)
	BEGIN
		SET @Result = 1
	END
	ELSE
	BEGIN
		SET @Result = 0
	END
	RETURN @Result;
END