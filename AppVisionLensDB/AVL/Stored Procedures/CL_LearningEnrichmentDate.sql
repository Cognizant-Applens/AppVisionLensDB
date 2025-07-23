/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		Sreeya
-- Create date: 9-4-2018
-- Description:	Gets the learning enrichment period date
-- =============================================
CREATE PROCEDURE [AVL].[CL_LearningEnrichmentDate] 
@projectID bigint,
@userID nvarchar(300)
AS
BEGIN
BEGIN TRY

SELECT 
		TOP(1) CL.StartDateTime AS 'FromDate' , CL.EndDateTime AS 'ToDate' 
FROM	
			AVL.CL_ProjectJobDetails CL 
WHERE
			CL.ProjectID=@projectID
AND
			IsDeleted=1
AND
			CL.StatusForJob=1
AND	
			(HasError=0 or HasError is null)
ORDER BY
			CL.CreatedDate DESC 


END TRY


BEGIN CATCH


		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[CL_LearningEnrichmentDate] ', @ErrorMessage, @projectID,@userID

END CATCH

END
