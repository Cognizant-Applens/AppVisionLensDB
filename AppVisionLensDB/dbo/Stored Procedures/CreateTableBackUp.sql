CREATE   PROCEDURE [dbo].[CreateTableBackUp]  
    @table varchar(200)
AS
DECLARE @new_table NVARCHAR(MAX) = @table + '_BKP_' + REPLACE(CONVERT(CHAR(11), getdate(), 106),' ','_')                                    

DECLARE @sql NVARCHAR(MAX) = 'select * into ' + @new_table + ' from '+ @table;

Print(@sql);
EXEC(@sql);
