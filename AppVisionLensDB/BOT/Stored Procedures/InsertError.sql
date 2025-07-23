/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [BOT].[InsertError]
 -- Add the parameters for the stored procedure here  
   @errorSource	VARCHAR(MAX),
   @message		VARCHAR(MAX),
   @userId		VARCHAR(50),
   @customerId	BIGINT = 0
AS  
BEGIN    
	BEGIN TRY  	
	          	  
		INSERT INTO  
			[BOT].[ErrorLog]  
		SELECT 
			@customerId, @errorSource, @message, @userId, GETDATE() 

		SELECT 1 AS Result
			
	END TRY  
	BEGIN CATCH  
	  
		DECLARE @errorMessage NVARCHAR(4000);  
		DECLARE @errorSeverity INT;  
		DECLARE @errorState INT;  
	  
		SELECT   
			@errorMessage = ERROR_MESSAGE(),  
			@errorSeverity = ERROR_SEVERITY(),  
			@errorState = ERROR_STATE();
	 
		-- Use RAISERROR inside the CATCH block to return error  
		-- information about the original error that caused  
		-- execution to jump to the CATCH block.  
		RAISERROR (@errorMessage, -- Message text.  
				   @errorSeverity, -- Severity.  
				   @errorState -- State.  
				   );  
	  
	END CATCH  
   
END
