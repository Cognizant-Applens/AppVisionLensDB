/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetAccountLevelWithProjectFilterApplicationDetails](
@EsaAccountID VARCHAR(max),
@EsaProjectID NVARCHAR(50),
@UserId VARCHAR(20)
)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;
DECLARE @AccountID BIGINT

IF((@EsaAccountID is not null and @EsaAccountID !='') and @EsaProjectID is not null and @EsaProjectID !='')
BEGIN 

SET @AccountID=(select top 1 CustomerID from [AVL].[Customer] where [ESA_AccountID]= @EsaAccountID and  IsDeleted=0) 

SELECT C.ESA_AccountID,C.CustomerID,C.CustomerName,
PM.EsaProjectID,PM.ProjectID,PM.ProjectName,
LOB.BusinessClusterMapID As LOB_BusinessClusterMapID,LOB.BusinessClusterID As LOB_BusinessClusterID ,
LOB.ParentBusinessClusterMapID As LOB_ParentBusinessClusterMapID,LOB.BusinessClusterBaseName AS LOB,
TRK.BusinessClusterMapID As TRK_BusinessClusterMapID,TRK.BusinessClusterID As TRK_BusinessClusterID ,
TRK.ParentBusinessClusterMapID As TRK_ParentBusinessClusterMapID,TRK.BusinessClusterBaseName AS TRACK,
APPGRP.BusinessClusterMapID As APPGRP_BusinessClusterMapID,APPGRP.BusinessClusterID As APPGRP_BusinessClusterID ,
APPGRP.ParentBusinessClusterMapID As APPGRP_ParentBusinessClusterMapID,APPGRP.BusinessClusterBaseName AS APPGROUP,
AD.ApplicationID, AD.ApplicationName,AD.ApplicationShortName
FROM AVL.Customer(NOLOCK) C
INNER JOIN AVL.BusinessCluster(NOLOCK) BC 
ON C.CustomerID=BC.CustomerID
INNER JOIN AVL.BusinessClusterMapping (NOLOCK) LOB
ON BC.BusinessClusterID=LOB.BusinessClusterID
INNER JOIN AVL.BusinessClusterMapping (NOLOCK) TRK ON TRK.ParentBusinessClusterMapID = LOB.BusinessClusterMapID 
AND  LOB.ParentBusinessClusterMapID IS NULL 
INNER JOIN AVL.BusinessClusterMapping (NOLOCK) APPGRP ON APPGRP.ParentBusinessClusterMapID = TRK.BusinessClusterMapID 
AND APPGRP.IsHavingSubBusinesss = 0
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON AD.SubBusinessClusterMapID=APPGRP.BusinessClusterMapID 
INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.CustomerID=C.CustomerID
INNER JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM ON APM.ApplicationID=AD.ApplicationID AND PM.ProjectID=apm.ProjectID
WHERE AD.IsActive=1 AND APM.IsDeleted=0 AND PM.IsDeleted=0 AND C.ESA_AccountID=@EsaAccountID AND PM.EsaProjectID=@EsaProjectID

END
ELSE
BEGIN
SET @AccountID=0

SELECT C.ESA_AccountID,C.CustomerID,C.CustomerName,
PM.EsaProjectID,PM.ProjectID,PM.ProjectName,
LOB.BusinessClusterMapID As LOB_BusinessClusterMapID,LOB.BusinessClusterID As LOB_BusinessClusterID ,
LOB.ParentBusinessClusterMapID As LOB_ParentBusinessClusterMapID,LOB.BusinessClusterBaseName AS LOB,
TRK.BusinessClusterMapID As TRK_BusinessClusterMapID,TRK.BusinessClusterID As TRK_BusinessClusterID ,
TRK.ParentBusinessClusterMapID As TRK_ParentBusinessClusterMapID,TRK.BusinessClusterBaseName AS TRACK,
APPGRP.BusinessClusterMapID As APPGRP_BusinessClusterMapID,APPGRP.BusinessClusterID As APPGRP_BusinessClusterID ,
APPGRP.ParentBusinessClusterMapID As APPGRP_ParentBusinessClusterMapID,APPGRP.BusinessClusterBaseName AS APPGROUP,
AD.ApplicationID, AD.ApplicationName,AD.ApplicationShortName
FROM AVL.Customer(NOLOCK) C
INNER JOIN AVL.BusinessCluster(NOLOCK) BC 
ON C.CustomerID=BC.CustomerID
INNER JOIN AVL.BusinessClusterMapping (NOLOCK) LOB
ON BC.BusinessClusterID=LOB.BusinessClusterID
INNER JOIN AVL.BusinessClusterMapping (NOLOCK) TRK ON TRK.ParentBusinessClusterMapID = LOB.BusinessClusterMapID 
AND  LOB.ParentBusinessClusterMapID IS NULL 
INNER JOIN AVL.BusinessClusterMapping (NOLOCK) APPGRP ON APPGRP.ParentBusinessClusterMapID = TRK.BusinessClusterMapID 
AND APPGRP.IsHavingSubBusinesss = 0
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON AD.SubBusinessClusterMapID=APPGRP.BusinessClusterMapID 
INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.CustomerID=C.CustomerID
INNER JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM ON APM.ApplicationID=AD.ApplicationID AND PM.ProjectID=apm.ProjectID
WHERE AD.IsActive=1 AND APM.IsDeleted=0 AND PM.IsDeleted=0

END

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetAccountLevelWithProjectFilterApplicationDetails]',@ErrorMessage,@UserId,@AccountID
		
	END CATCH  
END
