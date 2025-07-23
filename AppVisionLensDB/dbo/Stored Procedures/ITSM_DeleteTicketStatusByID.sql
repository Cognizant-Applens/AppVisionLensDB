/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_DeleteTicketStatusByID] --151,10324,'676659'
(	     
@ProjectID INT,
@StatusID INT,
@CreatedBy VARCHAR(100)=NULL,
@DARTStatusID INT,
@CustomerID INT
)
AS

BEGIN

    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION
	  DECLARE @IsCognizant INT,@ITSMScreenId INT
	  SELECT 	@IsCognizant=C.IsCognizant FROM AVL.Customer C WHERE CustomerID=@CustomerID AND C.IsDeleted=0

	  IF @IsCognizant=1
	   BEGIN 
	   SET @ITSMScreenId=7
	   END
	   ELSE
	    BEGIN
		SET @ITSMScreenId=6
		END

	  -- IF((SELECT Count(statusID) FROM  [AVL].[TK_MAP_ProjectStatusMapping] WHERE TicketStatus_ID=8 AND ProjectID=@ProjectID AND  CreatedBy=@CreatedBy AND  IsDeleted=0)=1 AND @DARTStatusID=8 )
		 --   BEGIN
			--update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate(),CompletionPercentage=null where ProjectID=@ProjectID and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0 
		 --END

		   IF (EXISTS(SELECT TicketStatusMapID FROM [AVL].[TK_TRN_TicketDetail] WHERE TicketStatusMapID=@StatusID AND ProjectID=@ProjectID AND IsDeleted!=1))
			  BEGIN
			    SELECT 'Deletion Unsuccessful. Ticket status is already mapped with Tickets' AS 'Result'
			  END
	      ELSE IF ((SELECT COUNT(StatusID) FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE ProjectID=@ProjectID AND IsDeleted=0)=1)
	       BEGIN
		      SELECT 'Deletion Unsuccessful. Configure at least one record.' AS 'Result'
		   END
          ELSE
			  BEGIN
				UPDATE [AVL].[TK_MAP_ProjectStatusMapping] SET IsDeleted=1,ModifiedDate=getdate(),ModifiedBy=@CreatedBy
				WHERE StatusID=@StatusID
			     
				IF NOT EXISTS(SELECT TOP 1 statusID FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE TicketStatus_ID=8 AND ProjectID=@ProjectID AND  IsDeleted=0)
					BEGIN
						UPDATE [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=GETDATE(),CompletionPercentage=null 
						where ProjectID=@ProjectID and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0  
					END
			   SELECT 'Ticket status deleted successfully. ' AS 'Result'
			   END
	   COMMIT TRANSACTION

     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'ITSM_DeleteTicketStatusByID', @ErrorMessage, 0 ,@ProjectID
			 SELECT 'Error' AS 'Result' 

	 END CATCH
	SET NOCOUNT OFF;
END
