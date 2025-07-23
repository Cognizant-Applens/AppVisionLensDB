/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_SaveAndDeleteTicketType] 
(	                
@Type VARCHAR(30),
@ProjectID INT,
@TicketTypeMappingID INT=0,
@TicketTypeName VARCHAR(100),
@DebtApplicable VARCHAR(20)=NULL,
@CreatedBy VARCHAR(100)=''
)
AS

BEGIN
    SET NOCOUNT ON; 
          
	IF @DebtApplicable=''
	 BEGIN 
	     SET @DebtApplicable=NULL
	 END
	BEGIN TRY
	  BEGIN TRANSACTION

	  IF(@Type='save')
	     BEGIN
		    IF (EXISTS(SELECT TicketType FROM [AVL].[TK_MAP_TicketTypeMapping] WHERE TicketType=@TicketTypeName AND ProjectID=@ProjectID AND IsDeleted=0))
			  BEGIN

			    SELECT 'TicketType already exist.' AS 'Result'
			  END
          ELSE
		  BEGIN
		    INSERT INTO [AVL].[TK_MAP_TicketTypeMapping] (TicketType,AVMTicketType,ProjectID,DebtConsidered,IsDeleted,CreatedDateTime,CreatedBy) VALUES
			                            (@TicketTypeName,NULL,@ProjectID,@DebtApplicable,0,GETDATE(),@CreatedBy)
		   SELECT 'Ticket type saved successfully. ' AS 'Result'
          END
		    END
     ELSE IF (@Type='update')
	  
	     BEGIN
	       UPDATE [AVL].[TK_MAP_TicketTypeMapping] 
		   SET TicketType=@TicketTypeName,DebtConsidered=@DebtApplicable,ModifiedDateTime=GETDATE(),ModifiedBY=@CreatedBy
		    WHERE TicketTypeMappingID=@TicketTypeMappingID
		    SELECT 'Ticket type updated successfully. ' AS 'Result'
	    END

		ELSE IF(@Type='delete')
		  BEGIN

		   IF (EXISTS(SELECT TicketTypeMapID FROM [AVL].[TK_TRN_TicketDetail] WHERE TicketTypeMapID=@TicketTypeMappingID AND ProjectID=@ProjectID AND IsDeleted!=1))
			  BEGIN

			    SELECT 'Ticket type is already mapped. So cannot delete the record' AS 'Result'
			  END
	
          ELSE
		      UPDATE [AVL].[TK_MAP_TicketTypeMapping] 
			  SET IsDeleted=1,
			  ModifiedDateTime=GETDATE(),ModifiedBY=@CreatedBy
			  WHERE TicketTypeMappingID=@TicketTypeMappingID
			   SELECT 'Ticket Type deleted successfully. ' AS 'Result'
		    END

	 COMMIT TRANSACTION

     END TRY

	 BEGIN CATCH
	     	DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_SaveAndDeleteTicketType] ', @ErrorMessage, @ProjectID,0
		
	 END CATCH

	SET NOCOUNT OFF;
END
