/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE Proc [dbo].[AVL_GetDetailsByProjectid] 
@ProjectID bigint
as
begin
SET NOCOUNT ON;
	SELECT PPM.PriorityIDMapID,PPM.PriorityName,PM.PriorityID,PPM.IsDefaultPriority 
	FROM [AVL].[TK_MAP_PriorityMapping] PPM (NOLOCK)
	LEFT  JOIN [AVL].[TK_MAS_Priority] PM (NOLOCK)
	ON PPM.PriorityID=PM.PriorityID AND PM.IsDeleted=0 
	where PPM.ProjectID=@ProjectID AND PPM.IsDeleted=0 and PPM.PriorityIDMapID IS NOT NULL

	select TTM.TicketTypeMappingID,TTM.TicketType,TTM.AVMTicketType,TTM.IsDefaultTicketType,TTM.SupportTypeID 
	from [AVL].[TK_MAP_TicketTypeMapping] TTM (NOLOCK)
	INNER JOIN AVL.MAP_ProjectConfig PC (NOLOCK) ON PC.ProjectID=TTM.ProjectID 
	LEFT JOIN [AVL].[TK_MAS_TicketType] TT (NOLOCK) ON TTM.AVMTicketType=TT.TicketTypeID and TT.IsDeleted=0
	where TTM.ProjectID=@ProjectID  and TTM.IsDeleted=0 AND TTM.TicketTypeMappingID IS NOT NULL
	and isnull(TT.TicketTypeID,0) not in(9,10,20) AND 
	CASE WHEN PC.SupportTypeId=3 AND (TTM.SupportTypeID IN (1,2,3)) THEN 1
	WHEN PC.SupportTypeId=2 AND TTM.SupportTypeID =2 THEN 1
	WHEN PC.SupportTypeId=1 AND TTM.SupportTypeID =1 THEN 1
	ELSE 0
	END=1

	select StatusID,StatusName,TicketStatus_ID,IsDefaultTicketStatus 
	from [AVL].[TK_MAP_ProjectStatusMapping] PSM
	INNER join [AVL].[TK_MAS_DARTTicketStatus] DTS (NOLOCK) 
	ON PSM.TicketStatus_ID=DTS.DARTStatusID 
	where PSM.ProjectID=@ProjectID and DTS.IsDeleted=0 AND PSM.IsDeleted=0 AND PSM.StatusID IS NOT NULL
	ORDER BY StatusName

	SELECT 
	ITDT.InfraTowerTransactionID as TowerID,
	ITDT.TowerName AS Tower
	FROM AVL.InfraTowerProjectMapping ITPM (NOLOCK)
	INNER JOIN AVL.MAP_ProjectConfig PC (NOLOCK)
	ON PC.ProjectID=ITPM.ProjectID
	INNER JOIN avl.InfraTowerDetailsTransaction ITDT ON ITDT.InfraTowerTransactionID=ITPM.TowerID
	 AND PC.ProjectID=@ProjectID AND PC.SupportTypeId <> 1 AND ITPM.IsEnabled=1 and ITPM.IsDeleted=0

	SELECT AG.AssignmentGroupMapID AS AssignmentGroupID,AG.AssignmentGroupName FROM AVL.BOTAssignmentGroupMapping AG (NOLOCK)
	INNER JOIN AVL.MAP_ProjectConfig PC (NOLOCK)
	ON PC.ProjectID=@ProjectID  AND pc.SupportTypeId<> 1
	AND AG.ProjectID=PC.ProjectID AND AG.IsBOTGroup=0 AND AG.AssignmentGroupCategoryTypeID=2 AND ag.IsDeleted=0 AND AG.SupportTypeID <>1 

end
