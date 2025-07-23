/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		<Anitha>
-- Create date: <Feb-11-2019>
-- Description:	Get the master values available for dd template
-- =============================================
CREATE PROCEDURE [AVL].[GetDDExcelColumnNames]
	
AS
BEGIN
 	SET NOCOUNT ON  

 BEGIN TRY 

	SELECT [ColumnName] AS [Column name]  FROM AVL.DD_MAS_GetExcelColumnNames WHERE IsDeleted=0

	END TRY
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError ' [AVL].[GetDDExcelColumnNames]', @ErrorMessage, '',0
END CATCH 

END
