/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ================================================
-- Common Stored Procure to get the Error Logs
-- EXEC [dbo].[GetErrorLogs] 'AppVisionLens', 'Application Error', 'CreatedDate', '2020-06-07', '2020-06-08', 1, 10
-- ================================================
CREATE PROCEDURE [dbo].[GetErrorLogs] 
@DatabaseName nvarchar(128),
@FeatureName nvarchar(128),
@DateFilterColumnName nvarchar(128),
@FromDate datetime,
@ToDate datetime,
@PageNo int,
@PageSize int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @PageCountQuery nvarchar(max)
		DECLARE @DataQuery nvarchar(max)
		DECLARE @ColumnQuery nvarchar(max)
		DECLARE @ColumnList nvarchar(max)
		DECLARE @TableName nvarchar(128)

		Select @TableName = TableName from dbo.LogViewerConfig where DatabaseName = @DatabaseName and FeatureName = @FeatureName


		SET @ColumnQuery = 'SELECT @ColumnList = STUFF((select '',''+c.name from '+@DatabaseName+'.sys.columns c (NOLOCK)
			inner join '+@DatabaseName+'.sys.tables t (NOLOCK) on t.object_id = c.object_id 
			inner join '+@DatabaseName+'.sys.schemas s (NOLOCK) on s.schema_id = t.schema_id 
			where s.name + ''.'' +t.name = '''+@TableName+''' and c.name <> '''+ @DateFilterColumnName+'''
			order by c.column_id
			FOR XML PATH(''''))       
            ,1,1,'' '')'

		--select @ColumnQuery
		EXECUTE sp_executesql  @ColumnQuery, N'@ColumnList nvarchar(max) out', @ColumnList out
		--select @ColumnList
		SET @PageCountQuery = 'SELECT PageCount = (count(1)/'+CONVERT(nvarchar, @PageSize)+') + (CASE WHEN CEILING(count(1)%'+CONVERT(nvarchar, @PageSize)+') > 0 THEN 1 ELSE 0 END)
				FROM '+@DatabaseName+'.'+@TableName+ ' (NOLOCK)'+
				' WHERE CONVERT(date,'+@DateFilterColumnName+ ') BETWEEN '''+convert(nvarchar, @FromDate,23)+''' AND ''' + 
				convert(nvarchar, @ToDate,23) + ''''

		SET @DataQuery = 'SELECT '+@ColumnList+', CONVERT(varchar(20),'+@DateFilterColumnName+',101) + '' '' + CONVERT(varchar(20),'+@DateFilterColumnName+',114) '+@DateFilterColumnName+' FROM '+@DatabaseName+'.'+@TableName+ ' (NOLOCK)'+
				' WHERE CONVERT(date,'+@DateFilterColumnName+ ') BETWEEN '''+convert(nvarchar, @FromDate,23)+''' AND ''' + 
				convert(nvarchar, @ToDate,23) + ''' 
				ORDER BY '+@DateFilterColumnName+' DESC
				OFFSET '+ CONVERT(nvarchar, @PageNo - 1 ) +' * '+ CONVERT(nvarchar, @PageSize) +' ROWS
				FETCH NEXT '+ CONVERT(nvarchar, @PageSize) +' ROWS ONLY'

		--select @PageCountQuery
		--select @DataQuery
		EXECUTE sp_executesql @PageCountQuery
		EXECUTE sp_executesql @DataQuery

END TRY
BEGIN CATCH
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_STATE() AS ErrorState,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
END
