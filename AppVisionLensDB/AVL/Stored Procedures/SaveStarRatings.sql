/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[SaveStarRatings]
@EmployeeId NVARCHAR(50),
@UseCaseDetailID BIGINT,
@Rating INT,
@HealingTicketID nvarchar(200)
AS
BEGIN
BEGIN TRY

IF EXISTS(SELECT UseCaseDetailID  FROM AVL.Effort_UseCaseRatings WHERE HealingTicketID = @HealingTicketID  AND UseCaseDetailID = @UseCaseDetailID )

BEGIN


UPDATE AVL.Effort_UseCaseRatings SET Rating=@Rating,ModifiedBy='SYSTEM',ModifiedOn=GETDATE(),EmployeeID = @EmployeeId
WHERE HealingTicketID = @HealingTicketID AND UseCaseDetailID = @UseCaseDetailID 
END

ELSE
BEGIN

INSERT INTO AVL.Effort_UseCaseRatings(EmployeeID,HealingTicketID,Rating,UseCaseDetailID,IsDeleted,CreatedBy,CreatedOn) VALUES(@EmployeeId,@HealingTicketID,@Rating,@UseCaseDetailID,0,'SYSTEM',GETDATE())

END

END TRY

BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		  
		EXEC AVL_InsertError '[AVL].[SaveStarRatings]', @ErrorMessage, NULL, @EmployeeId 
		
	END CATCH  
	END
