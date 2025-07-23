/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:      Prakash     
-- Create date:      23 Nov 2018
-- Description:   get configuration data
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- [AVL].[Mini_GetConfigurationProjectDetailsByEmployee]  '471742'
-- ============================================================================ 


CREATE Procedure [AVL].[Mini_GetConfigurationProjectDetailsByEmployee] 
@EmployeeID NVARCHAR(50)=null 
AS
BEGIN
	BEGIN TRY
	
	SELECT LM.ProjectID,PM.ProjectName,ISNULL(LM.IsMiniConfigured,1) AS IsMiniConfigured,LM.EmployeeName AS EmployeeName
	FROM [AVL].[MAS_LoginMaster](NOLOCK)  LM
	INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON LM.ProjectID=PM.ProjectID
	WHERE EmployeeID = @EmployeeID  AND LM.IsDeleted=0 
	ORDER BY PM.ProjectName ASC
	


	END TRY  

BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Mini_GetConfigurationProjectDetailsByEmployee] ', @ErrorMessage, @EmployeeID,0
END CATCH  

END
