/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================= 
-- Author:    683989 
-- Create date: 10/02/2019
-- Description:   SP for get all Standard CC and RC Values
-- ML.GetStandardRCAndCCDetailsForMigration 10337
-- =============================================  
CREATE PROCEDURE [ML].[GetStandardRCAndCCDetailsForMigration]
(
	@ProjectID int
)
AS
BEGIN
	DECLARE @IsDeleted INT = 0
	SET NOCOUNT ON

	SELECT ClusterID,ClusterName,CategoryID from mas.Cluster(nolock)
	where IsDeleted = @IsDeleted

	SELECT C.ProjectID,ISNULL(CauseStatusId,'') as CauseStatusId,
	CauseId,
	CASE WHEN isnull(P.IsMultilingualEnabled,0) = 0 THEN ISNULL(CauseCode,'')
	ELSE MCauseCode END AS CauseCodeName	
	FROM avl.DEBT_MAP_CauseCode C
	JOIN AVL.MAS_ProjectMaster(NOLOCK) P
	ON P.ProjectID=C.ProjectID
	AND P.IsDeleted =@IsDeleted
	WHERE C.IsDeleted = @IsDeleted
	AND isnull(P.IsMultilingualEnabled,0) <> 1
	and isnull(c.CauseStatusID,0) = 0
	and p.ProjectID=@ProjectID
			

	SELECT R.ProjectID,
	ResolutionId,
	ISNULL(ResolutionStatusID,'') AS ResolutionStatusID,
	CASE WHEN isnull(P.IsMultilingualEnabled,0) = 0 THEN ISNULL(ResolutionCode,'')
	ELSE MResolutionCode END AS ResolutionCode
	FROM avl.DEBT_MAP_ResolutionCode R
	JOIN AVL.MAS_ProjectMaster(NOLOCK) P
	ON P.ProjectID=R.ProjectID
	AND P.IsDeleted =@IsDeleted
	WHERE  R.IsDeleted = @IsDeleted
	AND isnull(P.IsMultilingualEnabled,0) <> 1
	and isnull(r.ResolutionStatusID,0)= 0
	and p.ProjectID=@ProjectID



	SET NOCOUNT OFF
END
