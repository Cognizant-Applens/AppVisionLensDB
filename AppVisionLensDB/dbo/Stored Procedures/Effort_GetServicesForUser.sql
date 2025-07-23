/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[Effort_GetServicesForUser] --4,'627384'
@ProjectID int=null,
@EmployeeID nvarchar(max)=null
as 
begin
BEGIN TRY
select
DISTINCT SPM.ServiceID,SPM.ServiceName from AVL.TK_PRJ_ServiceProjectMapping SPM

inner join [AVL].[MAS_LoginMaster] LM on Isnull(SPM.Servicelevelid,0)=Isnull(LM.Servicelevelid,0) and SPM.ProjectID=LM.projectid
where SPM.ProjectID=@ProjectID and LM.EmployeeID=@EmployeeID 

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[Effort_GetServicesForUser] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  



end
