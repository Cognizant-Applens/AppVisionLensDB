/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Effort_GetLoginDetails]   

(  

@projectid INT  

)  

AS  

BEGIN  
BEGIN TRY
SET NOCOUNT ON;  

 SELECT [UserID],  

 [EmployeeID],  

 [EmployeeName]  

 FROM [AVL].[MAS_LoginMaster] LM  

 WHERE 

 ProjectID = @projectid  

 AND IsDeleted=0   

SET NOCOUNT OFF;   

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError ' [AVL].[Effort_GetLoginDetails]   ', @ErrorMessage, @projectid,0
		
	END CATCH  
END
