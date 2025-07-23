/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



CREATE VIEW [dbo].[VW_Applens_ApplicationAttributes]  AS 

SELECT 
C.ESA_AccountID, C.CustomerName,
AD.ApplicationID,cast(AD.ApplicationName as NVARCHAR(100)) as ApplicationName
,AD.ApplicationCode,AD.ApplicationShortName
,BCM.BusinessClusterID,BCM.BusinessClusterBaseName
,AD.CodeOwnerShip,OD.ApplicationTypename
,AD.BusinessCriticalityID,CR.BusinessCriticalityName
,AD.PrimaryTechnologyID,PT.PrimaryTechnologyName
,AD.ProductMarketName,AD.ApplicationDescription
,AD.ApplicationCommisionDate
,AD.RegulatoryCompliantID,RC.RegulatoryCompliantName
,AD.DebtControlScopeID,DC.DebtcontrolScopeName
,EA.UserBase
,EA.SupportWindowID,SW.SupportWindowName
,EA.Incallwdgreen,EA.Infraallwdgreen,EA.Incallwdamber
,EA.Infraallwdamber,EA.Infoallwdamber,EA.Infoallwdgreen
,EA.SupportCategoryID,SC.SupportCategoryName
,IA.OperatingSystem,IA.ServerConfiguration,IA.ServerOwner
,IA.LicenseDetails,IA.DatabaseVersion
,IA.HostedEnvironmentID,HE.HostedEnvironmentName,CSP.CloudServiceProviderName
FROM AVL.Customer(NOLOCK) C
INNER JOIN AVL.BusinessCluster(NOLOCK) BC 
ON C.CustomerID=BC.CustomerID
INNER JOIN AVL.BusinessClusterMapping(NOLOCK) BCM
ON BC.BusinessClusterID=BCM.BusinessClusterID
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
ON BCM.BusinessClusterMapID=AD.SubBusinessClusterMapID
LEFT JOIN AVL.APP_MAS_OwnershipDetails(NOLOCK) OD ON AD.CodeOwnerShip=OD.ApplicationTypeID
LEFT JOIN AVL.APP_MAS_BusinessCriticality(NOLOCK) CR ON AD.BusinessCriticalityID=CR.BusinessCriticalityID
LEFT JOIN AVL.APP_MAS_PrimaryTechnology(NOLOCK) PT ON AD.PrimaryTechnologyID=PT.PrimaryTechnologyID
LEFT JOIN AVL.APP_MAS_RegulatoryCompliant(NOLOCK) RC ON AD.RegulatoryCompliantID=RC.RegulatoryCompliantID
LEFT JOIN AVL.APP_MAS_DebtcontrolScope(NOLOCK) DC ON AD.DebtControlScopeID=DC.DebtcontrolScopeID
LEFT JOIN AVL.APP_MAS_Extended_ApplicationDetail(NOLOCK) EA ON AD.ApplicationID=EA.ApplicationID
LEFT JOIN AVL.APP_MAS_SupportWindow(NOLOCK) SW ON EA.SupportWindowID=SW.SupportWindowID
LEFT JOIN AVL.APP_MAS_SupportCategory(NOLOCK) SC ON EA.SupportCategoryID=SC.SupportCategoryID
LEFT JOIN AVL.APP_MAS_InfrastructureApplication(NOLOCK) IA ON AD.ApplicationID=IA.ApplicationID
LEFT JOIN AVL.APP_MAS_HostedEnvironment(NOLOCK) HE ON IA.HostedEnvironmentID=HE.HostedEnvironmentID
LEFT JOIN avl.APP_MAS_CloudServiceProvider(NOLOCK) CSP ON CSP.CloudServiceProviderID=IA.CloudServiceprovider
WHERE AD.ApplicationID is NOT NULL AND AD.ApplicationName is NOT NULL 
AND AD.IsActive=1 AND BCM.IsHavingSubBusinesss=0
