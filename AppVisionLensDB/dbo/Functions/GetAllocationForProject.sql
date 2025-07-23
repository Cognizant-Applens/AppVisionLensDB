
CREATE FUNCTION [dbo].[GetAllocationForProject](@ProjectID int)  
RETURNS float   
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @ret float;  
    select @ret = ROUND(Sum(AllocationPercent)/100, 2) from esa.ProjectAssociates where ProjectId = @ProjectID
     IF (@ret IS NULL)   
        SET @ret = 0;  
    RETURN @ret;  
END; 
