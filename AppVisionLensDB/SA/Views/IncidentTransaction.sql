/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [SA].[IncidentTransaction] AS SELECT 
 TD.TicketID               AS     IncidentNumber
,TT.TicketTypeName         AS     TicketType
,TD.TicketDescription      AS     ShortDescription
,TD.AssignmentGroup        AS     AssignmentGroup
,ITH.BusinessName                   AS     BusinessName
,ITH.Category                       AS     Category
,ITH.ServiceCatalog          AS     ServiceCatalog
,MP.PriorityName           AS     [Priority]
,TD.OpenDateTime           AS     OpenedOn
,TD.TicketCreatedBy        AS     OpenedBy
,TD.AssignedTo                    AS     AssignedTo
,ITH.SupportRole                    AS     SupportRole
,DS.DARTStatusName         AS     IncidentState
,LastUpdatedDate           AS     UpdatedOn
,Closeddate                       AS     ClosedOn
,0                                       As     DurationMinutes
,RC.ResolutionCodeName     AS     ClosedCode
,TD.ResolutionRemarks      AS     ClosedNotes
,ITH.Technology              AS     Technology
,TD.ApplicationID          AS     ApplicationID    
,TD.MetResponseSLAMapID           AS ResponseSLAMAPID
,TD.MetResolutionMapID            AS ResolutionSLAMapID  ,
TD.DAPId AS DapId       
FROM
SA.IncidentDetails ITH INNER JOIN
AVL.TK_TRN_TicketDetail TD 
ON  TD.TicketID = ITH.IncidentNumber
INNER JOIN AVL.TK_MAS_TicketType TT
ON TD.TicketTypeMapID = TT.TicketTypeID
INNER JOIN AVL.TK_MAS_Priority MP 
ON MP.PriorityID = TD.PriorityMapID
INNER JOIN AVL.TK_MAS_DARTTicketStatus DS
ON DS.DARTStatusID = TD.DARTStatusID
INNER JOIN AVL.DEBT_MAS_ResolutionCode RC
ON RC.ResolutionCodeID = TD.ResolutionCodeMapID
