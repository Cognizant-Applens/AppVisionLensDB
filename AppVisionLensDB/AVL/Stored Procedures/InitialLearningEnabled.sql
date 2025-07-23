/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[InitialLearningEnabled]
 
@EmployeeID NVARCHAR(100)  
AS  
BEGIN  
BEGIN TRY
	SET NOCOUNT ON;
   
select lm.EmployeeID,lm.ProjectID,RoleID='3',IsDebtEnabled='Y' from [AVL].[MAS_LoginMaster] lm join

[AVL].[MAS_ProjectMaster] pm on lm.ProjectID=pm.ProjectID where EmployeeID=@EmployeeID
	
   
   SET NOCOUNT OFF;
   END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[InitialLearningEnabled] ', @ErrorMessage, @EmployeeID,0
		
	END CATCH  
END
