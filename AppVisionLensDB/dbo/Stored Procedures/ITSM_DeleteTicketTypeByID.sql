/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[ITSM_DeleteTicketTypeByID] --151,10324,'676659'
(	     
@ProjectID INT,
@TicketTypeID INT,
@CreatedBy VARCHAR(100)=NULL
)
AS

BEGIN

    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION

	    IF (EXISTS(SELECT TicketTypeMapID FROM [AVL].[TK_TRN_TicketDetail] (NOLOCK) WHERE TicketTypeMapID=@TicketTypeID AND ProjectID=@ProjectID AND IsDeleted!=1))
			  BEGIN

			    SELECT 'Deletion Unsuccessful. Ticket Type is already mapped with Tickets' AS 'Result'
			  END
	
          ELSE IF ((SELECT COUNT(TicketTypeMappingID) FROM [AVL].[TK_MAP_TicketTypeMapping] (NOLOCK) WHERE 
		  ProjectID=@ProjectID AND IsDeleted=0 AND TicketType NOT IN('A','H','K'))=1)
		     BEGIN

			    SELECT 'Deletion Unsuccessful. Configure at least one record.' AS 'Result'
			 END
			 ELSE

		      UPDATE [AVL].[TK_MAP_TicketTypeMapping] SET IsDeleted=1,ModifiedBY=@CreatedBy,ModifiedDateTime=Getdate() WHERE TicketTypeMappingID=@TicketTypeID
			   SELECT 'Ticket Type deleted successfully. ' AS 'Result'

	   COMMIT TRANSACTION

     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'ITSM_DeleteTicketTypeByID', @ErrorMessage, 0 ,@ProjectID
			 SELECT 'Error' AS 'Result' 

	 END CATCH
	SET NOCOUNT OFF;
END
