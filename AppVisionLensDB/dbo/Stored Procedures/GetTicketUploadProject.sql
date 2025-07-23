/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROC [dbo].[GetTicketUploadProject]
AS

BEGIN
SET NOCOUNT ON;
BEGIN try 


        SELECT EU.ProjectID,pm.EsaProjectID,eu.SharePath as SharePathName,isnull(cm.IsCognizant,0) AS IsCognizant ,ISNULL(cm.IsEffortTrackActivityWise,1) AS IsEffortTrackActivityWise 
		from TicketUploadProjectConfiguration AS EU (NOLOCK)
		INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) on PM.ProjectID = EU.ProjectID and pm.IsDeleted = 0
		INNER JOIN AVL.Customer CM (NOLOCK) on pm.CustomerID = cm.CustomerID and cm.IsDeleted = 0
		where EU.IsDeleted =0 and isnull(eu.IsManualOrAuto,'M')='M' 
		--AND PM.EsaProjectID != '1000442044'

END try 



      BEGIN catch 



          DECLARE @ErrorMessage VARCHAR(max); 



          SELECT @ErrorMessage = Error_message() 



          EXEC Avl_inserterror 

            '[dbo].[GetTicketUploadProject]', 

            @ErrorMessage, 

            '1' 



      END catch 

	  SET NOCOUNT OFF;
END
