/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetTicketDetailsDecrypt]
AS 
BEGIN

select top 100 TimeTickerID,
TicketID,
ApplicationID,
ProjectID,
TicketDescription,TicketDescriptionDecrypted from AVL.TK_TRN_TicketDetail_Decrpyt(NOLOCK) 

--SELECT * FROM AVL.TK_TRN_TicketDetail_Decrpyt
--SELECT TimeTickerID,TicketID,ApplicationID,ProjectID,TicketDescription INTO AVL.TK_TRN_TicketDetail_Decrpyt
-- FROM AVL.TK_TRN_TicketDetail WHERE TicketID IN ('DART0017935',
--'DART0017936',
--'DART0017937',
--'DART0017938',
--'DART0017939')

--ALTER TABLE AVL.TK_TRN_TicketDetail_Decrpyt
--ADD  TicketDescriptionDecrypted nvarchar(max) null


END
