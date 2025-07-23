/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[PodDetailValidation]
(
        @ProjectID BIGINT,
		@PodDetails AS [AVL].[TVP_PodDetails] READONLY	  
)
AS
BEGIN
   BEGIN TRY
		
		SELECT PP.PODName FROM @PodDetails PD INNER JOIN PP.Project_PODDetails PP ON PD.PodDetails = PP.PODName
			WHERE PP.ProjectID = @ProjectID AND IsDeleted =0

  END TRY
  BEGIN CATCH		
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()

		--- Insert Error Message ---
		EXEC AVL_InsertError '[AVL].[PodDetailValidation]', @ErrorMessage, 0, 0
		             
  END CATCH
END
