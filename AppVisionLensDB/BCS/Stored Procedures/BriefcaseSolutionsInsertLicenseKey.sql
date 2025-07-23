
CREATE PROCEDURE [BCS].[BriefcaseSolutionsInsertLicenseKey]
@userId nvarchar(50),
@projectID int,
@solutionName nvarchar(100),
@licenseKey nvarchar(50),
@flag bit 
AS
BEGIN
DECLARE @solutionId int
SET NOCOUNT ON;
BEGIN TRY
SELECT @solutionId = Id from [BCS].[SolutionMaster] (NOLOCK) where SolutionName = @solutionName and IsDeleted = 0
if  @flag = 0
	IF (@solutionName = 'SmartDebtClassifier'  or  @solutionName = 'TicketQualityBOT')
	BEGIN 
	INSERT INTO [BCS].[BriefcaseSolutionDetails] VALUES (@userId,@projectID,@solutionId,@licenseKey,GETDATE() + 7,0,'SYSTEM',GETDATE(),NULL,NULL,1)
	END
	ELSE IF (@solutionName = 'ILTutor')
	BEGIN 
	INSERT INTO [BCS].[BriefcaseSolutionDetails] VALUES (@userId,@projectID,@solutionId,@licenseKey,GETDATE() + 10,0,'SYSTEM',GETDATE(),NULL,NULL,1)
	END
	ELSE IF (@solutionName = 'Clustering')
	BEGIN
	INSERT INTO [BCS].[BriefcaseSolutionDetails] VALUES (@userId,@projectID,@solutionId,@licenseKey,GETDATE() + 60,0,'SYSTEM',GETDATE(),NULL,NULL,1)
	END
	ELSE
	BEGIN
	INSERT INTO [BCS].[BriefcaseSolutionDetails] VALUES (@userId,@projectID,@solutionId,@licenseKey,GETDATE() + 30,0,'SYSTEM',GETDATE(),NULL,NULL,1)
	END


Else if  @flag = 1
	IF (@solutionName = 'SmartDebtClassifier'or  @solutionName = 'TicketQualityBOT')
	BEGIN 
	 UPDATE [BCS].[BriefcaseSolutionDetails] SET [LicenseKey]=@licenseKey, 
	 [LicenseKeyExpiryDate] = GETDATE() + 7,  [ModifiedBy]='SYSTEM',[ModifiedDate]=GETDATE(),[Download]=Download+1
	 where  userId =@userId and ESAProjectID=@projectID and solutionId=@solutionId and IsDeleted = 0

	
	END
	ELSE IF (@solutionName = 'ILTutor')
	BEGIN 
	UPDATE [BCS].[BriefcaseSolutionDetails] SET [LicenseKey]=@licenseKey, 
	[LicenseKeyExpiryDate] = GETDATE() + 10,  [ModifiedBy]='SYSTEM',[ModifiedDate]=GETDATE(),[Download]=Download+1
	where  userId =@userId and ESAProjectID=@projectID and solutionId=@solutionId and IsDeleted = 0
	END
	ELSE IF (@solutionName = 'Clustering')
	BEGIN 
	UPDATE [BCS].[BriefcaseSolutionDetails] SET [LicenseKey]=@licenseKey, 
	[LicenseKeyExpiryDate] = GETDATE() + 60,  [ModifiedBy]='SYSTEM',[ModifiedDate]=GETDATE(),[Download]=Download+1
	where  userId =@userId and ESAProjectID=@projectID and solutionId=@solutionId and IsDeleted = 0
	END
	ELSE
	BEGIN
	UPDATE [BCS].[BriefcaseSolutionDetails]SET [LicenseKey]=@licenseKey, 
	[LicenseKeyExpiryDate] = GETDATE() + 30,  [ModifiedBy]='SYSTEM',[ModifiedDate]=GETDATE(),[Download]=Download+1
	where  userId =@userId and ESAProjectID=@projectID and solutionId=@solutionId and IsDeleted = 0
	END
	SET NOCOUNT OFF;
END TRY
BEGIN CATCH
DECLARE @errorMessage VARCHAR(MAX);

		SELECT @errorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[BCS].[BriefcaseSolutionsInsertLicenseKey]',@errorMessage,'',0
END CATCH
END
