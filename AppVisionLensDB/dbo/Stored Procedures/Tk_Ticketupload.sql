    
    
    
/***************************************************************************        
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET        
*Copyright [2018] – [2021] Cognizant. All rights reserved.        
*NOTICE: This unpublished material is proprietary to Cognizant and        
*its suppliers, if any. The methods, techniques and technical        
  concepts herein are considered Cognizant confidential and/or trade secret information.         
          
*This material may be covered by U.S. and/or foreign patents or patent applications.         
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.        
***************************************************************************/        
        
CREATE PROCEDURE [dbo].[Tk_Ticketupload]         
(          
  -- Add the parameters for the stored procedure here           
  @projectid        INT =NULL,           
  @CogID            VARCHAR(100) =NULL,            
  @Flag             varchar(50)=NULL,           
  @IsAuditAvailable BIT = 0,         
  @mode             varchar(50)=null,        
  @TicketUploadTrackID AS BIGINT        
)          
AS           
 BEGIN           
  BEGIN TRY          
  --BEGIN TRAN            
        
 SET nocount ON;            
   /*****************************Multilingual******************************/        
DECLARE @isMultiLingual INT=0;        
  DECLARE @IsResolutionRemarks [BIT]=0,        
    @IsComments [BIT] =0,        
    --@IsCauseCode [BIT],        
    --@IsResolutionCode [BIT],        
    @IsFlexField1 [BIT]=0,        
    @IsFlexField2[BIT]=0,        
    @IsFlexField3 [BIT]=0,        
    @IsFlexField4 [BIT]=0,        
    @IsCategory [BIT]=0,        
    @IsType [BIT]=0;        
        
 SELECT @isMultiLingual=1 FROM AVL.MAS_ProjectMaster WITH (NOLOCK) WHERE ProjectID=@projectid AND        
 IsDeleted=0 AND IsMultilingualEnabled=1;        
 PRINT @isMultiLingual;        
 IF(@isMultiLingual=1)        
  BEGIN        
  SELECT DISTINCT MCM.ColumnID INTO #Columns FROM AVL.MAS_MultilingualColumnMaster MCM WITH (NOLOCK)         
  JOIN AVL.PRJ_MultilingualColumnMapping MCP WITH(NOLOCK) ON MCM.ColumnID=MCP.ColumnID        
  WHERE MCM.IsActive=1 AND MCP.IsActive=1        
  AND MCP.ProjectID=@projectid;        
        
  --SELECT * FROM #Columns;        
  SELECT @IsResolutionRemarks=1 FROM #Columns WHERE ColumnID=3;        
   SELECT @IsComments=1 FROM #Columns WHERE ColumnID=4;        
    SELECT @IsFlexField1=1 FROM #Columns WHERE ColumnID=7;        
     SELECT @IsFlexField2=1 FROM #Columns WHERE ColumnID=8;        
      SELECT @IsFlexField3=1 FROM #Columns WHERE ColumnID=9;        
       SELECT @IsFlexField4=1 FROM #Columns WHERE ColumnID=10;        
        SELECT @IsCategory=1 FROM #Columns WHERE ColumnID=11;        
        SELECT @IsType=1 FROM #Columns WHERE ColumnID=12;        
        
   PRINT @IsResolutionRemarks ;        
   PRINT @IsComments  ;        
   PRINT @IsFlexField1 ;        
   PRINT @IsFlexField2;        
   PRINT @IsFlexField3 ;        
   PRINT @IsFlexField4 ;        
   PRINT @IsCategory ;        
   PRINT @IsType ;        
  END        
        
  DECLARE @FlexField1 BIT ;        
  DECLARE @FlexField2 BIT ;        
  DECLARE @FlexField3 BIT ;        
  DECLARE @FlexField4 BIT ;        
  DECLARE @ResolutionRemarksApp BIT;        
  DECLARE @ResolutionRemarksInfra BIT;        
    IF EXISTS         
   (SELECT 1 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)         
   WHERE ProjectID=@ProjectID AND IsActive=1 AND ColumnID=11)        
   BEGIN        
    SET @FlexField1=1;        
   END        
           
  IF EXISTS         
   (SELECT TOP 1 1 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)        
   WHERE ProjectID=@ProjectID AND IsActive=1 AND  ColumnID=12)        
   BEGIN        
    SET @FlexField2=1;        
   END        
  IF EXISTS         
   (SELECT TOP 1 1 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)         
   WHERE ProjectID=@ProjectID AND IsActive=1 AND  ColumnID=13)        
   BEGIN        
    SET @FlexField3=1;        
   END        
  IF EXISTS         
   (SELECT TOP 1 1 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)        
   WHERE ProjectID=@ProjectID AND IsActive=1 AND  ColumnID=14)        
   BEGIN        
    SET @FlexField4=1;        
   END        
   IF EXISTS         
   (SELECT TOP 1 1 FROM [ML].[ConfigurationProgress] (NOLOCK)        
     WHERE PROJECTID=@ProjectID AND IsOptionalField=1        
     and IsDeleted=0)        
   BEGIN        
    SET @ResolutionRemarksApp=1;        
   END        
    IF EXISTS         
   (SELECT TOP 1 1 FROM [ML].[InfraConfigurationProgress] (NOLOCK)        
     WHERE PROJECTID=@ProjectID AND IsOptionalField=1        
     and IsDeleted=0)        
   BEGIN        
    SET @ResolutionRemarksInfra=1;        
   END        
        
 /**********************************************************************/        
 DECLARE @TicketSource INT = (SELECT ID FROM AVL.TicketSource WHERE Upper(Ltrim(Rtrim(SourceName))) = Upper(Ltrim(Rtrim(@mode))))        
        
--#region Create Create and insert into ImportTicketDumpDetails        
        
  CREATE TABLE #ImportTicketDumpDetails(        
 [ID] [int] IDENTITY(1,1) NOT NULL,        
 [Ticket ID] [nvarchar](max) NOT NULL,        
 [Ticket Type] [nvarchar](max) NULL,        
 [TicketTypeID] [int] NULL,        
 [Assignee] [nvarchar](max) NULL,        
 [ActiveFlag] [nvarchar](max) NULL,        
 [Close Date] [datetime] NULL,        
 [Planned End Date] [datetime] NULL,        
 [Modified Date Time] [datetime] NULL,        
 [ArrivalDate] [datetime] NULL,        
 [Open Date] [datetime] NULL,        
 [Priority] [nvarchar](max) NULL,        
 [PriorityID] [int] NULL,        
 [Reopen Date] [datetime] NULL,        
 [Sla Miss] [nvarchar](max) NULL,        
 [ResolutionID] [nvarchar](max) NULL,        
 [Resolution Code] [nvarchar](max) NULL,        
 [Status] [nvarchar](max) NULL,        
 [StatusID] [int] NULL,        
 [Ticket Description] [nvarchar](max) NULL,        
 [Raised By Customer] [nvarchar](max) NULL,        
 [IsManual] [nvarchar](max) NULL,        
 [ProductName] [nvarchar](max) NULL,        
 [ModifiedBY] [nvarchar](max) NULL,        
 [Ticket Source] [nvarchar](max) NULL,        
 [Source Department] [nvarchar](max) NULL,        
 [Turn around Time] [decimal](25, 2) NULL,        
 [Application] [nvarchar](max) NULL,        
 [ApplicationID] [int] NULL,        
 [Application Group Trail] [nvarchar](max) NULL,        
 [TicketLocation] [nvarchar](max) NULL,        
 [Sec Assignee] [nvarchar](max) NULL,        
 [Root Cause] [nvarchar](max) NULL,        
 [Reviewer] [nvarchar](max) NULL,        
 [PriorityChng] [nvarchar](max) NULL,        
 [Service] [nvarchar](max) NULL,        
 [ServiceID] [int] NULL,        
 [EmployeeID] [nvarchar](max) NULL,        
 [EmployeeName] [nvarchar](max) NULL,        
 [External Login ID] [nvarchar](max) NULL,        
 [ProjectID] [int] NOT NULL,        
 [CTIcategory] [nvarchar](max) NULL,        
 [CTItype] [nvarchar](max) NULL,        
 [CTIitem] [nvarchar](max) NULL,        
 [SecAssigneeID] [int] NULL,        
 [UserID] [nvarchar](max) NULL,        
 [SecClientUserID] [nvarchar](max) NULL,        
 [Accountprojectlobid] [int] NULL,        
 [LOBTrackid] [int] NULL,        
 [IsDeleted] [char](1) NULL,        
 [Severity] [nvarchar](max) NULL,        
 [Release Type] [nvarchar](max) NULL,        
 [Planned Effort] [decimal](25, 2) NULL,        
 [Estimated Work Size] [decimal](25, 2) NULL,        
 [Actual Work Size] [decimal](25, 2) NULL,        
 [Planned Start Date and Time] [datetime] NULL,        
 [New Status Date Time] [datetime] NULL,        
 [Resolved date] [datetime] NULL,        
 [Rejected Time Stamp] [datetime] NULL,        
 [Release Date] [datetime] NULL,        
 [KEDBAvailableIndicatorID] [bigint] NULL,        
 [KEDB Available Indicator] [nvarchar](max) NULL,        
 [KEDBupdatedID] [bigint] NULL,        
 [KEDB updated] [nvarchar](max) NULL,        
 [Elevate Flag Internal] [nvarchar](max) NULL,        
 [RCA ID] [nvarchar](max) NULL,        
 [Met Response SLA] [nvarchar](max) NULL,        
 [Met Acknowledgement SLA] [nvarchar](max) NULL,        
 [Met Resolution] [nvarchar](max) NULL,        
 [Response Time] [decimal](25, 2) NULL,        
 [Resolved by] [nvarchar](max) NULL,        
 [Actual Start date Time] [datetime] NULL,        
 [Actual End date Time] [datetime] NULL,        
 [Planned Duration] [decimal](26, 5) NULL,        
 [Actual duration] [decimal](26, 5) NULL,        
 [TicketCreateDate] [datetime] NULL,        
 [Ticket Summary] [nvarchar](max) NULL,        
 [NatureOfTheTicketID] [bigint] NULL,        
 [Nature Of The Ticket] [nvarchar](max) NULL,        
 [Technology] [nvarchar](max) NULL,        
 [Business Impact] [nvarchar](max) NULL,        
 [Job Process Name] [nvarchar](max) NULL,        
 [Server Name] [nvarchar](max) NULL,        
 [Comments] [nvarchar](max) NULL,        
 [Requester Customer Id] [nvarchar](max) NULL,        
 [Requester First Name] [nvarchar](max) NULL,        
 [Requester Internet Email] [nvarchar](max) NULL,        
 [Requester Contact Number] [nvarchar](max) NULL,        
 [Repeated Incident] [nvarchar](max) NULL,        
 [Related Tickets] [nvarchar](max) NULL,        
 [Ticket Created By] [nvarchar](max) NULL,        
 [KEDB Path] [nvarchar](max) NULL,        
 [Requested Resolution Date Time] [date] NULL,        
 [CSAT Score] [decimal](10, 1) NULL,        
 [EscalatedFlagCustomerID] [bigint] NULL,        
 [Escalated Flag Customer] [nvarchar](max) NULL,        
 [Approved Date Time] [date] NULL,        
 [Reviewed Date Time] [date] NULL,        
 [Reason For Rejection] [nvarchar](max) NULL,        
 [Reason For Cancel] [nvarchar](max) NULL,        
 [Reason For On Hold] [nvarchar](max) NULL,        
 [Response SLA Overridden Reason] [nvarchar](max) NULL,        
 [Resolution SLA Overridden Reason] [nvarchar](max) NULL,        
 [Acknowledgement SLA Overridden Reason] [nvarchar](max) NULL,        
 [Type] [nvarchar](max) NULL,        
 [Item] [nvarchar](max) NULL,        
 [Started Date Time] [datetime] NULL,        
 [WIP Date Time] [datetime] NULL,        
 [On Hold Date Time] [datetime] NULL,        
 [Completed Date Time] [datetime] NULL,        
 [Cancelled Date Time] [datetime] NULL,        
 [Approved By] [nvarchar](max) NULL,        
 [Reviewed By] [nvarchar](max) NULL,        
 [Customer Ticket ID] [nvarchar](max) NULL,        
 [Outage Duration] [nvarchar](max) NULL,        
 [OutageFlagID] [bigint] NULL,        
 [Outage Flag] [nvarchar](max) NULL,        
 [WarrantyIssueID] [bigint] NULL,        
 [Warranty Issue] [nvarchar](max) NULL,        
 [ResolutionDetails] [nvarchar](max) NULL,        
 [sourceID] [int] NULL,        
 [severityID] [int] NULL,        
 [releaseTypeID] [int] NULL,        
 [Remarks] [nvarchar](max) NULL,        
 [Assigned Time Stamp] [datetime] NULL,        
 [DARTStatusId] [int] NULL,        
 [DebtClassificationId] [int] NULL,        
 [Debt Classification] [nvarchar](max) NULL,        
 [AvoidableFlagID] [int] NULL,        
 [Avoidable Flag] [nvarchar](max) NULL,        
 [Residual Debt] [nvarchar](max) NULL,        
 [Resolution Method] [nvarchar](max) NULL,        
 [ResidualDebtID] [int] NULL,        
 [Cause code] [nvarchar](max) NULL,        
 [CauseCodeID] [nvarchar](max) NULL,        
 [ITSM Effort] [nvarchar](max) NULL,        
 [Assignment Group] [nvarchar](max) NULL,        
 [Assignment Group ID] [bigint] NULL,        
 [UploadedBy] [nvarchar](max) NULL,        
 [UploadedDate] [datetime] NULL,        
 [Expected Completion Date] [datetime] NULL,        
 [Reason for Residual] [nvarchar](max) NULL,        
 [Resolution Remarks] [nvarchar](max) NULL,        
 [DebtModeID] [bigint] NULL,        
 [Flex Field (1)] [nvarchar](max) NULL,        
 [Flex Field (2)] [nvarchar](max) NULL,        
 [Flex Field (3)] [nvarchar](max) NULL,        
 [Flex Field (4)] [nvarchar](max) NULL,        
 [Category] [nvarchar](max) NULL,        
 TicketUploadTrackID [nvarchar](max) NULL,        
 LastModifiedSource [nvarchar](max) NULL,        
 IsBOT [INT] NULL,        
 IsTicketSummaryModified [BIT] NULL,        
 IsTicketDescriptionModified [BIT] NULL,        
 IsResolutionRemarksModified [BIT] NULL,        
 IsCommentsModified [BIT] NULL,        
 IsCauseCodeModified [BIT] NULL,        
 IsResolutionCodeModified [BIT] NULL,        
 IsFlexField1Modified [BIT] NULL,        
 IsFlexField2Modified [BIT] NULL,        
 IsFlexField3Modified [BIT] NULL,        
 IsFlexField4Modified [BIT] NULL,        
 IsCategoryModified [BIT] NULL,        
 IsTypeModified [BIT] NULL,        
 SupportType [INT] NULL,        
    [InitiatedSource] [nvarchar](max) NULL,        
 TowerName [nvarchar](max) NULL,        
 TowerID BIGINT NULL,        
 IsPartiallyAutomated varchar(max) NULL,        
    IsGracePeriodMet BIT DEFAULT 0,        
 [TicketDescriptionBasePattern] [nvarchar](250) NULL,        
 [TicketDescriptionSubPattern] [nvarchar](250) NULL,        
 [ResolutionRemarksBasePattern] [nvarchar](250) NULL,        
 [ResolutionRemarksSubPattern] [nvarchar](250) NULL        
 )         
 CREATE TABLE #RegexTicketDetail(        
  [ID] [int] IDENTITY(1,1) NOT NULL,        
  [TicketID] [nvarchar](max) NOT NULL,        
  [ProjectID] [bigint] NOT NULL,        
[TicketDescription] [nvarchar](max) NULL,        
  [ResolutionRemarks] [nvarchar](max) NULL,        
  [TicketSummary] [nvarchar](max) NULL,        
  [Comments] [nvarchar](max) NULL,        
  [SupportType] int NULL        
  )        
        
  CREATE TABLE #RegexInfraTicketDetail(        
  [ID] [int] IDENTITY(1,1) NOT NULL,        
  [TicketID] [nvarchar](max) NOT NULL,        
  [ProjectID] [bigint] NOT NULL,        
  [TicketDescription] [nvarchar](max) NULL,        
  [ResolutionRemarks] [nvarchar](max) NULL,        
  [TicketSummary] [nvarchar](max) NULL,        
  [Comments] [nvarchar](max) NULL,        
  [SupportType] int NULL        
  )        
         
        
 CREATE TABLE #ImportTicketDumpDetails_BOT(        
 [ID] [int] IDENTITY(1,1) NOT NULL,        
 [Ticket ID] [nvarchar](max) NOT NULL,        
 [Ticket Type] [nvarchar](max) NULL,        
 [TicketTypeID] [int] NULL,        
 [Assignee] [nvarchar](max) NULL,        
 [ActiveFlag] [nvarchar](max) NULL,        
 [Close Date] [datetime] NULL,        
 [Planned End Date] [datetime] NULL,        
 [Modified Date Time] [datetime] NULL,        
 [ArrivalDate] [datetime] NULL,        
 [Open Date] [datetime] NULL,        
 [Priority] [nvarchar](max) NULL,        
 [PriorityID] [int] NULL,        
 [Reopen Date] [datetime] NULL,        
 [Sla Miss] [nvarchar](max) NULL,        
 [ResolutionID] [nvarchar](max) NULL,        
 [Resolution Code] [nvarchar](max) NULL,        
 [Status] [nvarchar](max) NULL,        
 [StatusID] [int] NULL,        
 [Ticket Description] [nvarchar](max) NULL,        
 [Raised By Customer] [nvarchar](max) NULL,        
 [IsManual] [nvarchar](max) NULL,        
 [ProductName] [nvarchar](max) NULL,        
 [ModifiedBY] [nvarchar](max) NULL,        
 [Ticket Source] [nvarchar](max) NULL,        
 [Source Department] [nvarchar](max) NULL,        
 [Turn around Time] [decimal](25, 2) NULL,        
 [Application] [nvarchar](max) NULL,        
 [ApplicationID] [int] NULL,        
 [Application Group Trail] [nvarchar](max) NULL,        
 [TicketLocation] [nvarchar](max) NULL,        
 [Sec Assignee] [nvarchar](max) NULL,        
 [Root Cause] [nvarchar](max) NULL,        
 [Reviewer] [nvarchar](max) NULL,        
 [PriorityChng] [nvarchar](max) NULL,        
 [Service] [nvarchar](max) NULL,        
 [ServiceID] [int] NULL,        
 [EmployeeID] [nvarchar](max) NULL,        
 [EmployeeName] [nvarchar](max) NULL,        
 [External Login ID] [nvarchar](max) NULL,        
 [ProjectID] [int] NOT NULL,        
 [CTIcategory] [nvarchar](max) NULL,        
 [CTItype] [nvarchar](max) NULL,        
 [CTIitem] [nvarchar](max) NULL,        
 [SecAssigneeID] [int] NULL,        
 [UserID] [nvarchar](max) NULL,        
 [SecClientUserID] [nvarchar](max) NULL,        
 [Accountprojectlobid] [int] NULL,        
 [LOBTrackid] [int] NULL,        
 [IsDeleted] [char](1) NULL,        
 [Severity] [nvarchar](max) NULL,        
 [Release Type] [nvarchar](max) NULL,        
 [Planned Effort] [decimal](25, 2) NULL,        
 [Estimated Work Size] [decimal](25, 2) NULL,        
 [Actual Work Size] [decimal](25, 2) NULL,        
 [Planned Start Date and Time] [datetime] NULL,        
 [New Status Date Time] [datetime] NULL,        
 [Resolved date] [datetime] NULL,        
 [Rejected Time Stamp] [datetime] NULL,        
 [Release Date] [datetime] NULL,        
 [KEDBAvailableIndicatorID] [bigint] NULL,        
 [KEDB Available Indicator] [nvarchar](max) NULL,        
 [KEDBupdatedID] [bigint] NULL,        
 [KEDB updated] [nvarchar](max) NULL,        
 [Elevate Flag Internal] [nvarchar](max) NULL,        
 [RCA ID] [nvarchar](max) NULL,        
 [Met Response SLA] [nvarchar](max) NULL,        
 [Met Acknowledgement SLA] [nvarchar](max) NULL,        
 [Met Resolution] [nvarchar](max) NULL,        
 [Response Time] [decimal](25, 2) NULL,        
 [Resolved by] [nvarchar](max) NULL,        
 [Actual Start date Time] [datetime] NULL,        
 [Actual End date Time] [datetime] NULL,        
 [Planned Duration] [decimal](26, 5) NULL,        
 [Actual duration] [decimal](26, 5) NULL,        
 [TicketCreateDate] [datetime] NULL,        
 [Ticket Summary] [nvarchar](max) NULL,        
 [NatureOfTheTicketID] [bigint] NULL,        
 [Nature Of The Ticket] [nvarchar](max) NULL,        
 [Technology] [nvarchar](max) NULL,        
 [Business Impact] [nvarchar](max) NULL,        
 [Job Process Name] [nvarchar](max) NULL,        
 [Server Name] [nvarchar](max) NULL,        
 [Comments] [nvarchar](max) NULL,        
 [Requester Customer Id] [nvarchar](max) NULL,        
 [Requester First Name] [nvarchar](max) NULL,        
 [Requester Internet Email] [nvarchar](max) NULL,        
 [Requester Contact Number] [nvarchar](max) NULL,        
 [Repeated Incident] [nvarchar](max) NULL,        
 [Related Tickets] [nvarchar](max) NULL,        
 [Ticket Created By] [nvarchar](max) NULL,        
 [KEDB Path] [nvarchar](max) NULL,        
 [Requested Resolution Date Time] [date] NULL,        
 [CSAT Score] [decimal](10, 1) NULL,        
 [EscalatedFlagCustomerID] [bigint] NULL,        
 [Escalated Flag Customer] [nvarchar](max) NULL,        
 [Approved Date Time] [date] NULL,        
 [Reviewed Date Time] [date] NULL,        
 [Reason For Rejection] [nvarchar](max) NULL,        
 [Reason For Cancel] [nvarchar](max) NULL,        
 [Reason For On Hold] [nvarchar](max) NULL,        
 [Response SLA Overridden Reason] [nvarchar](max) NULL,        
 [Resolution SLA Overridden Reason] [nvarchar](max) NULL,        
 [Acknowledgement SLA Overridden Reason] [nvarchar](max) NULL,        
 [Type] [nvarchar](max) NULL,        
 [Item] [nvarchar](max) NULL,        
 [Started Date Time] [datetime] NULL,        
 [WIP Date Time] [datetime] NULL,        
 [On Hold Date Time] [datetime] NULL,        
 [Completed Date Time] [datetime] NULL,        
 [Cancelled Date Time] [datetime] NULL,        
 [Approved By] [nvarchar](max) NULL,        
 [Reviewed By] [nvarchar](max) NULL,        
 [Customer Ticket ID] [nvarchar](max) NULL,        
 [Outage Duration] [nvarchar](max) NULL,        
 [OutageFlagID] [bigint] NULL,        
 [Outage Flag] [nvarchar](max) NULL,        
 [WarrantyIssueID] [bigint] NULL,        
 [Warranty Issue] [nvarchar](max) NULL,        
 [ResolutionDetails] [nvarchar](max) NULL,        
 [sourceID] [int] NULL,        
 [severityID] [int] NULL,        
 [releaseTypeID] [int] NULL,        
 [Remarks] [nvarchar](max) NULL,        
 [Assigned Time Stamp] [datetime] NULL,        
 [DARTStatusId] [int] NULL,        
 [DebtClassificationId] [int] NULL,        
 [Debt Classification] [nvarchar](max) NULL,        
 [AvoidableFlagID] [int] NULL,        
 [Avoidable Flag] [nvarchar](max) NULL,        
 [Residual Debt] [nvarchar](max) NULL,        
 [Resolution Method] [nvarchar](max) NULL,        
 [ResidualDebtID] [int] NULL,        
 [Cause code] [nvarchar](max) NULL,        
 [CauseCodeID] [nvarchar](max) NULL,        
 [ITSM Effort] [nvarchar](max) NULL,        
 [Assignment Group] [nvarchar](max) NULL,        
 [Assignment Group ID] [bigint] NULL,        
 [UploadedBy] [nvarchar](max) NULL,        
 [UploadedDate] [datetime] NULL,        
 [Expected Completion Date] [datetime] NULL,        
 [Reason for Residual] [nvarchar](max) NULL,        
 [Resolution Remarks] [nvarchar](max) NULL,        
 [DebtModeID] [bigint] NULL,        
 [Flex Field (1)] [nvarchar](max) NULL,        
 [Flex Field (2)] [nvarchar](max) NULL,        
 [Flex Field (3)] [nvarchar](max) NULL,        
 [Flex Field (4)] [nvarchar](max) NULL,        
 [Category] [nvarchar](max) NULL,        
 TicketUploadTrackID [nvarchar](max) NULL,        
 LastModifiedSource [nvarchar](max) NULL,        
 IsBOT [INT] NULL,        
 IsTicketSummaryModified [BIT] NULL,        
 IsTicketDescriptionModified [BIT] NULL,        
 IsResolutionRemarksModified [BIT] NULL,        
 IsCommentsModified [BIT] NULL,        
 IsCauseCodeModified [BIT] NULL,        
 IsResolutionCodeModified [BIT] NULL,        
 IsFlexField1Modified [BIT] NULL,        
 IsFlexField2Modified [BIT] NULL,        
 IsFlexField3Modified [BIT] NULL,        
 IsFlexField4Modified [BIT] NULL,        
 IsCategoryModified [BIT] NULL,        
 IsTypeModified [BIT] NULL,        
 SupportType [INT] NULL,        
    [InitiatedSource] [nvarchar](max) NULL,        
 TowerName [nvarchar](max) NULL,        
 TowerID BIGINT NULL,        
 IsPartiallyAutomated int NULL        
        
        
)         
        
 CREATE TABLE #ImportTicketDumpDetails_Infra(        
 [ID] [int] IDENTITY(1,1) NOT NULL,        
 [Ticket ID] [nvarchar](max) NOT NULL,        
 [Ticket Type] [nvarchar](max) NULL,        
 [TicketTypeID] [int] NULL,        
 [Assignee] [nvarchar](max) NULL,        
 [ActiveFlag] [nvarchar](max) NULL,        
 [Close Date] [datetime] NULL,        
 [Planned End Date] [datetime] NULL,        
 [Modified Date Time] [datetime] NULL,        
 [ArrivalDate] [datetime] NULL,        
 [Open Date] [datetime] NULL,        
 [Priority] [nvarchar](max) NULL,        
 [PriorityID] [int] NULL,        
 [Reopen Date] [datetime] NULL,        
 [Sla Miss] [nvarchar](max) NULL,        
 [ResolutionID] [nvarchar](max) NULL,        
 [Resolution Code] [nvarchar](max) NULL,        
 [Status] [nvarchar](max) NULL,        
 [StatusID] [int] NULL,        
 [Ticket Description] [nvarchar](max) NULL,        
 [Raised By Customer] [nvarchar](max) NULL,        
 [IsManual] [nvarchar](max) NULL,        
 [ProductName] [nvarchar](max) NULL,        
 [ModifiedBY] [nvarchar](max) NULL,        
 [Ticket Source] [nvarchar](max) NULL,        
 [Source Department] [nvarchar](max) NULL,        
 [Turn around Time] [decimal](25, 2) NULL,        
 [Application] [nvarchar](max) NULL,        
 [ApplicationID] [int] NULL,        
 [Application Group Trail] [nvarchar](max) NULL,        
 [TicketLocation] [nvarchar](max) NULL,        
 [Sec Assignee] [nvarchar](max) NULL,        
 [Root Cause] [nvarchar](max) NULL,        
 [Reviewer] [nvarchar](max) NULL,        
 [PriorityChng] [nvarchar](max) NULL,        
 [Service] [nvarchar](max) NULL,        
 [ServiceID] [int] NULL,        
 [EmployeeID] [nvarchar](max) NULL,        
 [EmployeeName] [nvarchar](max) NULL,        
 [External Login ID] [nvarchar](max) NULL,        
 [ProjectID] [int] NOT NULL,        
 [CTIcategory] [nvarchar](max) NULL,        
 [CTItype] [nvarchar](max) NULL,        
 [CTIitem] [nvarchar](max) NULL,        
 [SecAssigneeID] [int] NULL,        
 [UserID] [nvarchar](max) NULL,        
 [SecClientUserID] [nvarchar](max) NULL,        
 [Accountprojectlobid] [int] NULL,        
 [LOBTrackid] [int] NULL,        
 [IsDeleted] [char](1) NULL,        
 [Severity] [nvarchar](max) NULL,        
 [Release Type] [nvarchar](max) NULL,        
 [Planned Effort] [decimal](25, 2) NULL,        
 [Estimated Work Size] [decimal](25, 2) NULL,        
 [Actual Work Size] [decimal](25, 2) NULL,        
 [Planned Start Date and Time] [datetime] NULL,        
 [New Status Date Time] [datetime] NULL,        
 [Resolved date] [datetime] NULL,        
 [Rejected Time Stamp] [datetime] NULL,        
 [Release Date] [datetime] NULL,        
 [KEDBAvailableIndicatorID] [bigint] NULL,        
 [KEDB Available Indicator] [nvarchar](max) NULL,        
 [KEDBupdatedID] [bigint] NULL,        
 [KEDB updated] [nvarchar](max) NULL,        
 [Elevate Flag Internal] [nvarchar](max) NULL,        
 [RCA ID] [nvarchar](max) NULL,        
 [Met Response SLA] [nvarchar](max) NULL,        
 [Met Acknowledgement SLA] [nvarchar](max) NULL,        
 [Met Resolution] [nvarchar](max) NULL,        
 [Response Time] [decimal](25, 2) NULL,        
 [Resolved by] [nvarchar](max) NULL,        
 [Actual Start date Time] [datetime] NULL,        
 [Actual End date Time] [datetime] NULL,        
 [Planned Duration] [decimal](26, 5) NULL,        
 [Actual duration] [decimal](26, 5) NULL,        
 [TicketCreateDate] [datetime] NULL,        
 [Ticket Summary] [nvarchar](max) NULL,        
 [NatureOfTheTicketID] [bigint] NULL,        
 [Nature Of The Ticket] [nvarchar](max) NULL,        
 [Technology] [nvarchar](max) NULL,        
 [Business Impact] [nvarchar](max) NULL,        
 [Job Process Name] [nvarchar](max) NULL,        
 [Server Name] [nvarchar](max) NULL,        
 [Comments] [nvarchar](max) NULL,        
 [Requester Customer Id] [nvarchar](max) NULL,        
 [Requester First Name] [nvarchar](max) NULL,        
 [Requester Internet Email] [nvarchar](max) NULL,        
 [Requester Contact Number] [nvarchar](max) NULL,        
 [Repeated Incident] [nvarchar](max) NULL,        
 [Related Tickets] [nvarchar](max) NULL,        
 [Ticket Created By] [nvarchar](max) NULL,        
 [KEDB Path] [nvarchar](max) NULL,        
 [Requested Resolution Date Time] [date] NULL,        
 [CSAT Score] [decimal](10, 1) NULL,        
 [EscalatedFlagCustomerID] [bigint] NULL,        
 [Escalated Flag Customer] [nvarchar](max) NULL,        
 [Approved Date Time] [date] NULL,        
 [Reviewed Date Time] [date] NULL,        
 [Reason For Rejection] [nvarchar](max) NULL,        
 [Reason For Cancel] [nvarchar](max) NULL,        
 [Reason For On Hold] [nvarchar](max) NULL,        
 [Response SLA Overridden Reason] [nvarchar](max) NULL,        
 [Resolution SLA Overridden Reason] [nvarchar](max) NULL,        
 [Acknowledgement SLA Overridden Reason] [nvarchar](max) NULL,        
 [Type] [nvarchar](max) NULL,        
 [Item] [nvarchar](max) NULL,        
 [Started Date Time] [datetime] NULL,        
 [WIP Date Time] [datetime] NULL,        
 [On Hold Date Time] [datetime] NULL,        
 [Completed Date Time] [datetime] NULL,        
 [Cancelled Date Time] [datetime] NULL,        
 [Approved By] [nvarchar](max) NULL,        
 [Reviewed By] [nvarchar](max) NULL,        
 [Customer Ticket ID] [nvarchar](max) NULL,        
 [Outage Duration] [nvarchar](max) NULL,        
 [OutageFlagID] [bigint] NULL,        
 [Outage Flag] [nvarchar](max) NULL,        
 [WarrantyIssueID] [bigint] NULL,        
 [Warranty Issue] [nvarchar](max) NULL,        
 [ResolutionDetails] [nvarchar](max) NULL,        
 [sourceID] [int] NULL,        
 [severityID] [int] NULL,        
 [releaseTypeID] [int] NULL,        
 [Remarks] [nvarchar](max) NULL,        
 [Assigned Time Stamp] [datetime] NULL,        
 [DARTStatusId] [int] NULL,        
 [DebtClassificationId] [int] NULL,        
 [Debt Classification] [nvarchar](max) NULL,        
 [AvoidableFlagID] [int] NULL,        
 [Avoidable Flag] [nvarchar](max) NULL,        
 [Residual Debt] [nvarchar](max) NULL,        
 [Resolution Method] [nvarchar](max) NULL,        
 [ResidualDebtID] [int] NULL,        
 [Cause code] [nvarchar](max) NULL,        
 [CauseCodeID] [nvarchar](max) NULL,        
 [ITSM Effort] [nvarchar](max) NULL,        
 [Assignment Group] [nvarchar](max) NULL,        
 [Assignment Group ID] [bigint] NULL,        
 [UploadedBy] [nvarchar](max) NULL,        
 [UploadedDate] [datetime] NULL,        
 [Expected Completion Date] [datetime] NULL,        
 [Reason for Residual] [nvarchar](max) NULL,        
 [Resolution Remarks] [nvarchar](max) NULL,        
 [DebtModeID] [bigint] NULL,        
 [Flex Field (1)] [nvarchar](max) NULL,        
 [Flex Field (2)] [nvarchar](max) NULL,        
 [Flex Field (3)] [nvarchar](max) NULL,        
 [Flex Field (4)] [nvarchar](max) NULL,        
 [Category] [nvarchar](max) NULL,        
 TicketUploadTrackID [nvarchar](max) NULL,        
 LastModifiedSource [nvarchar](max) NULL,        
 IsBOT [INT] NULL,        
 IsTicketSummaryModified [BIT] NULL,        
 IsTicketDescriptionModified [BIT] NULL,        
 IsResolutionRemarksModified [BIT] NULL,        
 IsCommentsModified [BIT] NULL,        
 IsCauseCodeModified [BIT] NULL,        
 IsResolutionCodeModified [BIT] NULL,        
 IsFlexField1Modified [BIT] NULL,        
 IsFlexField2Modified [BIT] NULL,        
 IsFlexField3Modified [BIT] NULL,        
 IsFlexField4Modified [BIT] NULL,        
 IsCategoryModified [BIT] NULL,        
 IsTypeModified [BIT] NULL,        
 SupportType [INT] NULL,        
    [InitiatedSource] [nvarchar](max) NULL,        
 TowerName [nvarchar](max) NULL,        
 TowerID BIGINT NULL,        
 IsPartiallyAutomated int NULL,        
        IsGracePeriodMet BIT DEFAULT 0        
 )        
        
 DECLARE @IsPartiallyMapped AS VARCHAR(200)='';         
        
    SELECT @IsPartiallyMapped=ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]  (NOLOCK)         
        
      WHERE  projectid = @projectid           
        
             AND ServiceDartColumn = 'Is Partially Automated' AND IsDeleted = 0        
            
     UPDATE  dbo.TicketUpload set IsPartiallyAutomated=null where projectID = @projectid and TicketUploadTrackID = @TicketUploadTrackID and (IsPartiallyAutomated='0' or IsPartiallyAutomated='')         
        
    if (@IsPartiallyMapped ='')        
     BEGIN        
     UPDATE  dbo.TicketUpload set IsPartiallyAutomated=null where projectID = @projectid and TicketUploadTrackID = @TicketUploadTrackID        
     END        
   ELSE        
     BEGIN        
      UPDATE  dbo.TicketUpload set IsPartiallyAutomated=null where projectID = @projectid and TicketUploadTrackID = @TicketUploadTrackID and (ltrim(rtrim(IsPartiallyAutomated))='' or IsPartiallyAutomated='0')        
      UPDATE  dbo.TicketUpload set IsPartiallyAutomated='InValid' where projectID = @projectid and TicketUploadTrackID = @TicketUploadTrackID and IsPartiallyAutomated is not null AND IsPartiallyAutomated not in        
      (select MetSLAName from AVL.TK_MAS_MetSLACondition (NOLOCK))         
      UPDATE TU SET TU.IsPartiallyAutomated=SLA.MetSLAId FROM dbo.TicketUpload TU          
      INNER JOIN AVL.TK_MAS_MetSLACondition(NOLOCK) SLA         
      ON LTRIM(RTRIM(TU.IsPartiallyAutomated)) =SLA.MetSLAName AND projectID = @projectid and TicketUploadTrackID = @TicketUploadTrackID        
        
        
        
     END        
        
         
  INSERT into #ImportTicketDumpDetails ([Ticket ID],[Ticket Type],[Open Date],Priority,Status,Application,[External Login ID],Assignee,[Modified Date Time],[Reopen Date],[Ticket Description]        
            ,[Close Date],[Ticket Source],[Sec Assignee],[Planned End Date],Severity,[Release Type],[Planned Effort],[Estimated Work Size],[Actual Work Size],        
            [Planned Start Date and Time],[Rejected Time Stamp],[KEDB Available Indicator],[KEDB updated],[Elevate Flag Internal],[RCA ID],[Met Response SLA],        
            [Met Acknowledgement SLA],[Met Resolution],[Resolved by],[Actual Start date Time],[Actual End date Time],[Planned Duration],[Actual duration],        
            [Ticket Summary],[Nature Of The Ticket],Comments,[Repeated Incident],[Related Tickets],[Ticket Created By],[KEDB Path],[Escalated Flag Customer],[Approved By],[Reason For Rejection],[Started Date Time],[WIP Date Time],[On Hold Date Time],    
   
   
            [Completed Date Time],[Cancelled Date Time],[Outage Duration],[Assigned Time Stamp],[Debt Classification],[Avoidable Flag],[Residual Debt],[Resolution Remarks],[Cause code],[Resolution Code],[ITSM Effort],[Assignment Group],        
            [Expected Completion Date],[Reason for Residual],[Flex Field (1)],        
            [Flex Field (2)],[Flex Field (3)],[Flex Field (4)],Category,Type,EmployeeID,EmployeeName,ProjectID,TicketLocation,Reviewer,[Resolution Method],TicketUploadTrackID,IsTicketSummaryModified,IsTicketDescriptionModified,        
            IsResolutionRemarksModified,IsCommentsModified,IsCauseCodeModified,IsResolutionCodeModified,IsFlexField1Modified,        
            IsFlexField2Modified,IsFlexField3Modified,IsFlexField4Modified,IsCategoryModified,IsTypeModified,TowerName,IsPartiallyAutomated,IsGracePeriodMet,        
            [TicketDescriptionBasePattern], [TicketDescriptionSubPattern], [ResolutionRemarksBasePattern], [ResolutionRemarksSubPattern],        
            [Service])        
  Select         
REPLACE(REPLACE(TicketID,'<',''),'>','')AS TicketID,        
REPLACE(REPLACE(TicketType,'<',''),'>','')AS TicketType,        
REPLACE(REPLACE(OpenDate,'<',''),'>','')AS OpenDate,        
REPLACE(REPLACE(Priority,'<',''),'>','')AS Priority,        
REPLACE(REPLACE(Status,'<',''),'>','')AS Status,        
REPLACE(REPLACE(Application,'<',''),'>','')AS Application,        
REPLACE(REPLACE(ExternalLoginID,'<',''),'>','')AS ExternalLoginID,        
REPLACE(REPLACE(Assignee,'<',''),'>','')AS Assignee,        
REPLACE(REPLACE(ModifiedDateTime,'<',''),'>','')AS ModifiedDateTime,      
REPLACE(REPLACE(ReopenDate,'<',''),'>','')AS ReopenDate,        
REPLACE(REPLACE(TicketDescription,'<',''),'>','')AS TicketDescription,        
REPLACE(REPLACE(CloseDate,'<',''),'>','')AS CloseDate,        
REPLACE(REPLACE(Ticketsource,'<',''),'>','')AS Ticketsource,        
REPLACE(REPLACE(SecAssignee,'<',''),'>','')AS SecAssignee,        
REPLACE(REPLACE(PlannedEndDate,'<',''),'>','')AS PlannedEndDate,        
REPLACE(REPLACE(Severity,'<',''),'>','')AS Severity,        
REPLACE(REPLACE(ReleaseType,'<',''),'>','')AS ReleaseType,        
REPLACE(REPLACE(PlannedEffort,'<',''),'>','')AS PlannedEffort,        
REPLACE(REPLACE(EstimatedWorkSize,'<',''),'>','')AS EstimatedWorkSize,        
REPLACE(REPLACE(ActualWorkSize,'<',''),'>','')AS ActualWorkSize,        
REPLACE(REPLACE(PlannedStartDateandTime,'<',''),'>','')AS PlannedStartDateandTime,        
REPLACE(REPLACE(RejectedTimeStamp,'<',''),'>','')AS RejectedTimeStamp,        
REPLACE(REPLACE(KEDBAvailableIndicator,'<',''),'>','')AS KEDBAvailableIndicator,        
REPLACE(REPLACE(KEDBupdated,'<',''),'>','')AS KEDBupdated,        
REPLACE(REPLACE(ElevateFlagInternal,'<',''),'>','')AS ElevateFlagInternal,        
REPLACE(REPLACE(RCAID,'<',''),'>','')AS RCAID,        
REPLACE(REPLACE(MetResponseSLA,'<',''),'>','')AS MetResponseSLA,        
REPLACE(REPLACE(MetAcknowledgementSLA,'<',''),'>','')AS MetAcknowledgementSLA,        
REPLACE(REPLACE(MetResolution,'<',''),'>','')AS MetResolution,        
REPLACE(REPLACE(Resolvedby,'<',''),'>','')AS Resolvedby,        
REPLACE(REPLACE(ActualStartdateTime,'<',''),'>','')AS ActualStartdateTime,        
REPLACE(REPLACE(ActualEnddateTime,'<',''),'>','')AS ActualEnddateTime,        
REPLACE(REPLACE(PlannedDuration,'<',''),'>','')AS PlannedDuration,        
REPLACE(REPLACE(Actualduration,'<',''),'>','')AS Actualduration,        
REPLACE(REPLACE(TicketSummary,'<',''),'>','')AS TicketSummary,        
REPLACE(REPLACE(NatureOfTheTicket,'<',''),'>','')AS NatureOfTheTicket,        
REPLACE(REPLACE(Comments,'<',''),'>','')AS Comments,        
REPLACE(REPLACE(RepeatedIncident,'<',''),'>','')AS RepeatedIncident,        
REPLACE(REPLACE(RelatedTickets,'<',''),'>','')AS RelatedTickets,        
REPLACE(REPLACE(TicketCreatedBy,'<',''),'>','')AS TicketCreatedBy,        
REPLACE(REPLACE(KEDBPath,'<',''),'>','')AS KEDBPath,        
REPLACE(REPLACE(EscalatedFlagCustomer,'<',''),'>','')AS EscalatedFlagCustomer,        
REPLACE(REPLACE(ApprovedBy,'<',''),'>','')AS ApprovedBy,        
REPLACE(REPLACE(ReasonForRejection,'<',''),'>','')AS ReasonForRejection,        
REPLACE(REPLACE(StartedDateTime,'<',''),'>','')AS StartedDateTime,        
REPLACE(REPLACE(WIPDateTime,'<',''),'>','')AS WIPDateTime,        
REPLACE(REPLACE(OnHoldDateTime,'<',''),'>','')AS OnHoldDateTime,        
REPLACE(REPLACE(CompletedDateTime,'<',''),'>','')AS CompletedDateTime,        
REPLACE(REPLACE(CancelledDateTime,'<',''),'>','')AS CancelledDateTime,        
REPLACE(REPLACE(OutageDuration,'<',''),'>','')AS OutageDuration,        
REPLACE(REPLACE(AssignedTimeStamp,'<',''),'>','')AS AssignedTimeStamp,        
REPLACE(REPLACE(DebtClassification,'<',''),'>','')AS DebtClassification,        
REPLACE(REPLACE(AvoidableFlag,'<',''),'>','')AS AvoidableFlag,        
REPLACE(REPLACE(ResidualDebt,'<',''),'>','')AS ResidualDebt,        
REPLACE(REPLACE(ResolutionRemarks,'<',''),'>','')AS ResolutionRemarks,        
REPLACE(REPLACE(Causecode,'<',''),'>','')AS Causecode,        
REPLACE(REPLACE(ResolutionCode,'<',''),'>','')AS ResolutionCode,        
REPLACE(REPLACE(ITSMEffort,'<',''),'>','')AS ITSMEffort,        
REPLACE(REPLACE(AssignmentGroup,'<',''),'>','')AS AssignmentGroup,        
REPLACE(REPLACE(ExpectedCompletionDate,'<',''),'>','')AS ExpectedCompletionDate,        
REPLACE(REPLACE(ReasonforResidual,'<',''),'>','')AS ReasonforResidual,        
REPLACE(REPLACE(FlexField1,'<',' '),'>',' ')AS FlexField1,        
REPLACE(REPLACE(FlexField2,'<',' '),'>',' ')AS FlexField2,        
REPLACE(REPLACE(FlexField3,'<',' '),'>',' ')AS FlexField3,        
REPLACE(REPLACE(FlexField4,'<',' '),'>',' ')AS FlexField4,        
REPLACE(REPLACE(Category,'<',''),'>','')AS Category,        
REPLACE(REPLACE(Type,'<',''),'>','')AS Type,        
REPLACE(REPLACE(EmployeeID,'<',''),'>','')AS EmployeeID,        
REPLACE(REPLACE(EmployeeName,'<',''),'>','')AS EmployeeName,        
REPLACE(REPLACE(ProjectID,'<',''),'>','')AS ProjectID,        
REPLACE(REPLACE(Causecode,'<',''),'>','')AS TicketLocation,        
REPLACE(REPLACE(ResolutionCode,'<',''),'>','')AS Reviewer,        
REPLACE(REPLACE(ResolutionRemarks,'<',''),'>','')AS [Resolution Method],        
REPLACE(REPLACE(TicketUploadTrackID,'<',''),'>','')AS TicketUploadTrackID,        
   IsTicketSummaryModified,        
   IsTicketDescriptionModified,        
   1,        
   1,        
   1,        
   1,        
   1,        
   1,        
   1,        
   1,        
   1,        
   1,        
REPLACE(REPLACE(Tower,'<',''),'>','')AS Tower,        
REPLACE(REPLACE(IsPartiallyAutomated,'<',''),'>','')AS IsPartiallyAutomated,        
                        0 AS IsGracePeriodMet,        
REPLACE(REPLACE([TicketDescriptionBasePattern] ,'<',''),'>','')AS TicketDescriptionBasePattern,        
REPLACE(REPLACE([TicketDescriptionSubPattern] ,'<',''),'>','')AS TicketDescriptionSubPattern,        
REPLACE(REPLACE([ResolutionRemarksBasePattern] ,'<',''),'>','')AS ResolutionRemarksBasePattern,        
REPLACE(REPLACE([ResolutionRemarksSubPattern] ,'<',''),'>','')AS ResolutionRemarksSubPattern,        
REPLACE(REPLACE([ServiceName] ,'<',''),'>','')AS ServiceName        
        
  From [dbo].[TicketUpload](NOLOCK) where projectID = @projectid and TicketUploadTrackID = @TicketUploadTrackID        
        
         
        
      DECLARE @DuplicateCount INT = 0           
        
      DECLARE @AttributeModififedDateTime DATETIME = Getdate()           
        
 DECLARE @TotalCount AS INT           
        
      DECLARE @FailCnt AS INT           
        
      DECLARE @REMARKS AS VARCHAR(50)           
        
      DECLARE @UploadCnt INT=0           
        
      DECLARE @UploadstartTime DATETIME           
        
      DECLARE @ReuploadedCount INT=0           
        
 DECLARE @GracePeriodValue INT        
        
   ----*********Check to met Grace Period Or Not**************----        
   SELECT TOP 1 @GracePeriodValue=GracePeriod FROM [AVL].[MAS_ProjectDebtDetails] With(nolock) WHERE ProjectID=@projectid AND IsDeleted<>1        
          
   UPDATE D        
         SET D.IsGracePeriodMet=1 FROM #ImportTicketDumpDetails(NOLOCK) D         
   LEFT JOIN  [AVL].[tk_map_projectstatusmapping](NOLOCK) B  ON B.statusname = D.status  AND B.projectid = D.projectid  AND B.isdeleted = 0        
   WHERE         
   B.ProjectID=@projectid AND        
   ( (Convert(date, (DATEADD(DAY,@GracePeriodValue,D.[Close Date])))< Convert(date, GETDATE()) AND B.TicketStatus_ID=8 AND D.[Close Date] IS NOT NULL AND        
   D.[Close Date] != '') OR         
    (Convert(date, (DATEADD(DAY,@GracePeriodValue,D.[Completed Date Time])))< Convert(date, GETDATE()) AND B.TicketStatus_ID=9 AND D.[Completed Date Time] IS NOT NULL        
    AND D.[Completed Date Time] != '')) --STATUS        
        
  --** APP Heal child Tickets**--        
  UPDATE DumpTic SET DumpTic.IsGracePeriodMet=1 FROM #ImportTicketDumpDetails(NOLOCK) DumpTic          
     INNER JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) CH ON CH.DARTTicketID =DumpTic.[Ticket ID]        
  INNER JOIN AVL.DEBT_TRN_HealTicketDetails(NOLOCK) HTD ON HTD.ProjectPatternMapId = CH.ProjectPatternMapId        
  INNER JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic(NOLOCK) HPPM ON HPPM.ProjectPatternMapId = HTD.ProjectPatternMapId        
  AND HPPM.ProjectID = @projectid AND CH.MapStatus=1 AND CH.IsDeleted<>1        
        
    --** Infra Heal child Tickets**--        
  UPDATE DumpTic SET DumpTic.IsGracePeriodMet=1 FROM #ImportTicketDumpDetails DumpTic          
     INNER JOIN AVL.DEBT_PRJ_InfraHealParentChild(NOLOCK) INFRACH ON INFRACH.DARTTicketID =DumpTic.[Ticket ID]        
  INNER JOIN AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) HTD ON HTD.ProjectPatternMapId = INFRACH.ProjectPatternMapId        
  INNER JOIN AVL.DEBT_PRJ_InfraHealProjectPatternMappingDynamic(NOLOCK) HPPM ON HPPM.ProjectPatternMapId = HTD.ProjectPatternMapId        
  AND HPPM.ProjectID = @projectid AND INFRACH.MapStatus=1 AND INFRACH.IsDeleted<>1        
        
     ----********* END *********************--        
          
   IF @CogID IS NULL OR RTRIM(LTRIM(@CogID))=''          
   BEGIN          
   SELECT TOP 1  @CogID=EmployeeID FROM #ImportTicketDumpDetails(NOLOCK)          
   WHERE ProjectID=@projectid;          
   END           
        
             
      SET @UploadstartTime = Getdate()           
        
       --Consider first 100 characters for flex fields        
        
     UPDATE #ImportTicketDumpDetails SET [Flex Field (1)] = CASE        
  WHEN LEN([Flex Field (1)]) >= 100 THEN Substring([Flex Field (1)],1,100)         
  ELSE [Flex Field (1)]        
  END          
  WHERE projectID = @projectid AND TicketUploadTrackID = @TicketUploadTrackID        
        
  UPDATE #ImportTicketDumpDetails SET [Flex Field (2)] = CASE        
  WHEN LEN([Flex Field (2)]) >= 100 THEN Substring([Flex Field (2)],1,100)         
  ELSE [Flex Field (2)]        
  END          
  WHERE projectID = @projectid AND TicketUploadTrackID = @TicketUploadTrackID        
        
  UPDATE #ImportTicketDumpDetails SET [Flex Field (3)] = CASE        
  WHEN LEN([Flex Field (3)]) >= 100 THEN Substring([Flex Field (3)],1,100)         
  ELSE [Flex Field (3)]        
  END          
  WHERE projectID = @projectid AND TicketUploadTrackID = @TicketUploadTrackID        
        
  UPDATE #ImportTicketDumpDetails SET [Flex Field (4)] = CASE        
  WHEN LEN([Flex Field (4)]) >= 100 THEN Substring([Flex Field (4)],1,100)         
  ELSE [Flex Field (4)]        
  END          
  WHERE projectID = @projectid AND TicketUploadTrackID = @TicketUploadTrackID        
        
              
           
   UPDATE #ImportTicketDumpDetails           
      SET    priority = Ltrim(Rtrim(priority)),          
             status = Ltrim(Rtrim(status)),          
             application = Ltrim(Rtrim(application))           
      WHERE  projectid = @projectid          
        
      UPDATE #ImportTicketDumpDetails            
      SET    uploadedby =  @CogID          
      WHERE  projectid = @projectid          
           
   -- Limiting work pattern columns to 250 characters        
          
  UPDATE #ImportTicketDumpDetails SET [TicketDescriptionBasePattern] = CASE        
  WHEN LEN([TicketDescriptionBasePattern]) >= 250 THEN Substring([TicketDescriptionBasePattern],1,250)         
  ELSE [TicketDescriptionBasePattern]        
  END          
  WHERE projectID = @projectid AND TicketUploadTrackID = @TicketUploadTrackID        
        
   UPDATE #ImportTicketDumpDetails SET [TicketDescriptionSubPattern] = CASE        
  WHEN LEN([TicketDescriptionSubPattern]) >= 250 THEN Substring([TicketDescriptionSubPattern],1,250)         
  ELSE [TicketDescriptionSubPattern]        
  END          
  WHERE projectID = @projectid AND TicketUploadTrackID = @TicketUploadTrackID        
        
    UPDATE #ImportTicketDumpDetails SET [ResolutionRemarksBasePattern] = CASE        
  WHEN LEN([ResolutionRemarksBasePattern]) >= 250 THEN Substring([ResolutionRemarksBasePattern],1,250)         
  ELSE [ResolutionRemarksBasePattern]        
  END          
  WHERE projectID = @projectid AND TicketUploadTrackID = @TicketUploadTrackID        
        
    UPDATE #ImportTicketDumpDetails SET [ResolutionRemarksSubPattern] = CASE        
  WHEN LEN([ResolutionRemarksSubPattern]) >= 250 THEN Substring([ResolutionRemarksSubPattern],1,250)         
  ELSE [ResolutionRemarksSubPattern]        
  END          
  WHERE projectID = @projectid AND TicketUploadTrackID = @TicketUploadTrackID        
          
        
        
      UPDATE #ImportTicketDumpDetails          
      SET    [actual end date time] = CASE Year([actual end date time])           
                                        WHEN 1900 THEN NULL            
                                        ELSE [actual end date time]           
                                      END         
   WHERE  projectid = @projectid             
        
      UPDATE #ImportTicketDumpDetails           
      SET    [actual start date time] = CASE Year([actual start date time])          
                                          WHEN 1900 THEN NULL          
                                  ELSE [actual start date time]           
                                        END            
      WHERE  projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails           
      SET    [approved date time] = CASE Year([approved date time])           
                                      WHEN 1900 THEN NULL           
                                      ELSE [approved date time]           
                                    END           
      WHERE projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails            
      SET    arrivaldate = CASE Year(arrivaldate)           
                             WHEN 1900 THEN NULL            
                             ELSE arrivaldate          
                           END           
      WHERE  projectid = @projectid            
        
      UPDATE #ImportTicketDumpDetails           
      SET    [assigned time stamp] = CASE Year([assigned time stamp])           
                                       WHEN 1900 THEN NULL          
                                  ELSE [assigned time stamp]          
                                     END           
      WHERE  projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails             
      SET    [cancelled date time] = CASE Year([cancelled date time])          
                                       WHEN 1900 THEN NULL            
                                       ELSE [cancelled date time]          
                                     END          
      WHERE  projectid = @projectid         
        
      UPDATE #ImportTicketDumpDetails           
      SET    [close date] = CASE Year([close date])           
                                WHEN 1900 THEN NULL           
                                ELSE [close date]          
       END           
      WHERE projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails           
      SET    [completed date time] = CASE Year([completed date time])           
                                         WHEN 1900 THEN NULL    
                                         ELSE [completed date time]           
                                       END           
      WHERE  projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails           
      SET    [modified date time] = CASE Year([modified date time])           
                                        WHEN 1900 THEN NULL           
                                        ELSE [modified date time]           
                                      END           
      WHERE  projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails           
      SET    [new status date time] = CASE Year([new status date time])           
                                      WHEN 1900 THEN NULL           
                                      ELSE [new status date time]           
                                      END           
      WHERE  projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails           
      SET    [on hold date time] = CASE Year([on hold date time])           
                                     WHEN 1900 THEN NULL           
                                     ELSE [on hold date time]           
                                   END           
      WHERE  projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails           
      SET    [open date] = CASE Year([open date])           
                            WHEN 1900 THEN NULL           
                            ELSE [open date]           
                         END           
      WHERE  projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails           
      SET    [planned end date] = CASE Year([planned end date])           
                                   WHEN 1900 THEN NULL           
                                  ELSE [planned end date]           
                                  END           
      WHERE  projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails           
      SET [planned start date and time] =           
            CASE Year([planned start date and time])         
             WHEN 1900 THEN NULL           
             ELSE [planned start date and time]           
      END           
      WHERE  projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails           
      SET    [rejected time stamp] = CASE Year([rejected time stamp])           
                                         WHEN 1900 THEN NULL           
                                         ELSE [rejected time stamp]           
                                       END           
        WHERE  projectid = @projectid           
        
      UPDATE #ImportTicketDumpDetails           
        
      SET    [release date] = CASE Year([release date])           
                WHEN 1900 THEN NULL           
                                 ELSE [release date]           
               END           
      WHERE  projectid = @projectid           
        
            
      UPDATE #ImportTicketDumpDetails           
        
      SET    [reopen date] = CASE Year([reopen date])           
                                 WHEN 1900 THEN NULL           
                                 ELSE [reopen date]           
                               END           
      WHERE  projectid = @projectid           
        
          
      UPDATE #ImportTicketDumpDetails           
        
      SET    [requested resolution date time] =           
        
        CASE Year([requested resolution date time])           
        
               WHEN 1900 THEN NULL           
        
               ELSE           
        
             [requested resolution date time]           
        
                                                END           
        
      WHERE  projectid = @projectid           
        
          
        
      UPDATE #ImportTicketDumpDetails           
        
      SET    [resolved date] = CASE Year([resolved date])           
      
                                 WHEN 1900 THEN NULL           
        
                                 ELSE [resolved date]           
        
      END           
        
      WHERE  projectid = @projectid           
        
          
        
     UPDATE #ImportTicketDumpDetails           
        
      SET    [reviewed date time] = CASE Year([reviewed date time])           
        
 WHEN 1900 THEN NULL           
        
                                      ELSE [reviewed date time]         
        
                                    END           
        
      WHERE  projectid = @projectid           
        
        
        
UPDATE #ImportTicketDumpDetails           
        
      SET    [started date time] = CASE Year([started date time])           
        
                                     WHEN 1900 THEN NULL           
                                     ELSE [started date time]           
        
                                   END           
        
      WHERE  projectid = @projectid           
        
          
        
      UPDATE #ImportTicketDumpDetails           
        
      SET    ticketcreatedate = CASE Year(ticketcreatedate)           
        
                                  WHEN 1900 THEN NULL           
        
                                  ELSE ticketcreatedate           
        
                                END           
        
      WHERE  projectid = @projectid           
        
          
        
      UPDATE #ImportTicketDumpDetails           
        
      SET    [wip date time] = CASE Year([wip date time])           
        
                                 WHEN 1900 THEN NULL           
        
                                 ELSE [wip date time]           
        
                               END           
        
      WHERE  projectid = @projectid           
        
        
   UPDATE #ImportTicketDumpDetails        
   SET [Expected Completion Date]=CASE Year([Expected Completion Date])           
        
                                 WHEN 1900 THEN NULL           
        
                                 ELSE [Expected Completion Date]           
        
                               END           
        
      WHERE  projectid = @projectid           
        
          
        
                 
        
      UPDATE #ImportTicketDumpDetails           
        
      SET    [avoidable flag] = CASE [avoidable flag]           
        
                                  WHEN '' THEN NULL           
        
                                  WHEN NULL THEN NULL           
        
                                  ELSE [avoidable flag]           
        
                                END           
        
      WHERE  projectid = @projectid           
        
          
        
      UPDATE #ImportTicketDumpDetails           
        
      SET    [residual debt] = CASE [residual debt]           
        
                                 WHEN '' THEN NULL           
        
                                 ELSE [residual debt]           
        
                               END           
        
      WHERE  projectid = @projectid           
        
          
        
      UPDATE #ImportTicketDumpDetails           
        
      SET    [debt classification] = CASE [debt classification]           
        
                                       WHEN '' THEN NULL           
        
                                       ELSE [debt classification]           
        
                                     END           
        
      WHERE  projectid = @projectid           
        
          
        
      UPDATE #ImportTicketDumpDetails           
        
      SET    [turn around time] = Round(Datediff(minute, [open date],           
        
                                        [close date]           
        
                                        ), 2)           
        
      WHERE  projectid = @projectid           
        
             AND [open date] IS NOT NULL          
        
             AND [close date] IS NOT NULL           
        
             AND Year([close date]) <> 1900           
        
             AND Year([open date]) <> 1900           
        
             AND [close date] <> ''           
        
           
  IF ( @Flag = 'N' )           
        
        BEGIN           
        
            UPDATE x           
        
            SET    x.tickettypeid = D.tickettypemappingid,           
        
                   x.priorityid = A.priorityidmapid,           
        
                   x.statusid = B.statusid,           
        
                   x.userid = C.userid,           
        
                   x.assignee = C.userid,           
        
                   x.dartstatusid = B.ticketstatus_id,        
        
       x.IsBOT = 0           
        
            FROM   #ImportTicketDumpDetails(NOLOCK) x           
        
                   LEFT JOIN [AVL].[tk_map_tickettypemapping](NOLOCK) D           
        
                          ON Ltrim(Rtrim(upper(D.tickettype))) = Ltrim(Rtrim(upper(x.[ticket type] )))          
        
                             AND D.isdeleted = 0           
        
              AND D.projectid = x.projectid           
        
            AND D.projectid = @projectid           
        
                   LEFT JOIN [AVL].[tk_mas_tickettype](NOLOCK) F           
        
                          ON F.[tickettypeid] = D.avmtickettype        
        
              LEFT JOIN [AVL].[tk_map_prioritymapping](NOLOCK) A           
        
        ON A.priorityname = x.priority           
        
                             AND A.projectid = X.projectid           
        
                             AND A.isdeleted = 0           
        
                             AND A.projectid = @projectid           
        
                   LEFT JOIN [AVL].[tk_map_projectstatusmapping](NOLOCK) B           
        
                          ON B.statusname = x.status           
        
                             AND B.projectid = x.projectid           
        
                             AND B.isdeleted = 0           
        
                             AND B.projectid = @projectid           
        
                   LEFT OUTER JOIN [AVL].[mas_loginmaster](NOLOCK) AS C           
        
                                -- ON C.clientuserid = x.[External Login ID]         
        ON (x.[External Login ID] IS NOT NULL AND x.[External Login ID]!='' AND C.clientuserid = x.[External Login ID]  )            
        
                                   AND C.projectid = x.projectid           
        
AND C.isdeleted = 0           
        
            WHERE  x.projectid = @projectid           
        
        END           
        
      ELSE IF ( @Flag = 'Y' )           
        
        BEGIN           
        
            UPDATE x           
        
            SET    x.tickettypeid = D.tickettypemappingid,           
        
                   x.priorityid = A.priorityidmapid,           
        
                   x.statusid = B.statusid,           
        
                   x.userid = C.userid,           
        
                   x.assignee = C.userid,           
        
                   x.dartstatusid = B.ticketstatus_id,        
        
       x.IsBOT = 0           
        
            FROM   #ImportTicketDumpDetails(NOLOCK) x           
        
                   LEFT JOIN [AVL].[tk_map_tickettypemapping](NOLOCK) D           
        
                          ON Ltrim(Rtrim(upper(D.tickettype))) = Ltrim(Rtrim(upper(x.[ticket type])))           
        
                             AND D.isdeleted = 0           
        
                             AND D.projectid = x.projectid           
        
                             AND D.projectid = @projectid           
        
                   LEFT JOIN [AVL].[tk_mas_tickettype](NOLOCK) F           
        
                          ON F.[tickettypeid] = D.avmtickettype           
        
                   LEFT JOIN [AVL].[tk_map_prioritymapping](NOLOCK) A           
        
                          ON A.priorityname = x.priority           
        
                             AND A.projectid = X.projectid           
        
                             AND A.isdeleted = 0           
        
                             AND A.projectid = @projectid           
        
                   LEFT JOIN [AVL].[tk_map_projectstatusmapping](NOLOCK) B           
        
                          ON B.statusname = x.status           
        
                             AND B.projectid = x.projectid           
        
                       AND B.isdeleted = 0           
        
                             AND B.projectid = @projectid           
        
                   LEFT OUTER JOIN [AVL].[mas_loginmaster](NOLOCK) AS C           
        
                  -- ON C.clientuserid = x.[External Login ID]           
        ON (x.[External Login ID] IS NOT NULL AND x.[External Login ID]!='' AND C.clientuserid = x.[External Login ID])        
                                   AND C.projectid = x.projectid           
        
            WHERE  x.projectid = @projectid           
        
        END           
        
      ELSE           
        
BEGIN           
            UPDATE x           
        
            SET    x.tickettypeid = D.tickettypemappingid,           
        
                   x.priorityid = A.priorityidmapid,           
        
                   x.statusid = B.statusid,           
        
                   x.userid = C.userid,           
        
                   x.assignee = C.userid,           
        
     x.dartstatusid = B.ticketstatus_id,        
        
       x.IsBOT = 0           
        
            FROM   #ImportTicketDumpDetails(NOLOCK) x           
        
                   LEFT JOIN [AVL].[tk_map_tickettypemapping](NOLOCK) D           
        
                          ON Ltrim(Rtrim(upper(D.tickettype))) = Ltrim(Rtrim(upper(x.[ticket type])))           
        
                   AND D.isdeleted = 0           
        
                             AND D.projectid = x.projectid           
        
                             AND D.projectid = @projectid           
        
                   LEFT JOIN [AVL].[tk_mas_tickettype](NOLOCK) F           
        
                          ON F.[tickettypeid] = D.avmtickettype           
        
                   LEFT JOIN [AVL].[tk_map_prioritymapping](NOLOCK) A           
        
                          ON A.priorityname = x.priority           
        
                             AND A.projectid = X.projectid           
        
                             AND A.isdeleted = 0           
        
                             AND A.projectid = @projectid           
        
                   LEFT JOIN [AVL].[tk_map_projectstatusmapping](NOLOCK) B           
        
   ON B.statusname = x.status           
        
                             AND B.projectid = x.projectid           
        
                             AND B.isdeleted = 0           
        
                             AND B.projectid = @projectid           
        
                   LEFT JOIN [AVL].[mas_loginmaster](NOLOCK) AS C           
        
        -- ON C.clientuserid = x.[External Login ID]           
        ON (x.[External Login ID] IS NOT NULL AND x.[External Login ID]!='' and C.clientuserid = x.[External Login ID] )            
        
           AND C.projectid = x.projectid           
        
                                   AND C.isdeleted = 0           
        
            WHERE  x.projectid = @projectid          
        
          
        END          
        
          
  --Update Assignee,UserID and Isbot Based on AssignmentGroupMapping        
  UPDATE x           
        
  SET   x.Assignee = Y.AssignmentGroupMapID, x.UserID= Y.AssignmentGroupMapID, x.IsBOT =1,x.SupportType = y.SupportTypeID            
        
  FROM   #ImportTicketDumpDetails(NOLOCK) x           
        
  INNER JOIN [AVL].[BOTAssignmentGroupMapping](NOLOCK) Y ON Upper(Ltrim(Rtrim(Y.AssignmentGroupName))) = Upper(Ltrim(Rtrim(x.[External Login ID])))      
        
  where y.ProjectID = @projectid and y.IsBOTGroup = 1 and  y.IsDeleted = 0 and y.AssignmentGroupCategoryTypeID = 1         
        
        
  --Update SupportType Based on the Assignee mapping to assignment Group         
  UPDATE x           
        
  SET    x.SupportType = y.SupportTypeID          
        
  FROM   #ImportTicketDumpDetails(NOLOCK) x           
        
  INNER JOIN AVL.UserAssignmentGroupMapping(nolock) AGM ON  AGM.UserId = x.Assignee AND AGM.ProjectId = @projectid        
        
  INNER JOIN [AVL].[BOTAssignmentGroupMapping](NOLOCK) Y ON y.AssignmentGroupMapID = AGM.AssignmentGroupMapID        
        
  WHERE AGM.Isdeleted = 0 AND x.Assignee is not NULL           
        
        
  --Update AssignmentGroupMapID and Isbot Based on AssignmentGroupMapping         
  UPDATE x           
        
  SET    x.[Assignment Group ID] = Y.AssignmentGroupMapID,x.IsBOT =y.IsBOTGroup,x.SupportType = y.SupportTypeID          
        
  FROM   #ImportTicketDumpDetails(NOLOCK) x           
        
  INNER JOIN [AVL].[BOTAssignmentGroupMapping](NOLOCK) Y ON Upper(Ltrim(Rtrim(Y.AssignmentGroupName))) = Upper(Ltrim(Rtrim(x.[Assignment Group])))          
        
  where y.ProjectID = @projectid and  y.IsDeleted = 0 and y.AssignmentGroupCategoryTypeID = 2         
        
        
        
  --Update AssignmentGroupMapID Based on External Login ID        
        
  UPDATE x           
        
  SET    x.Assignee = Y.AssignmentGroupMapID,x.IsBOT =y.IsBOTGroup        
        
  FROM   #ImportTicketDumpDetails(NOLOCK) x           
        
  INNER JOIN [AVL].[BOTAssignmentGroupMapping](NOLOCK) Y ON Upper(Ltrim(Rtrim(Y.AssignmentGroupName))) = Upper(Ltrim(Rtrim(x.[External Login ID])))          
        
  AND y.ProjectID=x.ProjectID        
        
  where y.ProjectID = @projectid and  y.IsDeleted = 0 and y.AssignmentGroupCategoryTypeID = 1 and x.IsBOT =0 AND y.IsBOTGroup=1        
        
        and ((x.[Assignment Group] is not null and x.[Assignment Group ID] is null) or (x.[Assignment Group] != '' and x.[Assignment Group ID] != ''))       
        
        
  --Update AssignmentGroupMapID Based on External Login ID        
        
  UPDATE x           
        
  SET    x.Assignee = Y.AssignmentGroupMapID         
        
  FROM   #ImportTicketDumpDetails(NOLOCK) x           
        
  LEFT JOIN [AVL].[BOTAssignmentGroupMapping](NOLOCK) Y ON Upper(Ltrim(Rtrim        
        
  (Y.AssignmentGroupName))) = Upper(Ltrim(Rtrim(x.[External Login ID])))          
        
  where y.ProjectID = @projectid and  y.AssignmentGroupName IS NULL AND  y.IsDeleted = 0 and y.AssignmentGroupCategoryTypeID = 1 and x.IsBOT =0 AND y.IsBOTGroup=1        
        
        and (x.[Assignment Group] is not null and x.[Assignment Group ID] is null) or (x.[Assignment Group] != '' and x.[Assignment Group ID] != '')        
          
        
  --Update Tower Based on the Mapping TO Project        
  update x         
        
  SET x.TowerID = ITD.InfraTowerTransactionID        
        
  FROM   #ImportTicketDumpDetails(NOLOCK) x        
        
  INNER JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) ITD on Upper(Ltrim(Rtrim(ITD.TowerName)))= Upper(Ltrim(Rtrim(x.TowerName)))         
        
  INNER JOIN AVL.InfraTowerProjectMapping (NOLOCK) ITPM on ITPM.TowerID = ITD.InfraTowerTransactionID        
        
  where ITPM.ProjectID = @projectid and ITD.IsDeleted = 0 and ITPM.IsDeleted = 0 and ITPM.IsEnabled = 1        
        
        
  --Update support Type base on the project if  Assignee exists and Assignment group not exists         
  UPDATE x           
        
  SET    x.SupportType = PC.SupportTypeID        
        
  FROM   #ImportTicketDumpDetails(NOLOCK) x         
        
  INNER JOIN AVL.MAP_ProjectConfig(NOLOCK) PC ON PC.ProjectID = X.ProjectID        
        
  WHERE (x.SupportType is NULL or x.SupportType = '') and x.[Assignment Group ID] is NULL and x.Assignee IS NOT NULL and pc.ProjectID = @projectid        
        
        
  --Update support Type base on the project if  Assignee not exists and Assignment group not exists         
  UPDATE x           
        
  SET    x.SupportType = PC.SupportTypeID        
        
  FROM   #ImportTicketDumpDetails(NOLOCK) x         
        
  INNER JOIN AVL.MAP_ProjectConfig(NOLOCK) PC ON PC.ProjectID = X.ProjectID        
        
  WHERE (x.SupportType is NULL or x.SupportType = '') and x.[Assignment Group ID] is NULL and x.Assignee is NULL and pc.ProjectID = @projectid        
        
          
  --Update Assignment group based Tower Mapping         
  update x           
          
  SET x.TowerID = TAG.TowerId , x.TowerName = ITDT.TowerName        
          
  FROM   #ImportTicketDumpDetails(NOLOCK) x          
          
  INNER JOIN PP.TowerAssignmentGroupMapping(NOLOCK) TAG on x.[Assignment Group ID]  = TAG.AssignmentGroupMapId        
        
  INNER JOIN [AVL].[InfraTowerDetailsTransaction](NOLOCK) ITDT on ITDT.InfraTowerTransactionID = TAG.TowerId        
           
  where TAG.ProjectId = @projectid and TAG.IsDeleted = 0 and x.SupportType = 2 and (x.TowerID is NULL OR x.TowerName is NULL)        
          
  --Update TicketType base on the Supporttype not matching with the perticular tickettype Mappring        
  UPDATE x           
        
  SET    x.TicketTypeID = -1        
        
  FROM   #ImportTicketDumpDetails(NOLOCK) x         
        
  INNER JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TT ON TT.TicketTypeMappingID = x.TicketTypeID and TT.SupportTypeID <> x.SupportType        
        
  WHERE TT.ProjectID = @projectid and TT.IsDeleted = 0 AND TT.SupportTypeID <> 3 and x.SupportType <> 3        
        
            
        
        
     --Filtering the AssignmentGroup from UserID for the Identification of NONAssignmentGroup        
  CREATE TABLE #AssignmentGroup        
  (        
        
   AssignmentGroupMapID bigint,        
   AssignmentGroupName nvarchar(200),        
   IsBOTGroup bit,        
   ProjectID bigint        
  )        
        
  insert into #AssignmentGroup        
  select AssignmentGroupMapID,AssignmentGroupName,IsBOTGroup,IsDeleted from [AVL].[BOTAssignmentGroupMapping] (NOLOCK)        
  WHERE ProjectID = @projectid and IsDeleted = 0 and AssignmentGroupCategoryTypeID = 2        
        
        
  --Not configered Assignment Group is update as -1        
  UPDATE x           
        
  SET    x.[Assignment Group ID] = -1         
        
  FROM   #ImportTicketDumpDetails(NOLOCK) x           
        
  LEFT JOIN #AssignmentGroup Y ON Upper(Ltrim(Rtrim(x.[Assignment Group])))  = Upper(Ltrim(Rtrim(Y.AssignmentGroupName)))        
        
  where  y.AssignmentGroupName IS NULL  and x.[Assignment Group] is not NULL         
        
        
        
        
   UPDATE x           
        
      SET    x.applicationid = Y.applicationid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) x           
        
             INNER JOIN [AVL].[app_mas_applicationdetails](NOLOCK) Y           
        
                     ON Ltrim(Rtrim(Y.applicationname)) = x.application           
        
                        AND Y.isactive = 1           
        
             INNER JOIN [AVL].[app_map_applicationprojectmapping](NOLOCK) APM     
        
                     ON APM.applicationid = Y.applicationid           
        
      WHERE  APM.projectid = @projectid           
        
         AND APM.isdeleted = 0           
        
      --KEDB Available Indicator           
        
      UPDATE X2           
        
      SET    X2.[kedbavailableindicatorid] = X3.kedbavailableindicatorid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[tk_mas_kedbavailableindicator](NOLOCK) X3           
        
                     ON           
        
             X2.[kedb available indicator] = X3.kedbavailableindicatorname           
        
      WHERE  X2.projectid = @projectid           
        
          
        
      --KEDB Updated / Added              
        
      UPDATE X2           
        
      SET    X2.[kedbupdatedid] = X3.[kedbupdatedid]           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[tk_mas_kedbupdated](NOLOCK) X3           
        
                     ON X2.[kedb updated] = X3.[kedbupdatedname]           
        
      WHERE  x2.projectid = @projectid           
        
          
        
      -- Updating Nature of the ticket           
        
     UPDATE X2           
        
      SET    X2.[NatureOfTheTicketID] = x3.natureoftheticketid           
        
    FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[itsm_mas_natureoftheticket](NOLOCK) x3           
        
                     ON X2.[nature of the ticket] = X3.[nature of the ticket]           
        
      WHERE  x2.projectid = @projectid           
        
                          
        
      --UPDATE X2           
        
      --SET    X2.[nature of the ticket] = x3.natureoftheticketid           
        
      --FROM   #ImportTicketDumpDetails X2           
        
      --       INNER JOIN [AVL].[itsm_mas_natureoftheticket] x3           
        
      --               ON X2.[nature of the ticket] = X3.[nature of the ticket]           
        
      --WHERE  x2.projectid = @projectid           
        
          
        
          
        
      -- Updating Escalated Flag - Customer                                         
        
      UPDATE X2           
        
      SET    X2.[escalatedflagcustomerid] = x3.escalatedflagcustomerid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[itsm_mas_escalatedflagcustomer](NOLOCK) x3           
        
                     ON           
        
             X2.[escalated flag customer] = x3.[escalated flag customer]           
        
      WHERE  x2.projectid = @projectid           
        
          
        
      -- Updating OutageFlag                                         
        
      UPDATE X2           
        
      SET    X2.[outageflagid] = x3.outageflagid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[itsm_mas_outageflag](NOLOCK) x3           
        
                     ON X2.[outage flag] = x3.[outage flag]           
        
      WHERE  x2.projectid = @projectid           
        
          
        
      ---- Updating WarrantyIssue                                         
        
      UPDATE X2           
        
      SET    X2.[warrantyissueid] = x3.warrantyissueid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[itsm_mas_warrantyissue](NOLOCK) x3           
        
                     ON X2.[warranty issue] = x3.[warranty issue]           
        
      WHERE  x2.projectid = @projectid           
        
      ---- Updating Ticket Source            
        
   DECLARE @CustomerID AS BIGINT=0;        
   DECLARE @IsCognizant AS INT=1;        
   SELECT DISTINCT @CustomerID=CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) PM WHERE ProjectID=@projectid AND IsDeleted=0;        
   SELECT DISTINCT @IsCognizant=IsCognizant FROM AVL.Customer(NOLOCK) WHERE CustomerID=@CustomerID AND IsDeleted=0;        
      UPDATE X2         
      SET    X2.sourceid = x3.sourceidmapid         
      FROM   #ImportTicketDumpDetails(NOLOCK) X2         
             JOIN [AVL].[tk_map_sourcemapping](NOLOCK) X3         
               ON X2.[ticket source] = X3.sourcename         
                  AND X3.isdeleted = 0         
                  AND X2.projectid = X3.projectid         
         WHERE  x2.projectid = @projectid         
      AND @IsCognizant=1;        
     UPDATE X2         
      SET    X2.sourceid = NULL         
   ,X2.[ticket source] = NULL        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2         
             WHERE @IsCognizant=0;        
        
        
        
          
        
            
      ---- Updating Release Type                 
        
      UPDATE X2           
        
      SET    X2.releasetypeid = x3.releasetypeid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
    INNER JOIN [AVL].[tk_mas_releasetype](NOLOCK) X3           
        
                     ON X2.[release type] = X3.releasetypename           
        
      WHERE  X2.projectid = @projectid           
        
          
        
      ---- Updating Servity                                         
        
      UPDATE X2           
        
      SET    X2.severityid = x3.SeverityIDMapID           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[tk_map_severitymapping](NOLOCK) X3           
        
                     ON X2.severity = X3.[severityname]           
        
                        AND X3.[isdeleted] = 0           
        
                        AND X2.projectid = X3.projectid           
        
      WHERE  x2.projectid = @projectid           
        
          
        
      ---- Debt Classification                                          
        
      UPDATE X2           
        
      SET    X2.debtclassificationid = x3.debtclassificationid            
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[debt_mas_debtclassification](NOLOCK) X3         
        
                     ON X2.[debt classification] = X3.debtclassificationname         
        
WHERE  x2.projectid = @projectid   and X2.SupportType = 1        
        
        
    ---- Debt Classification Infra                                        
        
      UPDATE X2           
        
      SET    X2.debtclassificationid = x3.debtclassificationid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[DEBT_MAS_DebtClassificationInfra](NOLOCK) X3           
        
                     ON X2.[debt classification] = X3.debtclassificationname           
        
      WHERE  x2.projectid = @projectid   and X2.SupportType = 2         
        
          
        
      -- Avoidable Flag                                          
        
      UPDATE X2           
        
      SET    X2.avoidableflagid = x3.avoidableflagid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[debt_mas_avoidableflag](NOLOCK) X3           
        
                     ON X2.[avoidable flag] = X3.avoidableflagname           
        
      WHERE  x2.projectid = @projectid           
        
          
        
      ---- Residual Debt                                          
        
      UPDATE X2           
        
      SET    X2.residualdebtid = x3.residualdebtid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[debt_mas_residualdebt](NOLOCK) X3           
        
                     ON X2.[residual debt] = X3.residualdebtname           
        
      WHERE  x2.projectid = @projectid           
        
          
        
   ----MetResponseSLA          
        
   UPDATE X2           
        
   SET  X2.[Met Response SLA]=X3.MetSLAId          
        
    FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[TK_MAS_MetSLACondition](NOLOCK) X3           
        
   ON X2.[Met Response SLA] = X3.MetSLAName           
        
      WHERE  x2.projectid = @projectid           
        
   --BELOW CONDITION ADDED FOR USER HAS GIVEN NULL AS VALUE IN TICKET UPLOAD         
        
 UPDATE X2         
        
 SET  X2.[Met Response SLA]=NULL        
        
 FROM   #ImportTicketDumpDetails(NOLOCK) X2         
        
 WHERE  x2.projectid = @projectid AND  UPPER(X2.[Met Response SLA]) = 'NULL'        
        
   ----Elevate Flag Internal          
        
    UPDATE X2           
        
   SET  X2.[Elevate Flag Internal]=X3.MetSLAId          
        
    FROM   #ImportTicketDumpDetails(NOLOCK) X2           
       
             INNER JOIN [AVL].[TK_MAS_MetSLACondition](NOLOCK) X3           
        
                     ON X2.[Elevate Flag Internal] = X3.MetSLAName           
        
      WHERE  x2.projectid = @projectid          
 --BELOW CONDITION ADDED FOR USER HAS GIVEN NULL AS VALUE IN TICKET UPLOAD        
        
    UPDATE X2         
        
 SET  X2.[Elevate Flag Internal]=NULL        
        
 FROM   #ImportTicketDumpDetails(NOLOCK) X2         
        
 WHERE  x2.projectid = @projectid AND  UPPER(X2.[Elevate Flag Internal]) = 'NULL'        
        
   --Met Resolution          
        
     UPDATE X2           
        
   SET  X2.[Met Resolution]=X3.MetSLAId          
        
    FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[TK_MAS_MetSLACondition](NOLOCK) X3           
        
                     ON X2.[Met Resolution] = X3.MetSLAName           
        
      WHERE  x2.projectid = @projectid           
        
   --BELOW CONDITION ADDED FOR USER HAS GIVEN NULL AS VALUE IN TICKET UPLOAD          
        
   UPDATE X2         
        
 SET  X2.[Met Resolution]=NULL        
        
 FROM   #ImportTicketDumpDetails(NOLOCK) X2         
        
 WHERE  x2.projectid = @projectid AND  UPPER(X2.[Met Resolution]) = 'NULL'        
        
   --Met Acknowledgement SLA          
        
      UPDATE X2           
        
   SET  X2.[Met Acknowledgement SLA]=X3.MetSLAId          
        
    FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[TK_MAS_MetSLACondition](NOLOCK) X3           
        
                     ON X2.[Met Acknowledgement SLA] = X3.MetSLAName           
        
      WHERE  x2.projectid = @projectid           
        
    --BELOW CONDITION ADDED FOR USER HAS GIVEN NULL AS VALUE IN TICKET UPLOAD        
        
      UPDATE X2         
        
 SET  X2.[Met Acknowledgement SLA]=NULL        
        
 FROM   #ImportTicketDumpDetails(NOLOCK) X2         
        
 WHERE  x2.projectid = @projectid AND  UPPER(X2.[Met Acknowledgement SLA]) = 'NULL'        
        
          
        
      --Cause Code             
        
      UPDATE X2           
        
      SET    X2.causecodeid = X3.causeid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
             INNER JOIN [AVL].[debt_map_causecode](NOLOCK) X3           
        
                     ON X2.ticketlocation = X3.causecode          
        
                        AND X3.isdeleted = 0           
        
AND X2.projectid = X3.projectid           
        
    WHERE  x2.projectid = @projectid           
        
  UPDATE X2           
        
      SET    X2.ServiceID =ISNULL(S.ServiceID,0)           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2           
        
    JOIN AVL.TK_MAS_Service(NOLOCK) S         
        
     ON LTRIM(RTRIM(X2.Service)) = S.ServiceName        
             
     AND S.IsDeleted = 0        
        
              JOIN [AVL].[TK_MAP_TicketTypeServiceMapping](NOLOCK) TSM           
        
                     ON X2.TicketTypeID = TSM.TicketTypeMappingID           
        
      AND S.ServiceID = TSM.ServiceID        
        
                        AND TSM.IsDeleted = 0           
        
                        AND X2.projectid = TSM.projectid           
        
    WHERE  x2.projectid = @projectid AND ISNULL(X2.IsBOT,0) = 0 AND ISNULL(X2.SupportType,1) = 1 AND S.ServiceID IN (1,4,5,6,7,8,10)        
        
    --BELOW CONDITION ADDED FOR USER HAS GIVEN NULL AS VALUE IN TICKET UPLOAD        
        
  UPDATE X2         
        
 SET  X2.causecodeid=NULL        
        
 FROM   #ImportTicketDumpDetails(NOLOCK) X2         
        
 WHERE  x2.projectid = @projectid AND  UPPER(X2.causecodeid) = 'NULL'        
        
      --Resolution Code             
        
      UPDATE X2           
        
      SET    X2.resolutionid = x3.resolutionid           
        
      FROM   #ImportTicketDumpDetails(NOLOCK) X2     
        
      INNER JOIN [AVL].[debt_map_resolutioncode](NOLOCK) X3           
        
                     ON X2.reviewer = X3.resolutioncode           
        
                        AND X3.isdeleted = 0           
        
                        AND X2.projectid = X3.projectid           
        
      WHERE  x2.projectid = @projectid           
        
   --BELOW CONDITION ADDED FOR USER HAS GIVEN NULL AS VALUE IN TICKET UPLOAD        
        
   UPDATE X2         
        
  SET  X2.resolutionid=NULL        
        
  FROM   #ImportTicketDumpDetails(NOLOCK) X2         
        
  WHERE  x2.projectid = @projectid AND  UPPER(X2.resolutionid) = 'NULL'        
        
        
      SET @UploadCnt=(SELECT Count([ticket id])           
        
                      FROM   #ImportTicketDumpDetails(NOLOCK)           
        
                      WHERE  projectid = @projectid)           
        
      -- if Assignee or Status or Priority or Application or Tickettype are not available for particular Project then taking the ticket backup           
        
           
        
      --SET @ReuploadedCount = (SELECT Count(ITD.[ticket id])           
        
      --                        FROM   #ImportTicketDumpDetails AS ITD           
        
      --INNER JOIN #ImportTicketDumpDetails_NullValue AS TD           
        
      --        ON TD.[ticket id] = ITD.[ticket id]           
        
      --                        WHERE  TD.projectid = @projectid)           
        
          
        
 --IF( @ReuploadedCount = 0 )           
        
      --  BEGIN           
        
   --Newly commented code          
        
            --SET @ReuploadedCount = (SELECT Count(ITD.[ticket id])           
        
            --                        FROM   #ImportTicketDumpDetails AS           
        
            --                               ITD           
        
            --                               INNER JOIN avl.tk_trn_ticketdetail AS           
        
            --                                          TD           
        
            --                                       ON           
        
            --                               TD.ticketid = ITD.[ticket id]           
        
            --                        WHERE  TD.projectid = @projectid)           
        
          
        
--Newly commented code end          
        
        --END           
        
          
        
  --          
        
                                   
        
          
        
          
        
---Duplicate Tickets          
        
DECLARE @DuplicateTickets TABLE(          
        
TicketCount INT,          
        
[Ticket ID] VARCHAR(100),          
        
 ProjectID VARCHAR(MAX)          
        
)          
        
           
 INSERT into   @DuplicateTickets          
        
    SELECT count([Ticket ID]),[Ticket ID], ProjectID                                   
        
          
        
      FROM  #ImportTicketDumpDetails(NOLOCK) ITM1                                   
        
          
        
   WHERE ITM1.ProjectID = @ProjectID                                 
        
          
        
   AND ((Select COUNT(ITM2.[Ticket ID]) from  #ImportTicketDumpDetails(NOLOCK) ITM2 Where ITM1.[Ticket ID] = ITM2.[Ticket ID]) > 1 )                                  
        
          
        
      GROUP BY [Ticket ID], ITM1.ProjectID                                   
        
          
        
HAVING COUNT(ITM1.[Ticket ID]) > 1            
        
         
        
        
 CREATE TABLE #ImportTicketDumpDetails_Nullvalue(        
 [ID] [int] IDENTITY(1,1) NOT NULL,        
 [Ticket ID] [nvarchar](max) NOT NULL,        
 [Ticket Type] [nvarchar](max) NULL,        
 [TicketTypeID] [int] NULL,        
 [Assignee] [nvarchar](max) NULL,        
 [ActiveFlag] [nvarchar](max) NULL,        
 [Close Date] [datetime] NULL,        
 [Planned End Date] [datetime] NULL,        
 [Modified Date Time] [datetime] NULL,        
 [ArrivalDate] [datetime] NULL,        
 [Open Date] [datetime] NULL,        
 [Priority] [nvarchar](max) NULL,        
 [PriorityID] [int] NULL,        
 [Reopen Date] [datetime] NULL,        
 [Sla Miss] [nvarchar](max) NULL,        
 [ResolutionID] [nvarchar](max) NULL,        
 [Resolution Code] [nvarchar](max) NULL,        
 [Status] [nvarchar](max) NULL,       
 [StatusID] [int] NULL,        
 [Ticket Description] [nvarchar](max) NULL,        
 [Raised By Customer] [nvarchar](max) NULL,        
 [IsManual] [nvarchar](max) NULL,        
 [ProductName] [nvarchar](max) NULL,        
 [ModifiedBY] [nvarchar](max) NULL,        
 [Ticket Source] [nvarchar](max) NULL,        
 [Source Department] [nvarchar](max) NULL,        
 [Turn around Time] [decimal](25, 2) NULL,        
 [Application] [nvarchar](max) NULL,        
 [ApplicationID] [int] NULL,        
 [Application Group Trail] [nvarchar](max) NULL,        
 [TicketLocation] [nvarchar](max) NULL,        
 [Sec Assignee] [nvarchar](max) NULL,        
 [Root Cause] [nvarchar](max) NULL,        
 [Reviewer] [nvarchar](max) NULL,        
 [PriorityChng] [nvarchar](max) NULL,        
 [Service] [nvarchar](max) NULL,        
 [ServiceID] [int] NULL,        
 [EmployeeID] [nvarchar](max) NULL,        
 [EmployeeName] [nvarchar](max) NULL,        
 [External Login ID] [nvarchar](max) NULL,        
 [ProjectID] [int] NOT NULL,        
 [CTIcategory] [nvarchar](max) NULL,        
 [CTItype] [nvarchar](max) NULL,        
 [CTIitem] [nvarchar](max) NULL,        
 [SecAssigneeID] [nvarchar](max) NULL,        
 [UserID] [nvarchar](max) NULL,        
 [SecClientUserID] [nvarchar](max) NULL,        
 [Accountprojectlobid] [int] NULL,        
 [LOBTrackid] [int] NULL,        
 [IsDeleted] [char](1) NULL,        
 [Severity] [nvarchar](max) NULL,        
 [Release Type] [nvarchar](max) NULL,        
 [Planned Effort] [decimal](25, 2) NULL,        
 [Estimated Work Size] [decimal](25, 2) NULL,        
 [Actual Work Size] [decimal](25, 2) NULL,        
 [Planned Start Date and Time] [datetime] NULL,        
 [New Status Date Time] [datetime] NULL,        
 [Resolved date] [datetime] NULL,        
 [Rejected Time Stamp] [datetime] NULL,        
 [Release Date] [datetime] NULL,        
 [KEDBAvailableIndicatorID] [bigint] NULL,        
 [KEDB Available Indicator] [nvarchar](max) NULL,        
 [KEDBupdatedID] [bigint] NULL,        
 [KEDB updated] [nvarchar](max) NULL,        
 [Elevate Flag Internal] [nvarchar](max) NULL,        
 [RCA ID] [nvarchar](max) NULL,        
 [Met Response SLA] [nvarchar](max) NULL,        
 [Met Acknowledgement SLA] [nvarchar](max) NULL,        
 [Met Resolution] [nvarchar](max) NULL,        
 [Response Time] [decimal](25, 2) NULL,        
 [Resolved by] [nvarchar](max) NULL,        
 [Actual Start date Time] [datetime] NULL,        
 [Actual End date Time] [datetime] NULL,        
 [Planned Duration] [decimal](26, 5) NULL,        
 [Actual duration] [decimal](26, 5) NULL,        
 [TicketCreateDate] [datetime] NULL,        
 [Ticket Summary] [nvarchar](max) NULL,        
 [NatureOfTheTicketID] [bigint] NULL,        
 [Nature Of The Ticket] [nvarchar](max) NULL,        
 [Technology] [nvarchar](max) NULL,        
 [Business Impact] [nvarchar](max) NULL,        
 [Job Process Name] [nvarchar](max) NULL,        
 [Server Name] [nvarchar](max) NULL,        
 [Comments] [nvarchar](max) NULL,        
 [Requester Customer Id] [nvarchar](max) NULL,        
 [Requester First Name] [nvarchar](max) NULL,        
 [Requester Internet Email] [nvarchar](max) NULL,        
 [Requester Contact Number] [nvarchar](max) NULL,        
 [Repeated Incident] [nvarchar](max) NULL,        
 [Related Tickets] [nvarchar](max) NULL,        
 [Ticket Created By] [nvarchar](max) NULL,        
 [KEDB Path] [nvarchar](max) NULL,        
 [Requested Resolution Date Time] [date] NULL,        
 [CSAT Score] [decimal](10, 1) NULL,        
 [EscalatedFlagCustomerID] [bigint] NULL,        
 [Escalated Flag Customer] [nvarchar](max) NULL,        
 [Approved Date Time] [date] NULL,        
 [Reviewed Date Time] [date] NULL,        
 [Reason For Rejection] [nvarchar](max) NULL,        
 [Reason For Cancel] [nvarchar](max) NULL,        
 [Reason For On Hold] [nvarchar](max) NULL,        
 [Response SLA Overridden Reason] [nvarchar](max) NULL,        
 [Resolution SLA Overridden Reason] [nvarchar](max) NULL,        
 [Acknowledgement SLA Overridden Reason] [nvarchar](max) NULL,        
 [Type] [nvarchar](max) NULL,        
 [Item] [nvarchar](max) NULL,        
 [Started Date Time] [datetime] NULL,        
 [WIP Date Time] [datetime] NULL,        
 [On Hold Date Time] [datetime] NULL,        
 [Completed Date Time] [datetime] NULL,        
 [Cancelled Date Time] [datetime] NULL,        
 [Approved By] [nvarchar](max) NULL,        
 [Reviewed By] [nvarchar](max) NULL,        
 [Customer Ticket ID] [nvarchar](max) NULL,        
 [Outage Duration] [nvarchar](max) NULL,        
 [OutageFlagID] [bigint] NULL,        
 [Outage Flag] [nvarchar](max) NULL,        
 [WarrantyIssueID] [bigint] NULL,        
 [Warranty Issue] [nvarchar](max) NULL,        
 [ResolutionDetails] [nvarchar](max) NULL,        
 [sourceID] [int] NULL,        
 [severityID] [int] NULL,        
 [releaseTypeID] [int] NULL,        
 [Remarks] [nvarchar](max) NULL,        
 [Assigned Time Stamp] [datetime] NULL,        
 [DARTStatusId] [int] NULL,        
 [DebtClassificationId] [int] NULL,        
 [Debt Classification] [nvarchar](max) NULL,        
 [AvoidableFlagID] [int] NULL,        
 [Avoidable Flag] [nvarchar](max) NULL,        
 [Residual Debt] [nvarchar](max) NULL,        
 [Resolution Method] [nvarchar](max) NULL,        
 [ResidualDebtID] [int] NULL,        
 [Cause code] [nvarchar](max) NULL,        
 [CauseCodeID] [nvarchar](max) NULL,        
 [ITSM Effort] [nvarchar](max) NULL,        
 [Assignment Group] [nvarchar](max) NULL,        
 [UploadedBy] [nvarchar](max) NULL,        
 [UploadedDate] [datetime] NULL,        
 [Flex Field (1)] [nvarchar](max) NULL,        
 [Flex Field (2)] [nvarchar](max) NULL,        
 [Flex Field (3)] [nvarchar](max) NULL,        
 [Flex Field (4)] [nvarchar](max) NULL,        
 [Category] [nvarchar](max) NULL,        
 [Assignment Group ID] [BIGINT],        
 SupportType [INT] NULL,        
 Tower BIGINT,        
 TowerName [nvarchar](max) NULL,        
 IsBot INT NULL,        
 IsPartiallyAutomated [nvarchar](max) NULL,        
 IsGracePeriodMet BIT NULL,        
 [RemarksForGracePeriod] [nvarchar](max) NULL,        
 [TicketDescriptionBasePattern] [nvarchar](250) NULL,        
 [TicketDescriptionSubPattern] [nvarchar](250) NULL,        
 [ResolutionRemarksBasePattern] [nvarchar](250) NULL,        
 [ResolutionRemarksSubPattern] [nvarchar](250) NULL        
)         
        
--Update Grace Period as 0 when the ticket is not present in Ticket Details        
UPDATE TT SET TT.IsGracePeriodMet =0        
FROM #ImportTicketDumpDetails(NOLOCK) TT        
LEFT JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON TT.ProjectID=TD.ProjectID        
and TT.[Ticket ID]=TD.TicketID WHERE TD.TicketID IS NULL AND TT.SupportType = 1        
        
UPDATE TT SET TT.IsGracePeriodMet =0        
FROM #ImportTicketDumpDetails(NOLOCK) TT        
LEFT JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD ON TT.ProjectID=TD.ProjectID        
and TT.[Ticket ID]=TD.TicketID WHERE TD.TicketID IS NULL AND TT.SupportType = 2        
        
-- New code        
UPDATE TT SET TT.IsGracePeriodMet =0        
FROM #ImportTicketDumpDetails(NOLOCK) TT        
INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON TT.ProjectID=TD.ProjectID and TT.[Ticket ID]=TD.TicketID        
where TD.Closeddate IS NULL         
        
        
 INSERT into  #ImportTicketDumpDetails_Nullvalue ([Ticket ID],[Ticket Type],TicketTypeID,Assignee,ActiveFlag,[Close Date],        
[Planned End Date],[Modified Date Time],ArrivalDate,[Open Date],Priority,PriorityID,        
[Reopen Date],[Sla Miss],ResolutionID,[Resolution Code],Status,StatusID,[Ticket Description],[Raised By Customer],        
IsManual,ProductName,ModifiedBY,[Ticket Source],[Source Department],[Turn around Time],Application,ApplicationID,        
[Application Group Trail],TicketLocation,[Sec Assignee],[Root Cause],Reviewer,PriorityChng,Service,ServiceID,EmployeeID,        
EmployeeName,[External Login ID],ProjectID,CTIcategory,CTItype,CTIitem,SecAssigneeID,UserID,SecClientUserID,Accountprojectlobid,LOBTrackid,        
IsDeleted,Severity,[Release Type],[Planned Effort],[Estimated Work Size],[Actual Work Size],[Planned Start Date and Time],        
[New Status Date Time],[Resolved date],[Rejected Time Stamp],[Release Date],KEDBAvailableIndicatorID,[KEDB Available Indicator],        
KEDBupdatedID,[KEDB updated],[Elevate Flag Internal],[RCA ID],[Met Response SLA],[Met Acknowledgement SLA],        
[Met Resolution],[Response Time],[Resolved by],[Actual Start date Time],[Actual End date Time],        
[Planned Duration],[Actual duration],TicketCreateDate,[Ticket Summary],NatureOfTheTicketID,[Nature Of The Ticket],        
Technology,[Business Impact],[Job Process Name],[Server Name],Comments,[Requester Customer Id],[Requester First Name],        
[Requester Internet Email],[Requester Contact Number],[Repeated Incident],[Related Tickets],[Ticket Created By],[KEDB Path],[Requested Resolution Date Time],        
[CSAT Score],EscalatedFlagCustomerID,[Escalated Flag Customer],[Approved Date Time],[Reviewed Date Time],[Reason For Rejection],        
[Reason For Cancel],[Reason For On Hold],[Response SLA Overridden Reason],[Resolution SLA Overridden Reason],        
[Acknowledgement SLA Overridden Reason],Type,Item,[Started Date Time],[WIP Date Time],[On Hold Date Time],[Completed Date Time],        
[Cancelled Date Time],[Approved By],[Reviewed By],[Customer Ticket ID],[Outage Duration],OutageFlagID,[Outage Flag],WarrantyIssueID,[Warranty Issue],ResolutionDetails,sourceID,        
severityID,releaseTypeID,Remarks,[Assigned Time Stamp],DARTStatusId,DebtClassificationId,[Debt Classification],AvoidableFlagID,[Avoidable Flag],[Residual Debt],[Resolution Method],ResidualDebtID,        
[Cause code],CauseCodeID,[ITSM Effort],[Assignment Group],UploadedBy,UploadedDate,[Flex Field (1)],        
[Flex Field (2)],[Flex Field (3)],[Flex Field (4)],Category,[Assignment Group ID],SupportType,Tower,TowerName,IsBot,IsPartiallyAutomated,IsGracePeriodMet,        
[TicketDescriptionBasePattern], [TicketDescriptionSubPattern], [ResolutionRemarksBasePattern], [ResolutionRemarksSubPattern]        
)        
        
        
 SELECT DISTINCT Ltrim(Rtrim(Replace([ticket id], Char(160), ''))) AS [ticket id],           
        
                      [ticket type],           
        
                      [tickettypeid],           
        
                      [assignee],           
        
                      activeflag,           
        
                      [close date],           
        
                      [planned end date],           
        
                      [modified date time],           
        
                      [arrivaldate],           
        
                   [open date],           
        
                      [priority],           
        
                      [priorityid],           
        
                      [reopen date],           
        
                      [sla miss],           
        
                      [resolutionid],           
        
                      [resolution code],           
        
                      [status],           
        
                      [statusid],           
        
                [ticket description],           
        
                      [raised by customer],           
        
                      [ismanual],           
        
                      [productname],           
        
                      [modifiedby],           
       [ticket source] ,           
        
                      [source department],           
        
                      [turn around time],           
        
                      [application],           
        
                      [applicationid],           
        
                      [application group trail],           
        
                      [ticketlocation],           
        
           [sec assignee],           
        
                      [root cause],           
        
                      [reviewer],           
        
                      [prioritychng],           
        
                      [service],           
        
                      [serviceid],           
        
                      [employeeid],           
        
                      [employeename],           
        
                      [External Login ID],           
        
                      [projectid],           
        
                      [cticategory],           
        
                      [ctitype],           
        
                      [ctiitem],           
        
                      [secassigneeid],           
        
          [userid],           
        
                      [secclientuserid],           
        
                      [accountprojectlobid],           
        
                      [lobtrackid],           
        
                      [isdeleted],           
        
                      [severity],           
        
                      [release type],           
        
                      [planned effort],           
        
                      [estimated work size],           
        
                      [actual work size],           
        
                      [planned start date and time],           
        
                      [new status date time],           
        
                      [resolved date],           
        
                      [rejected time stamp],           
        
                      [release date],           
        
                      [kedbavailableindicatorid],           
        
            [kedb available indicator],           
        
                      [kedbupdatedid],           
        
                      [kedb updated],           
        
                      [elevate flag internal],           
        
                      [rca id],           
        
                      [met response sla],           
        
                      [met acknowledgement sla],           
        
                      [met resolution],           
        
                      [response time],           
        
                      [resolved by],           
        
                      [actual start date time],           
        
                      [actual end date time],           
        
                      [planned duration],           
        
                      [actual duration],           
        
     [ticketcreatedate],           
        
                      [ticket summary],           
        
                      [natureoftheticketid],           
        
                      [nature of the ticket],           
        
        [technology],           
        
       [business impact],           
        
                       [job process name],           
        
                      [server name],           
        
                      [comments],           
        
                      [requester customer id],           
        
                      [requester first name],           
        
                      [requester internet email],           
        
                      [requester contact number],           
        
                      [repeated incident],           
        
                      [related tickets],           
        
                      [ticket created by],           
        
                      [kedb path],           
        
                      [requested resolution date time],           
        
                      [csat score],           
        
                      [escalatedflagcustomerid],           
        
                      [escalated flag customer],           
        
                      [approved date time],           
        
                     [reviewed date time],           
        
                      [reason for rejection],           
        
                      [reason for cancel],           
     
                      [reason for on hold],           
        
                      [response sla overridden reason],           
        
                      [resolution sla overridden reason],           
        
                      [acknowledgement sla overridden reason],           
        
           [type],           
        
                      [item],           
        
                      [started date time],           
        
                      [wip date time],           
        
                      [on hold date time],           
        
                      [completed date time],           
        
                      [cancelled date time],           
        
                      [approved by],           
        
                      [reviewed by],           
        
                      [customer ticket id],           
        
                      [outage duration],           
        
                      [outageflagid],           
        
                      [outage flag],           
        
               [warrantyissueid],           
        
                      [warranty issue],           
        
                      [resolutiondetails],           
        
                      [sourceid],           
        
                      [severityid],           
        
                      [releasetypeid],           
        
                      [remarks],           
        
                      [assigned time stamp],           
        
         [dartstatusid],           
        
                      [debtclassificationid],           
        
                      [debt classification],           
        
                      [avoidableflagid],         
        
                      [avoidable flag],           
        
                      [residual debt],           
        
                      [resolution method],           
        
                      [residualdebtid],           
        
                      [cause code],           
        
                      [causecodeid],           
        
                      [itsm effort],           
        
                      [assignment group],           
        
                      [uploadedby],           
            [uploadeddate],          
       [Flex Field (1)],          
       [Flex Field (2)],          
          [Flex Field (3)],          
          [Flex Field (4)],          
          [Category] ,        
    [Assignment Group ID],        
    SupportType,        
    TowerID,        
    TowerName,        
    IsBOT,        
    IsPartiallyAutomated,        
    IsGracePeriodMet,        
    [TicketDescriptionBasePattern],        
 [TicketDescriptionSubPattern],        
 [ResolutionRemarksBasePattern] ,        
 [ResolutionRemarksSubPattern]         
        
  FROM   #ImportTicketDumpDetails  (NOLOCK)        
        
     WHERE  projectid = @projectid           
        
             AND ( -- userid IS NULL           
     ([External Login ID] IS NOT NULL and [External Login ID]!='' and userid IS NULL)         
        
                    OR [ticket id] IS NULL           
        
                    OR tickettypeid IS NULL           
        
     OR TicketTypeID = -1        
        
     OR [Assignment Group ID] = -1         
        
     OR ([Assignment Group] is NULL or [Assignment Group] ='') and SupportType = 2        
        
     OR SupportType = 3          
        
     OR (SupportType = 2  and ([Ticket Description] is NULL or [Ticket Description] = ''))        
        
     OR (SupportType = 2  and (TowerID is NULL OR TowerName is NULL))        
        
     OR applicationid IS NULL  and SupportType = 1            
        
                    OR [open date] IS NULL           
        
                    OR priorityid IS NULL           
        
                 OR statusid IS NULL           
        
     OR [Ticket ID] in(Select [Ticket ID] from @DuplicateTickets)          
        
     OR (Severity is NOT NULL and severityID  IS NULL)                                         
      
     OR ([Ticket Source] is NOT NULL and sourceID IS NULL )                                        
        
     OR ([Release Type] is not NULL and releaseTypeID IS NULL )           
        
                  --OR IsC20Processed =1                 
        
     OR (DebtClassificationId IS NULL and [Debt Classification] is not NULL)                 
        
                    OR (AvoidableFlagID IS NULL  and [Avoidable Flag] is not NULL)            
        
     OR (TicketLocation is NOT null and CauseCodeID is NULL )               
        
     OR (Reviewer IS NOT null and ResolutionID IS NULL )          
  OR (IsPartiallyAutomated IS NOT NULL AND (IsPartiallyAutomated NOT IN (SELECT cast(MetSLAId as varchar(10)) FROM AVL.TK_MAS_MetSLACondition)))        
        
  OR [Open Date] > [Close Date]         
        
  OR [Open Date] > [Completed Date Time]         
        
     OR [Close Date] > GETDATE()        
        
  OR [Open Date] > GETDATE()        
          
         OR IsGracePeriodMet=1        
    );           
        
        
        
          
   DECLARE @SourceID AS VARCHAR(max);           
        
          
        
      SET @SourceID = (SELECT ProjectColumn           
        
                       FROM   [AVL].[itsm_prj_ssiscolumnmapping]   (NOLOCK)        
        
                   WHERE  projectid = @projectid           
        
                              AND ServiceDartColumn = 'Ticket source' AND IsDeleted = 0)         
        
          
        
      IF ( @SourceID <> '' )           
        
        BEGIN           
        
            DELETE #ImportTicketDumpDetails          
        
            WHERE  projectid = @projectid           
        
                   AND sourceid IS NULL           
        
                   AND [ticket source] IS NOT NULL;           
        
        END           
        
          
        
      --Delete Ticket Severity are not available for particular Project                                           
        
      DECLARE @SeverityID AS VARCHAR(max);           
        
          
        
      SET @SeverityID = (SELECT ProjectColumn           
        
                         FROM   [AVL].[itsm_prj_ssiscolumnmapping]  (NOLOCK)         
        
                         WHERE  projectid = @projectid           
        
                                AND ServiceDartColumn = 'Severity' AND IsDeleted = 0)           
        
          
        
      IF ( @SeverityID <> '' )           
        
        BEGIN           
        
            DELETE #ImportTicketDumpDetails           
        
            WHERE  projectid = @projectid           
        
                   AND severityid IS NULL           
        
                   AND severity IS NOT NULL;           
        
        END           
        
          
        
      DELETE #ImportTicketDumpDetails           
        
      WHERE  projectid = @projectid           
        
             AND [debtclassificationid] IS NULL           
        
             AND [debt classification] IS NOT NULL           
        
          
        
      ---Updating Error in Table                                    
        
      DECLARE @ClientID AS VARCHAR(200);           
        
      DECLARE @ApplicationName AS VARCHAR(200);           
        
      DECLARE @Priority AS VARCHAR(200);           
        
      DECLARE @TicketType AS VARCHAR(200);           
        
      DECLARE @Status AS VARCHAR(200);           
        
      DECLARE @CauseCode AS VARCHAR(50);           
        
      DECLARE @ResolutionCode AS VARCHAR(50); -- Added                    
        
    DECLARE @DebtClassification AS VARCHAR(200);           
        
      DECLARE @AvoidableFlag AS VARCHAR(200);        
        
   DECLARE @Tower AS VARCHAR(200);          
        
   DECLARE @AssignmentGroup AS VARCHAR(200);         
        
             
        
        
      SELECT  @ClientID=ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]  (NOLOCK)         
        
      WHERE  projectid = @projectid          
        
             AND ServiceDartColumn = 'External Login ID' AND IsDeleted = 0        
        
          
        
      SELECT @ApplicationName = ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]  (NOLOCK)         
        
      WHERE  projectid = @projectid           
        
             AND ServiceDartColumn = 'Application' AND IsDeleted = 0        
        
          
        
      SELECT @Priority = ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]   (NOLOCK)        
        
      WHERE  projectid = @projectid           
        
             AND ServiceDartColumn = 'Priority' AND IsDeleted = 0           
        
          
        
      SELECT @TicketType = ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]   (NOLOCK)        
        
      WHERE  projectid = @projectid           
        
             AND ServiceDartColumn = 'Ticket Type' AND IsDeleted = 0           
        
          
        
      SELECT @Status = ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]   (NOLOCK)        
        
      WHERE  projectid = @projectid           
        
             AND ServiceDartColumn = 'Status' AND IsDeleted = 0          
        
          
        
      SELECT @DebtClassification = ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]  (NOLOCK)         
        
      WHERE  projectid = @projectid           
        
             AND ServiceDartColumn = 'Debt Classification' AND IsDeleted = 0           
        
          
        
    SELECT @AvoidableFlag = ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]   (NOLOCK)        
        
      WHERE  projectid = @projectid           
        
             AND ServiceDartColumn = 'Avoidable Flag' AND IsDeleted = 0          
        
          
        
 SELECT @CauseCode=ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]   (NOLOCK)        
        
      WHERE  projectid = @projectid           
        
             AND ServiceDartColumn = 'Cause code' AND IsDeleted = 0          
        
              
        
 SELECT @ResolutionCode=ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]  (NOLOCK)         
        
      WHERE  projectid = @projectid           
        
             AND ServiceDartColumn = 'Resolution Code' AND IsDeleted = 0          
        
          
 SELECT @Tower=ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]  (NOLOCK)         
        
      WHERE  projectid = @projectid           
        
             AND ServiceDartColumn = 'Tower' AND IsDeleted = 0         
        
 SELECT @AssignmentGroup=ProjectColumn           
        
      FROM   [AVL].[itsm_prj_ssiscolumnmapping]  (NOLOCK)         
        
      WHERE  projectid = @projectid           
        
        AND ServiceDartColumn = 'Assignment Group' AND IsDeleted = 0          
            
        
        
--Update #ImportTicketDumpDetails_NullValue          
        
--SET remarks='There are Duplicate TicketID for this Project.A Project should contain only unique ticketIds.'          
        
--WHERE [Ticket ID] in(select [Ticket ID] from @DuplicateTickets)          
        
            
        
          
        
          
        
      DECLARE @CCCOUNT INT           
        
      DECLARE @RCCOUNT INT           
        
          
        
      SET @CCCOUNT =(SELECT Count(*)           
        
                     FROM  [AVL].[itsm_prj_ssiscolumnmapping]  (NOLOCK)         
        
                     WHERE  projectid = @projectid           
        
                            AND ServiceDartColumn = 'Cause code'  AND IsDeleted = 0)           
        
      SET @RCCOUNT =(SELECT Count(*)           
        
                     FROM   [AVL].[itsm_prj_ssiscolumnmapping]   (NOLOCK)        
        
                     WHERE  projectid = @projectid           
        
                            AND ServiceDartColumn = 'Resolution Code' AND IsDeleted = 0)           
        
          
        
      IF( @CCCOUNT > 0 )           
        
        BEGIN           
        
            UPDATE #ImportTicketDumpDetails_NullValue           
        
            SET    remarks = Isnull(remarks, '') + CASE WHEN TicketLocation is NOT NULL AND causecodeid IS NULL           
        
                             THEN           
        
                                    'There are entries in the "' + @CauseCode +           
        
'" column in the Ticket dump which are not mapped to ITSM Configuration Ticket Casue Code.                                        
        
 Use the "ITSM Configuration" screen to map the missing values to ITSM Configuration Casue Code. '           
        
                 ELSE '' END           
        
WHERE  projectid = @projectid           
        
END           
        
          
        
    IF( @RCCOUNT > 0 )           
        
      BEGIN           
        
          UPDATE #ImportTicketDumpDetails_NullValue           
        
          SET    remarks = Isnull(remarks, '') + CASE WHEN Reviewer is NOT NULL AND resolutionid IS NULL           
        
                           THEN           
        
                                  'There are entries in the "' + @ResolutionCode           
        
                           +           
        
'" column in the Ticket dump which are not mapped to ITSM Configuration Ticket Resolution Code.           
        
                              Use the "ITSM Configuration" screen to map the missing values to ITSM Configuration Resolution Code. '           
        
                 ELSE '' END           
        
WHERE  projectid = @projectid           
        
END           
        
          
        
          
        
--Current          
        
Update #ImportTicketDumpDetails_NullValue          
      SET Remarks='There are Duplicate TicketID for this Project.A Project should contain only unique ticketIds.        
'          
        
WHERE [Ticket ID] in (select [Ticket ID] from @DuplicateTickets)          
-- Update Remarks if Assignment Group is in valid For BOT Tickets        
        
UPDATE #ImportTicketDumpDetails_Nullvalue         
set Remarks = 'There are entries in the '+ ISNULL(@AssignmentGroup,'AssignmentGroup') + 'column in the ticket dump for which Assignment Group is not configured for the project. Use the ITSM Configuration - > Assignment Group section to add it.        
'        
where [Assignment Group ID] = -1 or (([Assignment Group] is NULL or [Assignment Group] ='') and SupportType = 2)        
        
UPDATE #ImportTicketDumpDetails_Nullvalue         
set Remarks = 'Please capture Assignment Group for the ticket (or) configure user to Assignment group mapping under User Management for the assignee captured here.          
'        
where SupportType = 3        
        
        
UPDATE #ImportTicketDumpDetails_Nullvalue         
set Remarks = 'Ticket Description should not be Empty for Infra Tickets.         
'        
where SupportType = 2  and  ([Ticket Description] is NULL or [Ticket Description] = '')        
        
        
UPDATE #ImportTicketDumpDetails_Nullvalue         
set Remarks = ISNULL(@IsPartiallyMapped,'Is Partially Automated' ) +' should have only "Yes" or "No" as values.        
'        
where   (IsPartiallyAutomated IS NOT NULL AND (IsPartiallyAutomated NOT IN (SELECT cast(MetSLAId as varchar(10)) FROM AVL.TK_MAS_MetSLACondition)))        
        
        
UPDATE #ImportTicketDumpDetails_Nullvalue         
set Remarks = 'Closed Date & time stamp should be greater than Open date & time stamp.        
'         
where  [Open Date] > [Close Date]         
        
UPDATE #ImportTicketDumpDetails_Nullvalue         
set Remarks = 'Completed Date & time stamp should be greater than Open date & time stamp.        
'         
where  [Open Date] > [Completed Date Time]         
        
UPDATE #ImportTicketDumpDetails_Nullvalue         
set Remarks = 'Closed Date & Time stamp cannot be future date.        
'         
where  [Close Date] > GETDATE()        
        
UPDATE #ImportTicketDumpDetails_Nullvalue         
set Remarks = 'Opened Date & Time stamp cannot be future date.        
'         
where   [Open Date] > GETDATE()        
        
  --For A/H tickets fix    
UPDATE #ImportTicketDumpDetails_Nullvalue        
        
SET [RemarksForGracePeriod] = 'Debt Specific parameters cannot be modified, as these ticket(s)         
 are already met with grace period (or) it is already tagged to an A/H/K tickets.'        
WHERE IsGracePeriodMet=1        
        
        
        
        
 UPDATE #ImportTicketDumpDetails_NullValue           
        
    SET    remarks = Isnull(remarks, '') + CASE WHEN ([External Login ID] IS NOT NULL and [External Login ID]!='' and userid IS NULL) THEN           
        
                            'There are entries in the "'  + @ClientID +           
        
'" column in the Ticket dump which are not mapped to a Employee Id.                                
        
Use the "Project Profiling" -> "User Management" -> "User Management" screen to map the missing. '           
        
                 + @ClientID +           
        
                 ' values to a Employee Id,'           
        
                 ELSE '' END + CASE WHEN ApplicationID IS NULL and SupportType = 1  THEN           
        
                 'There are entries in the "' + @ApplicationName +           
        
'" column in the Ticket dump for which Application Name have not been specified.                        
        
                  Use the "AppInventory" -> "Hierarchy Definition" ->"Hierarchy Mapping"->"App Profiling" screen to add the Application.                                                                  
        
    '           
        
                 ELSE '' END + CASE WHEN priorityid IS NULL THEN           
        
                 'There are entries in the "' + @Priority +           
        
'" column in the Ticket dump which were not originally configured                              
        
Use the "ITSM Configuration" screen to map the missing values to ITSM Configuration Priority.                                    
        
      '           
        
                 ELSE '' END + CASE WHEN tickettypeid IS NULL OR TicketTypeID = -1 THEN Isnull(           
        
                 remarks, '') + 'There are entries in the "' + @TicketType +           
        
'" column in the Ticket dump which are not mapped to ITSM Configuration Ticket Type.                     
        
                      Use the "ITSM Configuration" screen to map the missing values to ITSM Configuration Ticket Type.                                    
        
      '           
        
                 ELSE '' END + CASE WHEN statusid IS NULL THEN           
        
                 'There are entries in the "' + @Status +           
        
'" column in the Ticket dump which are not mapped to ITSM Configuration Ticket Status.                  
        
                        Use the "ITSM Configuration" screen to map the missing values to ITSM Configuration Ticket Status.                                     
        
      '           
        
                 ELSE '' END + CASE WHEN sourceid IS NULL AND [ticket source] IS           
        
                 NOT NULL  THEN 'There are entries in the "' + @SourceID +   --AND @IsCognizant=1        
        
'" column in the Ticket dump which are not mapped to ITSM Configuration Ticket Source.               
        
                          Use the "ITSM Configuration" screen to map the missing values to ITSM Configuration Ticket Source.                                     
        
      '           
        
                 ELSE '' END + CASE WHEN severityid IS NULL AND severity IS NOT           
        
                 NULL THEN 'There are entries in the "' + @SeverityID +           
        
'" column in the Ticket dump which are not mapped to ITSM Configuration Ticket Severity.              
        
     Use the "ITSM Configuration" screen to map the missing values to ITSM Configuration Ticket Severity.            
        
      '           
        
                 ELSE '' END           
        
          +           
        
          --  CASE WHEN IsC20Processed =1 THEN                                   
        
          --'Upload is not possible for already processed closed tickets in c20'  ELSE '' END +                 
        
          CASE WHEN debtclassificationid IS NULL AND [debt classification] IS           
        
                 NOT NULL THEN 'There are entries in the "' +           
        
        @DebtClassification +           
        
'" column in the Ticket dump which are not mapped to a ITSM Configuration DebtClassification.'           
        
                 ELSE '' END + CASE WHEN avoidableflagid IS NULL AND           
        
                 [avoidable flag] IS NOT NULL THEN 'There are entries in the "'           
        
                 + @AvoidableFlag +           
        
'" column in the Ticket dump which are not mapped to a ITSM Configuration AvoidableFlag.'           
        
    ELSE '' END + CASE WHEN [Open Date] IS NULL THEN 'OpenDate Should not be Empty.'           
        
            
                 ELSE '' END  + CASE WHEN SupportType = 2  and (Tower is NULL OR TowerName is NULL)THEN 'There are entries in the "'           
        
                 + ISNULL(@Tower,'Tower') +           
        
'"column in the Ticket dump for which Tower is not configured for the project. Use the "Infra Inventory" - > "Project Mapping" screen to add the Tower.'           
        
    ELSE '' END             
        
WHERE  projectid = @projectid            
        
          
        
          
        
    ---- TOTAL COUNT FROM THE DUMP TABLE            
        
    --SET @TotalCount = (SELECT Count(ITM.[ticket id])           
        
    --                   FROM   #ImportTicketDumpDetails AS ITM           
        
    --                          LEFT OUTER JOIN #ImportTicketDumpDetails           
        
    --                                          TM           
        
    --                                       ON ITM.[ticket id] = TM.[ticket id]           
        
    --                                         AND TM.projectid = ITM.projectid           
        
    --                   WHERE  ITM.projectid = @projectid)           
        
          
        
    -- FAILED COUNT FROM THE DUMP TABLE            
    IF @SourceID <> ''           
        
       AND @SeverityID <> ''           
        
      BEGIN           
        
             
        
          SET @FailCnt = (SELECT Count([ticket id])           
        
                          FROM   #ImportTicketDumpDetails_NullValue (NOLOCK)        
        
                          WHERE  projectid = @projectid           
        
                                 AND remarks IS NOT NULL           
        
                                 AND remarks <> ''          
        
         --AND [Ticket ID] NOT IN           
        
        --(SELECT DISTINCT [Ticket ID] FROM @DuplicateTickets)          
        
        )           
        
      END           
        
    ELSE IF @SourceID <> ''           
        
       AND @SeverityID = ''           
        
      BEGIN           
        
             
        
          SET @FailCnt = (SELECT Count([ticket id])           
        
                 FROM   #ImportTicketDumpDetails_NullValue (NOLOCK)        
        
                          WHERE  projectid = @projectid           
        
                                 AND remarks IS NOT NULL           
        
                                 AND remarks <> ''          
        
         AND [Ticket ID] NOT IN           
        
        (SELECT DISTINCT [Ticket ID] FROM @DuplicateTickets)          
        
        )           
        
      END           
        
    ELSE IF @SourceID = ''           
        
       AND @SeverityID <> ''           
        
      BEGIN           
        
             
      
          SET @FailCnt = (SELECT Count([ticket id])           
        
                          FROM   #ImportTicketDumpDetails_NullValue (NOLOCK)          
        
                          WHERE  projectid = @projectid           
        
                                 AND remarks IS NOT NULL           
        
                                 AND remarks <> ''          
        
        AND [Ticket ID] NOT IN           
        
       (SELECT DISTINCT [Ticket ID] FROM @DuplicateTickets)          
        
        )           
        
      END           
        
    ELSE           
        
      BEGIN           
        
           
        
          SET @FailCnt = (SELECT Count(DISTINCT [ticket id])           
        
                          FROM   #ImportTicketDumpDetails_NullValue (NOLOCK)          
        
                          WHERE  projectid =@projectid           
        
                       AND remarks IS NOT NULL        
        
                                 AND remarks <> ''          
        
       AND [Ticket ID] NOT IN           
        
       (SELECT DISTINCT [Ticket ID] FROM @DuplicateTickets)          
        
         )           
        
      END           
        
          
        
    -- ASSIGN REMARKS TO INSET IN TO DUMPSTATUS TABLE            
        
          
        
    DECLARE @FlagStatus VARCHAR(100)           
        
           
        
 Declare @DuplicatCountFails int           
        
 set @DuplicatCountFails = (Select sum(TicketCount) from @DuplicateTickets)          
        
          
        
 if(@DuplicatCountFails > 0)          
        
 BEGIN          
        
  set @FailCnt = @FailCnt + @DuplicatCountFails          
        
 END          
        
-- Error Log Only met Grace Period tickets        
  DECLARE @GracePeriodMetTickets INT=0,@GracePeriotMetTicket BIT=0        
        
  SELECT @GracePeriodMetTickets=COUNT([Ticket ID]) FROM #ImportTicketDumpDetails_Nullvalue(NOLOCK) WHERE ISNULL(Remarks,'')=''  AND ISNULL([RemarksForGracePeriod],'')<>''         
        
  IF (@GracePeriodMetTickets > 0)        
    BEGIN        
        
   SET @REMARKS='Upload Successful'           
        
      SET @FlagStatus = 'Success'         
        
   SET @GracePeriotMetTicket=1        
        
 END        
          
        
    ELSE IF ( @FailCnt = 0 )           
        
      BEGIN           
        
          SET @REMARKS='Upload Successful'           
        
          SET @FlagStatus = 'Success'           
        
      END           
        
    ELSE           
        
      BEGIN           
        
     IF ( @UploadCnt <> 0 )           
        
            BEGIN           
        
                SET @REMARKS='Ticket(s) Failed , Verify Error Log History'           
        
                SET @FlagStatus = 'Failed'           
        
            END           
        
          ELSE           
        
            BEGIN           
        
                SET @REMARKS='Dump upload Failed , Check Email for the Reason'           
        
                SET @FlagStatus = 'Failed'           
        
            END           
        
      END           
        
--Newly added          
        
 DECLARE @TotalTikcetCount AS INT        
 DECLARE @TotalInfraCount AS INT         
 DECLARE @TotalBotCount AS INT         
 DECLARE @ReuploadedTicketCount AS INT        
 DECLARE @ReuploadedInfraCount AS INT          
 DECLARE @ReuploadedBotCount AS INT             
         
 SELECT [Ticket ID] INTO #ValidTicketDump FROM #ImportTicketDumpDetails(NOLOCK) AS ITM  WHERE ITM.[Ticket ID] NOT IN (SELECT [Ticket ID]           
   FROM   #ImportTicketDumpDetails_NullValue (NOLOCK))        
        
 SET @TotalTikcetCount = (SELECT Count(ITM.[Ticket ID])           
        
                       FROM   #ImportTicketDumpDetails(NOLOCK) AS ITM          
                       INNER JOIN #ValidTicketDump(NOLOCK) AS VTD ON VTD.[Ticket ID] = ITM.[Ticket ID]        
        
                       --INNER JOIN AVL.TK_TRN_TicketDetail AS TD ON TD.ProjectID = ITM.ProjectID AND TD.TicketID NOT IN           
        
        WHERE ITM.SupportType != 2 AND IsNull(ITM.IsBOT,0) = 0  AND ITM.[Ticket ID] NOT IN (SELECT TicketID  FROM AVL.TK_TRN_TicketDetail(NOLOCK) WHERE ProjectID = @PROJECTID) AND ITM.ProjectID = @PROJECTID )         
                  
                
 SET @TotalInfraCount = (SELECT Count(ITM.[Ticket ID])           
        
                       FROM   #ImportTicketDumpDetails(NOLOCK) AS ITM           
        INNER JOIN #ValidTicketDump(NOLOCK) AS VTD ON VTD.[Ticket ID] = ITM.[Ticket ID]        
        
                       --INNER JOIN AVL.TK_TRN_TicketDetail AS TD ON TD.ProjectID = ITM.ProjectID AND TD.TicketID NOT IN           
        
        WHERE ISNULL(ITM.SupportType,1) = 2 AND IsNull(ITM.IsBOT,0) = 0          
        AND ITM.[Ticket ID] NOT IN (SELECT TicketID  FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) WHERE ProjectID = @PROJECTID) AND ITM.ProjectID = @PROJECTID )        
                
                 
  SET @TotalBotCount = (SELECT Count(ITM.[Ticket ID])           
        
                       FROM   #ImportTicketDumpDetails(NOLOCK) AS ITM           
        INNER JOIN #ValidTicketDump(NOLOCK) AS VTD ON VTD.[Ticket ID] = ITM.[Ticket ID]        
        
                       --INNER JOIN AVL.TK_TRN_TicketDetail AS TD ON TD.ProjectID = ITM.ProjectID AND TD.TicketID NOT IN           
        
        WHERE IsNull(ITM.IsBOT,0) = 1          
        AND ITM.[Ticket ID] NOT IN (SELECT TicketID  FROM [AVL].[TK_TRN_BOTTicketDetail](NOLOCK) WHERE ProjectID = @PROJECTID) AND ITM.ProjectID = @PROJECTID )         
               
              
        
          
        
  SET @ReuploadedTicketCount = (SELECT Count(ITD.[ticket id])           
                         FROM   #ImportTicketDumpDetails(NOLOCK) AS  ITD           
                                           INNER JOIN avl.tk_trn_ticketdetail(NOLOCK) AS TD   ON           
             TD.ticketid = ITD.[ticket id]           
             WHERE ITD.SupportType != 2 AND IsNull(ITD.IsBOT,0) = 0  AND  TD.projectid = @projectid)         
                                            
   SET @ReuploadedInfraCount = (SELECT Count(ITD.[ticket id])           
        FROM   #ImportTicketDumpDetails(NOLOCK) AS  ITD           
                                           INNER JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) AS TD   ON           
             TD.ticketid = ITD.[ticket id]           
             WHERE ISNULL(ITD.SupportType,1) = 2 AND IsNull(ITD.IsBOT,0) = 0   AND  TD.projectid = @projectid)        
                     
  SET @ReuploadedBotCount = (SELECT Count(ITD.[ticket id])           
                                    FROM   #ImportTicketDumpDetails(NOLOCK) AS  ITD           
                           INNER JOIN [AVL].[TK_TRN_BOTTicketDetail](NOLOCK) AS TD   ON           
             TD.ticketid = ITD.[ticket id]           
             WHERE IsNull(ITD.IsBOT,0) = 1   AND  TD.projectid = @projectid)        
        
        
          
        
  SET @TotalCount = @TotalTikcetCount + @TotalInfraCount + @TotalBotCount;        
  SET @ReuploadedCount =  @ReuploadedTicketCount +  @ReuploadedInfraCount + @ReuploadedBotCount;        
        
if(@UploadCnt > 0 )          
        
BEGIN          
        
          
        
    INSERT INTO [AVL].[ticketdumpuploadstatus]           
        
    VALUES    (@CogID,           
        
    @projectid,           
        
     @TotalCount,           
        
                 @UploadCnt,           
        
                 @ReuploadedCount,           
        
                 @FailCnt,           
        
                 @UploadstartTime,           
        
                 Getdate(),           
        
                 @Flag,           
        
                 @FlagStatus,           
        
                 '',           
        
                 @REMARKS,           
        
                 '',        
   @GracePeriotMetTicket)           
        
          
        
END          
        
  UPDATE AVL.TicketUploadTrack        
  SET         
  TotalRecordsInExcel=@UploadCnt,        
  TotalValidRecords=@TotalCount+@ReuploadedCount,        
  TotalDuplicateRecords=@DuplicateCount,        
  TotalRejectedRecords=@FailCnt        
  WHERE TicketUploadTrackID=@TicketUploadTrackID        
    --Insert and update for TikectDetail table Start          
        
 DELETE #ImportTicketDumpDetails           
        
      WHERE  projectid = @projectid           
        
             AND ( --userid IS NULL         
     ([External Login ID] IS NOT NULL and [External Login ID]!='' and userid IS NULL)          
        
                    OR applicationid IS NULL  and SupportType = 1        
        
                    OR priorityid IS NULL           
        
                    OR tickettypeid IS NULL          
        
     OR TicketTypeID = -1         
        
          OR statusid IS NULL           
        
                    OR [ticket id] IS NULL           
        
                    OR [Assignment Group ID] = -1          
        
     OR ([Assignment Group] is NULL or [Assignment Group] ='') and SupportType = 2        
        
     OR SupportType = 3        
        
     OR (SupportType = 2  and ([Ticket Description] is NULL or [Ticket Description] = ''))        
        
     OR (SupportType = 2  and (TowerID is NULL OR TowerName is NULL))        
        
                    OR [open date] IS NULL          
        
     or [Ticket ID] in(Select [Ticket ID] from @DuplicateTickets)           
        
     OR (Severity is NOT NULL and severityID  IS NULL)                                         
        
     OR ([Ticket Source] is NOT NULL and sourceID IS NULL )                                        
        
     OR ([Release Type] is not NULL and releaseTypeID IS NULL )           
        
                  --OR IsC20Processed =1                 
        
     OR (DebtClassificationId IS NULL and [Debt Classification] is not NULL)                 
        
     OR (AvoidableFlagID IS NULL  and [Avoidable Flag] is not NULL)            
        
     OR (TicketLocation is NOT null and CauseCodeID is NULL )               
        
     OR (Reviewer IS NOT null and ResolutionID IS NULL )          
  OR (IsPartiallyAutomated IS NOT NULL AND (IsPartiallyAutomated NOT IN (SELECT cast(MetSLAId as varchar(10)) FROM AVL.TK_MAS_MetSLACondition WITH(NOLOCK))))        
          
  OR [Open Date] > [Close Date]         
        
     OR [Close Date] > GETDATE()        
        
  OR [Open Date] > GETDATE()        
  --For A/H tickets fix    
  or IsGracePeriodMet=1     
     
  );          
        
        
        
--TicketDescription restricted for A/H        
          
 UPDATE TEMP SET TEMP.[Ticket Description] = null         
  FROM #ImportTicketDumpDetails(NOLOCK) AS TEMP        
  INNER JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TT ON TT.TicketTypeMappingID = TEMP.TicketTypeID and TT.ProjectID = TEMP.ProjectID        
  WHERE TT.TicketType in ('A','H','K')         
         
        
          
 -- Inserted only Bot Table         
 INSERT INTO #ImportTicketDumpDetails_BOT        
 select                    
 [Ticket ID]                   ,        
 [Ticket Type]                ,        
 [TicketTypeID]               ,        
 [Assignee]                   ,        
 [ActiveFlag]                 ,        
 [Close Date]                 ,        
 [Planned End Date]           ,        
 [Modified Date Time]         ,        
 [ArrivalDate]                ,        
 [Open Date]                  ,        
 [Priority]                   ,        
 [PriorityID]                 ,        
 [Reopen Date]                ,        
 [Sla Miss]                   ,        
 [ResolutionID]               ,        
 [Resolution Code]            ,        
 [Status]                     ,        
 [StatusID]                   ,        
 [Ticket Description]             ,        
 [Raised By Customer]             ,        
 [IsManual]                       ,        
 [ProductName]                    ,        
 [ModifiedBY]                     ,        
 [Ticket Source]                  ,        
 [Source Department]              ,        
 [Turn around Time]               ,        
 [Application]                    ,        
 [ApplicationID]                  ,        
 [Application Group Trail]        ,        
 [TicketLocation]                 ,        
 [Sec Assignee]                   ,        
 [Root Cause]                     ,        
 [Reviewer]                       ,        
 [PriorityChng]                   ,        
 [Service]                        ,        
 [ServiceID]                      ,        
 [EmployeeID]                     ,        
 [EmployeeName]                   ,        
 [External Login ID]              ,        
 [ProjectID]                      ,        
 [CTIcategory]                    ,        
 [CTItype]                        ,        
 [CTIitem]                        ,        
 [SecAssigneeID]                  ,        
 [UserID]                         ,        
 [SecClientUserID]                ,        
 [Accountprojectlobid]            ,        
 [LOBTrackid]                     ,        
 [IsDeleted]                     ,        
 [Severity]                      ,        
 [Release Type]                  ,        
 [Planned Effort]                ,        
 [Estimated Work Size]           ,        
 [Actual Work Size]              ,        
 [Planned Start Date and Time]      ,        
 [New Status Date Time]             ,        
 [Resolved date]                    ,        
 [Rejected Time Stamp]              ,        
 [Release Date]                     ,        
 [KEDBAvailableIndicatorID]         ,        
 [KEDB Available Indicator]         ,        
 [KEDBupdatedID]                    ,        
 [KEDB updated]                     ,        
 [Elevate Flag Internal]            ,        
 [RCA ID]                           ,        
 [Met Response SLA]                 ,        
 [Met Acknowledgement SLA]          ,        
 [Met Resolution]                   ,        
 [Response Time]                    ,        
 [Resolved by]                    ,        
 [Actual Start date Time]         ,        
 [Actual End date Time]           ,        
 [Planned Duration]               ,        
 [Actual duration]                ,        
 [TicketCreateDate]               ,        
 [Ticket Summary]                 ,        
 [NatureOfTheTicketID]            ,        
 [Nature Of The Ticket]           ,        
 [Technology]                     ,        
[Business Impact]                ,        
 [Job Process Name]               ,        
 [Server Name]                    ,        
 [Comments]                       ,        
 [Requester Customer Id]          ,        
 [Requester First Name]           ,        
 [Requester Internet Email]       ,        
 [Requester Contact Number]       ,        
 [Repeated Incident]              ,        
 [Related Tickets]                            ,         
 [Ticket Created By]                          ,         
 [KEDB Path]                                  ,         
 [Requested Resolution Date Time]             ,         
 [CSAT Score]                                 ,         
 [EscalatedFlagCustomerID]           ,         
 [Escalated Flag Customer]  ,         
 [Approved Date Time]                         ,         
 [Reviewed Date Time]                         ,         
 [Reason For Rejection]                       ,         
 [Reason For Cancel]                      ,         
 [Reason For On Hold]                         ,         
 [Response SLA Overridden Reason]             ,         
 [Resolution SLA Overridden Reason]           ,         
 [Acknowledgement SLA Overridden Reason]      ,         
 [Type]                ,         
 [Item]                                       ,         
 [Started Date Time]                          ,         
 [WIP Date Time]                              ,         
 [On Hold Date Time]                          ,         
 [Completed Date Time]                        ,         
 [Cancelled Date Time]                        ,         
 [Approved By]        ,         
 [Reviewed By]                                ,         
 [Customer Ticket ID]                         ,         
 [Outage Duration]                            ,         
 [OutageFlagID]                               ,         
 [Outage Flag]                      ,        
 [WarrantyIssueID]                  ,        
 [Warranty Issue]                   ,        
 [ResolutionDetails]                ,        
 [sourceID]                         ,        
 [severityID]                       ,        
 [releaseTypeID]                    ,        
 [Remarks]                          ,        
 [Assigned Time Stamp]              ,        
 [DARTStatusId]                     ,        
 [DebtClassificationId]             ,        
 [Debt Classification]         ,        
 [AvoidableFlagID]                  ,        
 [Avoidable Flag]                   ,        
 [Residual Debt]                    ,        
 [Resolution Method]                ,        
 [ResidualDebtID]                   ,        
 [Cause code]                       ,        
 [CauseCodeID]                      ,        
 [ITSM Effort]                      ,        
 [Assignment Group]                 ,        
 [Assignment Group ID]              ,        
 [UploadedBy]                       ,        
 [UploadedDate]                     ,        
 [Expected Completion Date]        ,        
 [Reason for Residual]              ,        
 [Resolution Remarks]               ,        
 [DebtModeID]                       ,        
 [Flex Field (1)]                   ,        
 [Flex Field (2)]                   ,        
 [Flex Field (3)]                   ,        
 [Flex Field (4)]                   ,        
 [Category]                         ,        
 TicketUploadTrackID                ,        
 LastModifiedSource                 ,        
 IsBOT                                        ,        
 IsTicketSummaryModified ,        
 IsTicketDescriptionModified ,        
 IsResolutionRemarksModified ,        
 IsCommentsModified ,        
 IsCauseCodeModified ,        
 IsResolutionCodeModified ,        
 IsFlexField1Modified ,        
 IsFlexField2Modified ,        
 IsFlexField3Modified ,        
 IsFlexField4Modified ,        
 IsCategoryModified ,        
 IsTypeModified ,        
 SupportType ,        
    [InitiatedSource],        
 TowerName,        
 TowerID ,        
 IsPartiallyAutomated        
 from #ImportTicketDumpDetails WHERE ISNULL(IsBOT,0) = 1        
        
        
        
 -- Deleted Bot Table from  #ImportTicketDumpDetails for filtering the tickets         
 DELETE FROM #ImportTicketDumpDetails WHERE IsBOT = 1        
        
        
        
         
 -- Insert only Infra Tickets        
 INSERT INTO #ImportTicketDumpDetails_Infra        
 select                    
 [Ticket ID]                   ,        
 [Ticket Type]           ,        
 [TicketTypeID]               ,        
 [Assignee]                   ,        
 [ActiveFlag]                 ,        
 [Close Date]                 ,        
 [Planned End Date]           ,        
 [Modified Date Time]         ,        
 [ArrivalDate]                ,        
 [Open Date]                  ,        
 [Priority]                   ,        
 [PriorityID]                 ,        
 [Reopen Date]                ,        
 [Sla Miss]                   ,        
 [ResolutionID]               ,        
 [Resolution Code]      ,        
 [Status]                     ,        
 [StatusID]                   ,        
 [Ticket Description]             ,        
 [Raised By Customer]             ,        
 [IsManual]                       ,        
 [ProductName]                    ,        
 [ModifiedBY]                     ,        
 [Ticket Source]                  ,        
 [Source Department]              ,        
 [Turn around Time]               ,        
 [Application]                 ,        
 [ApplicationID]                  ,        
 [Application Group Trail]        ,        
 [TicketLocation]                 ,        
 [Sec Assignee]            ,        
 [Root Cause]                     ,        
 [Reviewer]                       ,        
 [PriorityChng]                   ,        
 [Service]                        ,        
 [ServiceID]                      ,        
 [EmployeeID]                     ,        
 [EmployeeName]        ,        
 [External Login ID]              ,        
 [ProjectID]                      ,        
 [CTIcategory]                    ,        
 [CTItype]                        ,        
 [CTIitem]                        ,        
 [SecAssigneeID]                  ,        
 [UserID]                         ,        
 [SecClientUserID]                ,        
 [Accountprojectlobid]            ,        
 [LOBTrackid]                     ,        
 [IsDeleted]                     ,        
 [Severity]                      ,        
 [Release Type]                  ,        
 [Planned Effort]                ,        
 [Estimated Work Size]           ,        
 [Actual Work Size]              ,        
 [Planned Start Date and Time]      ,        
 [New Status Date Time]             ,        
 [Resolved date]                    ,        
 [Rejected Time Stamp]              ,        
 [Release Date]                     ,        
 [KEDBAvailableIndicatorID]         ,        
 [KEDB Available Indicator]         ,        
 [KEDBupdatedID]                    ,        
 [KEDB updated]                     ,        
 [Elevate Flag Internal]            ,        
 [RCA ID]         ,        
 [Met Response SLA]                 ,        
 [Met Acknowledgement SLA]          ,        
 [Met Resolution]                   ,        
 [Response Time]                    ,        
 [Resolved by]                    ,        
 [Actual Start date Time]         ,        
 [Actual End date Time]           ,        
 [Planned Duration]               ,        
 [Actual duration]                ,        
 [TicketCreateDate]               ,        
 [Ticket Summary]                 ,        
 [NatureOfTheTicketID]            ,        
 [Nature Of The Ticket]           ,        
 [Technology]                     ,        
 [Business Impact]                ,        
 [Job Process Name]               ,        
 [Server Name]                    ,        
 [Comments]                       ,        
 [Requester Customer Id]          ,        
 [Requester First Name]           ,        
 [Requester Internet Email]       ,        
 [Requester Contact Number]       ,        
 [Repeated Incident]              ,        
 [Related Tickets]                            ,         
 [Ticket Created By]                          ,         
 [KEDB Path]                                  ,         
 [Requested Resolution Date Time]             ,         
 [CSAT Score]                                 ,         
 [EscalatedFlagCustomerID]                    ,         
 [Escalated Flag Customer]                  ,         
 [Approved Date Time]                         ,         
 [Reviewed Date Time]                         ,         
 [Reason For Rejection]                       ,         
 [Reason For Cancel]                          ,         
 [Reason For On Hold]                         ,         
 [Response SLA Overridden Reason]             ,         
 [Resolution SLA Overridden Reason]           ,         
 [Acknowledgement SLA Overridden Reason]      ,         
 [Type]                                       ,         
 [Item]                                       ,         
 [Started Date Time]                          ,         
 [WIP Date Time]                              ,         
 [On Hold Date Time]            ,         
 [Completed Date Time]                        ,         
 [Cancelled Date Time]                        ,         
 [Approved By]                                ,         
 [Reviewed By]                                ,         
 [Customer Ticket ID]                         ,         
 [Outage Duration]                            ,         
 [OutageFlagID]                               ,         
 [Outage Flag]                      ,        
 [WarrantyIssueID]              ,        
 [Warranty Issue]                   ,        
 [ResolutionDetails]                ,        
 [sourceID]                         ,        
 [severityID]                       ,        
 [releaseTypeID]            ,        
 [Remarks]                          ,        
 [Assigned Time Stamp]              ,        
 [DARTStatusId]                     ,        
 [DebtClassificationId]             ,        
 [Debt Classification]              ,        
 [AvoidableFlagID]                  ,        
 [Avoidable Flag]               ,        
 [Residual Debt]                    ,        
 [Resolution Method]                ,        
 [ResidualDebtID]                   ,        
 [Cause code]                       ,        
 [CauseCodeID]                      ,        
 [ITSM Effort]                      ,        
 [Assignment Group]           ,        
 [Assignment Group ID]              ,        
 [UploadedBy]                       ,        
 [UploadedDate]                     ,        
 [Expected Completion Date]        ,        
 [Reason for Residual]              ,        
 [Resolution Remarks]               ,        
 [DebtModeID]                      ,        
 [Flex Field (1)]                   ,        
 [Flex Field (2)]                   ,        
 [Flex Field (3)]                   ,        
 [Flex Field (4)]                   ,        
 [Category]                         ,        
 TicketUploadTrackID                ,        
 LastModifiedSource                 ,        
 IsBOT                                        ,        
 IsTicketSummaryModified ,        
 IsTicketDescriptionModified ,        
 IsResolutionRemarksModified ,        
 IsCommentsModified ,        
 IsCauseCodeModified ,        
 IsResolutionCodeModified ,        
 IsFlexField1Modified ,        
 IsFlexField2Modified ,        
 IsFlexField3Modified ,        
 IsFlexField4Modified ,        
 IsCategoryModified ,        
 IsTypeModified ,        
 SupportType ,        
    [InitiatedSource],        
 TowerName,        
 TowerID,        
 IsPartiallyAutomated,        
 IsGracePeriodMet        
        
 from #ImportTicketDumpDetails(NOLOCK) WHERE ISNULL(SupportType,1) = 2 and IsNull(IsBOT,0) = 0         
        
 -- Deleted Bot Table from  #ImportTicketDumpDetails for filtering the tickets         
 DELETE FROM #ImportTicketDumpDetails WHERE IsNull(SupportType,1) = 2 and IsNull(IsBOT,0) = 0         
        
 /*************************Multilingual*************************************/        
 IF(@isMultiLingual=1)        
  BEGIN        
SELECT ITD.[Ticket ID],TD.TimeTickerID,ITD.IsTicketSummaryModified,ITD.IsTicketDescriptionModified,        
CASE WHEN (@IsResolutionRemarks =1 AND (( ITD.[Resolution Remarks]=TD.ResolutionRemarks)         
   OR (ITD.[Resolution Remarks]='') OR (ITD.[Resolution Remarks] IS NULL)))        
   OR (@IsResolutionRemarks !=1)        
   THEN 0 ELSE 1 END AS 'IsResolutionRemarksModified',        
CASE WHEN (@IsComments =1 AND (( ITD.Comments=TD.Comments) OR (ITD.Comments='') OR         
   (ITD.Comments IS NULL))) OR (@IsComments !=1)        
   THEN 0 ELSE 1 END AS 'IsCommentsModified',        
--CASE WHEN @IsCauseCode =1 AND ITD.CauseCodeID!=TD.CauseCodeMapID        
--THEN 1 ELSE ITD.IsCauseCodeModified END AS 'IsCauseCodeModified',        
--CASE WHEN @IsResolutionCode =1 AND ITD.ResolutionID!=TD.ResolutionCodeMapID        
--THEN 1 ELSE ITD.IsResolutionCodeModified END AS 'IsResolutionCodeModified',        
CASE WHEN (@IsFlexField1 =1 AND ((ITD.[Flex Field (1)]=TD.FlexField1) OR (ITD.[Flex Field (1)]='')        
    OR(ITD.[Flex Field (1)] IS NULL))) OR (@IsFlexField1!=1)        
   THEN 0 ELSE 1 END AS 'IsFlexField1Modified',        
CASE WHEN (@IsFlexField2 =1 AND ((ITD.[Flex Field (2)]=TD.FlexField2) OR (ITD.[Flex Field (2)]='') OR        
    (ITD.[Flex Field (2)] IS NULL))) OR (@IsFlexField2!=1)        
 THEN 0 ELSE 1 END AS 'IsFlexField2Modified',        
CASE WHEN (@IsFlexField3 =1 AND ((ITD.[Flex Field (3)]=TD.FlexField3) OR (ITD.[Flex Field (3)]='')         
 OR (ITD.[Flex Field (3)] IS NULL))) OR (@IsFlexField3!=1)        
 THEN 0 ELSE 1 END AS 'IsFlexField3Modified',        
CASE WHEN (@IsFlexField4 =1 AND ((ITD.[Flex Field (4)]=TD.FlexField4) OR (ITD.[Flex Field (4)]='')        
  OR(ITD.[Flex Field (4)] IS NULL))) OR (@IsFlexField4!=1)        
 THEN 0 ELSE 1 END AS 'IsFlexField4Modified',        
CASE WHEN (@IsCategory =1 AND (( ITD.Category=TD.Category) OR (ITD.Category='') OR        
 (ITD.Category IS NULL))) OR (@IsCategory !=1)        
 THEN 0 ELSE 1 END AS 'IsCategoryModified',        
CASE WHEN (@IsType =1 AND ((ITD.[Type]=TD.[Type]) OR ( ITD.[Type] IS NULL)         
 OR ( ITD.[Type]=''))) OR (@IsType!=1)        
 THEN 0 ELSE 1 END AS 'IsTypeModified'        
INTO #MultilingualTbl2        
FROM  #ImportTicketDumpDetails(NOLOCK) ITD LEFT JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON TD.TicketID=ITD.[Ticket ID]         
AND TD.ProjectID=@projectid AND TD.IsDeleted=0;        
        
SELECT ITD.[Ticket ID],TD.TimeTickerID,ITD.IsTicketSummaryModified,ITD.IsTicketDescriptionModified,        
CASE WHEN (@IsResolutionRemarks =1 AND (( ITD.[Resolution Remarks]=TD.ResolutionRemarks)         
   OR (ITD.[Resolution Remarks]='') OR (ITD.[Resolution Remarks] IS NULL)))        
   OR (@IsResolutionRemarks !=1)        
   THEN 0 ELSE 1 END AS 'IsResolutionRemarksModified',        
CASE WHEN (@IsComments =1 AND (( ITD.Comments=TD.Comments) OR (ITD.Comments='') OR         
   (ITD.Comments IS NULL))) OR (@IsComments !=1)        
   THEN 0 ELSE 1 END AS 'IsCommentsModified',        
--CASE WHEN @IsCauseCode =1 AND ITD.CauseCodeID!=TD.CauseCodeMapID        
--THEN 1 ELSE ITD.IsCauseCodeModified END AS 'IsCauseCodeModified',        
--CASE WHEN @IsResolutionCode =1 AND ITD.ResolutionID!=TD.ResolutionCodeMapID        
--THEN 1 ELSE ITD.IsResolutionCodeModified END AS 'IsResolutionCodeModified',        
CASE WHEN (@IsFlexField1 =1 AND ((ITD.[Flex Field (1)]=TD.FlexField1) OR (ITD.[Flex Field (1)]='')        
    OR(ITD.[Flex Field (1)] IS NULL))) OR (@IsFlexField1!=1)        
   THEN 0 ELSE 1 END AS 'IsFlexField1Modified',        
CASE WHEN (@IsFlexField2 =1 AND ((ITD.[Flex Field (2)]=TD.FlexField2) OR (ITD.[Flex Field (2)]='') OR        
    (ITD.[Flex Field (2)] IS NULL))) OR (@IsFlexField2!=1)        
 THEN 0 ELSE 1 END AS 'IsFlexField2Modified',        
CASE WHEN (@IsFlexField3 =1 AND ((ITD.[Flex Field (3)]=TD.FlexField3) OR (ITD.[Flex Field (3)]='')         
 OR (ITD.[Flex Field (3)] IS NULL))) OR (@IsFlexField3!=1)        
 THEN 0 ELSE 1 END AS 'IsFlexField3Modified',        
CASE WHEN (@IsFlexField4 =1 AND ((ITD.[Flex Field (4)]=TD.FlexField4) OR (ITD.[Flex Field (4)]='')        
  OR(ITD.[Flex Field (4)] IS NULL))) OR (@IsFlexField4!=1)        
 THEN 0 ELSE 1 END AS 'IsFlexField4Modified',        
CASE WHEN (@IsCategory =1 AND (( ITD.Category=TD.Category) OR (ITD.Category='') OR        
 (ITD.Category IS NULL))) OR (@IsCategory !=1)        
 THEN 0 ELSE 1 END AS 'IsCategoryModified',        
CASE WHEN (@IsType =1 AND ((ITD.[Type]=TD.[Type]) OR ( ITD.[Type] IS NULL)         
 OR ( ITD.[Type]=''))) OR (@IsType!=1)        
 THEN 0 ELSE 1 END AS 'IsTypeModified'        
INTO #MultilingualTblInfra        
FROM  #ImportTicketDumpDetails_Infra (NOLOCK) ITD LEFT JOIN AVL.TK_TRN_InfraTicketDetail (NOLOCK) TD ON TD.TicketID=ITD.[Ticket ID]         
AND TD.ProjectID=@projectid AND TD.IsDeleted=0;        
        
END        
  /*************************************************************************/        
 /**************************GRACE PERIOD UNDO UPDATE For APP Tickets***********************/        
        
     UPDATE #ImportTicketDumpDetails        
       SET        
     [tickettypeid]= TD.[tickettypemapid],        
     --[ServiceID]=TD.ServiceID,        
     [dartstatusid] = TD.[dartstatusid],        
  [statusid]=TD.[TicketStatusMapID],        
  [applicationid]=TD.[applicationid],        
  [causecodeid]= TD.[causecodemapid],        
  [resolutionid]=TD.[resolutioncodemapid],        
        [debtclassificationid]=TD.[debtclassificationmapid],        
      [residualdebtid]=TD.[residualdebtmapid],        
  [avoidableflagid]= TD.[avoidableflag],        
  IsPartiallyAutomated=TD.IsPartiallyAutomated,        
  [Open Date]=TD.OpenDateTime,        
        [Flex Field (1)]=(CASE  WHEN @FlexField1 =1 AND (Debt.OptionalAttributeType=1 OR Debt.OptionalAttributeType=3) THEN TD.[FlexField1] ELSE [Flex Field (1)] END),        
  [Flex Field (2)]=(CASE  WHEN @FlexField2 =1 AND (Debt.OptionalAttributeType=1 OR Debt.OptionalAttributeType=3) THEN TD.[FlexField2] ELSE [Flex Field (2)] END),        
  [Flex Field (3)]=(CASE  WHEN @FlexField3 =1 AND (Debt.OptionalAttributeType=1 OR Debt.OptionalAttributeType=3) THEN TD.[FlexField3] ELSE [Flex Field (3)] END),        
  [Flex Field (4)]=(CASE  WHEN @FlexField4 =1 AND (Debt.OptionalAttributeType=1 OR Debt.OptionalAttributeType=3) THEN TD.[FlexField4] ELSE [Flex Field (4)] END),        
  [Ticket Description]=(CASE WHEN (Debt.OptionalAttributeType=2 OR Debt.OptionalAttributeType=3) THEN TD.TicketDescription ELSE [Ticket Description] END),        
  [Resolution Remarks]=(CASE WHEN (Debt.OptionalAttributeType=2 OR Debt.OptionalAttributeType=3) AND @ResolutionRemarksApp=1 THEN TD.ResolutionRemarks ELSE [Resolution Remarks] END),        
  [Resolution Method]= (CASE WHEN (Debt.OptionalAttributeType=2 OR Debt.OptionalAttributeType=3) AND @ResolutionRemarksApp=1 THEN TD.ResolutionRemarks ELSE [Resolution Method] END)        
        
       FROM #ImportTicketDumpDetails T INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD        
       ON T.[Ticket ID] = TD.TicketID  AND TD.ProjectID  = @ProjectID AND TD.IsDeleted<>1        
    LEFT JOIN [AVL].MAS_ProjectDebtDetails (NOLOCK) AS Debt ON Debt.ProjectID=T.ProjectID AND Debt.IsDeleted<>1        
      WHERE T.ProjectID=@ProjectID AND  T.IsGracePeriodMet=1 and TD.DARTStatusID in(8,9)        
  --AND (TD.CauseCodeMapID IS NOT NULL OR TD.ResolutionCodeMapID IS NOT NULL OR TD.AvoidableFlag IS NOT NULL        
  --  OR TD.ResidualDebtMapID IS NOT NULL OR TD.DebtClassificationMapID IS NOT NULL)        
            
 UPDATE #ImportTicketDumpDetails   SET         
  [statusid]=PS.[StatusID]        
  From #ImportTicketDumpDetails T inner join AVL.TK_MAP_ProjectStatusMapping (NOLOCK) PS        
  on T.DARTStatusId=PS.TicketStatus_ID and T.ProjectID=PS.ProjectID        
   WHERE T.ProjectID=@ProjectID AND  T.IsGracePeriodMet=1         
        
  /*************************************************************************/        
        
   INSERT INTO #RegexTicketDetail([TicketID],ProjectID,TicketDescription,ResolutionRemarks,TicketSummary,Comments,SupportType)        
  SELECT [Ticket ID],ProjectID,[Ticket Description],[Resolution Remarks],[Ticket Summary],Comments,SupportType from #ImportTicketDumpDetails WITH(NOLOCK)        
        
        
        
    MERGE [AVL].[tk_trn_ticketdetail] TD         
    using #ImportTicketDumpDetails T1         
    ON t1.[Ticket ID] = TD.[ticketid]         
       AND t1.[ProjectID] = TD.[projectid]         
    WHEN matched THEN         
      UPDATE SET TD.[applicationid] = ISNULL(T1.[applicationid],TD.[applicationid] ) ,        
                 TD.[assignedto] = ISNULL(T1.UserID, TD.[assignedto] ),        
                 --TD.[EffortTillDate]= ,         
                 TD.[ticketdescription] =CASE WHEN RTRIM(LTRIM(t1.[ticket description]))!= '' AND RTRIM(LTRIM(t1.[ticket description])) IS NOT NULL THEN  T1.[ticket description] ELSE TD.[ticketdescription] END,        
                 TD.[IsDeleted] = ISNULL(T1.IsDeleted,  0),         
    TD.[causecodemapid] = ISNULL(T1.[causecodeid],  TD.[causecodemapid]),        
                 TD.[debtclassificationmapid] = ISNULL(T1.[debtclassificationid], TD.[debtclassificationmapid]),        
                 TD.[residualdebtmapid] = ISNULL(T1.[residualdebtid], TD.[residualdebtmapid]),        
            TD.[resolutioncodemapid] = ISNULL(T1.[resolutionid],   TD.[resolutioncodemapid]),        
    --TD.[ResolutionMethodMapID]= ,         
    TD.[kedbavailableindicatormapid] = ISNULL(T1.[kedbavailableindicatorid],TD.[kedbavailableindicatormapid]),         
    TD.[kedbupdatedmapid] = ISNULL(T1.[kedbupdatedid], TD.[kedbupdatedmapid]),        
    TD.[kedbpath] = ISNULL(T1.[kedb path],  TD.[kedbpath]),        
    TD.[prioritymapid] = ISNULL(T1.[priorityid],  TD.[prioritymapid]),        
    TD.[releasetypemapid] = ISNULL(T1.[releasetypeid], TD.[releasetypemapid]),        
    TD.[severitymapid] = ISNULL(T1.[severityid],  TD.[severitymapid]),        
    TD.[ticketsourcemapid] = ISNULL(T1.[sourceid], TD.[ticketsourcemapid]),        
    TD.[ticketstatusmapid] = ISNULL(T1.[statusid],  TD.[ticketstatusmapid]),        
    TD.[tickettypemapid] = ISNULL(T1.[tickettypeid], TD.[tickettypemapid]),        
    TD.[businesssourcename] = ISNULL(T1.[source department], TD.[businesssourcename]),        
    --TD.[Onsite_Offshore]= ,         
    TD.[plannedeffort] =  CASE WHEN t1.[planned effort]> 0.0 AND  T1.[planned effort] IS NOT NULL THEN  T1.[planned effort] ELSE  TD.[plannedeffort] END,        
    TD.[estimatedworksize] = CASE WHEN t1.[estimated work size]> 0.0 AND  T1.[estimated work size] IS NOT NULL THEN    T1.[estimated work size] ELSE TD.[estimatedworksize] END,        
    --TD.[ActualEffort]= ISNULL(T1.[actual work size], TD.[actualworksize]),,         
    TD.[actualworksize] = CASE WHEN T1.[actual work size] is NOT NULL and T1.[actual work size] !='0.00' THEN T1.[actual work size] ELSE  TD.[actualworksize] END,        
    TD.[resolvedby] = ISNULL(T1.[resolved by],  TD.[resolvedby]),        
    --TD.[Closedby]= ,         
    TD.[elevateflaginternal] = ISNULL(T1.[elevate flag internal], TD.[elevateflaginternal]),        
    TD.[rcaid] = ISNULL(T1.[rca id],TD.[rcaid]),         
    TD.[plannedduration] =CASE WHEN t1.[planned duration]> 0.0 AND  T1.[planned duration] IS NOT NULL THEN   T1.[planned duration] ELSE  TD.[plannedduration] END,        
    TD.[actualduration] = CASE WHEN t1.[actual duration]> 0.0 AND  T1.[actual duration] IS NOT NULL THEN   T1.[actual duration] ELSE TD.[actualduration] END,        
    TD.[ticketsummary] = CASE WHEN RTRIM(LTRIM(t1.[ticket summary]))!= '' AND RTRIM(LTRIM(t1.[ticket summary])) IS NOT NULL   THEN  T1.[ticket summary] ELSE TD.[ticketsummary] END,        
    TD.[natureoftheticket] = ISNULL(T1.[NatureOfTheTicketID], TD.[natureoftheticket]),        
    TD.[comments] = ISNULL(T1.[comments],  TD.[comments]),        
    TD.[repeatedincident] = ISNULL(T1.[repeated incident],   TD.[repeatedincident]),        
    TD.[relatedtickets] = ISNULL(T1.[related tickets], TD.[relatedtickets]),        
    TD.[ticketcreatedby] = ISNULL(T1.[ticket created by],   TD.[ticketcreatedby] ),        
    TD.[secondaryresources] = ISNULL(T1.[sec assignee],  TD.[secondaryresources]),        
    TD.[escalatedflagcustomer] = ISNULL(T1.[escalatedflagcustomerid],TD.[escalatedflagcustomer] ),         
    TD.[reasonforrejection] = ISNULL(T1.[reason for rejection], TD.[reasonforrejection] ),         
    TD.[avoidableflag] = ISNULL(T1.[avoidableflagid],   TD.[avoidableflag] ),        
    TD.[releasedate] = ISNULL(T1.[release date],   TD.[releasedate]),        
    --TD.[ticketcreatedate] = T1.[ticketcreatedate],         
    TD.[plannedstartdate] = ISNULL(T1.[planned start date and time],  TD.[plannedstartdate]),        
    TD.[plannedenddate] = ISNULL(T1.[planned end date],  TD.[plannedenddate]),        
    TD.[actualstartdatetime] = ISNULL(T1.[actual start date time], TD.[actualstartdatetime]),        
    TD.[actualenddatetime] = ISNULL(T1.[actual end date time], TD.[actualenddatetime]),         
    TD.[opendatetime] = ISNULL(T1.[open date],   TD.[opendatetime] ),        
    TD.[starteddatetime] = ISNULL(T1.[started date time],    TD.[starteddatetime]),        
    TD.[wipdatetime] = ISNULL(T1.[wip date time],  TD.[wipdatetime]),        
    TD.[onholddatetime] = ISNULL(T1.[on hold date time],  TD.[onholddatetime]),        
    TD.[completeddatetime] = ISNULL(T1.[completed date time], TD.[completeddatetime]),    
    TD.[reopendatetime] = ISNULL(T1.[reopen date],  TD.[reopendatetime] ),        
    TD.[cancelleddatetime] = ISNULL(T1.[cancelled date time],  TD.[cancelleddatetime]),        
TD.[rejecteddatetime] = ISNULL(T1.[rejected time stamp], TD.[rejecteddatetime]),        
    TD.[closeddate] = ISNULL(T1.[close date], TD.[closeddate]),        
    TD.[assigneddatetime] = ISNULL(T1.[assigned time stamp], TD.[assigneddatetime]),         
    TD.[outageduration] =CASE WHEN CONVERT(decimal(25,2),T1.[outage duration]) >0.0 AND CONVERT(decimal(25,2),T1.[outage duration]) IS NOT NULL THEN CONVERT(decimal(25,2),T1.[outage duration]) ELSE TD.[outageduration] END,         
    TD.[metresponseslamapid] = ISNULL(T1.[met response sla],  TD.[metresponseslamapid]),        
    TD.[metacknowledgementslamapid] = ISNULL(T1.[met acknowledgement sla],  TD.[metacknowledgementslamapid]),        
    TD.[metresolutionmapid] = ISNULL(T1.[met resolution],  TD.[metresolutionmapid]),        
    --TD.[EscalationSLA]= ,         
    --TD.[TKBusinessID] =,         
    --TD.[InscopeOutscope] =,         
    --TD.[IsAttributeUpdated]= ,         
    TD.[newstatusdatetime] = ISNULL(T1.[new status date time],TD.[newstatusdatetime] ),         
    --TD.[IsSDTicket]= ,         
    --TD.[IsManual]= ,         
    TD.[dartstatusid] = ISNULL(T1.[dartstatusid],TD.[dartstatusid] ),         
 TD.[resolutionremarks] = CASE WHEN  T1.[Resolution Method] IS NOT NULL AND T1.[Resolution Method] != '' THEN T1.[Resolution Method] ELSE TD.[resolutionremarks] END ,        
   -- TD.[resolutionremarks] = T1.[resolutiondetails] CONVERT(DECIMAL(25,2), T1.[itsm effort]),    TD.[itsmeffort] ,         
    TD.[itsmeffort] = CASE WHEN t1.[ITSM Effort] is NOT NULL and T1.[ITSM Effort] !='0.00' THEN T1.[ITSM Effort] ELSE  TD.[itsmeffort] END,          
    TD.[LastUpdatedDate] =GETDATE(),         
    TD.[modifiedby] = @CogID,         
    TD.[modifieddate] = Getdate(),         
    --TD.[IsApproved]= ,         
    --TD.[ReasonResidualMapID]= ,         
    TD.[ExpectedCompletionDate]=ISNULL(T1.[Expected Completion Date] ,  TD.[ExpectedCompletionDate]),        
    TD.[approvedby] = ISNULL(T1.[approved by] ,  TD.[approvedby] ),        
    TD.[FlexField1] = ISNULL(T1.[Flex Field (1)],TD.[FlexField1] ),        
 TD.[FlexField2] = ISNULL(T1.[Flex Field (2)],TD.[FlexField2] ),        
 TD.[FlexField3] = ISNULL(T1.[Flex Field (3)],TD.[FlexField3]),         
 TD.[FlexField4] = ISNULL(T1.[Flex Field (4)],TD.[FlexField4] ),        
 TD.[Category] = ISNULL(T1.[Category],TD.[Category] ),        
 TD.[Type] = ISNULL(T1.[Type],TD.[Type]),        
 TD.AssignmentGroupID = ISNULL(T1.[Assignment Group ID],TD.AssignmentGroupID),        
 TD.AssignmentGroup = ISNULL(T1.[Assignment Group],TD.AssignmentGroup),        
 TD.LastModifiedSource = ISNULL(@TicketSource,TD.LastModifiedSource),        
 TD.[IsPartiallyAutomated] =IsNull(T1.IsPartiallyAutomated,ISNULL(TD.[IsPartiallyAutomated],2)),        
 TD.[TicketDescriptionBasePattern] = ISNULL(T1.[TicketDescriptionBasePattern],TD.[TicketDescriptionBasePattern]),        
 TD.[TicketDescriptionSubPattern]= ISNULL(T1.[TicketDescriptionSubPattern],TD.[TicketDescriptionSubPattern]),        
 TD.[ResolutionRemarksBasePattern] = ISNULL(T1.[ResolutionRemarksBasePattern],TD.[ResolutionRemarksBasePattern]),        
 TD.[ResolutionRemarksSubPattern] = ISNULL(T1.[ResolutionRemarksSubPattern],TD.[ResolutionRemarksSubPattern]),        
 TD.[serviceid] = CASE WHEN ISNULL(TD.[serviceid],0) = 0 AND ISNULL(T1.[serviceid],0) <> 0        
        AND TD.ServiceClassificationMode = 3        
       THEN T1.[serviceid]        
       ELSE TD.[serviceid]        
     END,        
 TD.ServiceClassificationMode = CASE WHEN ISNULL(T1.[serviceid],0) <> 0 AND TD.ServiceClassificationMode = 3                              
          THEN 5        
          ELSE TD.ServiceClassificationMode        
         END            
    WHEN NOT matched THEN         
      INSERT ([ticketid],         
              [applicationid],         
       [projectid],         
              [assignedto],         
              [efforttilldate],         
   [serviceid],         
              [ticketdescription],         
              [isdeleted],         
              [causecodemapid],         
              [debtclassificationmapid],         
              [residualdebtmapid],         
              [resolutioncodemapid],         
              [resolutionmethodmapid],         
              [kedbavailableindicatormapid],         
              [kedbupdatedmapid],         
              [kedbpath],         
              [prioritymapid],         
              [releasetypemapid],         
              [severitymapid],         
              [ticketsourcemapid],         
          [ticketstatusmapid],         
              [tickettypemapid],         
              [businesssourcename],         
              [onsite_offshore],         
              [plannedeffort],         
              [estimatedworksize],         
              [actualeffort],         
    [actualworksize],         
              [resolvedby],         
              [closedby],         
              [elevateflaginternal],         
              [rcaid],         
              [plannedduration],         
              [actualduration],         
              [ticketsummary],         
              [natureoftheticket],         
              [comments],         
              [repeatedincident],         
              [relatedtickets],         
              [ticketcreatedby],         
              [secondaryresources],         
              [escalatedflagcustomer],         
              [reasonforrejection],         
              [avoidableflag],         
              [releasedate],         
              [ticketcreatedate],         
              [plannedstartdate],         
              [plannedenddate],         
              [actualstartdatetime],         
              [actualenddatetime],         
              [opendatetime],         
              [starteddatetime],         
              [wipdatetime],         
              [onholddatetime],         
              [completeddatetime],         
              [reopendatetime],         
              [cancelleddatetime],         
              [rejecteddatetime],         
              [closeddate],         
              [assigneddatetime],         
              [outageduration],         
              [metresponseslamapid],         
              [metacknowledgementslamapid],         
              [metresolutionmapid],         
              [escalationsla],         
              [tkbusinessid],         
              [inscopeoutscope],         
              [isattributeupdated],         
              [newstatusdatetime],         
              [issdticket],         
              [ismanual],         
              [dartstatusid],         
              [resolutionremarks],         
              [itsmeffort],         
              [createdby],         
              [createddate],         
              [lastupdateddate],         
              [modifiedby],         
              [modifieddate],         
          [isapproved],         
              [reasonresidualmapid],         
              [expectedcompletiondate],         
              [approvedby],        
      [FlexField1],        
     [FlexField2],        
     [FlexField3],        
     [FlexField4],        
     [Category],        
     [Type],        
     [AssignmentGroupID],        
     InitiatedSource,        
     IsPartiallyAutomated,        
    [TicketDescriptionBasePattern],         
    [TicketDescriptionSubPattern],        
    [ResolutionRemarksBasePattern],        
    [ResolutionRemarksSubPattern],        
    ServiceClassificationMode,        
    AssignmentGroup        
     )         
      VALUES (RTRIM(LTRIM(T1.[ticket id])),         
              ISNULL(T1.[applicationid],0),         
              T1.[projectid],         
              T1.UserID,         
              0,         
              Isnull(T1.[serviceid], ''),         
        Isnull(T1.[ticket description], ''),         
              0,         
              T1.[causecodeid],         
         T1.[debtclassificationid],         
              T1.[residualdebtid],         
              T1.[resolutionid],         
              NULL,         
              T1.[kedbavailableindicatorid],         
              T1.[kedbupdatedid],         
              T1.[kedb path],         
T1.[priorityid],         
              T1.[releasetypeid],         
              T1.[severityid],         
              T1.[sourceid],         
              T1.[statusid],         
              T1.[tickettypeid],         
              T1.[source department],         
              NULL,         
              T1.[planned effort],         
              T1.[estimated work size],         
              '0',         
              T1.[actual work size],         
      T1.[resolved by],         
              Null, --Closedby         
              T1.[elevate flag internal],         
              T1.[rca id],         
              T1.[planned duration],         
              T1.[actual duration],         
              T1.[ticket summary],         
              T1.[natureoftheticketid],         
              T1.[comments],         
              T1.[repeated incident],         
              T1.[related tickets],         
              T1.[ticket created by],         
              T1.[sec assignee],         
              T1.[escalatedflagcustomerid],         
              T1.[reason for rejection],         
              T1.[avoidableflagid],         
              T1.[release date],         
              GETDATE(),         
              T1.[planned start date and time],         
              T1.[planned end date],         
              T1.[actual start date time],        
              T1.[actual end date time],         
      T1.[open date],         
              T1.[started date time],         
              T1.[wip date time],         
              T1.[on hold date time],         
              T1.[completed date time],         
              T1.[reopen date],         
              T1.[cancelled date time],         
              T1.[rejected time stamp],         
              T1.[close date],         
              T1.[assigned time stamp],         
           CONVERT(DECIMAL(25,2), T1.[outage duration]),         
              T1.[met response sla],         
              T1.[met acknowledgement sla],         
              T1.[met resolution],         
              0,--'EscalationSLA',         
              0,--'TKBusinessID',         
              Null, --'InscopeOutscope',         
              0,--'IsAttributeUpdated',         
              T1.[new status date time],         
              0,--'IsSDTicket',         
              0,--'IsManual',         
              T1.[dartstatusid],         
              IIF( T1.[Resolution Method]='',NULL, T1.[Resolution Method]),         
              Convert(Decimal(25,2),T1.[itsm effort]),         
              @CogID,         
              Getdate(),         
              Getdate(),         
              NULL,         
              NULL,         
              0,         
              NULL,         
              T1.[Expected Completion Date],         
              T1.[approved by],        
     T1.[Flex Field (1)],        
     T1.[Flex Field (2)],        
     T1.[Flex Field (3)],        
     T1.[Flex Field (4)],        
     T1.[Category],        
     T1.[Type],        
     T1.[Assignment Group ID],        
     @TicketSource,        
    ISNULL( T1.IsPartiallyAutomated,2),        
    T1.[TicketDescriptionBasePattern],         
    T1.[TicketDescriptionSubPattern],        
    T1.[ResolutionRemarksBasePattern],        
    T1.[ResolutionRemarksSubPattern],        
    CASE WHEN Isnull(T1.[serviceid],0) <> 0         
    THEN 5        
    ELSE 3        
    END,        
    T1.[Assignment Group]        
     );         
         
         
 Update [AVL].[tk_trn_ticketdetail] set IsAttributeUpdated='0' where (DARTStatusID='8' or DARTStatusID='9')        
 and (Closeddate is null or DebtClassificationMapID is null or CauseCodeMapID is null or ResolutionCodeMapID is null) and projectid=@ProjectID        
        
 MERGE [AVL].[TK_TRN_BOTTicketDetail] TD         
    using #ImportTicketDumpDetails_BOT T1         
    ON t1.[Ticket ID] = TD.[ticketid]         
       AND t1.[ProjectID] = TD.[projectid]         
    WHEN matched THEN         
      UPDATE SET TD.[applicationid] = ISNULL(T1.[applicationid],TD.[applicationid] ) ,        
     TD.TowerID = ISNULL(T1.[TowerID],TD.[TowerID] ),        
                 TD.[assignedto] = ISNULL(T1.UserID, TD.[assignedto] ),        
                 --TD.[EffortTillDate]= ,         
                 TD.[ticketdescription] =CASE WHEN RTRIM(LTRIM(t1.[ticket description]))!= '' AND RTRIM(LTRIM(t1.[ticket description])) IS NOT NULL THEN  T1.[ticket description] ELSE TD.[ticketdescription] END,        
    TD.[IsDeleted] = ISNULL(T1.IsDeleted,  0),          
                 TD.[causecodemapid] = ISNULL(T1.[causecodeid],  TD.[causecodemapid]),        
                 TD.[debtclassificationmapid] = ISNULL(T1.[debtclassificationid], TD.[debtclassificationmapid]),        
                 TD.[residualdebtmapid] = ISNULL(T1.[residualdebtid], TD.[residualdebtmapid]),        
                 TD.[resolutioncodemapid] = ISNULL(T1.[resolutionid],   TD.[resolutioncodemapid]),        
    --TD.[ResolutionMethodMapID]= ,         
    TD.[kedbavailableindicatormapid] = ISNULL(T1.[kedbavailableindicatorid],TD.[kedbavailableindicatormapid]),         
    TD.[kedbupdatedmapid] = ISNULL(T1.[kedbupdatedid], TD.[kedbupdatedmapid]),        
    TD.[kedbpath] = ISNULL(T1.[kedb path],  TD.[kedbpath]),        
    TD.[prioritymapid] = ISNULL(T1.[priorityid],  TD.[prioritymapid]),        
    TD.[releasetypemapid] = ISNULL(T1.[releasetypeid], TD.[releasetypemapid]),        
    TD.[severitymapid] = ISNULL(T1.[severityid],  TD.[severitymapid]),        
    TD.[ticketsourcemapid] = ISNULL(T1.[sourceid], TD.[ticketsourcemapid]),        
    TD.[ticketstatusmapid] = ISNULL(T1.[statusid],  TD.[ticketstatusmapid]),        
    TD.[tickettypemapid] = ISNULL(T1.[tickettypeid], TD.[tickettypemapid]),        
    TD.[businesssourcename] = ISNULL(T1.[source department], TD.[businesssourcename]),        
    --TD.[Onsite_Offshore]= ,         
    TD.[plannedeffort] =  CASE WHEN t1.[planned effort]> 0.0 AND  T1.[planned effort] IS NOT NULL THEN  T1.[planned effort] ELSE  TD.[plannedeffort] END,        
    TD.[estimatedworksize] = CASE WHEN t1.[estimated work size]> 0.0 AND  T1.[estimated work size] IS NOT NULL THEN    T1.[estimated work size] ELSE TD.[estimatedworksize] END,        
    --TD.[ActualEffort]= ISNULL(T1.[actual work size], TD.[actualworksize]),,         
    TD.[actualworksize] = CASE WHEN T1.[actual work size] is NOT NULL and T1.[actual work size] !='0.00' THEN T1.[actual work size] ELSE  TD.[actualworksize] END,        
    TD.[resolvedby] = ISNULL(T1.[resolved by],  TD.[resolvedby]),        
    --TD.[Closedby]= ,         
    TD.[elevateflaginternal] = ISNULL(T1.[elevate flag internal], TD.[elevateflaginternal]),        
    TD.[rcaid] = ISNULL(T1.[rca id],TD.[rcaid]),         
    TD.[plannedduration] =CASE WHEN t1.[planned duration]> 0.0 AND  T1.[planned duration] IS NOT NULL THEN   T1.[planned duration] ELSE  TD.[plannedduration] END,        
    TD.[actualduration] = CASE WHEN t1.[actual duration]> 0.0 AND  T1.[actual duration] IS NOT NULL THEN   T1.[actual duration] ELSE TD.[actualduration] END,        
    TD.[ticketsummary] = CASE WHEN RTRIM(LTRIM(t1.[ticket summary]))!= '' AND RTRIM(LTRIM(t1.[ticket summary])) IS NOT NULL   THEN  T1.[ticket summary] ELSE TD.[ticketsummary] END,        
    TD.[natureoftheticket] = ISNULL(T1.[NatureOfTheTicketID], TD.[natureoftheticket]),        
    TD.[comments] = ISNULL(T1.[comments],  TD.[comments]),        
    TD.[repeatedincident] = ISNULL(T1.[repeated incident],   TD.[repeatedincident]),        
    TD.[relatedtickets] = ISNULL(T1.[related tickets], TD.[relatedtickets]),        
    TD.[ticketcreatedby] = ISNULL(T1.[ticket created by],   TD.[ticketcreatedby] ),        
    TD.[secondaryresources] = ISNULL(T1.[sec assignee],  TD.[secondaryresources]),        
    TD.[escalatedflagcustomer] = ISNULL(T1.[escalatedflagcustomerid],TD.[escalatedflagcustomer] ),         
    TD.[reasonforrejection] = ISNULL(T1.[reason for rejection], TD.[reasonforrejection] ),         
    TD.[avoidableflag] = ISNULL(T1.[avoidableflagid],   TD.[avoidableflag] ),        
    TD.[releasedate] = ISNULL(T1.[release date],   TD.[releasedate]),      
    --TD.[ticketcreatedate] = T1.[ticketcreatedate],         
    TD.[plannedstartdate] = ISNULL(T1.[planned start date and time],  TD.[plannedstartdate]),        
    TD.[plannedenddate] = ISNULL(T1.[planned end date],  TD.[plannedenddate]),        
    TD.[actualstartdatetime] = ISNULL(T1.[actual start date time], TD.[actualstartdatetime]),        
    TD.[actualenddatetime] = ISNULL(T1.[actual end date time], TD.[actualenddatetime]),         
    TD.[opendatetime] = ISNULL(T1.[open date],   TD.[opendatetime] ),        
    TD.[starteddatetime] = ISNULL(T1.[started date time],    TD.[starteddatetime]),        
    TD.[wipdatetime] = ISNULL(T1.[wip date time],  TD.[wipdatetime]),        
    TD.[onholddatetime] = ISNULL(T1.[on hold date time],  TD.[onholddatetime]),        
    TD.[completeddatetime] = ISNULL(T1.[completed date time], TD.[completeddatetime]),        
    TD.[reopendatetime] = ISNULL(T1.[reopen date],  TD.[reopendatetime] ),        
    TD.[cancelleddatetime] = ISNULL(T1.[cancelled date time],  TD.[cancelleddatetime]),        
    TD.[rejecteddatetime] = ISNULL(T1.[rejected time stamp], TD.[rejecteddatetime]),        
    TD.[closeddate] = ISNULL(T1.[close date], TD.[closeddate]),        
    TD.[assigneddatetime] = ISNULL(T1.[assigned time stamp], TD.[assigneddatetime]),         
    TD.[outageduration] =CASE WHEN CONVERT(decimal(25,2),T1.[outage duration]) >0.0 AND CONVERT(decimal(25,2),T1.[outage duration]) IS NOT NULL THEN CONVERT(decimal(25,2),T1.[outage duration]) ELSE TD.[outageduration] END,         
    TD.[metresponseslamapid] = ISNULL(T1.[met response sla],  TD.[metresponseslamapid]),        
    TD.[metacknowledgementslamapid] = ISNULL(T1.[met acknowledgement sla],  TD.[metacknowledgementslamapid]),        
    TD.[metresolutionmapid] = ISNULL(T1.[met resolution],  TD.[metresolutionmapid]),        
    --TD.[EscalationSLA]= ,         
    --TD.[TKBusinessID] =,         
    --TD.[InscopeOutscope] =,         
    --TD.[IsAttributeUpdated]= ,         
    TD.[newstatusdatetime] = ISNULL(T1.[new status date time],TD.[newstatusdatetime] ),         
    --TD.[IsSDTicket]= ,         
    --TD.[IsManual]= ,         
    TD.[dartstatusid] = ISNULL(T1.[dartstatusid],TD.[dartstatusid] ),         
 TD.[resolutionremarks] = CASE WHEN  T1.[Resolution Method] IS NOT NULL AND T1.[Resolution Method] != '' THEN T1.[Resolution Method] ELSE TD.[resolutionremarks] END ,        
   -- TD.[resolutionremarks] = T1.[resolutiondetails] CONVERT(DECIMAL(25,2), T1.[itsm effort]),    TD.[itsmeffort] ,         
    TD.[itsmeffort] = CASE WHEN t1.[ITSM Effort] is NOT NULL and T1.[ITSM Effort] !='0.00' THEN T1.[ITSM Effort] ELSE  TD.[itsmeffort] END,          
    TD.[LastUpdatedDate] =GETDATE(),         
    TD.[modifiedby] = @CogID,         
    TD.[modifieddate] = Getdate(),         
    --TD.[IsApproved]= ,         
    --TD.[ReasonResidualMapID]= ,         
    TD.[ExpectedCompletionDate]=ISNULL(T1.[Expected Completion Date] ,  TD.[ExpectedCompletionDate]),        
    TD.[approvedby] = ISNULL(T1.[approved by] ,  TD.[approvedby] ),        
    TD.[FlexField1] = ISNULL(T1.[Flex Field (1)],TD.[FlexField1] ),        
 TD.[FlexField2] = ISNULL(T1.[Flex Field (2)],TD.[FlexField2] ),        
 TD.[FlexField3] = ISNULL(T1.[Flex Field (3)],TD.[FlexField3]),         
 TD.[FlexField4] = ISNULL(T1.[Flex Field (4)],TD.[FlexField4] ),        
 TD.[Category] = ISNULL(T1.[Category],TD.[Category] ),        
 TD.[Type] = ISNULL(T1.[Type],TD.[Type]),        
 TD.AssignmentGroupID = ISNULL(T1.[Assignment Group ID],TD.AssignmentGroupID),        
 TD.AssignmentGroup = ISNULL(T1.[Assignment Group],TD.AssignmentGroup),        
 TD.LastModifiedSource = ISNULL(@TicketSource,TD.LastModifiedSource),        
 TD.SupportType = ISNULL(T1.SupportType,TD.SupportType),        
 TD.[IsPartiallyAutomated] =IsNull(T1.IsPartiallyAutomated,ISNULL(TD.[IsPartiallyAutomated],2))        
        
    WHEN NOT matched THEN         
      INSERT ([ticketid],         
              [applicationid],         
              [projectid],         
              [assignedto],         
              [efforttilldate],         
     [serviceid],         
              [ticketdescription],         
              [isdeleted],         
              [causecodemapid],         
              [debtclassificationmapid],         
         [residualdebtmapid],         
              [resolutioncodemapid],         
              [resolutionmethodmapid],         
              [kedbavailableindicatormapid],         
              [kedbupdatedmapid],         
              [kedbpath],         
              [prioritymapid],         
              [releasetypemapid],         
              [severitymapid],         
              [ticketsourcemapid],         
              [ticketstatusmapid],         
              [tickettypemapid],         
              [businesssourcename],         
              [onsite_offshore],         
              [plannedeffort],         
              [estimatedworksize],         
              [actualeffort],         
              [actualworksize],         
              [resolvedby],        
              [closedby],         
              [elevateflaginternal],         
              [rcaid],         
         [plannedduration],         
              [actualduration],         
              [ticketsummary],         
              [natureoftheticket],         
              [comments],         
              [repeatedincident],         
              [relatedtickets],         
              [ticketcreatedby],         
              [secondaryresources],         
           [escalatedflagcustomer],         
              [reasonforrejection],         
     [avoidableflag],         
              [releasedate],         
              [ticketcreatedate],         
              [plannedstartdate],         
              [plannedenddate],         
              [actualstartdatetime],         
              [actualenddatetime],         
              [opendatetime],         
              [starteddatetime],         
              [wipdatetime],         
              [onholddatetime],         
              [completeddatetime],         
             [reopendatetime],         
              [cancelleddatetime],         
      [rejecteddatetime],         
              [closeddate],         
              [assigneddatetime],         
              [outageduration],         
              [metresponseslamapid],         
              [metacknowledgementslamapid],         
              [metresolutionmapid],         
              [escalationsla],         
              [tkbusinessid],         
              [inscopeoutscope],         
              [isattributeupdated],         
              [newstatusdatetime],         
              [issdticket],         
              [ismanual],         
              [dartstatusid],         
              [resolutionremarks],         
              [itsmeffort],         
              [createdby],         
 [createddate],         
              [lastupdateddate],         
     [modifiedby],         
     [modifieddate],         
              [isapproved],         
              [reasonresidualmapid],         
              [expectedcompletiondate],         
              [approvedby],        
      [FlexField1],        
     [FlexField2],        
     [FlexField3],        
     [FlexField4],        
     [Category],        
     [Type],        
     [AssignmentGroupID],        
     LastModifiedSource,        
     SupportType,        
     InitiatedSource,        
     TowerID,        
     IsPartiallyAutomated,        
     [AssignmentGroup]        
     )         
      VALUES (RTRIM(LTRIM(T1.[ticket id])),         
              ISNULL(T1.[applicationid],0),         
              T1.[projectid],         
              T1.UserID,         
              0,         
              Isnull(T1.[serviceid], ''),         
              Isnull(T1.[ticket description], ''),         
              0,         
              T1.[causecodeid],         
              T1.[debtclassificationid],         
              T1.[residualdebtid],         
              T1.[resolutionid],         
              NULL,         
              T1.[kedbavailableindicatorid],         
              T1.[kedbupdatedid],         
              T1.[kedb path],         
              T1.[priorityid],         
              T1.[releasetypeid],         
            T1.[severityid],         
              T1.[sourceid],         
              T1.[statusid],         
              T1.[tickettypeid],         
              T1.[source department],         
              NULL,         
              T1.[planned effort],         
              T1.[estimated work size],         
              '0',         
              T1.[actual work size],         
              T1.[resolved by],         
              Null, --Closedby         
              T1.[elevate flag internal],         
              T1.[rca id],         
        T1.[planned duration],         
              T1.[actual duration],         
              T1.[ticket summary],         
              T1.[natureoftheticketid],         
            T1.[comments],         
              T1.[repeated incident],         
              T1.[related tickets],         
              T1.[ticket created by],         
              T1.[sec assignee],         
              T1.[escalatedflagcustomerid],         
              T1.[reason for rejection],         
              T1.[avoidableflagid],         
              T1.[release date],         
              GETDATE(),         
              T1.[planned start date and time],         
            T1.[planned end date],         
              T1.[actual start date time],        
              T1.[actual end date time],         
              T1.[open date],         
              T1.[started date time],         
              T1.[wip date time],         
              T1.[on hold date time],         
              T1.[completed date time],         
              T1.[reopen date],         
              T1.[cancelled date time],         
              T1.[rejected time stamp],         
         T1.[close date],         
              T1.[assigned time stamp],         
              CONVERT(DECIMAL(25,2), T1.[outage duration]),         
              T1.[met response sla],         
              T1.[met acknowledgement sla],         
              T1.[met resolution],         
              0,--'EscalationSLA',         
              0,--'TKBusinessID',         
              Null, --'InscopeOutscope',         
              0,--'IsAttributeUpdated',         
              T1.[new status date time],         
              0,--'IsSDTicket',         
              0,--'IsManual',         
              T1.[dartstatusid],         
              IIF( T1.[Resolution Method]='',NULL, T1.[Resolution Method]),         
              Convert(Decimal(25,2),T1.[itsm effort]),         
 @CogID,                 Getdate(),         
              Getdate(),         
              NULL,         
              NULL,         
              0,         
              NULL,         
              T1.[Expected Completion Date],         
              T1.[approved by],        
     T1.[Flex Field (1)],        
     T1.[Flex Field (2)],        
     T1.[Flex Field (3)],        
     T1.[Flex Field (4)],        
     T1.[Category],        
     T1.[Type],        
     T1.[Assignment Group ID],        
     T1.LastModifiedSource,        
     T1.SupportType,        
     @TicketSource,       
     T1.TowerID,        
     ISNULL( T1.IsPartiallyAutomated,2),        
     T1.[Assignment Group]        
     );         
        
Update [AVL].[TK_TRN_BOTTicketDetail] set IsAttributeUpdated='0' where (DARTStatusID='8' or DARTStatusID='9')        
and (Closeddate is null or DebtClassificationMapID is null or CauseCodeMapID is null or ResolutionCodeMapID is null) and projectid=@ProjectID        
        
    /**************************GRACE PERIOD UNDO UPDATE For Infra Tickets***********************/        
     UPDATE #ImportTicketDumpDetails_Infra        
       SET        
     [tickettypeid]= TD.[tickettypemapid],        
     [ServiceID]=TD.ServiceID,        
     [dartstatusid] = TD.[dartstatusid],        
   [statusid]=TD.[TicketStatusMapID],        
        [TowerID]=TD.TowerID,        
  [causecodeid]= TD.[causecodemapid],        
  [resolutionid]=TD.[resolutioncodemapid],        
        [debtclassificationid]=TD.[debtclassificationmapid],        
        [residualdebtid]=TD.[residualdebtmapid],        
  [avoidableflagid]= TD.[avoidableflag],        
  IsPartiallyAutomated=TD.IsPartiallyAutomated,        
   [Open Date]=TD.OpenDateTime,        
         [Flex Field (1)]=(CASE  WHEN @FlexField1 =1 AND (Debt.OptionalAttributeType=1 OR Debt.OptionalAttributeType=3)  THEN TD.[FlexField1]  ELSE [Flex Field (1)] END),        
  [Flex Field (2)]=(CASE  WHEN @FlexField2 =1 AND (Debt.OptionalAttributeType=1 OR Debt.OptionalAttributeType=3)  THEN TD.[FlexField2]  ELSE [Flex Field (2)] END),        
  [Flex Field (3)]=(CASE  WHEN @FlexField3 =1 AND (Debt.OptionalAttributeType=1 OR Debt.OptionalAttributeType=3)  THEN TD.[FlexField3]  ELSE [Flex Field (3)] END),        
  [Flex Field (4)]=(CASE  WHEN @FlexField4 =1 AND (Debt.OptionalAttributeType=1 OR Debt.OptionalAttributeType=3)  THEN TD.[FlexField4]  ELSE [Flex Field (4)] END),        
  [Ticket Description]=(CASE WHEN (Debt.OptionalAttributeType=2 OR Debt.OptionalAttributeType=3) THEN TD.TicketDescription ELSE [Ticket Description] END),        
  [Resolution Remarks]=(CASE WHEN (Debt.OptionalAttributeType=2 OR Debt.OptionalAttributeType=3) AND @ResolutionRemarksInfra=1 THEN TD.ResolutionRemarks ELSE [Resolution Remarks] END),        
  [Resolution Method]=(CASE WHEN  (Debt.OptionalAttributeType=2 OR Debt.OptionalAttributeType=3) AND @ResolutionRemarksInfra=1 THEN TD.ResolutionRemarks ELSE [Resolution Method] END)        
       FROM #ImportTicketDumpDetails_Infra(NOLOCK) T INNER JOIN [AVL].[TK_TRN_InfraTicketDetail](NOLOCK) TD        
       ON T.[Ticket ID] = TD.TicketID  AND TD.ProjectID  = @ProjectID AND TD.IsDeleted<>1        
      LEFT JOIN [AVL].MAS_ProjectDebtDetails (NOLOCK) AS Debt ON Debt.ProjectID=T.ProjectID AND Debt.IsDeleted<>1        
       WHERE T.ProjectID=@ProjectID AND  T.IsGracePeriodMet=1 and TD.DARTStatusID in(8,9)        
  --  AND (TD.CauseCodeMapID IS NOT NULL OR TD.ResolutionCodeMapID IS NOT NULL OR TD.AvoidableFlag IS NOT NULL        
  --  OR TD.ResidualDebtMapID IS NOT NULL OR TD.DebtClassificationMapID IS NOT NULL)        
        
        
UPDATE #ImportTicketDumpDetails_Infra   SET         
  [statusid]=PS.[StatusID]        
  From #ImportTicketDumpDetails_Infra T inner join AVL.TK_MAP_ProjectStatusMapping (NOLOCK) PS        
  on T.DARTStatusId=PS.TicketStatus_ID and T.ProjectID=PS.ProjectID        
   WHERE T.ProjectID=@ProjectID AND  T.IsGracePeriodMet=1        
        
  /*************************************************************************/        
   INSERT INTO #RegexInfraTicketDetail([TicketID],ProjectID,TicketDescription,ResolutionRemarks,TicketSummary,Comments,SupportType)        
  SELECT [Ticket ID],ProjectID,[Ticket Description],[Resolution Remarks],[Ticket Summary],Comments,SupportType from #ImportTicketDumpDetails_Infra WITH(NOLOCK)        
        
 MERGE [AVL].[TK_TRN_InfraTicketDetail] TD         
    using #ImportTicketDumpDetails_Infra T1         
    ON t1.[Ticket ID] = TD.[ticketid]         
       AND t1.[ProjectID] = TD.[projectid]         
    WHEN matched THEN         
      UPDATE SET TD.TowerID = ISNULL(T1.[TowerID],TD.[TowerID]) ,        
                 TD.[assignedto] = ISNULL(T1.UserID, TD.[assignedto] ),        
                 TD.[ticketdescription] =CASE WHEN RTRIM(LTRIM(t1.[ticket description]))!= '' AND RTRIM(LTRIM(t1.[ticket description])) IS NOT NULL THEN  T1.[ticket description] ELSE TD.[ticketdescription] END,        
                 TD.[IsDeleted] = ISNULL(T1.IsDeleted,  0),         
                 TD.[causecodemapid] = ISNULL(T1.[causecodeid],  TD.[causecodemapid]),        
                 TD.[debtclassificationmapid] = ISNULL(T1.[debtclassificationid], TD.[debtclassificationmapid]),        
                 TD.[residualdebtmapid] = ISNULL(T1.[residualdebtid], TD.[residualdebtmapid]),        
                 TD.[resolutioncodemapid] = ISNULL(T1.[resolutionid],   TD.[resolutioncodemapid]),        
    --TD.[ResolutionMethodMapID]= ,         
    TD.[kedbavailableindicatormapid] = ISNULL(T1.[kedbavailableindicatorid],TD.[kedbavailableindicatormapid]),         
    TD.[kedbupdatedmapid] = ISNULL(T1.[kedbupdatedid], TD.[kedbupdatedmapid]),        
    TD.[kedbpath] = ISNULL(T1.[kedb path],  TD.[kedbpath]),        
 TD.[prioritymapid] = ISNULL(T1.[priorityid],  TD.[prioritymapid]),        
    TD.[releasetypemapid] = ISNULL(T1.[releasetypeid], TD.[releasetypemapid]),        
    TD.[severitymapid] = ISNULL(T1.[severityid],  TD.[severitymapid]),        
    TD.[ticketsourcemapid] = ISNULL(T1.[sourceid], TD.[ticketsourcemapid]),        
    TD.[ticketstatusmapid] = ISNULL(T1.[statusid],  TD.[ticketstatusmapid]),        
    TD.[tickettypemapid] = ISNULL(T1.[tickettypeid], TD.[tickettypemapid]),        
    TD.[businesssourcename] = ISNULL(T1.[source department], TD.[businesssourcename]),        
    --TD.[Onsite_Offshore]= ,         
    TD.[plannedeffort] =  CASE WHEN t1.[planned effort]> 0.0 AND  T1.[planned effort] IS NOT NULL THEN  T1.[planned effort] ELSE  TD.[plannedeffort] END,        
    TD.[estimatedworksize] = CASE WHEN t1.[estimated work size]> 0.0 AND  T1.[estimated work size] IS NOT NULL THEN    T1.[estimated work size] ELSE TD.[estimatedworksize] END,        
    --TD.[ActualEffort]= ISNULL(T1.[actual work size], TD.[actualworksize]),,         
    TD.[actualworksize] = CASE WHEN T1.[actual work size] is NOT NULL and T1.[actual work size] !='0.00' THEN T1.[actual work size] ELSE  TD.[actualworksize] END,        
    TD.[resolvedby] = ISNULL(T1.[resolved by],  TD.[resolvedby]),        
    --TD.[Closedby]= ,         
    TD.[elevateflaginternal] = ISNULL(T1.[elevate flag internal], TD.[elevateflaginternal]),        
TD.[rcaid] = ISNULL(T1.[rca id],TD.[rcaid]),         
    TD.[plannedduration] =CASE WHEN t1.[planned duration]> 0.0 AND  T1.[planned duration] IS NOT NULL THEN   T1.[planned duration] ELSE  TD.[plannedduration] END,        
    TD.[actualduration] = CASE WHEN t1.[actual duration]> 0.0 AND  T1.[actual duration] IS NOT NULL THEN   T1.[actual duration] ELSE TD.[actualduration] END,        
    TD.[ticketsummary] = CASE WHEN RTRIM(LTRIM(t1.[ticket summary]))!= '' AND RTRIM(LTRIM(t1.[ticket summary])) IS NOT NULL   THEN  T1.[ticket summary] ELSE TD.[ticketsummary] END,        
    TD.[natureoftheticket] = ISNULL(T1.[NatureOfTheTicketID], TD.[natureoftheticket]),        
    TD.[comments] = ISNULL(T1.[comments],  TD.[comments]),        
    TD.[repeatedincident] = ISNULL(T1.[repeated incident],   TD.[repeatedincident]),        
    TD.[relatedtickets] = ISNULL(T1.[related tickets], TD.[relatedtickets]),        
    TD.[ticketcreatedby] = ISNULL(T1.[ticket created by],   TD.[ticketcreatedby] ),        
    TD.[secondaryresources] = ISNULL(T1.[sec assignee],  TD.[secondaryresources]),        
    TD.[escalatedflagcustomer] = ISNULL(T1.[escalatedflagcustomerid],TD.[escalatedflagcustomer] ),         
    TD.[reasonforrejection] = ISNULL(T1.[reason for rejection], TD.[reasonforrejection] ),         
    TD.[avoidableflag] = ISNULL(T1.[avoidableflagid],   TD.[avoidableflag] ),     
    TD.[releasedate] = ISNULL(T1.[release date],   TD.[releasedate]),        
    --TD.[ticketcreatedate] = T1.[ticketcreatedate],         
    TD.[plannedstartdate] = ISNULL(T1.[planned start date and time],  TD.[plannedstartdate]),        
    TD.[plannedenddate] = ISNULL(T1.[planned end date],  TD.[plannedenddate]),        
    TD.[actualstartdatetime] = ISNULL(T1.[actual start date time], TD.[actualstartdatetime]),        
    TD.[actualenddatetime] = ISNULL(T1.[actual end date time], TD.[actualenddatetime]),         
    TD.[opendatetime] = ISNULL(T1.[open date],   TD.[opendatetime] ),        
    TD.[starteddatetime] = ISNULL(T1.[started date time],    TD.[starteddatetime]),        
    TD.[wipdatetime] = ISNULL(T1.[wip date time],  TD.[wipdatetime]),        
    TD.[onholddatetime] = ISNULL(T1.[on hold date time],  TD.[onholddatetime]),        
    TD.[completeddatetime] = ISNULL(T1.[completed date time], TD.[completeddatetime]),        
    TD.[reopendatetime] = ISNULL(T1.[reopen date],  TD.[reopendatetime] ),        
    TD.[cancelleddatetime] = ISNULL(T1.[cancelled date time],  TD.[cancelleddatetime]),        
    TD.[rejecteddatetime] = ISNULL(T1.[rejected time stamp], TD.[rejecteddatetime]),        
    TD.[closeddate] = ISNULL(T1.[close date], TD.[closeddate]),        
    TD.[assigneddatetime] = ISNULL(T1.[assigned time stamp], TD.[assigneddatetime]),         
    TD.[outageduration] =CASE WHEN CONVERT(decimal(25,2),T1.[outage duration]) >0.0 AND CONVERT(decimal(25,2),T1.[outage duration]) IS NOT NULL THEN CONVERT(decimal(25,2),T1.[outage duration]) ELSE TD.[outageduration] END,         
    TD.[metresponseslamapid] = ISNULL(T1.[met response sla],  TD.[metresponseslamapid]),        
    TD.[metacknowledgementslamapid] = ISNULL(T1.[met acknowledgement sla],  TD.[metacknowledgementslamapid]),        
    TD.[metresolutionmapid] = ISNULL(T1.[met resolution],  TD.[metresolutionmapid]),        
    --TD.[EscalationSLA]= ,         
    --TD.[TKBusinessID] =,         
    --TD.[InscopeOutscope] =,         
    --TD.[IsAttributeUpdated]= ,         
    TD.[newstatusdatetime] = ISNULL(T1.[new status date time],TD.[newstatusdatetime] ),         
    --TD.[IsSDTicket]= ,         
    --TD.[IsManual]= ,         
    TD.[dartstatusid] = ISNULL(T1.[dartstatusid],TD.[dartstatusid] ),         
 TD.[resolutionremarks] = CASE WHEN  T1.[Resolution Method] IS NOT NULL AND T1.[Resolution Method] != '' THEN T1.[Resolution Method] ELSE TD.[resolutionremarks] END ,        
  -- TD.[resolutionremarks] = T1.[resolutiondetails] CONVERT(DECIMAL(25,2), T1.[itsm effort]),    TD.[itsmeffort] ,         
    TD.[itsmeffort] = CASE WHEN t1.[ITSM Effort] is NOT NULL and T1.[ITSM Effort] !='0.00' THEN T1.[ITSM Effort] ELSE  TD.[itsmeffort] END,          
    TD.[LastUpdatedDate] =GETDATE(),         
    TD.[modifiedby] = @CogID,         
    TD.[modifieddate] = Getdate(),         
    --TD.[IsApproved]= ,         
    --TD.[ReasonResidualMapID]= ,         
    TD.[ExpectedCompletionDate]=ISNULL(T1.[Expected Completion Date] ,  TD.[ExpectedCompletionDate]),        
    TD.[approvedby] = ISNULL(T1.[approved by] ,  TD.[approvedby] ),        
    TD.[FlexField1] = ISNULL(T1.[Flex Field (1)],TD.[FlexField1] ),        
 TD.[FlexField2] = ISNULL(T1.[Flex Field (2)],TD.[FlexField2] ),        
 TD.[FlexField3] = ISNULL(T1.[Flex Field (3)],TD.[FlexField3]),         
 TD.[FlexField4] = ISNULL(T1.[Flex Field (4)],TD.[FlexField4] ),        
 TD.[Category] = ISNULL(T1.[Category],TD.[Category] ),        
 TD.[Type] = ISNULL(T1.[Type],TD.[Type]),        
 TD.AssignmentGroupID = ISNULL(T1.[Assignment Group ID],TD.AssignmentGroupID),        
 TD.AssignmentGroup = ISNULL(T1.[Assignment Group],TD.AssignmentGroup),        
 TD.LastModifiedSource = ISNULL(@TicketSource,TD.LastModifiedSource),        
 TD.[IsPartiallyAutomated] =IsNull(T1.IsPartiallyAutomated,ISNULL(TD.[IsPartiallyAutomated],2))        
        
    WHEN NOT matched THEN         
      INSERT ([ticketid],         
              TowerID,         
         [projectid],         
              [assignedto],         
              [efforttilldate],         
              [serviceid],         
              [ticketdescription],         
              [isdeleted],         
              [causecodemapid],         
              [debtclassificationmapid],         
              [residualdebtmapid],         
              [resolutioncodemapid],         
              [resolutionmethodmapid],         
              [kedbavailableindicatormapid],         
              [kedbupdatedmapid],         
              [kedbpath],         
              [prioritymapid],         
              [releasetypemapid],         
              [severitymapid],         
              [ticketsourcemapid],         
              [ticketstatusmapid],         
              [tickettypemapid],         
              [businesssourcename],         
              [onsite_offshore],         
              [plannedeffort],         
              [estimatedworksize],         
              [actualeffort],         
              [actualworksize],         
              [resolvedby],         
              [closedby],         
              [elevateflaginternal],         
              [rcaid],         
         [plannedduration],         
              [actualduration],         
              [ticketsummary],         
              [natureoftheticket],         
              [comments],         
              [repeatedincident],         
              [relatedtickets],         
              [ticketcreatedby],         
              [secondaryresources],         
              [escalatedflagcustomer],         
              [reasonforrejection],         
     [avoidableflag],         
              [releasedate],         
              [ticketcreatedate],         
              [plannedstartdate],         
              [plannedenddate],         
            [actualstartdatetime],         
              [actualenddatetime],         
              [opendatetime],         
              [starteddatetime],         
              [wipdatetime],         
              [onholddatetime],         
              [completeddatetime],         
              [reopendatetime],         
              [cancelleddatetime],         
     [rejecteddatetime],         
              [closeddate],         
              [assigneddatetime],         
              [outageduration],         
              [metresponseslamapid],         
              [metacknowledgementslamapid],         
              [metresolutionmapid],         
              [escalationsla],         
              [tkbusinessid],         
              [inscopeoutscope],         
              [isattributeupdated],         
              [newstatusdatetime],         
              [issdticket],         
              [ismanual],         
              [dartstatusid],         
              [resolutionremarks],         
              [itsmeffort],         
              [createdby],         
              [createddate],         
              [lastupdateddate],         
              [modifiedby],         
              [modifieddate],         
  [isapproved],         
[reasonresidualmapid],         
              [expectedcompletiondate],         
              [approvedby],        
      [FlexField1],        
     [FlexField2],        
     [FlexField3],        
     [FlexField4],        
     [Category],        
     [Type],        
     [AssignmentGroupID],        
     InitiatedSource,        
     IsPartiallyAutomated,        
     AssignmentGroup        
     )         
      VALUES (T1.[ticket id],         
              T1.TowerId,         
              T1.[projectid],         
              T1.UserID,         
              0,         
           Isnull(T1.[serviceid], ''),         
              Isnull(T1.[ticket description], ''),         
              0,         
              T1.[causecodeid],         
              T1.[debtclassificationid],         
              T1.[residualdebtid],         
              T1.[resolutionid],         
  NULL,         
              T1.[kedbavailableindicatorid],         
              T1.[kedbupdatedid],         
              T1.[kedb path],         
              T1.[priorityid],         
              T1.[releasetypeid],         
              T1.[severityid],         
              T1.[sourceid],         
              T1.[statusid],         
              T1.[tickettypeid],         
              T1.[source department],         
              NULL,         
              T1.[planned effort],         
           T1.[estimated work size],         
              '0',         
              T1.[actual work size],         
              T1.[resolved by],         
              Null, --Closedby         
              T1.[elevate flag internal],         
              T1.[rca id],         
              T1.[planned duration],         
              T1.[actual duration],         
              T1.[ticket summary],         
              T1.[natureoftheticketid],         
              T1.[comments],         
              T1.[repeated incident],         
              T1.[related tickets],         
              T1.[ticket created by],         
              T1.[sec assignee],         
              T1.[escalatedflagcustomerid],         
              T1.[reason for rejection],         
              T1.[avoidableflagid],         
              T1.[release date],         
              GETDATE(),         
              T1.[planned start date and time],         
              T1.[planned end date],         
              T1.[actual start date time],        
              T1.[actual end date time],         
              T1.[open date],         
       T1.[started date time],         
              T1.[wip date time],         
              T1.[on hold date time],         
              T1.[completed date time],         
              T1.[reopen date],         
              T1.[cancelled date time],         
              T1.[rejected time stamp],         
         T1.[close date],         
              T1.[assigned time stamp],         
              CONVERT(DECIMAL(25,2), T1.[outage duration]),         
              T1.[met response sla],         
              T1.[met acknowledgement sla],         
              T1.[met resolution],         
              0,--'EscalationSLA',         
              0,--'TKBusinessID',         
              Null, --'InscopeOutscope',         
        0,--'IsAttributeUpdated',         
              T1.[new status date time],         
              0,--'IsSDTicket',         
              0,--'IsManual',         
              T1.[dartstatusid],         
              IIF( T1.[Resolution Method]='',NULL, T1.[Resolution Method]),         
              Convert(Decimal(25,2),T1.[itsm effort]),         
              @CogID,         
              Getdate(),         
              Getdate(),         
              NULL,         
              NULL,         
              0,         
              NULL,         
 T1.[Expected Completion Date],         
              T1.[approved by],        
     T1.[Flex Field (1)],        
     T1.[Flex Field (2)],        
     T1.[Flex Field (3)],        
     T1.[Flex Field (4)],        
     T1.[Category],        
     T1.[Type],        
     T1.[Assignment Group ID],        
     @TicketSource,        
     ISNULL( T1.IsPartiallyAutomated,2),        
     T1.[Assignment Group]        
     );         
        
        
Update  [AVL].[TK_TRN_InfraTicketDetail]  set IsAttributeUpdated='0' where (DARTStatusID='8' or DARTStatusID='9')        
and (Closeddate is null or DebtClassificationMapID is null or CauseCodeMapID is null or ResolutionCodeMapID is null)         
and projectid=@ProjectID            
 --ErrorData to c# code.Result set 1        
 SELECT [Ticket ID],Remarks        
 +ISNULL([RemarksForGracePeriod],'') AS Remarks FROM #ImportTicketDumpDetails_Nullvalue WITH(NOLOCK)        
        
 --Result set 2         
 DECLARE @count int ,@metOnlyGracePeriodCount INT        
 set @count = (select count([Ticket ID]) from #ImportTicketDumpDetails_Nullvalue WITH(NOLOCK) WHERE IsGracePeriodMet<>1)        
        
 SELECT @metOnlyGracePeriodCount= count([Ticket ID]) from #ImportTicketDumpDetails_Nullvalue WITH(NOLOCK) WHERE         
         ISNULL(Remarks,'')='' AND ISNULL([RemarksForGracePeriod],'')!=''        
        
 if(@count > 0)        
 BEGIN        
  select '1' AS Result        
 END        
 ELSE IF (@count=0 AND @metOnlyGracePeriodCount>0)        
 BEGIN        
  select '2' AS Result        
 END        
 ELSE        
 BEGIN        
   select '0' AS Result        
 END        
         
 --REsult set 3        
 SELECT AT.TimeTickerID,AT.[TicketID],AT.ProjectID,AT.TicketDescription,AT.ResolutionRemarks,AT.TicketSummary,AT.Comments,RT.SupportType From #RegexTicketDetail RT WITH(NOLOCK)        
 INNER JOIN AVL.TK_TRN_TicketDetail AT WITH (NOLOCK)  ON RT.ProjectID=AT.ProjectID and RT.TicketID=AT.TicketID        
        
 SELECT  AT.TimeTickerID,AT.[TicketID],AT.ProjectID,AT.TicketDescription,AT.ResolutionRemarks,AT.TicketSummary,AT.Comments,RT.SupportType FROM #RegexInfraTicketDetail RT WITH(NOLOCK)        
 INNER JOIN AVL.TK_TRN_InfraTicketDetail AT WITH (NOLOCK)  ON RT.ProjectID=AT.ProjectID and RT.TicketID=AT.TicketID        
         
        
 INSERT into [AVL].[ServiceAutoClassification_TicketUpload]([Ticket ID],ProjectID)        
 SELECT [Ticket ID],ITDD.ProjectID FROM #ImportTicketDumpDetails ITDD WITH(NOLOCK)         
  JOIN AVL.TK_TRN_TicketDetail TD WITH(NOLOCK)         
  ON ITDD.ProjectID = TD.ProjectID        
  AND ITDD.[Ticket ID] = TD.TicketID        
  AND TD.IsDeleted = 0         
  JOIN AVL.TK_MAP_TicketTypeMapping TTM WITH(NOLOCK)         
  ON TD.TicketTypeMapID = TTM.TicketTypeMappingID        
  AND TD.ProjectID = TTM.ProjectID        
  AND TTM.IsDeleted = 0        
  LEFT JOIN AVL.DEBT_MAP_CauseCode CC WITH(NOLOCK)         
  ON TD.CauseCodeMapID = CC.CauseID        
  AND TD.ProjectID = CC.ProjectID        
  AND CC.IsDeleted = 0        
  LEFT JOIN AVL.DEBT_MAP_ResolutionCode RC WITH(NOLOCK)         
  ON TD.ResolutionCodeMapID = RC.ResolutionID        
  AND TD.ProjectID = RC.ProjectID        
  AND RC.IsDeleted = 0        
  WHERE  TTM.TicketType !='A' AND TTM.TicketType !='H'and TTM.TicketType !='K' AND ITDD.SupportType = 1 AND        
  ISNULL(TD.ServiceID,0) = 0 AND        
  (ISNULL(TD.TicketDescription,'') != ''         
  OR (IsNULL(CC.CauseStatusID,0)!= 0 AND ISNULL(RC.ResolutionStatusID,0)!=0))        
        
   --25-04-2022          
  DECLARE @AppAlgorithmKey nvarchar(6);          
  DECLARE @InfraAlgorithmKey nvarchar(6);          
  IF((SELECT Count(AlgorithmKey) FROM [ML].[TRN_MLTransaction] WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0) > 0 )        
  BEGIN         
  IF EXISTS(SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction] WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1)        
  BEGIN        
  SET @AppAlgorithmKey = (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction] WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1)        
  END      
  ELSE    
  BEGIN    
  SET @AppAlgorithmKey ='AL002'    
  END      
  IF EXISTS(SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction] WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2)        
  BEGIN        
  SET @InfraAlgorithmKey = (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction] WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2)        
  END    
  ELSE    
  BEGIN    
  SET @InfraAlgorithmKey ='AL002'    
  END       
  END        
  ELSE        
  BEGIN        
  SET @AppAlgorithmKey ='AL002'        
  SET @InfraAlgorithmKey='AL002'        
  END                
        
          
 IF(@AppAlgorithmKey='AL001' OR @InfraAlgorithmKey='AL001')          
 BEGIN          
        
 DECLARE @AutoClassificationType tinyint;        
    DECLARE @AutoClassificationMode bit;        
 DECLARE @SupportType int;        
        
 set @SupportType =(SELECT TOP 1 SupportType FROM #ImportTicketDumpDetails (NOLOCK) WHERE PROJECTID=@ProjectID)        
 IF (@SupportType IS NULL)        
 BEGIN          
  set @SupportType =(SELECT TOP 1 SupportType FROM #ImportTicketDumpDetails_Infra (NOLOCK) WHERE PROJECTID=@ProjectID)        
 END        
          
 IF (@SupportType=1 AND @AppAlgorithmKey='AL001')         
 BEGIN         
        
  set @AutoClassificationType = (SELECT TOP 1 DebtAttributeId FROM [ML].[ConfigurationProgress] (NOLOCK)        
         WHERE PROJECTID=@ProjectID         
         and IsDeleted=0        
         ORDER BY ID ASC)        
  set @AutoClassificationMode = (SELECT TOP 1 IsTicketDescriptionOpted FROM [ML].[ConfigurationProgress] (NOLOCK)        
          WHERE PROJECTID=@ProjectID         
          and IsDeleted=0        
          ORDER BY ID ASC)        
           
  IF (@AutoClassificationType=1)        
  BEGIN        
   INSERT into AVL.TK_MLClassification_TicketUpload          
   SELECT [Ticket ID],ProjectID,ApplicationID,Application,[Ticket Description],'',CauseCodeID,TicketLocation,          
   ResolutionID,Reviewer,null,null,null,null,null,null,NULL,0,EmployeeID,'',NULL,1,        
   TicketDescriptionBasePattern,        
   TicketDescriptionSubPattern,        
   ResolutionRemarksBasePattern,        
   ResolutionRemarksSubPattern        
   from #ImportTicketDumpDetails WITH(NOLOCK)          
   where CauseCodeID is NOT NULL AND ResolutionID IS NOT NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND          
   DebtClassificationId is NULL and AvoidableFlagID is NULL and ResidualDebtID is NULL          
  END        
  ELSE IF (@AutoClassificationType=2)        
  BEGIN        
   IF(@AutoClassificationMode = 1)        
   BEGIN        
    INSERT into AVL.TK_MLClassification_TicketUpload          
    SELECT [Ticket ID],ProjectID,ApplicationID,Application,[Ticket Description],'',NULL,NULL,          
    NULL,NULL,null,null,null,null,null,null,NULL,0,EmployeeID,'',NULL,1,          
    TicketDescriptionBasePattern,        
    TicketDescriptionSubPattern,        
    ResolutionRemarksBasePattern,        
    ResolutionRemarksSubPattern        
    from #ImportTicketDumpDetails WITH(NOLOCK)          
    where CauseCodeID is NULL AND ResolutionID IS NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND          
    DebtClassificationId is NULL and AvoidableFlagID is NULL and ResidualDebtID is NULL  AND        
    [Ticket Description] IS NOT NULL AND [Ticket Description] <> ''        
   END        
   ELSE IF (@AutoClassificationMode = 0)        
   BEGIN        
    INSERT into AVL.TK_MLClassification_TicketUpload          
    SELECT [Ticket ID],ProjectID,ApplicationID,Application,[Ticket Description],'',NULL,NULL,          
    NULL,NULL,null,null,null,null,null,null,NULL,0,EmployeeID,'',NULL,1,        
    TicketDescriptionBasePattern,        
    TicketDescriptionSubPattern,        
    ResolutionRemarksBasePattern,        
    ResolutionRemarksSubPattern        
    from #ImportTicketDumpDetails  WITH(NOLOCK)         
    where CauseCodeID is NULL AND ResolutionID IS NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND          
    DebtClassificationId is NULL and AvoidableFlagID is NULL and ResidualDebtID is NULL  AND        
    [TicketDescriptionBasePattern] IS NOT NULL AND [TicketDescriptionBasePattern] <> ''        
    AND [TicketDescriptionBasePattern] <> '0'        
   END          
  END        
  END         
        
 --ELSE BEGIN        
 IF(@InfraAlgorithmKey='AL001')         
 BEGIN        
        
  set @AutoClassificationType = (SELECT TOP 1 DebtAttributeId FROM [ML].[InfraConfigurationProgress] (NOLOCK)        
         WHERE PROJECTID=@ProjectID         
         and IsDeleted=0        
         ORDER BY ID ASC)        
  set @AutoClassificationMode = (SELECT TOP 1 IsTicketDescriptionOpted FROM [ML].[InfraConfigurationProgress] (NOLOCK)        
          WHERE PROJECTID=@ProjectID         
          and IsDeleted=0        
          ORDER BY ID ASC)        
  IF (@AutoClassificationType=1)        
  BEGIN        
    INSERT into AVL.TK_MLClassification_TicketUpload          
    SELECT [Ticket ID],ProjectID,ApplicationID,Application,[Ticket Description],'',CauseCodeID,TicketLocation,          
    ResolutionID,Reviewer,null,null,null,null,null,null,NULL,0,EmployeeID,'',TowerID,2,NULL,NULL,NULL,NULL         
    from #ImportTicketDumpDetails_Infra  WITH(NOLOCK)          
   where CauseCodeID is NOT NULL AND ResolutionID IS NOT NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND          
   DebtClassificationId is NULL and AvoidableFlagID is NULL and ResidualDebtID is NULL          
  END        
  ELSE IF (@AutoClassificationType=2)        
  BEGIN        
   IF(@AutoClassificationMode = 1)        
   BEGIN        
    INSERT into AVL.TK_MLClassification_TicketUpload          
    SELECT [Ticket ID],ProjectID,ApplicationID,Application,[Ticket Description],'',CauseCodeID,TicketLocation,          
    ResolutionID,Reviewer,null,null,null,null,null,null,NULL,0,EmployeeID,'',TowerID,2,NULL,NULL,NULL,NULL         
    from #ImportTicketDumpDetails_Infra WITH(NOLOCK)         
    where CauseCodeID is NULL AND ResolutionID IS NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND          
    DebtClassificationId is NULL and AvoidableFlagID is NULL and ResidualDebtID is NULL  AND        
    [Ticket Description] IS NOT NULL AND [Ticket Description] <> ''        
   END        
   ELSE IF (@AutoClassificationMode = 0)        
   BEGIN        
    INSERT into AVL.TK_MLClassification_TicketUpload          
    SELECT [Ticket ID],ProjectID,ApplicationID,Application,[Ticket Description],'',CauseCodeID,TicketLocation,          
    ResolutionID,Reviewer,null,null,null,null,null,null,NULL,0,EmployeeID,'',TowerID,2,NULL,NULL,NULL,NULL         
    from #ImportTicketDumpDetails_Infra WITH(NOLOCK)         
    where CauseCodeID is NULL AND ResolutionID IS NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND          
    DebtClassificationId is NULL and AvoidableFlagID is NULL and ResidualDebtID is NULL          
   END          
  END        
 END        
 END        
        
 INSERT into AVL.TK_MLClassification_TicketUpload          
    SELECT [Ticket ID],ProjectID,ApplicationID,Application,[Ticket Description],'',CauseCodeID,TicketLocation,         
 ResolutionID,Reviewer,null,null,null,null,null,null,NULL,0,EmployeeID,'',NULL,1,        
  TicketDescriptionBasePattern,        
  TicketDescriptionSubPattern,        
  ResolutionRemarksBasePattern,        
  ResolutionRemarksSubPattern        
  from #ImportTicketDumpDetails WITH(NOLOCK)         
  where CauseCodeID is NOT NULL AND ResolutionID IS NOT NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND          
  DebtClassificationId is NULL and AvoidableFlagID is NULL and ResidualDebtID is NULL and [Ticket ID] not in(select [Ticket ID] from AVL.TK_MLClassification_TicketUpload )        
                                                                                       
         
        
    update mlt set MLT.[ISApprover] = td.IsApproved from AVL.TK_MLClassification_TicketUpload AS MLT          
    INNER join AVL.TK_TRN_TicketDetail(NOLOCK) AS TD ON TD.ProjectID = MLT.[ProjectID] and td.TicketID = MLT.[Ticket ID] AND MLT.SupportType = 1        
         
 update mlt set MLT.[ISApprover] = td.IsApproved from AVL.TK_MLClassification_TicketUpload AS MLT          
    INNER join AVL.TK_TRN_InfraTicketDetail(NOLOCK) AS TD ON TD.ProjectID = MLT.[ProjectID] and td.TicketID = MLT.[Ticket ID] AND MLT.SupportType = 2        
        
 --25/04/2022          
--END          
 IF(@AppAlgorithmKey='AL002' OR @InfraAlgorithmKey='AL002')                        
 BEGIN                        
  declare @DDClassifiedDate datetime                        
  declare @IsAutoClassified varchar(2)                        
  declare @IsDDAutoClassified varchar(2)                        
  declare @MLSignOffDate datetime                        
  Select @IsAutoClassified=IsAutoClassified , @MLSignOffDate=MLSignOffDate, @IsDDAutoClassified = IsDDAutoClassified, @DDClassifiedDate =IsDDAutoClassifiedDate                        
     from AVL.MAS_ProjectDebtDetails (NOLOCK) where ProjectID = @ProjectId and IsDeleted = 0                        
 SET @IsDDAutoClassified = CASE WHEN (@DDClassifiedDate<= getdate() AND @IsDDAutoClassified='Y') THEN 'Y' ELSE 'N' END                        
                        
 SET @IsAutoClassified = CASE WHEN (@MLSignOffDate<= getdate() AND @IsAutoClassified='Y') THEN 'Y' ELSE 'N' END                        
 --Batch process insert mode--                        
 IF EXISTS(( SELECT top 1 [Ticket ID] FROM #ImportTicketDumpDetails WHERE (DARTStatusId = 8 OR DARTStatusId = 9) AND DebtClassificationId is NULL and AvoidableFlagID is NULL                 
      and ResidualDebtID is NULL )) AND ( @IsDDAutoClassified<>'N' OR     @IsAutoClassified<>'N' )                  
 OR EXISTS(( SELECT top 1 [Ticket ID] FROM #ImportTicketDumpDetails_Infra WHERE (DARTStatusId = 8 OR DARTStatusId = 9) AND DebtClassificationId is NULL and AvoidableFlagID is                 
                      
NULL and ResidualDebtID is NULL )  ) AND ( @IsDDAutoClassified<>'N' OR     @IsAutoClassified<>'N' )                  
BEGIN                  
INSERT INTO ML.AutoClassificationBatchProcess([ProjectId],[EmployeeID],[IsAutoClassified],[IsDDAutoClassified],[AlgorithmKey],[StatusId],                  
[IsDeleted],[CreatedBy],[CreatedDate])                  
values( @projectid,@CogID,@IsAutoClassified,@IsDDAutoClassified,'AL002',13 ,0,@mode,GETDATE())                  
END                  
         
         
   IF(@IsDDAutoClassified<>'N' OR     @IsAutoClassified<>'N' )            
   BEGIN        
   IF(@AppAlgorithmKey='AL002')        
   BEGIN        
 --tickets for auto Classification insert mode--                    
 INSERT INTO ML.TicketsforAutoClassification                  
([BatchProcessId],[TicketId],[TicketDescription],[AssignmentGroupId],[Category],[CauseCodeMapID],[ResolutionCodeMapID],                  
[AvoidableFlagId],[ResidualFlagId],[DebtClassificationId],[TicketSourceMapID],[TicketTypeMapID],[TicketSummary],[ResolutionRemarks],                  
[Comments],[FlexField1],[FlexField2],[FlexField3],[FlexField4],[KEDBAvailableIndicatorMapID],[RelatedTickets],                  
[ReleaseTypeMapID],[StatusId],[IsDeleted],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[SupportType],[ApplicationId]                  
)                  
SELECT (SELECT max([BatchProcessId]) FROM ML.AutoClassificationBatchProcess WHERE ProjectId=@projectid) ,[Ticket ID],[Ticket Description],[Assignment Group ID],[Category],ISNULL([CauseCodeID],NULL),ISNULL([ResolutionID],NULL),              
ISNULL([AvoidableFlagID],NULL),ISNULL([ResidualDebtID],NULL),                  
ISNULL([DebtClassificationId],NULL),ISNULL([sourceID],NULL),ISNULL([TicketTypeID],NULL),[Ticket Summary],[Resolution Remarks],[Comments],[Flex Field (1)],[Flex Field (2)],                  
[Flex Field (3)],[Flex Field (4)],ISNULL([KEDBAvailableIndicatorID],NULL),[Related Tickets],ISNULL([releaseTypeID],NULL),13,0,@CogID,GETDATE(),[ModifiedBY],[Modified Date Time],1,[ApplicationID]                  
FROM #ImportTicketDumpDetails WHERE (DARTStatusId = 8 OR DARTStatusId = 9) AND DebtClassificationId is NULL and AvoidableFlagID is NULL and ResidualDebtID is NULL        
END                  
  --Infra--         
  IF(@InfraAlgorithmKey='AL002')        
BEGIN        
                   
INSERT INTO ML.TicketsforAutoClassification                  
([BatchProcessId],[TicketId],[TicketDescription],[AssignmentGroupId],[Category],[CauseCodeMapID],[ResolutionCodeMapID],                  
[AvoidableFlagId],[ResidualFlagId],[DebtClassificationId],[TicketSourceMapID],[TicketTypeMapID],[TicketSummary],[ResolutionRemarks],                  
[Comments],[FlexField1],[FlexField2],[FlexField3],[FlexField4],[KEDBAvailableIndicatorMapID],[RelatedTickets],                  
[ReleaseTypeMapID],[StatusId],[IsDeleted],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[SupportType],[TowerId]   
)                  
SELECT (SELECT max([BatchProcessId]) FROM ML.AutoClassificationBatchProcess WHERE ProjectId=@projectid) ,[Ticket ID],[Ticket Description],[Assignment Group ID],[Category],ISNULL([CauseCodeID],NULL),          
  ISNULL([ResolutionID],NULL),ISNULL([AvoidableFlagID],NULL),ISNULL([ResidualDebtID],NULL),                  
  ISNULL([DebtClassificationId],NULL),ISNULL([sourceID],NULL),ISNULL([TicketTypeID],NULL),[Ticket Summary],[Resolution Remarks],[Comments],[Flex Field (1)],[Flex Field (2)],                  
  [Flex Field (3)],[Flex Field (4)],ISNULL([KEDBAvailableIndicatorID],NULL),[Related Tickets],ISNULL([releaseTypeID],NULL),13,0,@CogID,GETDATE(),[ModifiedBY],[Modified Date Time],2,[TowerID]                  
FROM #ImportTicketDumpDetails_Infra WHERE (DARTStatusId = 8 OR DARTStatusId = 9) AND DebtClassificationId is NULL and AvoidableFlagID is NULL and ResidualDebtID is NULL                  
END         
END        
END        
  -----------Debt Classification Mode Insert-----------              
IF(@AppAlgorithmKey='AL002' OR @InfraAlgorithmKey='AL002')              
BEGIN           
--App        
IF(@AppAlgorithmKey='AL002')        
BEGIN        
  SELECT FN.ITSMColumn, FN.TK_TicketDetailColumn  INTO #columntemp                    
  FROM [ML].[TRN_MLTransaction] MT                          
  JOIN [ML].[TRN_TransactionCategorical] MD ON MD.MLTransactionId=MT.TransactionId                           
  JOIN [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=MD.CategoricalFieldId                             
  WHERE ProjectId= @projectid  AND SupportTypeId=1 AND ISNULL(MT.IsActiveTransaction,0)=1                          
  UNION                          
  (SELECT FN.ITSMColumn,FN.TK_TicketDetailColumn FROM [ML].[TRN_MLTransaction] t LEFT join                           
  [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=t.IssueDefinitionId                          
  or FN.FieldMappingId=t.ResolutionProviderId                              
  WHERE t.ProjectId= @projectid and SupportTypeId=1 AND ISNULL(t.IsActiveTransaction,0)=1 )                      
                    
                    
  DECLARE @GetQueryticketdetail NVARCHAR(MAX)                    
  DECLARE @result nvarchar(max)                    
  SET @GetQueryticketdetail=STUFF((SELECT ' ' + ' TD.' + QUOTENAME(TK_TicketDetailColumn) +' IS NOT NULL'+' OR'                      
  from #columntemp (NOLOCK)                    
  FOR XML PATH(''), TYPE                    
  ).value('.', 'NVARCHAR(MAX)')                    
  ,1,0,'')                    
                    
                    
                    
  SET @result='INSERT INTO AVL.TRN_DebtClassificationModeDetails                       
  (                    
   TimeTickerID, SystemDebtclassification, SystemAvoidableFlag, SystemResidualDebtFlag, UserDebtClassificationFlag,                    
   UserAvoidableFlag, UserResidualDebtFlag, DebtClassficationMode, SourceForPattern, CreatedDate, CreatedBy, Isdeleted,                    
   CauseCodeID, ResolutionCodeID                    
  )                      
  SELECT DISTINCT TD.TimeTickerID, PDD.DebtClassificationId, PDD.AvoidableFlagID, PDD.ResidualDebtID,                      
   TD.DebtClassificationMapID, TD.AvoidableFlag, TD.ResidualDebtMapID,                     
   (CASE WHEN PDD.ProjectID IS NOT NULL THEN 3 ELSE 5 END) AS DebtClassficationMode,                     
   (CASE WHEN  '''+@mode+''' = ''SharePath'' THEN 3 ELSE 2 END),                    
   GETDATE(), '''+@CogID+''', 0, TD.CauseCodeMapID, TD.ResolutionCodeMapID                      
  FROM AVL.TK_TRN_TicketDetail (NOLOCK) TD                      
  JOIN #ImportTicketDumpDetails IM                     
   ON IM.[Ticket ID] = TD.TicketID AND IM.ProjectID = TD.ProjectID AND TD.IsDeleted=0                     
  LEFT JOIN AVL.Debt_MAS_ProjectDataDictionary (NOLOCK) PDD                     
   ON IM.ProjectID = PDD.ProjectID AND IM.ApplicationID = PDD.ApplicationID                     
    AND IM.CauseCodeID = PDD.CauseCodeID AND IM.ResolutionID = PDD.ResolutionCodeID                     
    AND IM.DebtClassificationId = PDD.DebtClassificationID AND IM.AvoidableFlagID = PDD.AvoidableFlagID                     
    AND IM.ResidualDebtID = PDD.ResidualDebtID AND PDD.IsDeleted = 0                    
  LEFT JOIN AVL.TRN_DebtClassificationModeDetails DCM                     
   ON  DCM.TimeTickerID = TD.TimeTickerID AND TD.ProjectID = '+CAST(@ProjectID AS VARCHAR)+' AND TD.IsDeleted = 0                      
  WHERE DCM.ID IS NULL AND '+'('+' '+@GetQueryticketdetail + ' )'+ ' '                  
  SET @result=(Select left(@result, len(@result)-4))            
              
   SET @result=@result+')' +' AND IM.DebtClassificationId IS NOT NULL AND IM.AvoidableFlagID IS NOT NULL                  
 AND IM.ResidualDebtID IS NOT NULL AND TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag  IS NOT NULL AND TD.ResidualDebtMapID IS NOT NULL '            
            
  EXEC sp_executesql @result;           
  END        
            
  --Infra        
  IF(@InfraAlgorithmKey='AL002')        
  BEGIN        
  SELECT FN.ITSMColumn, FN.TK_TicketDetailColumn  INTO #columInfratemp                    
  FROM [ML].[TRN_MLTransaction] MT                          
  JOIN [ML].[TRN_TransactionCategorical] MD ON MD.MLTransactionId=MT.TransactionId                           
  JOIN [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=MD.CategoricalFieldId                             
  WHERE ProjectId= @projectid  AND SupportTypeId=2 AND ISNULL(MT.IsActiveTransaction,0)=1                          
  UNION                          
  (SELECT FN.ITSMColumn,FN.TK_TicketDetailColumn FROM [ML].[TRN_MLTransaction] t LEFT join                           
  [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=t.IssueDefinitionId                          
  or FN.FieldMappingId=t.ResolutionProviderId                              
  WHERE t.ProjectId= @projectid and SupportTypeId=2 AND ISNULL(t.IsActiveTransaction,0)=1 )                      
                    
                    
  DECLARE @GetQueryticketdetailInfra NVARCHAR(MAX)                    
  DECLARE @result_Infra nvarchar(max)                    
  SET @GetQueryticketdetailInfra=STUFF((SELECT ' ' + ' TD.' + QUOTENAME(TK_TicketDetailColumn) +' IS NOT NULL'+' OR'                      
  from #columInfratemp (NOLOCK)                    
  FOR XML PATH(''), TYPE        
  ).value('.', 'NVARCHAR(MAX)')                    
  ,1,0,'')                    
                    
                    
                    
  SET @result_Infra='INSERT INTO AVL.TRN_InfraDebtClassificationModeDetails                       
  (                    
   TimeTickerID, SystemDebtclassification, SystemAvoidableFlag, SystemResidualDebtFlag, UserDebtClassificationFlag,                    
   UserAvoidableFlag, UserResidualDebtFlag, DebtClassficationMode, SourceForPattern, CreatedDate, CreatedBy, Isdeleted,                    
   CauseCodeID, ResolutionCodeID                    
  )                      
  SELECT DISTINCT TD.TimeTickerID, PDD.DebtClassificationId, PDD.AvoidableFlagID, PDD.ResidualDebtID,                      
   TD.DebtClassificationMapID, TD.AvoidableFlag, TD.ResidualDebtMapID,                     
   (CASE WHEN PDD.ProjectID IS NOT NULL THEN 3 ELSE 5 END) AS DebtClassficationMode,                     
   (CASE WHEN  '''+@mode+''' = ''SharePath'' THEN 3 ELSE 2 END),                    
   GETDATE(), '''+@CogID+''', 0, TD.CauseCodeMapID, TD.ResolutionCodeMapID                      
  FROM AVL.tk_trn_infraticketdetail (NOLOCK) TD                      
  JOIN #ImportTicketDumpDetails_Infra IM                     
   ON IM.[Ticket ID] = TD.TicketID AND IM.ProjectID = TD.ProjectID AND TD.IsDeleted=0                     
  LEFT JOIN AVL.Debt_MAS_ProjectDataDictionary (NOLOCK) PDD                     
   ON IM.ProjectID = PDD.ProjectID AND IM.ApplicationID = PDD.ApplicationID                     
    AND IM.CauseCodeID = PDD.CauseCodeID AND IM.ResolutionID = PDD.ResolutionCodeID                     
    AND IM.DebtClassificationId = PDD.DebtClassificationID AND IM.AvoidableFlagID = PDD.AvoidableFlagID                     
    AND IM.ResidualDebtID = PDD.ResidualDebtID AND PDD.IsDeleted = 0                    
  LEFT JOIN AVL.TRN_InfraDebtClassificationModeDetails DCM                     
   ON  DCM.TimeTickerID = TD.TimeTickerID AND TD.ProjectID = '+CAST(@ProjectID AS VARCHAR)+' AND TD.IsDeleted = 0                      
  WHERE DCM.ID IS NULL AND '+'('+' '+@GetQueryticketdetailInfra + ' )'+ ' '                  
  SET @result_Infra=(Select left(@result_Infra, len(@result_Infra)-4))            
              
   SET @result_Infra=@result_Infra+')' +' AND IM.DebtClassificationId IS NOT NULL AND IM.AvoidableFlagID IS NOT NULL                  
 AND IM.ResidualDebtID IS NOT NULL AND TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag  IS NOT NULL AND TD.ResidualDebtMapID IS NOT NULL '            
 EXEC sp_executesql @result_Infra;         
 END        
        
  ----App DebtClassification Mode Update                        
 update debt SET                        
                    
 debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID,                        
                    
 debt.UserAvoidableFlag=ticket.AvoidableFlag,                        
               
 debt.UserResidualDebtFlag=ticket.ResidualDebtMapID                     
                             
 ,DebtClassficationMode=case when ((debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag                        
                    
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID) OR (debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag                        
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID))                    
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 1                        
                    
 when ( (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag                        
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID))                    
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 2                     
                     
                     
 when ((debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag                       or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID))                      
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 2                        
                      
                    
 when debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag                        
                    
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID and (debt.DebtClassficationMode=3 or debt.DebtClassficationMode=4) THEN 3                        
                    
 when (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag               
                    
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID) and (debt.DebtClassficationMode=3 or debt.DebtClassficationMode=4) THEN 4                        
                    
  WHEN debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL                      
 AND ticket.DebtClassificationMapID IS  NULL AND ticket.AvoidableFlag IS  NULL  AND ticket.ResidualDebtMapID IS  NULL                      
 THEN NULL                     
                    
 WHEN debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL                      
 AND ticket.DebtClassificationMapID IS NOT NULL AND ticket.AvoidableFlag IS NOT NULL  AND ticket.ResidualDebtMapID IS NOT NULL                      
 THEN 5                       
 END,          
 debt.ModifiedDate=GETDATE(),debt.ModifiedBy=@CogID ,                     
  debt.SourceForPattern=(CASE WHEN @mode='SharePath' THEN 3 ELSE 2 END)                        
 from                         
 AVL.TK_TRN_TicketDetail(NOLOCK) ticket                      
 JOIN #ImportTicketDumpDetails IM WITH(NOLOCK)  ON IM.[Ticket ID]=ticket.TicketID                    
 AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0                    
 JOIN AVL.TRN_DebtClassificationModeDetails debt WITH(NOLOCK)  on                         
 ticket.TimeTickerID=debt.TimeTickerID and ticket.ProjectID=@ProjectID where ticket.IsDeleted=0 AND debt.Isdeleted=0                         
                    
  ---Update as 'Manual'-----------                    
UPDATE DCM                     
SET DCM.DebtClassficationMode=5,dcm.SystemDebtclassification=NULL,DCM.SystemAvoidableFlag=NULL,                      
 DCM.SystemResidualDebtFlag=NULL,DCM.UserDebtClassificationFlag=TD.DebtClassificationMapID,                    
 DCM.UserAvoidableFlag=TD.AvoidableFlag,DCM.UserResidualDebtFlag=TD.ResidualDebtMapID,DCM.CauseCodeID=TD.CauseCodeMapID,                    
 DCM.ResolutionCodeID=TD.ResolutionCodeMapID,DCM.SourceForPattern=(CASE WHEN @mode='SharePath' THEN 3 ELSE 2 END),                    
 DCM.ModifiedDate=GETDATE(),DCM.ModifiedBy=@CogID, DCM.SystemCauseCodeID = NULL, DCM.SystemResolutionCodeID = NULL                     
FROM #ImportTicketDumpDetails IM WITH(NOLOCK)                      
JOIN AVL.TK_TRN_TicketDetail TD WITH(NOLOCK)                     
 ON TD.ProjectID=@ProjectID  AND IM.ProjectID=TD.ProjectID AND TD.TicketID=IM.[Ticket ID]                     
 AND TD.IsDeleted=0 JOIN AVL.Debt_MAS_ProjectDataDictionary PDD ON  PDD.ProjectID=@ProjectID  AND  IM.ApplicationID <> PDD.ApplicationID                    
 AND IM.DebtClassificationId <> PDD.DebtClassificationID                    
 AND IM.AvoidableFlagID <> PDD.AvoidableFlagID AND PDD.IsDeleted=0                    
JOIN AVL.TRN_DebtClassificationModeDetails DCM WITH(NOLOCK)  ON DCM.TimeTickerID=TD.TimeTickerID                     
 AND DCM.Isdeleted=0 AND (((TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL                     
 AND TD.ResidualDebtMapID IS NOT NULL )) OR ((                    
 IM.DebtClassificationId IS NOT NULL AND IM.AvoidableFlagID IS NOT NULL AND IM.ResidualDebtID IS NOT NULL)))                     
 AND PDD.DebtClassificationID IS NOT NULL AND PDD.AvoidableFlagID IS NOT NULL                    
 AND PDD.ResidualDebtID IS NOT NULL                   
 AND DCM.DebtClassficationMode NOT IN (1,2)           
                  
 ----------------------------------      \        
          
          
                    
END                
IF(@AppAlgorithmKey='AL001' OR @InfraAlgorithmKey='AL001')                   
BEGIN                    
INSERT INTO AVL.TRN_DebtClassificationModeDetails                       
(                    
 TimeTickerID, SystemDebtclassification, SystemAvoidableFlag, SystemResidualDebtFlag, UserDebtClassificationFlag,                    
 UserAvoidableFlag, UserResidualDebtFlag, DebtClassficationMode, SourceForPattern, CreatedDate, CreatedBy, Isdeleted,                    
 CauseCodeID, ResolutionCodeID                    
)                      
SELECT DISTINCT TD.TimeTickerID, PDD.DebtClassificationId, PDD.AvoidableFlagID, PDD.ResidualDebtID,                      
 TD.DebtClassificationMapID, TD.AvoidableFlag, TD.ResidualDebtMapID,                     
 (CASE WHEN PDD.ProjectID IS NOT NULL THEN 3 ELSE 5 END) AS DebtClassficationMode,                     
 (CASE WHEN @mode = 'SharePath' THEN 3 ELSE 2 END),                    
 GETDATE(), @CogID, 0, TD.CauseCodeMapID, TD.ResolutionCodeMapID                      
FROM AVL.TK_TRN_TicketDetail (NOLOCK) TD                      
JOIN #ImportTicketDumpDetails IM WITH(NOLOCK)                     
 ON IM.[Ticket ID] = TD.TicketID AND IM.ProjectID = TD.ProjectID AND TD.IsDeleted=0                     
LEFT JOIN AVL.Debt_MAS_ProjectDataDictionary (NOLOCK) PDD                     
 ON IM.ProjectID = PDD.ProjectID AND IM.ApplicationID = PDD.ApplicationID                     
  AND IM.CauseCodeID = PDD.CauseCodeID AND IM.ResolutionID = PDD.ResolutionCodeID                     
  AND IM.DebtClassificationId = PDD.DebtClassificationID AND IM.AvoidableFlagID = PDD.AvoidableFlagID                     
  AND IM.ResidualDebtID = PDD.ResidualDebtID AND PDD.IsDeleted = 0                    
LEFT JOIN AVL.TRN_DebtClassificationModeDetails DCM WITH(NOLOCK)                     
 ON  DCM.TimeTickerID = TD.TimeTickerID AND TD.ProjectID = @ProjectID AND TD.IsDeleted = 0                      
WHERE DCM.ID IS NULL AND IM.CauseCodeID IS NOT NULL AND IM.ResolutionID IS NOT NULL AND IM.CauseCodeID IS NOT NULL                    
 AND IM.ResolutionID IS NOT NULL AND IM.DebtClassificationId IS NOT NULL AND IM.AvoidableFlagID IS NOT NULL                    
 AND IM.ResidualDebtID IS NOT NULL AND TD.CauseCodeMapID IS NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL                      
 AND TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag  IS NOT NULL AND TD.ResidualDebtMapID IS NOT NULL               
           
          
 ----App DebtClassification Mode Update                        
 update debt SET                        
                    
 debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID,                        
                    
 debt.UserAvoidableFlag=ticket.AvoidableFlag,                        
                    
 debt.UserResidualDebtFlag=ticket.ResidualDebtMapID                     
                             
 ,DebtClassficationMode=case when (@AutoClassificationType=1 AND (debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag                        
                    
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID) OR (@AutoClassificationType=2 AND debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag                        
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID AND  debt.SystemCauseCodeID=ticket.CauseCodeMapID and debt.SystemResolutionCodeID=ticket.ResolutionCodeMapID))                    
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 1                        
                    
 when (@AutoClassificationType=1 AND (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag                        
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID) and (debt.CauseCodeID = ticket.CauseCodeMapID and debt.ResolutionCodeID=ticket.ResolutionCodeMapID ))                    
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 2                     
                     
                     
 when(@AutoClassificationType=2 AND (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag                        
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID or debt.SystemCauseCodeID<>ticket.CauseCodeMapID or debt.SystemResolutionCodeID<>ticket.ResolutionCodeMapID))                      
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 2                        
                      
                    
 when debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag                        
                    
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID and (debt.DebtClassficationMode=3 or debt.DebtClassficationMode=4) THEN 3                        
                    
 when (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag                        
                    
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID) and (debt.DebtClassficationMode=3 or debt.DebtClassficationMode=4) THEN 4                                    
  WHEN debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL                      
 AND ticket.DebtClassificationMapID IS  NULL AND ticket.AvoidableFlag IS  NULL  AND ticket.ResidualDebtMapID IS  NULL                      
 THEN NULL                     
                    
 WHEN debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL                      
 AND ticket.DebtClassificationMapID IS NOT NULL AND ticket.AvoidableFlag IS NOT NULL  AND ticket.ResidualDebtMapID IS NOT NULL                      
 THEN 5                       
 END,debt.ModifiedDate=GETDATE(),debt.ModifiedBy=@CogID ,           
  debt.SourceForPattern=(CASE WHEN @mode='SharePath' THEN 3 ELSE 2 END)                        
 from                         
 AVL.TK_TRN_TicketDetail(NOLOCK) ticket                      
 JOIN #ImportTicketDumpDetails IM WITH(NOLOCK)  ON IM.[Ticket ID]=ticket.TicketID                    
 AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0                    
 JOIN AVL.TRN_DebtClassificationModeDetails debt WITH(NOLOCK)  on                         
 ticket.TimeTickerID=debt.TimeTickerID and ticket.ProjectID=@ProjectID where ticket.IsDeleted=0 AND debt.Isdeleted=0                         
                    
  ---Update as 'Manual'-----------                    
UPDATE DCM                     
SET DCM.DebtClassficationMode=5,dcm.SystemDebtclassification=NULL,DCM.SystemAvoidableFlag=NULL,                      
 DCM.SystemResidualDebtFlag=NULL,DCM.UserDebtClassificationFlag=TD.DebtClassificationMapID,                    
 DCM.UserAvoidableFlag=TD.AvoidableFlag,DCM.UserResidualDebtFlag=TD.ResidualDebtMapID,DCM.CauseCodeID=TD.CauseCodeMapID,                    
 DCM.ResolutionCodeID=TD.ResolutionCodeMapID,DCM.SourceForPattern=(CASE WHEN @mode='SharePath' THEN 3 ELSE 2 END),                    
 DCM.ModifiedDate=GETDATE(),DCM.ModifiedBy=@CogID, DCM.SystemCauseCodeID = NULL, DCM.SystemResolutionCodeID = NULL                     
FROM #ImportTicketDumpDetails IM WITH(NOLOCK)                      
JOIN AVL.TK_TRN_TicketDetail TD WITH(NOLOCK)                     
 ON TD.ProjectID=@ProjectID  AND IM.ProjectID=TD.ProjectID AND TD.TicketID=IM.[Ticket ID]                     
 AND TD.IsDeleted=0 JOIN AVL.Debt_MAS_ProjectDataDictionary PDD ON  PDD.ProjectID=@ProjectID  AND  IM.ApplicationID <> PDD.ApplicationID                    
 AND IM.CauseCodeID <> PDD.ResolutionCodeID AND IM.DebtClassificationId <> PDD.DebtClassificationID                    
 AND IM.AvoidableFlagID <> PDD.AvoidableFlagID AND PDD.IsDeleted=0                    
JOIN AVL.TRN_DebtClassificationModeDetails DCM WITH(NOLOCK)  ON DCM.TimeTickerID=TD.TimeTickerID                     
 AND DCM.Isdeleted=0 AND (((TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL                     
 AND TD.ResidualDebtMapID IS NOT NULL )) OR ((                    
 (DCM.CauseCodeID<>TD.CauseCodeMapID OR DCM.ResolutionCodeID<>TD.ResolutionCodeMapID)                     
 AND IM.DebtClassificationId IS NOT NULL AND IM.AvoidableFlagID IS NOT NULL AND IM.ResidualDebtID IS NOT NULL)))                     
 AND TD.CauseCodeMapID IS NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL                     
 AND PDD.CauseCodeID IS NOT NULL AND PDD.ResolutionCodeID IS NOT NULL                    
 AND PDD.DebtClassificationID IS NOT NULL AND PDD.AvoidableFlagID IS NOT NULL                    
 AND PDD.ResidualDebtID IS NOT NULL                     
 AND DCM.DebtClassficationMode NOT IN (1,2)                    
 ----------------------------------              
          
          
END                
-------------END-------------------------            
        
----------Update as DD-----------------        
UPDATE DCM         
SET DCM.DebtClassficationMode=3,dcm.SystemDebtclassification=IM.DebtClassificationId,        
 DCM.SystemAvoidableFlag=IM.AvoidableFlagID,DCM.SystemResidualDebtFlag=IM.ResidualDebtID,        
 DCM.UserDebtClassificationFlag=TD.DebtClassificationMapID,DCM.UserAvoidableFlag=TD.AvoidableFlag,        
 DCM.UserResidualDebtFlag=TD.ResidualDebtMapID,DCM.CauseCodeID=TD.CauseCodeMapID,        
 DCM.ResolutionCodeID=TD.ResolutionCodeMapID,DCM.SourceForPattern=(CASE WHEN @mode='SharePath' THEN 3 ELSE 2 END),        
 DCM.ModifiedDate=GETDATE(),DCM.ModifiedBy=@CogID, DCM.SystemCauseCodeID = NULL, DCM.SystemResolutionCodeID = NULL         
FROM #ImportTicketDumpDetails IM WITH(NOLOCK)         
JOIN AVL.TK_TRN_TicketDetail TD WITH(NOLOCK)  ON  TD.ProjectID=@ProjectID AND IM.ProjectID=TD.ProjectID AND TD.TicketID=IM.[Ticket ID]         
JOIN AVL.Debt_MAS_ProjectDataDictionary PDD WITH(NOLOCK)  ON PDD.ProjectID=@ProjectID AND IM.ApplicationID=PDD.ApplicationID AND IM.CauseCodeID=PDD.CauseCodeID        
 AND IM.ResolutionID=PDD.ResolutionCodeID AND IM.DebtClassificationId=PDD.DebtClassificationID        
 AND IM.AvoidableFlagID=PDD.AvoidableFlagID AND IM.ResidualDebtID=PDD.ResidualDebtID AND PDD.IsDeleted=0        
 AND TD.IsDeleted=0         
JOIN AVL.TRN_DebtClassificationModeDetails DCM WITH(NOLOCK)  ON DCM.TimeTickerID=TD.TimeTickerID         
 AND DCM.Isdeleted=0 AND (((TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL         
 AND TD.ResidualDebtMapID IS NOT NULL ))         
 OR (((DCM.CauseCodeID<>TD.CauseCodeMapID OR DCM.ResolutionCodeID<>TD.ResolutionCodeMapID)         
 AND IM.DebtClassificationId IS NOT NULL         
 AND IM.AvoidableFlagID IS NOT NULL AND IM.ResidualDebtID IS NOT NULL)))         
 AND TD.CauseCodeMapID IS NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL        
 AND PDD.CauseCodeID IS NOT NULL AND PDD.ResolutionCodeID IS NOT NULL        
 AND PDD.DebtClassificationID IS NOT NULL AND PDD.AvoidableFlagID IS NOT NULL        
 AND PDD.ResidualDebtID IS NOT NULL        
 AND DCM.DebtClassficationMode NOT IN (1,2)        
        
 ----new code----        
      
update ticket set             
DebtClassficationMode='5' from        
AVL.TRN_DebtClassificationModeDetails(NOLOCK) ticket where ticket.SystemDebtclassification is not null and ticket.CauseCodeID is not null        
and ticket.ResolutionCodeID is not null and ticket.SystemAvoidableFlag is not null and ticket.SystemResidualDebtFlag is not null        
and ticket.UserDebtClassificationFlag is not null and ticket.UserResidualDebtFlag is not null and ticket.UserAvoidableFlag is not null and ticket.DebtClassficationMode is null        
      
--------------------------------        
        
        
         
 update ticket set             
 ticket.DebtClassificationMode= (case when (@AutoClassificationType=1 and ticket.CauseCodeMapID IS NULL or ticket.ResolutionCodeMapID is NULL) or         
            ((@AutoClassificationType=2 and @AutoClassificationMode = 1 and         
            (ticket.TicketDescription is null or  ticket.TicketDescription = '') and debt.DebtClassficationMode not in(3,4,5)) or        
            (@AutoClassificationType=2 and @AutoClassificationMode = 0 and         
            (ticket.TicketDescriptionBasePattern is null or ticket.TicketDescriptionBasePattern =''        
            or ticket.TicketDescriptionBasePattern = '0') and debt.DebtClassficationMode not in(3,4,5)))         
            then NULL ELSE debt.DebtClassficationMode END ),        
 ticket.LastModifiedSource =@TicketSource        
 from            
 AVL.TRN_DebtClassificationModeDetails(NOLOCK) debt join AVL.TK_TRN_TicketDetail(NOLOCK) ticket on ticket.TimeTickerID=debt.TimeTickerID            
 AND ticket.ProjectID=@ProjectID AND ticket.IsDeleted=0           
 JOIN #ImportTicketDumpDetails IM WITH(NOLOCK)  ON IM.[Ticket ID]=ticket.TicketID AND IM.ProjectID=ticket.ProjectID     
 AND ISNULL(ticket.DebtClassificationMode,0)<>5 --Restrict Override the Manual tickets          
        
        
            
 ---Insert into InfraModeTable----        
  
INSERT INTO AVL.TRN_InfraDebtClassificationModeDetails        
(           
 TimeTickerID, SystemDebtclassification, SystemAvoidableFlag, SystemResidualDebtFlag, UserDebtClassificationFlag,        
 UserAvoidableFlag, UserResidualDebtFlag, DebtClassficationMode, SourceForPattern, CreatedDate, CreatedBy, Isdeleted,        
 CauseCodeID, ResolutionCodeID        
)        
SELECT DISTINCT TD.TimeTickerID, PDD.DebtClassificationId, PDD.AvoidableFlagID, PDD.ResidualDebtID,          
 TD.DebtClassificationMapID, TD.AvoidableFlag, TD.ResidualDebtMapID,         
 (CASE WHEN PDD.ProjectID IS NOT NULL THEN 3 ELSE 5 END) AS DebtClassficationMode,         
 (CASE WHEN @mode = 'SharePath' THEN 3 ELSE 2 END),        
 GETDATE(), @CogID, 0, TD.CauseCodeMapID, TD.ResolutionCodeMapID          
FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD          
JOIN  #ImportTicketDumpDetails_Infra IM WITH(NOLOCK)         
 ON IM.[Ticket ID] = TD.TicketID AND IM.ProjectID = TD.ProjectID AND TD.IsDeleted=0         
LEFT JOIN AVL.Debt_MAS_ProjectDataDictionary (NOLOCK) PDD         
 ON IM.ProjectID = PDD.ProjectID AND IM.ApplicationID = PDD.ApplicationID         
  AND IM.CauseCodeID = PDD.CauseCodeID AND IM.ResolutionID = PDD.ResolutionCodeID         
  AND IM.DebtClassificationId = PDD.DebtClassificationID AND IM.AvoidableFlagID = PDD.AvoidableFlagID         
  AND IM.ResidualDebtID = PDD.ResidualDebtID AND PDD.IsDeleted = 0        
LEFT JOIN AVL.TRN_InfraDebtClassificationModeDetails DCM WITH(NOLOCK)         
 ON  DCM.TimeTickerID = TD.TimeTickerID AND TD.ProjectID = @ProjectID AND TD.IsDeleted = 0          
WHERE DCM.ID IS NULL AND IM.CauseCodeID IS NOT NULL AND IM.ResolutionID IS NOT NULL AND IM.CauseCodeID IS NOT NULL        
  AND IM.ResolutionID IS NOT NULL AND IM.DebtClassificationId IS NOT NULL AND IM.AvoidableFlagID IS NOT NULL        
  AND IM.ResidualDebtID IS NOT NULL AND TD.CauseCodeMapID IS NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL          
  AND TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag  IS NOT NULL AND TD.ResidualDebtMapID IS NOT NULL        
        
        
----Infra DebtClassification Mode Update  ----------          
        
 update debt SET            
        
 debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID,            
        
 debt.UserAvoidableFlag=ticket.AvoidableFlag,            
        
 debt.UserResidualDebtFlag=ticket.ResidualDebtMapID         
                 
 ,DebtClassficationMode=case when (@AutoClassificationType=1 AND debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag            
        
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID) OR (@AutoClassificationType=2 AND debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag            
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID AND  debt.SystemCauseCodeID=ticket.CauseCodeMapID and debt.SystemResolutionCodeID=ticket.ResolutionCodeMapID)        
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 1            
        
 when (@AutoClassificationType=1 AND (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag            
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID) and (debt.CauseCodeID = ticket.CauseCodeMapID and debt.ResolutionCodeID=ticket.ResolutionCodeMapID ))        
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 2         
         
         
 when(@AutoClassificationType=2 AND (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag            
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID or debt.SystemCauseCodeID<>ticket.CauseCodeMapID or debt.SystemResolutionCodeID<>ticket.ResolutionCodeMapID))          
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 2            
          
        
 when debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag            
        
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID and (debt.DebtClassficationMode=3 or debt.DebtClassficationMode=4) THEN 3            
        
 when (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag            
        
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID) and (debt.DebtClassficationMode=3 or debt.DebtClassficationMode=4) THEN 4            
        
  WHEN debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL          
 AND ticket.DebtClassificationMapID IS  NULL AND ticket.AvoidableFlag IS  NULL  AND ticket.ResidualDebtMapID IS  NULL          
 THEN NULL         
        
 WHEN debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL          
 AND ticket.DebtClassificationMapID IS NOT NULL AND ticket.AvoidableFlag IS NOT NULL  AND ticket.ResidualDebtMapID IS NOT NULL          
 THEN 5           
 END,debt.ModifiedDate=GETDATE(),debt.ModifiedBy=@CogID ,         
  debt.SourceForPattern=(CASE WHEN @mode='SharePath' THEN 3 ELSE 2 END)            
 from             
 AVL.TK_TRN_InfraTicketDetail(NOLOCK) ticket          
 JOIN #ImportTicketDumpDetails_Infra IM WITH(NOLOCK)  ON IM.[Ticket ID]=ticket.TicketID        
 AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0        
 JOIN AVL.TRN_InfraDebtClassificationModeDetails debt WITH(NOLOCK)  on             
 ticket.TimeTickerID=debt.TimeTickerID and ticket.ProjectID=@ProjectID where ticket.IsDeleted=0 AND debt.Isdeleted=0             
        
 ---Update as Manual-------------------        
UPDATE DCM         
SET DCM.DebtClassficationMode=5,dcm.SystemDebtclassification=NULL,DCM.SystemAvoidableFlag=NULL,          
 DCM.SystemResidualDebtFlag=NULL,DCM.UserDebtClassificationFlag=TD.DebtClassificationMapID,        
 DCM.UserAvoidableFlag=TD.AvoidableFlag,DCM.UserResidualDebtFlag=TD.ResidualDebtMapID,DCM.CauseCodeID=TD.CauseCodeMapID,        
 DCM.ResolutionCodeID=TD.ResolutionCodeMapID,DCM.SourceForPattern=(CASE WHEN @mode='SharePath' THEN 3 ELSE 2 END),        
 DCM.ModifiedDate=GETDATE(),DCM.ModifiedBy=@CogID , DCM.SystemCauseCodeID = NULL, DCM.SystemResolutionCodeID = NULL        
FROM #ImportTicketDumpDetails_Infra IM WITH(NOLOCK)         
JOIN  AVL.TK_TRN_InfraTicketDetail TD WITH(NOLOCK)           
 ON TD.ProjectID=@ProjectID AND IM.ProjectID=TD.ProjectID AND TD.TicketID=IM.[Ticket ID]         
 AND TD.IsDeleted=0         
JOIN AVL.Debt_MAS_ProjectDataDictionary PDD WITH(NOLOCK)  ON PDD.ProjectID=@ProjectID AND IM.ApplicationID <> PDD.ApplicationID        
 AND IM.CauseCodeID <> PDD.ResolutionCodeID AND IM.DebtClassificationId <> PDD.DebtClassificationID        
 AND IM.AvoidableFlagID <> PDD.AvoidableFlagID AND PDD.IsDeleted=0        
JOIN AVL.TRN_InfraDebtClassificationModeDetails DCM WITH(NOLOCK)  ON DCM.TimeTickerID=TD.TimeTickerID         
 AND DCM.Isdeleted=0 AND (((TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL         
 AND TD.ResidualDebtMapID IS NOT NULL )) OR ((        
 (DCM.CauseCodeID<>TD.CauseCodeMapID OR DCM.ResolutionCodeID<>TD.ResolutionCodeMapID)         
 AND IM.DebtClassificationId IS NOT NULL AND IM.AvoidableFlagID IS NOT NULL AND IM.ResidualDebtID IS NOT NULL)))         
 AND TD.CauseCodeMapID IS NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL         
 AND PDD.CauseCodeID IS NOT NULL AND PDD.ResolutionCodeID IS NOT NULL        
 AND PDD.DebtClassificationID IS NOT NULL AND PDD.AvoidableFlagID IS NOT NULL        
 AND PDD.ResidualDebtID IS NOT NULL         
 AND DCM.DebtClassficationMode NOT IN (1,2)        
-------------------------------        
        
   ---Update as DD -------------------        
        
UPDATE DCM         
SET DCM.DebtClassficationMode=3,dcm.SystemDebtclassification=IM.DebtClassificationId,        
 DCM.SystemAvoidableFlag=IM.AvoidableFlagID,DCM.SystemResidualDebtFlag=IM.ResidualDebtID,        
 DCM.UserDebtClassificationFlag=TD.DebtClassificationMapID,DCM.UserAvoidableFlag=TD.AvoidableFlag,        
 DCM.UserResidualDebtFlag=TD.ResidualDebtMapID,DCM.CauseCodeID=TD.CauseCodeMapID,        
 DCM.ResolutionCodeID=TD.ResolutionCodeMapID,DCM.SourceForPattern=(CASE WHEN @mode='SharePath' THEN 3 ELSE 2 END),        
 DCM.ModifiedDate=GETDATE(),DCM.ModifiedBy=@CogID ,DCM.SystemCauseCodeID = NULL, DCM.SystemResolutionCodeID = NULL         
FROM  #ImportTicketDumpDetails_Infra IM WITH(NOLOCK)         
JOIN AVL.TK_TRN_InfraTicketDetail TD WITH(NOLOCK)  ON TD.ProjectID=@ProjectID AND IM.ProjectID=TD.ProjectID AND TD.TicketID=IM.[Ticket ID]         
JOIN AVL.Debt_MAS_ProjectDataDictionary PDD  WITH(NOLOCK) ON PDD.ProjectID=@ProjectID AND IM.ApplicationID=PDD.ApplicationID AND IM.CauseCodeID=PDD.CauseCodeID        
 AND IM.ResolutionID=PDD.ResolutionCodeID AND IM.DebtClassificationId=PDD.DebtClassificationID        
 AND IM.AvoidableFlagID=PDD.AvoidableFlagID AND IM.ResidualDebtID=PDD.ResidualDebtID AND PDD.IsDeleted=0        
 AND TD.IsDeleted=0 JOIN AVL.TRN_DebtClassificationModeDetails DCM ON DCM.TimeTickerID=TD.TimeTickerID         
 AND DCM.Isdeleted=0 AND (((TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL         
 AND TD.ResidualDebtMapID IS NOT NULL ))         
 OR (((DCM.CauseCodeID<>TD.CauseCodeMapID OR DCM.ResolutionCodeID<>TD.ResolutionCodeMapID)         
 AND IM.DebtClassificationId IS NOT NULL         
 AND IM.AvoidableFlagID IS NOT NULL AND IM.ResidualDebtID IS NOT NULL)))         
 AND TD.CauseCodeMapID IS NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL        
 AND PDD.CauseCodeID IS NOT NULL AND PDD.ResolutionCodeID IS NOT NULL        
 AND PDD.DebtClassificationID IS NOT NULL AND PDD.AvoidableFlagID IS NOT NULL        
 AND PDD.ResidualDebtID IS NOT NULL        
 AND DCM.DebtClassficationMode NOT IN (1,2)        
        
 ----new code----        
        
update ticket set             
 DebtClassficationMode='5' from        
 AVL.TRN_InfraDebtClassificationModeDetails (NOLOCK) ticket where ticket.SystemDebtclassification is not null and ticket.CauseCodeID is not null        
 and ticket.ResolutionCodeID is not null and ticket.SystemAvoidableFlag is not null and ticket.SystemResidualDebtFlag is not null        
 and ticket.UserDebtClassificationFlag is not null and ticket.UserResidualDebtFlag is not null and ticket.UserAvoidableFlag is not null and ticket.DebtClassficationMode is null        
        
   -------------------------        
 update ticket set             
 ticket.DebtClassificationMode= (case when (@AutoClassificationType=1 and ticket.CauseCodeMapID IS NULL or ticket.ResolutionCodeMapID is NULL) or         
            ((@AutoClassificationType=2 and @AutoClassificationMode = 1 and         
            (ticket.TicketDescription is null or  ticket.TicketDescription = '') and debt.DebtClassficationMode not in(3,4,5)) or        
            (@AutoClassificationType=2 and @AutoClassificationMode = 0 and         
             debt.DebtClassficationMode not in(3,4,5)))         
            then NULL ELSE debt.DebtClassficationMode END ),        
 ticket.LastModifiedSource =@TicketSource        
 from            
 AVL.TRN_InfraDebtClassificationModeDetails(NOLOCK) debt join AVL.TK_TRN_InfraTicketDetail(NOLOCK) ticket on ticket.TimeTickerID=debt.TimeTickerID            
 AND ticket.ProjectID=@ProjectID AND ticket.IsDeleted=0           
 JOIN #ImportTicketDumpDetails_Infra IM WITH(NOLOCK)  ON IM.[Ticket ID]=ticket.TicketID AND IM.ProjectID=ticket.ProjectID     
 AND ISNULL(ticket.DebtClassificationMode,0)<>5 --Restrict Override the Manual tickets       
    
  IF(@AppAlgorithmKey = 'AL002' OR @InfraAlgorithmKey='AL002')              
  BEGIN              
  --App--    
  update debt SET                  
              
  debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID,                  
              
  debt.UserAvoidableFlag=ticket.AvoidableFlag,                  
           
  debt.UserResidualDebtFlag=ticket.ResidualDebtMapID               
                       
  ,DebtClassficationMode=case when (debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag                  
  and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID and @MLSignOffDate is not null) THEN 1                  
              
  END               
  from                   
  AVL.TK_TRN_TicketDetail(NOLOCK) ticket                
  JOIN #ImportTicketDumpDetails     IM ON IM.[Ticket ID]=ticket.TicketID              
  AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0              
  JOIN AVL.TRN_DebtClassificationModeDetails debt on                   
  ticket.TimeTickerID=debt.TimeTickerID and ticket.ProjectID=@ProjectID where ticket.IsDeleted=0 AND debt.Isdeleted=0        
        
  --Mode 5       
      
   update debt SET                  
              
  debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID,                  
              
  debt.UserAvoidableFlag=ticket.AvoidableFlag,                  
              
  debt.UserResidualDebtFlag=ticket.ResidualDebtMapID ,              
                       
  debt.ModifiedBy = 'Al002',      
        
  DebtClassficationMode=case when (debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID and debt.UserAvoidableFlag=ticket.AvoidableFlag                  
  and debt.UserResidualDebtFlag=ticket.ResidualDebtMapID) THEN 5                     
         
  END               
  from                   
  AVL.TK_TRN_TicketDetail(NOLOCK) ticket                
  JOIN #ImportTicketDumpDetails     IM ON IM.[Ticket ID]=ticket.TicketID              
  AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0              
  JOIN AVL.TRN_DebtClassificationModeDetails debt on                   
  ticket.TimeTickerID=debt.TimeTickerID and ticket.ProjectID=@ProjectID where ticket.IsDeleted=0 AND debt.Isdeleted=0       
  and debt.UserDebtClassificationFlag is not null and debt.UserAvoidableFlag is not null and debt.UserResidualDebtFlag is not null and       
  ticket.DebtClassificationMapID is not null and ticket.AvoidableFlag is not null and ticket.ResidualDebtMapID is not null       
  and ticket.DebtClassificationMode is null      
      
  update ticket SET                  
        
  DebtClassificationMode=case when (debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID and debt.UserAvoidableFlag=ticket.AvoidableFlag                  
  and debt.UserResidualDebtFlag=ticket.ResidualDebtMapID) THEN 5                     
         
  END               
  from                   
  AVL.TK_TRN_TicketDetail(NOLOCK) ticket                
  JOIN #ImportTicketDumpDetails     IM ON IM.[Ticket ID]=ticket.TicketID              
  AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0              
  JOIN AVL.TRN_DebtClassificationModeDetails debt on                   
  ticket.TimeTickerID=debt.TimeTickerID and ticket.ProjectID=@ProjectID where ticket.IsDeleted=0 AND debt.Isdeleted=0       
  and debt.UserDebtClassificationFlag is not null and debt.UserAvoidableFlag is not null and debt.UserResidualDebtFlag is not null and       
  ticket.DebtClassificationMapID is not null and ticket.AvoidableFlag is not null and ticket.ResidualDebtMapID is not null       
  and ticket.DebtClassificationMode is null      
  --Infra--    
  update debt SET                    
     
  debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID,                    
                
  debt.UserAvoidableFlag=ticket.AvoidableFlag,                    
                
  debt.UserResidualDebtFlag=ticket.ResidualDebtMapID                 
                         
  ,DebtClassficationMode=case when (debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag                    
  and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID) THEN 1                    
                
  END                 
  from                       AVL.TK_TRN_InfraTicketDetail(NOLOCK) ticket                  
  JOIN #ImportTicketDumpDetails_Infra IM ON IM.[Ticket ID]=ticket.TicketID                
  AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0                
  JOIN AVL.TRN_InfraDebtClassificationModeDetails debt on                     
  ticket.TimeTickerID=debt.TimeTickerID and ticket.ProjectID=@ProjectID where ticket.IsDeleted=0 AND debt.Isdeleted=0          
          
  --Mode 5         
        
   update debt SET                    
                
  debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID,                    
                
  debt.UserAvoidableFlag=ticket.AvoidableFlag,                    
                
  debt.UserResidualDebtFlag=ticket.ResidualDebtMapID ,                
                         
  debt.ModifiedBy = 'Al002',        
          
  DebtClassficationMode=case when (debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID and debt.UserAvoidableFlag=ticket.AvoidableFlag                    
  and debt.UserResidualDebtFlag=ticket.ResidualDebtMapID) THEN 5                       
           
  END                 
  from                     
  AVL.TK_TRN_InfraTicketDetail(NOLOCK) ticket                  
  JOIN #ImportTicketDumpDetails_Infra IM ON IM.[Ticket ID]=ticket.TicketID                
  AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0                
  JOIN AVL.TRN_InfraDebtClassificationModeDetails debt on                     
  ticket.TimeTickerID=debt.TimeTickerID and ticket.ProjectID=@ProjectID where ticket.IsDeleted=0 AND debt.Isdeleted=0         
  and debt.UserDebtClassificationFlag is not null and debt.UserAvoidableFlag is not null and debt.UserResidualDebtFlag is not null and         
  ticket.DebtClassificationMapID is not null and ticket.AvoidableFlag is not null and ticket.ResidualDebtMapID is not null         
  and ticket.DebtClassificationMode is null        
        
  update ticket SET                    
          
  DebtClassificationMode=case when (debt.UserDebtClassificationFlag=ticket.DebtClassificationMapID and debt.UserAvoidableFlag=ticket.AvoidableFlag                    
  and debt.UserResidualDebtFlag=ticket.ResidualDebtMapID) THEN 5                       
           
  END                 
  from                     
  AVL.TK_TRN_InfraTicketDetail(NOLOCK) ticket                  
  JOIN #ImportTicketDumpDetails_Infra IM ON IM.[Ticket ID]=ticket.TicketID                
  AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0                
  JOIN AVL.TRN_InfraDebtClassificationModeDetails debt on                     
  ticket.TimeTickerID=debt.TimeTickerID and ticket.ProjectID=@ProjectID where ticket.IsDeleted=0 AND debt.Isdeleted=0         
  and debt.UserDebtClassificationFlag is not null and debt.UserAvoidableFlag is not null and debt.UserResidualDebtFlag is not null and         
  ticket.DebtClassificationMapID is not null and ticket.AvoidableFlag is not null and ticket.ResidualDebtMapID is not null         
  and ticket.DebtClassificationMode is null        
  --App - without Transaction update    
  IF((SELECT Count(AlgorithmKey) FROM [ML].[TRN_MLTransaction] WHERE ProjectId = @ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1) = 0 )        
  BEGIN      
   update ticket SET                  
        
   DebtClassificationMode=case when (IM.DebtClassificationId=ticket.DebtClassificationMapID and IM.AvoidableFlagID=ticket.AvoidableFlag                  
   and IM.ResidualDebtID=ticket.ResidualDebtMapID) THEN 5         
         
   END               
   from                   
   AVL.TK_TRN_TicketDetail(NOLOCK) ticket                
   JOIN #ImportTicketDumpDetails IM ON IM.[Ticket ID]=ticket.TicketID              
   AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0              
   AND ticket.DebtClassificationMapID is not null and ticket.AvoidableFlag is not null and ticket.ResidualDebtMapID is not null       
   AND IM.DebtClassificationId is not null and IM.AvoidableFlagID is not null and IM.ResidualDebtID is not null      
   and ticket.DebtClassificationMode is null      
  END       
      
  --Infra - without Transaction update    
     IF((SELECT Count(AlgorithmKey) FROM [ML].[TRN_MLTransaction] WHERE ProjectId = @ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2) = 0 )          
  BEGIN        
   update ticket SET                    
          
   DebtClassificationMode=case when (IM.DebtClassificationId=ticket.DebtClassificationMapID and IM.AvoidableFlagID=ticket.AvoidableFlag                    
   and IM.ResidualDebtID=ticket.ResidualDebtMapID) THEN 5                       
           
   END                 
   from                     
   AVL.TK_TRN_InfraTicketDetail(NOLOCK) ticket                  
   JOIN #ImportTicketDumpDetails_Infra IM ON IM.[Ticket ID]=ticket.TicketID                
   AND IM.ProjectID=ticket.ProjectID and ticket.IsDeleted=0                
   AND ticket.DebtClassificationMapID is not null and ticket.AvoidableFlag is not null and ticket.ResidualDebtMapID is not null         
   AND IM.DebtClassificationId is not null and IM.AvoidableFlagID is not null and IM.ResidualDebtID is not null        
   and ticket.DebtClassificationMode is null        
  END      
       
 END        
    
        
        
        
 SELECT ProjectID, [Ticket ID], MAX(ID) AS DuplicateRecordMaxID         
 INTO #tmpdup         
 FROM #ImportTicketDumpDetails_NullValue (NOLOCK)        
 GROUP BY [Ticket ID], ProjectID        
 HAVING ProjectID = @projectid        
        
        
        
 -- Updating Error Log Correction table        
 UPDATE T         
  SET         
  T.[Ticket Type] = S.[Ticket Type],        
  T.[TicketTypeID] = S.TicketTypeID,        
  T.[Assignee] = S.Assignee,        
  T.[Modified Date Time] = S.[Modified Date Time],        
  T.[Open Date] = S.[Open Date],        
  T.[Priority] = S.[Priority],        
  T.[PriorityID] = S.PriorityID,        
  T.[ResolutionID] = S.ResolutionID,        
  T.[Resolution Code] = S.[Resolution Code],        
  T.[Status] = S.[Status],        
  T.[StatusID] = S.StatusID,        
  T.[Ticket Description] = S.[Ticket Description],        
  T.[IsManual] = S.IsManual,        
  T.[ModifiedBY] = S.ModifiedBY,        
  T.[Application] = S.[Application],        
  T.[ApplicationID] = S.ApplicationID,        
  T.[EmployeeID] = S.EmployeeID,        
  T.[EmployeeName] = S.EmployeeName,        
  T.[External Login ID] = S.[External Login ID],        
  T.[IsDeleted] = S.IsDeleted,        
  T.[Severity] = S.Severity,         
  T.[severityID] = S.severityID,         
  T.[DebtClassificationId] = S.DebtClassificationId,        
  T.[Debt Classification] = S.[Debt Classification],        
  T.[AvoidableFlagID] = S.AvoidableFlagID,        
  T.[Avoidable Flag] = S.[Avoidable Flag],        
  T.[Residual Debt] = S.[Residual Debt],        
  T.[ResidualDebtID] = S.ResidualDebtID,        
  T.[Cause code] = S.[Cause code],        
  T.[CauseCodeID] = S.CauseCodeID,        
  T.SupportTypeID = S.SupportType,        
  T.TowerID = S.Tower,        
  T.TowerName = S.TowerName,        
  T.[Assignment Group ID] = S.[Assignment Group ID],        
  T.[Assignment Group] = S.[Assignment Group] ,        
  T.[IsPartiallyAutomated]=ISNULL(S.IsPartiallyAutomated,2)        
 FROM AVL.ErrorLogCorrectionTickets  T WITH(NOLOCK)         
 JOIN #ImportTicketDumpDetails_NullValue (NOLOCK) S         
  ON s.ProjectID = @projectid AND s.ProjectID = t.ProjectID AND s.[Ticket ID] = t.[Ticket ID] and ISNULL(s.IsBOT,0) = 0         
        
PRINT 'Multilingual BEFORE MERGE'        
 /*****************************Multilingual******************************/        
IF(@isMultiLingual=1)        
BEGIN        
        
PRINT 'Multilingual 2'        
--SELECT 'ML';        
        
        
        
        
UPDATE ITD SET ITD.TimeTickerID=TD.TimeTickerID        
FROM #MultilingualTbl2 ITD WITH(NOLOCK)  JOIN AVL.TK_TRN_TicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[Ticket ID]         
AND TD.ProjectID=@projectid AND TD.IsDeleted=0;      
        
UPDATE ITD SET ITD.TimeTickerID=TD.TimeTickerID        
FROM #MultilingualTblInfra ITD WITH(NOLOCK)  JOIN AVL.TK_TRN_InfraTicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[Ticket ID]         
AND TD.ProjectID=@projectid AND TD.IsDeleted=0;        
        
        
--SELECT '/*BEFORE DELETE*/';        
--SELECT * FROM #MultilingualTbl2;        
--DELETE FROM #MultilingualTbl2 WHERE TimeTickerID IS NULL;        
        
--SELECT * FROM #MultilingualTbl2;        
        
MERGE [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails] AS TARGET        
USING #MultilingualTbl2 AS SOURCE        
ON (Target.TimeTickerID=SOURCE.TimeTickerID)        
WHEN MATCHED          
THEN         
UPDATE SET TARGET.IsTicketDescriptionUpdated=(CASE WHEN SOURCE.IsTicketDescriptionModified=1 THEN 1 ELSE TARGET.IsTicketDescriptionUpdated END),        
TARGET.IsTicketSummaryUpdated=(CASE WHEN SOURCE.IsTicketSummaryModified=1 THEN 1 ELSE TARGET.IsTicketSummaryUpdated END),        
TARGET.IsResolutionRemarksUpdated=(CASE WHEN SOURCE.IsResolutionRemarksModified=1 THEN 1 ELSE TARGET.IsResolutionRemarksUpdated END),        
TARGET.IsCommentsUpdated=(CASE WHEN SOURCE.IsCommentsModified=1 THEN 1 ELSE TARGET.IsCommentsUpdated END),        
TARGET.IsFlexField1Updated=(CASE WHEN SOURCE.IsFlexField1Modified=1 THEN 1 ELSE TARGET.IsFlexField1Updated END),        
TARGET.IsFlexField2Updated=(CASE WHEN SOURCE.IsFlexField2Modified=1 THEN 1 ELSE TARGET.IsFlexField2Updated END),        
TARGET.IsFlexField3Updated=(CASE WHEN SOURCE.IsFlexField3Modified=1 THEN 1 ELSE TARGET.IsFlexField3Updated END),        
TARGET.IsFlexField4Updated=(CASE WHEN SOURCE.IsFlexField4Modified=1 THEN 1 ELSE TARGET.IsFlexField4Updated END),        
TARGET.IsCategoryUpdated=(CASE WHEN SOURCE.IsCategoryModified=1 THEN 1 ELSE TARGET.IsCategoryUpdated END),        
TARGET.IsTypeUpdated=(CASE WHEN SOURCE.IsTypeModified=1 THEN 1 ELSE TARGET.IsTypeUpdated END),        
TARGET.ModifiedBy=@CogID,        
TARGET.ModifiedDate=GETDATE(),        
TARGET.TicketCreatedType=1        
WHEN NOT MATCHED BY TARGET         
THEN         
INSERT (TimeTickerID,IsTicketDescriptionUpdated,IsResolutionRemarksUpdated,IsTicketSummaryUpdated,        
IsCommentsUpdated,IsFlexField1Updated,IsFlexField2Updated,IsFlexField3Updated,IsFlexField4Updated,        
IsCategoryUpdated,IsTypeUpdated,Isdeleted,CreatedBy,CreatedDate,TicketCreatedType )         
VALUES (SOURCE.TimeTickerID,SOURCE.IsTicketDescriptionModified,SOURCE.IsResolutionRemarksModified,        
SOURCE.IsTicketSummaryModified,SOURCE.IsCommentsModified,SOURCE.IsFlexField1Modified,        
SOURCE.IsFlexField2Modified,SOURCE.IsFlexField3Modified,SOURCE.IsFlexField4Modified,        
SOURCE.IsCategoryModified,SOURCE.IsTypeModified,0,@CogID,GETDATE(),1);        
        
MERGE [AVL].[TK_TRN_Multilingual_TranslatedInfraTicketDetails] AS TARGET        
USING #MultilingualTblInfra AS SOURCE        
ON (Target.TimeTickerID=SOURCE.TimeTickerID)        
WHEN MATCHED          
THEN         
UPDATE SET TARGET.IsTicketDescriptionUpdated=(CASE WHEN SOURCE.IsTicketDescriptionModified=1 THEN 1 ELSE TARGET.IsTicketDescriptionUpdated END),        
TARGET.IsTicketSummaryUpdated=(CASE WHEN SOURCE.IsTicketSummaryModified=1 THEN 1 ELSE TARGET.IsTicketSummaryUpdated END),        
TARGET.IsResolutionRemarksUpdated=(CASE WHEN SOURCE.IsResolutionRemarksModified=1 THEN 1 ELSE TARGET.IsResolutionRemarksUpdated END),        
TARGET.IsCommentsUpdated=(CASE WHEN SOURCE.IsCommentsModified=1 THEN 1 ELSE TARGET.IsCommentsUpdated END),        
TARGET.IsFlexField1Updated=(CASE WHEN SOURCE.IsFlexField1Modified=1 THEN 1 ELSE TARGET.IsFlexField1Updated END),        
TARGET.IsFlexField2Updated=(CASE WHEN SOURCE.IsFlexField2Modified=1 THEN 1 ELSE TARGET.IsFlexField2Updated END),        
TARGET.IsFlexField3Updated=(CASE WHEN SOURCE.IsFlexField3Modified=1 THEN 1 ELSE TARGET.IsFlexField3Updated END),        
TARGET.IsFlexField4Updated=(CASE WHEN SOURCE.IsFlexField4Modified=1 THEN 1 ELSE TARGET.IsFlexField4Updated END),        
TARGET.IsCategoryUpdated=(CASE WHEN SOURCE.IsCategoryModified=1 THEN 1 ELSE TARGET.IsCategoryUpdated END),        
TARGET.IsTypeUpdated=(CASE WHEN SOURCE.IsTypeModified=1 THEN 1 ELSE TARGET.IsTypeUpdated END),        
TARGET.ModifiedBy=@CogID,        
TARGET.ModifiedDate=GETDATE(),        
TARGET.TicketCreatedType=1        
WHEN NOT MATCHED BY TARGET         
THEN         
INSERT (TimeTickerID,IsTicketDescriptionUpdated,IsResolutionRemarksUpdated,IsTicketSummaryUpdated,        
IsCommentsUpdated,IsFlexField1Updated,IsFlexField2Updated,IsFlexField3Updated,IsFlexField4Updated,        
IsCategoryUpdated,IsTypeUpdated,Isdeleted,CreatedBy,CreatedDate,TicketCreatedType )         
VALUES (SOURCE.TimeTickerID,SOURCE.IsTicketDescriptionModified,SOURCE.IsResolutionRemarksModified,        
SOURCE.IsTicketSummaryModified,SOURCE.IsCommentsModified,SOURCE.IsFlexField1Modified,        
SOURCE.IsFlexField2Modified,SOURCE.IsFlexField3Modified,SOURCE.IsFlexField4Modified,        
SOURCE.IsCategoryModified,SOURCE.IsTypeModified,0,@CogID,GETDATE(),1);        
        
        
END        
--SELECT * from [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails]        
        
        
 /**********************************************************************/        
        
 --Inserting into Error Log Correction table        
  INSERT INTO AVL.ErrorLogCorrectionTickets        
 (        
  [Ticket ID],        
  [Ticket Type],        
  [TicketTypeID],        
  [Assignee],        
  [Modified Date Time],        
  [Open Date],        
  [Priority],        
  [PriorityID],        
  [ResolutionID],        
  [Resolution Code],        
  [Status],        
  [StatusID],        
  [Ticket Description],        
  [IsManual],        
  [ModifiedBY],        
  [Application],        
  [ApplicationID],        
  [EmployeeID],        
  [EmployeeName],        
  [External Login ID],        
  [ProjectID],        
  [IsDeleted],        
  [Severity],         
  [severityID],         
  [DebtClassificationId],        
  [Debt Classification],        
  [AvoidableFlagID],        
  [Avoidable Flag],        
  [Residual Debt],        
  [ResidualDebtID],        
  [Cause code],        
  [CauseCodeID],        
  SupportTypeID,        
     TowerID ,        
  TowerName,        
  [Assignment Group ID],        
  [Assignment Group],        
  IsPartiallyAutomated        
 )        
 SELECT         
  S.[Ticket ID],        
  S.[Ticket Type],        
  S.[TicketTypeID],        
  S.[Assignee],        
  S.[Modified Date Time],        
  S.[Open Date],        
  S.[Priority],        
  S.[PriorityID],        
  S.[ResolutionID],        
  S.[Resolution Code],        
  S.[Status],        
  S.[StatusID],        
  S.[Ticket Description],        
  S.[IsManual],        
  S.[ModifiedBY],        
  S.[Application],        
  S.[ApplicationID],        
  S.[EmployeeID],        
  S.[EmployeeName],        
  S.[External Login ID],        
  S.[ProjectID],        
  S.[IsDeleted],        
  S.[Severity],         
  S.[severityID],         
  S.[DebtClassificationId],        
  S.[Debt Classification],        
  S.[AvoidableFlagID],        
  S.[Avoidable Flag],        
  S.[Residual Debt],        
  S.[ResidualDebtID],        
  S.[Cause code],        
  S.[CauseCodeID],        
  S.SupportType,        
  S.Tower,        
  S.TowerName,        
  S.[Assignment Group ID],        
  S.[Assignment Group] ,        
  ISNULL(S.IsPartiallyAutomated,2)        
 FROM #ImportTicketDumpDetails_NullValue (NOLOCK) S        
 JOIN #tmpdup Temp1 WITH(NOLOCK)         
  ON Temp1.ProjectId = S.ProjectID AND Temp1.[Ticket ID] = S.[Ticket ID] AND Temp1.DuplicateRecordMaxID = S.ID        
 LEFT JOIN AVL.ErrorLogCorrectionTickets (NOLOCK) T         
  ON S.[Ticket ID] = T.[Ticket ID] AND S.ProjectID = T.ProjectID        
 WHERE S.ProjectID = @projectid AND T.ID IS NULL and ISNULL(s.IsBOT,0) = 0 AND S.IsGracePeriodMet<>1        
        
        
 -- Dropping temp table        
 DROP table #tmpdup        
        
 -- Deleting from errorlog table comparing with ticketdetail table        
 DELETE FROM AVL.ErrorLogCorrectionTickets        
 WHERE EXISTS (        
     SELECT TicketID        
    FROM AVL.TK_TRN_TicketDetail (NOLOCK)        
     WHERE AVL.TK_TRN_TicketDetail.[TicketID] = AVL.ErrorLogCorrectionTickets.[Ticket ID]        
      AND AVL.TK_TRN_TicketDetail.ProjectID = AVL.ErrorLogCorrectionTickets.ProjectID         
      AND AVL.ErrorLogCorrectionTickets.SupportTypeID = 1         
     )         
        
 -- Deleting from errorlog table comparing with InfraTicketDetail table        
 DELETE FROM AVL.ErrorLogCorrectionTickets        
 WHERE EXISTS (        
     SELECT TicketID        
     FROM AVL.TK_TRN_InfraTicketDetail (NOLOCK)        
     WHERE AVL.TK_TRN_InfraTicketDetail.[TicketID] = AVL.ErrorLogCorrectionTickets.[Ticket ID]        
      AND AVL.TK_TRN_InfraTicketDetail.ProjectID = AVL.ErrorLogCorrectionTickets.ProjectID         
      AND AVL.ErrorLogCorrectionTickets.SupportTypeID = 2         
     )        
        
 INSERT into AVL.TK_TRN_IsAttributeUpdated        
 select td.TimeTickerID,ITD.ProjectID,ITD.[Ticket ID],@mode,0,0,@CogID,GETDATE(),NULL,NULL from #ImportTicketDumpDetails(NOLOCK) ITD        
 INNER join AVL.TK_TRN_TicketDetail(NOLOCK)  TD ON ITD.[Ticket ID] = td.TicketID and ITD.ProjectID = TD.ProjectID        
        
 INSERT into [AVL].[TK_TRN_InfraIsAttributeUpdated]        
 select td.TimeTickerID,ITD.ProjectID,ITD.[Ticket ID],@mode,0,0,@CogID,GETDATE(),NULL,NULL from #ImportTicketDumpDetails_Infra(NOLOCK) ITD        
 INNER join AVL.TK_TRN_InfraTicketDetail(NOLOCK)  TD ON ITD.[Ticket ID] = td.TicketID and ITD.ProjectID = TD.ProjectID        
        
 DROP TABLE #ImportTicketDumpDetails        
 DROP TABLE #ImportTicketDumpDetails_BOT        
 DROP TABLE #ImportTicketDumpDetails_Infra        
 DROP TABLE #ImportTicketDumpDetails_Nullvalue        
 DELETE [dbo].[TicketUpload] WHERE  projectID = @projectid and TicketUploadTrackID = @TicketUploadTrackID        
 --COMMIT TRAN          
 END TRY            
        
        
 /*----------------------------------END TRY--------------------------------*/          
        
 BEGIN CATCH            
        
   DECLARE @ErrorMessage VARCHAR(MAX);          
        
   SELECT @ErrorMessage = ERROR_MESSAGE()          
   DELETE [dbo].[TicketUpload] WHERE  projectID = @projectid and TicketUploadTrackID = @TicketUploadTrackID        
   --ROLLBACK TRAN          
 UPDATE AVL.TicketUploadTrack        
 SET         
 DBErrorMessage=@ErrorMessage        
 WHERE TicketUploadTrackID=@TicketUploadTrackID        
   --INSERT Error              
   EXEC AVL_InsertError '[dbo].[Tk_Ticketupload]', @ErrorMessage, @CogID, @projectID          
        
          
 END CATCH            
        
END