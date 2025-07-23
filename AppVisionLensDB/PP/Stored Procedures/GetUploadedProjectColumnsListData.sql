/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetUploadedProjectColumnsListData]
 (	         
	@ProjectID INT  
)
AS
 BEGIN
 BEGIN TRY
 SET NOCOUNT ON
   
 
  SELECT CONVERT(varchar(100), ID) as   ALM_Source_ColumnID, ProjectID, ColumnName,  IsDeleted  
    FROM  PP.ALM_SourceColumn where ProjectId=@ProjectID and IsDeleted=0
  
 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[GetUploadedProjectColumnsListData]', @ErrorMessage, 0 ,0
  END CATCH

END
