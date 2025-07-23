/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_DataMigration_GetSharePathProjectID_FolderAccess]
AS
BEGIN

	DECLARE @CustomerIds NVARCHAR(MAX)
	DECLARE @ESAProjectIds NVARCHAR(MAX)
	
	--SET @CustomerIds = '1223432,1201125,1224804'
	--set @CustomerIds
	--SET @ESAProjectIds = '1000083654,1000171606,1000192711'

	--SELECT Item INTO #AccountID FROM SPLIT(@CustomerIds,',')
	--SELECT Item INTO #ESAProjectIDS FROM SPLIT(@ESAProjectIds,',')

 --   DECLARE @ProjectDetailsITSM TABLE 
	--( 
	--	CustomerID INT,
	--	ProjectID INT
	--)

   -- INSERT INTO @ProjectDetailsITSM
   --    SELECT DA.CustomerID AS CustomerID,
   --           PM.ProjectID  
   --    FROM AVL.MAS_ProjectMaster (NOLOCK) PM
   --    JOIN AVL.Customer (NOLOCK) DA ON DA.CustomerID = PM.CustomerID 
			--AND DA.IsDeleted = 0 AND PM.IsDeleted = 0 
	  -- JOIN DataMigration_Projects(NOLOCK) DP ON PM.EsaProjectID = DP.ESAPROJECTID
			--AND DA.ESA_AccountID = DP.ESA_AccountID
	  ---- JOIN #AccountID acc 
			----ON acc.Item = CAST(DA.ESA_AccountID AS VARCHAR(MAX))
	  ---- JOIN #ESAProjectIDS ESA ON ESA.item = PM.EsaProjectID
	 

	SELECT	TUPC.TicketUploadPrjConfigID, 
			PM.EsaProjectID, 
			TUPC.ProjectID, 
			dbo.fn_DataMigrationGet_ValidUsers (TUPC.TicketSharePathUsers, TUPC.ProjectID, PM.CustomerID) AS TicketSharePathUsers 
	FROM [dbo].[TicketUploadProjectConfiguration] (NOLOCK) TUPC
	JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
		ON TUPC.ProjectID = PM.ProjectID AND PM.IsDeleted = 0 AND PM.IsMigratedFromDART=1
	JOIN AVL.Customer (NOLOCK) cust 
		ON cust.CustomerID = PM.CustomerID AND cust.IsDeleted = 0 AND PM.CustomerID=8760 
	--JOIN @ProjectDetailsITSM prjdet 
	--	ON prjdet.CustomerID = cust.CustomerID AND prjdet.ProjectID = PM.ProjectID

END
