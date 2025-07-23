/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : 
-- Create date : 9/13/2020
-- Description : Procedure to check historical ITSM cause code details  before deleting
-- Revision    :
-- Revised By  :
-- ========================================================================================= 

CREATE PROCEDURE [PP].[ITSM_DeleteCauseCodeDetails] --151,10324,'676659'
(	     
@ProjectID INT,
@CauseCodeID INT,
@CreatedBy VARCHAR(100)=NULL
)
AS

BEGIN

    SET NOCOUNT ON; 
	BEGIN TRY
	 
	   IF (EXISTS(SELECT CauseCodeMapID FROM [AVL].[TK_TRN_TicketDetail] WHERE CauseCodeMapID=@CauseCodeID AND ProjectID=@ProjectID and IsDeleted<>1 AND @CauseCodeID!=0 ))
			  BEGIN

			    SELECT 'Historical tickets which are mapped with this Cause code will have an impact upon deletion' AS 'Result'
			  END	   
        ELSE		     
			   SELECT 'Do you want to delete' AS 'Result'

     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[ITSM_DeleteCauseCodeDetails]', @ErrorMessage, 0 ,@ProjectID
			 SELECT 'Error' AS 'Result' 

	 END CATCH
END
