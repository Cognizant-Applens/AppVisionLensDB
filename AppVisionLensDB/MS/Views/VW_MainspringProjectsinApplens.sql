/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--CREATE VIEW [MS].[VW_MainspringProjectsinApplens]
--AS

--	SELECT EsaProjectID AS EsaProjectID,ProjectID AS ProjectID FROM AVL.MAS_ProjectMaster(NOLOCK)
--	WHERE IsMainSpringConfigured='Y' 
--		AND IsMigratedFromDART IN(0,1)
--		AND EsaProjectID IN(	
--			SELECT DISTINCT PROJECTID FROM [CTSC00698426801].[Swiftalm].[Swiftalm].[CTS_AVM_DART_ACTIVITIES_VIEW]
--			WHERE projectid IS NOT NULL)
