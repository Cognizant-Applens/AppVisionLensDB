/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
  
  
CREATE Procedure InsertUserManagementDetailsNonCognizant   
(       @projectID int,  
        @CustomerID int,  
        @EmployeeID varchar(100),  
        @EmployeeName varchar(100),  
        @EmployeeEmail varchar(100),  
      --  @ClientID varchar(100),  
        @TSApproverID varchar(100)  
      --  @MandatoryHours varchar(100),  
      --  @TimeZoneId int  
  
  
)  
AS  
BEGIN  
declare @result bit;  
SET @EmployeeID = TRIM(@EmployeeID)
  
If exists(select top 1 EmployeeID from avl.MAS_LoginMaster where EmployeeID=@EmployeeID and ProjectID=@projectID) --and IsDeleted=0)  
begin  
set @result=0;  
SELECT @result AS RESULT  
end  
else  
begin  
insert into avl.MAS_LoginMaster(CustomerID,EmployeeID,EmployeeName,EmployeeEmail,TSApproverID,ProjectID,IsDeleted ,MandatoryHours)   
values(@CustomerID,@EmployeeID,@EmployeeName,@EmployeeEmail,@TSApproverID,@projectID,0,0)  
set @result=1  
SELECT @result AS RESULT  
end  
END  
  
  
  
--select * from [AVL].MAS_LoginMaster where EmployeeID='587567'  
