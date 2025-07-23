/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [AVL].[GetRHMSUserDetails]    
@customerid int,                      
@keyedinuserid varchar(10),                      
@loggedinuserid varchar(10)                      
as                      
begin                      
begin try                      
                      
                      
-- set nocount on added to prevent extra result sets from                      
-- interfering with select statements.                      
set nocount on;                      
                      
-- insert statements for procedure here                      
                       
                      
 declare @userroles as table(                      
 employeeid  varchar(50),                      
 projectid  bigint,                      
 esaprojectid  varchar(100) ,                      
 projectname  varchar(max),                      
 customerid  bigint,                      
 projectadminroles int,                      
 ischecked  bit null default 0,                      
 isdisabled  bit null default 0,                      
 isdeleted bit null default 0,                      
 customername varchar(max),                       
 rolename varchar(max),                      
 datasource  varchar(100)                       
 )                      
                    
        
                      
 declare @iscognizant int=(select iscognizant from avl.customer(NOLOCK) where customerid=@customerid)              
         
 declare @Esacustomerid varchar(50)        
 declare @CustomerName varchar(50)        
         
 select @Esacustomerid=ESA_AccountID,@CustomerName=CustomerName from avl.customer(NOLOCK) where customerid=@customerid        
            
        
 SELECT ApplensRoleID,Associateid,AssociateName,PRA.isdeleted,Trim(PM.ESAProjectid) as ESAprojectid,PM.Projectid,PM.ProjectName,PM.CustomerID,        
  Trim(EsaCustomerId) as EsaCustomerId,RoleName,RoleKey,[Priority],DataSource,          
  Email INTO  #tmpKeyuserroletable FROM RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK) PRA        
  INNER JOIN AVL.MAS_PROJECTMASTER PM (NOLOCK) ON PM.ESAPROJECTID=PRA.ESAPROJECTID and PM.isdeleted=0        
   Where Associateid=@keyedinuserid --and RoleKey in ('RLE003','RLE005')-- proxyadmin,operational        
        
SELECT ApplensRoleID,Associateid,AssociateName,PRA.isdeleted,Trim(PM.ESAProjectid) as ESAprojectid,PM.Projectid,PM.ProjectName, PM.CustomerID,          
  Trim(EsaCustomerId) as EsaCustomerId,RoleName,RoleKey,[Priority],DataSource,           
  Email INTO  #tmploginuserroletable FROM RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK) PRA        
  INNER JOIN AVL.MAS_PROJECTMASTER PM (NOLOCK) ON PM.ESAPROJECTID=PRA.ESAPROJECTID and PM.isdeleted=0        
   Where Associateid=@loggedinuserid and RoleKey in ('RLE005','RLE004') and ESACustomerid=@Esacustomerid -- proxyadmin,admin        
        
                              
                      
 select DISTINCT '' as customerid,Associateid as employeeid,AssociateName as employeename,Email as employeeemail                      
 ,@iscognizant as iscognizant from #tmpKeyuserroletable (NOLOCK) --replaced loginmaster table             
 --and customerid=@customerid              
         
        
                      
  SELECT distinct KR.ApplensRoleID as 'Roleid', KR.rolename,                     
    CASE WHEN KR.isdeleted = 1 THEN 0 ELSE 1 END as isselected,KR.Priority                      
    FROM #tmpKeyuserroletable (NOLOCK) KR         
 Inner Join #tmploginuserroletable (NOLOCK) LR ON KR.ESAProjectId=LR.ESAProjectId        
                       
                    
 --important - need to incorperate a ecm view here                      
                      
                
 SELECT Distinct Associateid as employeeid,projectid,esaprojectid,projectname, customerid,@CustomerName as customername,rolename                      
from #tmpKeyuserroletable (NOLOCK) where ESACustomerId=@Esacustomerid                
                      
                      
 Insert into @userroles                      
 (employeeid,projectid,esaprojectid ,projectname,customerid,projectadminroles,customername,rolename,datasource)                       
 SELECT Distinct AssociateId,projectid,esaprojectid,projectname,customerid,0 as projectadminroles,@CustomerName,rolename,DataSource                      
 FROM #tmploginuserroletable (NOLOCK) LR        
          
        
                      
                       
   update a                      
   set ischecked=1,                      
   isdisabled=0                      
   from @userroles a                    
   INNER JOIN #tmpKeyuserroletable (NOLOCK) b on a.Esaprojectid=b.Esaprojectid and (Rolekey='RLE003' OR Rolekey='RLE005')                     
                                                                      
 --end                      
 delete from @userroles where isdeleted=1;                      
                      
                       
 select distinct employeeid,projectid,esaprojectid,projectname,customerid,projectadminroles,                
 ischecked,isdisabled,customername,'' as rolename                      
 from @userroles                      
 where isdeleted=0                      
    order by projectname asc                      
                      
                      
 -- committing the getmapped function for no need to check that project should have access                      
                      
 ---App Level Hierarchy Data-----                      
 exec [AVL].[GetRHMSHierarchyData] @keyedinuserid,@customerid                      
                       
                      
 ----screen access data-------------                      
 select distinct ESM.employeeid,PRA.customerid,PRA.Applensroleid as 'roleid',screenid,accessread,accesswrite                        
 from   [avl].[employeescreenmapping] (NOLOCK) ESM                            
 INNER JOIN #tmpKeyuserroletable  (NOLOCK) PRA ON ESM.CustomerID=PRA.CustomerID  and ESM.EmployeeID=PRA.Associateid                            
 where ESM.screenid is not null  and PRA.Customerid=@customerid      
     
    
 --ends---------                      
                      
                        
end try                      
begin catch                      
                      
 DECLARE @ErrorMessage VARCHAR(MAX);                      
                      
 SELECT @ErrorMessage = ERROR_MESSAGE()                      
                      
 --INSERT Error                      
                      
 -- EXEC AVL_InsertError 'AVL.GetRHMSUserDetails',@ErrorMessage,0,@customerid                      
                         
end catch                      
end
