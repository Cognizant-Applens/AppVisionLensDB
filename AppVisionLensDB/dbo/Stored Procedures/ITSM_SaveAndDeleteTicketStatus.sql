/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_SaveAndDeleteTicketStatus]
(	                
@Type VARCHAR(30),
@ProjectID INT,
@StatusID INT=0,
@DARTStatusID INT=0,
@DARTStatusName VARCHAR(100)='',
@CreatedBy VARCHAR(100)=''
)
AS

BEGIN
    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION

	 

	  IF(@Type='save')
	     BEGIN
		    IF (EXISTS(SELECT StatusName FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE StatusName=@DARTStatusName AND ProjectID=@ProjectID AND IsDeleted=0))
			  BEGIN

			    SELECT 'StatusName already exist.' AS 'Result'
			  END
          ELSE
		  BEGIN
		    INSERT INTO [AVL].[TK_MAP_ProjectStatusMapping] (StatusName,TicketStatus_ID,ProjectID,IsDeleted,CreatedDate,CreatedBy) VALUES
			                            (@DARTStatusName,@DARTStatusID,@ProjectID,0,GETDATE(),@CreatedBy)
		   SELECT 'Ticket status saved successfully. ' AS 'Result'
          END
		    END
     ELSE IF (@Type='update')
	    --      IF (EXISTS(SELECT StatusName FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE StatusName=@DARTStatusName AND ProjectID=@ProjectID))
			  --BEGIN

			  --  SELECT 'StatusName already exist.' AS 'Result'
			  --END
     --     ELSE
	     BEGIN
	       UPDATE [AVL].[TK_MAP_ProjectStatusMapping] SET StatusName=@DARTStatusName,TicketStatus_ID=@DARTStatusID,ModifiedDate=GETDATE(),ModifiedBy=@CreatedBy
		     WHERE StatusID=@StatusID
		    SELECT 'Ticket status updated successfully. ' AS 'Result'
	    END

		ELSE IF(@Type='delete')
		  BEGIN

		   IF (EXISTS(SELECT TicketStatusMapID FROM [AVL].[TK_TRN_TicketDetail] WHERE TicketStatusMapID=@DARTStatusID AND ProjectID=@ProjectID AND IsDeleted!=1))
			  BEGIN

			    SELECT 'Ticket status is already mapped. So cannot delete the record' AS 'Result'
			  END
	
          ELSE
		      UPDATE [AVL].[TK_MAP_ProjectStatusMapping] 
			  SET IsDeleted=1,
			  ModifiedDate=GETDATE(),
			  ModifiedBy=@CreatedBy
			  WHERE StatusID=@StatusID
			   SELECT 'Ticket status deleted successfully. ' AS 'Result'
		    END

	 COMMIT TRANSACTION

     END TRY

	 BEGIN CATCH
	   	DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_SaveAndDeleteTicketStatus] ', @ErrorMessage, @ProjectID,0
		
	 END CATCH

	SET NOCOUNT OFF;
END
