/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [BCS].[GetSolutionDownloads]

@solutionName nvarchar(100)
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
select  count ([RecordId]) AS DownloadCount,A.SolutionId
  FROM [BCS].[BriefcaseSolutionDetails] A join [BCS].[SolutionMaster] B on A.SolutionId = B.Id where  B.SolutionName = @solutionName
  Group by SolutionId

END TRY
BEGIN CATCH
DECLARE @errorMessage VARCHAR(MAX);

		SELECT @errorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[BCS].[GetBriefcaseSolutionDetails]',@errorMessage,'',0
END CATCH
END
