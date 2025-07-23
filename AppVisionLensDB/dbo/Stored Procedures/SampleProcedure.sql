
CREATE PROCEDURE SampleProcedure
AS
BEGIN
    BEGIN TRY
        -- Simulate an error (e.g., divide by zero)
        DECLARE @x INT = 1, @y INT = 0, @z INT;
        SET @z = @x / @y;
    END TRY
    BEGIN CATCH
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
    END CATCH
END
