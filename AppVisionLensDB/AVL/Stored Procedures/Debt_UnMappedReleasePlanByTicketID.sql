/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Debt_UnMappedReleasePlanByTicketID]
(
    @releaseDetails TVP_UpdateReleasePlanList READONLY --parameeter declaration 
)
AS
	BEGIN
	BEGIN TRY
		SET NOCOUNT ON;  
		DECLARE @result bit
		
		
	  BEGIN TRANSACTION

			 UPDATE [AVL].[DEBT_TRN_HealTicketDetails] SET Assignee=0,
			 ReleasePlanning=NULL,DARTStatusID=null
	         FROM [AVL].[DEBT_TRN_HealTicketDetails] t1
			 JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic HMD ON HMD.ProjectPatternMapID=t1.ProjectPatternMapID  
			 JOIN @releaseDetails t2 ON t1.HealingTicketID=t2.TicketID AND HMD.ProjectID=t2.ProjectID

	  COMMIT TRANSACTION
	  SET @result= 1
 
	END TRY 
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()--sql exception 
		SET @result= 0
		EXEC AVL_InsertError '[AVL].[Debt_UnMappedReleasePlanByTicketID]', @ErrorMessage, 0,0
	END CATCH  

	 SELECT @result AS RESULT
    SET NOCOUNT OFF; 
END
