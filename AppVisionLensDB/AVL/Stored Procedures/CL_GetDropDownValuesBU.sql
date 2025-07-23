/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		Sreeya
-- Create date: 3-29-2018
-- Description:	business unit dropdown values
-- =============================================
CREATE PROCEDURE [AVL].[CL_GetDropDownValuesBU] 
@EmployeeID nvarchar(1000)=null
AS
BEGIN
BEGIN TRY
		SELECT 
				DISTINCT BusinessUnitID AS BUID,BusinessUnitName AS BUName 
		FROM	[MAS].[BusinessUnits] 
		WHERE	BusinessUnitID IN (
						SELECT 
								DISTINCT BusinessUnitID 
						FROM	AVL.Customer 
						WHERE	CustomerID IN (
												SELECT 
														DISTINCT LM.CustomerID 
												FROM	AVL.MAS_LoginMaster LM 
												WHERE EmployeeID=@EmployeeID
												AND LM.IsDeleted=0
												AND LM.ProjectID IN 
													(
														SELECT
																ProjectID
														FROM
																AVL.MAS_ProjectDebtDetails PDD
														WHERE
																PDD.IsAutoClassified='Y'
														AND
																PDD.IsMLSignOff=1
														AND 
																PDD.IsDeleted=0
													)
												) 
						AND IsDeleted=0
						)
		AND IsDeleted=0
END TRY  
/*----------------------------------END TRY--------------------------------*/

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[CL_GetDropDownValuesBU]', @ErrorMessage, @EmployeeID, 0 
		
	END CATCH  
END
