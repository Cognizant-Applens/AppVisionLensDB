/***************************************************************************              
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET              
*Copyright [2018] – [2021] Cognizant. All rights reserved.              
*NOTICE: This unpublished material is proprietary to Cognizant and              
*its suppliers, if any. The methods, techniques and technical              
  concepts herein are considered Cognizant confidential and/or trade secret information.               
                
*This material may be covered by U.S. and/or foreign patents or patent applications.               
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.              
***************************************************************************/              
              
CREATE PROCEDURE [AVL].[TK_SaveAttributeDetails]              
@IsAuditAvailable bit=0,  --1            
@UserID VARCHAR(50)=NULL,   --'2155552'            
@ResidualDebtId VARCHAR(50) = NULL,  --0            
@AvoidableFlagId VARCHAR(50)= NULL  ,   --0            
@IsAttributeUpdated VARCHAR(10) = NULL,   --'N'            
@TicketStatusID VARCHAR(50) = NULL,  --'10807'            
@Attribute [AVL].[TVP_TicketAttributeDetails]  READONLY  ,              
@IsTicketDescriptionUpdated BIT =NULL,  --null            
@IsTicketSummaryUpdated BIT =NULL,  --null            
@SupportTypeID INT= NULL,  --1            
@SourceID INT=7             
AS                    
BEGIN                  
BEGIN TRY                
BEGIN TRAN              
SET NOCOUNT ON;                    
               
DECLARE @tempAttri TABLE                    
(                    
    [TicketID] [varchar](100) NULL,              
    [serviceid] [int] NULL,              
    [projectId] [bigint] NULL,              
    [Priority] [bigint] NULL,              
    [Severity] [bigint] NULL,              
    [Assignedto] [varchar](100) NULL,              
    [ReleaseType] [bigint] NULL,              
              
    [EstimatedWorkSize] [decimal](20, 2) NULL,              
    [Ticketcreatedate] [datetime] NULL,              
              
    [ActualStartdateTime] [datetime] NULL,              
    [ActualEnddateTime] [datetime] NULL,              
    [ReopenDate] [datetime] NULL,              
    [CloseDate] [datetime] NULL,              
    [KEDBAvailableIndicator] [bigint] NULL,              
    [KEDBUpdatedAdded] [bigint] NULL,              
    [MetResponseSLA] [varchar](100) NULL,              
    [MetResolution] [varchar](100) NULL,              
    [TicketDescription] [nvarchar](max) NULL,              
    [Application] [bigint] NULL,              
    [KEDBPath] [varchar](max) NULL,              
    [CompletedDateTime] [datetime] NULL,              
    [ResolutionCode] [bigint] NULL,              
    [DebtClassificationId] [bigint] NULL,              
    [Resolutionmethod] NVARCHAR(MAX) NULL,              
    [CauseCode] [bigint] NULL,              
    [TicketOpenDate] [datetime] NULL,              
                  
    ----Newly added              
    ActualEffort decimal (20,2) null,              
    Comments NVARCHAR(MAX),               
    PlannedEffort decimal (20,2) null,              
    PlannedEndDate Datetime null,               
    PlannedStartDate Datetime null,               
    RCAID NVARCHAR(100) NULL,              
    ReleaseDate DATETIME NULL,              
    TicketSummary NVARCHAR(MAX) NULL,              
    AvoidableFlag INT NULL,              
    ResidualDebtId INT NULL,              
    TicketSource BIGINT NULL,              
    FlexField1 NVARCHAR(MAX) NULL,              
    FlexField2 NVARCHAR(MAX) NULL,              
    FlexField3 NVARCHAR(MAX) NULL,              
    FlexField4 NVARCHAR(MAX) NULL,              
    IsPartiallyAutomated INT NULL,              
    AHBusinessImpact Smallint NULL,                          
    AHImpactComments nvarchar(250)  NULL                
);                 
--Single classification--            
INSERT  INTO @tempAttri                    
SELECT  *                    
FROM    @Attribute            
            
DECLARE @IsCognizant BIT;            
declare @TicketID NVARCHAR(max) , @ProjectID BIGINT,@TicketDesc NVARCHAR(MAX)            
select @TicketID=TicketID,@ProjectID=projectId,@TicketDesc=TicketDescription FROM @tempAttri            
SELECT @IsCognizant=ISNULL( IsCoginzant,0) FROM [AVL].[MAS_ProjectMaster] WHERE ProjectID=@ProjectID             
IF(@IsCognizant=0)            
BEGIN            
   --Single AutoClassification Starts------            
declare @DDClassifiedDate datetime                                      
declare @IsAutoClassified varchar(2)                                      
declare @IsDDAutoClassified varchar(2)                                      
declare @MLSignOffDate datetime               
DECLARE @ApplicationName varchar(200);              
DECLARE @AutoClassificationType TINYINT;              
DECLARE @AutoClassificationMode bit;              
DECLARE @ApplicationID bigint;            
DECLARE @DARTStatus INT = 0                    
SELECT  @DARTStatus = DS.DARTStatusID from AVL.TK_MAP_ProjectStatusMapping(NOLOCK) SM JOIN @tempAttri TA ON                  
TA.projectId = SM.ProjectID  AND SM.IsDeleted = 0                  
JOIN AVL.TK_MAS_DARTTicketStatus(NOLOCK)DS ON DS.DARTStatusID = SM.TicketStatus_ID AND DS.IsDeleted = 0                  
WHERE SM.StatusID = @TicketStatusID              
 DECLARE @AppAlgorithmKey nvarchar(6);              
  DECLARE @InfraAlgorithmKey nvarchar(6);              
  IF((SELECT Count(AlgorithmKey) FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0) > 0 )            
  BEGIN             
  IF EXISTS(SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1)            
  BEGIN            
  SET @AppAlgorithmKey = (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1)            
  END            
  IF EXISTS(SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2)            
  BEGIN            
  SET @InfraAlgorithmKey = (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2)            
  END            
  END            
  ELSE            
  BEGIN            
  SET @AppAlgorithmKey ='AL002'            
  SET @InfraAlgorithmKey='AL002'            
  END                                  
 SELECT @ApplicationID=[Application] FROM @tempAttri            
            
 SET @ApplicationName= (SELECT ApplicationName FROM [AVL].[APP_MAS_ApplicationDetails] WHERE ApplicationId=@ApplicationID)              
 --Single AutoClassification Starts - Support type -1------            
IF(@SupportTypeID=1)            
BEGIN            
IF(@AppAlgorithmKey='AL001')            
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
  IF EXISTS(SELECT 1 FROM AVL.TK_MLClassification_TicketUpload(NOLOCK) WHERE ProjectID=@ProjectID and [Ticket ID]=@TicketID)            
  BEGIN            
    UPDATE TMT                      
    SET TMT.[Ticket Description]=@TicketDesc,            
 TMT.CauseCodeID= (CASE WHEN TA.CauseCode =0 THEN NULL else TA.CauseCode end) ,                   
 TMT.[Cause code]=NULL,                      
    TMT.[Resolution Code ID]=(CASE WHEN TA.ResolutionCode =0 THEN NULL else TA.ResolutionCode end) ,               
 TMT.[Resolution Code]=NULL,            
 TMT.AvoidableFlagID=(CASE WHEN TA.AvoidableFlag=0 THEN NULL ELSE TA.AvoidableFlag END),            
 TMT.ResidualDebtID=(CASE WHEN TA.ResidualDebtId=0 THEN NULL ELSE TA.ResidualDebtId END),            
 TMT.DebtClassificationId=(CASE WHEN TA.DebtClassificationId=0 THEN NULL ELSE TA.DebtClassificationId END)            
 --TMT.DescWorkPattern=TA.TicketDescriptionBasePattern,         
 --TMT.DescSubWorkPattern=TA.TicketDescriptionSubPattern,            
 --TMT.ResolutionWorkPattern=TA.ResolutionRemarksBasePattern,            
 --TMT.ResolutionSubWorkPattern=TA.ResolutionRemarksSubPattern            
    FROM AVL.TK_MLClassification_TicketUpload TMT JOIN  @tempAttri TA            
 ON TMT.[Ticket ID]=TA.TicketID AND TMT.ProjectID=TA.ProjectID            
  END            
  ELSE             
  BEGIN            
 IF(@DARTStatus=8 OR @DARTStatus=9)            
 BEGIN            
 INSERT INTO AVL.TK_MLClassification_TicketUpload              
    select @TicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDesc,'',null,null,null,null,null,null,null,null,null,null,null,0,              
    @UserID,'',null,1,null,null,null,null --(@DARTStatus=8 OR @DARTStatus=9)              
 END            
  END                
  END            
  ELSE IF (@AutoClassificationType=2)                    
  BEGIN                    
   IF(@AutoClassificationMode = 1)                    
   BEGIN              
   IF EXISTS(SELECT 1 FROM AVL.TK_MLClassification_TicketUpload(NOLOCK) WHERE ProjectID=@ProjectID and [Ticket ID]=@TicketID)            
   BEGIN            
    UPDATE TMT                      
    SET TMT.[Ticket Description]=TA.TicketDescription,            
 TMT.CauseCodeID= (CASE WHEN TA.CauseCode =0 THEN NULL else TA.CauseCode end) ,            
 TMT.[Cause code]=NULL,                      
    TMT.[Resolution Code ID]=(CASE WHEN TA.ResolutionCode =0 THEN NULL else TA.ResolutionCode end) ,               
 TMT.[Resolution Code]=NULL,            
 TMT.AvoidableFlagID=(CASE WHEN TA.AvoidableFlag=0 THEN NULL ELSE TA.AvoidableFlag END),            
 TMT.ResidualDebtID=(CASE WHEN TA.ResidualDebtId=0 THEN NULL ELSE TA.ResidualDebtId END),            
 TMT.DebtClassificationId=(CASE WHEN TA.DebtClassificationId=0 THEN NULL ELSE TA.DebtClassificationId END)            
 --TMT.DescWorkPattern=TD.TicketDescriptionBasePattern,            
 --TMT.DescSubWorkPattern=TD.TicketDescriptionSubPattern,            
 --TMT.ResolutionWorkPattern=TD.ResolutionRemarksBasePattern,            
 --TMT.ResolutionSubWorkPattern=TD.ResolutionRemarksSubPattern            
    from AVL.TK_MLClassification_TicketUpload TMT JOIN  @tempAttri TA            
  ON TMT.[Ticket ID]=TA.TicketID AND TMT.ProjectID=TA.ProjectID            
   --where TD.CauseCodeMapID is NULL AND TD.ResolutionCodeMapID IS NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND                      
   --TD.DebtClassificationMapID is NULL and TD.AvoidableFlag is NULL and TD.ResidualDebtMapID is NULL AND                 
   -- TD.TicketDescription IS NOT NULL AND TD.TicketDescription <> ''                    
   END            
   ELSE            
   BEGIN            
   IF(@DARTStatus=8 OR @DARTStatus=9)            
   BEGIN            
 INSERT into AVL.TK_MLClassification_TicketUpload                        
    SELECT @TicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDesc,'',NULL,NULL,                        
    NULL,NULL,null,null,null,null,null,null,NULL,0,@UserID,'',NULL,1,                        
    null,null,null,null             
 -- AND @@TicketDesc IS NOT NULL AND @@TicketDesc <> ''                
   END            
   END            
   END                    
   ELSE IF (@AutoClassificationMode = 0)                    
   BEGIN                   
   IF EXISTS(SELECT 1 FROM AVL.TK_MLClassification_TicketUpload(NOLOCK) WHERE ProjectID=@ProjectID and [Ticket ID]=@TicketID)            
   BEGIN            
    UPDATE TMT                      
    SET TMT.[Ticket Description]=TA.TicketDescription,            
 TMT.CauseCodeID= (CASE WHEN TA.CauseCode =0 THEN NULL else TA.CauseCode end) ,            
 TMT.[Cause code]=NULL,                      
    TMT.[Resolution Code ID]=(CASE WHEN TA.ResolutionCode =0 THEN NULL else TA.ResolutionCode end) ,               
 TMT.[Resolution Code]=NULL,            
 TMT.AvoidableFlagID=(CASE WHEN TA.AvoidableFlag=0 THEN NULL ELSE TA.AvoidableFlag END),            
 TMT.ResidualDebtID=(CASE WHEN TA.ResidualDebtId=0 THEN NULL ELSE TA.ResidualDebtId END),            
 TMT.DebtClassificationId=(CASE WHEN TA.DebtClassificationId=0 THEN NULL ELSE TA.DebtClassificationId END)            
 --TMT.DescWorkPattern=TD.TicketDescriptionBasePattern,            
 --TMT.DescSubWorkPattern=TD.TicketDescriptionSubPattern,            
 --TMT.ResolutionWorkPattern=TD.ResolutionRemarksBasePattern,            
 --TMT.ResolutionSubWorkPattern=TD.ResolutionRemarksSubPattern            
    from AVL.TK_MLClassification_TicketUpload TMT JOIN  @tempAttri TA            
  ON TMT.[Ticket ID]=TA.TicketID AND TMT.ProjectID=TA.ProjectID            
   END            
   ELSE            
   BEGIN            
   IF(@DARTStatus=8 OR @DARTStatus=9)            
   BEGIN            
 INSERT into AVL.TK_MLClassification_TicketUpload                        
    SELECT @TicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDesc,'',NULL,NULL,                        
    NULL,NULL,null,null,null,null,null,null,NULL,0,@UserID,'',NULL,1,                      
    null,null,null,null             
    --[TicketDescriptionBasePattern] IS NOT NULL AND [TicketDescriptionBasePattern] <> ''                      
    --AND [TicketDescriptionBasePattern] <> '0'                      
   END            
   END            
   --where TD.CauseCodeMapID is NULL AND TD.ResolutionCodeMapID IS NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND                      
   --TD.DebtClassificationMapID is NULL and TD.AvoidableFlag is NULL and TD.ResidualDebtMapID is NULL             
               
   END                      
  END                    
END            
ELSE IF(@AppAlgorithmKey='AL002')            
BEGIN            
         
 IF EXISTS(SELECT 1 FROM ML.TicketsforAutoClassification TAC JOIN ML.AutoClassificationBatchProcess AC ON TAC.BatchProcessId=AC.BatchProcessId WHERE TAC.TicketId=@TicketID AND AC.ProjectId=@ProjectID)            
 BEGIN            
 select 'inside exists',@TicketID AS TICKET,@ProjectID AS PROJECT            
  UPDATE TAC            
  SET TAC.TicketDescription=@TicketDesc,            
  TAC.CauseCodeMapID=(CASE WHEN TA.CauseCode =0 THEN NULL else TA.CauseCode end) ,            
  TAC.ResolutionCodeMapID=(CASE WHEN TA.ResolutionCode =0 THEN NULL else TA.ResolutionCode end) ,            
  TAC.AvoidableFlagId=(CASE WHEN TA.AvoidableFlag=0 THEN NULL ELSE TA.AvoidableFlag END),            
  TAC.ResidualFlagId=(CASE WHEN TA.ResidualDebtId=0 THEN NULL ELSE TA.ResidualDebtId END),            
  TAC.DebtClassificationId=(CASE WHEN TA.DebtClassificationId=0 THEN NULL ELSE TA.DebtClassificationId END),            
  TAC.TicketSourceMapID=(CASE WHEN TA.TicketSource =0 THEN NULL ELSE TA.TicketSource END),            
  TAC.TicketSummary=TA.TicketSummary,            
  TAC.ResolutionRemarks= (CASE WHEN TA.Resolutionmethod  =' ' THEN NULL ELSE TA.Resolutionmethod  END),            
  TAC.Comments=TA.Comments,            
  TAC.FlexField1 = (CASE WHEN TA.FlexField1  =' ' THEN NULL else TA.FlexField1  end),              
        TAC.FlexField2 = (CASE WHEN TA.FlexField2  =' ' THEN NULL else TA.FlexField2  end),              
        TAC.FlexField3 = (CASE WHEN TA.FlexField3  =' ' THEN NULL else TA.FlexField3  end),              
        TAC.FlexField4 = (CASE WHEN TA.FlexField4  =' ' THEN NULL else TA.FlexField4  end),            
  TAC.KEDBAvailableIndicatorMapID = (CASE WHEN TA.KEDBAvailableIndicator =0 THEN NULL ELSE TA.KEDBAvailableIndicator END),            
  TAC.ReleaseTypeMapID = (CASE WHEN TA.ReleaseType =0 THEN NULL ELSE TA.ReleaseType END)            
  FROM ML.TicketsforAutoClassification(NOLOCK) TAC JOIN @tempAttri TA ON TAC.TicketId=TA.TicketID JOIN ML.AutoClassificationBatchProcess AC ON   
 (TAC.BatchProcessId=AC.BatchProcessId AND TA.projectId=AC.ProjectId) WHERE TAC.TicketId=@TicketID AND AC.ProjectId=@ProjectID            
 END            
 --ELSE             
 --BEGIN            
 -- INSERT INTO ML.TicketsforAutoClassification                                
 -- ([BatchProcessId],[TicketId],[TicketDescription],[AssignmentGroupId],[Category],                                
 --  [TicketSourceMapID],[TicketTypeMapID],[TicketSummary],                                
 -- [ReleaseTypeMapID],[StatusId],[IsDeleted],[CreatedBy],[CreatedDate],[ModifiedBy],[SupportType],[ApplicationId]                                
 --  ) values(                           
 -- (SELECT max([BatchProcessId]) FROM ML.AutoClassificationBatchProcess WHERE ProjectId=@projectid),@AppTicketID ,@TicketDescription,@AssignmentGroupID,null,NULL,null,null,null,13,0,@EmployeeID,GETDATE(),null,1,@ApplicationID  )                    
 --END            
END            
END            
  --Single AutoClassification Ends - 1------            
--Single AutoClassification Starts - Support type -2------            
ELSE IF(@SupportTypeID=2)            
BEGIN            
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
  IF EXISTS(SELECT 1 FROM AVL.TK_MLClassification_TicketUpload(NOLOCK) WHERE ProjectID=@ProjectID and [Ticket ID]=@TicketID)            
  BEGIN            
    UPDATE TMT                      
    SET TMT.[Ticket Description]=@TicketDesc,            
 TMT.CauseCodeID= (CASE WHEN TA.CauseCode =0 THEN NULL else TA.CauseCode end) ,            
 TMT.[Cause code]=NULL,                      
    TMT.[Resolution Code ID]=(CASE WHEN TA.ResolutionCode =0 THEN NULL else TA.ResolutionCode end) ,             
 TMT.[Resolution Code]=NULL,            
 TMT.AvoidableFlagID=(CASE WHEN TA.AvoidableFlag=0 THEN NULL ELSE TA.AvoidableFlag END),            
 TMT.ResidualDebtID=(CASE WHEN TA.ResidualDebtId=0 THEN NULL ELSE TA.ResidualDebtId END),            
 TMT.DebtClassificationId=(CASE WHEN TA.DebtClassificationId=0 THEN NULL ELSE TA.DebtClassificationId END)            
    from AVL.TK_MLClassification_TicketUpload TMT JOIN  @tempAttri TA            
  ON TMT.[Ticket ID]=TA.TicketID AND TMT.ProjectID=TA.ProjectID            
   --where TD.CauseCodeMapID is NOT NULL AND TD.ResolutionCodeMapID IS NOT NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND                      
   --TD.DebtClassificationMapID is NULL and TD.AvoidableFlag is NULL and TD.ResidualDebtMapID is NULL                      
  END              
  ELSE            
  BEGIN            
  IF(@DARTStatus=8 OR @DARTStatus=9)            
  BEGIN            
 INSERT INTO AVL.TK_MLClassification_TicketUpload              
    select @TicketID,@ProjectID,0,NULL,@TicketDesc,'',null,null,null,null,null,null,null,null,null,null,null,0,              
    @UserID,'',TTI.TowerID,2,null,null,null,null from [AVL].[TK_TRN_InfraTicketDetail] AS TTI where TTI.ProjectID=@ProjectID AND TTI.TicketID=@TicketID             
  END            
  END            
  END            
  ELSE IF (@AutoClassificationType=2)                 
  BEGIN                    
   IF(@AutoClassificationMode = 1)                    
   BEGIN                    
   IF EXISTS(SELECT 1 FROM AVL.TK_MLClassification_TicketUpload(NOLOCK) WHERE ProjectID=@ProjectID and [Ticket ID]=@TicketID)            
   BEGIN            
    UPDATE TMT                      
    SET TMT.[Ticket Description]=@TicketDesc,            
 TMT.CauseCodeID= (CASE WHEN TA.CauseCode =0 THEN NULL else TA.CauseCode end) ,            
 TMT.[Cause code]=NULL,                      
    TMT.[Resolution Code ID]=(CASE WHEN TA.ResolutionCode =0 THEN NULL else TA.ResolutionCode end) ,            
 TMT.[Resolution Code]=NULL,            
 TMT.AvoidableFlagID=(CASE WHEN TA.AvoidableFlag=0 THEN NULL ELSE TA.AvoidableFlag END),            
 TMT.ResidualDebtID=(CASE WHEN TA.ResidualDebtId=0 THEN NULL ELSE TA.ResidualDebtId END),            
 TMT.DebtClassificationId=(CASE WHEN TA.DebtClassificationId=0 THEN NULL ELSE TA.DebtClassificationId END)            
    from AVL.TK_MLClassification_TicketUpload TMT JOIN  @tempAttri TA             
  ON TMT.[Ticket ID]=TA.TicketID AND TMT.ProjectID=TA.ProjectID            
   --where TD.CauseCodeMapID is NULL AND TD.ResolutionCodeMapID IS NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND                      
   --TD.DebtClassificationMapID is NULL and TD.AvoidableFlag is NULL and TD.ResidualDebtMapID is NULL AND                 
   -- TD.TicketDescription IS NOT NULL AND TD.TicketDescription <> ''                    
   END                    
   ELSE BEGIN            
     IF(@DARTStatus=8 OR @DARTStatus=9)            
  BEGIN            
 INSERT into AVL.TK_MLClassification_TicketUpload                        
    SELECT @TicketID,@ProjectID,0,'',@TicketDesc,'',NULL,NULL,                        
    NULL,NULL,null,null,null,null,null,null,NULL,0,@UserID,'',TTI.TowerID,2,                        
    null,null,null,null from [AVL].[TK_TRN_InfraTicketDetail] AS TTI where TTI.ProjectID=@ProjectID AND TTI.TicketID=@TicketID             
 -- AND @@TicketDesc IS NOT NULL AND @@TicketDesc <> ''                 
   END            
   END            
   END            
   --END            
   ELSE IF (@AutoClassificationMode = 0)                    
   BEGIN                    
   IF EXISTS(SELECT 1 FROM AVL.TK_MLClassification_TicketUpload(NOLOCK) WHERE ProjectID=@ProjectID and [Ticket ID]=@TicketID)            
   BEGIN            
    UPDATE TMT                      
    SET TMT.[Ticket Description]=TA.TicketDescription,            
 TMT.CauseCodeID= (CASE WHEN TA.CauseCode =0 THEN NULL else TA.CauseCode end) ,            
 TMT.[Cause code]=NULL,                      
    TMT.[Resolution Code ID]=(CASE WHEN TA.ResolutionCode =0 THEN NULL else TA.ResolutionCode end) ,            
 TMT.[Resolution Code]=NULL,            
 TMT.AvoidableFlagID=(CASE WHEN TA.AvoidableFlag=0 THEN NULL ELSE TA.AvoidableFlag END),            
 TMT.ResidualDebtID=(CASE WHEN TA.ResidualDebtId=0 THEN NULL ELSE TA.ResidualDebtId END),            
 TMT.DebtClassificationId=(CASE WHEN TA.DebtClassificationId=0 THEN NULL ELSE TA.DebtClassificationId END)            
    from AVL.TK_MLClassification_TicketUpload TMT JOIN  @tempAttri TA            
  ON TMT.[Ticket ID]=TA.TicketID AND TMT.ProjectID=TA.ProjectID            
   --where TD.CauseCodeMapID is NULL AND TD.ResolutionCodeMapID IS NULL AND (DARTStatusId = 8 OR DARTStatusId = 9) AND                      
   --TD.DebtClassificationMapID is NULL and TD.AvoidableFlag is NULL and TD.ResidualDebtMapID is NULL                       
   END            
   ELSE BEGIN            
   IF(@DARTStatus=8 OR @DARTStatus=9)            
   BEGIN            
 INSERT into AVL.TK_MLClassification_TicketUpload                        
    SELECT @TicketID,@ProjectID,0,'',@TicketDesc,'',NULL,NULL,                        
    NULL,NULL,null,null,null,null,null,null,NULL,0,@UserID,'',TTI.TowerID,2,                      
    null,null,null,null from [AVL].[TK_TRN_InfraTicketDetail] AS TTI where TTI.ProjectID=@ProjectID AND TTI.TicketID=@TicketID            
   END            
   END            
   END                      
  END                   
END            
ELSE IF(@InfraAlgorithmKey='AL002')            
BEGIN            
 IF EXISTS(SELECT 1 FROM ML.TicketsforAutoClassification TAC JOIN ML.AutoClassificationBatchProcess AC ON TAC.BatchProcessId=AC.BatchProcessId WHERE TAC.TicketId=@TicketID AND AC.ProjectId=@ProjectID)            
 BEGIN            
  UPDATE TAC             
  SET TAC.TicketDescription=@TicketDesc,            
  TAC.CauseCodeMapID=(CASE WHEN TA.CauseCode =0 THEN NULL else TA.CauseCode end) ,            
  TAC.ResolutionCodeMapID=(CASE WHEN TA.ResolutionCode =0 THEN NULL else TA.ResolutionCode end) ,            
  TAC.AvoidableFlagId=(CASE WHEN TA.AvoidableFlag=0 THEN NULL ELSE TA.AvoidableFlag END),            
  TAC.ResidualFlagId=(CASE WHEN TA.ResidualDebtId=0 THEN NULL ELSE TA.ResidualDebtId END),            
  TAC.DebtClassificationId=(CASE WHEN TA.DebtClassificationId=0 THEN NULL ELSE TA.DebtClassificationId END),            
  TAC.TicketSourceMapID=(CASE WHEN TA.TicketSource =0 THEN NULL ELSE TA.TicketSource END),            
  TAC.TicketSummary=TA.TicketSummary,            
  TAC.ResolutionRemarks= (CASE WHEN TA.Resolutionmethod  =' ' THEN NULL ELSE TA.Resolutionmethod  END),            
  TAC.Comments=TA.Comments,            
  TAC.FlexField1 = (CASE WHEN TA.FlexField1  =' ' THEN NULL else TA.FlexField1  end),              
        TAC.FlexField2 = (CASE WHEN TA.FlexField2  =' ' THEN NULL else TA.FlexField2  end),       
        TAC.FlexField3 = (CASE WHEN TA.FlexField3  =' ' THEN NULL else TA.FlexField3  end),              
        TAC.FlexField4 = (CASE WHEN TA.FlexField4  =' ' THEN NULL else TA.FlexField4  end),            
  TAC.KEDBAvailableIndicatorMapID = (CASE WHEN TA.KEDBAvailableIndicator =0 THEN NULL ELSE TA.KEDBAvailableIndicator END),            
  TAC.ReleaseTypeMapID = (CASE WHEN TA.ReleaseType =0 THEN NULL ELSE TA.ReleaseType END)            
  FROM ML.TicketsforAutoClassification TAC JOIN @tempAttri TA ON TAC.TicketId=TA.TicketID JOIN ML.AutoClassificationBatchProcess AC ON   
 (TAC.BatchProcessId=AC.BatchProcessId AND TA.projectId=AC.ProjectId) WHERE TAC.TicketId=@TicketID AND AC.ProjectId=@ProjectID            
 END            
END            
END            
  --Single AutoClassification Ends -2------            
END            
--            
IF(@IsAttributeUpdated = 'Y')              
BEGIN              
SET @IsAttributeUpdated  =  1              
END              
ELSE              
BEGIN              
SET @IsAttributeUpdated  =  0              
END              
              
INSERT  INTO @tempAttri                    
SELECT  *                    
FROM    @Attribute               
              
/* Taking Assigned To using External LoginID */              
    DECLARE @ExternalUserID BIGINT              
                  
    SELECT @ExternalUserID=lm.UserID               
        FROM AVL.MAS_LoginMaster(NOLOCK) lm               
        JOIN @tempAttri a on lm.EmployeeID=a.Assignedto and lm.ProjectID = a.projectId and lm.IsDeleted=0              
              
--select * from @Attribute              
--select * from @tempAttri              
              
/*****************************Multilingual******************************/              
DECLARE @isMultiLingual INT;              
SET @isMultiLingual = 0;              
        DECLARE @IsResolutionRemarks [BIT]=0,              
                @IsComments [BIT] =0,              
                @IsFlexField1 [BIT]=0,              
                @IsFlexField2[BIT]=0,              
                @IsFlexField3 [BIT]=0,              
                @IsFlexField4 [BIT]=0,              
                @IsCategory [BIT]=0,              
                @IsType [BIT]=0,              
                @TicketSummary [BIT]=0,              
                @TicketDescription[BIT] = 0              
                  
              
    SELECT @isMultiLingual=1 FROM AVL.MAS_ProjectMaster P WITH (NOLOCK)        
    JOIN @tempAttri TA ON                  
TA.projectId = P.ProjectID                    
     WHERE IsDeleted=0 AND IsMultilingualEnabled=1;              
                  
    IF(@isMultiLingual=1)              
        BEGIN              
        SELECT DISTINCT MCM.ColumnID INTO #Columns FROM AVL.MAS_MultilingualColumnMaster MCM WITH (NOLOCK)               
        JOIN AVL.PRJ_MultilingualColumnMapping MCP WITH(NOLOCK) ON MCM.ColumnID=MCP.ColumnID              
        JOIN @tempAttri TA ON TA.projectId = MCP.ProjectID                
        WHERE MCM.IsActive=1 AND MCP.IsActive=1              
                          
                      
        SELECT @IsResolutionRemarks=1 FROM #Columns WHERE ColumnID=3;              
            SELECT @IsComments=1 FROM #Columns WHERE ColumnID=4;              
                SELECT @IsFlexField1=1 FROM #Columns WHERE ColumnID=7;              
                    SELECT @IsFlexField2=1 FROM #Columns WHERE ColumnID=8;              
                        SELECT @IsFlexField3=1 FROM #Columns WHERE ColumnID=9;              
                            SELECT @IsFlexField4=1 FROM #Columns WHERE ColumnID=10;              
                                SELECT @IsCategory=1 FROM #Columns WHERE ColumnID=11;              
                                SELECT @IsType=1 FROM #Columns WHERE ColumnID=12;              
                                SELECT @TicketSummary=1 FROM #Columns WHERE ColumnID=2;              
                                SELECT @TicketDescription=1 FROM #Columns WHERE ColumnID=1;              
              
IF(@SupportTypeID = 1 OR @SupportTypeID  IS NULL)              
BEGIN              
SELECT ITD.[TicketID],TD.TimeTickerID,              
CASE WHEN (@IsResolutionRemarks =1 AND (( ITD.[Resolutionmethod]=TD.ResolutionRemarks)               
            OR (ITD.[Resolutionmethod]='') OR (ITD.[Resolutionmethod] IS NULL)))              
            OR (@IsResolutionRemarks !=1)              
            THEN 0 ELSE 1 END AS 'IsResolutionRemarksModified',              
ISNULL(@IsTicketDescriptionUpdated,0) AS 'IsTicketDescriptionModified',              
ISNULL(@IsTicketSummaryUpdated,0) AS 'IsTicketSummaryModified',              
CASE WHEN (@IsComments =1 AND (( ITD.Comments=TD.Comments) OR (ITD.Comments='') OR               
            (ITD.Comments IS NULL))) OR (@IsComments !=1)              
            THEN 0 ELSE 1 END AS 'IsCommentsModified',              
CASE WHEN (@IsFlexField1 =1 AND ((ITD.[FlexField1]=TD.FlexField1) OR (ITD.[FlexField1]='')              
             OR(ITD.[FlexField1] IS NULL))) OR (@IsFlexField1!=1)              
            THEN 0 ELSE 1 END AS 'IsFlexField1Modified',              
CASE WHEN (@IsFlexField2 =1 AND ((ITD.[FlexField2]=TD.FlexField2) OR (ITD.[FlexField2]='') OR              
             (ITD.[FlexField2] IS NULL))) OR (@IsFlexField2!=1)              
    THEN 0 ELSE 1 END AS 'IsFlexField2Modified',              
CASE WHEN (@IsFlexField3 =1 AND ((ITD.[FlexField3]=TD.FlexField3) OR (ITD.[FlexField3]='')               
    OR (ITD.[FlexField3] IS NULL))) OR (@IsFlexField3!=1)              
    THEN 0 ELSE 1 END AS 'IsFlexField3Modified',              
CASE WHEN (@IsFlexField4 =1 AND ((ITD.[FlexField4]=TD.FlexField4) OR (ITD.[FlexField4]='')              
     OR(ITD.[FlexField4] IS NULL))) OR (@IsFlexField4!=1)              
    THEN 0 ELSE 1 END AS 'IsFlexField4Modified',              
CASE WHEN (@IsCategory =1  OR @IsCategory !=1)              
    THEN 0 ELSE 1 END AS 'IsCategoryModified',              
CASE WHEN (@IsType =1  OR @IsType!=1)              
    THEN 0 ELSE 1 END AS 'IsTypeModified'              
INTO #MultilingualTbl2              
FROM  @tempAttri ITD LEFT JOIN AVL.TK_TRN_TicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[TicketID]               
AND TD.ProjectID=ITD.[projectId]  AND TD.IsDeleted=0;              
END              
ELSE IF(@SupportTypeID = 2)              
BEGIN              
              
SELECT ITD.[TicketID],TD.TimeTickerID,             
CASE WHEN (@IsResolutionRemarks =1 AND (( ITD.[Resolutionmethod]=TD.ResolutionRemarks)               
            OR (ITD.[Resolutionmethod]='') OR (ITD.[Resolutionmethod] IS NULL)))              
            OR (@IsResolutionRemarks !=1)              
            THEN 0 ELSE 1 END AS 'IsResolutionRemarksModified',              
ISNULL(@IsTicketDescriptionUpdated,0) AS 'IsTicketDescriptionModified',              
ISNULL(@IsTicketSummaryUpdated,0) AS 'IsTicketSummaryModified',              
CASE WHEN (@IsComments =1 AND (( ITD.Comments=TD.Comments) OR (ITD.Comments='') OR               
            (ITD.Comments IS NULL))) OR (@IsComments !=1)              
            THEN 0 ELSE 1 END AS 'IsCommentsModified',              
CASE WHEN (@IsFlexField1 =1 AND ((ITD.[FlexField1]=TD.FlexField1) OR (ITD.[FlexField1]='')              
             OR(ITD.[FlexField1] IS NULL))) OR (@IsFlexField1!=1)              
            THEN 0 ELSE 1 END AS 'IsFlexField1Modified',      
CASE WHEN (@IsFlexField2 =1 AND ((ITD.[FlexField2]=TD.FlexField2) OR (ITD.[FlexField2]='') OR              
             (ITD.[FlexField2] IS NULL))) OR (@IsFlexField2!=1)              
    THEN 0 ELSE 1 END AS 'IsFlexField2Modified',              
CASE WHEN (@IsFlexField3 =1 AND ((ITD.[FlexField3]=TD.FlexField3) OR (ITD.[FlexField3]='')               
    OR (ITD.[FlexField3] IS NULL))) OR (@IsFlexField3!=1)              
    THEN 0 ELSE 1 END AS 'IsFlexField3Modified',              
CASE WHEN (@IsFlexField4 =1 AND ((ITD.[FlexField4]=TD.FlexField4) OR (ITD.[FlexField4]='')              
     OR(ITD.[FlexField4] IS NULL))) OR (@IsFlexField4!=1)              
    THEN 0 ELSE 1 END AS 'IsFlexField4Modified',              
CASE WHEN (@IsCategory =1 OR @IsCategory !=1)              
    THEN 0 ELSE 1 END AS 'IsCategoryModified',              
CASE WHEN (@IsType =1 OR @IsType!=1)              
    THEN 0 ELSE 1 END AS 'IsTypeModified'              
INTO #MultilingualInfraTbl2              
FROM  @tempAttri ITD LEFT JOIN AVL.TK_TRN_InfraTicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[TicketID]               
AND TD.ProjectID=ITD.[projectId]  AND TD.IsDeleted=0;              
END              
                      
        END              
              
    /**********************************************************************/              
--DECLARE @DARTStatus INT = 0                    
--SELECT  @DARTStatus = DS.DARTStatusID from AVL.TK_MAP_ProjectStatusMapping(NOLOCK) SM JOIN @tempAttri TA ON                  
--TA.projectId = SM.ProjectID  AND SM.IsDeleted = 0                  
--JOIN AVL.TK_MAS_DARTTicketStatus(NOLOCK)DS ON DS.DARTStatusID = SM.TicketStatus_ID AND DS.IsDeleted = 0                  
--WHERE SM.StatusID = @TicketStatusID                 
              
--Update the Business Impact Column and Impact Comments in DE                        
IF(@SupportTypeID = 1 OR @SupportTypeID  IS NULL)                 
 BEGIN                
--App Ticket                    
UPDATE TT                      
SET TT.BusinessImpactId=IIF(TS.AHBusinessImpact=0,NULL,TS.AHBusinessImpact),                       
TT.ImpactComments=TS.AHImpactComments                        
FROM AVL.TK_TRN_TicketDetail TD                         
INNER JOIN @tempAttri TS ON TS.projectId=TD.ProjectID AND   TD.TicketID=TS.TicketID                          
INNER JOIN avl.DEBT_TRN_HealTicketDetails TT (NOLOCK) ON TD.TicketID=TT.HealingTicketID                          
INNER JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic PM (NOLOCK) ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TD.ProjectID=PM.ProjectID AND TT.IsDeleted=0                          
INNER JOIN avl.TK_MAP_TicketTypeMapping TTM (NOLOCK) ON TD.ProjectID = TTM.ProjectID AND TD.TicketTypeMapID = TTM.TicketTypeMappingID                         
WHERE TD.TicketID=TS.TicketID                      
    END                
 IF(@SupportTypeID = 2)                
BEGIN                
--Infra Ticket                    
UPDATE TT                        
SET TT.BusinessImpactId=IIF(TS.AHBusinessImpact=0,NULL,TS.AHBusinessImpact),                        
TT.ImpactComments=TS.AHImpactComments                        
FROM AVL.TK_TRN_InfraTicketDetail TD                         
INNER JOIN @tempAttri TS ON TS.projectId=TD.ProjectID AND   TD.TicketID=TS.TicketID                          
INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails] TT (NOLOCK) ON TD.TicketID=TT.HealingTicketID                      
 INNER JOIN AVL.DEBT_TRN_InfraHealTicketEfffortDormantDetails TTDO ON TTDO.HealingID=TT.Id                         
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] PM (NOLOCK) ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TD.ProjectID=PM.ProjectID AND TT.IsDeleted=0                          
INNER JOIN avl.TK_MAP_TicketTypeMapping TTM (NOLOCK) ON TD.ProjectID = TTM.ProjectID AND TD.TicketTypeMapID = TTM.TicketTypeMappingID                         
WHERE TD.TicketID=TS.TicketID                      
END              
              
--Need to check once              
--SELECT   DS.DARTStatusID from AVL.TK_MAP_ProjectStatusMapping(NOLOCK) SM JOIN @tempAttri TA ON                  
--TA.projectId = SM.ProjectID  AND SM.IsDeleted = 0                  
--JOIN AVL.TK_MAS_DARTTicketStatus(NOLOCK) DS ON DS.DARTStatusID = SM.TicketStatus_ID AND  DS.IsDeleted = 0                   
--WHERE  SM.StatusID = @TicketStatusID                   
              
--declare @TicketID NVARCHAR(max) , @ProjectID BIGINT              
            
IF @SupportTypeID = 2              
BEGIN              
    UPDATE TM SET                    
        TM.AssignedTo=  @ExternalUserID,                  
        TM.SeverityMapID = (CASE WHEN TA.Severity =0 THEN NULL else TA.Severity end)  ,              
        TM.PriorityMapID = TA.Priority,              
        --Problem Fix--              
        TM.ReleaseTypeMapID = (CASE WHEN TA.ReleaseType =0 THEN NULL else TA.ReleaseType end),                             
        TM.EstimatedWorkSize = (CASE WHEN TA.EstimatedWorkSize =0.00 THEN NULL else TA.EstimatedWorkSize end) ,              
        TM.CauseCodeMapID=(CASE WHEN TA.CauseCode =0 THEN NULL else TA.CauseCode end) ,                   
        TM.Closeddate =(case when TA.CloseDate='1/1/1900 12:00:00 AM' then null else TA.CloseDate end),                    
        TM.ActualStartdateTime =  (case when TA.ActualStartdateTime='1/1/1900 12:00:00 AM' then null else TA.ActualStartdateTime end),                    
        TM.ActualEnddateTime = (case when TA.ActualEnddateTime='1/1/1900 12:00:00 AM' then null else TA.ActualEnddateTime end),               
        TM.KEDBAvailableIndicatorMapID = (case when TA.KEDBAvailableIndicator =0 then NULL else TA.KEDBAvailableIndicator END) ,                    
        TM.KEDBUpdatedMapID = (case when TA.KEDBUpdatedAdded =0 then NULL else TA.KEDBUpdatedAdded END) ,                            
        TM.MetResponseSLAMapID = case when TA.MetResponseSLA =0 then NULL else TA.MetResponseSLA END,                        
        TM.MetResolutionMapID = case when TA.MetResolution=0 then NULL ELSE TA.MetResolution END,                    
        TM.TicketDescription = TA.TicketDescription,                       
        TM.KEDBPath  = (case when TA.KEDBPath='0' then null else TA.KEDBPath end),                               
        TM.CompletedDateTime =  (case when TA.CompletedDateTime='1/1/1900 12:00:00 AM' then null else TA.CompletedDateTime end) ,                         
        TM.ResolutionCodeMapID = (CASE WHEN TA.ResolutionCode =0 THEN NULL else TA.ResolutionCode end) ,               
        TM.DebtClassificationMapID=(CASE WHEN TA.DebtClassificationId =0 THEN NULL else TA.DebtClassificationId end) ,              
        TM.AvoidableFlag=(CASE WHEN TA.AvoidableFlag =0 THEN NULL else TA.AvoidableFlag end) ,               
        TM.ResidualDebtMapID = (CASE WHEN Ta.ResidualDebtId =0 THEN NULL else Ta.ResidualDebtId end) ,              
        TM.ResolutionRemarks= (CASE WHEN TA.Resolutionmethod  =' ' THEN NULL else TA.Resolutionmethod  end),              
        TM.LastUpdatedDate = GETDATE(),              
        TM.ModifiedDate=getdate(),              
        TM.ModifiedBy=@UserID,              
        TM.ActualEffort = TA.ActualEffort,              
        TM.IsAttributeUpdated = @IsAttributeUpdated,              
        TM.OpenDateTime =  (case when TA.TicketOpenDate='1/1/1900 12:00:00 AM' then null else TA.TicketOpenDate end),              
        TM.DARTStatusID= @DARTStatus,              
        TM.Comments=TA.Comments,              
        TM.PlannedEffort=TA.PlannedEffort,              
        TM.PlannedStartDate = (case when TA.PlannedStartDate='1/1/1900 12:00:00 AM' then null else TA.PlannedStartDate end),                    
        TM.PlannedEndDate = (case when TA.PlannedEndDate='1/1/1900 12:00:00 AM' then null else TA.PlannedEndDate end),                    
        TM.RCAID=TA.RCAID,              
        TM.ReleaseDate =  (case when TA.ReleaseDate='1/1/1900 12:00:00 AM' then null else TA.ReleaseDate end),              
        TM.TicketSummary=TA.TicketSummary,              
        TM.TicketSourceMapID=(CASE WHEN Ta.TicketSource =0 THEN NULL else Ta.TicketSource end),               
        TM.ReopenDateTime = (case when TA.ReopenDate='1/1/1900 12:00:00 AM' then null else TA.ReopenDate end),              
        TM.FlexField1 = (CASE WHEN TA.FlexField1  =' ' THEN NULL else TA.FlexField1  end),              
        TM.FlexField2 = (CASE WHEN TA.FlexField2  =' ' THEN NULL else TA.FlexField2  end),              
        TM.FlexField3 = (CASE WHEN TA.FlexField3  =' ' THEN NULL else TA.FlexField3  end),              
        TM.FlexField4 = (CASE WHEN TA.FlexField4  =' ' THEN NULL else TA.FlexField4  end),              
        TM.IsPartiallyAutomated=(case when TA.IsPartiallyAutomated =0 then 2 else TA.IsPartiallyAutomated END),              
        TM.LastModifiedSource=@SourceID              
        FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TM                    
        JOIN @tempAttri TA                 
        ON TM.TicketID = TA.TicketID                    
        AND TA.projectId = TM.ProjectID              
        AND TM.IsDeleted = 0                
              
                      
/*************************Infra Auto Classification*************************************/              
              
--select *              
--      FROM AVL.TK_TRN_TicketDetail TM                    
--      JOIN @tempAttri TA                 
--      ON TM.TicketID = TA.TicketID                    
--      AND TM.IsDeleted = 0                
--      AND TA.projectId = TM.ProjectID              
        --declare @TicketID NVARCHAR(max) , @ProjectID BIGINT              
        select @TicketID=TicketID,@ProjectID=projectId FROM @tempAttri              
                      
--      insert into AVL.TRN_InfraDebtClassificationModeDetails (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,              
--UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode)              
                      
--      select DC.TimeTickerID,DC.SystemDebtclassification,DC.SystemAvoidableFlag,DC.SystemResidualDebtFlag,              
--DC.UserDebtClassificationFlag,DC.UserAvoidableFlag,DC.UserResidualDebtFlag,DC.SourceForPattern,DC.IsDeleted,              
--DC.CreatedBy,DC.CreatedDate,DC.DebtClassficationMode              
--from  [AVL].[TRN_DebtClassificationModeDetails_Dump]  DC              
--INNER JOIN  AVL.TK_TRN_TicketDetail TD ON TD.TimeTickerID=DC.TimeTickerID              
--INNER JOIN  @tempAttri TA ON TA.TicketID=TD.TicketID and TA.projectId=TD.ProjectID              
              
            
                      
exec [AVL].[InsertAttrToDebtClassificationMode] @TicketID,@ProjectID, @UserID,1,2              
            
--update ticket set               
--ticket.DebtClassificationMode=debt.DebtClassficationMode              
   
--from              
--AVL.TRN_InfraDebtClassificationModeDetails debt               
--join AVL.TK_TRN_InfraTicketDetail ticket               
--on ticket.TimeTickerID=debt.TimeTickerID               
--INNER JOIN  @tempAttri TA ON TA.TicketID=ticket.TicketID and TA.projectId=ticket.ProjectID              
--WHERE TA.projectId=@ProjectID              
END              
              
ELSE              
   BEGIN              
        UPDATE TM SET                    
        TM.AssignedTo=  @ExternalUserID,                  
        TM.SeverityMapID = (CASE WHEN TA.Severity =0 THEN NULL else TA.Severity end)  ,              
        TM.PriorityMapID = TA.Priority,              
        --Problem Fix--              
        TM.ReleaseTypeMapID = (CASE WHEN TA.ReleaseType =0 THEN NULL else TA.ReleaseType end),                             
        TM.EstimatedWorkSize = (CASE WHEN TA.EstimatedWorkSize =0.00 THEN NULL else TA.EstimatedWorkSize end) ,              
        TM.CauseCodeMapID=(CASE WHEN TA.CauseCode =0 THEN NULL else TA.CauseCode end) ,                   
        TM.Closeddate =(case when TA.CloseDate='1/1/1900 12:00:00 AM' then null else TA.CloseDate end),                    
        TM.ActualStartdateTime =  (case when TA.ActualStartdateTime='1/1/1900 12:00:00 AM' then null else TA.ActualStartdateTime end),                    
        TM.ActualEnddateTime = (case when TA.ActualEnddateTime='1/1/1900 12:00:00 AM' then null else TA.ActualEnddateTime end),               
        TM.KEDBAvailableIndicatorMapID = (case when TA.KEDBAvailableIndicator =0 then NULL else TA.KEDBAvailableIndicator END) ,                    
        TM.KEDBUpdatedMapID = (case when TA.KEDBUpdatedAdded =0 then NULL else TA.KEDBUpdatedAdded END) ,                            
        TM.MetResponseSLAMapID = case when TA.MetResponseSLA =0 then NULL else TA.MetResponseSLA END,                        
        TM.MetResolutionMapID = case when TA.MetResolution=0 then NULL ELSE TA.MetResolution END,                    
        TM.TicketDescription = TA.TicketDescription,                     
        TM.KEDBPath  = (case when TA.KEDBPath='0' then null else TA.KEDBPath end),                              
        TM.CompletedDateTime =  (case when TA.CompletedDateTime='1/1/1900 12:00:00 AM' then null else TA.CompletedDateTime end) ,                            
        TM.ResolutionCodeMapID = (CASE WHEN TA.ResolutionCode =0 THEN NULL else TA.ResolutionCode end) ,               
        TM.DebtClassificationMapID=(CASE WHEN TA.DebtClassificationId =0 THEN NULL else TA.DebtClassificationId end) ,              
        TM.AvoidableFlag=(CASE WHEN TA.AvoidableFlag =0 THEN NULL else TA.AvoidableFlag end) ,               
        TM.ResidualDebtMapID = (CASE WHEN Ta.ResidualDebtId =0 THEN NULL else Ta.ResidualDebtId end) ,              
        TM.ResolutionRemarks= (CASE WHEN TA.Resolutionmethod  =' ' THEN NULL else TA.Resolutionmethod  end),              
        TM.LastUpdatedDate = GETDATE(),              
        TM.ModifiedDate=getdate(),              
        TM.ModifiedBy=@UserID,              
        TM.ActualEffort = TA.ActualEffort,              
        TM.IsAttributeUpdated = @IsAttributeUpdated,              
        TM.OpenDateTime =  (case when TA.TicketOpenDate='1/1/1900 12:00:00 AM' then null else TA.TicketOpenDate end),              
        TM.DARTStatusID= @DARTStatus,              
        TM.Comments=TA.Comments,              
        TM.PlannedEffort=TA.PlannedEffort,              
        TM.PlannedStartDate = (case when TA.PlannedStartDate='1/1/1900 12:00:00 AM' then null else TA.PlannedStartDate end),                    
        TM.PlannedEndDate = (case when TA.PlannedEndDate='1/1/1900 12:00:00 AM' then null else TA.PlannedEndDate end),                    
        TM.RCAID=TA.RCAID,              
        TM.ReleaseDate =  (case when TA.ReleaseDate='1/1/1900 12:00:00 AM' then null else TA.ReleaseDate end),              
        TM.TicketSummary=TA.TicketSummary,   
        TM.TicketSourceMapID=(CASE WHEN Ta.TicketSource =0 THEN NULL else Ta.TicketSource end),               
        TM.ReopenDateTime = (case when TA.ReopenDate='1/1/1900 12:00:00 AM' then null else TA.ReopenDate end),              
        TM.FlexField1 = (CASE WHEN TA.FlexField1  =' ' THEN NULL else TA.FlexField1  end),              
        TM.FlexField2 = (CASE WHEN TA.FlexField2  =' ' THEN NULL else TA.FlexField2  end),              
        TM.FlexField3 = (CASE WHEN TA.FlexField3  =' ' THEN NULL else TA.FlexField3  end),              
        TM.FlexField4 = (CASE WHEN TA.FlexField4  =' ' THEN NULL else TA.FlexField4  end),              
        TM.LastModifiedSource=@SourceID,              
        TM.IsPartiallyAutomated=(case when TA.IsPartiallyAutomated =0 then 2 else TA.IsPartiallyAutomated END),              
        TM.ApplicationID = TA.[Application]              
        FROM AVL.TK_TRN_TicketDetail(NOLOCK) TM                    
        JOIN @tempAttri TA                 
        ON TM.TicketID = TA.TicketID                
        AND TA.projectId = TM.ProjectID              
        AND TM.IsDeleted = 0                
                      
              
        if exists(select 1 from avl.TM_TRN_TimesheetDetail(NOLOCK) tsd join @tempAttri TA on tsd.TicketID=ta.TicketID and tsd.ProjectId=ta.projectId)              
        begin              
        update tsd set tsd.applicationid=ta.[application] from avl.TM_TRN_TimesheetDetail tsd join @tempAttri TA on tsd.TicketID=ta.TicketID and tsd.ProjectId=ta.projectId              
        end               
              
        --select *              
        --FROM AVL.TK_TRN_TicketDetail TM                    
        --JOIN @tempAttri TA                 
        --ON TM.TicketID = TA.TicketID                    
        --AND TM.IsDeleted = 0                
        --AND TA.projectId = TM.ProjectID              
        --declare @TicketID NVARCHAR(max) , @ProjectID BIGINT              
        select @TicketID=TicketID,@ProjectID=projectId FROM @tempAttri              
                      
              
        insert into AVL.TRN_DebtClassificationModeDetails (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,              
UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode)              
                      
        select DC.TimeTickerID,DC.SystemDebtclassification,DC.SystemAvoidableFlag,DC.SystemResidualDebtFlag,              
DC.UserDebtClassificationFlag,DC.UserAvoidableFlag,DC.UserResidualDebtFlag,DC.SourceForPattern,DC.IsDeleted,              
DC.CreatedBy,DC.CreatedDate,DC.DebtClassficationMode              
from  [AVL].[TRN_DebtClassificationModeDetails_Dump](NOLOCK) DC              
INNER JOIN  AVL.TK_TRN_TicketDetail(NOLOCK) TD ON TD.TimeTickerID=DC.TimeTickerID              
INNER JOIN  @tempAttri TA ON TA.TicketID=TD.TicketID and TA.projectId=TD.ProjectID              
              
                 
                            
              
exec [AVL].[InsertAttrToDebtClassificationMode] @TicketID,@ProjectID, @UserID,1,1              
            
            
            
--update ticket set               
--ticket.DebtClassificationMode=debt.DebtClassficationMode              
              
--from              
--AVL.TRN_DebtClassificationModeDetails debt               
--join AVL.TK_TRN_TicketDetail ticket               
--on ticket.TimeTickerID=debt.TimeTickerID               
--INNER JOIN  @tempAttri TA ON TA.TicketID=ticket.TicketID and TA.projectId=ticket.ProjectID              
--WHERE TA.projectId=@ProjectID              
              
/*************************Multilingual*************************************/              
              
IF(@isMultiLingual=1)              
BEGIN  IF(@SupportTypeID = 1)              
BEGIN              
UPDATE ITD SET ITD.TimeTickerID=TD.TimeTickerID              
FROM #MultilingualTbl2 ITD JOIN AVL.TK_TRN_TicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[TicketID]               
AND TD.ProjectID=@ProjectID AND TD.IsDeleted=0;              
              
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
TARGET.ModifiedBy=@UserID,              
TARGET.ModifiedDate=GETDATE()              
WHEN NOT MATCHED BY TARGET               
THEN               
INSERT (TimeTickerID,IsTicketDescriptionUpdated,IsResolutionRemarksUpdated,IsTicketSummaryUpdated,              
IsCommentsUpdated,IsFlexField1Updated,IsFlexField2Updated,IsFlexField3Updated,IsFlexField4Updated,              
IsCategoryUpdated,IsTypeUpdated,Isdeleted,CreatedBy,CreatedDate )               
VALUES (SOURCE.TimeTickerID,SOURCE.IsTicketDescriptionModified,SOURCE.IsResolutionRemarksModified,              
SOURCE.IsTicketSummaryModified,SOURCE.IsCommentsModified,SOURCE.IsFlexField1Modified,              
SOURCE.IsFlexField2Modified,SOURCE.IsFlexField3Modified,SOURCE.IsFlexField4Modified,              
SOURCE.IsCategoryModified,SOURCE.IsTypeModified,0,@UserID,GETDATE());              
              
UPDATE MLV SET              
MLV.TicketDescription = (CASE WHEN ISNULL(TD.TicketDescription,'') = '' THEN TD.TicketDescription ELSE MLV.TicketDescription END),              
MLV.ResolutionRemarks =(CASE WHEN ISNULL(TD.ResolutionRemarks,'') = '' THEN TD.ResolutionRemarks ELSE MLV.ResolutionRemarks END),              
MLV.TicketSummary =(CASE WHEN ISNULL(TD.TicketSummary,'') = '' THEN TD.TicketSummary ELSE MLV.TicketSummary END),              
MLV.Comments =(CASE WHEN ISNULL(TD.Comments,'') = '' THEN TD.Comments ELSE MLV.Comments END),              
MLV.FlexField1 =(CASE WHEN ISNULL(TD.FlexField1,'') = '' THEN TD.FlexField1 ELSE MLV.FlexField1 END),              
MLV.FlexField2 =(CASE WHEN ISNULL(TD.FlexField2,'') = '' THEN TD.FlexField2 ELSE MLV.FlexField2 END),              
MLV.FlexField3 =(CASE WHEN ISNULL(TD.FlexField3,'') = '' THEN TD.FlexField3 ELSE MLV.FlexField3 END),              
MLV.FlexField4 =(CASE WHEN ISNULL(TD.FlexField4,'') = '' THEN TD.FlexField4 ELSE MLV.FlexField4 END)              
FROM [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails] MLV              
INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON TD.TimeTickerID = MLV.TimeTickerID              
INNER JOIN #MultilingualTbl2(NOLOCK) MTD ON MTD.TimeTickerID = TD.TimeTickerID              
WHERE TD.ProjectID = @ProjectID              
              
END              
ELSE IF(@SupportTypeID = 2)              
BEGIN              
UPDATE ITD SET ITD.TimeTickerID=TD.TimeTickerID              
FROM #MultilingualInfraTbl2 ITD JOIN TK_TRN_InfraTicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[TicketID]               
AND TD.ProjectID=@ProjectID AND TD.IsDeleted=0;              
              
MERGE [AVL].[TK_TRN_Multilingual_TranslatedInfraTicketDetails] AS TARGET              
USING #MultilingualInfraTbl2 AS SOURCE              
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
TARGET.ModifiedBy=@UserID,              
TARGET.ModifiedDate=GETDATE()              
WHEN NOT MATCHED BY TARGET               
THEN               
INSERT (TimeTickerID,IsTicketDescriptionUpdated,IsResolutionRemarksUpdated,IsTicketSummaryUpdated,              
IsCommentsUpdated,IsFlexField1Updated,IsFlexField2Updated,IsFlexField3Updated,IsFlexField4Updated,              
IsCategoryUpdated,IsTypeUpdated,Isdeleted,CreatedBy,CreatedDate )               
VALUES (SOURCE.TimeTickerID,SOURCE.IsTicketDescriptionModified,SOURCE.IsResolutionRemarksModified,              
SOURCE.IsTicketSummaryModified,SOURCE.IsCommentsModified,SOURCE.IsFlexField1Modified,              
SOURCE.IsFlexField2Modified,SOURCE.IsFlexField3Modified,SOURCE.IsFlexField4Modified,              
SOURCE.IsCategoryModified,SOURCE.IsTypeModified,0,@UserID,GETDATE());              
              
UPDATE MLV SET              
MLV.TicketDescription = (CASE WHEN ISNULL(TD.TicketDescription,'') = '' THEN TD.TicketDescription ELSE MLV.TicketDescription END),              
MLV.ResolutionRemarks =(CASE WHEN ISNULL(TD.ResolutionRemarks,'') = '' THEN TD.ResolutionRemarks ELSE MLV.ResolutionRemarks END),              
MLV.TicketSummary =(CASE WHEN ISNULL(TD.TicketSummary,'') = '' THEN TD.TicketSummary ELSE MLV.TicketSummary END),              
MLV.Comments =(CASE WHEN ISNULL(TD.Comments,'') = '' THEN TD.Comments ELSE MLV.Comments END),              
MLV.FlexField1 =(CASE WHEN ISNULL(TD.FlexField1,'') = '' THEN TD.FlexField1 ELSE MLV.FlexField1 END),              
MLV.FlexField2 =(CASE WHEN ISNULL(TD.FlexField2,'') = '' THEN TD.FlexField2 ELSE MLV.FlexField2 END),              
MLV.FlexField3 =(CASE WHEN ISNULL(TD.FlexField3,'') = '' THEN TD.FlexField3 ELSE MLV.FlexField3 END),              
MLV.FlexField4 =(CASE WHEN ISNULL(TD.FlexField4,'') = '' THEN TD.FlexField4 ELSE MLV.FlexField4 END)              
FROM [AVL].[TK_TRN_Multilingual_TranslatedInfraTicketDetails] MLV              
INNER JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK)  TD ON TD.TimeTickerID = MLV.TimeTickerID              
INNER JOIN #MultilingualInfraTbl2(NOLOCK) MTD ON MTD.TimeTickerID = TD.TimeTickerID              
WHERE TD.ProjectID = @ProjectID              
              
END              
              
END              
END              
IF OBJECT_ID('tempdb..#Columns', 'U') IS NOT NULL              
BEGIN              
    DROP TABLE #Columns              
END              
IF OBJECT_ID('tempdb..#MultilingualInfraTbl2', 'U') IS NOT NULL              
BEGIN              
    DROP TABLE #MultilingualInfraTbl2              
END              
IF OBJECT_ID('tempdb..#MultilingualTbl2', 'U') IS NOT NULL              
BEGIN              
    DROP TABLE #MultilingualTbl2              
END              
              
  /*************************************************************************/              
                 
SET NOCOUNT OFF;                 
COMMIT TRAN                 
END TRY                
BEGIN CATCH                
              
        DECLARE @ErrorMessage VARCHAR(MAX);              
              
        SELECT @ErrorMessage = ERROR_MESSAGE()              
        ROLLBACK TRAN              
        --INSERT Error                  
        EXEC AVL_InsertError '[AVL].[TK_SaveAttributeDetails]  ', @ErrorMessage, @UserID,0              
                      
    END CATCH                
              
END
