/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[GetWorkPatternHeaderDetails]
(
	@ID BIGINT --ProjectID
)
AS
BEGIN
	 BEGIN TRY
		BEGIN TRAN
		SET NOCOUNT ON;
		
		SELECT 
		TicketDescriptionBasePattern AS TicketDescBasePatt
		,TicketDescriptionSubPattern AS TicketDescSubPatt
		,ResolutionRemarksBasePattern AS ResolRemarksBasePatt
		,ResolutionRemarksSubPattern AS ResolRemarksSubPatt
		FROM ML.WorkPatternConfiguration (NOLOCK) 
		WHERE ProjectID = @ID 
		AND IsDeleted = 0

   COMMIT TRAN
	END TRY
	BEGIN CATCH	
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		INSERT INTO AVL.Errors VALUES(0,'ML.GetWorkPatternHeaderDetails',@ErrorMessage,'system',GETDATE())

		ROLLBACK TRAN	
		              
   END CATCH
END
