/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procEDURE [dbo].[ML_SavePatternValidation]
(
@ProjectID NVARCHAR(200)=null,
@lstApprovedPatternValidation TVP_SaveApprovedPatternValidation READONLY,
@UserId NVARCHAR(10)=null,
@SupportType int
)
AS 
BEGIN
BEGIN TRY
BEGIN TRAN
CREATE TABLE #DebtApprovedPVTickets
	(
	[ID] [int] NOT NULL,
	[TicketPattern] [nvarchar](max) NULL,
	[SMEComments] [nvarchar](max) NULL,
	[SMEResidualFlagID] [nvarchar](500) NULL,
	[SMEDebtClassificationID] [nvarchar](500) NULL
	,[SMEAvoidableFlagID] [nvarchar](500) NULL,
	[MLResidualFlagID] [nvarchar](500) NULL,
	[MLDebtClassificationID] [nvarchar](500) NULL,
	[MLAvoidableFlagID] [nvarchar](500) NULL,
	[SMECauseCodeID] [nvarchar](500) NULL,
	[IsApprovedOrMute] [int] NULL,
	[OveriddenPatternCount] [int] NULL,
	[MLAccuracy] [nvarchar](500) NULL,
	[TicketOccurence] [int] NULL
	)
	INSERT INTO #DebtApprovedPVTickets
	SELECT  
	ID,TicketPattern,SMEComments
	,SMEResidualFlagID
	,SMEDebtClassificationID
	,SMEAvoidableFlagID
	,MLResidualFlagID
	,MLDebtClassificationID
	,MLAvoidableFlagID
	,SMECauseCodeID 
	,IsApprovedOrMute
	,OveriddenPatternCount
	,MLAccuracy
	,TicketOccurence
	FROM @lstApprovedPatternValidation
	
select * from  #DebtApprovedPVTickets
	
--SELECT 
--DT.ID,
--DT.TicketPattern,
--DT.SME_ResidualFlagName,
--	DT.SME_DebtClassificationName,
--	DT.SME_AvoidableFlagName,
--	DT.SME_CauseCodeName,
--	DT.IsApprovedOrMute 
--FROM #DebtApprovedPVTickets DT
--INNER JOIN [TRN].[Debt_MLPatternValidation] DMLV ON DT.ID = DMLV.ID


UPDATE #DebtApprovedPVTickets SET SMEResidualFlagID = NULL WHERE SMEResidualFlagID='0'

UPDATE #DebtApprovedPVTickets SET SMEDebtClassificationID = NULL WHERE SMEDebtClassificationID='0'

UPDATE #DebtApprovedPVTickets SET SMEAvoidableFlagID = NULL WHERE SMEAvoidableFlagID='0'

UPDATE #DebtApprovedPVTickets SET SMECauseCodeID = NULL WHERE SMECauseCodeID='0'

UPDATE #DebtApprovedPVTickets SET SMEComments = NULL WHERE SMEComments=''
if(@SupportType=1)
BEGIN
Update DMLV SET 
DMLV.SMEResidualFlagID= ISNULL(DT.SMEResidualFlagID,DMLV.SMEResidualFlagID),
DMLV.SMEDebtClassificationID= ISNULL(DT.SMEDebtClassificationID,DMLV.SMEDebtClassificationID),
DMLV.SMEAvoidableFlagID= ISNULL(DT.SMEAvoidableFlagID,DMLV.SMEAvoidableFlagID),
DMLV.MLResidualFlagID= ISNULL(DT.MLResidualFlagID,DMLV.MLResidualFlagID),
DMLV.MLDebtClassificationID= ISNULL(DT.MLDebtClassificationID,DMLV.MLDebtClassificationID),
DMLV.MLAvoidableFlagID= ISNULL(DT.MLAvoidableFlagID,DMLV.MLAvoidableFlagID),
DMLV.SMECauseCodeID= ISNULL(DT.SMECauseCodeID,DMLV.SMECauseCodeID),
DMLV.SMEComments= ISNULL(DT.SMEComments,DMLV.SMEComments),
DMLV.IsApprovedOrMute= DT.IsApprovedOrMute,
ModifiedBy=@UserId, ModifiedDate=GETDATE(),
DMLV.OverridenPatternCount = CASE WHEN DMLV.OverridenPatternCount = 1 THEN DMLV.OverridenPatternCount ELSE DT.OveriddenPatternCount END,
DMLV.MLAccuracy =  ISNULL(DT.MLAccuracy,DMLV.MLAccuracy),
DMLV.TicketOccurence =  ISNULL(DT.TicketOccurence,DMLV.TicketOccurence)
FROM #DebtApprovedPVTickets DT
INNER JOIN AVL.ML_TRN_MLPatternValidation DMLV ON DT.ID = DMLV.ID
--AND DMLV.TicketPattern=DT.TicketPattern
WHERE DMLV.ProjectID=@ProjectID 
END
ELSE
BEGIN
SELECT * from  #DebtApprovedPVTickets DT
INNER JOIN AVL.ML_TRN_MLPatternValidationInfra DMLV ON DT.ID = DMLV.ID
--AND DMLV.TicketPattern=DT.TicketPattern
WHERE DMLV.ProjectID=@ProjectID
Update DMLV SET 
DMLV.SMEResidualFlagID= ISNULL(DT.SMEResidualFlagID,DMLV.SMEResidualFlagID),
DMLV.SMEDebtClassificationID= ISNULL(DT.SMEDebtClassificationID,DMLV.SMEDebtClassificationID),
DMLV.SMEAvoidableFlagID= ISNULL(DT.SMEAvoidableFlagID,DMLV.SMEAvoidableFlagID),
DMLV.MLResidualFlagID= ISNULL(DT.MLResidualFlagID,DMLV.MLResidualFlagID),
DMLV.MLDebtClassificationID= ISNULL(DT.MLDebtClassificationID,DMLV.MLDebtClassificationID),
DMLV.MLAvoidableFlagID= ISNULL(DT.MLAvoidableFlagID,DMLV.MLAvoidableFlagID),
DMLV.SMECauseCodeID= ISNULL(DT.SMECauseCodeID,DMLV.SMECauseCodeID),
DMLV.SMEComments= ISNULL(DT.SMEComments,DMLV.SMEComments),
DMLV.IsApprovedOrMute= DT.IsApprovedOrMute,
ModifiedBy=@UserId, ModifiedDate=GETDATE(),
DMLV.OverridenPatternCount = CASE WHEN DMLV.OverridenPatternCount = 1 THEN DMLV.OverridenPatternCount ELSE DT.OveriddenPatternCount END,
DMLV.MLAccuracy =  ISNULL(DT.MLAccuracy,DMLV.MLAccuracy),
DMLV.TicketOccurence =  ISNULL(DT.TicketOccurence,DMLV.TicketOccurence)
FROM #DebtApprovedPVTickets DT
INNER JOIN AVL.ML_TRN_MLPatternValidationInfra DMLV ON DT.ID = DMLV.ID
--AND DMLV.TicketPattern=DT.TicketPattern
WHERE DMLV.ProjectID=@ProjectID 

END


COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_SavePatternValidation]', @ErrorMessage, @ProjectID,0
		
	END CATCH  

END
