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
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================*/
CREATE PROCEDURE  [AVL].[CL_GetDropDownValuesProjectPortfolio]

@CustomerID bigint,
@EmployeeID nvarchar(1000),
@ProjectID bigint=0,
@IsPortfolio int=0
AS 
BEGIN
BEGIN TRY
IF @IsPortfolio=0
BEGIN

	SELECT
			DISTINCT PM.ProjectID,PM.ProjectName,PC.SupportTypeId	FROM 
			AVL.MAS_ProjectMaster PM	JOIN 
			AVL.MAS_LoginMaster LM			
	ON 		LM.ProjectID=PM.ProjectID
			JOIN AVL.MAP_ProjectConfig PC 
	ON		PC.ProjectID = PM.ProjectID
	WHERE 	PM.CustomerID=@CustomerID
			
	AND		
			EmployeeID=@EmployeeID
	AND 
			PM.IsDeleted=0 
	AND	
			LM.IsDeleted=0
	--AND
	--		LM.ProjectID IN 
	--						(
	--							SELECT
	--									ProjectID
	--							FROM
	--									AVL.MAS_ProjectDebtDetails PDD
	--							WHERE
	--									PDD.IsAutoClassified='Y'
	--							AND
	--									PDD.IsMLSignOff='1'
	--							AND 
	--									PDD.IsDeleted=0
	--							)

END
ELSE
BEGIN
	
	SELECT
			DISTINCT BC.BusinessClusterMapID,BC.BusinessClusterBaseName 
	FROM
			AVL.APP_MAP_ApplicationProjectMapping APM
	JOIN
			AVL.APP_MAS_ApplicationDetails AD
	ON	
			APM.ApplicationID=AD.ApplicationID
	 JOIN
			AVL.BusinessClusterMapping BC
	ON		 
			AD.SubBusinessClusterMapID=BC.BusinessClusterMapID 
	WHERE 
			BC.IsHavingSubBusinesss=0 
	AND
			 BC.IsDeleted=0 
	AND
			AD.IsActive=1
	AND 
			BC.CustomerID=@CustomerID
	AND
			APM.ProjectID = @ProjectId
	AND 
			APM.IsDeleted=0;
			

	--SELECT
	--		 DISTINCT BC.BusinessClusterMapID,BusinessClusterBaseName 
	--FROM 
	--		AVL.APP_MAS_ApplicationDetails AD
	--JOIN		 			
	--		 AVL.BusinessClusterMapping BC
	--ON		 
	--		AD.SubBusinessClusterMapID=BC.BusinessClusterMapID 
	--JOIN
	--		AVL.MAS_LoginMaster CM	
	--ON 
	--		CM.CustomerId=BC.CustomerID
	--WHERE 
	--		BC.IsHavingSubBusinesss=0 
	--AND
	--		 BC.IsDeleted=0 
	--AND
	--		AD.IsActive=1
	--AND
	--		CM.EmployeeID=@EmployeeID
	--AND 
	--		BC.CustomerID=@CustomerID
	--AND 
	--		CM.CustomerID=@CustomerID
	--AND
	--		CM.ProjectID IN 
	--						(
	--							SELECT
	--									ProjectID
	--							FROM
	--									AVL.MAS_ProjectDebtDetails PDD
	--							WHERE
	--									PDD.IsAutoClassified='Y'
	--							AND
	--									PDD.IsMLSignOff='1'
	--							AND 
	--									PDD.IsDeleted=0
	--							)


END
		END TRY  
/*----------------------------------END TRY--------------------------------*/

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError 'CL_GetDropDownValuesProjectPortfolio', @ErrorMessage, @EmployeeID, @CustomerID 
		
	END CATCH  
	END
