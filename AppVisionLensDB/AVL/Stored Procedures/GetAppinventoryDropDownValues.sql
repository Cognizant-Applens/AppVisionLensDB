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
-- Author      : Annadurai
-- Create date : 08.07.2019
-- Description : This Procedure used to get Appinventory DropDown values
-- Revision    :  
-- Revised By  :
-- ============================================================================================
CREATE PROCEDURE [AVL].[GetAppinventoryDropDownValues]
AS
BEGIN
   BEGIN TRY

		SET NOCOUNT ON;

        DECLARE @IsDeleted INT = 0;
		--DECLARE @HostEnvronment VARCHAR(10) = 'IAAS&PAAS';
		--DECLARE @HostedEnvirontSSAS VARCHAR(8) = 'SAAS';
		DECLARE @TechnologyIsDeleted CHAR(1) = 'N';
		
		---Code OwnerShip
		SELECT ApplicationTypename 
		FROM AVL.APP_MAS_OwnershipDetails(NOLOCK)
		WHERE IsDeleted = @IsDeleted	

		---Business Critically
		SELECT	BusinessCriticalityName
		FROM AVL.APP_MAS_BusinessCriticality(NOLOCK)
		WHERE IsDeleted = @IsDeleted

		---Primary Technology

		SELECT DISTINCT PrimaryTechnologyName
		FROM AVL.APP_MAS_PrimaryTechnology(NOLOCK)
		WHERE	IsDeleted = @IsDeleted

		--Regulatory Complaints

		SELECT	RegulatoryCompliantName
		FROM AVL.APP_MAS_RegulatoryCompliant(NOLOCK)
		where IsDeleted = @IsDeleted

		--Debt Controle Scope

		SELECT	DebtcontrolScopeName
		FROM    AVL.APP_MAS_DebtcontrolScope(NOLOCK)
		WHERE	IsDeleted = @IsDeleted

		--Support Window

		SELECT 					
				SupportWindowName 
		FROM    AVL.APP_MAS_SupportWindow(NOLOCK) 
		WHERE	IsDeleted = @IsDeleted

		--support category

		SELECT 	SupportCategoryName 
		FROM    AVL.APP_MAS_SupportCategory(NOLOCK)
		WHERE	IsDeleted = @IsDeleted

		--Hosted Environment

		SELECT 	HostedEnvironmentName 
		FROM    AVL.APP_MAS_HostedEnvironment(NOLOCK)
		WHERE	IsDeleted = @IsDeleted
	

		---Cloud Service Provider -Cloud IAAS-Infrastructure as a Service

		SELECT  CloudServiceProviderName AS CloudServiceProviderNameIAASPAAS
		FROM    AVL.APP_MAS_CloudServiceProvider(NOLOCK)
		WHERE	isdeleted= @IsDeleted
		AND  HostedEnvironmentName LIKE '%IAAS%'
			---Cloud Service Provider -Cloud PAAS- Platform as a Service

		SELECT  CloudServiceProviderName AS CloudServiceProvidername
		FROM    AVL.APP_MAS_CloudServiceProvider(NOLOCK)
		WHERE	isdeleted= @IsDeleted
		AND  HostedEnvironmentName LIKE '%PAAS%'

			---Cloud Service Provider -Cloud SAAS- Software as a Service

		SELECT  CloudServiceProviderName AS CloudServiceProviderNameSAAS
		FROM    AVL.APP_MAS_CloudServiceProvider(NOLOCK)
		WHERE	isdeleted= @IsDeleted
		AND  HostedEnvironmentName LIKE '%SAAS%'

		--Clouf Model
		SELECT   CloudModelName 
		FROM     MAS.MAS_CloudModelProvider(NOLOCK)
		WHERE	 IsDeleted = @IsDeleted

		--Technology
		SELECT DISTINCT TechnologyName 
		FROM SA.TechnologyMaster(NOLOCK) 
		WHERE IsDeleted = @TechnologyIsDeleted

				

 END TRY
  BEGIN CATCH			

		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()

		--- Insert Error Message ---
		EXEC AVL_InsertError '[AVL].[GetAppinventoryDropDownValues]', @ErrorMessage, 0, 0
		             
  END CATCH
END
