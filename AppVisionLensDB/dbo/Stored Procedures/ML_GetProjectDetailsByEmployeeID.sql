/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[ML_GetProjectDetailsByEmployeeID] 
@EmployeeID nvarchar(50)=null,
@CustomerID nvarchar(50)=null
as
begin
BEGIN TRY

select distinct LM.UserID,LM.[EmployeeID],LM.[ProjectID],PM.ProjectName from [AVL].[MAS_LoginMaster] LM 
join [AVL].[MAS_ProjectMaster] PM ON LM.Projectid=PM.Projectid 
--INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping] AP ON AP.ProjectID = PM.ProjectID
where LM.EmployeeID=@EmployeeID 
--and AP.ISDELETED = 0
AND
 LM.CustomerID = @CustomerID AND LM.IsDeleted=0
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_GetProjectDetailsByEmployeeID]  ', @ErrorMessage, @EmployeeID ,0
		
	END CATCH  
end
