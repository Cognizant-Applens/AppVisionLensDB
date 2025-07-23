CREATE PROCEDURE [PP].[SaveProjectMigrationDetails]      
(      
@MigrationType int,      
@RequestedBy nvarchar(50),      
@RequestedDate datetime,      
@TvpProjects As [PP].[TVP_ProjectMigrationProjects] ReadOnly,      
@EmployeeId nvarchar(50)      
)      
AS BEGIN      
BEGIN TRY      
BEGIN TRAN    
SET NOCOUNT ON;      
DECLARE @Response varchar(250),@IsValidated bit=0,@ProjectID int,@MigrationCancelledStatusId int;    
Select SourceESAProjectId,DestinationESAProjectId into #tmpProjectDetails From @TvpProjects;      
Select @ProjectID = ProjectID from AVL.MAS_ProjectMaster Where ESAProjectId= (Select Top 1 SourceESAProjectId From #tmpProjectDetails);    
Create Table #OnboardPercentage ( OnboardPercentage int);    
Insert into #OnboardPercentage Execute [PP].[GetAdaptersScopeDetails] @ProjectID,'';    
    
SELECT @MigrationCancelledStatusId = AttributeValueId from MAS.PPAttributeValues Where AttributeValueName='Cancelled' And AttributeID =       
(Select AttributeId from MAS.PPattributes Where AttributeName = 'ProjectMigrationStatus');      
    
  
IF (Select OnboardPercentage From #OnboardPercentage ) < 100    
BEGIN    
Set @IsValidated =0;    
SET @Response = 'Chosen Source project is not on-boarded.'    
Select @Response as Result    
END    
ELSE IF EXISTS (Select SourceESAProjectId From #tmpProjectDetails Where SourceESAProjectId in (Select DestinationESAProjectId From #tmpProjectDetails))    
BEGIN    
Set @IsValidated =0;    
SET @Response = 'Source and Destination projects are same.'    
Select @Response as Result    
END    
ELSE IF EXISTS (Select DestinationESAProjectId From #tmpProjectDetails Where DestinationESAProjectId in (Select DestinationESAProjectId From PP.ProjectMigrationDetails where MigrationStatusId <> @MigrationCancelledStatusId))    
BEGIN    
Set @IsValidated =0;    
SET @Response = 'Destination Project already has data.'    
Select @Response as Result    
END    
ELSE IF EXISTS (Select SourceESAProjectId From PP.ProjectMigrationDetails Where MigrationStatusId <> @MigrationCancelledStatusId and SourceESAProjectId = (Select Top 1 SourceESAProjectId From #tmpProjectDetails))    
BEGIN    
Set @IsValidated =0;    
SET @Response = 'Source project has already been moved.'    
Select @Response as Result    
END    
ELSE    
BEGIN    
Set @IsValidated =1;    
END    
    
IF(@IsValidated =1)    
BEGIN    
    
      
DECLARE @Prefix Varchar(2)='MG',@RowId int, @MigrationStatusId int, @MigrationId nvarchar(20);      
SELECT @RowId = ISNULL(Count(MigrationId),0) + 1 FROM PP.ProjectMigrationRequest;      
      
SELECT @MigrationStatusId = AttributeValueId from MAS.PPAttributeValues Where AttributeValueName='Initiated' And AttributeID =       
(Select AttributeId from MAS.PPattributes Where AttributeName = 'ProjectMigrationStatus');      
      
 SELECT @MigrationId = @Prefix + RIGHT('00000000' + CAST(@RowId AS VARCHAR(8)),8);      
      
 INSERT INTO PP.ProjectMigrationRequest      
 VALUES (@MigrationId,@RequestedBy,@RequestedDate,@MigrationType,@MigrationStatusId,0,@EmployeeId,GETDATE(),NULL,NULL)      
      
 INSERT INTO PP.ProjectMigrationDetails      
 SELECT      
 @MigrationId,      
 NULL,      
 NULL,      
 tp.SourceESAProjectId,      
 tp.DestinationESAProjectId,      
 @MigrationStatusId,      
 0,      
 @EmployeeId,      
 GETDATE(),      
 NULL,      
 NULL      
 FROM #tmpProjectDetails tp      
    
 Set @Response = 'Submitted Successfully. Once migration is completed you will receive a mail.';    
 Select @Response as Result    
END     
    
COMMIT TRAN    
END TRY     
    
BEGIN CATCH     
SET @Response = 'Submission Failed.'    
Select @Response as Result    
DECLARE @ErrorMessage VARCHAR(MAX);     
SELECT @ErrorMessage = ERROR_MESSAGE()     
--INSERT Error       
ROLLBACK TRAN    
EXEC AVL_INSERTERROR  '[PP].[SaveProjectMigrationDetails]', @ErrorMessage,  0, 0     
END CATCH       
END
