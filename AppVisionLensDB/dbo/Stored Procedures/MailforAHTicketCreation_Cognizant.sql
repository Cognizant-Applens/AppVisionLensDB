


/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[MailforAHTicketCreation_Cognizant]  
as   
begin  
BEGIN TRY  
BEGIN TRAN  
SET NOCOUNT ON;    
  
  
create table #Applensusers(  
EmployeeEmail nvarchar(max),  
ProjectId nvarchar(max)  
)  
  
insert into #Applensusers  
SELECT distinct LM.EmployeeEmail,PMD.ProjectId  
from   
AVL.VW_EmployeeCustomerProjectRoleBUMapping VMEC  
join AVL.MAS_LoginMaster LM (NOLOCK) on LM.EmployeeID=VMEC.EmployeeId   
join AVL.Customer C (NOLOCK) on C.CustomerID=LM.CustomerID and c.CustomerID = VMEC.CustomerID  
join AVL.DEBT_PRJ_HealProjectPatternMappingDynamic PMD (NOLOCK) on  PMD.ProjectID=VMEC.ProjectId  
join AVL.DEBT_TRN_HealTicketDetails HD (NOLOCK) on hd.ProjectPatternMapID = PMD.ProjectPatternMapID   
and convert(date,hd.CreatedDate) = convert(date,GETDATE())  
where HD.IsDeleted=0 and PMD.IsDeleted=0 and VMEC.RoleId=3 AND HD.TicketType<>'K'  
and C.IsCognizant=1  
AND ISNULL(HD.ManualNonDebt,0)<>1 AND ISNULL(PMD.ManualNonDebt,0)<>1  
-----Login master-----  
select distinct   
 LM1.EmployeeID,  
 LM1.EmployeeEmail,  
 PMD.projectID,  
 LM1.TSApproverID,  
 LM1.HcmSupervisorID  
 into #temp1 from  [AVL].[MAS_LoginMaster] LM1   
 join AVL.Customer C (NOLOCK) on LM1.CustomerID=C.CustomerID  
 join AVL.DEBT_PRJ_HealProjectPatternMappingDynamic PMD (NOLOCK) on PMD.ProjectID=LM1.ProjectID  
 join AVL.DEBT_TRN_HealTicketDetails HD (NOLOCK) on PMD.ProjectPatternMapID=HD.ProjectPatternMapID   
 and convert(date,hd.CreatedDate) = convert(date,GETDATE())  
 where HD.IsDeleted=0 and PMD.IsDeleted=0 and  LM1.EmployeeEmail is not null and   
 LM1.isdeleted=0 and C.IsCognizant=1 AND HD.TicketType<>'K'  
 AND ISNULL(HD.ManualNonDebt,0)<>1 AND ISNULL(PMD.ManualNonDebt,0)<>1  
---segregate TSapprover-----   
create table #temp2(  
EmployeeEmail nvarchar(max),  
ProjectId nvarchar(max),  
TSApproverID nvarchar(max),  
)  
 insert into #temp2   
 select distinct LM.EmployeeEmail,T.Projectid,T.TSApproverID from  #temp1 T  (NOLOCK)
 join AVL.MAS_LoginMaster LM on LM.ProjectID= T.Projectid and LM.IsDeleted=0  
 and LM.EmployeeID=T.TSApproverID  
 ---segregate HCMSupervisor-----   
 create table #temp3(  
 EmployeeEmail nvarchar(max),  
ProjectId nvarchar(max),  
HcmSupervisorID nvarchar(max)  
 )  
  insert into #temp3  
 select distinct LM.EmployeeEmail,T.Projectid,T.HcmSupervisorID from  #temp1 T (NOLOCK)  
 join AVL.MAS_LoginMaster LM on LM.ProjectID= T.Projectid and LM.IsDeleted=0  
 and  LM.EmployeeID=T.HcmSupervisorID  
 -----joining two lead id's----  
create table  #loginmasterusers(  
 EmployeeEmail nvarchar(max),  
 ProjectId nvarchar(max)  
  
)  
insert into #loginmasterusers  
select T1.EmployeeEmail as EmployeeEmail,T1.ProjectId as ProjectId from #temp2 T1 (NOLOCK) union  
select T2.EmployeeEmail as EmployeeEmail,T2.ProjectId as ProjectId from #temp3 T2 (NOLOCK)  
----segregate projectid-------  
create table #finalProjectList(  
Sno INT IDENTITY(1,1),  
ProjectId bigint  
)  
insert into #finalProjectList  
select ProjectId from #Applensusers (NOLOCK) union   
select ProjectId from  #loginmasterusers (NOLOCK) 
----segregate emailid's-------  
create table #finalEmailList(  
Sno INT IDENTITY(1,1),  
EmployeeEmail nvarchar(max),  
ProjectId bigint  
)  
insert into #finalEmailList  
select a.EmployeeEmail as EmployeeEmail,ProjectId as ProjectId from #Applensusers a (NOLOCK) union   
select  l.EmployeeEmail as EmployeeEmail,l.ProjectId as ProjectId from  #loginmasterusers l  (NOLOCK)
/*****My Task******/  
  
declare @taskname varchar(500),@taskurl varchar(max),@taskapplication varchar(500),@taskstatus varchar(100),@tasktype as varchar(100) ;  
declare @taskid int=14;  
select @taskname=taskname from dbo.taskmaster (NOLOCK) where taskid=@taskid;  
select @taskurl=taskurl from dbo.taskurl (NOLOCK) where taskid=@taskid;  
select @taskapplication=applicationname from dbo.taskapplication (NOLOCK) where taskid=@taskid;  
select @taskstatus=status from dbo.taskstatus (NOLOCK) where taskstatusid=1;  
select @tasktype=tasktype from dbo.tasktype (NOLOCK) where tasktypeid=1;  
  
SELECT DISTINCT  AccessLevelID  AS 'ProjectID',UR.EmployeeID,PM.EsaProjectID,PM.ProjectName  
INTO #OpUsers  
 FROM AVL.Customer C  WITH (NOLOCK) JOIN AVL.MAS_ProjectMaster PM WITH (NOLOCK) ON C.CustomerID=PM.CustomerID  
JOIN AVL.UserRoleMapping UR WITH (NOLOCK) ON PM.ProjectID=UR.AccessLevelID JOIN   
 AVL.DEBT_PRJ_HealProjectPatternMappingDynamic PMD (NOLOCK) on  PMD.ProjectID=UR.AccessLevelID AND PMD.ProjectID=PM.ProjectID  
 JOIN AVL.DEBT_TRN_HealTicketDetails HD (NOLOCK) on hd.ProjectPatternMapID = PMD.ProjectPatternMapID   
 AND convert(date,hd.CreatedDate) = convert(date,GETDATE())  
WHERE UR.RoleID=3 AND AccessLevelSourceID=4 AND IsActive=1 AND PM.IsDeleted=0 AND C.IsDeleted=0 AND HD.IsDeleted=0 AND HD.TicketType<>'K'  
AND PMD.IsDeleted=0 AND C.IsCognizant=1   
AND PMD.PatternStatus=1 AND NOT EXISTS(SELECT DISTINCT URM.EmployeeID FROM AVL.UserRoleMapping URM WHERE   
URM.RoleID<>3 AND URM.IsActive=1 AND URM.EmployeeID=UR.EmployeeID AND URM.AccessLevelID=PMD.ProjectID)  
AND ISNULL(HD.ManualNonDebt,0)<>1 AND ISNULL(PMD.ManualNonDebt,0)<>1;  
  
INSERT INTO AVL.MyTaskAutoHealingJob (UserID,TaskID,TaskName,URL,TaskDetails,Application,Status,RefreshedTime,  
CreatedBy,CreatedTime,ModifiedBy,ModifiedTime,TaskType,ExpiryDate,[Read],DueDate,ExpiryAfterRead,AccountID)  
SELECT Op.EmployeeID as'UserID',@taskid as 'TaskID',@taskname as 'TaskName',@taskurl as 'URL',  
'Automation/Healing tickets are created for the Project  : '+Op.EsaProjectID +'-'+ Op.ProjectName  
as 'TaskDetails',@taskapplication as 'Application',@taskstatus as 'Status',  
getdate() as 'RefreshedTime','system' as 'CreatedBy', getdate() as 'CreatedTime',null as 'ModifiedBy',null as 'ModifiedTime',  
@tasktype as 'TaskType',null as 'ExpiryDate','N' as 'Read',NULL as 'DueDate',2 as 'ExpiryAfterRead',  
ProjectID as 'AccountID'  
FROM #OpUsers Op  (NOLOCK)
  
 -- Mail template for the A/H Ticket Created Projects starts--------------  
  
  DECLARE @PID INT  
  DECLARE @MinCount INT  
  DECLARE @MaxCount INT   
  
  SET @MinCount = (SELECT MIN(Sno) from  #finalProjectList )  
  --print @MinCount  
  SET @MaxCount = (SELECT MAX(Sno) from  #finalProjectList)  
  --print @MaxCount  
 WHILE(@MinCount <= @MaxCount)  
 BEGIN  
  --PRINT @MinCount  
   SET @PID = (SELECT  ProjectId FROM  #finalProjectList (NOLOCK) WHERE Sno = @MinCount)  
   PRINT @PID  
     
   DECLARE @tableHTML  VARCHAR(MAX);  
   DECLARE @EmailProjectName varchar(max);  
   DECLARE @Subjecttext VARCHAR(max);     
   DECLARE @MailingToList VARCHAR(MAX)  
   SET   @MailingToList = ''  
   SET @Subjecttext = ''  
            SET @EmailProjectName=(SELECT DISTINCT CONCAT(PM.EsaProjectID, '-', PM.ProjectName) from #finalProjectList FL join AVL.MAS_ProjectMaster PM  
   on PM.ProjectID=FL.ProjectId and FL.ProjectId =@PID)  
   print @EmailProjectName  
   SET @Subjecttext = 'New Automation/Healing ticket(s) created for the Project - '+@EmailProjectName;  
   print @Subjecttext  
   SELECT @MailingToList =  COALESCE(@MailingToList + ';', '') + CAST(RTRIM(ISNULL(EmployeeEmail,';')) AS VARCHAR(200))    
           FROM  #finalEmailList (NOLOCK) where ProjectId=@PID  
   Print @MailingToList  
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
             '</br>'+  
                                                    
             N'<left>   
              
          <font-weight:normal>  
            
           Hi All,'  
           + '</BR>'  
           +'&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp'  
           +'</BR>'  
           +'Automation/Healing Ticket has been created for the project - '  
            +'<font color="#000000"><b>'+@EmailProjectName+'</b></font>'  
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
           <font size="1">          
       **This is an Auto Generated Mail. Please Do not reply to this mail**  
       </font>  
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
    
  
  -- DROP TABLE #FinalRlt   
   SET @MinCount = @MinCount + 1  
  END  
  
    SET NOCOUNT OFF;    
 COMMIT TRAN  
END TRY    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SET @ErrorMessage = ERROR_MESSAGE()  
  
  SELECT @ErrorMessage  
  ROLLBACK TRAN  
  EXEC AVL_InsertError 'MailforAHTicketCreation_Cognizant', @ErrorMessage, 0,0  
END CATCH    
END


