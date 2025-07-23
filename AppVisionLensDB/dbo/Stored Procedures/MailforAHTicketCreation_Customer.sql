
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[MailforAHTicketCreation_Customer]  
AS  
BEGIN  
BEGIN TRY  
BEGIN TRAN  
SET NOCOUNT ON;    
---APplenscheck----  
create table #Customerlst(  
Sno INT IDENTITY(1,1),  
EmployeeEmail nvarchar(max),  
CustomerId nvarchar(max),  
CustomerName nvarchar(max),  
HierarchyName NVARCHAR(MAX)  
)  
insert into #Customerlst  
select distinct  LM.EmployeeEmail,VMEC.CustomerId,C.CustomerName,CONCAT(C.CustomerName, '- ', BC.BusinessClusterBaseName) as HierarchyName   
from AVL.MAS_LoginMaster LM (NOLOCK) 
JOIN AVL.VW_EmployeeCustomerProjectRoleBUMapping VMEC on LM.EmployeeID=VMEC.EmployeeID  
--join  AVL.EmployeeCustomerMapping  EC on EC.EmployeeId = LM.EmployeeId  
----and Ec.CustomerId=Lm.CustomerID  
join AVL.Customer C on C.CustomerID=VMEC.CustomerID  
--join AVL.EmployeeRoleMapping RM on RM.EmployeeCustomerMappingId=Ec.Id  
--join AVL.EmployeeProjectMapping EP ON EP.EmployeeCustomerMappingId=EC.Id  
--and Ep.ProjectId=Lm.ProjectID  
join AVL.DEBT_PRJ_HealProjectPatternMappingDynamic PMD on VMEC.ProjectID=PMD.ProjectID  
join AVL.DEBT_TRN_HealTicketDetails HD on HD.ProjectPatternMapID = PMD.ProjectPatternMapID   
and convert(date,hd.CreatedDate) = convert(date,GETDATE())  
join AVL.APP_MAS_ApplicationDetails  AD on AD.ApplicationID=PMD.ApplicationID  
join AVL.EmployeeSubClusterMapping SM on AD.SubBusinessClusterMapID=SM.SubClusterId  
join AVL.BusinessClusterMapping  BC on BC.BusinessClusterMapID=SM.SubClusterId  
where HD.IsDeleted=0 and PMD.IsDeleted=0 and VMEC.RoleId=3  AND ISNULL(HD.ManualNonDebt,0)=1 AND ISNULL(PMD.ManualNonDebt,0)=1  
and Lm.IsDeleted=0 and Ad.IsActive=1 and BC.IsDeleted=0 and c.IsCognizant=0 AND HD.TicketType<>'K'  
  
--select * from #Customerlst   
  
create table #HierarchyList(  
Sno INT IDENTITY(1,1),  
CustomerId NVARCHAR(MAX),  
countcust int,  
HierarchyName NVARCHAR(MAX),  
HierarchyNameCount int  
)  
  
insert into #HierarchyList  
select l.CustomerId,count(CustomerId) as countcust,l.HierarchyName,count(l.HierarchyName) as HierarchyNameCount from #Customerlst l (NOLOCK) 
group by l.CustomerId,l.HierarchyName  
  
--select * from #HierarchyList  
create table #finalCustomerListcount(  
Sno INT IDENTITY(1,1),  
Custcount int,  
CustomerId  NVARCHAR(MAX)  
)  
insert into #finalCustomerListcount  
select count(*),customerid from (  
select l.CustomerId,count(CustomerId) as countcust,l.HierarchyName,count(l.HierarchyName) as HierarchyNameCount from #Customerlst l  (NOLOCK)
group by l.CustomerId,l.HierarchyName) a group by CustomerId  
---select * from #finalCustomerListcount  
  
create table #finalEmailList(  
Sno INT IDENTITY(1,1),  
EmployeeEmail nvarchar(max),  
CustomerName NVARCHAR(MAX),  
CustomerId  NVARCHAR(MAX)  
)  
insert into #finalEmailList  
select distinct EmployeeEmail,CustomerName,CustomerId from #Customerlst (NOLOCK) 
  
/*****My Task******/  
  
declare @taskname varchar(500),@taskurl varchar(max),@taskapplication varchar(500),@taskstatus varchar(100),@tasktype as varchar(100) ;  
declare @taskid int=14;  
select @taskname=taskname from dbo.taskmaster (NOLOCK) where taskid=@taskid;  
select @taskurl=taskurl from dbo.taskurl (NOLOCK) where taskid=@taskid;  
select @taskapplication=applicationname from dbo.taskapplication (NOLOCK) where taskid=@taskid;  
select @taskstatus=status from dbo.taskstatus (NOLOCK) where taskstatusid=1;  
select @tasktype=tasktype from dbo.tasktype (NOLOCK) where tasktypeid=1;  
  
--DROP Table #OpUsers  
--delete from avl.MyTaskAutoHealingJob  
  
  
SELECT DISTINCT  AccessLevelID  AS 'ProjectID',UR.EmployeeID,PM.EsaProjectID,PM.ProjectName  
INTO #OpUsers  
 FROM AVL.Customer C WITH (NOLOCK) JOIN AVL.MAS_ProjectMaster PM WITH (NOLOCK) ON C.CustomerID=PM.CustomerID  
 JOIN AVL.UserRoleMapping UR WITH (NOLOCK) ON PM.ProjectID=UR.AccessLevelID JOIN   
 AVL.DEBT_PRJ_HealProjectPatternMappingDynamic PMD on  PMD.ProjectID=UR.AccessLevelID AND PMD.ProjectID=PM.ProjectID  
 JOIN AVL.DEBT_TRN_HealTicketDetails HD on hd.ProjectPatternMapID = PMD.ProjectPatternMapID   
 AND convert(date,hd.CreatedDate) = convert(date,GETDATE())  
 --AND convert(date,hd.CreatedDate) = convert(date,'1-25-2019')  
WHERE UR.RoleID=3 AND AccessLevelSourceID=4 AND IsActive=1 AND PM.IsDeleted=0 AND C.IsDeleted=0 AND HD.IsDeleted=0 AND HD.TicketType<>'K'   
AND PMD.IsDeleted=0 AND C.IsCognizant=0  
AND PMD.PatternStatus=1 AND NOT EXISTS(SELECT DISTINCT URM.EmployeeID FROM AVL.UserRoleMapping URM (NOLOCK) WHERE   
URM.RoleID<>3 AND URM.IsActive=1 AND URM.EmployeeID=UR.EmployeeID AND URM.AccessLevelID=PMD.ProjectID)  
AND ISNULL(HD.ManualNonDebt,0)=1 AND ISNULL(PMD.ManualNonDebt,0)=1;  
--select distinct UR.EmployeeID from AVL.UserRoleMapping UR where UR.AccessLevelID IN(44639)  
-- and UR.AccessLevelSourceID=4 and UR.RoleID=3 and UR.IsActive=1  
  
INSERT INTO AVL.MyTaskAutoHealingJob (UserID,TaskID,TaskName,URL,TaskDetails,Application,Status,RefreshedTime,  
CreatedBy,CreatedTime,ModifiedBy,ModifiedTime,TaskType,ExpiryDate,[Read],DueDate,ExpiryAfterRead,AccountID)  
SELECT Op.EmployeeID as'UserID',@taskid as 'TaskID',@taskname as 'TaskName',@taskurl as 'URL',  
'Automation/Healing tickets are created for the Project  : '+Op.EsaProjectID +'-'+ Op.ProjectName  
as 'TaskDetails',@taskapplication as 'Application',@taskstatus as 'Status',  
getdate() as 'RefreshedTime','system' as 'CreatedBy', getdate() as 'CreatedTime',null as 'ModifiedBy',null as 'ModifiedTime',  
@tasktype as 'TaskType',null as 'ExpiryDate','N' as 'Read',NULL as 'DueDate',2 as 'ExpiryAfterRead',  
ProjectID as 'AccountID'  
FROM #OpUsers Op (NOLOCK)  
  
  
  
/******My Task******/  
  
--select * from #finalEmailList  
  
  
  
  
  
---end of TOlist----  
 -- Mail template for the A/H Ticket Created Projects starts--------------  
 DECLARE @Count INT=1;  
 DECLARE @CountCID INT;  
 SELECT @CountCID = (SELECT distinct count(CustomerId)  FROM  #finalCustomerListcount)  
   --PRINT @CountCID   
 WHILE(@Count<=@CountCID)  
 BEGIN  
   DECLARE @tableHTML  VARCHAR(MAX);  
   DECLARE @EmailCustomerID varchar(max);  
   DECLARE @EmailCustomerName varchar(max);  
   Declare @EmailCustomerHierarchy varchar(max);  
   DECLARE @Subjecttext VARCHAR(max);     
   DECLARE @MailingToList VARCHAR(MAX)  
   SET   @MailingToList = ''  
   SET @Subjecttext = ''  
   SET @EmailCustomerID=(SELECT  distinct FL.CustomerId from #finalCustomerListcount FL (NOLOCK)  
    where FL.Sno=@Count)  
   SET @EmailCustomerName=(SELECT  distinct FL.CustomerName from #finalEmailList FL (NOLOCK)  
    where FL.CustomerId =@EmailCustomerID)  
    
   declare @CustHierarchyCount int   
   set @EmailCustomerHierarchy=''  
   set @CustHierarchyCount=(select Custcount from #finalCustomerListcount (NOLOCK) WHERE CustomerId=@EmailCustomerID)  
   print @CustHierarchyCount  
   IF(@CustHierarchyCount>1)  
   BEGIN  
     
   SELECT @EmailCustomerHierarchy =  COALESCE(@EmailCustomerHierarchy + ',', '') + CAST(RTRIM(ISNULL(HierarchyName,',')) AS VARCHAR(200))    
           FROM  #HierarchyList where CustomerId=@EmailCustomerID            
     
   END  
  
   ELSE  
   BEGIN  
   SELECT @EmailCustomerHierarchy = (select HierarchyName  
           FROM  #HierarchyList where CustomerId=@EmailCustomerID)  
   END  
   print @EmailCustomerHierarchy  
   SET @Subjecttext = 'New Automation/Healing ticket(s) created for - '+@EmailCustomerName;  
   print @Subjecttext  
   SELECT @MailingToList =  COALESCE(@MailingToList + ';', '') + CAST(RTRIM(ISNULL(EmployeeEmail,';')) AS VARCHAR(200))    
           FROM  #finalEmailList (NOLOCK) where CustomerId=@EmailCustomerID  
   Print @MailingToList  
   --comment this block after testing----  
   --SET @Count = @Count + 1  
   --END  
   -----------------------------------------  
   ---------------mailer body---------------  
  
   SET @tableHTML ='<html style="width:auto !important">'+  
   '<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">'+  
   '<table width="650" face="Times New Roman,serif" border="0" cellpadding="0" cellspacing="0" style="margin-left:60px;font-family:sans-serif;font-size:14px;font-weight:normal">'+  
   '<tbody>'+  
   '<tr>'+  
   '<td valign="top" style="padding: 0;">'+  
   '<div align="center" style="text-align: center;">'+  
   '<table width="650" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">'+  
   '<tbody>'+  
     '<tr style="height:50px">'+  
                                    '<td width="auto" valign="top" align="center">'+  
                                     '<img src="\\CTSC01165050301\WeeklyUAT\ApplensBanner.png" width="700" height="50" style="border-width: 0px;"/>'+  
                                    '</td>'+  
    '</tr>'+  
        
     '<tr style="background-color:#F0F8FF">'+  
                                    '<td valign="top" style="padding: 0;">'+  
                                        '<div align="center" style="text-align: center;margin-left:50px">'+  
                                            '<table width="650" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">'+  
                                                '<tbody>'+  
                                                  +'</BR>'+  
             N'<left>    
          <font-weight:normal>  
           
                  Hi All,'  
           + '</BR>'  
           +'&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp'  
           +'</BR>'  
           +'Automation/Healing Ticket has been created for the project  - '  
           +'<font color="#000000"><b>'+@EmailCustomerHierarchy+'</b></font>'  
           +'</BR>'  
           +'</BR>'  
           +'Requesting you to navigate to  App Healer/Automation menu available under Debt Engine'  
           +'</BR>'  
           +'module and assign/plan the newly created tickets'  
           +'</BR>'  
           +'</font>    
        </Left>'   
                  +  
          N'  
          
        <p align="left">    
        <font color="Black" Size = "2" font-weight=bold>    
        <b> Thanks & Regards,</b>  
         </font>   
         </BR>  
         Solution Zone Team     
          </BR>  
          </BR>        
       **This is an Auto Generated Mail. Please Do not reply to this mail**  
       </p>' +     
                                                '</tbody>'+  
                                            '</table>'+  
                                        '</div>'+  
                                   '</td>'+  
                                '</tr>'+  
   '</tbody>'+  
   '</table>'+  
   '</div>'+  
   '</td>'+  
   '</tr>'+  
   '</tbody>'+  
   '</table>'+  
   '</body>' +  
   '</html>'   
   -------------executing mail-------------  
    DECLARE @recipientsAddress NVARCHAR(4000)='';  
    SET @recipientsAddress = (SELECT ConfigValue FROM AVL.AppLensConfig (NOLOCK) WHERE ConfigName='Mail' AND IsActive=1);     
   EXEC [AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@Subjecttext,
    @Body = @tableHTML
    
   SET @Count = @Count + 1  
  END  
    SET NOCOUNT OFF;    
 COMMIT TRAN  
END TRY    
BEGIN CATCH    
DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SET @ErrorMessage = ERROR_MESSAGE()  
  
  SELECT @ErrorMessage  
  ROLLBACK TRAN  
  --INSERT Error      
  EXEC AVL_InsertError 'MailforAHTicketCreation_Customer', @ErrorMessage, 0,0  
END CATCH    
END


