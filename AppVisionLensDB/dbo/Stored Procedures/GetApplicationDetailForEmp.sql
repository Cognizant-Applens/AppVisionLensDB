/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


--[dbo].[GetApplicationDetailForEmp]  '471742',7097
CREATE Proc [dbo].[GetApplicationDetailForEmp]  --'627384',7

@EmployeeID nvarchar(max),

@CustomerID bigint

AS

BEGIN

BEGIN TRY
BEGIN TRAN

SELECT DISTINCT 

--app.ApplicationID,appuser.ApplicationID

AD.ApplicationID,AD.ApplicationName

,PM.ProjectID,PM.Projectname,ISNULL(LM.TimeZoneId,0) AS UserTimeZoneId,TZM.TZoneName AS UserTimeZoneName,
ISNULL(PC.TimeZoneId,32) AS ProjectTimeZoneId,TZM1.TZoneName AS ProjectTimeZoneName

FROM AVL.MAS_Loginmaster LM WITH(NOLOCK)

INNER JOIN AVL.APP_MAP_ApplicationProjectMapping APP WITH(NOLOCK) ON LM.ProjectID=APP.ProjectID and APP.IsDeleted=0
INNER JOIN AVL.APP_MAS_ApplicationDetails AD WITH(NOLOCK) ON APP.ApplicationID=AD.ApplicationID 

INNER join AVL.MAS_ProjectMaster PM WITH(NOLOCK) ON PM.projectid=lm.projectid 
LEFT join AVL.MAS_TimeZoneMaster TZM WITH(NOLOCK) on ISNULL(LM.TimeZoneId,0)=TZM.TimeZoneID
LEFT JOIN AVL.MAP_ProjectConfig PC WITH(NOLOCK) ON PM.ProjectID=PC.ProjectID 
LEFT join AVL.MAS_TimeZoneMaster TZM1 WITH(NOLOCK) on   ISNULL(PC.TimeZoneID,32)=TZM1.TimeZoneId
WHERE LM.EmployeeID=@EmployeeID AND LM.CustomerID=@CustomerID AND ISNULL(LM.IsDeleted,0)=0 

AND AD.IsActive=1 AND APP.IsDeleted=0
AND ISNULL(PM.IsDeleted,0)=0
-- AND APPUSER.IsDeleted=0


COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'dbo.GetApplicationDetailForEmp', @ErrorMessage, @EmployeeID ,@CustomerID
		
	END CATCH  

END
