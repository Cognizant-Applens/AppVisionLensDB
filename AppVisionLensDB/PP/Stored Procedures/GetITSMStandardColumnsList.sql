/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : 
-- Create date : 23/07/20200
-- Description : Get Saved Column Mapping Data
-- Revision    :
-- Revised By  :
-- ========================================================================================= 
CREATE PROCEDURE [PP].[GetITSMStandardColumnsList]  
  @SupportTypeID INT null   
AS
 BEGIN
 BEGIN TRY
 SET NOCOUNT ON
   
 
  SELECT  ITSM_MAS_CN.ColumnID as ColumnMappingId,REPLACE(REPLACE(ITSM_MAS_CN.ColumnName,'\',' or '),'/',' or ') as ColumnMappingName, ITSM_MAS_CN.IsMandatory, ITSM_MAS_CN.IsDeleted ,REPLACE(REPLACE(ITSM_MAS_CN.ColumnName,'\',' or '),'/',' or ') as ITSM_Source_ColumnID  
   FROM  MAS.ITSM_Columnname ITSM_MAS_CN  where SupportTypeID=@SupportTypeID and ITSM_MAS_CN.IsDeleted=0 --order by IsMandatory desc,ColumnName  

 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[GetITSMStandardColumnsList]', @ErrorMessage, 0 ,0
  END CATCH

END
