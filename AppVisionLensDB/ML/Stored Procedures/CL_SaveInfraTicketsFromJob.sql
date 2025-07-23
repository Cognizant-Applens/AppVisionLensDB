/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[CL_SaveInfraTicketsFromJob]
@ProjectID BIGINT,
@TVP_lstInfraJobPattern ML.TVP_InfraCLJobTickets READONLY
AS
BEGIN
BEGIN TRAN
BEGIN TRY
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
DECLARE @ContLearningID INT;
SELECT TOP 1 @ContLearningID=ContLearningID FROM ML.CL_PRJ_InfraContLearningState
						WHERE ProjectID=@ProjectID and IsDeleted=0 ORDER BY ContLearningID DESC
INSERT INTO ML.CL_InfraBaseDetails 
( ContLearningID, ProjectID,TicketID, TowerName,CauseCode, ResolutionCode,DebtClassification, AvoidableFlag,
ResidualDebt, TicketDescriptionPattern, TicketDescriptionSubPattern, OptionalFieldpattern, OptionalFieldSubPattern,Isdeleted,
CreatedBy,CreatedDate)
SELECT @ContLearningID,@ProjectID,TicketID,TowerName,CauseCode,ResolutionCode,DebtClassification,
AvoidableFlag,ResidualDebt,Desc_Base_WorkPattern,Desc_Sub_WorkPattern,Res_Base_WorkPattern,
Res_Sub_WorkPattern,0,'SYSTEM',GETDATE()
FROM @TVP_lstInfraJobPattern 
COMMIT TRAN
END TRY
BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError 'ML.CL_SaveInfraTicketsFromJob', @ErrorMessage, @ProjectID ,0
END CATCH
END
