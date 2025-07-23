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
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- EXEC AVL.USP_GetTicketStatusByProjectID 10337
CREATE PROCEDURE [AVL].[USP_GetTicketStatusByProjectID]
	@ProjectID VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT 
		CAST(DT.DARTStatusID AS INT) AS StatusID, DT.DARTStatusName AS StatusName
	FROM 
		AVL.TK_MAP_ProjectStatusMapping (NOLOCK) PSM 
	JOIN 
		AVL.TK_MAS_DARTTicketStatus (NOLOCK) DT 
	ON 
		DT.DARTStatusID = PSM.TicketStatus_ID
	WHERE 
		PSM.ProjectID IN (SELECT item FROM split(@ProjectID,',')) 
	AND 
		PSM.IsDeleted = 0
		ORDER BY DT.DARTStatusName
END
