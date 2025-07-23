/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[InsertJobStatus]
@RegexConfigID BIGINT,
@CreatedBy nvarchar(50)
AS
BEGIN
 BEGIN TRY  
	   BEGIN TRAN
INSERT INTO AVL.RegexJobStatus(RegexConfigID,ConfigTypeID,EffectiveStartDate,EffectiveEndDate,InitiatedBy,InitiatedOn,ProcessStartDate,ProcessEndDate,
JobMessage,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate) 
SELECT @RegexConfigID,ConfigTypeID,EffectiveStartDate,EffectiveEndDate,@CreatedBy,GETDATE(),GETDATE(),null,'Sent',0,@CreatedBy,GETDATE(),
null,null from AVL.PRJ_RegexConfiguration WHERE RegexConfigID = @RegexConfigID

SELECT ID FROM AVL.RegexJobStatus WHERE RegexConfigID = @RegexConfigID

	COMMIT TRAN
	END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error   
		ROLLBACK TRAN
        EXEC AVL_INSERTERROR  '[PP].[InsertJobStatus]', @ErrorMessage,  0, 
        0 
    END CATCH 
			
END
