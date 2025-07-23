/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


--[dbo].[GetTicketStatus] 4
CREATE PROCEDURE [dbo].[GetTicketStatus] --4
@ProjectId BIGINT

AS
BEGIN
BEGIN TRY
	--SELECT distinct SM.StatusID as StatusID,TS.DARTStatusName as StatusName ,SM.TicketStatus_ID as DartStatus FROM [AVL].TK_MAP_ProjectStatusMapping  SM
	--INNER JOIN [AVL].[TK_MAS_DARTTicketStatus] TS
	--ON TS.DARTStatusID =SM.TicketStatus_ID
	--AND SM.ProjectID=@ProjectId where SM.ISDeleted=0
	select distinct PSM.StatusID as StatusID,PSM.StatusName as StatusName,Dt.DARTStatusID as DartStatus
from  AVL.TK_MAP_ProjectStatusMapping PSM join  AVL.TK_MAS_DARTTicketStatus DT on DT.DARTStatusID=PSM.TicketStatus_ID
where PSM.ProjectID=@ProjectID AND PSM.IsDeleted=0

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[GetTicketStatus] ', @ErrorMessage, @ProjectId,0
		
	END CATCH  



END
