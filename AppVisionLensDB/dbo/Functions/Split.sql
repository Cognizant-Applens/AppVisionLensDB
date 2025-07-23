CREATE FUNCTION [dbo].[Split]    
/* This function is used to split up multi-value parameters */
    (
      @ItemList VARCHAR(MAX) ,
      @delimiter CHAR(1)
    )
RETURNS @IDTable TABLE
    (
      Item VARCHAR(MAX) COLLATE database_default
    )
AS 
    BEGIN    
        DECLARE @tempItemList VARCHAR(MAX)    
        SET @tempItemList = @ItemList    
    
        DECLARE @i INT    
        DECLARE @Item VARCHAR(MAX)    
    
        SET @tempItemList = REPLACE(@tempItemList, @delimiter + ' ',
                                    @delimiter)    
        SET @i = CHARINDEX(@delimiter, @tempItemList)    
    
        WHILE ( LEN(@tempItemList) > 0 ) 
            BEGIN    
                IF @i = 0 
                    SET @Item = @tempItemList    
                ELSE 
                    SET @Item = LEFT(@tempItemList, @i - 1)    
    
                INSERT  INTO @IDTable
                        ( Item )
                VALUES  ( @Item )    
    
                IF @i = 0 
                    SET @tempItemList = ''    
                ELSE 
                    SET @tempItemList = RIGHT(@tempItemList,
                                              LEN(@tempItemList) - @i)    
    
                SET @i = CHARINDEX(@delimiter, @tempItemList)    
            END    
        RETURN    
    END


