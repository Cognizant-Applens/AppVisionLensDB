/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE ProcEDURE [AVL].[Effort_GetProjectBasedTicketStatusDetails] 

--[AVL].[Effort_GetProjectBasedTicketStatusDetails]  4

 @ProjectID bigint

AS

BEGIN

BEGIN TRY
SET NOCOUNT ON

CREATE TABLE #Status(
StatusID BIGINT,
StatusName nvarchar(500),
[Type] CHAR(1))

DECLARE @IsALMConfigured Bit;
SET @IsALMConfigured = (SELECT Top 1 IsApplensAsALM FROM PP.ScopeOfWork(NOLOCK) where ProjectId =@ProjectId and IsDeleted = 0)
INSERT INTO #Status
SELECT DISTINCT PSM.StatusID as StatusID,PSM.StatusName as StatusName,'T' AS [Type]
FROM  AVL.TK_MAP_ProjectStatusMapping PSM With (NOLOCK) JOIN  AVL.TK_MAS_DARTTicketStatus(NOLOCK) DT
on DT.DARTStatusID=PSM.TicketStatus_ID
WHERE PSM.ProjectID=@ProjectID AND PSM.IsDeleted=0
ORDER BY PSM.StatusName

IF(ISNULL(@IsALMConfigured,0))=1
BEGIN
INSERT INTO  #Status
SELECT StatusMapId AS StatusID, ProjectStatusName AS StatusName,'W' AS [Type] FROM PP.ALM_MAP_Status With (NOLOCK) 
WHERE IsDeleted = 0 AND IsDefault = 'Y'
ORDER BY StatusName

END
ELSE
BEGIN
INSERT INTO #Status
SELECT	StatusMapId AS StatusID,ProjectStatusName AS StatusName,'W' AS [Type] FROM PP.ALM_MAP_Status With (NOLOCK) 
WHERE ProjectId =@ProjectID AND IsDeleted = 0
ORDER BY StatusName
END

SELECT StatusId,StatusName,[Type] FROM #Status With (NOLOCK)
SET NOCOUNT OFF
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    

		EXEC AVL_InsertError ' [AVL].[Effort_GetProjectBasedTicketStatusDetails]', @ErrorMessage, @ProjectID,0

	END CATCH  

END
