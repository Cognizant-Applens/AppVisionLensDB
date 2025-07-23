/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ADM].[GetSharepathUploadProject]       
AS        
BEGIN        
BEGIN TRY         
	 SELECT EU.ProjectID,pm.EsaProjectID,isnull(cm.IsCognizant,0) AS IsCognizant ,ISNULL(cm.IsEffortTrackActivityWise,1) AS IsEffortTrackActivityWise 
	 FROM ADM.SmartExecutionSharePathDetails AS EU WITH(NOLOCK)
		INNER JOIN AVL.MAS_ProjectMaster PM  WITH(NOLOCK) on PM.ProjectID = EU.ProjectID and pm.IsDeleted = 0
		INNER JOIN AVL.Customer CM  WITH(NOLOCK) on pm.CustomerID = cm.CustomerID and cm.IsDeleted = 0
		INNER JOIN PP.ScopeOfWork SW  WITH(NOLOCK) ON PM.ProjectID = SW.ProjectID 
		Where EU.IsDeleted =0 --AND isnull(eu.IsManualOrAuto,'M')='M' 
			  AND SW.IsApplensAsALM = 0 AND SW.IsDeleted = 0
END TRY 
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[ADM].[[GetSharepathUploadProject]] ', @ErrorMessage,'1' 
    
END CATCH  END
