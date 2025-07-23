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
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[AVL].[UploadAndUpdateDataDictionary] 89401,154,'548986'

CREATE PROCEDURE [AVL].[UploadAndUpdateDataDictionary] 
	 @ProjectID int,
	 @ApplicationID int =null,
	 @EmployeeID nvarchar(50)
AS
BEGIN
  

BEGIN TRY
SET NOCOUNT ON;
--Delete  from [AVL].Debt_MAS_ProjectDataDictionary where ProjectID=@ProjectID

DECLARE @applicationMaster TABLE(ApplicationId INT,
ApplicationName VARCHAR(255))

INSERT INTO @applicationMaster
EXEC [AVL].[Effort_GetApplicationDetails] @ProjectID

DECLARE @ResolutionMaster TABLE(ResolutionId INT,
ResolutionName VARCHAR(255))

INSERT INTO @ResolutionMaster
EXEC [AVL].[ReMap_GetResolutionCodeDetails] @ProjectID

DECLARE @CausecodeMaster TABLE(CauseId INT,
CauseName VARCHAR(255))

INSERT INTO @CausecodeMaster
EXEC [AVL].[ReMap_GetCauseCodeDetails] @ProjectID


--Declare @EffectiveDate DateTime
DECLARE @IsMerge INT = 0
-- Set @EffectiveDate=(Select top 1 IsDDAutoClassifiedDate from AVL.MAS_ProjectDebtDetails Where ProjectID=74 and IsDeleted=0 and IsDDAutoClassifiedDate is not null )
SELECT
DISTINCT
	AP.ApplicationID
	,CC.CauseID
	,RC.ResolutionID
	,DB.DebtClassificationID
	,AF.AvoidableFlagID
	,RD.ResidualDebtID
	,RR.ReasonResidualID
	,ExpectedCompletionDate INTO #temptable
FROM dbo.DataDictionaryTemp AS DDT
JOIN @applicationMaster AP
	ON AP.ApplicationName = DDT.ApplicationName
JOIN AVL.DEBT_MAS_DebtClassification DB
	ON DB.DebtClassificationName = DDT.DebtCategory
	AND DB.IsDeleted = 0
JOIN AVL.DEBT_MAS_AvoidableFlag AF
	ON AF.AvoidableFlagName = DDT.AvoidableFlag
	AND AF.IsDeleted = 0
JOIN @CausecodeMaster CC
	ON CC.CauseName = DDT.CauseCode
JOIN @ResolutionMaster RC
	ON RC.ResolutionName = DDT.ResolutionCode
JOIN AVL.DEBT_MAS_ResidualDebt RD
	ON RD.ResidualDebtName = DDT.ResidualFlag
	AND RD.IsDeleted = 0
LEFT JOIN AVL.TK_MAS_ReasonForResidual RR
	ON RR.ReasonResidualName = DDT.ReasonForResidual
	AND RR.IsDeleted = 0


MERGE INTO [AVL].Debt_MAS_ProjectDataDictionary Target USING (SELECT
		*
	FROM #temptable) AS Source (ApplicationID, CauseID, ResolutionID, DebtClassificationID, AvoidableFlagID, ResidualDebtID, ReasonResidualID, ExpectedCompletionDate) ON Source.ApplicationID = Target.ApplicationID
AND Source.CauseID = Target.CauseCodeID
AND Source.ResolutionID = Target.ResolutionCodeID
AND @ProjectID = Target.ProjectId WHEN MATCHED THEN UPDATE SET ModifiedBy =
																			CASE
																				WHEN
																					Target.DebtClassificationID = source.DebtClassificationID OR
																					Target.AvoidableFlagID = source.AvoidableFlagID OR
																					Target.ResidualDebtID = source.ResidualDebtID OR
																					Target.ReasonForResidual = source.ReasonResidualID OR
																					Target.ExpectedCompletionDate = source.ExpectedCompletionDate OR
																					Target.IsDeleted = 0 THEN @EmployeeID
																				ELSE NULL
																			END,

ModifiedDate =
				CASE
					WHEN
						Target.DebtClassificationID = source.DebtClassificationID OR
						Target.AvoidableFlagID = source.AvoidableFlagID OR
						Target.ResidualDebtID = source.ResidualDebtID OR
						Target.ReasonForResidual = source.ReasonResidualID OR
						Target.ExpectedCompletionDate = source.ExpectedCompletionDate OR
						Target.IsDeleted = 0 THEN GETDATE()
					ELSE NULL
				END
, DebtClassificationID = source.DebtClassificationID
, AvoidableFlagID = source.AvoidableFlagID
, ResidualDebtID = source.ResidualDebtID
, ReasonForResidual = source.ReasonResidualID
, ExpectedCompletionDate = source.ExpectedCompletionDate,
Target.EffectiveDate = GETDATE(),
@IsMerge = 1,
--EffectiveDate=case when @EffectiveDate is null then EffectiveDate else @EffectiveDate end
IsDeleted = 0 WHEN NOT MATCHED THEN INSERT(ProjectID
, ApplicationID
, CauseCodeID
, ResolutionCodeID
, DebtClassificationID
, AvoidableFlagID
, ResidualDebtID
, ReasonForResidual
, ExpectedCompletionDate
, EffectiveDate
, IsDeleted
, CreatedBy
, CreatedDate) VALUES(@ProjectID, Source.ApplicationID, Source.CauseID, Source.ResolutionID, Source.DebtClassificationID, Source.AvoidableFlagID, Source.ResidualDebtID, Source.ReasonResidualID, Source.ExpectedCompletionDate, GETDATE(), 0,
@EmployeeID, GETDATE());


-- All Block--
IF EXISTS ( select 1 from dbo.DataDictionaryTemp where ApplicationName IN( 'ALL'))
BEGIN
	--DELETE from @applicationMaster where applicationID  in (select ApplicationID from [AVL].Debt_MAS_ProjectDataDictionary where ProjectID = @ProjectID)

	  SELECT DISTINCT			  AP.ApplicationID,CC.CauseID,RC.ResolutionID,DB.DebtClassificationID,AF.AvoidableFlagID,RD.ResidualDebtID,RR.ReasonResidualID,ExpectedCompletionDate
						into #temptable_all
				 FROM  dbo.DataDictionaryTemp AS DDT		  
				  JOIN @applicationMaster AP on AP.ApplicationName <> DDT.ApplicationName  
				  JOIN AVL.DEBT_MAS_DebtClassification DB on DB.DebtClassificationName=DDT.DebtCategory and DB.IsDeleted=0
				  JOIN AVL.DEBT_MAS_AvoidableFlag AF on AF.AvoidableFlagName=DDT.AvoidableFlag and AF.IsDeleted=0
				  JOIN @CausecodeMaster CC on CC.CauseName=DDT.CauseCode 
				  JOIN @ResolutionMaster RC on RC.ResolutionName=DDT.ResolutionCode 
				  JOIN AVL.DEBT_MAS_ResidualDebt RD on RD.ResidualDebtName=DDT.ResidualFlag and RD.IsDeleted=0
				  LEFT JOIN AVL.TK_MAS_ReasonForResidual RR on RR.ReasonResidualName=DDT.ReasonForResidual and RR.IsDeleted=0
				  where DDT.ApplicationName IN( 'ALL')

				  UNION


				   SELECT DISTINCT AP.ApplicationID,CC.CauseID,RC.ResolutionID,DB.DebtClassificationID,AF.AvoidableFlagID,RD.ResidualDebtID,RR.ReasonResidualID,ExpectedCompletionDate
				 FROM  dbo.DataDictionaryTemp AS DDT		  
				  LEFT JOIN @applicationMaster AP on AP.ApplicationName = DDT.ApplicationName  
				  JOIN AVL.DEBT_MAS_DebtClassification DB on DB.DebtClassificationName=DDT.DebtCategory and DB.IsDeleted=0
				  JOIN AVL.DEBT_MAS_AvoidableFlag AF on AF.AvoidableFlagName=DDT.AvoidableFlag and AF.IsDeleted=0
				  JOIN @CausecodeMaster CC on CC.CauseName=DDT.CauseCode 
				  JOIN @ResolutionMaster RC on RC.ResolutionName=DDT.ResolutionCode 
				  JOIN AVL.DEBT_MAS_ResidualDebt RD on RD.ResidualDebtName=DDT.ResidualFlag and RD.IsDeleted=0
				  LEFT JOIN AVL.TK_MAS_ReasonForResidual RR on RR.ReasonResidualName=DDT.ReasonForResidual and RR.IsDeleted=0
				  where DDT.ApplicationName NOT IN( 'ALL')
			
		          If Exists (SELECT  * FROM  AVL.Debt_MAS_ProjectDataDictionary PD 
				   JOIN  #temptable_all TA ON PD.ApplicationID=TA.ApplicationID
				   WHERE PD.ApplicationID=TA.ApplicationID AND PD.CauseCodeID=TA.CauseID
				   AND PD.ResolutionCodeID=TA.ResolutionID )
				   BEGIN
				   DELETE TM FROM AVL.Debt_MAS_ProjectDataDictionary TM INNER JOIN #temptable_all TTM ON TM.ApplicationID = TTM.ApplicationID 
				   AND TM.ProjectID = @ProjectID AND TM.CauseCodeID=TTM.CauseID AND TM.ResolutionCodeID=TTM.ResolutionID
				 INSERT INTO [AVL].Debt_MAS_ProjectDataDictionary
				 select distinct @ProjectID,ApplicationID,CauseID,ResolutionID,DebtClassificationID,AvoidableFlagID,ResidualDebtID,ReasonResidualID,ExpectedCompletionDate,0,GETDATE()
				,@EmployeeID,GETDATE(),NULL,NULL from #temptable_all 
				  END
				  Else
				  BEGIN
  INSERT INTO [AVL].Debt_MAS_ProjectDataDictionary
				 select distinct @ProjectID,ApplicationID,CauseID,ResolutionID,DebtClassificationID,AvoidableFlagID,ResidualDebtID,ReasonResidualID,ExpectedCompletionDate,0,GETDATE()
				,@EmployeeID,GETDATE(),NULL,NULL from #temptable_all 
				  END
				 
		  
		
		   

	 
				
				END

-- End All Block--	

--YOUR SP STATEMENTS
END TRY BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()

EXEC AVL_InsertError	'UploadAndUpdateDataDictionary'
						,@ErrorMessage
						,@ProjectID

END CATCH





SET NOCOUNT OFF;

END
