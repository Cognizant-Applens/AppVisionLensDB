/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ADM].[AppInvSaveALMApplicationAttributes]   
@applicationID bigint,
@isRevenue bit=null,
@isAnySIVendor bit=null,
@functionalKnowledge bigint,
@executionMethod bigint,
@otherExecutionMethod nvarchar(100),
@sourceCodeAvailability int,
@otherRegulatoryBody nvarchar(100),
@userName nvarchar(50),
@isUpdate bit,
@isAppAvailable bit=null,
@availability varchar(10),
@TvpApplicationScopeList as [ADM].[TvpAppApplicationScope] READONLY,
@TvpGeographyList as [ADM].[TvpAppGeographies] READONLY,
@TvpRegulatoryBodyList as [ADM].[TvpAppRegulatoryBody] READONLY
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;
DECLARE @count BIGINT;
IF @applicationID > 0
BEGIN

SELECT
	@count = 1
FROM ADM.ALMApplicationDetails (NOLOCK)
WHERE ApplicationID = @applicationID;

DECLARE @Availperc decimal(18,2)=(select cast(cast(@availability AS float) as DECIMAL(18, 2)));

IF @count IS NOT NULL AND @count = 1
BEGIN
UPDATE ADM.ALMApplicationDetails
SET	IsRevenue = @isRevenue
	,IsAnySIVendor = @isAnySIVendor
	,FunctionalKnowledge = @functionalKnowledge
	,ExecutionMethod = @executionMethod
	,OtherExecutionMethod = LTRIM(RTRIM(@otherExecutionMethod))
	,SourceCodeAvailability = @sourceCodeAvailability       
	,OtherRegulatoryBody = LTRIM(RTRIM(@otherRegulatoryBody))
	,IsAppAvailable=@isAppAvailable
	,AvailabilityPercentage=@Availperc
	,IsDeleted=0
	,ModifiedBy = @userName
	,ModifiedDate = GETDATE()
WHERE ApplicationID = @applicationID;
END 
ELSE 
BEGIN
INSERT INTO ADM.ALMApplicationDetails (ApplicationID,
IsRevenue,
IsAnySIVendor,
FunctionalKnowledge,
ExecutionMethod,
OtherExecutionMethod,
SourceCodeAvailability,
OtherRegulatoryBody,
IsAppAvailable,
AvailabilityPercentage,
IsDeleted,
CreatedBy,
CreatedDate
)
VALUES (@applicationID,@isRevenue, @isAnySIVendor, @functionalKnowledge, @executionMethod,
LTRIM(RTRIM(@otherExecutionMethod)), @sourceCodeAvailability,LTRIM(RTRIM(@otherRegulatoryBody)), @isAppAvailable, 
@Availperc,0, @userName, GETDATE())

END
DELETE FROM ADM.AppApplicationScope WHERE ApplicationId=@applicationID

INSERT INTO ADM.AppApplicationScope(ApplicationId, ApplicationScopeId, IsDeleted, CreatedBy, CreatedDate)
SELECT @applicationID, ApplicationScopeID, 0, @userName, GETDATE() FROM @TvpApplicationScopeList


DELETE FROM ADM.AppGeographies WHERE ApplicationId=@applicationID

INSERT INTO ADM.AppGeographies(ApplicationId,GeographyId,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
SELECT @applicationID,GeographID,0,@userName,GETDATE(),NULL,NULL FROM @TvpGeographyList

DELETE FROM ADM.AppRegulatoryBody WHERE ApplicationId=@applicationID

INSERT INTO ADM.AppRegulatoryBody(ApplicationId,RegulatoryId,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
SELECT @applicationID,RegulatoryID,0,@userName,GETDATE(),NULL,NULL FROM @TvpRegulatoryBodyList


--END
END
SET NOCOUNT OFF;
END TRY 
BEGIN CATCH

DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()


EXEC AVL_InsertError	'[ADM].[AppInvSaveALMApplicationAttributes]'
						,@ErrorMessage
						,@userName
						,@applicationID

END CATCH
END
