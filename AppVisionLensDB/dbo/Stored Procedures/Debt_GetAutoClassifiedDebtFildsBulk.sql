/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Debt_GetAutoClassifiedDebtFildsBulk] 

-- [Debt_GetAutoClassifiedDebtFildsBulk]

--[Debt_GetAutoClassifiedDebtFildsBulk] 'TDebt1',  383323, 7, 10139, 'doesn work', 'Y', 'N'
--[Debt_GetAutoClassifiedDebtFildsBulk] 19100, 'AVM DART', 'My Error is due to hot spot', 59,31, 'Y','Y'

--Debt_GetAutoClassifiedDebtFildsBulkwithmode 'Devk5',3,'627384','this is new'

@TicketID VARCHAR(1000),
@CogID VARCHAR(20),
@ProjectID VARCHAR(MAX),
@ApplicationID VARCHAR(MAX),
@TicketDescription NVARCHAR(MAX),
@IsAutoClassified VARCHAR(2), 
@IsDDAutoClassified VARCHAR(2)

AS
BEGIN

Delete from AVL.[TempDebtFieldsBulkUpload] where ProjectID = @ProjectID and TicketID = @TicketID

Declare @DDCausecode INT;
Declare @DDResolution INT;
Declare @DDCausecodeML INT;
Declare @DDResolutioncodeML INT;
--newly added
DECLARE @IsDebtEnabled NVARCHAR(10);
DECLARE @CustomerID BIGINT;
DECLARE @IsCognizant INT;
DECLARE @ISTicketTypeApplicable INT
SET @CustomerID=(SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0 )
SET @IsDebtEnabled=(SELECT IsDebtEnabled FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0)
SET @IsCognizant=(SELECT IsCognizant FROM AVL.Customer(NOLOCK) WHERE CustomerID=@CustomerID AND IsDeleted=0)
SET @ISTicketTypeApplicable=(SELECT COUNT(TTM.TicketTypeMappingID) FROM AVL.TK_MAP_TicketTypeMapping TTM INNER JOIN AVL.TK_ImportTicketDumpDetails ITD 
ON TTM.TicketType=ITD.[Ticket Type] AND ITD.ProjectID=@ProjectID WHERE TTM.IsDeleted=0 AND TTM.DebtConsidered='Y' AND ITD.[Ticket ID]=@TicketID)

IF  (@IsDebtEnabled ='Y' AND ((@IsCognizant=1)) OR (@ISTicketTypeApplicable > 0 AND @IsCognizant=0) )
BEGIN

IF(@IsAutoClassified = 'Y')
BEGIN

DECLARE @PATTERN_ID VARCHAR(MAX)
DECLARE @PATTERN_TYPE VARCHAR(MAX)

SET @DDCausecodeML = (Select Top 1 CC.CauseID from AVL.TK_ImportTicketDumpDetails STM Inner Join AVL.DEBT_MAP_CauseCode CC 
on CC.ProjectID = STM.ProjectID and CC.CauseCode = STM.TicketLocation  where STM.ProjectID = @ProjectID and STM.[Ticket ID] = @TicketID)

SET @DDResolutioncodeML=(SELECT TOP 1 RC.ResolutionID from AVL.TK_ImportTicketDumpDetails STM Inner Join AVL.DEBT_MAP_ResolutionCode RC
ON RC.ProjectID=STM.ProjectID AND RC.ResolutionCode=STM.Reviewer WHERE STM.ProjectID = @ProjectID and STM.[Ticket ID] = @TicketID)

CREATE TABLE #Tmp_Pattern
(
ID INT IDENTITY(1,1),
PATTERNID VARCHAR(MAX),
PATTERN_TYPE VARCHAR(MAX)
)

INSERT INTO #Tmp_Pattern 
SELECT ID, TicketPattern from [AVL].[ML_TRN_MLPatternValidation] WHERE ProjectID = @ProjectID AND 
ApplicationID = @ApplicationID AND IsApprovedOrMute = 1 AND MLCauseCodeID = @DDCausecodeML 
AND MLResolutionCode=@DDResolutioncodeML
AND IsDeleted=0

--SELECT * FROM #Tmp_Pattern

DECLARE @MIN INT
SET @MIN = (SELECT MIN(ID) FROM #Tmp_Pattern)

DECLARE @MAX INT
SET @MAX = (SELECT MAX(ID) FROM #Tmp_Pattern)

CREATE TABLE #FINAL_PATTERN_SPLIT
(
PATTERNID VARCHAR(MAX),
PATTERN_WORD VARCHAR(MAX)
)

WHILE(@MIN <= @MAX)
BEGIN

SET @PATTERN_ID = (Select PATTERNID from #Tmp_Pattern where ID = @MIN)
SET @PATTERN_TYPE = (Select PATTERN_TYPE from #Tmp_Pattern where ID = @MIN)

INSERT INTO #FINAL_PATTERN_SPLIT
EXEC Proc_SplitWords @PATTERN_ID, @PATTERN_TYPE

SET @MIN = @MIN + 1;
END

--SELECT * FROM #FINAL_PATTERN_SPLIT

CREATE TABLE #TICDESC
(
TD VARCHAR(MAX)
)

INSERT INTO #TICDESC
EXEC Proc_SplitWords_TD @TicketDescription 

DELETE FROM #TICDESC WHERE TD IN (SELECT Stopword FROM Debt_Stopwords)

Select Top 1 FPT.PATTERNID, MLP.TicketPattern, count(FPT.PATTERNID) as CountofRepeat, MLP.MLAccuracy INTO #TempFinal
from #FINAL_PATTERN_SPLIT FPT INNER JOIN [AVL].[ML_TRN_MLPatternValidation] MLP
on FPT.PATTERNID = MLP.ID
where FPT.PATTERN_WORD in (SELECT * FROM #TICDESC) and MLP.IsDeleted = 0 and MLP.IsApprovedOrMute = 1
GROUP BY FPT.PATTERNID,MLP.TicketPattern,MLP.MLAccuracy
ORDER BY CountofRepeat DESC,MLP.MLAccuracy DESC 

--select * from #TempFinal

DECLARE @TimeTickerID BIGINT


set @TimeTickerID=(select top 1 TimeTickerID from AVL.TK_TRN_TicketDetail ORDER by TimeTickerID)
set @TimeTickerID=@TimeTickerID+1
INSERT INTO  AVL.[TempDebtFieldsBulkUpload]
Select DISTINCT @ProjectID,@CogID,@TicketID,@TicketDescription,@ApplicationID,
DebtClassificationID =
       CASE 
       WHEN MLP.SMEDebtClassificationID IS NOT NULL THEN MLP.SMEDebtClassificationID 
       WHEN MLP.SMEDebtClassificationID IS NULL AND MLDebtClassificationID IS NOT NULL THEN MLP.MLDebtClassificationID 
       --WHEN MLP.SMEDebtClassificationID IS NULL AND MLDebtClassificationID IS NULL AND MLP.AnalystDebtClassificationID IS NOT NULL
       --THEN MLP.AnalystDebtClassificationID 
       ELSE NULL
	   END ,

AvoidableFlagID = 
       CASE 
       WHEN MLP.SMEAvoidableFlagID IS NOT NULL THEN MLP.SMEAvoidableFlagID 
       WHEN MLP.SMEAvoidableFlagID IS NULL AND MLAvoidableFlagID IS NOT NULL THEN MLP.MLAvoidableFlagID 
       --WHEN MLP.SMEAvoidableFlagID IS NULL AND MLAvoidableFlagID IS NULL AND MLP.AnalystAvoidableFlagID IS NOT NULL
       --THEN MLP.AnalystAvoidableFlagID
       ELSE NULL
	   END ,
ResidualFlagID =
	   CASE 
       WHEN MLP.SMEResidualFlagID IS NOT NULL THEN MLP.SMEResidualFlagID 
       WHEN MLP.SMEResidualFlagID IS NULL AND MLP.MLResidualFlagID IS NOT NULL THEN MLP.MLResidualFlagID 
	   --WHEN MLP.SMEResidualFlagID IS NULL AND MLP.MLResidualFlagID IS NULL AND MLP.AnalystResidualFlagID IS NOT NULL
	   --THEN MLP.AnalystResidualFlagID
       ELSE NULL
	   END,
	   ResolutionCodeID = 
       CASE 
       WHEN MLP.SMEResolutionCodeID IS NOT NULL THEN MLP.SMEResolutionCodeID 
       WHEN MLP.SMEResolutionCodeID IS NULL AND MLP.MLResolutionCode IS NOT NULL THEN MLP.MLResolutionCode
       --WHEN MLP.SMECauseCodeID IS NULL AND MLCauseCodeID IS NULL AND MLP.AnalystCauseCodeID IS NOT NULL
       --THEN MLP.AnalystCauseCodeID
       ELSE NULL
	   END,
CauseCodeID = 
       CASE 
       WHEN MLP.SMECauseCodeID IS NOT NULL THEN MLP.SMECauseCodeID 
       WHEN MLP.SMECauseCodeID IS NULL AND MLCauseCodeID IS NOT NULL THEN MLP.MLCauseCodeID
       --WHEN MLP.SMECauseCodeID IS NULL AND MLCauseCodeID IS NULL AND MLP.AnalystCauseCodeID IS NOT NULL
       --THEN MLP.AnalystCauseCodeID
       ELSE NULL
	   END,'N',@CogID,GETDATE(), 'ML'

from #FINAL_PATTERN_SPLIT FPT INNER JOIN [AVL].[ML_TRN_MLPatternValidation] MLP
on FPT.PATTERNID = MLP.ID
INNER JOIN #TempFinal TF ON TF.PATTERNID = MLP.ID
WHERE MLP.ProjectID=@ProjectID AND MLP.IsDeleted=0 AND MLP.IsApprovedOrMute=1

Select DISTINCT @ProjectID,@CogID,@TicketID,@TicketDescription,@ApplicationID,
DebtClassificationID =
       CASE 
       WHEN MLP.SMEDebtClassificationID IS NOT NULL THEN MLP.SMEDebtClassificationID 
       WHEN MLP.SMEDebtClassificationID IS NULL AND MLDebtClassificationID IS NOT NULL THEN MLP.MLDebtClassificationID 
       --WHEN MLP.SMEDebtClassificationID IS NULL AND MLDebtClassificationID IS NULL AND MLP.AnalystDebtClassificationID IS NOT NULL
       --THEN MLP.AnalystDebtClassificationID 
       ELSE NULL
	   END ,

AvoidableFlagID = 
       CASE 
       WHEN MLP.SMEAvoidableFlagID IS NOT NULL THEN MLP.SMEAvoidableFlagID 
       WHEN MLP.SMEAvoidableFlagID IS NULL AND MLAvoidableFlagID IS NOT NULL THEN MLP.MLAvoidableFlagID 
       --WHEN MLP.SMEAvoidableFlagID IS NULL AND MLAvoidableFlagID IS NULL AND MLP.AnalystAvoidableFlagID IS NOT NULL
       --THEN MLP.AnalystAvoidableFlagID
       ELSE NULL
	   END ,
ResidualFlagID =
	   CASE 
       WHEN MLP.SMEResidualFlagID IS NOT NULL THEN MLP.SMEResidualFlagID 
       WHEN MLP.SMEResidualFlagID IS NULL AND MLP.MLResidualFlagID IS NOT NULL THEN MLP.MLResidualFlagID 
	   --WHEN MLP.SMEResidualFlagID IS NULL AND MLP.MLResidualFlagID IS NULL AND MLP.AnalystResidualFlagID IS NOT NULL
	   --THEN MLP.AnalystResidualFlagID
       ELSE NULL
	   END,
	      ResolutionCodeID = 
       CASE 
WHEN MLP.SMEResolutionCodeID IS NOT NULL THEN MLP.SMEResolutionCodeID 
       WHEN MLP.SMEResolutionCodeID IS NULL AND MLP.MLResolutionCode IS NOT NULL THEN MLP.MLResolutionCode
       --WHEN MLP.SMECauseCodeID IS NULL AND MLCauseCodeID IS NULL AND MLP.AnalystCauseCodeID IS NOT NULL
       --THEN MLP.AnalystCauseCodeID
       ELSE NULL
	   END,
CauseCodeID = 
       CASE 
       WHEN MLP.SMECauseCodeID IS NOT NULL THEN MLP.SMECauseCodeID 
       WHEN MLP.SMECauseCodeID IS NULL AND MLCauseCodeID IS NOT NULL THEN MLP.MLCauseCodeID
       --WHEN MLP.SMECauseCodeID IS NULL AND MLCauseCodeID IS NULL AND MLP.AnalystCauseCodeID IS NOT NULL
       --THEN MLP.AnalystCauseCodeID
       ELSE NULL
	   END,'N',@CogID,GETDATE(), 'ML'

from #FINAL_PATTERN_SPLIT FPT INNER JOIN [AVL].[ML_TRN_MLPatternValidation] MLP
on FPT.PATTERNID = MLP.ID
INNER JOIN #TempFinal TF ON TF.PATTERNID = MLP.ID
WHERE MLP.ProjectID=@ProjectID AND MLP.IsDeleted=0 AND MLP.IsApprovedOrMute=1


DROP TABLE #FINAL_PATTERN_SPLIT
DROP TABLE #TICDESC
DROP TABLE #Tmp_Pattern
DROP TABLE #TempFinal

DECLARE @DC VARCHAR(10);
DECLARE @AF VARCHAR(10);
DECLARE @RD VARCHAR(10);
DECLARE @CC VARCHAR(10);
DECLARE @RC VARCHAR(10);

Select @DC=DebtClassificationID , @AF=AvoidableFlagID, @RD = ResidualFlagID,@RC=ResolutionCodeID, @CC =CauseCodeID  from
AVL.[TempDebtFieldsBulkUpload] where ProjectID = @ProjectID and	TicketID = @TicketID and ApplicationID = @ApplicationID

select * from AVL.[TempDebtFieldsBulkUpload]
DECLARE @cOUNT int
set @cOUNT = (sELECT cOUNT(*) FROM AVL.[TempDebtFieldsBulkUpload] where ProjectID = @ProjectID and TicketID = @TicketID  and	ApplicationID = @ApplicationID);

IF((@cOUNT = 0) or ((@DC = NULL AND @AF = NULL AND @RD = NULL AND  @RC=NULL AND @CC = NULL ) OR (@DC = '' AND @AF = '' AND @RD = '' AND @RC='' AND @CC = '' )) AND (@IsDDAutoClassified = 'Y'))
BEGIN


Select 'Coming to Else'

Insert into AVL.[TempDebtFieldsBulkUpload] values(@ProjectID, @CogID, @TicketID, @TicketDescription, @ApplicationID, NULL, NULL, NULL,NULL, NULL, 'N', @CogID, GETDATE(), NULL )

UPDATE TDF SET TDF.DebtClassificationID = DIC.DebtClassificationID, TDF.AvoidableFlagID = DIC.AvoidableFlagID,
TDF.ResidualFlagID = DIC.ResidualDebtID, TDF.CauseCodeID = Mc.CauseID , TDF.UpdatedBY = 'DD' from [AVL].[Debt_MAS_ProjectDataDictionary] DIC Inner Join AVL.[TempDebtFieldsBulkUpload]  TDF
ON DIC.ProjectID = TDF.ProjectID AND DIC.ApplicationID = TDF.ApplicationID 
INNER JOIN [AVL].[TK_ImportTicketDumpDetails] SS on SS.ProjectID = TDF.ProjectID and SS.[Ticket ID] = TDF.TicketID
INNER JOIN [AVL].[DEBT_MAP_CauseCode] MC on MC.ProjectID = TDF.ProjectID and MC.CauseCode = SS.TicketLocation
INNER JOIN [AVL].[DEBT_MAP_ResolutionCode] MR on MR.ProjectID = TDF.ProjectID and MR.ResolutionCode = SS.Reviewer
where DIC.CauseCodeID = Mc.CauseID and DIC.ResolutionCodeID = MR.ResolutionID and TDF.TicketID = @TicketID
Select @DC=isnull(DebtClassificationID,'0') , @AF=isnull(AvoidableFlagID,'0'), @RD =isnull( ResidualFlagID,'0'), @CC =isnull(CauseCodeID,'0') from
AVL.[TempDebtFieldsBulkUpload] where ProjectID = @ProjectID and	TicketID = @TicketID 
--and ApplicationID = @ApplicationID
IF( (@DC = '0' AND @AF = '0' AND @RD = '0' AND @CC = '0'))
BEGIN
--SELECT * FROM AVL.TRN_DebtClassificationModeDetails
insert into AVL.TRN_DebtClassificationModeDetails
values(NULL,NULL,NULL,NULL,NULL,NULL,NULL,5,2,0,@CogID,GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
END
ELSE
BEGIN
insert into AVL.TRN_DebtClassificationModeDetails values(NULL,@DC,@AF,@RD,NULL,NULL,NULL,3,2,0,@CogID,GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
END
END
ELSE
begin
insert into AVL.TRN_DebtClassificationModeDetails values(NULL,@DC,@AF,@RD,NULL,NULL,NULL,1,2,0,@CogID,GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
END


UPDATE AVL.TK_ImportTicketDumpDetails set DebtModeID=(select top 1 ID from AVL.TRN_DebtClassificationModeDetails order by ID desc)
where [Ticket ID]=@TicketID AND ProjectID=@ProjectID
END

ELSE IF((@IsDDAutoClassified = 'Y') AND (@IsAutoClassified = 'N') ) 
BEGIN

--Select * from TRN.TempDebtFieldsBulkUpload 

Select 'Coming to DD Else'

declare @DebtClassificationFlag NVARCHAR(MAX),@AvoidableFlag NVARCHAR(max),@ResidualDebt NVARCHAR(MAX)

Insert into AVL.[TempDebtFieldsBulkUpload]  values(@ProjectID, @CogID, @TicketID, @TicketDescription, @ApplicationID, NULL, NULL, NULL,NULL, NULL, 'N', @CogID, GETDATE(), NULL )


UPDATE TDF SET TDF.DebtClassificationID = DIC.DebtClassificationID, TDF.AvoidableFlagID = DIC.AvoidableFlagID,
TDF.ResidualFlagID = DIC.ResidualDebtID, TDF.CauseCodeID = Mc.CauseID , TDF.UpdatedBY = 'DD' from [AVL].[Debt_MAS_ProjectDataDictionary] DIC Inner Join AVL.[TempDebtFieldsBulkUpload]  TDF
ON DIC.ProjectID = TDF.ProjectID AND DIC.ApplicationID = TDF.ApplicationID 
INNER JOIN [AVL].[TK_ImportTicketDumpDetails] SS on SS.ProjectID = TDF.ProjectID and SS.[Ticket ID] = TDF.TicketID
INNER JOIN [AVL].[DEBT_MAP_CauseCode] MC on MC.ProjectID = TDF.ProjectID and MC.CauseCode = SS.TicketLocation
INNER JOIN [AVL].[DEBT_MAP_ResolutionCode] MR on MR.ProjectID = TDF.ProjectID and MR.ResolutionCode = SS.Reviewer
where DIC.CauseCodeID = Mc.CauseID and DIC.ResolutionCodeID = MR.ResolutionID and TDF.TicketID = @TicketID 

select @DebtClassificationFlag=ISNULL(DebtClassificationID,'0'),@ResidualDebt=ISNULL(ResidualFlagID,'0'),@AvoidableFlag
=ISNULL(AvoidableFlagID,'0') from AVL.TempDebtFieldsBulkUpload where  TicketID=@TicketID

if(@DebtClassificationFlag='0' and @AvoidableFlag='0' and @ResidualDebt='0')
BEGIN


insert into AVL.TRN_DebtClassificationModeDetails values(NULL,NULL,NULL,NULL,NULL,NULL,NULL,5,2,0,@CogID,GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
END
ELSE
BEGIN
insert into AVL.TRN_DebtClassificationModeDetails values(NULL,@DebtClassificationFlag,@AvoidableFlag,@ResidualDebt,NULL,NULL,NULL,3,2,0,@CogID,GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
END

UPDATE AVL.TK_ImportTicketDumpDetails set DebtModeID=(select top 1 ID from AVL.TRN_DebtClassificationModeDetails order by ID desc)
where [Ticket ID]=@TicketID AND ProjectID=@ProjectID 
END
END

END
