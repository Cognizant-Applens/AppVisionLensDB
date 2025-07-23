CREATE procedure [RLE].[ProjectProfiling]          
as begin          
          
create table #GetAllTileProgressPercentage          
(          
ProjectID nvarchar(100),          
ProjectName  nvarchar(100),          
ProjectDetailCompPerc  nvarchar(100),          
AppInventoryCompPerc  nvarchar(100),          
UserMgmtCompPerc  nvarchar(100),          
ServiceCatalogCompPerc  nvarchar(100),          
AdaptorCompPerc  nvarchar(100)          
          
)          
          
insert into #GetAllTileProgressPercentage (          
ProjectID          
,ProjectName          
,ProjectDetailCompPerc          
,AppInventoryCompPerc          
,UserMgmtCompPerc          
,ServiceCatalogCompPerc          
,AdaptorCompPerc          
) exec [PP].[GetAllTileProgressPercentage]           
          
          
select       
distinct        
a.istransitioninscope ,a.projectid,a.ProjectTypeID      
,B.AttributeValueName,B.AttributeValueID,b.attributeid,k.IsAcceptanceDefined,k.IsVelocityMeasured,k.IsReqBaselined,k.ScopeChangeControlId,    
case when b.attributeid=21 then B.AttributeValueID end as 'TechnicaLDriverID',    
case when b.attributeid=19 then B.AttributeValueID end as 'BuisnessDriverID',   
case when b.attributeid=52 then B.AttributeValueID end as 'DigitalAcceleratorID'    
--,c.attributeid as DeploymentID,c.AttributeValueID as DeploymentValueid       
--,pp.attributeid as subparentID,pp.AttributeValueID as subparentValueid ,pp.AttributeValueName as subparentValueName      
,pp.AttributeValueName as 'ArchettypeName'      
,d.WorkItemSize,d.VendorPresence      
,f.servicename,g.servicetypeid,g.servicetypename      
,i.VendorName,i.vendordetailid,j.OtherFieldValue       
,k.ExternalKEDB,k.ExplicitRisks,KEDBOwnedId,IntegratedServiceId, n.projectshortdescription      
,l.ProjectDetailCompPerc          
,l.AppInventoryCompPerc          
,l.UserMgmtCompPerc          
,l.ServiceCatalogCompPerc       
,l.AdaptorCompPerc       
,pm.esaprojectid,pm.customerid      
into #OveralllData      
from  PP.ScopeOfWork a with (nolock)      
left join  avl.mas_projectmaster pm with (nolock)        
on pm.projectid=a.projectid and pm.IsDeleted = 0 and a.isdeleted=0  
--on pm.projectid in (154) and pm.IsDeleted = 0 and a.isdeleted=0      
left join #GetAllTileProgressPercentage l with (nolock) on l.projectid=a.projectid       
left join PP.BestPractices(NOLOCK) k on K.projectid=a.projectid          
and  k.KEDBOwnedId in (87,88,89,264) and k.IsDeleted = 0       
left join PP.Project_VendorDetails i with (nolock) on i.projectid=a.projectid and i.IsDeleted = 0           
left join PP.OperatingModel d with (nolock) on d.projectid=a.projectid and d.IsDeleted = 0       
left join PP.ProjectAttributeValues C with (nolock)on A.ProjectID = C.ProjectID and c.isdeleted=0 and A.IsDeleted = 0       
left join mas.PPAttributevalues B with (nolock)on c.AttributeValueID = B.AttributeValueID and B.IsDeleted = 0          
left join mas.PPAttributevalues pp with (nolock) on a.ProjectTypeID = pp.AttributeValueID and pp.IsDeleted = 0       
left join AVL.TK_PRJ_ProjectServiceActivityMapping e on e.ProjectID=a.projectid  and e.isdeleted=0        
left join AVL.TK_MAS_ServiceActivityMapping f on f.ServiceMappingID=e.ServiceMapID  and f.isdeleted=0          
left join AVL.TK_MAS_ServiceType g on f.ServiceTypeID=g.ServiceTypeID  and g.isdeleted=0        
 left join PP.OtherAttributeValues j with (nolock) on j.AttributeValueID=b.AttributeValueID  and j.IsDeleted = 0         
left join PP.ProjectDetails n on n.projectid=pm.projectid and n.isdeleted=0    
 
       
       
 --Tools      
 select a.projectid,count(distinct tc.toolid) as 'No:of Tools' into #Tools      
 from #OveralllData a       
 left join ToolsCatalog.[dbo].[ToolAccIDMapping] tc on tc.projectid=a.esaprojectid  and tc.IsDeleted = 0         
 left join ToolsCatalog.dbo.tools t on t.ToolID = tc.toolid  and t.IsDeleted = 0        
 left join ToolsCatalog.dbo.ToolFunctionIDMapping_AccAdmin tfm on tfm.ToolID = tc.toolid and tc.ToolAccountID = tfm.toolaccountid and tfm.isdeleted=0      
  group by a.projectid      
      
 --Service      
      
select a.projectid,count(distinct f.servicename) as 'No:of Service' into #Service      
 from #OveralllData a       
left join AVL.TK_PRJ_ProjectServiceActivityMapping e on e.ProjectID=a.projectid and e.IsDeleted = 0          
left join AVL.TK_MAS_ServiceActivityMapping f on f.ServiceMappingID=e.ServiceMapID    and f.IsDeleted = 0        
group by a.projectid      
      
---Application      
select a.projectid,count(distinct app.applicationid) as 'No:of Application' into #Application      
 from #OveralllData a       
left join [AVL].[APP_MAP_ApplicationProjectMapping] app on app.projectid=a.projectid       
left join AVL.APP_MAs_Applicationdetails m on m.ApplicationID=app.ApplicationID  and m.isactive=1        
group by a.projectid      
      
      
      
--Display with counts      
select a.*,b.[No:of Tools],c.[No:of Service],d.[No:of Application] into #AllCount from #OveralllData a       
left join #Tools b on a.projectid=b.projectid      
left join #Service c on c.projectid=a.projectid      
left join #Application d on d.projectid=a.projectid      
      
      
--function      
      
select distinct a.ProjectID,h.functionname into #function      
 from #AllCount a       
 left join ToolsCatalog.[dbo].[ToolAccIDMapping] tc on tc.projectid=a.esaprojectid  and tc.IsDeleted = 0         
  left join ToolsCatalog.dbo.ToolFunctionIDMapping_AccAdmin tfm on tfm.ToolID = tc.toolid           
 and tc.ToolAccountID = tfm.toolaccountid   and tfm.IsDeleted=0        
  left join ToolsCatalog.dbo.Functionality h on tfm.FunctionID = h.FunctionID   and h.isdeleted=0        
      
  select distinct a.*,b.functionname from #AllCount a left join #function b on a.projectid=b.projectid      
      

drop table #function      
drop table #OveralllData      
drop table #AllCount      
drop table #Tools      
drop table #Service      
drop table #Application      
drop table #GetAllTileProgressPercentage          
end
