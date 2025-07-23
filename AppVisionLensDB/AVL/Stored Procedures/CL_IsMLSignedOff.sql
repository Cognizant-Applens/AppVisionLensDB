/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/*-- =============================================
-- Author:		Sreeya
-- Create date: 26 June 2018
-- Description:	Checks if any project assigned to the user has ml signed off
-- =============================================*/
CREATE PROCEDURE [AVL].[CL_IsMLSignedOff] 
@EmployeeID nvarchar(max),
@CustomerId bigint
AS
BEGIN
BEGIN TRY
IF EXISTS(select 1 from AVL.MAS_LoginMaster WHERE ( TSApproverID=@EmployeeID or HcmSupervisorID=@EmployeeID )
AND CustomerID=@CustomerId and isdeleted=0 and ProjectID in (SELECT  ProjectID  FROM  AVL.MAS_ProjectDebtDetails PDD  
WHERE  PDD.IsAutoClassified='Y'AND PDD.IsMLSignOff='1' AND  (PDD.IsDeleted=0 or PDD.IsDeleted is null)))
BEGIN
		 SELECT 1
END
ELSE 
		 BEGIN
		 SELECT 0
		 END
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[CL_IsMLSignedOff] ', @ErrorMessage, @CustomerId,@EmployeeID
		
	END CATCH  
END