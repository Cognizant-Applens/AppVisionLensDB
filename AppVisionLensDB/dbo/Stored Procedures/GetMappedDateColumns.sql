/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [dbo].[GetMappedDateColumns]
    @ProjectID INT,
	@UserID VARCHAR(10)
    
AS 
    BEGIN
       
	BEGIN TRY
SET NOCOUNT ON;

SELECT
	SSIS_Column.ProjectColumn
FROM AVL.ITSM_PRJ_SSISColumnMapping SSIS_Column (NOLOCK)
INNER JOIN [AVL].[ITSM_MAS_Columnname] (NOLOCK) Master_Column
	ON Master_Column.name = SSIS_Column.ServiceDartColumn
	AND SSIS_Column.IsDeleted = 0
	AND Master_Column.Isdeleted = 0
	AND 
	--(Master_Column.name LIKE '%date%' OR Master_Column.name LIKE '%time%')
	(Master_Column.name in (
	'Actual End date Time',
	'Actual Start date Time',
	'Assigned Time Stamp',
	'Cancelled Date Time',
	'Close Date',
	'Completed Date Time',
	'Expected Completion Date',
	'Modified Date Time',
	'On Hold Date Time',
	'Open Date',
	'Planned End Date',
	'Planned Start Date and Time',
	'Rejected Time Stamp',
	'Reopen Date',
	'Started Date Time',
	'WIP Date Time'
	))
	AND Master_Column.name != 'KEDB updated'
WHERE SSIS_Column.ProjectID = @ProjectID


END TRY BEGIN CATCH

DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()

--INSERT Error    
EXEC AVL_InsertError	'[dbo].[[GetMappedDateColumns]] '
						,@ErrorMessage
						,@ProjectID
						,@UserID

END CATCH
SET NOCOUNT OFF
END
