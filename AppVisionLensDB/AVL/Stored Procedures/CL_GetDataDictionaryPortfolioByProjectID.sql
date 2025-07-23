/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE  [AVL].[CL_GetDataDictionaryPortfolioByProjectID] 
(
@projectID int,
@employeeID nvarchar(1000),
@customerId int
)		   
AS 
BEGIN
BEGIN TRY
	
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

	JOIN AVL.MAS_ProjectDebtDetails PDD 
	
	ON LM.ProjectID=PDD.ProjectID 

    AND (PDD.IsDeleted=0 or PDD.IsDeleted is NULL)
	WHERE 

			BC.IsHavingSubBusinesss=0 
	AND
			 BC.IsDeleted=0 
	AND
			AD.IsActive=1
	AND
			LM.EmployeeID=@EmployeeID
	AND 
			BC.CustomerID=@customerId

	AND     LM.ProjectID=@projectID
		
		END TRY  


	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
   
		EXEC AVL_InsertError 'CL_GetDataDictionaryPortfolioByProjectID', @ErrorMessage, @projectID
		
	END CATCH  
	END
