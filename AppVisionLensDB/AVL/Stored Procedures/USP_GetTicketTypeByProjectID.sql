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
-- EXEC [AVL].[USP_GetTicketTypeByProjectID] '44669,44671,44672,44673,44674',1
CREATE PROCEDURE [AVL].[USP_GetTicketTypeByProjectID]
	-- Add the parameters for the stored procedure here
	@ProjectID VARCHAR(MAX),
	@IsCognizant int=0
AS
BEGIN

IF (@IsCognizant = 1) BEGIN
SELECT DISTINCT
	CAST(TT.TicketTypeID AS INT) AS TicketTypeID
	,TT.TicketTypeName,ISNULL(TM.SupportTypeID,0) AS SupportTypeID
FROM [AVL].[TK_MAP_TicketTypeMapping] TM
INNER JOIN AVL.TK_MAS_TicketType TT
	ON TT.TicketTypeID = TM.AVMTicketType
WHERE TM.ProjectID IN (SELECT
		item
	FROM split(@ProjectID, ','))
AND TM.IsDeleted = 0 and TT.IsDeleted=0 AND TM.AVMTicketType <> 20--AND TM.DebtConsidered ='Y'
END
else
BEGIN
SELECT DISTINCT
	CAST(TM.TicketTypeMappingID AS INT) AS TicketTypeID
	,TM.TicketType as TicketTypeName,ISNULL(TM.SupportTypeID,0) AS SupportTypeID
FROM [AVL].[TK_MAP_TicketTypeMapping] TM

WHERE TM.ProjectID IN (SELECT
		item
	FROM split(@ProjectID, ','))
AND TM.IsDeleted = 0 AND ISNULL(TM.AVMTicketType,0) <> 20 --AND TM.DebtConsidered ='Y'
END
END

--select * from [AVL].[TK_MAP_TicketTypeMapping]  where ProjectID=44655 
