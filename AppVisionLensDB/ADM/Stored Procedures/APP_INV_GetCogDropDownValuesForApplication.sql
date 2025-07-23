/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ADM].[APP_INV_GetCogDropDownValuesForApplication] --'627129',7097
	
	@UserID NVARCHAR(50),
	@CustomerID BIGINT
AS
BEGIN
BEGIN TRY

SET NOCOUNT ON;
/*--------------------------------BUSINESS CRTICALITY-------------------------*/
				SELECT 
						BC.BusinessCriticalityID,
						BC.BusinessCriticalityName
				FROM
						AVL.APP_MAS_BusinessCriticality BC(NOLOCK)
				WHERE
						BC.IsDeleted=0
				ORDER BY
						BC.BusinessCriticalityName ASC

/*--------------------------------CODE OWNERSHIP-------------------------*/
	IF EXISTS(SELECT 1 FROM AVL.Customer WHERE CustomerID=@CustomerID AND IsCognizant=0)
	BEGIN
					SELECT 
							OD.ApplicationTypeID AS 'CodeOwnershipID' ,
							OD.ApplicationTypename AS 'CodeOwnershipName'
					FROM
							AVL.APP_MAS_OwnershipDetails OD(NOLOCK)
					WHERE
							OD.IsDeleted=0 AND OD.ApplicationTypeID!=1
					ORDER BY
							OD.ApplicationTypename ASC
	END
	ELSE
	BEGIN
	SELECT 
							OD.ApplicationTypeID AS 'CodeOwnershipID' ,
							OD.ApplicationTypename AS 'CodeOwnershipName'
					FROM
							AVL.APP_MAS_OwnershipDetails OD(NOLOCK)
					WHERE
							OD.IsDeleted=0 AND OD.ApplicationTypeID!=5
					ORDER BY
							OD.ApplicationTypename ASC
	END


/*--------------------------------PRIMARY TECHNOLOGY-------------------------*/

				SELECT 
							PT.PrimaryTechnologyID,
							PT.PrimaryTechnologyName
					FROM
							AVL.APP_MAS_PrimaryTechnology PT(NOLOCK)
					WHERE 
							PT.IsDeleted=0 ORDER BY PT.PrimaryTechnologyName ASC;

/*--------------------------------HOSTED ENVIRONMENT-------------------------*/

			SELECT 
					HE.HostedEnvironmentID,
					HE.HostedEnvironmentName
			FROM
					AVL.APP_MAS_HostedEnvironment HE(NOLOCK)

			WHERE
					HE.Isdeleted=0
			ORDER BY
					HE.HostedEnvironmentName ASC
/*--------------------------------SUB BUSINESS CLUSTER MAP ID App Scope-------------------------*/

			SELECT 
					BC.BusinessClusterMapID,
					BC.BusinessClusterBaseName
			FROM
					AVL.BusinessClusterMapping BC(NOLOCK)

			WHERE
					BC.Isdeleted=0 
			AND
					BC.CustomerID=@CustomerID
			AND	
					BC.BusinessClusterID IS NOT NULL
			AND 
					BC.ParentBusinessClusterMapID IS NOT NULL
			AND
					BC.IsHavingSubBusinesss=0
			ORDER BY
					BC.BusinessClusterBaseName ASC

/*************************************CLUSTER LABEL*****************************/

			SELECT 
					BC.BusinessClusterName AS 'ClusterLabel' 
			FROM 
					AVL.BusinessCluster BC(NOLOCK)
			WHERE 
					CustomerID=@customerID 
			AND 
					BC.IsHavingSubBusinesss=0
			AND 
					BC.IsDeleted=0
			ORDER BY
					BC.BusinessClusterName ASC
/*************************************SUPPORT WINDOW*****************************/

			SELECT 
					SW.SupportWindowID,SW.SupportWindowName 
			FROM 
					AVL.APP_MAS_SupportWindow SW(NOLOCK)
			WHERE 
					SW.IsDeleted=0
			
/*************************************SUPPORT CATEGORY*****************************/

			SELECT 
					SC.SupportCategoryID,SC.SupportCategoryName 
			FROM 
					AVL.APP_MAS_SupportCategory SC(NOLOCK)
			WHERE 
					SC.IsDeleted=0
			ORDER BY
					SC.SupportCategoryName ASC
/*************************************COGNIZANT CUSTOMER*****************************/

			SELECT 
					C.IsCognizant 
			FROM 
					AVL.Customer C(NOLOCK)
			WHERE 
					C.CustomerID=@CustomerID;
/*--------------------------------Cloud Service Provider-------------------------*/

			SELECT 
					CSP.CloudServiceProviderID,
					CSP.CloudServiceProviderName,
					CSP.HostedEnvironmentName
			FROM
					AVL.APP_MAS_CloudServiceProvider CSP(NOLOCK)

			WHERE
					CSP.Isdeleted=0
			ORDER BY
					CSP.CloudServiceProviderName ASC

		
/*--------------------------------Cloud Model Provider-------------------------*/

			SELECT 
					CloudModelID,
					CloudModelName 
			FROM    [MAS].[MAS_CloudModelProvider](NOLOCK) 
			WHERE   IsDeleted=0
			ORDER BY CloudModelName ASC


/* -------------------------------Excluded Words ----------------------------*/

	 SELECT ExcludedWordID AS Id,ExcludedWordName AS [ExcludeName] FROM MAS.ExcludedWords(NOLOCK) WHERE IsDeleted = 0
	 

/* -------------------------------Geographies ----------------------------*/

SELECT ID AS GeographID,GeographiesName AS GeographiesName FROM ADM.GeographiesSupported(NOLOCK) WHERE IsDeleted = 0
ORDER BY GeographiesName ASC

/* -------------------------------FUNCTIONAL KNOWLWDGE----------------------------*/

SELECT ID AS FunctionalID,FunctionalKnowledgeName AS FunctionalName FROM ADM.FunctionalKnowledge(NOLOCK) WHERE IsDeleted = 0
ORDER BY FunctionalKnowledgeName ASC

/* -------------------------------EXECUTION METHOD ----------------------------*/

--SELECT ID AS ExecutionID,ExecutionMethodName AS ExecutionName FROM ADM.ExecutionMethod WHERE IsDeleted = 0
--ORDER BY ExecutionMethodName ASC
--select DISTINCT PAV.AttributeValueID AS ExecutionID, PPA.AttributeValueName AS ExecutionName from PP.ProjectAttributeValues (NOLOCK) PAV
--	INNER JOIN Mas.PPAttributeValues (NOLOCK) PPA ON PPA.AttributeID = PAV.AttributeID AND PPA.AttributeValueID = PAV.AttributeValueID AND PAV.IsDeleted = 0
--	AND PPA.IsDeleted = 0
--	INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0
--	WHERE AttributeName = 'ExecutionMethod' AND ProjectID IN (SELECT DISTINCT PM.ProjectID FROM AVL.Customer(NOLOCK) C 
--	INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.CustomerID=C.CustomerID AND PM.IsDeleted=0
--	AND C.IsDeleted=0 and c.CustomerID = @CustomerID) ORDER BY PPA.AttributeValueName ASC

IF EXISTS
(
select DISTINCT PAV.AttributeValueID AS ExecutionID, PPA.AttributeValueName AS ExecutionName from PP.ProjectAttributeValues (NOLOCK) PAV
	INNER JOIN Mas.PPAttributeValues (NOLOCK) PPA ON PPA.AttributeID = PAV.AttributeID AND PPA.AttributeValueID = PAV.AttributeValueID AND PAV.IsDeleted = 0
	AND PPA.IsDeleted = 0
	INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0
	WHERE AttributeName = 'ExecutionMethod' AND ProjectID IN (SELECT DISTINCT PM.ProjectID FROM AVL.Customer(NOLOCK) C 
	INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.CustomerID=C.CustomerID AND PM.IsDeleted=0
	AND C.IsDeleted=0 and c.CustomerID = @CustomerID))
	BEGIN
	select DISTINCT PAV.AttributeValueID AS ExecutionID, PPA.AttributeValueName AS ExecutionName from PP.ProjectAttributeValues (NOLOCK) PAV
	INNER JOIN Mas.PPAttributeValues (NOLOCK) PPA ON PPA.AttributeID = PAV.AttributeID AND PPA.AttributeValueID = PAV.AttributeValueID AND PAV.IsDeleted = 0
	AND PPA.IsDeleted = 0
	INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0
	WHERE AttributeName = 'ExecutionMethod' AND ProjectID IN (SELECT DISTINCT PM.ProjectID FROM AVL.Customer(NOLOCK) C 
	INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.CustomerID=C.CustomerID AND PM.IsDeleted=0
	AND C.IsDeleted=0 and c.CustomerID = @CustomerID) ORDER BY PPA.AttributeValueName ASC
	END
ELSE
BEGIN

SELECT '0' AS ExecutionID,'NA' AS ExecutionName

END
/* -------------------------------Regulatory Body----------------------------*/

SELECT ID AS RegulatoryID,RegulatoryBodyName AS RegulatoryBodyName  FROM ADM.RegulatoryBody(NOLOCK) WHERE IsDeleted = 0
ORDER BY RegulatoryBodyName ASC

/* -------------------------------Source Code Availability----------------------------*/

SELECT ID AS SourceCodeID,SourceCodeName AS SourceName FROM ADM.SourceCodeAvailability(NOLOCK) WHERE IsDeleted = 0
ORDER BY SourceCodeName ASC

/* -------------------------------Application Scope----------------------------*/

SELECT ID AS ApplicationScopeID,ScopeName AS ApplicationScopeName FROM ADM.ApplicationScope(NOLOCK) WHERE IsDeleted = 0
ORDER BY ScopeName ASC

/*---------------------------------Execution scope-------------------------------------*/

SELECT ProjectID INTO #Projects FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE CustomerID=@CustomerID

SELECT COUNT(DISTINCT AttributeValueID) AS ExecCount FROM PP.ProjectAttributeValues(NOLOCK) WHERE AttributeID=3 
AND IsDeleted= 0 AND ProjectID IN (SELECT ProjectID FROM #Projects)

/*---------------------------------Unit testing framework-------------------------------------*/

select UnitTestFrameworkID As FrameworkID,FrameWorkName from [PP].[MAS_UnitTestingFramework](NOLOCK) 
where IsDeleted=0 ORDER by FrameWorkName ASC



/*----------------------------------END TRY--------------------------------*/
SET NOCOUNT OFF;
END TRY  

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

	  
		EXEC AVL_InsertError '[ADM].[APP_INV_GetCogDropDownValuesForApplication]', @ErrorMessage, @UserID, 0 
		
	END CATCH  
END
