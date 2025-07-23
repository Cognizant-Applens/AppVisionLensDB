/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [dbo].[GetProjects] 
@ApplicationID BIGINT,
@EmployeeID VARCHAR(1000)
AS
BEGIN
BEGIN TRY


SELECT distinct PM.ProjectID,PM.ProjectName from [AVL].[MAS_ProjectMaster] PM
INNER JOIN  [AVL].[APP_MAP_ApplicationProjectMapping] AMP ON PM.ProjectID=AMP.ProjectID  
AND PM.IsDeleted=0 
INNER JOIN AVL.MAS_LoginMaster LM ON LM.ProjectID=PM.ProjectID AND LM.IsDeleted=0
INNER JOIN AVL.APP_MAP_ApplicationUserMapping AUM ON AUM.ApplicationID=AMP.ApplicationID
AND AUM.UserID=LM.UserID
where AMP.ApplicationID=@ApplicationID AND LM.EmployeeID=@EmployeeID
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[GetProjects]  ', @ErrorMessage, 0,@EmployeeID
		
	END CATCH  
END



--SELECT * FROM AVL.MAS_ProjectMaster WHERE IsDeleted=0
