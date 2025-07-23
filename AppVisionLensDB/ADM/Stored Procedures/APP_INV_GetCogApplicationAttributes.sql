/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ADM].[APP_INV_GetCogApplicationAttributes] --119893,'691750'
	@applicationID BIGINT,
	@UserID NVARCHAR(50)
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;
	DECLARE @OtherUnitTestID INT =4;
	DECLARE @UnitTestID VARCHAR(100);
	DECLARE @OtherUnitTestName NVARCHAR(250);
	-----------------------geographic-----------------------
	
	SELECT distinct 
    SAD.ApplicationID,
    STUFF((SELECT ', ' + Cast(AD.GeographyId as varchar(10))
          FROM  ADM.AppGeographies(NOLOCK) AD
          WHERE AD.ApplicationID=@applicationID AND AD.ApplicationID = SAD.ApplicationID 
          ORDER BY GeographyId
          FOR XML PATH('')), 1, 1, '') [GeographiesSupported]
    into #Geographic FROM  ADM.AppGeographies(NOLOCK) SAD
	WHERE SAD.ApplicationID=@applicationID
    GROUP BY SAD.ApplicationID, SAD.GeographyId
    ORDER BY 1

	DECLARE @Geographic varchar(100)=(select GeographiesSupported from #Geographic(NOLOCK) where ApplicationID=@applicationID)
	-----------------------applicationscope-----------------------

	SELECT distinct 
    SAD.ApplicationID,
    STUFF((SELECT ', ' + Cast(AD.ApplicationScopeId  as varchar(10))
          FROM ADM.AppApplicationScope(NOLOCK) AD
          WHERE  AD.ApplicationID=@applicationID AND AD.ApplicationID = SAD.ApplicationID
		  AND AD.IsDeleted=0
          ORDER BY ApplicationScopeId
          FOR XML PATH('')), 1, 1, '') [ApplicationScope]
    into #ApplicationScope FROM ADM.AppApplicationScope(NOLOCK) SAD
	WHERE SAD.ApplicationID=@applicationID
    GROUP BY SAD.ApplicationID, SAD.ApplicationScopeId
    ORDER BY 1

	DECLARE @Applicationscope varchar(100)=(select  [ApplicationScope] from #ApplicationScope(NOLOCK) where ApplicationID=@applicationID)
	-----------------------RegulatoryBody-----------------------

	SELECT distinct 
    SAD.ApplicationID,
    STUFF((SELECT ', ' + CAST(AD.RegulatoryId as varchar(10)) 
          FROM ADM.AppRegulatoryBody(NOLOCK) AD
          WHERE AD.ApplicationID=@applicationID AND AD.ApplicationID = SAD.ApplicationID 
          ORDER BY RegulatoryId
          FOR XML PATH('')), 1, 1, '') [RegulatoryBody]
    into #RegulatoryBody FROM ADM.AppRegulatoryBody(NOLOCK) SAD
	WHERE SAD.ApplicationID=@applicationID
    GROUP BY SAD.ApplicationID, SAD.RegulatoryId
    ORDER BY 1

	DECLARE @RegulatoryBody varchar(100)=(select [RegulatoryBody] from #RegulatoryBody(NOLOCK) where ApplicationID=@applicationID)
	---------------------------------------New Attributes----------------------------------
	DECLARE @Count INT=(SELECT  COUNT(DISTINCT ApplicationID) FROM  ADM.ALMApplicationDetails(NOLOCK) WHERE ApplicationID=@applicationID and IsDeleted=0)
		
	IF(@Count>0)
	BEGIN
	SELECT AD.ApplicationID,@Applicationscope AS ApplicationScope,AD.IsRevenue,AD.IsAnySIVendor,@Geographic AS GeographiesSupported,
		   (CASE WHEN AD.FunctionalKnowledge IS NULL THEN 0 ELSE AD.FunctionalKnowledge END) AS FunctionalKnowledge,
		   (CASE WHEN AD.ExecutionMethod IS NULL THEN 0 ELSE AD.ExecutionMethod END) AS ExecutionMethod
		   ,AD.OtherExecutionMethod
		   ,(CASE WHEN AD.SourceCodeAvailability IS NULL THEN 0 ELSE AD.SourceCodeAvailability END) AS SourceCodeAvailability,
		   @RegulatoryBody AS RegulatoryBody,AD.OtherRegulatoryBody,
		   AD.IsAppAvailable,AD.AvailabilityPercentage AS Availabilityperc
	FROM
		 ADM.ALMApplicationDetails(NOLOCK) AD
	--INNER JOIN #ApplicationScope APS ON APS.ApplicationID=AD.ApplicationID
	----INNER JOIN #Geographic G ON G.ApplicationID=AD.ApplicationID
	--INNER JOIN #RegulatoryBody RB ON RB.ApplicationID=AD.ApplicationID
    WHERE
		AD.ApplicationID=@applicationID and IsDeleted=0
    END
	ELSE
	BEGIN
	SELECT 0 AS ApplicationID,@Applicationscope AS ApplicationScope,'' AS IsRevenue,'' AS IsAnySIVendor,@Geographic AS GeographiesSupported,0 AS FunctionalKnowledge,
		   0 AS ExecutionMethod,NULL AS OtherExecutionMethod,0 AS SourceCodeAvailability,@RegulatoryBody AS RegulatoryBody,NULL AS OtherRegulatoryBody,
		   '' AS IsAppAvailable,0 AS Availabilityperc
	END
	---------------------------------------Common Attributes-----------------------------------------
	SELECT 
			AL.ApplicationID,AL.ApplicationName,AL.ApplicationCode,AL.ApplicationShortName
			,AL.BusinessCriticalityID,AL.CodeOwnerShip,AL.PrimaryTechnologyID,AL.ProductMarketName
			,AL.ApplicationCommisionDate,AL.RegulatoryCompliantID,AL.ApplicationDescription
			,AL.DebtControlScopeID,AL.SubBusinessClusterMapID,AL.OtherPrimaryTechnology
	FROM
			AVL.APP_MAS_ApplicationDetails AL(NOLOCK)
	WHERE	
			AL.ApplicationID=@applicationID;
	
	---------------------------------------Infra Attributes--------------------------------------------
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
			AVL.APP_MAS_InfrastructureApplication IA(NOLOCK)
	WHERE 
			IA.ApplicationID=@applicationID;

		
	----------------------------------------------Extended Attributes-------------------------------------
	SELECT 			
			EAD.ApplicationID,EAD.UserBase,EAD.Incallwdgreen,
			EAD.Infraallwdgreen,EAD.Infoallwdgreen,EAD.Incallwdamber,EAD.Infraallwdamber,
			EAD.Infoallwdamber,EAD.SupportWindowID,EAD.SupportCategoryID,EAD.OtherSupportWindow
	FROM
		AVL.APP_MAS_Extended_ApplicationDetail EAD(NOLOCK)

	WHERE
		EAD.ApplicationID=@applicationID;  
		
		----------------------------------Quality attributes---------------------------------------
		select AQ.ApplicationID,AQ.NFRCaptured,AQ.IsUnitTestAutomated,AQ.TestingCoverage,AQ.IsRegressionTest
		,AQ.RegressionTestCoverage from PP.ApplicationQualityAttributes(NOLOCK) AQ 
		
		where AQ.ApplicationID=@applicationID

		------------------------------------UnitTesting attributes---------------------------------------
		SELECT DISTINCT 
			UTF.ApplicationID AS ApplicationID,
			STUFF((SELECT ', ' + Cast(AD.UnitTestFrameworkID  as varchar(10))
		FROM PP.MAP_UnitTestingFramework(NOLOCK) AD
        WHERE  AD.ApplicationID=@applicationID AND AD.ApplicationID = UTF.ApplicationID 
			   AND AD.IsDeleted=0
        ORDER BY UnitTestFrameworkID
        FOR XML PATH('')), 1, 1, '') [UnitTestFrameworkID]
			INTO #UnitTestList
			FROM  PP.MAP_UnitTestingFramework(NOLOCK) UTF
			WHERE UTF.ApplicationID=@applicationID
			GROUP BY UTF.ApplicationID, UTF.UnitTestFrameworkID
			ORDER BY 1
		SET @UnitTestID = (SELECT UnitTestFrameworkID FROM #UnitTestList(NOLOCK) WHERE ApplicationID=@applicationID)

		SET @OtherUnitTestName=(SELECT OtherUnitTestFramework FROM PP.MAP_UnitTestingFramework(NOLOCK) 
								WHERE ApplicationID=@applicationID AND UnitTestFrameworkID=@OtherUnitTestID)

		SELECT  @UnitTestID AS UnitTestFrameworkID,@OtherUnitTestName AS OtherUnitTestFramework

		DROP TABLE #UnitTestList
	SET NOCOUNT OFF;
	END TRY  
	BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		
		EXEC AVL_InsertError '[ADM].[APP_INV_GetCogApplicationAttributes]', @ErrorMessage, @UserID, @applicationID 
		
	END CATCH  

END
