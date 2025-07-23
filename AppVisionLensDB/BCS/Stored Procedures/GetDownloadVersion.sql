/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE  PROCEDURE [BCS].[GetDownloadVersion]


AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
 SELECT sm.Id UtilityId,sm.SolutionName UtilityName, count(b.Download) DownloadCount,VersionNumber, convert(varchar,LastUpdatedDate,107) LastUpdatedDate
 FROM [BCS].[SolutionMaster] sm  WITH (NOLOCK)
   LEFT join BCS.BCS_Version a WITH (NOLOCK)
   on sm.Id=a.UtilityId and  sm.IsDeleted=0 AND A.IsDeleted=0
  LEFT JOIN [BCS].[BriefcaseSolutionDetails]  b WITH (NOLOCK)
  ON a.UtilityId=b.SolutionId and b.IsDeleted=0
  group by  SolutionName,VersionNumber,Id,LastUpdatedDate
  order by sm.Id
END TRY
BEGIN CATCH
DECLARE @errorMessage VARCHAR(MAX);

		SELECT @errorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[BCS].[GetBriefcaseSolutionDetails]',@errorMessage,'',0
END CATCH
END