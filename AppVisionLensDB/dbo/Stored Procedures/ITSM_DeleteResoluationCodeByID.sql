/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_DeleteResoluationCodeByID] --151,10324,'676659'
(	     
@ProjectID INT,
@ResolutionCodeID INT,
@CreatedBy VARCHAR(100)=NULL
)
AS

BEGIN

    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION

	   --IF (EXISTS(SELECT ResolutionCodeMapID FROM [AVL].[TK_TRN_TicketDetail] WHERE ResolutionCodeMapID=@ResolutionCodeID AND ProjectID=@ProjectID and IsDeleted<>1))
			 -- BEGIN

			 --   SELECT 'Resolution Code is already mapped. So cannot delete the record' AS 'Result'
			 -- END
	    --IF ((SELECT COUNT(ResolutionID) FROM [AVL].[DEBT_MAP_ResolutionCode] WHERE ProjectID=@ProjectID AND IsDeleted=0)=1)
	    --     BEGIN
		   --   SELECT 'Deletion Unsuccessful. Configure at least one record.' AS 'Result'
		   --  END
     --   ELSE
		      UPDATE [AVL].[DEBT_MAP_ResolutionCode] 
			  SET IsDeleted=1,
			  ModifiedDate=GETDATE(),
			  ModifiedBy=@CreatedBy
			  WHERE ResolutionId=@ResolutionCodeID

			  UPDATE AVL.CauseCodeResolutionCodeMapping
			  SET IsDeleted=1,
			  ModifiedDate=GETDATE(),
			  ModifiedBy=@CreatedBy
			  WHERE ResolutionCodeMapID=@ResolutionCodeID AND ProjectID=@ProjectID
			  

			   SELECT 'Resolution Code deleted successfully.' AS 'Result'

	   COMMIT TRANSACTION
     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'ITSM_DeleteResoluationCodeByID', @ErrorMessage, 0 ,@ProjectID
			 SELECT 'Error' AS 'Result' 

	 END CATCH
	SET NOCOUNT OFF;
END
