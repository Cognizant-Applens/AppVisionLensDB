/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [dbo].[vw_IncidentDetail]
AS

Select TD.TicketID,
TD.TicketDescription,
PRM.ProjectName,
PRM.EsaProjectID,
TD.ProjectID,
TD.PriorityMapID,
SER.ServiceName,
TD.ServiceID,
TD.OpenDateTime,
PM.PriorityName AS [Priority],
PM.PriorityID,
DART.DARTStatusName,
TD.Closeddate,
TD.ApplicationID,
APPD.ApplicationName from [AVL].[TK_TRN_TicketDetail] TD WITH (NOLOCK)
INNER JOIN [AVL].MAS_ProjectMaster PRM WITH (NOLOCK) ON PRM.ProjectID = TD.ProjectID AND PRM.IsDeleted = 0
LEFT JOIN [AVL].TK_MAS_Service SER WITH (NOLOCK) on SER.ServiceID = TD.ServiceID AND SER.IsDeleted = 0
LEFT JOIN [AVL].[TK_MAP_PriorityMapping] PM WITH (NOLOCK) ON TD.PriorityMapID = PM.PriorityIDMapID AND PM.IsDeleted = 0
LEFT JOIN [AVL].[TK_MAS_Priority] P WITH (NOLOCK) ON PM.PriorityID=P.PriorityID AND P.IsDeleted = 0
LEFT JOIN [AVL].[TK_MAS_DARTTicketStatus] DART WITH (NOLOCK) ON TD.DARTStatusID = DART.DARTStatusID AND DART.IsDeleted = 0 
LEFT JOIN [AVL].APP_MAS_ApplicationDetails APPD WITH (NOLOCK) ON APPD.ApplicationID = TD.ApplicationID AND APPD.IsActive = 1
Where TD.IsDeleted = 0
