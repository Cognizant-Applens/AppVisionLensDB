/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/




CREATE PROCEDURE [AVL].[InsertDecrptedTicketDesc]

@TicketDecryptedList AS [AVL].[TicketDetailsDecrypt] READONLY
AS 
BEGIN

UPDATE A SET A.[TicketDescriptionDecrypted]=B.[TicketDescriptionDecrypted]
FROM AVL.TK_TRN_TicketDetail_Decrpyt A 
JOIN @TicketDecryptedList B ON A.TimeTickerID=B.TimeTickerID
AND A.TicketID=B.TicketID
AND A.ProjectID=B.ProjectID
AND A.ApplicationID=B.ApplicationID
AND A.TicketDescription=B.TicketDescription



END
