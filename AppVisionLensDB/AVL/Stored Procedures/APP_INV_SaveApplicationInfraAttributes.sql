/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================================
-- Author       : 
-- Create date  : 
-- Description  : This Procedure Used to Save the Application Infra Attributes
-- Modified Date: 02 Aug 2019
-- Revision     : Added Cloud Module Id 
-- Revised By   : Annadurai
-- ============================================================================================
CREATE PROCEDURE [AVL].[APP_INV_SaveApplicationInfraAttributes] 
@applicationID bigint,
@operatingSystem nvarchar(100),
@serverConfiguration nvarchar(100),
@serverOwner nvarchar(100),
@licenseDetails nvarchar(100),
@databaseVersion nvarchar(100),
@hostedEnvironmentID bigint,
@userName nvarchar(50),
@isUpdate bit,
@CloudServiceProvider int,
@CloudModelProvider int,
@OtherCloudServiceProvider nvarchar(100)
AS
BEGIN
BEGIN TRY

SET NOCOUNT ON;

DECLARE @count BIGINT;
IF @applicationID > 0
BEGIN
				SELECT
					@count=1
				FROM 
					AVL.APP_MAS_InfrastructureApplication
				WHERE
					ApplicationID=@applicationID;

				IF @count IS NOT NULL AND @count=1
				BEGIN
						UPDATE 
							AVL.APP_MAS_InfrastructureApplication 
						SET 
							OperatingSystem = LTRIM(RTRIM(@operatingSystem)),
							ServerConfiguration = LTRIM(RTRIM(@serverConfiguration)),
							ServerOwner = LTRIM(RTRIM(@serverOwner)),
							LicenseDetails = LTRIM(RTRIM(@licenseDetails)),
							DatabaseVersion = LTRIM(RTRIM(@databaseVersion)),
							HostedEnvironmentID = @hostedEnvironmentID,
							ModifiedBy = @userName,
							ModifiedDate = GETDATE(),
							CloudServiceProvider = @CloudServiceProvider,
							CloudModelID = @CloudModelProvider,
							OtherCloudServiceProvider = LTRIM(RTRIM(@OtherCloudServiceProvider))

						WHERE
							ApplicationID=@applicationID;
				END
				ELSE

					BEGIN
							INSERT
							INTO
								AVL.APP_MAS_InfrastructureApplication 
									(ApplicationID,
									OperatingSystem,
									ServerConfiguration,
									ServerOwner,
									LicenseDetails,
									DatabaseVersion,
									HostedEnvironmentID,
									IsDeleted,
									CreatedBy,
									CreatedDate,
									CloudServiceProvider,
									CloudModelID,
									OtherCloudServiceProvider
									)
							VALUES
									(@applicationID,
									LTRIM(RTRIM(@operatingSystem)),
									LTRIM(RTRIM(@serverConfiguration)),
									LTRIM(RTRIM(@serverOwner)),
									LTRIM(RTRIM(@licenseDetails)),
									LTRIM(RTRIM(@databaseVersion)),
									@hostedEnvironmentID,
									0,
									@userName,
									GETDATE(),
									@CloudServiceProvider,
									@CloudModelProvider,
									LTRIM(RTRIM(@OtherCloudServiceProvider))
									)

					END
END

EXEC [PP].[ProjectAttributeBasedOnCloudService]  NULL,@applicationID,@userName
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
  
		EXEC AVL_InsertError '[AVL].[APP_INV_SaveApplicationInfraAttributes]', @ErrorMessage, @userName, @applicationID 
		
	END CATCH  


END
