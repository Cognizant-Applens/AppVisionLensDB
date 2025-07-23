/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- [AVL].[Effort_GetProjectBasedApplicationDetails] '471742',48
--[AVL].[Effort_GetProjectBasedApplicationDetails]  '627119',4 
CREATE PROCEDURE [AVL].[Effort_GetProjectBasedApplicationDetails] 

@EmployeeID NVARCHAR(MAX),
@ProjectID int
AS
BEGIN
BEGIN TRY
DECLARE @CustomerID INT;
DECLARE @IsCognizantID INT;
SET @CustomerID=(SELECT CustomerID FROM AVL.MAS_LoginMaster WHERE EmployeeID=@EmployeeID AND IsDeleted=0)
SET @IsCognizantID=(SELECT IsCognizant FROM AVL.Customer WHERE CustomerID=@CustomerID)

IF @IsCognizantID=1

BEGIN
	select distinct LM.EmployeeID,LM.EmployeeName,PM.ProjectID,PM.ProjectName,AD.ApplicationID,Ad.ApplicationName
	from  [AVL].[MAS_LoginMaster] LM 
	join [AVL].[MAS_ProjectMaster] PM on LM.ProjectID=PM.ProjectID 
	join [AVL].[APP_MAP_ApplicationProjectMapping] APM on APM.ProjectID=PM.ProjectID AND APM.IsDeleted=0
	join [AVL].[APP_MAS_ApplicationDetails] AD on APM.ApplicationID=AD.ApplicationID
	--where PM.ProjectID=@ProjectID
	where  LM.UserID in (select UserID from  [AVL].[MAS_LoginMaster] 
	where ProjectID=@ProjectID AND EmployeeID=@EmployeeID and LM.IsDeleted=0)
END
ELSE
BEGIN
		SELECT  distinct LM.EmployeeID,LM.EmployeeName,PM.ProjectID,PM.ProjectName,AD.ApplicationID,Ad.ApplicationName from [AVL].[MAS_ProjectMaster] PM
		INNER JOIN AVL.Customer C ON PM.CustomerID=C.CustomerID AND PM.IsDeleted=0 AND C.IsDeleted=0
		INNER JOIN AVL.BusinessClusterMapping BCM ON BCM.CustomerID=C.CustomerID AND BCM.IsHavingSubBusinesss=0 AND BCM.IsDeleted=0
		INNER JOIN AVL.APP_MAS_ApplicationDetails AD ON AD.SubBusinessClusterMapID = BCM.BusinessClusterMapID AND AD.IsActive=1
		INNER JOIN AVL.MAS_LoginMaster LM ON PM.ProjectID=LM.ProjectID
		WHERE LM.EmployeeID=@EmployeeID  AND  LM.IsDeleted=0



END
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_GetProjectBasedApplicationDetails] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  
END
