/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================================
-- Author      : Annadurai
-- Create date : 07.01.2019
-- Description : This Procedure used to get  Project Name and isCognizant User details
-- Revision    :  
-- Revised By  :
-- ============================================================================================
CREATE PROCEDURE [AVL].[GetTicketingModuleProjectDetails]
(
	@projectID INT,
	@customerID INT
)

AS
BEGIN
BEGIN TRY
	SELECT EsaProjectID,
		   REPLACE(ProjectName,'/','') as ProjectName,
		   C.IsCognizant 
	FROM AVL.MAS_ProjectMaster(NOLOCK) PM
	JOIN AVL.Customer(NOLOCK) C
		ON c.CustomerID=PM.CustomerID
	WHERE ProjectID = @projectid AND C.CustomerID=@customerID

  END TRY
  BEGIN CATCH			

		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--- Insert Error Message ---
		EXEC AVL_InsertError '[AVL].[GetTicketingModuleProjectDetails]', @ErrorMessage, 0, 0
		             
  END CATCH

END
