/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ADM_GetMailCCDetails] 
   @ProjectId  BigINT,
   @UserId  NVarchar(50)
AS
SET NOCOUNT ON;  
  BEGIN
      BEGIN try
  
			DECLARE @tempCCList VARCHAR(500)
			DECLARE @tempToList VARCHAR(500)
			DECLARE @employeeMail VARCHAR(500)
	
          SELECT  distinct Lm.EmployeeEmail into #Emails
            from AVL.MAS_LoginMaster LM
	       -- join avl.UserRoleMapping URM on LM.EmployeeID = URM.EmployeeID AND LM.isdeleted=0
		   join [RLE].[VW_UserRoleMappingDataAccess] URM on LM.EmployeeID = URM.AssociateId AND LM.isdeleted=0
		   inner join MAS.RLE_Roles Rol on Rol.ApplensRoleID=URM.ApplensRoleID and Rol.RoleKey='RLE005'
		   where URM.ProjectID = @ProjectId and LM.isdeleted = 0 
		   and URM.AssociateId != @UserId

		select  @tempCCList = COALESCE(@tempCCList+';', '')+ EmployeeEmail 
		from #Emails

		select top 1 @employeeMail =  EmployeeEmail From AVL.MAS_LoginMaster where EmployeeID=@UserId

		select distinct PM.EsaProjectID,Pm.ProjectName, @employeeMail as 'EmployeeEmail', '' as CCList --ISNULL(@tempCCList,'') as CCList 
		from avl.MAS_ProjectMaster PM 
	    where PM.projectid = @ProjectId and PM.IsDeleted=0
       
	   IF Object_id('tempdb..#Emails', 'U') IS NOT NULL
            BEGIN
                DROP TABLE #Emails
            END 
      END try

      BEGIN catch
          DECLARE @Message VARCHAR(2000);

          SELECT @Message = Error_message()
          --INSERT Error    
           EXEC AVL_InsertError '[AVL].[ADM_GetMailCCDetails]', @Message,@UserId,@ProjectID
      END catch
  END
