/***************************************************************************        
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET        
*Copyright [2018] – [2021] Cognizant. All rights reserved.        
*NOTICE: This unpublished material is proprietary to Cognizant and        
*its suppliers, if any. The methods, techniques and technical        
  concepts herein are considered Cognizant confidential and/or trade secret information.         
          
*This material may be covered by U.S. and/or foreign patents or patent applications.         
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.        
***************************************************************************/        
        
CREATE PROCEDURE [AVL].[SaveTicketDetails]             
--'sing_02',43472,146918,'2155552','09/01/2022 11:40:18 PM',19351,5642,'',0,10807,8,8143537,1,8732,'04/09/2022','10/09/2022',null,1,0,3551,'7 eleven'            
            
 @TicketID nvarchar(50),             
 @ApplicationID bigint,            
 @ProjectID bigint,            
 @EmployeeID nvarchar(50),            
 @OpenDate datetime,            
 @TicketTypeID bigint,            
 @PriorityID bigint,            
 @TicketDescription nvarchar(max),            
 @IsSDTicket bit,            
 @TicketStatus bigint,            
 @DartStatusID bigint,            
 @UserID bigint,            
 @IsCognizant int =NULL,            
 @CustomerID bigint,            
 @FirstDateOfWeek varchar(30)=null,            
 @LastDateOfWeek varchar(30)=null,            
 @mticketdescription varchar(MAx)= null,            
 @SupportTypeID int=null,            
 @TowerID int=null,            
 @AssignmentGroupID int=null,            
 @AssignmentGroup nvarchar(max)=''            
            
AS            
BEGIN         
SET NOCOUNT ON;            
BEGIN TRY            
        
--BEGIN TRAN            
Declare @ispartiallyautomated int=NULL;            
set @ispartiallyautomated =2            
            
--      
    declare @DDClassifiedDate datetime                              
    declare @IsAutoClassified varchar(2)                              
    declare @IsDDAutoClassified varchar(2)                              
    declare @MLSignOffDate datetime                 
   -- declare @mode varchar(100)='Add'      
      
 DECLARE @ApplicationName varchar(200);      
 DECLARE @AutoClassificationType TINYINT;      
 DECLARE @AutoClassificationMode bit;      
      
 SET @ApplicationName= (SELECT ApplicationName FROM [AVL].[APP_MAS_ApplicationDetails] WHERE ApplicationId=@ApplicationID)      
 DECLARE @autoClassifiedField TABLE      
 (      
 IsAutoClassified VARCHAR(2),      
 AutoClassificationDate DATETIME,      
 IsDDAutoClassified VARCHAR(2),      
 DDClassifiedDate VARCHAR(2),      
 IsAutoClassifiedInfra VARCHAR(2),      
 AutoClassificationDateInfra DATETIME,      
 IsDDAutoClassifiedInfra VARCHAR(2),      
 DDAutoClassifiedDateInfra VARCHAR(2)      
 );      
    INSERT INTO @autoClassifiedField EXEC debt_getautoclassifiedfieldforsharepathchange @ProjectID      
      
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
    --      
            
            
if(@IsSDTicket=1)            
 BEGIN            
 Declare @AppTicketID nvarchar(max)            
 Declare @tempTicket table            
 (            
 Ticketid nvarchar(max)            
 )            
            
 insert into @tempTicket            
 exec [AVL].[Effort_GetTicketIdByAccount] @CustomerID             
            
 set @AppTicketID=(select Ticketid from @tempTicket)            
  set @TicketID=@AppTicketID       
        
 If LTRIM(RTRIM(@AppTicketID)) != ''            
 BEGIN            
  IF @SupportTypeID =1            
  BEGIN            
            
   INSERT INTO [AVL].[TK_TRN_TicketDetail] (TicketID,ApplicationID,ProjectID,AssignedTo,DARTStatusID,EffortTillDate,ServiceID,IsDeleted,CreatedDate,OpenDateTime,TicketCreateDate,            
   TicketTypeMapID,PriorityMapID,TicketStatusMapID,TicketDescription,IsSDTicket,CreatedBy,LastUpdatedDate,ModifiedBy,ModifiedDate,IsManual,AssignmentGroup,AssignmentGroupID,InitiatedSource,IsPartiallyAutomated)             
   values (@AppTicketID,@ApplicationID,@ProjectID,@UserID,@DARTStatusID,'0.00',0,0,GETDATE(),ISNULL(@OpenDate,GETDATE()),GETDATE(),            
   @TicketTypeID,@PriorityID,@TicketStatus,@TicketDescription,@IsSDTicket,@EmployeeID,getdate(),@EmployeeID,getdate(),1,@AssignmentGroup,@AssignmentGroupID,1,@ispartiallyautomated)            
            
 END            
 ELSE            
  BEGIN            
   INSERT INTO [AVL].[TK_TRN_InfraTicketDetail] (TicketID,ProjectID,AssignedTo,DARTStatusID,EffortTillDate,ServiceID,IsDeleted,CreatedDate,OpenDateTime,TicketCreateDate,            
   TicketTypeMapID,PriorityMapID,TicketStatusMapID,TicketDescription,IsSDTicket,CreatedBy,LastUpdatedDate,ModifiedBy,ModifiedDate,IsManual,AssignmentGroupID,AssignmentGroup,InitiatedSource,TowerID,IsPartiallyAutomated)             
   values (@AppTicketID,@ProjectID,@UserID,@DARTStatusID,'0.00',0,0,GETDATE(),ISNULL(@OpenDate,GETDATE()),GETDATE(),            
   @TicketTypeID,@PriorityID,@TicketStatus,@TicketDescription,@IsSDTicket,@EmployeeID,getdate(),@EmployeeID,getdate(),1,@AssignmentGroupID,@AssignmentGroup,1,@TowerID,@ispartiallyautomated)            
            
  END           
    --Single Autoclassification Starts     
IF(@IsCognizant=0)    
BEGIN    
 IF(@AppAlgorithmKey='AL001' OR @InfraAlgorithmKey='AL001')                
 BEGIN       
  IF (@SupportTypeID =1 AND @AppAlgorithmKey='AL001')    
  BEGIN          
   INSERT into AVL.TK_ProjectForMLClassification (ProjectID,EmployeeID,IsAutoClassified,IsDDAutoClassified,DDAutoClassificationDate,AutoClassificationDate,CreatedBy,        
     CreatedDate,IsAutoClassifiedInfra,IsDDAutoClassifiedInfra,DDAutoClassificationDateInfra,AutoClassificationDateInfra)        
    (SELECT @ProjectID,@EmployeeID,IsAutoClassified,IsDDAutoClassified,DDClassifiedDate,AutoClassificationDate,@UserID,GETDATE(),IsAutoClassifiedInfra,   
 IsDDAutoClassifiedInfra,DDAutoClassifiedDateInfra,AutoClassificationDateInfra FROM @autoClassifiedField)      
     --AUTOCLASSIFICATION TYPE BASED      
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
    INSERT INTO AVL.TK_MLClassification_TicketUpload      
    select @AppTicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',null,null,null,null,null,null,null,null,null,null,null,0,      
    @EmployeeID,'',null,1,null,null,null,null where @DartStatusID=8 OR @DartStatusID=9      
    END      
    ELSE IF (@AutoClassificationType=2)              
   BEGIN              
      IF(@AutoClassificationMode = 1)              
      BEGIN              
    INSERT into AVL.TK_MLClassification_TicketUpload                
    SELECT @AppTicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',NULL,NULL,                
    NULL,NULL,null,null,null,null,null,null,NULL,0,@EmployeeID,'',NULL,1,                
    null,null,null,null where @DartStatusID=8 OR @DartStatusID=9 AND @TicketDescription IS NOT NULL AND @TicketDescription <> ''              
      END              
      ELSE IF (@AutoClassificationMode = 0)              
      BEGIN              
    INSERT into AVL.TK_MLClassification_TicketUpload                
    SELECT @AppTicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',NULL,NULL,                
    NULL,NULL,null,null,null,null,null,null,NULL,0,@EmployeeID,'',NULL,1,              
    null,null,null,null where @DartStatusID=8 OR @DartStatusID=9 --AND      
    --[TicketDescriptionBasePattern] IS NOT NULL AND [TicketDescriptionBasePattern] <> ''              
    --AND [TicketDescriptionBasePattern] <> '0'              
      END          
   END      
  END      
  ELSE IF(@SupportTypeID=2 AND @InfraAlgorithmKey='AL001')    
  BEGIN    
   INSERT into AVL.TK_ProjectForMLClassification (ProjectID,EmployeeID,IsAutoClassified,IsDDAutoClassified,DDAutoClassificationDate,AutoClassificationDate,CreatedBy,        
    CreatedDate,IsAutoClassifiedInfra,IsDDAutoClassifiedInfra,DDAutoClassificationDateInfra,AutoClassificationDateInfra)        
   (SELECT @ProjectID,@EmployeeID,IsAutoClassified,IsDDAutoClassified,DDClassifiedDate,AutoClassificationDate,@UserID,GETDATE(),IsAutoClassifiedInfra, IsDDAutoClassifiedInfra,DDAutoClassifiedDateInfra,AutoClassificationDateInfra FROM @autoClassifiedField
)  
    
      
  --AUTOCLASSIFICATION TYPE BASED      
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
    INSERT INTO AVL.TK_MLClassification_TicketUpload      
    select @AppTicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',null,null,null,null,null,null,null,null,null,null,null,0,      
    @EmployeeID,'',@TowerID,2,null,null,null,null where @DartStatusID=8 OR @DartStatusID=9      
    END      
    ELSE IF (@AutoClassificationType=2)              
   BEGIN              
      IF(@AutoClassificationMode = 1)              
      BEGIN              
    INSERT into AVL.TK_MLClassification_TicketUpload                
    SELECT @AppTicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',NULL,NULL,                
    NULL,NULL,null,null,null,null,null,null,NULL,0,@EmployeeID,'',@TowerID,2,                
    null,null,null,null where @DartStatusID=8 OR @DartStatusID=9 AND @TicketDescription IS NOT NULL AND @TicketDescription <> ''              
      END              
      ELSE IF (@AutoClassificationMode = 0)              
      BEGIN              
    INSERT into AVL.TK_MLClassification_TicketUpload                
    SELECT @AppTicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',NULL,NULL,                
    NULL,NULL,null,null,null,null,null,null,NULL,0,@EmployeeID,'',@TowerID,2,              
    null,null,null,null where @DartStatusID=8 OR @DartStatusID=9       
      END          
   END      
      
      
  END      
 END      
 IF(@AppAlgorithmKey='AL002' OR @InfraAlgorithmKey='AL002')    
 BEGIN      
    Select @IsAutoClassified=IsAutoClassified , @MLSignOffDate=MLSignOffDate, @IsDDAutoClassified = IsDDAutoClassified, @DDClassifiedDate =IsDDAutoClassifiedDate  from AVL.MAS_ProjectDebtDetails (NOLOCK) where ProjectID = @ProjectId and IsDeleted = 0    
   
    
                     
   SET @IsDDAutoClassified = CASE WHEN (@DDClassifiedDate<= getdate() AND @IsDDAutoClassified='Y') THEN 'Y' ELSE 'N' END                              
   SET @IsAutoClassified = CASE WHEN (@MLSignOffDate<= getdate() AND @IsAutoClassified='Y') THEN 'Y' ELSE 'N' END      
    IF(@IsDDAutoClassified<>'N' OR     @IsAutoClassified<>'N' )      
 BEGIN    
   INSERT INTO ML.AutoClassificationBatchProcess([ProjectId],[EmployeeID],[IsAutoClassified],[IsDDAutoClassified],[AlgorithmKey],[StatusId],                        
  [IsDeleted],[CreatedBy],[CreatedDate])                        
  values( @projectid,@EmployeeID,@IsAutoClassified,@IsDDAutoClassified,'AL002',13 ,0,@EmployeeID,GETDATE())       
   --tickets for auto Classification insert mode--      
  IF(@SupportTypeID=1 AND @AppAlgorithmKey='AL002')    
  BEGIN    
  INSERT INTO ML.TicketsforAutoClassification                        
  ([BatchProcessId],[TicketId],[TicketDescription],[AssignmentGroupId],[Category],                        
  [TicketSourceMapID],[TicketTypeMapID],[TicketSummary],                        
  [ReleaseTypeMapID],[StatusId],[IsDeleted],[CreatedBy],[CreatedDate],[ModifiedBy],[SupportType],[ApplicationId]                        
  ) values(                   
  (SELECT max([BatchProcessId]) FROM ML.AutoClassificationBatchProcess WHERE ProjectId=@projectid), @AppTicketID ,@TicketDescription,@AssignmentGroupID,null,NULL,@TicketTypeID,null,null,13,0,@EmployeeID,GETDATE(),null,1,@ApplicationID  )            
   END    
   ELSE IF(@SupportTypeID=2 AND @InfraAlgorithmKey='AL002')    
   BEGIN    
   --Infra--                              
                         
  INSERT INTO ML.TicketsforAutoClassification                        
  ([BatchProcessId],[TicketId],[TicketDescription],[AssignmentGroupId],[Category],[TicketSourceMapID],[TicketTypeMapID],[TicketSummary],                       
  [ReleaseTypeMapID],[StatusId],[IsDeleted],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[SupportType],[TowerId]                        
  )                        
  Values ((SELECT max([BatchProcessId]) FROM ML.AutoClassificationBatchProcess WHERE ProjectId=@projectid) ,@AppTicketID,@TicketDescription,@AssignmentGroupID,null,null,@TicketTypeID,null,null,13,0,@EmployeeID,GETDATE(),null,null,2,@TowerID )       
 END      
 END    
 END    
END    
 --Single Autoclassification Ends      
 END            
 end            
 ELSE            
 BEGIN            
 If LTRIM(RTRIM(@TicketID)) != ''            
 BEGIN            
 IF @SupportTypeID =1            
  BEGIN            
  INSERT INTO [AVL].[TK_TRN_TicketDetail] (TicketID,ApplicationID,ProjectID,AssignedTo,DARTStatusID,EffortTillDate,ServiceID,IsDeleted,CreatedDate,OpenDateTime,TicketCreateDate,            
  TicketTypeMapID,PriorityMapID,TicketStatusMapID,TicketDescription,IsSDTicket,CreatedBy,LastUpdatedDate,ModifiedBy,ModifiedDate,IsManual,AssignmentGroupID,AssignmentGroup,InitiatedSource,IsPartiallyAutomated)             
  values (@TicketID,@ApplicationID,@ProjectID,@UserID,@DARTStatusID,'0.00',0,0,GETDATE(),ISNULL(@OpenDate,GETDATE()),GETDATE(),            
  @TicketTypeID,@PriorityID,@TicketStatus,@TicketDescription,@IsSDTicket,@EmployeeID,getdate(),@EmployeeID,getdate(),1,@AssignmentGroupID,@AssignmentGroup,1,@ispartiallyautomated)            
 END            
 ELSE            
  BEGIN            
   INSERT INTO [AVL].[TK_TRN_InfraTicketDetail] (TicketID,ProjectID,AssignedTo,DARTStatusID,EffortTillDate,ServiceID,IsDeleted,CreatedDate,OpenDateTime,TicketCreateDate,            
   TicketTypeMapID,PriorityMapID,TicketStatusMapID,TicketDescription,IsSDTicket,CreatedBy,LastUpdatedDate,ModifiedBy,ModifiedDate,IsManual,AssignmentGroupID,AssignmentGroup,InitiatedSource,TowerID,IsPartiallyAutomated)             
   values (@TicketID,@ProjectID,@UserID,@DARTStatusID,'0.00',0,0,GETDATE(),ISNULL(@OpenDate,GETDATE()),GETDATE(),            
   @TicketTypeID,@PriorityID,@TicketStatus,@TicketDescription,@IsSDTicket,@EmployeeID,getdate(),@EmployeeID,getdate(),1,@AssignmentGroupID,@AssignmentGroup,1,@TowerID,@ispartiallyautomated)            
            
  END         
  --Single Autoclassification Starts      
 IF(@IsCognizant=0)    
 BEGIN    
 IF(@AppAlgorithmKey='AL001' OR @InfraAlgorithmKey='AL001')                
 BEGIN       
  IF (@SupportTypeID =1 AND @AppAlgorithmKey='AL001')    
  BEGIN          
   INSERT into AVL.TK_ProjectForMLClassification (ProjectID,EmployeeID,IsAutoClassified,IsDDAutoClassified,DDAutoClassificationDate,AutoClassificationDate,CreatedBy,        
     CreatedDate,IsAutoClassifiedInfra,IsDDAutoClassifiedInfra,DDAutoClassificationDateInfra,AutoClassificationDateInfra)        
    (SELECT @ProjectID,@EmployeeID,IsAutoClassified,IsDDAutoClassified,DDClassifiedDate,AutoClassificationDate,@UserID,GETDATE(),IsAutoClassifiedInfra, IsDDAutoClassifiedInfra,DDAutoClassifiedDateInfra,AutoClassificationDateInfra FROM @autoClassifiedField
  
    
)      
     --AUTOCLASSIFICATION TYPE BASED      
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
    INSERT INTO AVL.TK_MLClassification_TicketUpload      
    select @TicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',null,null,null,null,null,null,null,null,null,null,null,0,      
    @EmployeeID,'',null,1,null,null,null,null where @DartStatusID=8 OR @DartStatusID=9      
    END      
    ELSE IF (@AutoClassificationType=2)              
   BEGIN              
      IF(@AutoClassificationMode = 1)              
      BEGIN              
    INSERT into AVL.TK_MLClassification_TicketUpload                
    SELECT @TicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',NULL,NULL,                
    NULL,NULL,null,null,null,null,null,null,NULL,0,@EmployeeID,'',NULL,1,                
    null,null,null,null where @DartStatusID=8 OR @DartStatusID=9 --AND @TicketDescription IS NOT NULL AND @TicketDescription <> ''              
      END              
      ELSE IF (@AutoClassificationMode = 0)              
      BEGIN              
    INSERT into AVL.TK_MLClassification_TicketUpload                
    SELECT @TicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',NULL,NULL,                
    NULL,NULL,null,null,null,null,null,null,NULL,0,@EmployeeID,'',NULL,1,              
    null,null,null,null where @DartStatusID=8 OR @DartStatusID=9 --AND      
    --[TicketDescriptionBasePattern] IS NOT NULL AND [TicketDescriptionBasePattern] <> ''              
    --AND [TicketDescriptionBasePattern] <> '0'              
      END          
   END      
  END      
  ELSE IF(@SupportTypeID=2 AND @InfraAlgorithmKey='AL001')    
  BEGIN      
   INSERT into AVL.TK_ProjectForMLClassification (ProjectID,EmployeeID,IsAutoClassified,IsDDAutoClassified,DDAutoClassificationDate,AutoClassificationDate,CreatedBy,        
    CreatedDate,IsAutoClassifiedInfra,IsDDAutoClassifiedInfra,DDAutoClassificationDateInfra,AutoClassificationDateInfra)        
   (SELECT @ProjectID,@EmployeeID,IsAutoClassified,IsDDAutoClassified,DDClassifiedDate,AutoClassificationDate,@UserID,GETDATE(),IsAutoClassifiedInfra, IsDDAutoClassifiedInfra,DDAutoClassifiedDateInfra,AutoClassificationDateInfra FROM @autoClassifiedField)
  
    
      
  --AUTOCLASSIFICATION TYPE BASED      
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
    INSERT INTO AVL.TK_MLClassification_TicketUpload      
    select @TicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',null,null,null,null,null,null,null,null,null,null,null,0,      
    @EmployeeID,'',@TowerID,2,null,null,null,null where @DartStatusID=8 OR @DartStatusID=9      
    END      
    ELSE IF (@AutoClassificationType=2)              
   BEGIN              
      IF(@AutoClassificationMode = 1)              
      BEGIN              
    INSERT into AVL.TK_MLClassification_TicketUpload                
    SELECT @TicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',NULL,NULL,                
    NULL,NULL,null,null,null,null,null,null,NULL,0,@EmployeeID,'',@TowerID,2,                
    null,null,null,null where @DartStatusID=8 OR @DartStatusID=9 AND @TicketDescription IS NOT NULL AND @TicketDescription <> ''              
      END              
      ELSE IF (@AutoClassificationMode = 0)              
      BEGIN              
    INSERT into AVL.TK_MLClassification_TicketUpload                
    SELECT @TicketID,@ProjectID,@ApplicationID,@ApplicationName,@TicketDescription,'',NULL,NULL,                
    NULL,NULL,null,null,null,null,null,null,NULL,0,@EmployeeID,'',@TowerID,2,              
    null,null,null,null where @DartStatusID=8 OR @DartStatusID=9       
      END          
   END      
      
      
  END      
 END      
 ELSE IF(@AppAlgorithmKey='AL002' OR @InfraAlgorithmKey='AL002')       
 BEGIN      
        
      
    Select @IsAutoClassified=IsAutoClassified , @MLSignOffDate=MLSignOffDate, @IsDDAutoClassified = IsDDAutoClassified, @DDClassifiedDate =IsDDAutoClassifiedDate  from AVL.MAS_ProjectDebtDetails (NOLOCK) where ProjectID = @ProjectId and IsDeleted = 0     
  
    
                     
   SET @IsDDAutoClassified = CASE WHEN (@DDClassifiedDate<= getdate() AND @IsDDAutoClassified='Y') THEN 'Y' ELSE 'N' END                              
   SET @IsAutoClassified = CASE WHEN (@MLSignOffDate<= getdate() AND @IsAutoClassified='Y') THEN 'Y' ELSE 'N' END      
    IF(@IsDDAutoClassified<>'N' OR     @IsAutoClassified<>'N' )      
 BEGIN    
   INSERT INTO ML.AutoClassificationBatchProcess([ProjectId],[EmployeeID],[IsAutoClassified],[IsDDAutoClassified],[AlgorithmKey],[StatusId],                        
  [IsDeleted],[CreatedBy],[CreatedDate])                        
  values( @projectid,@EmployeeID,@IsAutoClassified,@IsDDAutoClassified,'AL002',13 ,0,@EmployeeID,GETDATE())       
     
   --tickets for auto Classification insert mode--          
 IF(@SupportTypeID=1 AND @AppAlgorithmKey='AL002')    
 BEGIN    
  INSERT INTO ML.TicketsforAutoClassification                        
  ([BatchProcessId],[TicketId],[TicketDescription],[AssignmentGroupId],[Category],                        
  [TicketSourceMapID],[TicketTypeMapID],[TicketSummary],                        
  [ReleaseTypeMapID],[StatusId],[IsDeleted],[CreatedBy],[CreatedDate],[ModifiedBy],[SupportType],[ApplicationId]                        
  ) values(                   
  (SELECT max([BatchProcessId]) FROM ML.AutoClassificationBatchProcess WHERE ProjectId=@projectid), @TicketID ,@TicketDescription,@AssignmentGroupID,null,NULL,@TicketTypeID,null,null,13,0,@EmployeeID,GETDATE(),null,1,@ApplicationID  )            
 END    
 ELSE IF(@SupportTypeID=2 AND @InfraAlgorithmKey='AL002')    
 BEGIN    
   --Infra--                              
                         
  INSERT INTO ML.TicketsforAutoClassification                        
  ([BatchProcessId],[TicketId],[TicketDescription],[AssignmentGroupId],[Category],[TicketSourceMapID],[TicketTypeMapID],[TicketSummary],                       
  [ReleaseTypeMapID],[StatusId],[IsDeleted],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[SupportType],[TowerId]                        
  )                        
  Values ((SELECT max([BatchProcessId]) FROM ML.AutoClassificationBatchProcess WHERE ProjectId=@projectid) ,@TicketID,@TicketDescription,@AssignmentGroupID,null,null,@TicketTypeID,null,null,13,0,@EmployeeID,GETDATE(),null,null,2,@TowerID )       
 END      
 END    
 END    
 END    
 --Single Autoclassification Ends      
 END            
 ELSE            
 BEGIN            
            
 EXEC AVL_InsertError 'Null Ticket', @TicketID, @ProjectID,@EmployeeID            
              
 END            
 END          
            
            
  DECLARE @Servicecount INT            
  SET @Servicecount=0;            
            
             
CREATE TABLE #UserProjectDetails            
    (            
    SNO INT IDENTITY(1,1),            
    UserID BigINT,            
      ProjectID BigINT            
               
     )            
            
;WITH MYCTE AS            
      (            
      SELECT UserID,ProjectID FROM [AVL].[MAS_LoginMaster](NOLOCK) WHERE EmployeeID = @EmployeeID and CustomerID=@CustomerID AND IsDeleted=0            
      )            
                  
            INSERT INTO #UserProjectDetails            
            SELECT UserID,ProjectID            
            FROM    MYCTE             
            OPTION (MAXRECURSION 0)            
            
            
   CREATE TABLE #SelectedTickets            
   (            
   SNO INT IDENTITY(1,1),            
     TimeTickerID bigint,            
     TicketID nvarchar(50),            
     ProjectID Bigint,            
     ApplicationID Bigint            
     )            
     IF @SupportTypeID=1            
      BEGIN            
      WITH MYCTE AS            
      (            
      SELECT TD.TimeTickerID,TD.TicketID,TD.ProjectID,TD.ApplicationID from [AVL].[TK_TRN_TicketDetail] TD (NOLOCK)            
                
      where TD.Projectid=@ProjectID and TD.TicketID= @TicketID AND TD.ApplicationID=@ApplicationID            
      )            
       INSERT INTO #SelectedTickets            
      SELECT  TimeTickerID ,   TicketID ,  ProjectID ,ApplicationID            
      FROM    MYCTE             
      OPTION (MAXRECURSION 0)            
     END            
    ELSE            
     BEGIN            
      ;WITH MYCTE AS            
        (            
       SELECT TD.TimeTickerID,TD.TicketID,TD.ProjectID,TD.TowerID from [AVL].[TK_TRN_InfraTicketDetail] TD (NOLOCK)            
                
       where TD.Projectid=@ProjectID and TD.TicketID= @TicketID AND TD.TowerID=@TowerID            
        )            
        INSERT INTO #SelectedTickets            
        SELECT  TimeTickerID ,   TicketID ,  ProjectID ,TowerID            
        FROM    MYCTE             
        OPTION (MAXRECURSION 0)            
     END            
            
   CREATE TABLE #EFFORTDATES            
   (            
   SNO INT IDENTITY(1,1),            
   DATETODAY DATE,            
   NAME VARCHAR(50),            
   FreezeStatus NVARCHAR(50)            
   )            
            
  ;WITH MYCTE AS            
     (            
    SELECT CAST(@FirstDateOfWeek AS DATETIME) DATEVALUE            
    UNION ALL            
    SELECT  DATEVALUE + 1            
    FROM    MYCTE               
    WHERE   DATEVALUE + 1 <= @LastDateOfWeek            
     )            
                 
     INSERT INTO #EFFORTDATES            
     SELECT  CONVERT(DATE,DATEVALUE) AS DATETODAY , DATENAME(W,DATEVALUE) AS NAME,''            
     FROM    MYCTE             
     OPTION (MAXRECURSION 0)            
            
     SELECT C.CustomerId      AS CustomerId,PM.ProjectID,            
       ISNULL(CASE WHEN C.IsCognizant='0' THEN 0 ELSE 1 END,1)   AS IsCustomer,            
       ISNULL(CASE WHEN C.IsCognizant='0' THEN 0 ELSE 1 END,1)   AS IsCognizant,            
       ISNULL(C.IsEffortConfigured,0)  AS IsEfforTracked,            
       ISNULL(CASE WHEN PM.IsDebtEnabled='Y' THEN 1 ELSE 0 END,0)   AS IsDebtEnabled,            
       ISNULL(CASE WHEN PM.IsMainspringConfigured='Y' THEN 1 ELSE 0 END,0) AS IsMainSpringConfigured,            
       IsDaily,TM.TZoneName AS ProjectTimeZoneName Into #ConfigTemp            
       FROM AVL.Customer C ( NOLOCK )             
       INNER JOIN AVL.MAS_ProjectMaster PM ( NOLOCK )             
       ON C.CustomerID=PM.CustomerID  AND PM.IsDeleted = 0            
            
       LEFT JOIN AVL.MAP_ProjectConfig PC ( NOLOCK ) ON PM.ProjectID=PC.ProjectID            
       LEFT JOIN AVL.MAS_TimeZoneMaster TM ( NOLOCK ) ON ISNULL(PC.TimeZoneId,32)=TM.TimeZoneID            
       WHERE C.CustomerID=@CustomerID and PM.ProjectID=@ProjectID AND C.IsDeleted = 0            
                   
    Select TimesheetId,TimesheetDate,StatusId INTO #TimesheetTemp FROM AVL.TM_PRJ_Timesheet(NOLOCK)             
       where TimesheetDate >= @FirstDateOfWeek AND TimesheetDate  <= @LastDateOfWeek AND CustomerID =@CustomerID             
     AND SubmitterId In(SELECT userid from #UserProjectDetails(NOLOCK))            
   CREATE TABLE #AddTicketTemp            
   (            
   CustomerID BIGINT NOT NULL,            
   ProjectID BIGINT  NULL,             
   ApplicationID BIGINT  NULL,             
   TicketID NVARCHAR(100) NULL,            
   AssignedTo BIGINT  NULL,             
   TimeTickerID BIGINT  NULL,             
    IsNonTicket INT NULL,            
   IsCustomer INT NULL,            
   IsEfforTracked INT NULL,            
   IsDebtEnabled INT NULL,            
   IsMainSpringConfigured INT NULL,            
    ActivityId BIGINT  NULL,             
   ProjectTimeZoneName NVARCHAR(100) NULL,            
    UserTimeZoneName NVARCHAR(100) NULL,            
   TowerID BIGINT  NULL,             
   ClosedDate DATETIME NULL,            
   CompletedDate DATETIME NULL            
   )            
   CREATE TABLE #EffortEntryDataTemp            
   (            
   TimesheetId BIGINT  NULL,            
   TimesheetDate DATE NULL,            
   TimeSheetDetailId BIGINT  NULL,            
   TimeTickerID BIGINT  NULL,            
   TicketID NVARCHAR(100) NULL,            
   ApplicationID BIGINT  NULL,            
   ProjectID BIGINT  NULL,             
   AssignedTo BIGINT  NULL,            
   EffortTillDate DECIMAL(5,2) NULL,            
   Effort  DECIMAL(5,2) NULL,            
   ServiceID INT NULL,            
   TicketDescription NVARCHAR(MAX) NULL,            
   IsDeleted INT NULL,             
   TicketStatusMapID BIGINT  NULL,             
   TicketTypeMapID BIGINT  NULL,             
   IsSDTicket INT NULL,             
   DARTStatusID INT NULL,             
   ITSMEffort  DECIMAL(25,2) NULL,            
   IsNonTicket INT NULL,            
   IsCustomer INT NULL,            
   IsEfforTracked INT NULL,            
   IsDebtEnabled INT NULL,            
   IsMainSpringConfigured INT NULL,            
   ISTicket INT NULL,            
   ActivityId INT NULL,            
    ProjectTimeZoneName NVARCHAR(100) NULL,            
    UserTimeZoneName NVARCHAR(100) NULL,            
   TowerID BIGINT  NULL,            
   ClosedDate DATETIME NULL,            
   CompletedDate DATETIME NULL            
   )            
   IF @SupportTypeID =1            
   BEGIN            
   INSERT INTO #AddTicketTemp             
   select distinct PM.CustomerID,TD.ProjectID, TD.ApplicationID,TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket            
   ,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,            
   CT.ProjectTimeZoneName AS ProjectTimeZoneName,TM.TZoneName AS UserTimeZoneName,0 AS TowerID,TD.ClosedDate AS ClosedDate,            
   TD.CompletedDateTime AS CompletedDate            
               
   from [AVL].[TK_TRN_TicketDetail] TD (NOLOCK)            
   INNER JOIN [AVL].[MAS_ProjectMaster] PM (NOLOCK) ON PM.CustomerID=@CustomerID and PM.ProjectID=@ProjectID AND PM.IsDeleted = 0            
   INNER JOIN [AVL].[BusinessClusterMapping] BCM (NOLOCK) ON  BCM.CustomerId=@CustomerID            
   INNER JOIN [AVL].[APP_MAS_ApplicationDetails] AD (NOLOCK) ON AD.SubBusinessClusterMapID=BCM.BusinessClusterMapID            
   INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping] APM (NOLOCK)  ON APM.ApplicationID=AD.ApplicationID and APM.ProjectID=PM.ProjectID            
              
   INNER JOIN #ConfigTemp CT (NOLOCK) ON CT.CustomerId=@CustomerID and CT.ProjectID=TD.ProjectId            
   INNER JOIN #SelectedTickets ST (NOLOCK) ON ST.TimeTickerID=TD.TimeTickerID AND ST.ProjectID=@ProjectID            
   LEFT JOIN AVL.MAS_LoginMaster LM  (NOLOCK) ON TD.ProjectID=LM.ProjectID AND LM.EmployeeID=@EmployeeID AND LM.IsDeleted = 0            
   LEFT JOIN AVL.MAS_TimeZoneMaster TM (NOLOCK) ON LM.TimeZoneId=TM.TimeZoneID            
   WHERE  TD.ProjectID = @ProjectID            
            
   INSERT INTO #EffortEntryDataTemp             
   Select null as TimesheetId, cast(null as date) as TimesheetDate,NULL AS TimeSheetDetailId, TD.TimeTickerID, TD.TicketID, TD.ApplicationID,             
   TD.ProjectID, TD.AssignedTo,            
   TD.EffortTillDate,0 As Effort ,TD.ServiceID AS ServiceID, TD.TicketDescription, TD.IsDeleted, TD.TicketStatusMapID, TD.TicketTypeMapID,             
   TD.IsSDTicket,  TD.DARTStatusID, TD.ITSMEffort, ATT.IsNonTicket,            
   ATT.IsCustomer,ATT.IsEfforTracked,ATT.IsDebtEnabled,ATT.IsMainSpringConfigured,1 as ISTicket, Null as ActivityId,            
   ATT.ProjectTimeZoneName AS ProjectTimeZoneName,ATT.UserTimeZoneName AS UserTimeZoneName,0 AS TowerID,TD.Closeddate AS ClosedDate,            
   TD.CompletedDateTime AS CompletedDate            
  FROM            
   [AVL].[TK_TRN_TicketDetail] TD (NOLOCK)           
   INNER JOIN  #AddTicketTemp ATT  (NOLOCK)ON ATT.TimeTickerID= TD.TimeTickerID            
   END            
   ELSE            
   BEGIN            
   INSERT INTO #AddTicketTemp             
    select distinct PM.CustomerID,TD.ProjectID,0 AS 'ApplicationID',TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket            
   ,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,            
   CT.ProjectTimeZoneName AS ProjectTimeZoneName,TM.TZoneName AS UserTimeZoneName, TD.TowerID,TD.Closeddate AS ClosedDate,            
   TD.CompletedDateTime AS CompletedDate            
              
   from [AVL].[TK_TRN_InfraTicketDetail] TD (NOLOCK)            
   INNER JOIN [AVL].[MAS_ProjectMaster] PM (NOLOCK)ON PM.CustomerID=@CustomerID and PM.ProjectID=@ProjectID AND PM.Isdeleted = 0            
   INNER JOIN [AVL].InfraTowerDetailsTransaction AD (NOLOCK)ON AD.InfraTowerTransactionID=@TowerID            
   INNER JOIN [AVL].[InfraTowerProjectMapping] APM (NOLOCK) ON APM.TowerID=AD.InfraTowerTransactionID and APM.ProjectID=PM.ProjectID            
   INNER JOIN #ConfigTemp CT (NOLOCK)ON CT.CustomerId=@CustomerID and CT.ProjectID=TD.ProjectId            
   INNER JOIN #SelectedTickets ST (NOLOCK)ON ST.TimeTickerID=TD.TimeTickerID AND ST.ProjectID=@ProjectID            
   LEFT JOIN AVL.MAS_LoginMaster LM (NOLOCK)ON TD.ProjectID=LM.ProjectID AND LM.EmployeeID=@EmployeeID AND LM.IsDeleted = 0            
   LEFT JOIN AVL.MAS_TimeZoneMaster TM (NOLOCK)ON LM.TimeZoneId=TM.TimeZoneID            
   WHERE TD.ProjectID = @ProjectID             
            
   INSERT INTO #EffortEntryDataTemp             
   Select null as TimesheetId, cast(null as date) as TimesheetDate,NULL AS TimeSheetDetailId, TD.TimeTickerID, TD.TicketID,0 AS ApplicationID,            
   TD.ProjectID, TD.AssignedTo,            
   TD.EffortTillDate,0 As Effort ,TD.ServiceID AS ServiceID, TD.TicketDescription, TD.IsDeleted, TD.TicketStatusMapID, TD.TicketTypeMapID,             
   TD.IsSDTicket,  TD.DARTStatusID, TD.ITSMEffort, ATT.IsNonTicket,     
   ATT.IsCustomer,ATT.IsEfforTracked,ATT.IsDebtEnabled,ATT.IsMainSpringConfigured,1 as ISTicket, Null as ActivityId,            
   ATT.ProjectTimeZoneName AS ProjectTimeZoneName,ATT.UserTimeZoneName AS UserTimeZoneName,TD.TowerID,TD.Closeddate AS ClosedDate,            
   TD.CompletedDateTime AS CompletedDate            
   FROM [AVL].TK_TRN_InfraTicketDetail TD (NOLOCK)           
   INNER JOIN  #AddTicketTemp ATT (NOLOCK)ON ATT.TimeTickerID= TD.TimeTickerID            
            
   END            
               
 CREATE TABLE #TimesheetandTimesheetdetailsidTemp            
 (            
 SNO INT ,            
 DATETODAY DATE,            
 TimesheetId Bigint,            
 TimesheetDate DATE,            
 ProjectID Bigint,            
 TimeSheetDetailId Bigint            
 )            
            
 INSERT Into #TimesheetandTimesheetdetailsidTemp            
 SELECT DISTINCT              
 ED.SNO,ED.DATETODAY,TS.TimesheetId,TS.TimesheetDate ,TS.ProjectID,TS.TimeSheetDetailId   From  #EFFORTDATES ED            
 LEFT JOIN #EffortEntryDataTemp TS (NOLOCK)  on TS.TimesheetDate=ED.DATETODAY            
            
  SELECT PVTResult.* INTO #LastTemp From               
  (SELECT TimeTickerID, TicketID, ApplicationID,TowerID, ProjectID, AssignedTo,            
  EffortTillDate,ServiceID, TicketDescription, IsDeleted, TicketStatusMapID,TicketTypeMapID,             
  IsSDTicket,  DARTStatusID, ITSMEffort, IsNonTicket,            
  IsCustomer,IsEfforTracked,IsDebtEnabled,IsMainSpringConfigured, ISTicket ,ActivityId,ProjectTimeZoneName,            
  UserTimeZoneName,            
  [1TimeSheetDetailId]= CASE WHEN p.[1] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,               
  [1] = CASE WHEN p.[1] IS NULL THEN NULL ELSE p.[1] END,            
  [2TimeSheetDetailId]= CASE WHEN p.[2] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,               
  [2] = CASE WHEN p.[2] IS NULL THEN NULL ELSE p.[2] END,             
  [3TimeSheetDetailId]= CASE WHEN p.[3] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,               
  [3] = CASE WHEN p.[3] IS NULL THEN NULL ELSE p.[3] END,              
  [4TimeSheetDetailId]= CASE WHEN p.[4] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,               
  [4] = CASE WHEN p.[4] IS NULL THEN NULL ELSE p.[4] END,              
  [5TimeSheetDetailId]= CASE WHEN p.[5] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,               
  [5] = CASE WHEN p.[5] IS NULL THEN NULL ELSE p.[5] END,              
  [6TimeSheetDetailId]= CASE WHEN p.[6] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,               
  [6] = CASE WHEN p.[6] IS NULL THEN NULL ELSE p.[6] END,              
  [7TimeSheetDetailId]= CASE WHEN p.[7] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,               
  [7] = CASE WHEN p.[7] IS NULL THEN NULL ELSE p.[7] END,            
  ClosedDate,            
  CompletedDate            
  FROM  (SELECT               
  ED.SNO,ED.DATETODAY,TS.TimesheetId,TS.TimesheetDate,TS.TimeSheetDetailId, TS.TimeTickerID, TS.TicketID, TS.ApplicationID,TS.TowerID, TS.ProjectID, TS.AssignedTo,            
  TS.EffortTillDate,TS.Effort ,TS.ServiceID, TS.TicketDescription, TS.IsDeleted, TS.TicketStatusMapID,TS.TicketTypeMapID,             
  TS.IsSDTicket,  TS.DARTStatusID, TS.ITSMEffort, TS.IsNonTicket,            
  TS.IsCustomer,TS.IsEfforTracked,TS.IsDebtEnabled,TS.IsMainSpringConfigured, TS.ISTicket,ActivityId            
  ,TS.ProjectTimeZoneName AS ProjectTimeZoneName,TS.UserTimeZoneName AS UserTimeZoneName,TS.ClosedDate,            
  TS.CompletedDate AS CompletedDate   FROM  #EffortEntryDataTemp(NOLOCK) TS            
  LEFT JOIN #EFFORTDATES ED (NOLOCK)on Ts.TimesheetDate=ED.DATETODAY) s            
  PIVOT(MAX(Effort)            
  FOR s.SNO IN ( [1], [2], [3], [4], [5], [6], [7]) ) p             
  )            
  as PVTResult              
            
  ORDER BY PVTResult.TicketID;            
            
               
 select distinct TimeTickerID, TicketID, ApplicationID,TowerID, ProjectID, AssignedTo,            
 EffortTillDate,ServiceID, TicketDescription, IsDeleted, TicketStatusMapID,TicketTypeMapID,             
 IsSDTicket,  DARTStatusID, ITSMEffort, IsNonTicket,            
 IsCustomer,IsEfforTracked,IsDebtEnabled,IsMainSpringConfigured, ISTicket,ActivityId,            
 ProjectTimeZoneName,UserTimeZoneName,            
 max([1TimeSheetDetailId]) AS [1TimeSheetDetailId],max([1]) AS [1],            
 max([2TimeSheetDetailId]) AS [2TimeSheetDetailId] ,max([2]) AS [2],            
 max([3TimeSheetDetailId]) AS [3TimeSheetDetailId],max([3]) AS [3] ,            
  max([4TimeSheetDetailId]) AS [4TimeSheetDetailId],max([4]) AS [4],            
 max([5TimeSheetDetailId]) AS [5TimeSheetDetailId],max([5]) AS [5] ,            
 max([6TimeSheetDetailId]) AS [6TimeSheetDetailId],max([6]) AS [6],            
 max([7TimeSheetDetailId]) AS [7TimeSheetDetailId],max([7]) AS [7],            
 ClosedDate,CompletedDate            
 Into #FinalTemp from #LastTemp(NOLOCK)            
 GROUP BY TimeTickerID, TicketID, ApplicationID, ProjectID, AssignedTo,            
 EffortTillDate,ServiceID, TicketDescription, IsDeleted, TicketStatusMapID,TicketTypeMapID,             
 IsSDTicket,  DARTStatusID, ITSMEffort, IsNonTicket,            
 IsCustomer,IsEfforTracked,IsDebtEnabled,IsMainSpringConfigured, ISTicket,ActivityId,ProjectTimeZoneName,            
 UserTimeZoneName,TowerID,ClosedDate,CompletedDate            
               
            
            
Select T.TicketID,T.ProjectID,T.IsAttributeUpdated INTO #IsAttributeTemp from [AVL].[TK_TRN_TicketDetail] T (NOLOCK)           
Inner JOIN #FinalTemp F (NOLOCK)ON F.TicketID=T.TicketID and F.ProjectID=T.ProjectID            
            
            
Select  FT.TimeTickerID, FT.TicketID, FT.ApplicationID, TowerID, FT.ProjectID, FT.AssignedTo,            
 FT.EffortTillDate,FT.ServiceID, FT.TicketDescription, FT.IsDeleted, FT.TicketStatusMapID,FT.TicketTypeMapID,             
 FT.IsSDTicket,  FT.DARTStatusID, FT.ITSMEffort,FT.IsNonTicket,            
 FT.IsCustomer,FT.IsEfforTracked,FT.IsDebtEnabled,FT.IsMainSpringConfigured,FT.ISTicket,FT.ActivityId,            
 ETDT.IsAttributeUpdated,            
 FT.ProjectTimeZoneName,FT.UserTimeZoneName,            
 FT.[1TimeSheetDetailId], FT.[1],            
 FT.[2TimeSheetDetailId],  FT.[2],            
 FT.[3TimeSheetDetailId], FT.[3] ,            
 FT.[4TimeSheetDetailId],   FT.[4],            
 FT.[5TimeSheetDetailId], FT.[5] ,            
 FT.[6TimeSheetDetailId], FT.[6],            
 FT.[7TimeSheetDetailId], FT.[7],            
 CASE WHEN             
 (SELECT COUNT(HealingTicketID) FROM [AVL].[DEBT_TRN_HealTicketDetails](NOLOCK) WHERE HealingTicketID=FT.TicketID AND Isdeleted<>1 AND ISNULL(ManualNonDebt,0) != 1 )>0            
 THEN 1 ELSE 0 END AS 'IsAHTicket',            
 @SupportTypeID as 'SupportTypeID',            
 ISNULL(PDB.GracePeriod,365) AS GracePeriod,            
 NULL AS 'IsAHTagged',            
 FT.ClosedDate,            
 FT.CompletedDate,'T' as [Type],            
 CASE WHEN  @SupportTypeID =1            
 Then            
 (select Top 1 OpenDateTime from [AVL].[TK_TRN_TicketDetail] as Tic (NOLOCK) where Tic.TimeTickerID=FT.TimeTickerID)             
 Else            
 (select Top 1 OpenDateTime from [AVL].[TK_TRN_InfraTicketDetail] as Tic (NOLOCK) where Tic.TimeTickerID=FT.TimeTickerID)              
 END            
 AS OpenDateNTime            
 from #FinalTemp FT (NOLOCK)           
 LEFT JOIn #IsAttributeTemp ETDT (NOLOCK)ON ETDT.TicketID=FT.TicketID and FT.ProjectID=ETDT.ProjectID            
 --Added            
 LEFT JOIN AVL.MAS_ProjectDebtDetails PDB (NOLOCK)ON FT.ProjectID=PDB.ProjectID AND ISNULL(PDB.IsDeleted,0)=0            
             
 select distinct TTDT.SNO,TTDT.DATETODAY,TTDT.TimesheetId,TTDT.TimesheetDate,TTDT.TimeSheetDetailId,TTDT.ProjectID,            
 (CASE WHEN TT.StatusId in(2,3,6) THEN 'true' ELSE 'false'  END) AS FreezStatus  from #TimesheetandTimesheetdetailsidTemp(NOLOCK) TTDT            
 INNER JOIN #TimesheetTemp TT (NOLOCK)ON TT.TimesheetDate=TTDT.DATETODAY            
 where TTDT.sno is not null and TTDT.ProjectID is not null            
            
 select distinct TTDT.SNO,TTDT.DATETODAY,TTDT.TimesheetId,TTDT.TimesheetDate,TTDT.TimeSheetDetailId,TTDT.ProjectID,            
 (CASE WHEN TT.StatusId in(2,3,6) THEN 'true' ELSE 'false'  END) AS FreezeStatus              
    INTO #FreezeStatus from #TimesheetandTimesheetdetailsidTemp TTDT (NOLOCK)           
 INNER JOIN #TimesheetTemp TT (NOLOCK)ON TT.TimesheetDate=TTDT.DATETODAY            
 where TTDT.sno is not null and TTDT.ProjectID is not null            
             
 UPDATE ED             
 SET ED.FreezeStatus=FS.FreezeStatus             
 FROM #EFFORTDATES  ED            
 INNER JOIN #FreezeStatus FS (NOLOCK)           
 ON FS.DATETODAY=ED.DATETODAY            
            
 UPDATE #FreezeStatus SET FreezeStatus='false' WHERE FreezeStatus=''            
  DECLARE @IsDaily INT;            
 SET @IsDaily=(SELECT TOP 1 IsDaily FROM #ConfigTemp(NOLOCK))            
 IF @IsDaily = 0            
 BEGIN            
  DECLARE @CheckFreezeStatus NVARCHAR(50);            
  SET @CheckFreezeStatus=(SELECT COUNT(*) FROM #EFFORTDATES(NOLOCK) WHERE FreezeStatus='true')            
  if @CheckFreezeStatus> 0            
  update #EFFORTDATES set FreezeStatus='true'            
 END            
            
            
             
 UPDATE E            
 SET E.FreezeStatus='true'            
 from #EFFORTDATES E            
 LEFT JOIN #TimesheetTemp TT (NOLOCK)ON TT.TimesheetDate=E.DATETODAY            
 WHERE ISNULL(TT.StatusId,0) in (2,3,6)            
            
             
 select distinct E.SNO , E.DATETODAY ,  E.NAME,CONCAT(DATEPART(DAY,E.DATETODAY) , '-',LEFT(E.NAME,3)) AS DisplayDate,E.FreezeStatus AS FreezeStatus ,            
 ISNULL(TT.StatusId,0) AS StatusId            
 from #EFFORTDATES E (NOLOCK)           
 LEFT JOIN #TimesheetTemp TT (NOLOCK)ON TT.TimesheetDate=E.DATETODAY            
             
IF @SupportTypeID =1            
BEGIN            
IF EXISTS(SELECT TOP 1 1 FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID = @ProjectID AND IsMultilingualEnabled = '1' AND IsDeleted =0) AND            
EXISTS(SELECT  TOP 1 1 FROM AVL.PRJ_MultilingualColumnMapping(NOLOCK) WHERE ProjectID = @ProjectID AND ColumnID = 1 AND IsActive = 1)            
BEGIN            
 DECLARE @TimeTrackerId BIGINT            
 SET @TimeTrackerId = (SELECT TimeTickerID FROM AVL.TK_TRN_TicketDetail(NOLOCK) WHERE TicketID = @ticketID AND ProjectID = @ProjectID and IsDeleted = 0)            
 IF NOT EXISTS (SELECT TimeTickerID FROM AVL.[TK_TRN_Multilingual_TranslatedTicketDetails](NOLOCK) WHERE TimeTickerID = @TimeTrackerId and IsDeleted = 0)            
  BEGIN            
   INSERT INTO AVL.[TK_TRN_Multilingual_TranslatedTicketDetails](TimeTickerID,TicketDescription,createdby,createddate,TicketCreatedType,Isdeleted) VALUES(@TimeTrackerId,@mticketdescription,@UserID,GETDATE(),3,0)            
  END            
 ELSE            
 BEGIN            
  UPDATE AVL.[TK_TRN_Multilingual_TranslatedTicketDetails] SET TicketDescription = @mticketdescription, ModifiedDate=getdate(),IsTicketDescriptionUpdated = 0 WHERE TimeTickerID = @TimeTrackerId and IsDeleted = 0            
 END            
END            
END            
ELSE            
BEGIN            
IF EXISTS(SELECT 1 FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID = @ProjectID AND IsMultilingualEnabled = '1' AND IsDeleted =0) AND            
EXISTS(SELECT 1 FROM AVL.PRJ_MultilingualColumnMapping(NOLOCK) WHERE ProjectID = @ProjectID AND ColumnID = 1 AND IsActive = 1)            
 BEGIN            
 DECLARE @Infra_TimeTrackerId BIGINT            
 SET @Infra_TimeTrackerId = (SELECT TimeTickerID FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) WHERE TicketID = @ticketID AND ProjectID = @ProjectID and IsDeleted = 0)            
 print @Infra_TimeTrackerId            
 IF NOT EXISTS (SELECT TimeTickerID FROM AVL.[TK_TRN_Multilingual_TranslatedInfraTicketDetails](NOLOCK) WHERE TimeTickerID = @Infra_TimeTrackerId and IsDeleted = 0)            
  BEGIN            
   INSERT INTO AVL.[TK_TRN_Multilingual_TranslatedInfraTicketDetails](TimeTickerID,TicketDescription,createdby,createddate,TicketCreatedType,isdeleted) VALUES(@Infra_TimeTrackerId,@mticketdescription,@UserID,GETDATE(),3,0)            
  END            
 ELSE            
  BEGIN            
   UPDATE AVL.[TK_TRN_Multilingual_TranslatedInfraTicketDetails] SET TicketDescription = @mticketdescription, ModifiedDate=getdate(),IsTicketDescriptionUpdated = 0 WHERE TimeTickerID = @Infra_TimeTrackerId and IsDeleted = 0            
  END            
 END            
END            
            
 IF OBJECT_ID('tempdb..#UserProjectDetails', 'U') IS NOT NULL            
 BEGIN            
 DROP Table #UserProjectDetails            
 END            
 IF OBJECT_ID('tempdb..#AddTicketTemp', 'U') IS NOT NULL            
 BEGIN            
 DROP Table #AddTicketTemp            
 END            
 IF OBJECT_ID('tempdb..#ConfigTemp', 'U') IS NOT NULL            
 BEGIN            
 DROP Table #ConfigTemp            
 END            
 IF OBJECT_ID('tempdb..#EFFORTDATES', 'U') IS NOT NULL            
 BEGIN            
 DROP Table #EFFORTDATES            
 END            
 IF OBJECT_ID('tempdb..#EffortEntryDataTemp', 'U') IS NOT NULL            
 BEGIN            
 DROP TABLE #EffortEntryDataTemp            
 END            
 IF OBJECT_ID('tempdb..#LastTemp', 'U') IS NOT NULL            
 BEGIN            
 DROP TABLE #LastTemp            
 END            
 IF OBJECT_ID('tempdb..#FinalTemp', 'U') IS NOT NULL            
 BEGIN            
 DROP TABLE #FinalTemp            
 END            
 IF OBJECT_ID('tempdb..#TimesheetandTimesheetdetailsidTemp', 'U') IS NOT NULL            
 BEGIN            
 DROP Table #TimesheetandTimesheetdetailsidTemp            
 END            
 IF OBJECT_ID('tempdb..#TimesheetTemp', 'U') IS NOT NULL            
 BEGIN            
 DROP TABLE #TimesheetTemp            
 END            
 IF OBJECT_ID('tempdb..#IsAttributeTemp', 'U') IS NOT NULL            
 BEGIN            
 DROP Table #IsAttributeTemp            
 END            
 IF OBJECT_ID('tempdb..#FreezeStatus', 'U') IS NOT NULL            
 BEGIN            
 DROP Table #FreezeStatus            
 END            
 IF OBJECT_ID('tempdb..#SelectedTickets', 'U') IS NOT NULL            
 BEGIN            
 DROP Table #SelectedTickets            
 END            
            
             
 if(@IsSDTicket=1)            
 begin            
   UPDATE [AVL].[TK_MAP_IDGeneration]  SET NextID=NextID+1 WHERE CustomerID=@CustomerID             
            
  enD            
            
  --COMMIT TRAN            
  END TRY            
  BEGIN CATCH            
   DECLARE @ErrorMessage VARCHAR(MAX);            
            
  SELECT @ErrorMessage = ERROR_MESSAGE()            
  SELECT @ErrorMessage            
  --ROLLBACK TRAN            
  --INSERT Error                
  EXEC AVL_InsertError '[AVL].[SaveTicketDetails]', @ErrorMessage, @ProjectID,0            
              
  END CATCH            
  SET NOCOUNT OFF;          
END
