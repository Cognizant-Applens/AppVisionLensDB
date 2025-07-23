/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Debt_GetTicketsForAutoClassification_DD_sharepath] 

@PROJECTID INT,  
@CogID VARCHAR(50)

AS  

BEGIN  
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON; 



SELECT [Ticket ID],[Ticket Description],ApplicationName AS ApplicationName,

ApplicationID AS ApplicationID 

FROM AVL.TK_MLClassification_TicketUpload

WHERE PROJECTID=@PROJECTID AND EmployeeID=@CogID 

AND [Ticket ID] NOT IN (SELECT [TicketID] FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) TD 
JOIN AVL.MAS_ProjectDebtDetails PD (NOLOCK) ON PD.ProjectID=TD.ProjectID  WHERE TD.ProjectID=@PROJECTID AND PD.IsDDAutoClassifiedDate > TD.CreatedDate)
AND (IsApprover=0 or IsApprover is null)


SET NOCOUNT OFF;  
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN   
		EXEC AVL_InsertError 'dbo.Debt_GetTicketsForAutoClassification_DD_sharepath', @ErrorMessage, 0 ,0
		
	END CATCH  

END
