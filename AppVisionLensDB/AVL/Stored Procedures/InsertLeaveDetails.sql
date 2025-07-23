
/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] � [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
-- ====================================================================================================================  
-- Author   : Sathyanarayanan  
-- Create Date   : 11 Nov 2019  
-- Description   : Get the leave details from CRS   
-- Revision By   :   
-- Revision Date :   
-- ====================================================================================================================   
  
CREATE   PROCEDURE [AVL].[InsertLeaveDetails]  
AS     
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @ErrorMessage VARCHAR(MAX);  
   
  
 BEGIN TRY   
    
  DECLARE @JobID INT  
  DECLARE @JobName VARCHAR(50) = 'Leave Tracker'  
  DECLARE @Success VARCHAR(10) ='Success'  
  DECLARE @Failed VARCHAR(10) ='Failed'  
  DECLARE @CreatedBy VARCHAR(10) = 'LeaveTracker'  
  DECLARE @ActivityName VARCHAR(20) = 'NonDelivery'  
  DECLARE @StartDateTime DATETIME   
  DECLARE @Rows int = 0  
  SET @StartDateTime = ( SELECT TOP 1 CreatedDate FROM [$(AVMCOEESADB)].[DBO].[LeaveTrackerDateDetails] ORDER BY ID DESC  )  
  
  SELECT @JobID = JobID FROM MAS.JobMaster WHERE JobName =@JobName  
    
  IF EXISTS(SELECT TOP 1 1 FROM [$(AVMCOEESADB)].[DBO].[LeaveDetails])  
  BEGIN   
        
   TRUNCATE TABLE AVL.LeaveDetails  
  
   INSERT INTO AVL.LeaveDetails  
    (  
    EmployeeID,  
    LeaveType,   
    ABSENCE_DATE,  
    CT_TOTAL_HRS,  
    LastUpdatedDateTime,  
    LASTUPDDTTM  
    )          
   SELECT DISTINCT   
    EmployeeID,  
    '',  
    ABSENCE_DATE,  
    CT_TOTAL_HRS,  
    LastUpdatedDateTime,  
    LASTUPDDTTM  
   FROM [$(AVMCOEESADB)].[DBO].[LeaveDetails]  
  
---Temp Table CleanUp  
  
   IF OBJECT_ID('tempdb..#JobGrade', 'U') IS NOT NULL  
    BEGIN  
     DROP TABLE #JobGrade  
    END  
  
    IF OBJECT_ID('tempdb..#Activeemployee', 'U') IS NOT NULL  
    BEGIN  
     DROP TABLE #Activeemployee  
    END  
  
    IF OBJECT_ID('tempdb..#ESAProjectLeaveDetails', 'U') IS NOT NULL  
    BEGIN  
     DROP TABLE #ESAProjectLeaveDetails  
    END  
  
----------------FETCH ASSOCIATES BELOW 'M' DESIGNATION-----------------  
    CREATE Table #JobGrade  
    (  
     EmployeeID nvarchar(100)  
    )  
  
    INSERT INTO #JobGrade   
    SELECT DISTINCT  
     AssociateID   
    FROM ESA.Associates(nolock)  
    WHERE Grade IN ('C33', 'C35', 'C40', 'C45', 'C50', 'C60','C65','C70','C75','C80','C85','C97',  
    'CC1','E60', 'E65', 'E70', 'E75', 'E80','E82','E85','E90','E95','E97','E99','N60',  
    'N65','N70','N75','N85','N90','N95','N98','NC1','NC2','NC3','NC4','NI1')  
  
---------------- FETCH CUSTOMER, PROJECT AND EMPLOYEE DETAILS FOR COGNIZANT -----------------  
  
    SELECT DISTINCT   
     C.CustomerID,  
     PM.ProjectID ,  
     LM.EmployeeID,  
     PJ.SupportTypeId,  
     LM.UserID,  
     PAP.AllocationPercent,  
     LD.CT_TOTAL_HRS,  
     LD.ABSENCE_DATE AS LeaveDate,  
     '' AS LeaveType  
    INTO #ESAProjectLeaveDetails   
    FROM avl.Customer(NOLOCK) C  
     JOIN avl.MAS_ProjectMaster(NOLOCK) PM  
      ON PM.CustomerID=C.CustomerID AND PM.IsDeleted = 0  
     JOIN [AVL].[PRJ_ConfigurationProgress](NOLOCK) PC  
      ON PC.ProjectID=PM.ProjectID AND PC.IsDeleted = 0  
      AND PC.ScreenID in(2,4,5) and CompletionPercentage=100  
     JOIN avl.MAS_LoginMaster(NOLOCK) LM  
      ON Lm.ProjectID=PC.ProjectID  
      AND LM.CustomerID=C.CustomerID   
      AND LM.IsDeleted=0  
     JOIN [AVL].[MAP_ProjectConfig] (NOLOCK) PJ  
      ON PJ.ProjectID=pm.ProjectID  
     JOIN #JobGrade JG  
      ON JG.EmployeeID=LM.EmployeeID  
     JOIN AVL.LeaveDetails  (NOLOCK) LD  
      ON LD.EmployeeID=JG.EmployeeID   
     JOIN  ESA.ProjectAssociates(nolock) PAP  
      ON PAP.AssociateID=LM.EmployeeID  
      AND PAP.ProjectID=PM.EsaProjectID  
    WHERE C.IsDeleted=0 AND C.IsCognizant = 1   
  
    SELECT CustomerID,EmployeeID,LeaveDate,COUNT(ProjectID) AS COUNT INTO #TEMP  
    FROM #ESAProjectLeaveDetails  
    WHERE AllocationPercent IN(90,10)  
    GROUP BY CustomerID,EmployeeID,LeaveDate  
    HAVING COUNT(ProjectID) = 2  
  
    DELETE ES   
    FROM #ESAProjectLeaveDetails ES  JOIN   
    #TEMP T ON ES.CustomerID = T.CustomerID   
    AND ES.EmployeeID = T.EmployeeID AND ES.LeaveDate = T.LeaveDate   
    WHERE ES.AllocationPercent = 10   
  
  
 -------------------TIMESHEET ENTRY --------------------  
  
    INSERT INTO AVL.TM_Prj_Timesheet  
    (   
     CustomerID,  
     ProjectID,  
     SubmitterId,  
     TimesheetDate,  
     StatusId,  
     ApprovedBy,  
     UnfreezedBy,  
     UnfreezedDate,  
     CreatedBy,  
     CreatedDateTime,  
     ModifiedBy,  
     ModifiedDateTime,  
     IsAutosubmit,  
     RejectionComments,  
     ApprovedDate,  
     TSRegion,  
     IsNonTicket  
    )  
    SELECT DISTINCT   
     E.CustomerID,  
     E.ProjectId,  
     E.UserID as SubmitterID,  
     LeaveDate,  
     1,  
     NULL,  
     NULL,  
     NULL,  
     @CreatedBy,  
     getdate(),  
     NULL,  
     NULL,  
     NULL,  
     NULL,  
     NULL,  
     NULL,  
     0  
    FROM  #ESAProjectLeaveDetails(NOLOCK) E         
    LEFT JOIN AVL.TM_Prj_Timesheet(nolock) TS  
     ON TS.ProjectID=E.ProjectID  
     AND TS.CustomerID=E.CustomerID  
     AND TS.SubmitterId=E.UserID  
     AND TS.TimesheetDate=E.LeaveDate  
    WHERE TS.ProjectID IS NULL AND (TS.StatusId IS NULL OR TS.StatusId NOT IN (2,3))  
  
    SET @Rows = @@ROWCOUNT  
  
    -------------------APP + INFRA PROJECT -------------------  
     
    INSERT INTO [AVL].[TM_TRN_TimesheetDetail]  
    (  
     TimesheetId,  
     TimeTickerID,  
     ApplicationID,  
     TicketID,  
     ShiftId,  
     IsNonTicket,  
     ServiceId,  
     CategoryId,  
     ActivityId,  
     TicketTypeMapID,  
     Hours,  
     Remarks,  
     IsAttributeUpdated,  
     TicketSourceID,  
     IsSDTicket,  
     ProjectId,  
     IsDeleted,  
     CreatedBy,  
     CreatedDateTime,  
     ModifiedBy,  
     ModifiedDateTime  
    )  
    SELECT DISTINCT   
     TS.TimesheetId,  
     NULL,  
     NULL,  
     @ActivityName,  
     NULL,  
     1,  
     NULL,  
     NULL,  
     1,  
     NULL,  
     CASE when (AllocationPercent/100)*8 >= 7.2 Then CT_TOTAL_HRS else CONVERT(DECIMAL(10,1),(AllocationPercent/100)*8) end as CT_TOTAL_HRS,  
     NULL,  
     NULL,  
     NULL,  
     NULL,  
     EPJ.ProjectID,  
     0,  
     @CreatedBy,  
     GETDATE(),  
     NULL,  
     NULL   
    FROM AVL.TM_Prj_Timesheet(NOLOCK) TS  
     JOIN #ESAProjectLeaveDetails EPJ ON TS.PROJECTID= EPJ.ProjectId  
     AND TS.CustomerID=EPJ.CustomerID  
     AND TS.SubmitterId=EPJ.UserID  
     AND TS.TimesheetDate=EPJ.LeaveDate  
    LEFT JOIN [AVL].[TM_TRN_TimesheetDetail](NOLOCK) TSD  
     ON TSD.ProjectId=TS.ProjectId  
     AND TSD.TimesheetId=TS.TimesheetId  
    WHERE TSD.TimesheetId IS NULL AND TSD.ProjectId IS NULL AND SupportTypeId IN(1,3)  
       
    SET @Rows = @Rows + @@ROWCOUNT  
  
    -------------------INFRA ENABLED PROJECT -------------------  
     
    INSERT INTO [AVL].[TM_TRN_InfraTimesheetDetail]  
    (   
     TimesheetId,  
     TimeTickerID,  
     TowerID,  
     TicketID,  
     IsNonTicket,  
     TaskId,  
     TicketTypeMapID,  
     Hours,  
     Remarks,  
     ProjectId,  
     IsDeleted,  
     CreatedBy,  
     CreatedDateTime,  
     ModifiedBy,  
     ModifiedDateTime  
    )  
    SELECT   
     TS.TimesheetId,  
     0,  
     0,  
     @ActivityName,   
     1,  
     1,  
     0,    
     CASE when (AllocationPercent/100)*8 >= 7.2 Then CT_TOTAL_HRS else CONVERT(DECIMAL(10,1),(AllocationPercent/100)*8) end as CT_TOTAL_HRS,  
     NULL,    
     EPJ.ProjectID,  
     0,  
     @CreatedBy,  
     GETDATE(),  
     NULL,  
     NULL   
    FROM AVL.TM_Prj_Timesheet(NOLOCK) TS  
     JOIN #ESAProjectLeaveDetails EPJ ON TS.PROJECTID= EPJ.ProjectId  
     AND TS.CustomerID=EPJ.CustomerID  
     AND TS.SubmitterId=EPJ.UserID  
     AND TS.TimesheetDate=EPJ.LeaveDate  
    LEFT JOIN [AVL].[TM_TRN_InfraTimesheetDetail](NOLOCK) TSD  
     ON TSD.ProjectId=TS.ProjectId  
     AND TSD.TimesheetId=TS.TimesheetId  
    WHERE TSD.TimesheetId IS NULL AND TSD.ProjectId IS NULL AND SupportTypeId IN(2)  
  
    SET @Rows = @Rows + @@ROWCOUNT  
  
  --Job Ststus   
      
     INSERT INTO MAS.JobStatus  
     (JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)  
     VALUES(@JobID,@StartDateTime,GETDATE(),@Success,GETDATE(),0,@JobName,GETDATE(),@Rows,0,0)  
       
     SELECT 1 AS Success  
          
  END    
  ELSE  
  BEGIN      
    INSERT INTO MAS.JobStatus  
    (JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)  
    VALUES(@JobID,GETDATE(),GETDATE(),@Failed,GETDATE(),0,@JobName,GETDATE(),0,0,0)  
        
    SELECT 0 AS Success   
      
    SET @ErrorMessage = 'No Records found in AppLens Leave table'  
    RAISERROR (@ErrorMessage,16,1);  
  END    
 END TRY  
 BEGIN CATCH   
  
  DECLARE @MailSubject NVARCHAR(100);    
  DECLARE @MailBody  NVARCHAR(MAX);  
  DECLARE @MailRecipients NVARCHAR(MAX);  
  DECLARE @MailContent NVARCHAR(100);  
  DECLARE @Status CHAR(1)  
  DECLARE @ScriptName  NVARCHAR(100)  
    
  SELECT @MailSubject = CONCAT(@@servername, ': Leave Tracker Job Failure Notification')     
  SELECT @ErrorMessage = ERROR_MESSAGE()   
  SET @MailContent = 'Oops! Error Occurred in Leave Tracker during the Gateway Data insert Execution!'  
  SET @Status = 'E'   
  SET @ScriptName = '[AVL].[InsertLeaveDetails]'  
  SELECT @MailBody =[dbo].[fn_FormatEmailBody](@ErrorMessage,@MailContent,@Status,@ScriptName)  
  
  ---Mail Option Added by Annadurai on 11.01.2019 to send mail during error ESAJob  
  SET @MailRecipients = ( SELECT ConfigValue FROM [AVL].[AppLensConfig] WHERE ConfigId = 1 )  
  EXEC [AVL].[SendDBEmail] @To=@MailRecipients,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody  
    
 END CATCH   
   
END  

