
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROC [dbo].[GetEffortProject]
AS

BEGIN
SET NOCOUNT ON;
BEGIN try 

        SELECT EU.ProjectID,pm.EsaProjectID,eu.SharePathName,isnull(cm.IsCognizant,0) AS IsCognizant 
		,ISNULL(cm.IsEffortTrackActivityWise,1) AS IsEffortTrackActivityWise,ISNULL(CM.IsDaily,0) AS IsDaily from AVL.EffortUploadConfiguration (NOLOCK) AS EU
		INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) on PM.ProjectID = EU.ProjectID and pm.IsDeleted = 0
		INNER JOIN AVL.Customer CM (NOLOCK) on pm.CustomerID = cm.CustomerID and cm.IsDeleted = 0
		where EU.isactive =1 and isnull(eu.EffortUploadType,'M')='A' --and Sharepathname like '%EffortUploadSharePath%'
		--AND PM.EsaProjectID  IN ('1000383377')

END try 



      BEGIN catch 



          DECLARE @ErrorMessage VARCHAR(max); 



          SELECT @ErrorMessage = Error_message() 



          EXEC Avl_inserterror 

            '[dbo].[GetEffortProject] ', 

            @ErrorMessage, 

            '1' 



      END catch 

	  SET NOCOUNT OFF;
END
