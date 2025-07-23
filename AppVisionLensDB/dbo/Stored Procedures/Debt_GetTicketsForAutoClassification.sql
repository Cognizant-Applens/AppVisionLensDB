/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--Exec [dbo].[Debt_GetTicketsForAutoClassification] 10337, '627384'

CREATE PROCEDURE [dbo].[Debt_GetTicketsForAutoClassification] --10337, '627384'

@PROJECTID INT,  

@CogID VARCHAR(50)

AS  

BEGIN  
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON; 



SELECT [Ticket ID],[Ticket Description],Application AS ApplicationName,

ApplicationID AS ApplicationID 

FROM [AVL].[TK_ImportTicketDumpDetails]

WHERE PROJECTID=@PROJECTID AND EmployeeID=@CogID and Status = 'Closed'

AND [Ticket ID] NOT IN (SELECT [TicketID] FROM [AVL].[TK_TRN_TicketDetail] (NOLOCK) WHERE ProjectID=@PROJECTID)

 AND TicketLocation is not NULL AND Reviewer is NOT NULL

UNION

SELECT [Ticket ID],[Ticket Description],Application AS ApplicationName,

ApplicationID AS ApplicationID 

FROM [AVL].[TK_ImportTicketDumpDetails]

WHERE PROJECTID=@PROJECTID AND EmployeeID=@CogID and Status = 'Closed'

--AND [Ticket ID] NOT IN (SELECT [TicketID] FROM [AVL].[TK_TRN_TicketDetail] (NOLOCK) WHERE ProjectID=@PROJECTID)

 AND TicketLocation is not NULL AND Reviewer is NOT NULL

--newly added

AND [Ticket ID] IN (SELECT TicketID FROM AVL.TK_TRN_TicketDetail WHERE ProjectID=@PROJECTID AND IsApproved=0)



SET NOCOUNT OFF;  
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'dbo.Debt_GetTicketsForAutoClassification', @ErrorMessage, 0 ,0
		
	END CATCH  

END
