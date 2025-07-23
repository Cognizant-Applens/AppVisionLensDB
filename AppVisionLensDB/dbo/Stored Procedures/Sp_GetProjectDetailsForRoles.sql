/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
-- ====================================================================
-- author:		
-- create date: 
-- Modified by : 686186
-- Modified For: RHMS CR
-- description: getting project details using customerID and employeeid
-- ====================================================================

-- EXEC [dbo].[Sp_GetProjectDetailsForRoles] 8245,'308965' 

CREATE PROCEDURE [dbo].[Sp_GetProjectDetailsForRoles] --5554,'191439'
(
	@CustomerID int,
	@EmployeeID varchar(50)
)
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
	SELECT    DISTINCT     ECPRM.ProjectID, PM.ProjectName,ISNULL(PM.IsMainspringConfigured,'N') AS IsMainspringConfigured,
		ISNULL(PM.IsDebtEnabled,'N') AS IsDebtEnabled,ISNULL(supporttypeid,0) AS supporttypeid
	
	FROM  [AVL].[VW_EmployeeCustomerProjectRoleBUMapping] ECPRM (NOLOCK) 
		JOIN AVL.MAS_ProjectMaster PM (NOLOCK) on ECPRM.ProjectID=PM.ProjectID and PM.IsDeleted=0
		LEFT JOIN AVL.MAP_ProjectConfig PC (NOLOCK)  ON PC.projectid = PM.projectid 
		WHERE (ECPRM.CustomerID =@CustomerID) AND (ECPRM.EmployeeID = @EmployeeID)
		and (ECPRM.RoleID in (6,7))
END TRY     
BEGIN CATCH  

    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT; 

    SELECT @ErrorMessage = ERROR_MESSAGE()
    SELECT @ErrorSeverity = ERROR_SEVERITY()
    SELECT @ErrorState =  ERROR_STATE()
    --INSERT Error    
    EXEC AVL_InsertError '[dbo].[Sp_GetProjectDetailsForRoles]', @ErrorMessage, 0 ,0
         
              
END CATCH  
SET NOCOUNT OFF;
END
