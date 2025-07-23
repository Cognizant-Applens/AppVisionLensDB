/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[dbo].[GetApplicationsDetails]  '627119'
--[dbo].[GetApplicationsDetails]  '627134'
CREATE PROCEDURE [dbo].[GetApplicationsDetails] 
@EmployeeID nvarchar(50)
AS
BEGIN
BEGIN TRY

DECLARE @CustomerID INT;
DECLARE @IsCognizantID INT;
SET @CustomerID=(SELECT top 1 CustomerID FROM AVL.MAS_LoginMaster WHERE EmployeeID=@EmployeeID AND IsDeleted=0)
SET @IsCognizantID=(SELECT top 1 IsCognizant FROM AVL.Customer WHERE CustomerID=@CustomerID AND IsDeleted=0)
print @IsCognizantID
IF @IsCognizantID=1
	BEGIN

		SELECT distinct AD.ApplicationID,AD.ApplicationName from [AVL].[APP_MAS_ApplicationDetails] AD
		INNER join [AVL].[APP_MAP_ApplicationUserMapping] AUP ON AD.ApplicationID=AUP.ApplicationID
		INNER join [AVL].[MAS_LoginMaster] LM ON AUP.UserID=LM.UserId AND LM.IsDeleted=0
		INNER JOIN AVL.APP_MAP_ApplicationProjectMapping APM ON APM.ApplicationID=AUP.ApplicationID 
		AND  LM.ProjectID=APM.ProjectID AND APM.IsDeleted=0
		 where LM.EmployeeID=@EmployeeID

	 END
 ELSE
	 BEGIN
		SELECT distinct AD.ApplicationID,AD.ApplicationName FROM [AVL].[APP_MAS_ApplicationDetails] AD
		INNER JOIN AVL.BusinessClusterMapping BCM
		ON AD.SubBusinessClusterMapID=BCM.BusinessClusterMapID AND BCM.IsDeleted=0
		WHERE BCM.CustomerID=@CustomerID and ad.IsActive=1
	 END
	 END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[GetApplicationsDetails]  ', @ErrorMessage, 0,@EmployeeID
		
	END CATCH  



END


--UPDATE AVL.APP_MAS_ApplicationDetails SET IsActive=0 WHERE ApplicationID IN(10140,10141)
