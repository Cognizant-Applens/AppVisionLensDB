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
-- Create date : 29/07/2020
-- Description : Get Saved Column Mapping Data
-- Revision    :
-- Revised By  :
--[PP].[SaveITSMColumnReset]  9829
-- ========================================================================================= 
CREATE PROCEDURE [PP].[SaveITSMColumnReset]
(	         
	@ProjectID INT  
)
AS
 BEGIN
 BEGIN TRY
 SET NOCOUNT ON   
 
  --Update [AVL].[ITSM_PRJ_SSISExcelColumnMapping] set IsDeleted=1 where ProjectId=@ProjectID and IsDeleted=0 
  DELETE FROM [AVL].[ITSM_PRJ_SSISExcelColumnMapping] where ProjectId=@ProjectID 
  delete from [AVL].[ITSM_PRJ_SSISColumnMapping] where ProjectID=@ProjectID
  
 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[SaveITSMColumnReset]', @ErrorMessage, 0 ,0
  END CATCH

END
