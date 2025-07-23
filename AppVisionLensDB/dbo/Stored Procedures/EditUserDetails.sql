---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
-- ====================================================================  
-- author:    
-- create date:   
-- Modified by : 686186  
-- Modified For: RHMS CR  
-- description: getting user details using customerID and employeeid  
-- ====================================================================  
--EXEC [dbo].[EditUserDetails] '104559',0,'AuthenticateUser'  
--EXEC [dbo].[EditUserDetails] '104559',7297,'IsExists'  
--EXEC [dbo].[EditUserDetails] '104559',7297,'GetESA'  
CREATE   PROCEDURE [dbo].[EditUserDetails](  
@employeeid varchar(50)=null,  
@customerid bigint=null,  
@mode varchar(50)=null  
)  
as   
begin  
begin try  
  
select top 1 * into #loginmastertemp from avl.mas_loginmaster where employeeid=@employeeid and isdeleted=0  
if(@mode='isexists')  
--if exists(select 1 from avl.userdetails where userid=@userid)  
begin   
if exists(select distinct rm.roleid,rm.rolename,rm.priority   
from   
--[avl].[employeecustomermapping] lm   
--inner join  [avl].[employeerolemapping] urm on lm.id=urm.employeecustomermappingid  
[avl].[vw_employeecustomerprojectrolebumapping] ecpm   
inner join avl.rolemaster rm on rm.roleid=ecpm.roleid  
where ecpm.employeeid=@employeeid and ecpm.customerid=@customerid --and rm.roleid in (1,6)  
)  
begin  
 if exists(select lm.employeeid,lm.employeename,lm.employeeemail,  
 lm.roleid,rm.rolename,bcm.businessclusterbasename from   
 --[avl].[employeecustomermapping] ud  
  #loginmastertemp lm --on lm.employeeid=ud.employeeid  
 --inner join [avl].[employeerolemapping] udr on ud.id=udr.employeecustomermappingid  
 inner join [avl].[vw_employeecustomerprojectrolebumapping] ecpm on lm.employeeid=ecpm.employeeid and lm.customerid=ecpm.customerid  
 inner join avl.rolemaster rm on rm.roleid=ecpm.roleid --and udr.roleid=1  
 left join [avl].[employeesubclustermapping] scm on ecpm.employeeid=scm.employeeid and ecpm.customerid=scm.customerid --scm.employeecustomermappingid=ud.id  
 inner join avl.businessclustermapping bcm on bcm.businessclustermapid=scm.subclusterid  
 where ecpm.employeeid=@employeeid and ecpm.customerid=@customerid and lm.isdeleted=0)  
 begin  
 print 1  
  select lm.employeeid,lm.employeename,lm.employeeemail,  
 lm.roleid,rm.rolename,bcm.businessclusterbasename from   
 --[avl].[employeecustomermapping] ud  
  #loginmastertemp lm --on lm.employeeid=ud.employeeid  
 --inner join [avl].[employeerolemapping] udr on ud.id=udr.employeecustomermappingid  
 inner join [avl].[vw_employeecustomerprojectrolebumapping] ecpm on lm.employeeid=ecpm.employeeid and lm.customerid=ecpm.customerid  
 inner join avl.rolemaster rm on rm.roleid=ecpm.roleid --and udr.roleid=1  
 inner join [avl].[employeesubclustermapping] scm on ecpm.employeeid=scm.employeeid and ecpm.customerid=scm.customerid --scm.employeecustomermappingid=ud.id  
 inner join avl.businessclustermapping bcm on bcm.businessclustermapid=scm.subclusterid  
 where ecpm.employeeid=@employeeid and ecpm.customerid=@customerid and lm.isdeleted=0  
 end  
 else  
 begin  
 print 2  
  
 select distinct lm.employeeid,lm.employeename,lm.employeeemail,  
   rm.roleid,rolename,bcm.businessclusterbasename businessclusterbasename from   
  --[avl].[employeecustomermapping] ud  
    #loginmastertemp lm --on lm.employeeid=ud.employeeid  
  inner join [avl].[vw_employeecustomerprojectrolebumapping] ecpm on lm.employeeid=ecpm.employeeid and lm.customerid=ecpm.customerid  
  --inner join [avl].[employeerolemapping] udr on ud.id=udr.employeecustomermappingid  
  inner join avl.rolemaster rm on rm.roleid=ecpm.roleid   
  left join [avl].[employeesubclustermapping] scm on ecpm.employeeid=scm.employeeid and ecpm.customerid=scm.customerid --scm.employeecustomermappingid=ud.id  
  left join avl.businessclustermapping bcm on bcm.businessclustermapid=scm.subclusterid   
  where ecpm.employeeid=@employeeid and ecpm.customerid=@customerid and lm.isdeleted=0  
 end  
end  
else  
begin  
if exists(select ecpm.employeeid,lm.employeename,lm.employeeemail,  
   rm.roleid,rolename,bcm.businessclusterbasename businessclusterbasename from   
  --[avl].[employeecustomermapping] ud  
      #loginmastertemp lm --on lm.employeeid=ud.employeeid  
  --inner join [avl].[employeerolemapping] udr on ud.id=udr.employeecustomermappingid  
  inner join [avl].[vw_employeecustomerprojectrolebumapping] ecpm on lm.employeeid=ecpm.employeeid and lm.customerid=ecpm.customerid  
  inner join avl.rolemaster rm on rm.roleid=ecpm.roleid   
  left join [avl].[employeesubclustermapping] scm on ecpm.employeeid=scm.employeeid and ecpm.customerid=scm.customerid  --scm.employeecustomermappingid=ud.id  
  left join avl.businessclustermapping bcm on bcm.businessclustermapid=scm.subclusterid   
  where ecpm.employeeid=@employeeid and ecpm.customerid=@customerid and lm.isdeleted=0)  
   
 begin  
 print 3  
  
  select ecpm.employeeid,lm.employeename,lm.employeeemail,  
   rm.roleid,rolename,'' businessclusterbasename from   
  --[avl].[employeecustomermapping] ud  
     #loginmastertemp lm -- on lm.employeeid=ud.employeeid  
  inner join [avl].[vw_employeecustomerprojectrolebumapping] ecpm on lm.employeeid=ecpm.employeeid and lm.customerid=ecpm.customerid  
  --inner join [avl].[employeerolemapping] udr on ud.id=udr.employeecustomermappingid  
  inner join avl.rolemaster rm on rm.roleid=ecpm.roleid    
  where ecpm.employeeid=@employeeid and ecpm.customerid=@customerid and lm.isdeleted=0  
 end  
 else  
 begin  
 print 4  
  
  select lm.employeeid,lm.employeename,lm.employeeemail,  
  '' roleid,'' rolename,'' businessclusterbasename from   
  #loginmastertemp lm   
  --left join [avl].[employeerolemapping] udr on ud.id=udr.employeecustomermappingid  
  --left join avl.rolemaster rm on rm.roleid=udr.roleid   
  where lm.employeeid=@employeeid  and lm.isdeleted=0   
  --and ud.customerid=@customerid  
 end  
end  
  
select distinct ecpm.employeeid,ecpm.customerid,r.roleid,screenid,accessread,accesswrite    
from   [avl].[employeescreenmapping] r   
inner join [avl].[vw_employeecustomerprojectrolebumapping] ecpm on r.employeeid=ecpm.employeeid and r.customerid=ecpm.customerid  
-- inner join [avl].[employeecustomermapping] ud on r.employeecustomermappingid=ud.id    
where ecpm.employeeid=@employeeid and ecpm.customerid=@customerid and r.screenid is not null  
end  
if(@mode='getesa')  
  
select distinct [associate_id] as [userid] , [associate_name] as [username],email_id as [email] from [$(AVMCOEESADB)].[dbo].[GMSPMO_Associate] nolock where associate_id=@employeeid  
  
if(@mode='authenticateuser')  
  
select lm.employeeid,lm.employeename,lm.employeeemail from #loginmastertemp lm   
 where lm.employeeid=@employeeid  
  
  
if not exists(select  c.customerid,c.customername,ecpm.projectid,pm.projectname   
from   
--avl.employeecustomermapping ecm join  
--avl.employeeprojectmapping epm on epm.employeecustomermappingid=ecm.id  
[avl].[vw_employeecustomerprojectrolebumapping] ecpm   
join avl.mas_projectmaster pm on pm.projectid=ecpm.projectid  
join avl.customer c on c.customerid=pm.customerid   
where ecpm.employeeid= @employeeid    
and ecpm.customerid=@customerid)  
begin  
 select c.customerid,c.customername,ecpm.projectid,pm.projectname   
 from   
 --avl.employeecustomermapping ecm join  
 --avl.employeeprojectmapping epm on epm.employeecustomermappingid=ecm.id  
 [avl].[vw_employeecustomerprojectrolebumapping] ecpm   
 join avl.mas_projectmaster pm on pm.projectid=ecpm.projectid  
 join avl.customer c on c.customerid=pm.customerid   
 where ecpm.employeeid= @employeeid    
 --and ecm.customerid=@customerid  
end  
else  
begin  
 select  c.customerid,c.customername,ecpm.projectid,pm.projectname   
 from   
 --avl.employeecustomermapping ecm join  
 --avl.employeeprojectmapping epm on epm.employeecustomermappingid=ecm.id  
 [avl].[vw_employeecustomerprojectrolebumapping] ecpm   
 join avl.mas_projectmaster pm on pm.projectid=ecpm.projectid  
 join avl.customer c on c.customerid=pm.customerid   
 where ecpm.employeeid= @employeeid    
 and ecpm.customerid=@customerid  
end  
    
end try  
begin catch  
  
 DECLARE @ErrorMessage VARCHAR(MAX);  
  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  
 --INSERT Error  
  
 EXEC AVL_InsertError 'dbo.EditUserDetails',@ErrorMessage,0,@customerid  
     
end catch  
end 
