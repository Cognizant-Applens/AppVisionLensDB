/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE  [AVL].[CL_GetDataDictionaryProjectPortfolio] 

@CustomerID int,
@EmployeeID nvarchar(1000)
AS 
BEGIN
BEGIN TRY
	SELECT
			DISTINCT PM.ProjectID,PM.ProjectName,PDD.IsDDAutoClassified,PDD.IsTicketApprovalNeeded,
			PDD.IsManual
	FROM 
			AVL.MAS_ProjectMaster PM
	JOIN 
			AVL.MAS_LoginMaster LM
	ON 
			LM.ProjectID=PM.ProjectID

    JOIN AVL.MAS_ProjectDebtDetails PDD

	ON

	       PDD.ProjectID=LM.ProjectID
	WHERE 
			LM.CustomerID=@CustomerID
			
	AND		
			EmployeeID=@EmployeeID
	AND 
			LM.IsDeleted=0 
	AND 
			PM.IsDeleted=0
	AND
			LM.ProjectID IN 
							(
								SELECT
										ProjectID 
								FROM
										AVL.MAS_ProjectDebtDetails PDD
								WHERE
										
										(PDD.IsDeleted=0 or PDD.IsDeleted is NULL)
								)
								ORDER BY PM.ProjectName ASC

	SELECT
			 DISTINCT BC.BusinessClusterMapID,BusinessClusterBaseName 
	FROM 
			AVL.APP_MAS_ApplicationDetails AD
	JOIN		 			
			 AVL.BusinessClusterMapping BC
	ON		 
			AD.SubBusinessClusterMapID=BC.BusinessClusterMapID 
	JOIN
			AVL.MAS_LoginMaster LM
	ON
			BC.CustomerID=LM.CustomerID
	WHERE 
			BC.IsHavingSubBusinesss=0 
	AND
			 BC.IsDeleted=0 
	AND
			AD.IsActive=1
	AND
			LM.EmployeeID=@EmployeeID
	AND 
			BC.CustomerID=@CustomerID
	AND
			LM.ProjectID IN 
							(
								SELECT
										ProjectID
								FROM
										AVL.MAS_ProjectDebtDetails PDD
								WHERE
							
										(PDD.IsDeleted=0 or PDD.IsDeleted is NULL)
								)



		END TRY  

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		  
		EXEC AVL_InsertError 'CL_GetDropDownValuesProjectPortfolio', @ErrorMessage, @EmployeeID, @CustomerID 
		
	END CATCH  
	END
