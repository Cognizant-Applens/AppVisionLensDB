/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_DeleteTicketSourceBYTicketID] 
(
@ProjectID INT,
@SourceIDMapID INT,
@CreatedBy VARCHAR(100)=NULL
)

AS
BEGIN
 SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION

	    IF (EXISTS(SELECT TicketSourceMapID FROM [AVL].[TK_TRN_TicketDetail] WHERE TicketSourceMapID=@SourceIDMapID AND ProjectID=@ProjectID AND IsDeleted!=1))
			  BEGIN

			    SELECT 'Deletion Unsuccessful. Ticket Source is already mapped with Tickets' AS 'Result'
			  END
	
          ELSE IF ((SELECT COUNT(SourceIDMapID) FROM  [AVL].[TK_MAP_SourceMapping] WHERE ProjectID=@ProjectID AND IsDeleted=0)=1)
		     BEGIN

			    SELECT 'Deletion Unsuccessful. Configure at least one record.' AS 'Result'
			 END
			 ELSE

		      UPDATE [AVL].[TK_MAP_SourceMapping] SET IsDeleted=1,ModifiedBY=@CreatedBy,ModifiedDateTime=Getdate() WHERE SourceIDMapID=@SourceIDMapID
			   SELECT 'Ticket Source deleted successfully. ' AS 'Result'

	   COMMIT TRANSACTION

     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError ' ITSM_DeleteTicketSourceBYTicketID', @ErrorMessage, 0 ,@ProjectID
			 SELECT 'Error' AS 'Result' 

	 END CATCH
	SET NOCOUNT OFF;




END


--select * from [AVL].[TK_TRN_TicketDetail]
