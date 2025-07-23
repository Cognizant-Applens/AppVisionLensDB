/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ML_GetRegeneratedApplication] --10337
@ProjectID BIGINT
AS  
BEGIN
BEGIN TRY
--Get the lobname,track,appgrp,application details based application project mapping
select DISTINCT AD.ApplicationName,AD.ApplicationID
from AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
INNER JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) MAP ON MAP.ApplicationID = AD.ApplicationID
AND AD.IsActive=1 AND ISNULL(MAP.IsDeleted,0)=0 AND MAP.ProjectID=@ProjectID 
AND AD.ApplicationID NOT IN(SELECT DISTINCT ML.ApplicationID FROM AVL.ML_TRN_MLPatternValidation ML (NOLOCK) 
WHERE ML.ProjectID=@ProjectID AND ML.IsDeleted=0)
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()		
	END CATCH  
END
