/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[CL_GetEnrichmentDate] 
(
@ProjectID  NVARCHAR(200)
)
AS 
BEGIN 
BEGIN TRY
SET NOCOUNT ON;

DECLARE @FromDate DATETIME

SET @FromDate = (SELECT MIN(CreatedDate) FROM AVL.CL_TRN_PatternValidation WHERE ProjectID = @ProjectID AND PatternsOrigin = 'CL' AND IsDeleted = 0)
SET @FromDate = (SELECT TOP 1 StartDateTime FROM AVL.CL_ProjectJobDetails WHERE ProjectID = @ProjectID AND CONVERT(DATE, JobDate) = CONVERT(DATE, @FromDate))

SELECT @FromDate AS FromDate, MAX(CreatedDate) AS ToDate FROM [AVL].[CL_TRN_PatternValidation] (NOLOCK) 
WHERE ProjectID = @ProjectID 
AND IsDeleted = 0
AND PatternsOrigin = 'CL'


END TRY
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[CL_GetEnrichmentDate] ', @ErrorMessage, @ProjectID
		
END CATCH  	
END
