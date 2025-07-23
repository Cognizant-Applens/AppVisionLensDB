/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AC].[GetHcmSupervisorID]
@EmployeeID NVARCHAR(50),
@CustomerID bigint,
@ESAProjectid NVARCHAR(50)
AS
BEGIN
BEGIN TRY
	
	Declare @projectID NVARCHAR(50)
	Declare @HcmSupervisorID NVARCHAR(100)

	set @projectID = (select ProjectID from [AVL].[MAS_ProjectMaster] where EsaProjectID = @ESAProjectid)

	set @HcmSupervisorID = (select HcmSupervisorID from [AVL].[MAS_LoginMaster] where Employeeid = @EmployeeID and CustomerID = @CustomerID and ProjectID = @projectID)

	select EmployeeEmail from [AVL].[MAS_LoginMaster] where EmployeeID = @HcmSupervisorID and  CustomerID = @CustomerID and ProjectID = @projectID


END TRY

	BEGIN CATCH

		DECLARE @ErrorMessage VARCHAR(4000);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error                                    
		EXEC AVL_InsertError '[AC].[GetHcmSupervisorID]',@ErrorMessage,0

	END CATCH
END
