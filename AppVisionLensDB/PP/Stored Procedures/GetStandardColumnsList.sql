/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE  PROCEDURE [PP].[GetStandardColumnsList]  
 
AS
 BEGIN
 BEGIN TRY
 SET NOCOUNT ON
   
 
  SELECT  ALM_MAS_CN.ALMColID as ColumnMappingId,REPLACE(REPLACE(ALM_MAS_CN.ALMColumnName,'\',' or '),'/',' or ') as ColumnMappingName, ALM_MAS_CN.IsMandatory, ALM_MAS_CN.IsDeleted ,'0' alM_Source_ColumnID  
   FROM  [PP].[ALM_MAS_ColumnName] ALM_MAS_CN  where ALM_MAS_CN.IsDeleted=0 

      
 ORDER BY  CASE IsMandatory
WHEN 1 THEN IsMandatory End DESC,
Case WHEN IsMandatory=0 THEN ALM_MAS_CN.ALMColumnName 
END

 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[GetStandardColumnsList]', @ErrorMessage, 0 ,0
  END CATCH

END
