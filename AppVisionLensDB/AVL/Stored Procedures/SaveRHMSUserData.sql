/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ==============================================================
-- Author:		201422
-- Create date: 20-Dec-2018
-- Description:	SP is used to update the User Management details
-- ==============================================================
CREATE procedure [AVL].[SaveRHMSUserData]       
@employeeid as varchar(100),      
@username as varchar(100),      
@emailid as varchar(100),      
@customerid as bigint,      
@role as varchar(100),      
@appnames as tvp_apphierarchy readonly,      
@screenroles as tvp_screenaccess_rhms readonly,      
@employeecustomerproject as tvp_projecthierarchy readonly,      
@createdby as varchar(100),      
@mode as varchar(10),    
@isOldRoleApi as bit    
as      
begin 
SET NOCOUNT ON
begin try      
        
--------------------declration section -----------------------      
 declare @projectrole as table      
 (      
  id int identity(1,1),      
  roleid int      
 );      
 declare @id int;      
 declare @roleid as varchar(10);      
 declare @loginUserID as varchar(100)      
 SET @loginUserID =@createdby      
      
 DECLARE @IsCognizant INT      
      
 SELECT @IsCognizant=IsCognizant from AVL.Customer  WHERE CustomerID=@customerid      
      
 select distinct employeeid,projectid,esaprojectid,projectname,customerid,customername,rolename into #KeyInUser      
 from getmappedprojectdetails(@employeeid,@customerid,0)       
      
 select distinct employeeid,projectid,esaprojectid,projectname,customerid,customername into #LogInUser      
 from getmappedprojectdetails(@loginUserID,@customerid,0)      
      
 --select * into #UnCheckedProjects from #LogInUser where projectid not in (select projectid from @employeecustomerproject)      
      
      
 /*===== Deactivating all proxyAdmin and operational roles for LoginUser projects ====*/     
 if(@isOldRoleApi=1)    
 BEGIN    
 UPDATE urm set IsActive=0      
 from AVL.UserRoleMapping urm join #LogInUser LU on urm.AccessLevelID=LU.projectid       
 and urm.AccessLevelSourceID=4 and urm.RoleID in (3,7)      
 WHERE urm.EmployeeID=@employeeid      
 END    
      
      
--------------------declration section ------------------------      
      
-------------------- split the roleids-------------------------      
 insert into @projectrole(roleid)      
 select item from dbo.split(@role,',');      
-------------------- split the roleids-------------------------      
      
-------------------- process the roles-------------------------      
       
 IF EXISTS( select * from @employeecustomerproject)      
 BEGIN      
 IF (@IsCognizant=1 and  @isOldRoleApi=1)      
 BEGIN      
 while (select count(*) from @projectrole) > 0      
 begin      
   select top 1 @id = id,@roleid=roleid from @projectrole;      
         
   merge avl.userrolemapping as target      
   using @employeecustomerproject as source      
   on (target.accesslevelid = source.projectid and target.employeeid=@employeeid       
   and target.roleid =@roleid)      
   when not matched by target then      
   insert (employeeid,roleid,accesslevelsourceid,accesslevelid,isactive,createdby,createddate,modifieddate,datasource)      
   values (@employeeid,@roleid,4, source.projectid,1,'UI',getdate(),getdate(),'UI')      
   when matched then      
   update       
   set       
   target.isactive=1,      
   target.modifieddate=getdate(),      
   target.modifiedby='UI';      
   delete from @projectrole where id=@id;      
 END      
      
 END      
 ELSE IF EXISTS(select * from @appnames)      
 BEGIN      
 IF(@isOldRoleApi=1)    
 BEGIN    
 while (select count(*) from @projectrole) > 0      
 begin      
   select top 1 @id = id,@roleid=roleid from @projectrole;      
         
   merge avl.userrolemapping as target      
   using @employeecustomerproject as source      
   on (target.accesslevelid = source.projectid and target.employeeid=@employeeid       
   and target.roleid =@roleid)      
   when not matched by target then      
   insert (employeeid,roleid,accesslevelsourceid,accesslevelid,isactive,createdby,createddate,modifieddate,datasource)      
   values (@employeeid,@roleid,4, source.projectid,1,'UI',getdate(),getdate(),'UI')      
   when matched then      
   update       
   set       
   target.isactive=1,      
   target.modifieddate=getdate(),      
   target.modifiedby='UI';      
   delete from @projectrole where id=@id;      
 END     
 END    
       
 END       
       
  END      
      
-------------------- process the roles--------------------------      
      
-------------------- process the application hierarchy ----------      
       
      
 delete from @projectrole      
      
 insert into @projectrole(roleid)      
 select item from dbo.split(@role,',');      
      
      
  DELETE ESCM       
  FROM avl.EmployeeSubClusterMapping ESCM      
  --INNER JOIN @appnames App ON       
  WHERE      
  ESCM.EmployeeID=@employeeid      
  AND ESCM.CustomerID = @customerid      
  --AND ESCM.SubClusterId=APP.ApplicationID      
      
  IF EXISTS (select * from @projectrole)      
  BEGIN      
   IF EXISTS(select * from @employeecustomerproject)      
   BEGIN      
   IF EXISTS(select * from @appnames)      
   BEGIN      
     merge avl.employeesubclustermapping as target      
     using @appnames as source      
     on       
     (target.employeeid=@employeeid and target.customerid=@customerid      
     and target.subclusterid=source.applicationid)      
     when not matched by target then      
     insert (employeeid,customerid,subclusterid,createdby,createdon)      
     values (@employeeid,@customerid,source.applicationid,@employeeid,getdate())      
     when matched then      
     update set      
     target.modifiedby = @employeeid,      
     target.modifiedon=getdate();      
    END      
   END      
  END      
 --END      
-------------------- process the application hierarchy ----------      
      
-------------------- process the screen access------------------      
      
    delete avl.employeescreenmapping where EmployeeID=@employeeid and CustomerID=@customerid      
 IF EXISTS (select * from @projectrole )      
 BEGIN      
  IF EXISTS(select * from @employeecustomerproject)      
  BEGIN      
      
   merge avl.employeescreenmapping as target      
   using @screenroles as source      
   on (target.employeeid = @employeeid      
   and target.customerid=@customerid      
   and target.roleid =source.roleid      
   and target.screenid = source.screenid      
   and target.accessread=source.[read]      
   and target.accesswrite=source.write      
   )      
   when not matched by target then      
   insert (employeeid,customerid,screenid,roleid,accessread,accesswrite)      
   values (@employeeid,@customerid,source.screenid, source.roleid,source.[read],source.write);      
  END      
 END      
-------------------- process the screen access-----------------------      
 select 1 as result      
       
      
    SET NOCOUNT OFF    
end try      
begin catch      
      
 DECLARE @ErrorMessage VARCHAR(MAX);      
      
 SELECT @ErrorMessage = ERROR_MESSAGE()      
      
 --INSERT Error      
      
 EXEC AVL_InsertError 'AVL.SaveRHMSUserData',@ErrorMessage,0,@customerid      
         
end catch      
end
