/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [SA].[ApplicationMaster] AS SELECT
       AppDetails.ApplicationID                                     AS ApplicationID
       ,AppDetails.ApplicationName                                   AS ApplicationName
       ,AppData.ApplicationType                                                   AS ApplicationType
       ,BusinessCriticality.BusinessCriticalityName    AS ApplicationCriticality
       ,AppData.BusinessCluster                                                   AS BusinessCluster
       ,AppData.SubCluster                                                        AS SubCluster
       ,Technology.PrimaryTechnologyName                      AS TechnologyStack
       ,AppData.BusinessOwner                                                     AS BusinessOwner
       ,AppData.SystemOwner                                                             AS SystemOwner
       ,ISNULL(ExtAppDetails.Incallwdgreen,99)        AS IncidentAllowedGreen
     ,ISNULL(ExtAppDetails.Infraallwdgreen,25)         AS InfraAllowedGreen
     ,ISNULL(ExtAppDetails.Incallwdamber,98)           AS IncidentAllowedAmber
     ,ISNULL(ExtAppDetails.Infraallwdamber,75)         AS InfraAllowedAmber
       ,AppDetails.ApplicationDescription                           AS ApplicationComments
FROM 
SA.ApplicationHierarchy AppData
INNER JOIN AVL.APP_MAS_ApplicationDetails AppDetails
ON AppData.ApplicationID = AppDetails.ApplicationID
INNER JOIN AVL.APP_MAS_BusinessCriticality BusinessCriticality
ON AppDetails.BusinessCriticalityID=BusinessCriticality.BusinessCriticalityID
INNER JOIN AVL.APP_MAS_PrimaryTechnology Technology 
ON Technology.PrimaryTechnologyID=AppDetails.PrimaryTechnologyID
LEFT JOIN AVL.APP_MAS_Extended_ApplicationDetail ExtAppDetails
ON ExtAppDetails.ApplicationID = AppDetails.ApplicationID
WHERE AppDetails.IsActive=1 AND BusinessCriticality.IsDeleted=0 AND Technology.IsDeleted=0
