/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[GetHierarchyIL] --'7097','10337'
@CustomerID int,
@ProjectID int
AS  
BEGIN
BEGIN TRY
--Get the lobname,track,appgrp,application details based application project mapping
select b1.BusinessClusterBaseName as LOBName,b1.BusinessClusterMapID as LobID, b2.BusinessClusterBaseName as PortfolioName,b2.BusinessClusterMapID as PortfolioID,
b3.BusinessClusterBaseName as AppgroupName,b3.BusinessClusterMapID as AppgroupID,
AD.ApplicationName,AD.ApplicationID,OS.ApplicationTypeID,PT.PrimaryTechnologyID
from AVL.BusinessClusterMapping b1,AVL.BusinessClusterMapping b2,AVL.BusinessClusterMapping b3,
AVL.APP_MAS_ApplicationDetails AD,AVL.APP_MAP_ApplicationProjectMapping APM,AVL.APP_MAS_OwnershipDetails OS,AVL.APP_MAS_PrimaryTechnology PT
WHERE b1.BusinessClusterMapID=b2.ParentBusinessClusterMapID and
b2.BusinessClusterMapID=b3.ParentBusinessClusterMapID and
AD.SubBusinessClusterMapID=b3.BusinessClusterMapID and
APM.ProjectID=@ProjectID and APM.ApplicationID=AD.ApplicationID and AD.IsActive=1 and APM.IsDeleted=0 and
PT.PrimaryTechnologyID=AD.PrimaryTechnologyID and PT.IsDeleted=0 and
AD.CodeOwnerShip=OS.ApplicationTypeID and OS.IsDeleted=0 and
b1.CustomerID=@CustomerID
and b1.IsDeleted=0 and b2.IsDeleted=0 and b3.IsDeleted=0 
AND AD.ApplicationID NOT IN(SELECT DISTINCT ML.ApplicationID FROM AVL.ML_TRN_MLPatternValidation ML WHERE ML.ProjectID=APM.ProjectID AND ML.ProjectID=@ProjectID AND ML.IsDeleted=0)
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()		
	END CATCH  
END
