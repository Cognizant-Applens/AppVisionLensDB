
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
-- Author   : Umamaheswari S  
-- Create Date   : 22 Oct 2019  
-- Description   : Insert Non delivery activity into timesheet  
-- Revision By   :   
-- Revision Date :   
-- ====================================================================================================================   
CREATE PROCEDURE [AVL].[InsertHolidayTimesheetForNonDeliveryActivity]  
AS     
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @ErrorMessage VARCHAR(MAX);  
  
 BEGIN TRY  
  
  DECLARE @JobID INT  
  DECLARE @JobName VARCHAR(50) = 'Holiday Tracker'  
  DECLARE @Success VARCHAR(10) ='Success'  
  DECLARE @Failed VARCHAR(10) ='Failed'  
  DECLARE @CreatedBy VARCHAR(10) = 'System'  
  DECLARE @ActivityName VARCHAR(20) = 'NonDelivery'  
  DECLARE @NextWeekDate DATETIME   
  DECLARE @StartDate DATE  
  DECLARE @EndDate DATE  
  DECLARE @Rows int = 0  
  
  SET @NextWeekDate= GETDATE()+ 7  
  SET @StartDate=DATEADD(DAY, DATEDIFF(DAY, -1, @NextWeekDate) /7*7, -1)  
  SET @EndDate= DATEADD(DAY, DATEDIFF(DAY, 5, @NextWeekDate-1) /7*7 + 7, 5)  
    
  
  SELECT @JobID = JobID FROM MAS.JobMaster (NOLOCK) WHERE JobName =@JobName  
  
  IF EXISTS(SELECT TOP 1 1 FROM ESA.HolidayDetails (NOLOCK) WHERE HOLIDAY BETWEEN @StartDate AND @EndDate)  
   BEGIN      
      
    IF OBJECT_ID('tempdb..#JobGrade', 'U') IS NOT NULL  
    BEGIN  
     DROP TABLE #JobGrade  
    END  
  
    IF OBJECT_ID('tempdb..#Activeemployee', 'U') IS NOT NULL  
    BEGIN  
     DROP TABLE #Activeemployee  
    END  
  
    IF OBJECT_ID('tempdb..#ESAProjectHolidayDetails', 'U') IS NOT NULL  
    BEGIN  
     DROP TABLE #ESAProjectHolidayDetails  
    END  
  
    ----------------FETCH ASSOCIATES BELOW 'M' DESIGNATION-----------------  
    CREATE Table #JobGrade  
    (  
     EmployeeID nvarchar(100),  
     Assignment_Location nvarchar(24)  
    )  
  
    INSERT INTO #JobGrade   
    SELECT DISTINCT  
     AssociateID ,  
     Assignment_Location  
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
     H.HOLIDAY_HRS_NUMBER,  
     LOCATION,  
     HOLIDAY AS HolidayDate  
    INTO #ESAProjectHolidayDetails   
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
     JOIN #JobGrade JG (NOLOCK)  
      ON JG.EmployeeID=LM.EmployeeID  
     JOIN  ESA.HolidayDetails (NOLOCK) H  
      ON H.LOCATION=JG.Assignment_Location   
     JOIN  ESA.ProjectAssociates (NOLOCK) PAP  
      ON PAP.AssociateID=LM.EmployeeID  
      AND PAP.ProjectID=PM.EsaProjectID  
      AND PAP.ACCOUNT_ID=c.ESA_AccountID       
    WHERE C.IsDeleted=0 AND C.IsCognizant = 1  
     AND HOLIDAY BETWEEN @StartDate AND @EndDate  
           
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
     HolidayDate,  
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
    FROM  #ESAProjectHolidayDetails(NOLOCK) E         
    LEFT JOIN AVL.TM_Prj_Timesheet(nolock) TS  
     ON TS.ProjectID=E.ProjectID  
     AND TS.CustomerID=E.CustomerID  
     AND TS.SubmitterId=E.UserID  
     AND TS.TimesheetDate=E.HolidayDate  
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
     0,  
     0,  
     @ActivityName,  
     NULL,  
     1,  
     NULL,  
     NULL,  
     1,  
     NULL,  
     CASE when (AllocationPercent/100)*8 >= 7.2 Then HOLIDAY_HRS_NUMBER else CONVERT(DECIMAL(10,1),(AllocationPercent/100)*8) end as HOLIDAY_HRS_NUMBER,  
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
     JOIN #ESAProjectHolidayDetails EPJ (NOLOCK) ON TS.PROJECTID= EPJ.ProjectId  
     AND TS.CustomerID=EPJ.CustomerID  
     AND TS.SubmitterId=EPJ.UserID  
     AND TS.TimesheetDate=EPJ.HolidayDate  
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
     CASE when (AllocationPercent/100)*8 >= 7.2 Then HOLIDAY_HRS_NUMBER else CONVERT(DECIMAL(10,1),(AllocationPercent/100)*8) end as HOLIDAY_HRS_NUMBER,  
     NULL,    
     EPJ.ProjectID,  
     0,  
     @CreatedBy,  
     GETDATE(),  
     NULL,  
     NULL   
    FROM AVL.TM_Prj_Timesheet(NOLOCK) TS  
     JOIN #ESAProjectHolidayDetails EPJ (NOLOCK) ON TS.PROJECTID= EPJ.ProjectId  
     AND TS.CustomerID=EPJ.CustomerID  
     AND TS.SubmitterId=EPJ.UserID  
     AND TS.TimesheetDate=EPJ.HolidayDate  
    LEFT JOIN [AVL].[TM_TRN_InfraTimesheetDetail](NOLOCK) TSD  
     ON TSD.ProjectId=TS.ProjectId  
     AND TSD.TimesheetId=TS.TimesheetId  
    WHERE TSD.TimesheetId IS NULL AND TSD.ProjectId IS NULL AND SupportTypeId IN(2)  
  
    SET @Rows = @Rows + @@ROWCOUNT  
  
    INSERT INTO MAS.JobStatus   
    (JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)  
    VALUES(@JobID,@StartDate,@EndDate,@Success,GETDATE(),0,@JobName,GETDATE(),@Rows,0,0)  
  
   END  
  ELSE  
   BEGIN  
    INSERT INTO MAS.JobStatus   
    (JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)  
    VALUES(@JobID,@StartDate,@EndDate,@Failed,GETDATE(),0,@JobName,GETDATE(),0,0,0)       
      
    SET @ErrorMessage = 'No Records found in AppLens Holiday table'  
    RAISERROR (@ErrorMessage,16,1);  
   END    
 END TRY  
 BEGIN CATCH   
  
  DECLARE @MailSubject NVARCHAR(500);    
  DECLARE @MailBody  NVARCHAR(MAX);  
  DECLARE @MailRecipients NVARCHAR(MAX);  
  DECLARE @MailContent NVARCHAR(500);  
  DECLARE @Status CHAR(1)  
  DECLARE @ScriptName  NVARCHAR(100)  
    
  SELECT @MailSubject = CONCAT(@@servername, ': Holiday Tracker - Insert Non delivery activity into Timesheet Job Failure Notification')     
  SELECT @ErrorMessage = ERROR_MESSAGE()   
  SET @MailContent = 'Oops! Error Occurred while insert Non delivery activity into timesheet grid via holiday track job Execution!'  
  SET @Status = 'E'   
  SET @ScriptName = '[AVL].[InsertHolidayTimesheetForNonDeliveryActivity]'  
  SELECT @MailBody =[dbo].[fn_FormatEmailBody](@ErrorMessage,@MailContent,@Status,@ScriptName)  
  
  ---Mail Option Added by Annadurai on 11.01.2019 to send mail during error ESAJob  
  SELECT @MailRecipients = ConfigValue FROM [AVL].[AppLensConfig] WHERE ConfigId = 1  
  EXEC [AVL].[SendDBEmail] @To=@MailRecipients,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody  
    
 END CATCH  
 SET NOCOUNT OFF;
END


