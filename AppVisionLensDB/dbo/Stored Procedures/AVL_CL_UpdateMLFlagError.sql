/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/*-- =============================================
-- Author:		Sreeya
-- Create date: 25-6-2018
-- Description:	updates job on error
-- =============================================*/
CREATE PROCEDURE [dbo].[AVL_CL_UpdateMLFlagError] 
@ProjectID bigint
AS
BEGIN
BEGIN TRY
BEGIN TRAN

update AVL.CL_PRJ_ContLearningState set PresentStatus=5 where ProjectID=@ProjectID and [IsDeleted]=0

 COMMIT TRAN
 END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[AVL_CL_UpdateMLFlagError] ', @ErrorMessage, 0,0
		
	END CATCH  
END
