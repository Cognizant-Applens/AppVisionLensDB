/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[APP_INV_GetApplicationAttributes] 
	@applicationID BIGINT,
	@UserID NVARCHAR(50)
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	SELECT 
			AL.ApplicationID,AL.ApplicationName,AL.ApplicationCode,AL.ApplicationShortName
			,AL.BusinessCriticalityID,AL.CodeOwnerShip,AL.PrimaryTechnologyID,AL.ProductMarketName
			,AL.ApplicationCommisionDate,AL.RegulatoryCompliantID,AL.ApplicationDescription
			,AL.DebtControlScopeID,AL.SubBusinessClusterMapID,AL.OtherPrimaryTechnology
	FROM
			AVL.APP_MAS_ApplicationDetails AL
			WITH(NOLOCK)
	WHERE	
			AL.ApplicationID=@applicationID;
		
	SELECT 
			IA.ApplicationID,
			IA.OperatingSystem,
			IA.ServerConfiguration,
			IA.ServerOwner,
			IA.LicenseDetails,
			IA.DatabaseVersion,
			IA.HostedEnvironmentID,
			IA.CloudServiceProvider,
			IA.CloudModelID as CloudModelProvider,---Cloud Model
			IA.OtherCloudServiceProvider
	FROM
			AVL.APP_MAS_InfrastructureApplication IA
			WITH(NOLOCK)
	WHERE 
			IA.ApplicationID=@applicationID;

		

	SELECT 
			EAD.ApplicationID,EAD.UserBase,EAD.Incallwdgreen,
			EAD.Infraallwdgreen,EAD.Infoallwdgreen,EAD.Incallwdamber,EAD.Infraallwdamber,
			EAD.Infoallwdamber,EAD.SupportWindowID,EAD.SupportCategoryID,EAD.OtherSupportWindow
	FROM
		AVL.APP_MAS_Extended_ApplicationDetail EAD
		WITH(NOLOCK)

	WHERE
		EAD.ApplicationID=@applicationID;   

	END TRY  
	BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		
		EXEC AVL_InsertError '[AVL].[APP_INV_GetApplicationAttributes]', @ErrorMessage, @UserID, @applicationID 
		
	END CATCH  

END
