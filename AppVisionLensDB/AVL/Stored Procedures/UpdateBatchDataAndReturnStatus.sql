Create PROCEDURE [AVL].[UpdateBatchDataAndReturnStatus]  --'AppVisionLens','BID.RuleTransaction','ModifiedDate','RecordID',5,0
    @DatabaseName NVARCHAR(128),
    @TableName NVARCHAR(128),
    @UTCColumnName NVARCHAR(128),
    @IdentityColumnName NVARCHAR(128),
    @BatchSize INT,
    @LastId INT
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @LastUpdatedId INT;
    DECLARE @OutputTable TABLE (Id INT);
    DECLARE @BatchData TABLE (Id INT, LocalTime DATETIME);
    DECLARE @ErrorMessage VARCHAR(MAX);
    DECLARE @DataType NVARCHAR(20);
 
    BEGIN TRANSACTION;
 
    BEGIN TRY
        IF @IdentityColumnName = 'NA'
        BEGIN
            -- Update the whole table without batch processing
            IF @DatabaseName = 'AppVisionLens'
            BEGIN
                SET @SQL = 'UPDATE ' + @TableName + ' 
                            SET ' + QUOTENAME(@UTCColumnName) + ' = DATEADD(minute, -330, ' + QUOTENAME(@UTCColumnName) + ')
                            WHERE ' + QUOTENAME(@UTCColumnName) + ' IS NOT NULL AND ' + QUOTENAME(@UTCColumnName) + ' <> ''''';
            END
            ELSE
            BEGIN
                SET @SQL = 'USE ' + QUOTENAME(@DatabaseName) + ' UPDATE ' + @TableName + ' 
                            SET ' + QUOTENAME(@UTCColumnName) + ' = DATEADD(minute, -330, ' + QUOTENAME(@UTCColumnName) + ')
                            WHERE ' + QUOTENAME(@UTCColumnName) + ' IS NOT NULL AND ' + QUOTENAME(@UTCColumnName) + ' <> ''''';
            END
            EXEC sp_executesql @SQL;
            COMMIT TRANSACTION;
            SELECT 'Success' AS Status, NULL AS LastUpdatedId,0 AS Result;;
            RETURN;
        END
        ELSE
        BEGIN
            -- Fetch batch data
            IF @DatabaseName = 'AppVisionLens'
            BEGIN
                SET @SQL = 'SELECT TOP ' + CAST(@BatchSize AS NVARCHAR(10)) + ' ' + QUOTENAME(@IdentityColumnName) + ', ' + QUOTENAME(@UTCColumnName) + ' 
                            FROM ' + @TableName + ' NOLOCK
                            WHERE (' + QUOTENAME(@IdentityColumnName) + ' > ' + CAST(@LastId AS NVARCHAR(MAX)) + ') 
                            AND (' + QUOTENAME(@UTCColumnName) + ' IS NOT NULL AND ' + QUOTENAME(@UTCColumnName) + ' <> '''') 
                            ORDER BY ' + QUOTENAME(@IdentityColumnName);
            END
            ELSE
            BEGIN
                SET @SQL = 'USE ' + QUOTENAME(@DatabaseName) + ' SELECT TOP ' + CAST(@BatchSize AS NVARCHAR(10)) + ' ' + QUOTENAME(@IdentityColumnName) + ', ' + QUOTENAME(@UTCColumnName) + ' 
                            FROM ' + @TableName + ' NOLOCK
                            WHERE (' + QUOTENAME(@IdentityColumnName) + ' > ' + CAST(@LastId AS NVARCHAR(MAX)) + ') 
                            AND (' + QUOTENAME(@UTCColumnName) + ' IS NOT NULL AND ' + QUOTENAME(@UTCColumnName) + ' <> '''') 
                            ORDER BY ' + QUOTENAME(@IdentityColumnName);
            END
 
            INSERT INTO @BatchData
            EXEC sp_executesql @SQL;
 
            SELECT @LastUpdatedId = MAX(Id) FROM @BatchData;
 
            IF (SELECT COUNT(*) FROM @BatchData) = 0
            BEGIN
                COMMIT TRANSACTION;
                SELECT 'No more data' AS Status, NULL AS LastUpdatedId,0 AS Result;
                RETURN;
            END
 
            -- Update Date column
            IF @DatabaseName = 'AppVisionLens'
            BEGIN
                SET @SQL = 'UPDATE ' + @TableName + ' 
                            SET ' + QUOTENAME(@UTCColumnName) + ' = DATEADD(minute, -330, ' + QUOTENAME(@UTCColumnName) + ')
                            WHERE (' + QUOTENAME(@IdentityColumnName) + ' BETWEEN ' + CAST(@LastId AS NVARCHAR(MAX)) + ' AND ' + CAST(@LastUpdatedId AS NVARCHAR(MAX)) + ')'
                            ----AND ' + QUOTENAME(@UTCColumnName) + ' IS NOT NULL AND ' + QUOTENAME(@UTCColumnName) + ' <> ''''';
            END
            ELSE
            BEGIN
                SET @SQL = 'USE ' + QUOTENAME(@DatabaseName) + ' UPDATE ' + @TableName + ' 
                            SET ' + QUOTENAME(@UTCColumnName) + ' = DATEADD(minute, -330, ' + QUOTENAME(@UTCColumnName) + ')
                            WHERE (' + QUOTENAME(@IdentityColumnName) + ' BETWEEN ' + CAST(@LastId AS NVARCHAR(MAX)) + ' AND ' + CAST(@LastUpdatedId AS NVARCHAR(MAX)) + ')'
                            --AND ' + QUOTENAME(@UTCColumnName) + ' IS NOT NULL AND ' + QUOTENAME(@UTCColumnName) + ' <> ''''';
            END
            EXEC sp_executesql @SQL;
 
            COMMIT TRANSACTION;
            SELECT 'Success' AS Status, @LastUpdatedId AS LastUpdatedId,0 AS Result;
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT @ErrorMessage = ERROR_MESSAGE();
        EXEC AVL_InsertError '[AVL].[UpdateBatchDataAndReturnStatus] ', @ErrorMessage, 'UTC';
    END CATCH
END;