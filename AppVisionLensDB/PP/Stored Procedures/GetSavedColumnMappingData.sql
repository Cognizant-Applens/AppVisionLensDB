/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetSavedColumnMappingData]  
 (	         
	@ProjectID INT  
)
AS
 BEGIN
 BEGIN TRY
 SET NOCOUNT ON
   
 
  --SELECT ColumnMapId as MappedColumnSerialId,ALMColID as StandardColumnId,ProjectColumn as UploadedFileColumnName,
  --ProjectId,IsDeleted       
  --  FROM  [PP].[ALM_MAP_ColumnName]	 where ProjectId=@ProjectID and IsDeleted=0

	select ALS.ID as MappedColumnSerialId,ALMColID as StandardColumnId,AC.ProjectColumn as UploadedFileColumnName, AC.ProjectId,AC.IsDeleted 
	from [PP].[ALM_MAP_ColumnName] AC inner join pp.ALM_SourceColumn AS ALS on
	AC.ProjectColumn=als.ColumnName where ALS.ProjectId=@ProjectID and  AC.IsDeleted=0 and AC.ProjectId=@ProjectID and  ALS.IsDeleted=0 

  
 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[GetSavedColumnMappingData]', @ErrorMessage, 0 ,0
  END CATCH

END
