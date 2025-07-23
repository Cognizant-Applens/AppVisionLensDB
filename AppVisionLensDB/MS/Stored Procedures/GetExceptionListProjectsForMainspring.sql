/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
--EXEC [MS].[GetExceptionListProjectsForMainspring]
CREATE PROCEDURE [MS].[GetExceptionListProjectsForMainspring]

AS
BEGIN	
    SET NOCOUNT ON;
	SELECT ProjectID AS ProjectId,
	ProjectName AS ProjectName
	FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE IsMainSpringConfigured='Y' AND IsODCRestricted='Y' AND 
	ISNULL(IsDeleted,0)=0
	SET NOCOUNT OFF;

	
	
END
