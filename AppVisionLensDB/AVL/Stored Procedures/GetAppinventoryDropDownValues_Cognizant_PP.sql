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
-- Author      : Subramanian S
-- Create date : 31.03.2020
-- Description : This Procedure used to get Appinventory DropDown values 
-- Revision    :  
-- Revised By  :
-- ============================================================================================
-- [AVL].[GetAppinventoryDropDownValues_Cognizant_PP] 8862
CREATE PROCEDURE [AVL].[GetAppinventoryDropDownValues_Cognizant_PP] 
@CustomerID BIGINT
AS
BEGIN
   BEGIN TRY

		SET NOCOUNT ON;

        DECLARE @IsDeleted INT = 0;
		--DECLARE @HostEnvronment VARCHAR(10) = 'IAAS&PAAS';
		--DECLARE @HostedEnvirontSSAS VARCHAR(8) = 'SAAS';
		DECLARE @TechnologyIsDeleted CHAR(1) = 'N';
		
		---Code OwnerShip --For cognizant need to exclude in house
		SELECT ApplicationTypename 
		FROM AVL.APP_MAS_OwnershipDetails(NOLOCK)
		WHERE IsDeleted = @IsDeleted and lower(trim(ApplicationTypename))!='in house';	

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

		---Geographies Supported--------
		SELECT DISTINCT GeographiesName 
		FROM ADM.GeographiesSupported(NOLOCK) 
		WHERE IsDeleted = @IsDeleted
			
		---Functional Knowledge-----
		SELECT DISTINCT FunctionalKnowledgeName 
		FROM ADM.FunctionalKnowledge(NOLOCK) 
		WHERE IsDeleted = @IsDeleted

		---ExecutionMethod---
		--SELECT DISTINCT ExecutionMethodName 
		--FROM ADM.ExecutionMethod(NOLOCK)
		--WHERE IsDeleted = @IsDeleted
		--ORDER BY ExecutionMethodName ASC

		--SELECT  ExecutionMethodName into #TempExecutionMethod
		--FROM ADM.ExecutionMethod(NOLOCK) 
		--WHERE IsDeleted =@IsDeleted order by ExecutionMethodName asc
		--delete from #TempExecutionMethod where ExecutionMethodName='Others'
		--insert into #TempExecutionMethod values('Others')
		--select ExecutionMethodName from #TempExecutionMethod
		--drop table #TempExecutionMethod

		IF EXISTS
(
	select DISTINCT PAV.AttributeValueID AS ExecutionID, PPA.AttributeValueName AS ExecutionName 
	from PP.ProjectAttributeValues (NOLOCK) PAV
	INNER JOIN Mas.PPAttributeValues (NOLOCK) PPA ON PPA.AttributeID = PAV.AttributeID AND PPA.AttributeValueID = PAV.AttributeValueID AND PAV.IsDeleted = 0
	AND PPA.IsDeleted = 0
	INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0
	WHERE AttributeName = 'ExecutionMethod' AND ProjectID IN (SELECT DISTINCT PM.ProjectID FROM AVL.Customer(NOLOCK) C 
	INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.CustomerID=C.CustomerID AND PM.IsDeleted=0
	AND C.IsDeleted=0 and c.CustomerID = @CustomerID))
	BEGIN

	select DISTINCT  PPA.AttributeValueName AS ExecutionMethodName 
	from PP.ProjectAttributeValues (NOLOCK) PAV
	INNER JOIN Mas.PPAttributeValues (NOLOCK) PPA ON PPA.AttributeID = PAV.AttributeID AND PPA.AttributeValueID = PAV.AttributeValueID AND PAV.IsDeleted = 0
	AND PPA.IsDeleted = 0
	INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0
	WHERE AttributeName = 'ExecutionMethod' AND ProjectID IN (SELECT DISTINCT PM.ProjectID FROM AVL.Customer(NOLOCK) C 
	INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.CustomerID=C.CustomerID AND PM.IsDeleted=0
	AND C.IsDeleted=0 and c.CustomerID = @CustomerID) ORDER BY PPA.AttributeValueName ASC

	
	END
ELSE
BEGIN

SELECT 'NA' AS ExecutionName

END

		---SourceCodeAvailability---
		SELECT DISTINCT SourceCodeName 
		FROM ADM.SourceCodeAvailability(NOLOCK) 
		WHERE IsDeleted = @IsDeleted

		---RegulatoryBody---
		SELECT DISTINCT RegulatoryBodyName 
		FROM ADM.RegulatoryBody(NOLOCK) 
		WHERE IsDeleted = @IsDeleted

		--- ---

 END TRY
  BEGIN CATCH			

		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()

		--- Insert Error Message ---
		EXEC AVL_InsertError '[AVL].[GetAppinventoryDropDownValues_Cognizant_PP]', @ErrorMessage, 0, 0
		             
  END CATCH
END
