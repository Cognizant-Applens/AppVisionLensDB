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
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- EXEC AVL.USP_GetCTSAccountDetails '587567'
-- EXEC AVL.USP_GetCTSAccountDetails '473172'
CREATE PROCEDURE [AVL].[USP_WorkEffort_GetCTSAccountDetails]
	-- Add the parameters for the stored procedure here
	@AssociateID VARCHAR(100),
	@isCognizant varchar(10)=1
AS
BEGIN
--SET @AssociateID  = '622764'
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- SELECT statements for procedure here
		SELECT
		--DISTINCT 
			CAST(BU.BusinessUnitID AS INT) as BUID,
			BU.BusinessUnitName AS BUName, 
			CAST(C.CustomerID AS INT) AS AccountID, 
			C.CustomerName AS AccountName, 
			CAST(P.ProjectID AS INT) AS ProjectID, 
			P.ProjectName AS ProjectName, 
			C.IsCognizant
		INTO 
			#AccountDetails
		FROM
			[AVL].[EmployeeCustomerMapping] EM
		INNER JOIN 
			[AVL].[EmployeeRoleMapping] RM 
		ON
			RM.EmployeeCustomerMappingID = EM.Id AND RM.RoleID IN (2,3,4,8)
		INNER JOIN 
			AVL.Customer C
		ON
			EM.CustomerID= C.CustomerID 
		INNER JOIN
			[AVL].[EmployeeProjectMapping] PM
		ON
			PM.EmployeeCustomerMappingID = EM.Id
		INNER JOIN
			AVL.MAS_ProjectMaster P
		ON
			P.ProjectID = PM.ProjectID 		
		INNER JOIN
			[MAS].[BusinessUnits] BU
		ON
			BU.BusinessUnitID = C.BusinessUnitID
		WHERE 
			EM.EmployeeID = @AssociateID --AND PM.ProjectId = 178

		SELECT
		DISTINCT BUID, BUName
		FROM
			#AccountDetails
		
		SELECT
		DISTINCT BUID, AccountID,AccountName,IsCognizant
		FROM
			#AccountDetails
			
		SELECT
		DISTINCT ProjectID,ProjectName
		FROM
			#AccountDetails
			
END
