/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[dbo].[GetProjectsByApplicationID] 14,'471742'
--[dbo].[GetProjectsByApplicationID]  1,'471742'
CREATE PROCEDURE [dbo].[GetProjectsByApplicationID]  
@ApplicationID BIGINT,
@EmployeeID VARCHAR(1000)
AS
BEGIN
BEGIN TRY
DECLARE @CustomerID INT;
DECLARE @IsCognizantID INT;
SET @CustomerID=(SELECT top 1 CustomerID FROM AVL.MAS_LoginMaster WHERE EmployeeID=@EmployeeID AND IsDeleted=0)
SET @IsCognizantID=(SELECT top 1 IsCognizant FROM AVL.Customer WHERE CustomerID=@CustomerID)
IF @IsCognizantID=1 AND @ApplicationID >0
	BEGIN
		SELECT distinct PM.ProjectID,PM.ProjectName from [AVL].[MAS_ProjectMaster] PM
		INNER JOIN  [AVL].[APP_MAP_ApplicationProjectMapping] AMP ON PM.ProjectID=AMP.ProjectID  
		AND PM.IsDeleted=0 
		INNER JOIN AVL.MAS_LoginMaster LM ON LM.ProjectID=PM.ProjectID AND LM.IsDeleted=0
		INNER JOIN AVL.APP_MAP_ApplicationUserMapping AUM ON AUM.ApplicationID=AMP.ApplicationID
		AND AUM.UserID=LM.UserID AND AMP.ApplicationID=AUM.ApplicationID
		where AMP.ApplicationID=@ApplicationID AND LM.EmployeeID=@EmployeeID
	END
 ELSE IF @ApplicationID >0
	 BEGIN

	 --	select PM.ProjectID,PM.ProjectName from AVL.APP_MAS_ApplicationDetails AD 
		--INNER JOIN AVL.BusinessClusterMapping BCM on AD.SubBusinessClusterMapID=BCM.BusinessClusterMapID and BCM.IsDeleted=0 and AD.IsActive=1
		--INNER JOIN AVL.MAS_ProjectMaster PM on PM.CustomerID=BCM.CustomerID and PM.IsDeleted=0 and BCM.IsDeleted=0
		--INNER JOIN AVL.MAS_LoginMaster LM on LM.CustomerID=PM.CustomerID and LM.IsDeleted=0
		--where LM.EmployeeID=@EmployeeID and AD.ApplicationID=@ApplicationID

		SELECT distinct PM.ProjectID,PM.ProjectName from [AVL].[MAS_ProjectMaster] PM
		INNER JOIN AVL.Customer C ON PM.CustomerID=C.CustomerID AND PM.IsDeleted=0 AND C.IsDeleted=0
		INNER JOIN AVL.BusinessClusterMapping BCM ON BCM.CustomerID=C.CustomerID AND BCM.IsHavingSubBusinesss=0 AND BCM.IsDeleted=0
		INNER JOIN AVL.APP_MAS_ApplicationDetails AD ON AD.SubBusinessClusterMapID = BCM.BusinessClusterMapID AND AD.IsActive=1
		INNER JOIN AVL.MAS_LoginMaster LM ON PM.ProjectID=LM.ProjectID
		WHERE LM.EmployeeID=@EmployeeID AND AD.ApplicationID=@ApplicationID AND  LM.IsDeleted=0
	 END
	ELSE IF @ApplicationID=0
		BEGIN
		SELECT distinct PM.ProjectID,PM.ProjectName from [AVL].[MAS_ProjectMaster] PM
		INNER JOIN AVL.Customer C ON PM.CustomerID=C.CustomerID AND PM.IsDeleted=0 AND C.IsDeleted=0
			INNER JOIN AVL.MAS_LoginMaster LM ON PM.ProjectID=LM.ProjectID
		WHERE LM.EmployeeID=@EmployeeID  AND  LM.IsDeleted=0
		END
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[GetProjectsByApplicationID] ', @ErrorMessage, 0,@EmployeeID
		
	END CATCH  

END

--SELECT distinct PM.ProjectID,PM.ProjectName from [AVL].[MAS_ProjectMaster] PM
--		INNER JOIN AVL.Customer C ON PM.CustomerID=C.CustomerID AND PM.IsDeleted=0 AND C.IsDeleted=0
--		INNER JOIN AVL.BusinessClusterMapping BCM ON BCM.CustomerID=C.CustomerID AND BCM.IsHavingSubBusinesss=0 AND BCM.IsDeleted=0
--		INNER JOIN AVL.APP_MAS_ApplicationDetails AD ON AD.SubBusinessClusterMapID = BCM.BusinessClusterMapID AND AD.IsActive=1
--		INNER JOIN AVL.MAS_LoginMaster LM ON PM.ProjectID=LM.ProjectID
--		WHERE LM.EmployeeID='471742' AND AD.ApplicationID=10193 AND  LM.IsDeleted=0


--		select * from AVL.Customer where CustomerID=44
--		select * from AVL.MAS_ProjectMaster where CustomerID=44
--		select * from AVL.BusinessClusterMapping where BusinessClusterMapID=414
--		select * from AVL.APP_MAS_ApplicationDetails where ApplicationID=10193

--		select * from AVL.MAS_LoginMaster where ProjectID=42 and EmployeeID='471742'

--SELECT * FROM AVL.MAS_ProjectMaster WHERE IsDeleted=0 AND ProjectID=4

--SELECT * FROM AVL.MAS_LoginMaster WHERE EmployeeID='471742' AND IsDeleted=0 

--SELECT * FROM AVL.APP_MAP_ApplicationProjectMapping WHERE ProjectID<>4
--SELECT * FROM AVL.APP_MAP_ApplicationUserMapping WHERE UserID=7

--INSERT INTO  AVL.APP_MAP_ApplicationUserMapping VALUES(20,1,0,'471742',GETDATE(),NULL,NULL)
--INSERT INTO  AVL.APP_MAP_ApplicationUserMapping VALUES(20,11,0,'471742',GETDATE(),NULL,NULL)
--INSERT INTO  AVL.APP_MAP_ApplicationUserMapping VALUES(20,12,0,'471742',GETDATE(),NULL,NULL)
--INSERT INTO AVL.MAS_LoginMaster  VALUES('471742','471742','DhivyaBharathi','DhivyaBharathi.M@cognizant.com',
--42,44,null,null,null,getdate(),32,
--8,getdate(),null,1,0,1,1,1,getdate(),null,null,null)
