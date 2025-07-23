/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [dbo].[vw_applicationDetails]
AS
SELECT 
DISTINCT AD.ApplicationID,CAST(AD.ApplicationName as NVARCHAR(100)) AS ApplicationName
,AD.ApplicationCode,AD.ApplicationShortName
,APPGRP.BusinessClusterID,APPGRP.BusinessClusterBaseName
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
,IA.HostedEnvironmentID,HE.HostedEnvironmentName
,CSP.CloudServiceProviderID
,CSP.CloudServiceProviderName
,C.CustomerID
,CMP.CloudModelName
,CASE WHEN AD.IsActive = 1 THEN 'Yes' ELSE 'No' END Active
FROM AVL.Customer C
INNER JOIN AVL.BusinessCluster BC 
ON C.CustomerID=BC.CustomerID
INNER JOIN AVL.BusinessClusterMapping LOB on bc.BusinessClusterID=lob.BusinessClusterID
join AVL.BusinessClusterMapping  TRK ON TRK.ParentBusinessClusterMapID = LOB.BusinessClusterMapID
join AVL.BusinessClusterMapping APPGRP ON APPGRP.ParentBusinessClusterMapID = TRK.BusinessClusterMapID AND APPGRP.IsHavingSubBusinesss = 0
INNER JOIN AVL.APP_MAS_ApplicationDetails AD
ON APPGRP.BusinessClusterMapID=AD.SubBusinessClusterMapID
LEFT JOIN AVL.APP_MAS_OwnershipDetails OD ON AD.CodeOwnerShip=OD.ApplicationTypeID
LEFT JOIN AVL.APP_MAS_BusinessCriticality CR ON AD.BusinessCriticalityID=CR.BusinessCriticalityID
LEFT JOIN AVL.APP_MAS_PrimaryTechnology PT ON AD.PrimaryTechnologyID=PT.PrimaryTechnologyID
LEFT JOIN AVL.APP_MAS_RegulatoryCompliant RC ON AD.RegulatoryCompliantID=RC.RegulatoryCompliantID
LEFT JOIN AVL.APP_MAS_DebtcontrolScope DC ON AD.DebtControlScopeID=DC.DebtcontrolScopeID
LEFT JOIN AVL.APP_MAS_Extended_ApplicationDetail EA ON AD.ApplicationID=EA.ApplicationID
LEFT JOIN AVL.APP_MAS_SupportWindow SW ON EA.SupportWindowID=SW.SupportWindowID
LEFT JOIN AVL.APP_MAS_SupportCategory SC ON EA.SupportCategoryID=SC.SupportCategoryID
LEFT JOIN AVL.APP_MAS_InfrastructureApplication IA ON AD.ApplicationID=IA.ApplicationID
LEFT JOIN AVL.APP_MAS_HostedEnvironment HE ON IA.HostedEnvironmentID=HE.HostedEnvironmentID
LEFT JOIN avl.APP_MAS_CloudServiceProvider CSP ON CSP.CloudServiceProviderID=IA.CloudServiceprovider
LEFT JOIN MAS.MAS_CloudModelProvider(NOLOCK) CMP ON CMP.CloudModelID=IA.CloudModelID
WHERE
AD.ApplicationID IS NOT NULL AND AD.ApplicationName IS NOT NULL 
AND APPGRP.IsHavingSubBusinesss=0 and lob.IsDeleted='0' and trk.IsDeleted='0' and APPGRP.IsDeleted='0'
