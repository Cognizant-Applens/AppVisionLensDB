/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE ProcEDURE [AVL].[Effort_GetApplicationDetailsByProjectID]-- 10337
(        
@ProjectID BIGINT  
)  

AS        

BEGIN     

BEGIN TRY   

SET NOCOUNT ON;     



BEGIN    

		SELECT DISTINCT APM.ApplicationID,ApplicationName       

		FROM [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK)

		APM INNER JOIN [AVL].[APP_MAS_ApplicationDetails](NOLOCK) AD ON  APM.ApplicationID=AD.ApplicationId 
		INNER JOIN AVL.MAP_ProjectConfig PC ON PC.ProjectID=APM.ProjectID

		where PC.ProjectID=@ProjectID AND APM.IsDeleted=0 AND AD.IsActive=1
		ORDER BY ApplicationName ASC



END  

SET NOCOUNT OFF;        

END TRY  

BEGIN CATCH  



		DECLARE @ErrorMessage VARCHAR(MAX);



		SELECT @ErrorMessage = ERROR_MESSAGE()



		--INSERT Error    

		EXEC AVL_InsertError '[AVL].[Effort_GetApplicationDetailsByProjectID] ', @ErrorMessage, @projectid ,0

		

	END CATCH   

END
