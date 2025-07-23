/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:      Prakash, Divya     
-- Create date:      23 Nov 2018
-- Description:    upadte is mini configured flag
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- EXEC [AVL].[Mini_UpdateIsMiniConfiguredInLoginMaster]

-- ============================================================================ 

CREATE PROCEDURE [AVL].[Mini_UpdateIsMiniConfiguredInLoginMaster]
(
@EmployeeID nvarchar(50),
@ProjectID bigint,
@isMiniConfigured bit
)
AS 
BEGIN
BEGIN TRY
BEGIN TRAN
	IF Exists(SELECT  UserID FROM AVL.MAS_LoginMaster where EmployeeID=@EmployeeID AND ProjectID=@ProjectID AND IsDeleted=0) 
	BEGIN	
		UPDATE AVL.MAS_LoginMaster SET IsMiniConfigured=@isMiniConfigured WHERE EmployeeID=@EmployeeID AND ProjectID=@ProjectID AND IsDeleted=0	
		COMMIT TRAN
	END

END TRY
BEGIN CATCH  
	ROLLBACK TRAN
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Mini_UpdateIsMiniConfiguredInLoginMaster]', @ErrorMessage, @EmployeeID,0
END CATCH 

END
