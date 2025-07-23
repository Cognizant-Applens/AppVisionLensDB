/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_DeletePriorityByMapID] --151,10324,'676659'
(	     
@ProjectID INT,
@PriorityIDMapID INT,
@CreatedBy VARCHAR(100)=NULL
)
AS

BEGIN

    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION

	   IF (EXISTS(SELECT PriorityMapID FROM [AVL].[TK_TRN_TicketDetail] WHERE PriorityMapID=@PriorityIDMapID AND ProjectID=@ProjectID AND IsDeleted!=1))
			  BEGIN

			    SELECT 'Deletion Unsuccessful. Priority is already mapped with Tickets' AS 'Result'
			  END
      ELSE IF ((SELECT COUNT(PriorityIDMapID) FROM AVL.TK_MAP_PriorityMapping WHERE ProjectID=@ProjectID AND IsDeleted=0)=1)
	       BEGIN
		      SELECT 'Deletion Unsuccessful. Configure at least one record.' AS 'Result'
		   END
        ELSE
		BEGIN
		      UPDATE AVL.TK_MAP_PriorityMapping SET IsDeleted=1,ModifiedDateTime=getdate(),ModifiedBY=@CreatedBy 
			  WHERE PriorityIDMapID=@PriorityIDMapID AND ProjectID=@ProjectID 
			   SELECT 'Priority deleted successfully. ' AS 'Result'
	    END

	   COMMIT TRANSACTION

     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'ITSM_DeletePriorityByMapID', @ErrorMessage, 0 ,@ProjectID
			 SELECT 'Error' AS 'Result' 

	 END CATCH
	SET NOCOUNT OFF;
END
