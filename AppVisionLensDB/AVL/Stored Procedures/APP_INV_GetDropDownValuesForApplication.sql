/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[APP_INV_GetDropDownValuesForApplication] 
	
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
						AVL.APP_MAS_BusinessCriticality BC
						WITH(NOLOCK)
				WHERE
						BC.IsDeleted=0

/*--------------------------------CODE OWNERSHIP-------------------------*/
	IF EXISTS(SELECT 1 FROM AVL.Customer WHERE CustomerID=@CustomerID AND IsCognizant=0)
	BEGIN
					SELECT 
							OD.ApplicationTypeID AS 'CodeOwnershipID' ,
							OD.ApplicationTypename AS 'CodeOwnershipName'
					FROM
							AVL.APP_MAS_OwnershipDetails OD
							WITH(NOLOCK)
					WHERE
							OD.IsDeleted=0 AND OD.ApplicationTypeID!=1;
	END
	ELSE
	BEGIN
	SELECT 
							OD.ApplicationTypeID AS 'CodeOwnershipID' ,
							OD.ApplicationTypename AS 'CodeOwnershipName'
					FROM
							AVL.APP_MAS_OwnershipDetails OD
							WITH(NOLOCK)
					WHERE
							OD.IsDeleted=0 AND OD.ApplicationTypeID!=5;
	END


/*--------------------------------PRIMARY TECHNOLOGY-------------------------*/

				SELECT 
							PT.PrimaryTechnologyID,
							PT.PrimaryTechnologyName
					FROM
							AVL.APP_MAS_PrimaryTechnology PT
							WITH(NOLOCK)
					WHERE 
							PT.IsDeleted=0 ORDER BY PT.PrimaryTechnologyName ASC;

/*--------------------------------REGULATORY COMPLIANT-------------------------*/

			SELECT 
						RC.RegulatoryCompliantID,
						RC.RegulatoryCompliantName
				FROM
						AVL.APP_MAS_RegulatoryCompliant RC
						WITH(NOLOCK)
				WHERE
						RC.IsDeleted=0;

/*--------------------------------DEBT CONTROL-------------------------*/

			SELECT 
						DS.DebtcontrolScopeID,
						DS.DebtcontrolScopeName
				FROM
						AVL.APP_MAS_DebtcontrolScope DS
						WITH(NOLOCK)
				WHERE
						DS.IsDeleted=0;
/*--------------------------------HOSTED ENVIRONMENT-------------------------*/

			SELECT 
					HE.HostedEnvironmentID,
					HE.HostedEnvironmentName
			FROM
					AVL.APP_MAS_HostedEnvironment HE
					WITH(NOLOCK)

			WHERE
					HE.Isdeleted=0;
/*--------------------------------SUB BUSINESS CLUSTER MAP ID-------------------------*/

			SELECT 
					BC.BusinessClusterMapID,
					BC.BusinessClusterBaseName
			FROM
					AVL.BusinessClusterMapping BC
					WITH(NOLOCK)

			WHERE
					BC.Isdeleted=0 
			AND
					BC.CustomerID=@CustomerID
			AND	
					BC.BusinessClusterID IS NOT NULL
			AND 
					BC.ParentBusinessClusterMapID IS NOT NULL
			AND
					BC.IsHavingSubBusinesss=0;

/*************************************CLUSTER LABEL*****************************/

			SELECT 
					BC.BusinessClusterName AS 'ClusterLabel' 
			FROM 
					AVL.BusinessCluster BC 
					WITH(NOLOCK)
			WHERE 
					CustomerID=@customerID 
			AND 
					BC.IsHavingSubBusinesss=0
			AND 
					BC.IsDeleted=0;
/*************************************SUPPORT WINDOW*****************************/

			SELECT 
					SW.SupportWindowID,SW.SupportWindowName 
			FROM 
					AVL.APP_MAS_SupportWindow SW 
					WITH(NOLOCK)
			WHERE 
					SW.IsDeleted=0;
/*************************************SUPPORT CATEGORY*****************************/

			SELECT 
					SC.SupportCategoryID,SC.SupportCategoryName 
			FROM 
					AVL.APP_MAS_SupportCategory SC 
					WITH(NOLOCK)
			WHERE 
					SC.IsDeleted=0;
/*************************************COGNIZANT CUSTOMER*****************************/

			SELECT 
					C.IsCognizant 
			FROM 
					AVL.Customer C 
					WITH(NOLOCK)
			WHERE 
					C.CustomerID=@CustomerID;
/*--------------------------------Cloud Service Provider-------------------------*/

			SELECT 
					CSP.CloudServiceProviderID,
					CSP.CloudServiceProviderName,
					CSP.HostedEnvironmentName
			FROM
					AVL.APP_MAS_CloudServiceProvider CSP
					WITH(NOLOCK)

			WHERE
					CSP.Isdeleted=0;

		
/*--------------------------------Cloud Model Provider-------------------------*/

			SELECT 
					CloudModelID,
					CloudModelName 
			FROM    [MAS].[MAS_CloudModelProvider](NOLOCK) 
			WHERE   IsDeleted=0


/* -------------------------------Excluded Words ----------------------------*/

	 SELECT ExcludedWordID AS Id,ExcludedWordName AS [ExcludeName] FROM MAS.ExcludedWords WHERE IsDeleted = 0

/*----------------------------------END TRY--------------------------------*/

END TRY  

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

	  
		EXEC AVL_InsertError '[AVL].[APP_INV_GetDropDownValuesForApplication]', @ErrorMessage, @UserID, 0 
		
	END CATCH  
END
