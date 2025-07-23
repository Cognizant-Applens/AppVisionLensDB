/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--SELECT * FROM AVL.MAS_LoginMaster(NOLOCK) WHERE ProjectID IN(6944,7588)
-- AND ClientUserID='' and IsDeleted=0

-- SELECT * FROM AVL.MAS_LoginMaster(NOLOCK) WHERE EmployeeID='206520'

--EXEC AVL.Update_LoginMaster
CREATE PROCEDURE AVL.Update_LoginMaster
as
BEGIN
--SELECT * INTO  #DataMigration_Projects FROM DataMigration_Projects
CREATE TABLE #DataMigration_Projects
(
ID BIGINT IDENTITY(1,1) ,
CustomerID BIGINT,
ESA_AccountID BIGINT,
CustomerName NVARCHAR(500),
ProjectID BIGINT,
EsaProjectID NVARCHAR(100),
ProjectName NVARCHAR(1000)
)
INSERT INTO  #DataMigration_Projects
 SELECT CustomerID,ESA_AccountID,CustomerName,ProjectID,EsaProjectID,ProjectName FROM DataMigration_Projects


DECLARE @MinID INT;
DECLARE @MaxID INT;
SET @MinID =(SELECT MIN(ID) FROM #DataMigration_Projects)
SET @MaxID =(SELECT MAX(ID) FROM #DataMigration_Projects)

WHILE @MinID <= @MaxID
	BEGIN
		DECLARE @CustomerID BIGINT;
		SET @CustomerID=(SELECT CustomerID FROM #DataMigration_Projects WHERE ID=@MinID);
		SELECT @CustomerID AS CustomerID
		
		SELECT * FROM AVL.MAS_LoginMaster(NOLOCK) WHERE CustomerID=@CustomerID





		SET @MinID=@MinID+1;

	END
END

--SELECT * FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE CustomerID=6597
