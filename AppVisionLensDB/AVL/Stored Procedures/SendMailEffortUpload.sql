
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[SendMailEffortUpload]
@To NVARCHAR(MAX),
@From NVARCHAR(MAX),
@CC NVARCHAR(MAX),
@Body NVARCHAR(MAX),
@Subject NVARCHAR(MAX)

AS 
BEGIN
	BEGIN TRY 
 SET NOCOUNT ON;
DECLARE @Result bit;
		
			-------------executing mail-------------
			EXEC [AVL].[SendDBEmail] @To=@To,
				@From='ApplensSupport@cognizant.com',
				@CC=@CC,
				@Subject =@Subject,
				@Body = @Body
SET @Result = 1
Select @Result as Result
END TRY

BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
		SET @Result = 0
		Select @Result as Result
		  EXEC AVL_INSERTERROR  'AVL.SendMailEffortUpload', @ErrorMessage,  0,  0 

END CATCH
								
								
END


