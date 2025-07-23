/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_SavePatternValidationaltertemp]
(
@ProjectID NVARCHAR(200),
@lstApprovedPatternValidation TVP_SaveApprovedPatternValidationTemp READONLY,
@UserId NVARCHAR(10)
)
AS 
BEGIN

CREATE TABLE #DebtApprovedPVTickets
	(
	[ID] [int] NOT NULL,
	[TicketPattern] [nvarchar](max) NULL,
	[SMEComments] [nvarchar](max) NULL,
	[SMEResidualFlagID] [nvarchar](500) NULL,
	[SMEDebtClassificationID] [nvarchar](500) NULL
	,[SMEAvoidableFlagID] [nvarchar](500) NULL,
	[SMECauseCodeID] [nvarchar](500) NULL,
	SMEResolutionCodeID [nvarchar](500) NULL,
	ReasonForResidual [nvarchar](500) NULL,
	ReasonID int,
	ExpectedCompDate datetime,
	[IsApprovedOrMute] [int] NULL
	)
	INSERT INTO #DebtApprovedPVTickets
	SELECT  
	ID,TicketPattern,SMEComments
	,SMEResidualFlagID
	,SMEDebtClassificationID
	,SMEAvoidableFlagID
	,SMECauseCodeID, 
	SMEResolutionCodeID,
	ReasonForResidual,
	ReasonID,ExpectedCompDate
	,IsApprovedOrMute
	FROM @lstApprovedPatternValidation
	
select * from  #DebtApprovedPVTickets
	
select ID,ReasonForResidual,
	ReasonID,ROW_NUMBER() OVER (ORDER BY ID) AS RowNumber INTO #DemoPattern from #DebtApprovedPVTickets


	declare @i as int,@lastno as int;
	
	set @lastno=(select max(RowNumber) from #DemoPattern);
	set @i=(select min(RowNumber) from #DemoPattern);
	select  @i
		select  @lastno
	while(@i<=@lastno)
	begin

	declare @rid int,@reason nvarchar(max);
	set @rid=(select ReasonID from #DemoPattern where RowNumber=@i)
	set @reason=(select ReasonForResidual from #DemoPattern where RowNumber=@i)
	select @rid
	if(@rid=0)
	select @rid
	begin
	insert into [AVL].[CL_MAS_ResidualReason] values(@reason,0,null,getdate(),0)
	update #DemoPattern set ReasonID=(select top 1 ReasonID from [AVL].[CL_MAS_ResidualReason]  where ISMaster=0 order by createddate DESC) WHERE RowNumber=@i
	end
	
	set @i=@i+1;

	end
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

select * from #DemoPattern
UPDATE #DebtApprovedPVTickets SET SMEResidualFlagID = NULL WHERE SMEResidualFlagID='0'

UPDATE #DebtApprovedPVTickets SET SMEDebtClassificationID = NULL WHERE SMEDebtClassificationID='0'

UPDATE #DebtApprovedPVTickets SET SMEAvoidableFlagID = NULL WHERE SMEAvoidableFlagID='0'

UPDATE #DebtApprovedPVTickets SET SMECauseCodeID = NULL WHERE SMECauseCodeID='0'
UPDATE #DebtApprovedPVTickets SET SMEResolutionCodeID = NULL WHERE SMEResolutionCodeID='0'

UPDATE #DebtApprovedPVTickets SET SMEComments = NULL WHERE SMEComments=''

update #DebtApprovedPVTickets set ReasonForResidual=DP.ReasonID from #DebtApprovedPVTickets debt join #DemoPattern DP
 ON debt.ID=DP.ID

--SELECT 
--* FROM AVL.ML_TRN_MLPatternValidation WHERE PROJECTID=40


Update DMLV SET 
DMLV.SMEResidualFlagID= ISNULL(DT.SMEResidualFlagID,DMLV.SMEResidualFlagID),
DMLV.SMEDebtClassificationID= ISNULL(DT.SMEDebtClassificationID,DMLV.SMEDebtClassificationID),
DMLV.SMEAvoidableFlagID= ISNULL(DT.SMEAvoidableFlagID,DMLV.SMEAvoidableFlagID),
DMLV.SMECauseCodeID= ISNULL(DT.SMECauseCodeID,DMLV.SMECauseCodeID),
DMLV.SMEComments= ISNULL(DT.SMEComments,DMLV.SMEComments),
DMLV.SMEResolutionCodeID=ISNULL(DT.SMEResolutionCodeID,DMLV.SMEResolutionCodeID),
DMLV.ReasonForResidual=ISNULL(DT.ReasonForResidual,DMLV.ReasonForResidual),
DMLV.ExpectedCompDate=ISNULL(DT.ExpectedCompDate,DMLV.ExpectedCompDate),
DMLV.IsApprovedOrMute= DT.IsApprovedOrMute,
ModifiedBy=@UserId, ModifiedDate=GETDATE()
FROM #DebtApprovedPVTickets DT
INNER JOIN AVL.ML_TRN_MLPatternValidation DMLV ON DT.ID = DMLV.ID
--AND DMLV.TicketPattern=DT.TicketPattern
WHERE DMLV.ProjectID=@ProjectID 


END

--select * from AVL.ML_TRN_MLPatternValidation where projectid=40

--alter table AVL.ML_TRN_MLPatternValidation add ReasonForResidual nvarchar(max)

select * from [AVL].[CL_MAS_ResidualReason]
