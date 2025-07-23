/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[LoggedInUserDetails] --383323
 
@EmployeeID NVARCHAR(100)  
AS  
BEGIN  
BEGIN TRY
	SET NOCOUNT ON;
   

	SELECT distinct MPM.ProjectName,LM.EmployeeName,LM.ClientUserID,LM.EmployeeName AS TimesheetApproverName,LM.EmployeeName AS ManagerName  
 	FROM [AVL].[MAS_LoginMaster] LM WITH (NOLOCK)
		--JOIN [AVL].[MAS_LoginMaster] Appr WITH (NOLOCK) ON LM.TSApproverID=Appr.EmployeeID  
		--JOIN [AVL].[MAS_LoginMaster] Mgr WITH (NOLOCK) ON LM.ManagerID=Mgr.EmployeeID  
		JOIN [AVL].[MAS_ProjectMaster] MPM on MPM.ProjectID=LM.ProjectID
	WHERE LM.employeeid=@EmployeeID
		 
   
   SET NOCOUNT OFF;
   END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[LoggedInUserDetails]  ', @ErrorMessage, @EmployeeID,0
		
	END CATCH  



END
