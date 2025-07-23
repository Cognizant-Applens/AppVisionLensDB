/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--DROP PROCEDURE [dbo].[Effort_SubmitTicketDetails]

CREATE PROCEDURE [dbo].[Effort_SubmitTicketDetails]
@EmployeeID NVARCHAR(100),
@Status NVARCHAR(100),
@TVP_TicketDetailsCollection TVP_TicketSubmit READONLY                


AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;  
       
	   SELECT TicketID,TicketTypeID,StatusID FROM @TVP_TicketDetailsCollection                
	SELECT * INTO #TicketDetailsCollection 
	FROM @TVP_TicketDetailsCollection 
	WHERE StatusID <> 0 AND TicketTypeID <>0

	UPDATE TD
	SET TD.TicketTypeMapID=TDC.TicketTypeID, TD.TicketStatusMapID=TDC.StatusID,
	TD.ModifiedBy=@EmployeeID , TD.ModifiedDate=GETDATE(), TD.LastUpdatedDate =GETDATE()
	FROM AVL.TK_TRN_TicketDetail TD
	INNER JOIN #TicketDetailsCollection TDC
	ON TD.TicketID=TDC.TicketID AND TD.ProjectID=TDC.ProjectID
	
	
SET NOCOUNT OFF; 
COMMIT TRAN
     END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[Effort_SubmitTicketDetails] ', @ErrorMessage, @EmployeeID,0
		
	END CATCH 



END

--SELECT * FROM 
