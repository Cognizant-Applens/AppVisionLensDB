/***************************************************************************      
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET      
*Copyright [2018] – [2021] Cognizant. All rights reserved.      
*NOTICE: This unpublished material is proprietary to Cognizant and      
*its suppliers, if any. The methods, techniques and technical      
  concepts herein are considered Cognizant confidential and/or trade secret information.       
        
*This material may be covered by U.S. and/or foreign patents or patent applications.       
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.      
***************************************************************************/      
      
-- =============================================      
-- author:        
-- create date:       
-- Modified by : 835658      
-- Modified For: RHMS CR      
-- description:      
-- =============================================      
CREATE PROCEDURE [PP].[SaveApplicationAttributes]        
      
(      
@applicationid bigint,      
@applicationname nvarchar(100),      
@applicationcode nvarchar(50),      
@applicationshortname nvarchar(8),      
@businesscriticalityid bigint,      
@codeownership bigint,      
@primarytechnologyid bigint,      
@productmarketname nvarchar(200),      
@applicationcommisiondate datetime,      
@regulatorycompliantid bigint,      
@applicationdescription nvarchar(200),      
@debtcontrolscopeid bigint,      
@username nvarchar(50),      
@businessclusterid bigint,      
@OtherPrimaryTechnology nvarchar(100),      
@isupdate bit,      
@projectid bigint,      
@appid bigint output      
)      
      
as      
begin      
begin try      
declare @count bigint;      
declare @prjcustomerid bigint=0;      
declare @projectcount bigint=0;      
      
IF(@debtcontrolscopeid=0)      
BEGIN      
SET @debtcontrolscopeid=NULL      
END      
      
select  @prjcustomerid=customerid from avl.businessclustermapping      
where businessclustermapid=@businessclusterid;      
      
if @isupdate =1 and @applicationid>0      
begin      
      
 select       
   @count=1      
 from       
   avl.app_mas_applicationdetails      
 where      
   applicationid=@applicationid;      
      
   if @count is not null and @count=1        
        
     begin      
      
      if exists(select  1 from avl.app_mas_applicationdetails ad with(nolock) join avl.businessclustermapping bcm with(nolock) on bcm.businessclustermapid=ad.subbusinessclustermapid      
      where applicationname = (ltrim(rtrim(@applicationname))) and bcm.customerid=@prjcustomerid and bcm.isdeleted=0 and ad.ApplicationID=@applicationid)      
      begin      
      update avl.app_mas_applicationdetails       
      set      
       applicationname=ltrim(rtrim(@applicationname)),      
       applicationcode=ltrim(rtrim(@applicationcode)),      
       subbusinessclustermapid=@businessclusterid,      
       applicationshortname=ltrim(rtrim(@applicationshortname)),      
       businesscriticalityid=@businesscriticalityid,      
       codeownership=@codeownership,      
       primarytechnologyid=@primarytechnologyid,      
       productmarketname=ltrim(rtrim(@productmarketname)),      
       applicationcommisiondate=@applicationcommisiondate,      
       regulatorycompliantid=@regulatorycompliantid,      
       applicationdescription=@applicationdescription,      
       debtcontrolscopeid=@debtcontrolscopeid,      
       modifiedby=@username,      
       modifieddate=getdate(),      
       OtherPrimaryTechnology=ltrim(rtrim(@OtherPrimaryTechnology))      
      
      where      
       applicationid=@applicationid;      
      set @appid=0;           
      end      
     end      
end      
      
else if not exists(select  1 from avl.app_mas_applicationdetails ad with(nolock)      
join avl.businessclustermapping bcm with(nolock) on bcm.businessclustermapid=ad.subbusinessclustermapid      
 where applicationname = (ltrim(rtrim(@applicationname))) and bcm.customerid=@prjcustomerid and bcm.isdeleted=0)      
begin      
 /***progress****/      
      
   if exists(      
   select       
     1       
   from       
     avl.prj_configurationprogress       
   where       
     screenid=1 and customerid=@prjcustomerid)       begin      
    if not exists(      
    select 1 from avl.app_mas_applicationdetails ad with(nolock) join avl.businessclustermapping bc with(nolock)      
    on bc.businessclustermapid=ad.subbusinessclustermapid where bc.customerid=@prjcustomerid and bc.isdeleted=0      
    )      
     begin      
     update avl.prj_configurationprogress set completionpercentage=75,      
     modifiedby=@username,      
     modifieddate=getdate()      
     where customerid=@prjcustomerid and screenid=1      
     end      
   end      
      
/***progress****/      
      
     insert       
      into      
        avl.app_mas_applicationdetails      
        (applicationname,      
        applicationcode,      
        applicationshortname,      
        subbusinessclustermapid,      
        codeownership,      
        businesscriticalityid,      
        primarytechnologyid,      
        applicationdescription,      
        productmarketname,      
        applicationcommisiondate,      
        regulatorycompliantid,      
        debtcontrolscopeid,      
        isactive,      
        createdby,      
        createddate,      
        OtherPrimaryTechnology)      
      values      
        (ltrim(rtrim(@applicationname)),      
        ltrim(rtrim(@applicationcode)),      
        ltrim(rtrim(@applicationshortname)),      
        @businessclusterid,      
        @codeownership,      
        @businesscriticalityid,      
        @primarytechnologyid,      
        @applicationdescription,      
        ltrim(rtrim(@productmarketname)),      
        @applicationcommisiondate,      
        @regulatorycompliantid,      
        @debtcontrolscopeid,      
        1,      
        @username,      
        getdate(),      
        ltrim(rtrim(@OtherPrimaryTechnology))      
        );      
     set @appid=scope_identity()      
/*project-application*/      
      
      
if @prjcustomerid >0       
begin       
      
--select       
      
--  @projectcount=count (distinct ecpm.projectid)      
--   from       
--   [avl].[vw_employeecustomerprojectrolebumapping]  ecpm      
--   -- avl.employeecustomermapping evm with(nolock)       
--   --join avl.employeeprojectmapping epm with(nolock) on epm.employeecustomermappingid=evm.id      
--   join avl.mas_projectmaster pm with(nolock) on pm.projectid=ecpm.projectid      
--   where       
--    ecpm.customerid=@prjcustomerid and pm.customerid=@prjcustomerid and pm.isdeleted=0      
/*projectmapping***/      
      
--if @projectcount>0      
--begin      
if not exists(select  1 from avl.app_map_applicationprojectmapping ap where ap.projectid=@projectid and ap.applicationid=@applicationid)      
begin      
      
insert       
    into       
      avl.app_map_applicationprojectmapping       
      (      
      projectid      
      ,applicationid      
      ,isdeleted      
      ,createdby      
      ,createddate)      
      values      
      (      
      @projectid,      
      @appid,      
      0,      
      @username,      
      getdate()      
      );      
/***progress****/      
      
--if exists(      
--   select       
--     1       
--   from       
--     avl.prj_configurationprogress with(nolock)      
--   where       
--     screenid=1 and customerid=@prjcustomerid)      
--begin      
      
      
-- update avl.prj_configurationprogress set completionpercentage=100,      
-- modifiedby=@username,      
-- modifieddate=getdate()      
-- where customerid=@prjcustomerid and screenid=1      
--end      
      
      
/***progress****/      
      
        
end      
end      
      
/***project mapping*****/      
--end      
      
      
/******************/      
end      
      
        
end try      
begin catch      
      
 DECLARE @ErrorMessage VARCHAR(MAX);      
      
 SELECT @ErrorMessage = ERROR_MESSAGE()      
      
 --INSERT Error      
      
 EXEC AVL_InsertError 'AVL.APP_INV_SaveApplicationAttributes',@ErrorMessage,0,0      
         
end catch      
end
