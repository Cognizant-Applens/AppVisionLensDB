/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_MLPatternValidationTemp]

-- [[ML_MLPatternValidationTemp]] 40 ,'','',627384
(
@ProjectID NVARCHAR(200),
@DateFrom DATETIME =NULL,
@DateTo DATETIME=NULL,
@UserID NVARCHAR(50)
)
AS 
BEGIN
			DECLARE @CustomerID INT=0;
			DECLARE @IsCognizantID INT;
			SET @CustomerID=(SELECT top 1 CustomerID FROM AVL.MAS_LoginMaster WHERE ProjectID=@ProjectID AND IsDeleted=0)
			SET @IsCognizantID=(SELECT top 1 IsCognizant FROM AVL.Customer WHERE CustomerID=@CustomerID AND IsDeleted=0)
			
 IF @IsCognizantID=0
BEGIN

SELECT * INTO #Debt_MLPatternValidation FROM AVL.ML_TRN_MLPatternValidation(NOLOCK) MV
		where MV.projectid = @ProjectID AND MV.IsDeleted=0

Create table #tmp_final
(
ID INT Identity(1,1),
ApplicationID nvarchar(max),
TicketPattern NVARCHAR(MAX),
MLAccuracy Decimal(10,2),
Occur INT
)

	Insert into #tmp_final

	  SELECT Distinct ApplicationID, TicketPattern, MAX(MLAccuracy) as MLAccuracy, MAX(TicketOccurence) as TicketOccurence
      FROM #Debt_MLPatternValidation where TicketPattern <> '0' and TicketOccurence != 0
      GROUP BY ApplicationID, TicketPattern 

--Select * from #tmp_final

declare @num int;
Set @num = 1

declare @max int
set @max = (Select max(ID) from #tmp_final)

declare @Pattern Nvarchar(max)
declare @Accuracy decimal(10,2)
declare @ApplicationID Nvarchar(max)
declare @Occurance Int

Create table #MaxIDs
(
TickID INT,
ApplicationID NVARCHAR(MAX),
TicketPattern NVARCHAR(MAX),
MLAccuracy Decimal(10,2),
Occurance Int
)

while (@num <= @max)
begin

Set @Pattern = (Select TicketPattern from #tmp_final where ID = @num)
Set @Accuracy = (Select MLAccuracy from #tmp_final where ID = @num)
Set @ApplicationID = (Select ApplicationID from #tmp_final where ID = @num)
Set @Occurance = (Select Occur from #tmp_final where ID = @num)

Insert into #MaxIDs

Select top 1 ID, ApplicationID, TicketPattern, MLAccuracy, TicketOccurence from #Debt_MLPatternValidation where 
TicketPattern = @Pattern and MLAccuracy = @Accuracy and ApplicationID = @ApplicationID and TicketOccurence = @Occurance

--Select top 1 ID, TicketPattern, ML_Accuracy from #Debt_MLPatternValidation where TicketPattern = 'access' and ML_Accuracy = 100.00

SET @num = @num +1;
end


		SELECT distinct
	        MV.ID,
			ISNULL(MV.InitialLearningID,0) AS InitialLearningID,
			ISNULL(MV.ApplicationID,0) as ApplicationID,
			ISNULL(AM.ApplicationName,'') AS ApplicationName,
			ISNULL(MV.ApplicationTypeID,0) AS  ApplicationTypeID,
			ISNULL(AT.ApplicationTypename,'') AS  ApplicationTypeName,
			ISNULL(MV.TechnologyID,0) AS TechnologyID,
			ISNULL(MT.[PrimaryTechnologyName],'') AS TechnologyName,
			TicketPattern,
			ISNULL(MLDebtClassificationID,0) AS MLDebtClassificationID,
			ISNULL(AFM.[DebtClassificationName],'') AS MLDebtClassificationName,
			ISNULL(MLResidualFlagID,0) AS MLResidualFlagID,
			ISNULL(AFMM.[ResidualDebtName],'') AS MLResidualFlagName,
			ISNULL(MLAvoidableFlagID,0) AS MLAvoidableFlagID,
			ISNULL(AFMF.[AvoidableFlagName],'') AS MLAvoidableFlagName,
			IsNULL(MV.ExpectedCompDate,getdate()) as ExpectedCompDate,
			ISNULL(MLCauseCodeID,0) AS MLCauseCodeID,

			ISNULL(DCC.[CauseCode],'') AS MLCauseCodeName,
			MLAccuracy as MLAccuracy,
			TicketOccurence,
			ISNULL(AnalystResolutionCodeID,0) AS AnalystResolutionCodeID,

			ISNULL(DRC.[ResolutionCode],'') AS AnalystResolutionCodeName,

			ISNULL(AnalystCauseCodeID,0) AS AnalystCauseCodeID,
			ISNULL(DCC2.[CauseCode],'') AS AnalystCauseCodeName,


			ISNULL(AnalystDebtClassificationID,0) AS AnalystDebtClassificationID,
			ISNULL(AFM1.[DebtClassificationName],'') AS AnalystDebtClassificationName,
			ISNULL(AnalystAvoidableFlagID,0) AS AnalystAvoidableFlagID,
			ISNULL(AFMF2.[AvoidableFlagName],'') AS AnalystAvoidableFlagName,
			ISNULL(SMEComments,'') AS SMEComments,
			ISNULL(SMEResidualFlagID,0) AS SMEResidualFlagID,
			ISNULL(AFMF5.[ResidualDebtName],'') AS SMEResidualFlagName,
			ISNULL(SMEDebtClassificationID,0) AS SMEDebtClassificationID,
			ISNULL(AFM3.[DebtClassificationName],'') AS SMEDebtClassificationName,
			ISNULL(SMEAvoidableFlagID,0) AS SMEAvoidableFlagID,
			AFMF4.[AvoidableFlagName] AS SMEAvoidableFlagName ,
			ISNULL(SMECauseCodeID,0) AS SMECauseCodeID,

			DCC1.[CauseCode] AS SMECauseCodeName,
			ISNULL(SMEResolutionCodeID,0) AS SMEResolutionCodeID,

			DRC.[ResolutionCode] AS SMEResolutionCodeName,
			ISNULL(ReasonForResidual,'')  as ReasonForResidual,
			RES.[ReasonName],
			ISNULL(IsApprovedOrMute,0) AS IsApprovedOrMute into #Temp
			FROM AVL.ML_TRN_MLPatternValidation(NOLOCK) MV
			LEFT JOIN AVL.[APP_MAS_ApplicationDetails] AM  ON MV.ApplicationID=AM.ApplicationID LEFT JOIN AVL.BusinessClusterMapping BCM
			ON AM.SubBusinessClusterMapID=BCM.BusinessClusterMapID AND BCM.IsDeleted=0 AND BCM.CustomerID=@CustomerID
		
			--Left join [AVL].[APP_MAP_ApplicationProjectMapping] AP ON  MV.ProjectID=AP.ProjectID AND AP.APPLICATIONID=MV.APPLICATIONID

			LEFT JOIN AVL.[APP_MAS_OwnershipDetails] AT ON AM.[CodeOwnerShip]=AT.ApplicationTypeID

			LEFT JOIN AVL.[APP_MAS_PrimaryTechnology] MT ON AM.[PrimaryTechnologyID]=MT.[PrimaryTechnologyID]

			LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM ON MV.MLDebtClassificationID= AFM.[DebtClassificationID]
			LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AFMM ON MV.MLResidualFlagID= AFMM.[ResidualDebtID]

			LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] AFMF ON MV.MLAvoidableFlagId= AFMF.[AvoidableFlagID]

			LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC ON MV.MLCauseCodeID=DCC.CauseID AND DCC.ProjectID=@ProjectID AND DCC.IsDeleted=0
			LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC2 ON MV.AnalystCauseCodeID=DCC2.[CauseID] AND DCC2.ProjectID=@ProjectID AND DCC2.IsDeleted=0
			
			LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM1 ON MV.AnalystDebtClassificationID= AFM1.[DebtClassificationID]
			LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] AFMF2 ON MV.AnalystAvoidableFlagID= AFMF2.[AvoidableFlagID]
			LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM3 ON MV.SMEDebtClassificationID= AFM3.[DebtClassificationID]
			LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] AFMF4 ON MV.SMEAvoidableFlagID= AFMF4.[AvoidableFlagID]
			LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AFMF5 ON MV.SMEResidualFlagID= AFMF5.[ResidualDebtID]
			LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC1 ON MV.SMECauseCodeID=DCC1.[CauseID] AND DCC1.ProjectID=@ProjectID AND DCC1.IsDeleted=0
			LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] DRC ON MV.AnalystResolutionCodeID=DRC.[ResolutionID] AND DRC.ProjectID=@ProjectID AND DRC.IsDeleted=0
			left join [AVL].[CL_MAS_ResidualReason] RES ON MV.ReasonForResidual=RES.ReasonID and Res.Isdeleted=0
			where MV.projectid = @ProjectID AND MV.IsDeleted=0 AND MV.ID IN(SELECT TickID FROM #MaxIDs) and TicketPattern <> '0' and Res.Isdeleted=0
			--AND MV.TicketOccurence >0
			and BCM.CustomerID=@CustomerID and AM.IsActive=1
			END
			declare @RowCount int
			declare @ApproveCount int
			declare @MuteCOunt int
			Set @RowCount=(select count(*) from #Temp)
			set @ApproveCount =(select Count(*) from #Temp where IsApprovedOrMute=1)
			set @MuteCOunt =(select count(*) from #Temp where IsApprovedOrMute=2)
			if(@RowCount=@ApproveCount)
			begin
			select *,1 as IsApproved from #Temp
			--select 1 as IsApproved
			end
			else if(@RowCount=@MuteCOunt)
			begin
			select *,2 as IsApproved from #Temp
			end
			else 
			begin
			select *,0 as IsApproved from #Temp
			end

			END
		
		
		
		
	--SELECT * FROM AVL.ML_TRN_MLPatternValidation

	--ALTER TABLE AVL.ML_TRN_MLPatternValidation ADD  ExpectedCompDate datetime
