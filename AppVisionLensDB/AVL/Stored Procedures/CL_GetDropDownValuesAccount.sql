/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[CL_GetDropDownValuesAccount] 
@BUID int,
@EmployeeID nvarchar(1000)=null
AS
BEGIN
BEGIN TRY
SELECT 
		DISTINCT c.CustomerID,c.CustomerName
FROM	
		[MAS].[BusinessUnits] BU WITH (NOLOCK)
JOIN
		AVL.Customer c WITH (NOLOCK)
ON 
		c.BusinessUnitID=BU.BusinessUnitID
JOIN
		AVL.MAS_LoginMaster MAS WITH (NOLOCK)
ON 
		MAS.CustomerID=c.CustomerID
WHERE
		BU.BusinessUnitID=@BUID 
AND
		MAS.EmployeeID=@EmployeeID 
AND
		MAS.IsDeleted=0 
AND 
		BU.IsDeleted=0
AND 
		 MAS.ProjectID IN 
							(
								SELECT
										ProjectID
								FROM
										AVL.MAS_ProjectDebtDetails PDD WITH (NOLOCK)
								WHERE
										PDD.IsAutoClassified='Y'
								AND
										PDD.IsMLSignOff=1
								AND 
										PDD.IsDeleted=0
								)

		END TRY  


	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

	
		EXEC AVL_InsertError '[AVL].[CL_GetDropDownValuesAccount]', @ErrorMessage, @EmployeeID, @BUID 
		
	END CATCH  
END
