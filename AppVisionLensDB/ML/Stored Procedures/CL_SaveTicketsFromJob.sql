/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		Sreeya
-- Create date: 20-8-2019
-- Description:	Save Tickets to CL Base Details
-- =============================================
CREATE PROCEDURE [ML].[CL_SaveTicketsFromJob]
@ProjectID BIGINT,
@TVP_lstMLJobPattern ML.TVP_CLJobTickets READONLY
AS
BEGIN
BEGIN TRAN
BEGIN TRY
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

DECLARE @ContLearningID INT;
SET @ContLearningID=(SELECT TOP 1 ContLearningID FROM ML.CL_PRJ_ContLearningState
						WHERE ProjectID=@ProjectID and IsDeleted=0 ORDER BY ContLearningID DESC);

--UPDATE CL 
--SET 
--	ApplicationName=TVP.ApplicationName, 
--	CauseCode=TVP.CauseCode, 
--	ResolutionCode=TVP.ResolutionCode, 
--	DebtClassification=TVP.DebtClassification, 
--	AvoidableFlag=TVP.AvoidableFlag , 
--	ResidualDebt=TVP.ResidualDebt , 
--	TicketDescriptionPattern=TVP.Desc_Base_WorkPattern, 
--	TicketDescriptionSubPattern=TVP.Desc_Sub_WorkPattern, 
--	OptionalFieldpattern=TVP.Res_Base_WorkPattern,
--	OptionalFieldSubPattern=TVP.Res_Sub_WorkPattern,
--	ModifiedBy='SYSTEM',
--	ModifiedDate=GETDATE()

--FROM 
--	AVL.CL_BaseDetails CL 
--JOIN 
--	@TVP_lstMLJobPattern TVP 
--ON 
--	TVP.ProjectID=CL.ProjectID 
--AND 
--	CL.TicketID=TVP.TicketID 

--WHERE 
--	CL.TicketDescriptionPattern='0' AND CL.OptionalFieldpattern='0' AND 
--	CL.TicketDescriptionSubPattern='0' AND CL.OptionalFieldSubPattern='0' AND 
--	TVP.Desc_Base_WorkPattern!='0' AND TVP.Desc_Sub_WorkPattern!='0' AND 
--	TVP.Res_Base_WorkPattern!='0' AND TVP.Res_Sub_WorkPattern!='0';


--MERGE AVL.CL_BaseDetails AS T
--USING @TVP_lstMLJobPattern AS S
--ON (T.ProjectID=S.ProjectID AND T.TicketID=S.TicketID AND T.TicketDescriptionPattern=S.Desc_Base_WorkPattern AND T.TicketDescriptionSubPattern=S.Desc_Sub_WorkPattern
--AND T.OptionalFieldpattern=S.Res_Base_WorkPattern AND T.OptionalFieldSubPattern=S.Res_Sub_WorkPattern)
--WHEN NOT MATCHED BY TARGET  
--THEN 
--INSERT ( ContLearningID, ProjectID,TicketID, ApplicationName,CauseCode, ResolutionCode,DebtClassification, AvoidableFlag,
--ResidualDebt, TicketDescriptionPattern, TicketDescriptionSubPattern, OptionalFieldpattern, OptionalFieldSubPattern,Isdeleted,
--CreatedBy,CreatedDate)
--VALUES(@ContLearningID,@ProjectID,S.TicketID,S.ApplicationName,S.CauseCode,S.ResolutionCode,S.DebtClassification,
--S.AvoidableFlag,S.ResidualDebt,S.Desc_Base_WorkPattern,S.Desc_Sub_WorkPattern,S.Res_Base_WorkPattern,
--S.Res_Sub_WorkPattern,0,'SYSTEM',GETDATE());

INSERT INTO ML.CL_BaseDetails 
( ContLearningID, ProjectID,TicketID, ApplicationName,CauseCode, ResolutionCode,DebtClassification, AvoidableFlag,
ResidualDebt, TicketDescriptionPattern, TicketDescriptionSubPattern, OptionalFieldpattern, OptionalFieldSubPattern,Isdeleted,
CreatedBy,CreatedDate)
SELECT @ContLearningID,@ProjectID,TicketID,ApplicationName,CauseCode,ResolutionCode,DebtClassification,
AvoidableFlag,ResidualDebt,Desc_Base_WorkPattern,Desc_Sub_WorkPattern,Res_Base_WorkPattern,
Res_Sub_WorkPattern,0,'SYSTEM',GETDATE()
FROM @TVP_lstMLJobPattern 

COMMIT TRAN
END TRY
BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError 'ML.CL_SaveTicketsFromJob', @ErrorMessage, @ProjectID ,0
END CATCH
END
