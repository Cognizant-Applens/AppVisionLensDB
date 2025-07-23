/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Audit_GetTicketMasterDetails]
@ProjectID BIGINT,
@TicketID NVARCHAR(1000)
AS
BEGIN
begin try
SET NOCOUNT ON;

SELECT PROJECTID,TICKETID,'' AS FieldName,
[DebtClassificationMapID] AS DebtClassification,AvoidableFlag AS AvoidableFlag,
[ResidualDebtMapID] AS ResidualDebt,
[CauseCodeMapID] AS CauseCode,[ResolutionCodeMapID] AS ResolutionCode FROM [AVL].[TK_TRN_TicketDetail](NOLOCK)
WHERE PROJECTID=@ProjectID AND TICKETID=@TicketID

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[Audit_GetTicketMasterDetails] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  



END
