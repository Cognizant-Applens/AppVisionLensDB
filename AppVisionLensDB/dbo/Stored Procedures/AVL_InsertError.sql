/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [dbo].[AVL_InsertError]   
 -- Add the parameters for the stored procedure here  
   @ErrSource	VARCHAR(MAX),
   @Message		VARCHAR(MAX),
   @UserID		VARCHAR(50)=0,
   @CustomerID	BIGINT =0
AS  
BEGIN    
	BEGIN TRY  	
	    SET NOCOUNT ON;	  
		INSERT INTO  
			AVL.Errors  
		SELECT 
			@CustomerID, @ErrSource, @Message, @UserID, GETDATE() 

		SELECT 1 AS Result
			
	END TRY  
	BEGIN CATCH  
	  
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  
	  
		SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE();
	 
		-- Use RAISERROR inside the CATCH block to return error  
		-- information about the original error that caused  
		-- execution to jump to the CATCH block.  
		RAISERROR (@ErrorMessage, -- Message text.  
				   @ErrorSeverity, -- Severity.  
				   @ErrorState -- State.  
				   );  
	  
	END CATCH  
   
END
