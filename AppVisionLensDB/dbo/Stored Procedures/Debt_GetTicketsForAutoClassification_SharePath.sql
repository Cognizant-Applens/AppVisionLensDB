/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--Exec [dbo].[Debt_GetTicketsForAutoClassification_SharePath] 7, '383323'
CREATE PROCEDURE [dbo].[Debt_GetTicketsForAutoClassification_SharePath] --7, '383323'
@PROJECTID INT,  
@CogID VARCHAR(50)
AS  
BEGIN  
SET NOCOUNT ON; 
SELECT [Ticket ID],[Ticket Description],Application AS ApplicationName,
ApplicationID AS ApplicationID 
FROM [AVL].[TK_ImportTicketDumpDetails_SharePath]
WHERE PROJECTID=@PROJECTID AND EmployeeID=@CogID and Status = 'Closed'
AND [Ticket ID] NOT IN
(SELECT [TicketID] FROM [AVL].[TK_TRN_TicketDetail] (NOLOCK) WHERE ProjectID=@PROJECTID)
 AND TicketLocation is not NULL AND Reviewer is NOT NULL
 UNION
SELECT [Ticket ID],[Ticket Description],Application AS ApplicationName,
ApplicationID AS ApplicationID 
FROM [AVL].[TK_ImportTicketDumpDetails_SharePath]
WHERE PROJECTID=@PROJECTID AND EmployeeID=@CogID and Status = 'Closed'
--AND [Ticket ID] NOT IN (SELECT [TicketID] FROM [AVL].[TK_TRN_TicketDetail] (NOLOCK) WHERE ProjectID=@PROJECTID)
 AND TicketLocation is not NULL AND Reviewer is NOT NULL
 --newly added
AND [Ticket ID] IN (SELECT TicketID FROM AVL.TK_TRN_TicketDetail WHERE ProjectID=@PROJECTID AND IsApproved=0)

SET NOCOUNT OFF;  
END
