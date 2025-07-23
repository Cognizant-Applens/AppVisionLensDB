/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Effort_SaveUseCaseDetails]
@ProjectID  BIGINT,
@HealingTicketID nvarchar(200),
@UseCaseSolutionMapID BIGINT,
@IsSolutionMapped BIT,
@StarRatings INT,
@EmployeeID VARCHAR(50)

AS 
  BEGIN 
      BEGIN TRY 
		SET NOCOUNT ON;
		IF EXISTS(SELECT TOP 1 UseCaseSolutionMapId FROM AVL.DEBT_UseCaseSolutionIdentificationDetails WHERE PROJECTID = @ProjectID 
		AND HealingTicketID = @HealingTicketID
		AND UseCaseSolutionMapId = @UseCaseSolutionMapID)
	    BEGIN
		
		UPDATE AVL.DEBT_UseCaseSolutionIdentificationDetails SET IsMappedSolution = 0 WHERE PROJECTID = @ProjectID  AND HealingTicketID = @HealingTicketID 

		UPDATE AVL.DEBT_UseCaseSolutionIdentificationDetails SET IsMappedSolution = @IsSolutionMapped,ModifiedBy = 'SYSTEM',ModifiedOn=GETDATE() 
		WHERE PROJECTID = @ProjectID AND HealingTicketID = @HealingTicketID AND UseCaseSolutionMapId = @UseCaseSolutionMapID

		UPDATE  RAT SET RAT.Isdeleted=1 
		FROM AVL.Effort_UseCaseRatings RAT JOIN  AVL.DEBT_UseCaseSolutionIdentificationDetails US ON US.HealingTicketID=RAT.HealingTicketID
		WHERE US.HealingTicketID=@HealingTicketID AND IsMappedSolution = 0

		EXEC AVL.SaveStarRatings @EmployeeID,@UseCaseSolutionMapID,@StarRatings,@HealingTicketID
	    END
      END TRY 
      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE()   
          EXEC AVL_INSERTERROR '[AVL].[Effort_SaveUseCaseDetails]',  @ErrorMessage, @ProjectID,  0 
      END CATCH 
  END
