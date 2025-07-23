/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:		 Dhivya        
-- Create Date:  Jan 30 2019
-- Description:  Get the project information and ortfolio name
-- DB Name :     AppVisionlens
-- ============================================================================ 
CREATE PROCEDURE  [AVL].[DD_GetDataDictionaryProjectPortfolio] 

@CustomerID int,
@EmployeeID nvarchar(1000)
AS 
BEGIN
BEGIN TRY

	DECLARE @IsCognizant INT;
	DECLARE @PortfolioName NVARCHAR(1000);
	SET @IsCognizant=(SELECT ISNULL(IsCognizant,0)AS IsCognizant 
					FROM AVL.Customer(NOLOCK) WHERE CustomerID=@CustomerID)

	SELECT DISTINCT PM.ProjectID,PM.ProjectName,PDD.IsDDAutoClassified,PDD.IsTicketApprovalNeeded,PDD.IsManual
	FROM AVL.MAS_ProjectMaster(NOLOCK) PM
	JOIN AVL.MAS_LoginMaster(NOLOCK) LM
	ON LM.ProjectID=PM.ProjectID
    JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDD
	ON PDD.ProjectID=LM.ProjectID
	WHERE LM.CustomerID=@CustomerID	
	AND	EmployeeID=@EmployeeID
	AND LM.IsDeleted=0 
	AND PM.IsDeleted=0
	AND LM.ProjectID IN (SELECT ProjectID FROM AVL.MAS_ProjectDebtDetails(NOLOCK) PDD
								WHERE (PDD.IsDeleted=0 or PDD.IsDeleted is NULL))ORDER BY PM.ProjectName ASC

	IF @IsCognizant='1'
	SET @PortfolioName='AppGroup'
	ELSE
	SET @PortfolioName=(SELECT TOP 1 BusinessClusterName FROM AVL.BusinessCluster(NOLOCK) WHERE CustomerID=@CustomerID AND IsDeleted=0
						AND IsHavingSubBusinesss=0)
	SELECT @PortfolioName AS PortfolioName
		END TRY  

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		  
		EXEC AVL_InsertError '[AVL].[DD_GetDataDictionaryProjectPortfolio]', @ErrorMessage, @EmployeeID, @CustomerID 
		
	END CATCH  
	END
