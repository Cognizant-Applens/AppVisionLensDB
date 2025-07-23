/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/




CREATE PROCEDURE [AVL].[UpdateEncrptedTicket]

@TicketEncryptedList AS [AVL].[TicketDetailsEncrypt] READONLY
AS 
BEGIN

UPDATE A SET TicketDescriptionEncrpted=B.[TicketDescriptionEncrpted],
TicketSummaryEncrypted=B.TicketSummaryEncrypted
FROM Avl.TK_TRN_TicketDetail_EncrptDecrpyt A 
JOIN @TicketEncryptedList B ON A.TimeTickerID=B.TimeTickerID
AND A.TicketID=B.TicketID
AND A.ProjectID=B.ProjectID
--44670
--B.ProjectID
AND A.ApplicationID=B.ApplicationID
AND A.TicketDescription=B.TicketDescription
--AND A.TicketSummary=B.TicketSummary


--UPDATE A SET A.TicketDescription=B.TicketDescriptionEncrpted,
--A.TicketSummary=B.TicketSummaryEncrypted
-- FROM AVL.TK_TRN_TicketDetail A JOIN Avl.TK_TRN_TicketDetail_EncrptDecrpyt B
-- ON A.TimeTickerID=B.TimeTickerID
--AND A.TicketID=B.TicketID
--AND A.ProjectID=B.ProjectID
----44670
----B.ProjectID
--AND A.ApplicationID=B.ApplicationID
--AND A.TicketDescription=B.TicketDescription 
--and a.ProjectID in(9352,14156)

--UPDATE AVL.TK_TRN_TicketDetail SET TicketSummary=NULL WHERE TicketSummary=''

END
