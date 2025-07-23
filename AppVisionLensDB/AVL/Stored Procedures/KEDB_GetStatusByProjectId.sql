/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetStatusByProjectId]
@ProjectID bigint  
AS
BEGIN  
 
BEGIN TRY 
  SET NOCOUNT ON;  
 SELECT StatusID as DARTStatusID,StatusName as DARTStatusName,DTS.DARTStatusID as MasterId
 FROM [AVL].[TK_MAP_ProjectStatusMapping] PSM  
 INNER join [AVL].[TK_MAS_DARTTicketStatus] DTS   
 ON PSM.TicketStatus_ID=DTS.DARTStatusID   
 WHERE PSM.ProjectID=@ProjectID and DTS.IsDeleted=0 AND PSM.IsDeleted=0 AND PSM.StatusID
  IS NOT NULL 
 ORDER BY StatusName  
  
 END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		--EXEC AVL_InsertError '[AVL].[KEDB_GetStatusByProjectId] ', @ErrorMessage, @UserId,''
		RETURN @ErrorMessage
  END CATCH   
END
