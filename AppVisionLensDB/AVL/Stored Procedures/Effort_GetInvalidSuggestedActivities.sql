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
-- Author      : Dhivya Bharathi M
-- Create date : 27 Dec 2019
-- Description : Procedure to get the list of invalid words from the master table            
-- Test        : [AVL].[Effort_GetInvalidSuggestedActivities]
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [AVL].[Effort_GetInvalidSuggestedActivities]
AS
BEGIN
  BEGIN TRY
     SET NOCOUNT ON; 
		 SELECT ExcludedWordID AS Id,ExcludedWordName AS [Name] FROM MAS.ExcludedWords 
		 WHERE ISNULL(IsDeleted,0)=0
		 UNION
		 SELECT ID AS Id,NonTicketedActivity AS [Name] FROM AVL.MAS_NonDeliveryActivity WHERE IsActive=1
	 SET NOCOUNT OFF; 
   END TRY

	BEGIN CATCH
       
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Effort_GetInvalidSuggestedActivities]', @ErrorMessage, 0,0            
   END CATCH

END
