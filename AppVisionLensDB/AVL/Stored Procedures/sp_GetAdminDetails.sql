/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[sp_GetAdminDetails] 
(  
@projectid INT ,
@CustomerID bigint 
)  
AS  
	BEGIN 

	select distinct( case when TSApproverID is not null and TSApproverID <> '0' and TSApproverID<>'' then TSApproverID else HcmSupervisorID END) as EmpID into #Temp from avl.MAS_LoginMaster 
where ((TSApproverID is not null and TSApproverID <> '0' and TSApproverID<>'') or (HCMSupervisorID is not null and HCMSupervisorID <> '0' and HCMSupervisorID<>'')) and  ProjectID = @ProjectID 
 --and CustomerID=@CustomerID 
		--(select distinct(HCMSupervisorID) as EmpID into #Temp from [AVL].[MAS_LoginMaster] 
		--where (HCMSupervisorID is not null and HCMSupervisorID <> 0 and HCMSupervisorID<>'') and ProjectID = @ProjectID and CustomerID=@CustomerID and IsDeleted=0  )

		--Union
		
		--(select distinct(TSApproverID) from [AVL].[MAS_LoginMaster] 
		--where (TSApproverID is not null and TSApproverID <> 0 and TSApproverID<>'') and ProjectID = @ProjectID and CustomerID=@CustomerID and IsDeleted=0  )

	SET NOCOUNT ON; 
		SELECT 
		distinct  
			EmployeeID,  
			EmployeeName,
			EmployeeEmail
			--GradeID    
		FROM [AVL].[MAS_LoginMaster] LM
		WHERE 
		--LM.ProjectID=@ProjectID and LM.CustomerID=@CustomerID and
		LM.Isdeleted=0 and EmployeeID in (select EmpID from  #Temp)
		
		drop Table #Temp
	SET NOCOUNT OFF;  
	END
