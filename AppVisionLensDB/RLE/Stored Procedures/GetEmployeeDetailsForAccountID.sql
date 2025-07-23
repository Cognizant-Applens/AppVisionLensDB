CREATE PROCEDURE [RLE].[GetEmployeeDetailsForAccountID] -- '1230511'  
(    
 @ESAAccountID NVARCHAR(50)   
)    
AS    
BEGIN    
   SET NOCOUNT ON     
    BEGIN  
 --Getting the ApplensRoleID for the roles ('Admin','Proxy Admin','EDL','EDL- SL')   
 SELECT ApplensRoleID,RoleName into #RoleIDList FROM MAS.RLE_ROLES WHERE ROLENAME IN ('Admin','Proxy Admin','EDL','EDL- SL') order by ApplensRoleID  
  
 SELECT  DISTINCT   URM.ASSOCIATEID  as AssociateId ,   LM.EMPLOYEENAME as AssociateName , LM.EMPLOYEEEMAIL  as Email ,   
 RR.ApplensRoleID as ApplensRoleID,RR.RoleName as RoleName into #DISTINCTDATA  
 from RLE.Userrolemapping URM   
  JOIN RLE.Userroledataaccess URDA on URDA.Rolemappingid=URM.Rolemappingid   
  JOIN RLE.MASTERHIERARCHY MH ON (MH.PROJECTID=URDA.PROJECTID or MH.CUSTOMERID=URDA.CUSTOMERID)  
  JOIN AVL.MAS_LOGINMASTER LM ON LM.EMPLOYEEID=URM.ASSOCIATEID  
  JOIN #RoleIDList RR ON RR.ApplensRoleID=URM.ApplensRoleID  
  WHERE URM.ISDELETED=0 AND URDA.ISDELETED=0  AND LM.ISDELETED=0 AND MH.ESACUSTOMERID=@ESAAccountID and   
  LM.EMPLOYEEEMAIL not in ('ApplensQA2@cognizant.com','ApplensDev@cognizant.com')  
  ORDER BY  URM.ASSOCIATEID, LM.EMPLOYEENAME, LM.EMPLOYEEEMAIL,RR.RoleName   desc  
  
  select Distinct Associateid,ApplensRoleID,RoleName  into #AssociateRoleDetails from #distinctdata  
  
  
Alter table #AssociateRoleDetails add AssociateName NVarchar(100)  
Alter table #AssociateRoleDetails add Email NVarchar(100)  
  
update ARD  
set ARD.AssociateName = DD.AssociateName ,  
ARD.Email=DD.Email from   
#AssociateRoleDetails ARD  join  
#distinctdata DD  on  DD.associateid=ARD.Associateid   
  
  
select Distinct Associateid,AssociateName,Email,ApplensRoleID,RoleName  From #AssociateRoleDetails  
    
 DROP table #RoleIDList  
 DROP table #DistinctData  
 Drop table #AssociateRoleDetails  
      
   END    
 END
