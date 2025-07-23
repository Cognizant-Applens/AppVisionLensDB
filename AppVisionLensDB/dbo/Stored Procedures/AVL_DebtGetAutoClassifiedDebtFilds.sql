/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--exec [AVL_DebtGetAutoClassifiedDebtFilds]  '93027','BID','DataDict',365,362,'Y','N','0','347','141447','548986'
-- [AVL_DebtGetAutoClassifiedDebtFilds] 4, 'AVM DART', 'access issue', 1,'', 'N','Y'
-- [AVL_DebtGetAutoClassifiedDebtFilds] 19100, 'AVM DART', 'My Error is due to hot spot', 59,31, 'Y','Y'
--[dbo].[AVL_DebtGetAutoClassifiedDebtFildsnew]  10337,'TestApp','',1,2,'N','Y','0','1','8080','627384'
CREATE PROCEDURE [dbo].[AVL_DebtGetAutoClassifiedDebtFilds] 
--44655,'Dart','PeopleSoft Launching Issue',7,7,'Y','Y','0',17,19245,659977

@ProjectID VARCHAR(MAX),
@ApplicationName VARCHAR(MAX),
@TicketDescription NVARCHAR(MAX),
@Causecode INT,
@Resolutioncode INT,
@IsAutoClassified CHAR,
@IsDDAutoClassified CHAR,
@ServiceID NVARCHAR(10)= NULL,
@TicketTypeID NVARCHAR(10)= NULL,
@TimeTickerID  nvarchar(max),
@UserID nvarchar(max)
AS
BEGIN
--BEGIN TRY
--SELECT 1
SET @TicketDescription=LTRIM(RTRIM(@TicketDescription));
delete from [AVL].[TRN_DebtClassificationModeDetails_Dump]
DECLARE @IsDebtEnabled NVARCHAR(10);
DECLARE @CustomerID BIGINT;
DECLARE @IsCognizant INT;
SET @CustomerID=(SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0 )
SET @IsDebtEnabled=(SELECT IsDebtEnabled FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0)
SET @IsCognizant=(SELECT IsCognizant FROM AVL.Customer(NOLOCK) WHERE CustomerID=@CustomerID AND IsDeleted=0)

DECLARE @IsserviceApplicable INT
DECLARE @ISTicketTypeApplicable INT

DECLARE @DebtClassificationflag NVARCHAR(max),@AvoidableFlag NVARCHAR(max),@ResidualFlag NVARCHAR(max)
SET @IsserviceApplicable =(Select cOUNT(ServiceID) from  AVL.TK_MAS_Service(NOLOCK) 
							where ServiceID in (1,4,5,6,7,8,10)  AND ServiceID=@ServiceID)
SET @ISTicketTypeApplicable=(sELECT cOUNT(TicketTypeMappingID)  FROM AVL.TK_MAP_TicketTypeMapping WHERE ProjectID=@ProjectID AND DebtConsidered='Y' AND TicketTypeMappingID=@TicketTypeID )

print @ISTicketTypeApplicable

IF  (@IsDebtEnabled ='Y' AND ((@IsCognizant=1) AND  (@IsserviceApplicable > 0)) OR (@ISTicketTypeApplicable > 0 AND @IsCognizant=0) )
BEGIN


DECLARE @ApplicationID  VARCHAR(MAX)

SET @ApplicationID =  (Select Top 1 ApplicationID from AVL.APP_MAS_ApplicationDetails(NOLOCK) where ApplicationID in 
(Select ApplicationID from AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) where ProjectID = @ProjectID) and ApplicationName = @ApplicationName )

--SELECT @ApplicationID
declare @mlsignoffdate datetime,@mlsignoff nvarchar(max);
select @mlsignoffdate=MLSignOffDate,@mlsignoff=IsMLSignOff from AVL.MAS_ProjectDebtDetails where ProjectID=@ProjectID and IsDeleted=0
IF(@IsAutoClassified = 'Y')
BEGIN 
PRINT 'INML'
DECLARE @PATTERN_ID VARCHAR(MAX)
DECLARE @PATTERN_TYPE VARCHAR(MAX)

CREATE TABLE #Tmp_Pattern
(
ID INT IDENTITY(1,1),
PATTERNID VARCHAR(MAX),
PATTERN_TYPE VARCHAR(MAX)
)

INSERT INTO #Tmp_Pattern 
SELECT Distinct ID, TicketPattern from AVL.ML_TRN_MLPatternValidation WHERE ProjectID = @ProjectID AND 
ApplicationID = @ApplicationID AND IsApprovedOrMute = 1 and IsDeleted = 0 and MLCauseCodeID = @Causecode and MLResolutionCode=@Resolutioncode
 
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

print @PATTERN_ID
print @PATTERN_TYPE

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

Select Top 1 FPT.PATTERNID, MLP.TicketPattern, count(FPT.PATTERNID) as CountofRepeat, MLP.MLAccuracy
INTO #TempFinal
from #FINAL_PATTERN_SPLIT FPT INNER JOIN AVL.ML_TRN_MLPatternValidation MLP
on FPT.PATTERNID = MLP.ID
where PATTERN_WORD in (SELECT * FROM #TICDESC) GROUP BY FPT.PATTERNID,MLP.TicketPattern,MLP.MLAccuracy
ORDER BY CountofRepeat DESC,MLP.MLAccuracy DESC

--select * from #TempFinal

Select DISTINCT MLP.ProjectID, MLP.ApplicationID ,TF.PATTERNID, TF.TicketPattern,TF.CountofRepeat, TF.MLAccuracy, 
ResidualFlagID =
	   CASE 
       WHEN MLP.SMEResidualFlagID IS NOT NULL THEN MLP.SMEResidualFlagID 
       WHEN MLP.SMEResidualFlagID IS NULL AND MLP.MLResidualFlagID IS NOT NULL THEN MLP.MLResidualFlagID 
	   --WHEN MLP.SMEResidualFlagID IS NULL AND MLP.MLResidualFlagID IS NULL AND MLP.AnalystResidualFlagID IS NOT NULL
	   --THEN MLP.AnalystResidualFlagID
       ELSE NULL
	   END,

DebtClassificationID =
       CASE 
       WHEN MLP.SMEDebtClassificationID IS NOT NULL THEN MLP.SMEDebtClassificationID 
       WHEN MLP.SMEDebtClassificationID IS NULL AND MLDebtClassificationID IS NOT NULL THEN MLP.MLDebtClassificationID 
       --WHEN MLP.SMEDebtClassificationID IS NULL AND MLDebtClassificationID IS NULL AND MLP.AnalystDebtClassificationID IS NOT NULL
       --THEN MLP.AnalystDebtClassificationID 
       ELSE NULL
	   END,

AvoidableFlagID = 
       CASE 
       WHEN MLP.SMEAvoidableFlagID IS NOT NULL THEN MLP.SMEAvoidableFlagID 
       WHEN MLP.SMEAvoidableFlagID IS NULL AND MLAvoidableFlagID IS NOT NULL THEN MLP.MLAvoidableFlagID 
       --WHEN MLP.SMEAvoidableFlagID IS NULL AND MLAvoidableFlagID IS NULL AND MLP.AnalystAvoidableFlagID IS NOT NULL
       --THEN MLP.AnalystAvoidableFlagID
       ELSE NULL
	   END

into #Tmp_Final_Cause from #FINAL_PATTERN_SPLIT FPT INNER JOIN AVL.ML_TRN_MLPatternValidation MLP
on FPT.PATTERNID = MLP.ID
INNER JOIN #TempFinal TF ON TF.PATTERNID = MLP.ID


--select * from #Tmp_Final_Cause


--Select DebtClassificationID, AvoidableFlagID, ResidualFlagID from #Tmp_Final_Cause 

DECLARE @DC VARCHAR(10);
DECLARE @AF VARCHAR(10);
DECLARE @RD VARCHAR(10);

Select @DC=DebtClassificationID , @AF=AvoidableFlagID, @RD = ResidualFlagID from #Tmp_Final_Cause 
PRINT @DC
PRINT @AF
PRINT @RD
DECLARE @cOUNT int
set @cOUNT = (sELECT cOUNT(*) FROM #Tmp_Final_Cause);

IF (((@cOUNT = 0) or ((@DC = NULL AND @AF = NULL AND @RD = NULL) OR (@DC = '' AND @AF = '' AND @RD = ''))) AND (@IsDDAutoClassified = 'Y'))

--Select 'Coming to Else Part'

BEGIN
 
Select @ProjectID AS ProjectID ,@ApplicationID AS ApplicationID , @Causecode AS CausecodeID, @Resolutioncode AS ResolutioncodeID ,
NULL AS DebtClassificationID, NULL AS AvoidableFlagID, NULL AS ResidualFlagID into #Tmp_Final_Cause_dd

UPDATE TDF SET TDF.DebtClassificationID = DIC.DebtClassificationID, TDF.AvoidableFlagID = DIC.AvoidableFlagID,
TDF.ResidualFlagID = DIC.ResidualDebtID from [AVL].[Debt_MAS_ProjectDataDictionary] DIC Inner Join #Tmp_Final_Cause_dd TDF
ON DIC.ProjectID = TDF.ProjectID AND DIC.ApplicationID = TDF.ApplicationID 
where DIC.CauseCodeID = @Causecode and DIC.ResolutionCodeID = @Resolutioncode



IF NOT EXISTS (Select DebtClassificationID, AvoidableFlagID, ResidualFlagID from #Tmp_Final_Cause )
BEGIN
Select DebtClassificationID, AvoidableFlagID, ResidualFlagID from #Tmp_Final_Cause_dd 
Select @DebtClassificationflag=isnull(DebtClassificationID,'0'),@AvoidableFlag= isnull(AvoidableFlagID,'0'), @ResidualFlag=isnull(ResidualFlagID,'0') from #Tmp_Final_Cause_dd 
	if((@DebtClassificationflag='0' and @AvoidableFlag='0' and @ResidualFlag='0'))
	BEGIN
	insert into [AVL].[TRN_DebtClassificationModeDetails_Dump]
	--AVL.TRN_DebtClassificationModeDetails
	 (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode) 
 values(@TimeTickerID,NULL ,NULL,NULL,NULL,null,NULL,1,0,@UserID,GETDATE(),5)
	END
	ELSE
	BEGIN
	insert into [AVL].[TRN_DebtClassificationModeDetails_Dump]
	--AVL.TRN_DebtClassificationModeDetails 
	(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode) 
 values(@TimeTickerID,@DebtClassificationflag,@AvoidableFlag,@ResidualFlag,NULL,null,NULL,1,0,@UserID,GETDATE(),3)
	END

END
END

ELSE
BEGIN
	
	Select @DebtClassificationflag=DebtClassificationID,@AvoidableFlag= AvoidableFlagID, @ResidualFlag=ResidualFlagID from #Tmp_Final_Cause
		Select DebtClassificationID, AvoidableFlagID, ResidualFlagID from #Tmp_Final_Cause

--		if(@DebtClassificationflag=NULL and @AvoidableFlag=NULL and  @ResidualFlag=NULL)
--	BEGIN
--	insert into AVL.TRN_DebtClassificationModeDetails (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
--UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode) 
-- values(@TimeTickerID,@DebtClassificationflag,@AvoidableFlag,@ResidualFlag,NULL,null,NULL,1,0,@UserID,GETDATE(),5)
--	END
--	ELSE
--	BEGIN
		insert into [AVL].[TRN_DebtClassificationModeDetails_Dump]
		--AVL.TRN_DebtClassificationModeDetails 
		(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode) 
 values(@TimeTickerID,@DebtClassificationflag,@AvoidableFlag,@ResidualFlag,NULL,null,NULL,1,0,@UserID,GETDATE(),1)
 --END
--select @DebtClassificationflag=DebtClassificationID,@AvoidableFlag=AvoidableFlagID,@ResidualFlag=ResidualFlagID from  #Tmp_Final_Cause

END

END

ELSE IF((@IsDDAutoClassified = 'Y') AND (@IsAutoClassified = 'N')) 
BEGIN


PRINT 'inside @IsDDAutoClassified=Y and @IsAutoClassified=N'
--Select 'Coming to DD Else Part'

Select @ProjectID AS ProjectID ,@ApplicationID AS ApplicationID , @Causecode AS CausecodeID, @Resolutioncode AS ResolutioncodeID ,
 NULL AS DebtClassificationID, NULL AS AvoidableFlagID, NULL AS ResidualFlagID into #Tmp_DD

UPDATE TDF SET TDF.DebtClassificationID = DIC.DebtClassificationID, TDF.AvoidableFlagID = DIC.AvoidableFlagID,
TDF.ResidualFlagID = DIC.ResidualDebtID from [AVL].[Debt_MAS_ProjectDataDictionary] DIC Inner Join #Tmp_DD TDF
ON DIC.ProjectID = TDF.ProjectID AND DIC.ApplicationID = TDF.ApplicationID 
where DIC.CauseCodeID = @Causecode and DIC.ResolutionCodeID = @Resolutioncode

Select @DebtClassificationflag=isnull(DebtClassificationID,'0'),@AvoidableFlag= isnull(AvoidableFlagID,'0'), @ResidualFlag=isnull(ResidualFlagID,'0') from #Tmp_DD 

declare @countfordd int;

set @countfordd=(SELECT count(*) from #Tmp_DD )

Select DebtClassificationID, AvoidableFlagID, ResidualFlagID from #Tmp_DD 

if((@DebtClassificationflag='0' and @AvoidableFlag='0'AND @ResidualFlag='0') or (@DebtClassificationflag='' and @AvoidableFlag='' AND @ResidualFlag=''))
BEGIN
print 5
insert into [AVL].[TRN_DebtClassificationModeDetails_Dump]
--AVL.TRN_DebtClassificationModeDetails 
(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode) 
 values(@TimeTickerID,NULL,NULL,NULL,NULL,null,NULL,1,0,@UserID,GETDATE(),5)
end
ELSE
begin
print 3
insert into [AVL].[TRN_DebtClassificationModeDetails_Dump]
-- AVL.TRN_DebtClassificationModeDetails 
(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode) 
 values(@TimeTickerID,@DebtClassificationflag,@AvoidableFlag,@ResidualFlag,NULL,null,NULL,1,0,@UserID,GETDATE(),3)
 end
END
ELSE
BEGIN
PRINT 'IN LAST'
	--SELECT * FROM AVL.TK_MAP_TicketTypeMapping(NOLOCK) WHERE ProjectID=@ProjectID AND DebtConsidered='Y'
Select NULL AS DebtClassificationID, NULL AS AvoidableFlagID,NULL AS ResidualFlagID
select @DebtClassificationflag=NULL ,@AvoidableFlag=null ,@ResidualFlag=null 
insert into [AVL].[TRN_DebtClassificationModeDetails_Dump]
--AVL.TRN_DebtClassificationModeDetails 
(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode) 
 values(@TimeTickerID,@DebtClassificationflag,@AvoidableFlag,@ResidualFlag,NULL,null,NULL,1,0,@UserID,GETDATE(),5)

END


END

--END TRY  
--BEGIN CATCH  

--		DECLARE @ErrorMessage VARCHAR(MAX);

--		SELECT @ErrorMessage = ERROR_MESSAGE()

--		--INSERT Error    
--		EXEC AVL_InsertError '[dbo].[AVL_DebtGetAutoClassifiedDebtFilds] ', @ErrorMessage, @ProjectID,0
		
--	END CATCH  



END




--SELECT * from AVL.ML_TRN_MLPatternValidation WHERE ProjectID = 4 AND IsDeleted=0
--ApplicationID = 3 AND IsApprovedOrMute = 1 and IsDeleted = 1 and MLCauseCodeID = 1

--select * from AVL.APP_MAS_ApplicationDetails where ApplicationName like '%AVM DART%'




--UPDATE AVL.ML_TRN_MLPatternValidation set IsDeleted=0 where ID IN(1,2,3)
