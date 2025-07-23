/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[SaveColumnMappingsList]
(	         
	@ProjectID Bigint  Null,    
	@CreatedBy VARCHAR(100) null,
	@ColumnMappingsList [PP].[TVP_ALM_SourceAndDestinationColumnMappingDataList] READONLY
)
AS
 BEGIN
 BEGIN TRY
 SET NOCOUNT ON
 declare @RowCount int  

 set @RowCount= (Select count(ProjectId) as Row_Count from [PP].[ALM_MAP_ColumnName] where ProjectID=@ProjectID and IsDeleted=0)

 IF(@RowCount = 0)
   Begin 
    INSERT INTO [PP].[ALM_MAP_ColumnName](ALMColID,ProjectColumn,ProjectId,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
      SELECT SourceColumnId,LTRIM(RTRIM(MappedColumnName)) AS MappedColumnName,ProjectID,IsDeleted,CreatedBy,CreatedDate,CreatedBy,CreatedDate FROM @ColumnMappingsList
	  WHERE MappedColumnName IS NOT NULL AND MappedColumnName <> ''
   end
   else
   Begin 
   Update [PP].[ALM_MAP_ColumnName] set IsDeleted=1 where ProjectID=@ProjectID and IsDeleted=0
    
	INSERT INTO [PP].[ALM_MAP_ColumnName](ALMColID,ProjectColumn,ProjectId,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
    SELECT SourceColumnId,LTRIM(RTRIM(MappedColumnName)) AS MappedColumnName,ProjectID,IsDeleted,CreatedBy,CreatedDate,CreatedBy,CreatedDate FROM @ColumnMappingsList
	 WHERE MappedColumnName IS NOT NULL AND MappedColumnName <> ''
   End 
   EXEC [PP].[SaveAdapterTileProgressPercentage] @ProjectID,@CreatedBy
 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[SaveColumnMappingsList]', @ErrorMessage, 0 ,@CreatedBy
  END CATCH

END
