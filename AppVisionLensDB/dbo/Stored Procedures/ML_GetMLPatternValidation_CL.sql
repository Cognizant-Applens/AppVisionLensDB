/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_GetMLPatternValidation_CL]
(
@ProjectID NVARCHAR(200),
@AppID nVARCHAR(MAX)

)
AS 
BEGIN 
BEGIN TRY
DECLARE @CustomerID INT=0;
			DECLARE @IsCognizantID INT;
			SET @CustomerID=(SELECT top 1 CustomerID FROM AVL.MAS_LoginMaster WHERE ProjectID=@ProjectID AND IsDeleted=0)
			SET @IsCognizantID=(SELECT top 1 IsCognizant FROM AVL.Customer WHERE CustomerID=@CustomerID AND IsDeleted=0)
PRINT @AppID 
Create Table #tempid (
  ITEM bigint
)
IF @AppID IS NOT NULL AND LEN(@AppID)>0
BEGIN 
INSERT INTO #tempid SELECT ITEM FROM split(@AppID,',')
END
ELSE
BEGIN
INSERT INTO #tempid SELECT APM.ApplicationID  FROM AVL.APP_MAP_ApplicationProjectMapping APM 
WHERE
 APM.ProjectID=@projectID AND APM.IsDeleted=0

END


--SELECT * FROM #tempid


CREATE TABLE #discrepency
(
ticketpattern nvarchar(max),
patterncount int,
discrepancy char(1),
causecode int,
resolutioncode int,
ApplicationID bigint
)

INSERT INTO #discrepency
SELECT ticketpattern,COUNT(*) as patterncount,'Y' as discrepancy,O.SMECauseCodeID as causecode,ISNULL(O.SMEResolutionCodeID,0) as resolutioncode,o.ApplicationID as ApplicationID FROM AVL.CL_PatterOccurence O
INNER JOIN #tempid t ON t.item = O.ApplicationID
WHERE O.isdeleted = 0 AND O.ProjectID=@ProjectID 

GROUP BY ticketpattern,O.SMECauseCodeID,O.SMEResolutionCodeID,o.ApplicationID HAVING COUNT(*) > 1 ORDER BY TicketPattern

CREATE TABLE #NoDiscrepency
(
ticketpattern nvarchar(max),
patterncount int,
discrepancy char(1),
causecode int,
resolutioncode int,
ApplicationID bigint
)

INSERT INTO #NoDiscrepency
SELECT ticketpattern,count(*),'N',O.SMECauseCodeID,ISNULL(O.SMEResolutionCodeID,0),o.ApplicationID FROM AVL.CL_PatterOccurence O
INNER JOIN #tempid t ON t.item = O.ApplicationID
WHERE O.isdeleted = 0 AND O.ProjectID=@ProjectID 

GROUP BY ticketpattern,O.SMECauseCodeID,O.SMEResolutionCodeID,o.ApplicationID HAVING count(*) = 1 ORDER BY TicketPattern

create table #tmpDiscrepancy
(
ticketpattern nvarchar(max),
patterncount int,
discrepancy char(1),
causecode int,
resolutioncode int,
ApplicationID bigint
)

INSERT INTO #tmpDiscrepancy
SELECT * FROM  #discrepency
UNION ALL
SELECT * FROM #NoDiscrepency


--select * from #tmpDiscrepancy
SELECT 
CASE WHEN TicketPattern not in (SELECT ticketpattern FROM avl.ML_TRN_MLPatternValidation) THEN 'New' ELSE 'Old' 
END AS 'PatternType',
* 
INTO #Debt_MLPatternValidation FROM AVL.ML_TRN_MLPatternValidation_CL(NOLOCK) MV
INNER JOIN #tempid t ON t.item = MV.ApplicationID
WHERE MV.projectid = @ProjectID AND   MV.IsDeleted=0

--New Learnings 
SELECT cl.ID,cl.InitialLearningID,cl.ProjectID,cl.ApplicationID,cl.ApplicationTypeID,cl.TechnologyID,cl.TicketPattern,cl.MLResidualFlagID,
cl.MLDebtClassificationID,cl.MLAvoidableFlagID,cl.MLCauseCodeID,cl.MLAccuracy,cl.TicketOccurence,cl.AnalystResidualFlagID,
cl.AnalystResolutionCodeID,cl.AnalystCauseCodeID,cl.AnalystDebtClassificationID,cl.AnalystAvoidableFlagID,cl.SMEComments,cl.SMEResidualFlagID,cl.SMEDebtClassificationID,cl.SMEAvoidableFlagID,cl.SMECauseCodeID,cl.IsApprovedOrMute,cl.CreatedBy,cl.CreatedDate,cl.ModifiedBy,cl.ModifiedDate,cl.ExpectedCompletionDate,cl.ReasonforResidual,cl.MLResolutionCodeID
INTO #tmpNewLearnings FROM AVL.ML_TRN_MLPatternValidation_CL cl
inner join AVL.ML_TRN_MLPatternValidation ml ON ml.TicketPattern = cl.TicketPattern 
and cl.ApplicationID = ml.ApplicationID and ml.ProjectID = cl.ProjectID and cl.MLCauseCodeID = ml.MLCauseCodeID and cl.MLResolutionCodeID = ml.MLResolutionCode
WHERE cl.projectid = @ProjectID ORDER BY  cl.ID

UPDATE ml SET patterntype =  CASE WHEN id not in (SELECT id FROM #tmpNewLearnings) 
THEN 'New' ELSE 'Old'END  FROM #Debt_MLPatternValidation ml


--Update Existing Approve/Mute all in Initial Learnings
UPDATE cl SET cl.IsApprovedOrMute = CASE WHEN isnull(cl.IsApprovedOrMute,'') = '' THEN  ml.IsApprovedOrMute ELSE cl.IsApprovedOrMute END 
FROM AVL.ML_TRN_MLPatternValidation_CL cl
inner join AVL.ML_TRN_MLPatternValidation ml ON cl.ProjectID = ml.ProjectID
and cl.ApplicationID = ml.ApplicationID and ltrim(rtrim(cl.TicketPattern)) = ltrim(rtrim(ml.TicketPattern))
AND CL.MLCauseCodeID = ML.MLCauseCodeID AND CL.MLResolutionCodeID = ML.MLResolutionCode
and cl.isdeleted = 0  and ml.TicketPattern !='0' and cl.TicketPattern != '0'
AND CL.ProjectID = @ProjectID

--select * from #Debt_MLPatternValidation order by id

CREATE TABLE #tmpnewUniqueID
(
pattern VARCHAR(max),
ID int,
MLCauseCodeID int,
MLResolutionCode int,
ApplicationID int,
Occurence int
)

Insert into #tmpnewUniqueID
select  ticketpattern,min(id),mlcausecodeid,mlresolutioncodeid,applicationid,max(ticketoccurence)  from 
#Debt_MLPatternValidation where patterntype = 'New' and ticketpattern<> '0'
group by ticketpattern,mlcausecodeid,mlresolutioncodeid,applicationid



update dl set dl.isdeleted = 1 from #Debt_MLPatternValidation dl 
where  patterntype = 'New'  and ID not in (select ID from #tmpnewUniqueID)

update cl set cl.isdeleted = 1 from AVL.ML_TRN_MLPatternValidation_CL cl 
inner join #Debt_MLPatternValidation dl  on dl.ID = cl.ID
where dl.isdeleted = 1


SELECT distinct
	        MV.ID,
			ISNULL(MV.InitialLearningID,0) AS InitialLearningID,
			ISNULL(MV.ApplicationID,0) as ApplicationID,
			ISNULL(AM.ApplicationName,'') AS ApplicationName,
			ISNULL(MV.ApplicationTypeID,0) AS  ApplicationTypeID,
			ISNULL(AT.ApplicationTypename,'') AS  ApplicationTypeName,
			ISNULL(MV.TechnologyID,0) AS TechnologyID,
			ISNULL(MT.[PrimaryTechnologyName],'') AS TechnologyName,
		 	MV.TicketPattern,
			MID.PatternType, 
			ISNULL(MV.MLDebtClassificationID,0) AS MLDebtClassificationID,
			CASE 
			WHEN MID.PatternType = 'Old' THEN ISNULL(AFM.[DebtClassificationName],'') 
			WHEN ISNULL(MV.MLDebtClassificationID,0) > 0 THEN ISNULL(AFM.[DebtClassificationName],'') 
			ELSE 'N/A' END AS MLDebtClassificationName,

			ISNULL(MV.MLResidualFlagID,0) AS MLResidualFlagID,

			CASE 
			WHEN MID.PatternType = 'Old' THEN ISNULL(AFMM.[ResidualDebtName],'') 
			WHEN ISNULL(MV.MLResidualFlagID,0) > 0 THEN ISNULL(AFMM.[ResidualDebtName],'') 
			ELSE 'N/A' END AS MLResidualFlagName,

			ISNULL(MV.MLAvoidableFlagID,0) AS MLAvoidableFlagID,

			CASE WHEN MID.PatternType = 'Old' THEN ISNULL(AFMF.[AvoidableFlagName],'') 
			WHEN ISNULL(MV.MLAvoidableFlagID,0) > 0 THEN ISNULL(AFMF.[AvoidableFlagName],'') 
			ELSE 'N/A' END AS MLAvoidableFlagName,
			
			ISNULL(MV.MLCauseCodeID,0) AS MLCauseCodeID,

			CASE WHEN MID.PatternType = 'Old' THEN ISNULL(DCC.[CauseCode],'') 
			WHEN ISNULL(MV.MLCauseCodeID,0) > 0 THEN ISNULL(DCC.[CauseCode],'') 
			ELSE 'N/A' END AS MLCauseCodeName,

			MV.MLAccuracy as MLAccuracy,
			MV.TicketOccurence,
			ISNULL(MV.AnalystResolutionCodeID,0) AS AnalystResolutionCodeID,

			ISNULL(DRC.[ResolutionCode],'') AS AnalystResolutionCodeName,

			ISNULL(MV.AnalystCauseCodeID,0) AS AnalystCauseCodeID,
			ISNULL(DCC2.[CauseCode],'') AS AnalystCauseCodeName,


			ISNULL(MV.AnalystDebtClassificationID,0) AS AnalystDebtClassificationID,
			ISNULL(AFM1.[DebtClassificationName],'') AS AnalystDebtClassificationName,
			ISNULL(MV.AnalystAvoidableFlagID,0) AS AnalystAvoidableFlagID,
			ISNULL(AFMF2.[AvoidableFlagName],'') AS AnalystAvoidableFlagName,
			ISNULL(MV.SMEComments,'') AS SMEComments,
			ISNULL(MV.SMEResidualFlagID,0) AS SMEResidualFlagID,

			CASE 
			WHEN MID.PatternType = 'Old' THEN ISNULL(AFMF5.[ResidualDebtName],'') 
			WHEN ISNULL(MV.SMEResidualFlagID,0) > 0 THEN ISNULL(AFMF5.[ResidualDebtName],'') 
			 ELSE 'N/A' END AS SMEResidualFlagName,

			ISNULL(MV.SMEDebtClassificationID,0) AS SMEDebtClassificationID,

		    CASE 
			WHEN MID.PatternType = 'Old' THEN ISNULL(AFM3.[DebtClassificationName],'')
			WHEN ISNULL(MV.SMEDebtClassificationID,0) > 0 THEN ISNULL(AFM3.[DebtClassificationName],'') 
			ELSE 'N/A' END AS SMEDebtClassificationName,

			ISNULL(MV.SMEAvoidableFlagID,0) AS SMEAvoidableFlagID,

			CASE 
			WHEN MID.PatternType = 'Old' THEN  AFMF4.[AvoidableFlagName] 
			WHEN ISNULL(MV.SMEAvoidableFlagID,0) > 0 THEN ISNULL(AFMF4.[AvoidableFlagName],'') 
			ELSE 'N/A' END AS SMEAvoidableFlagName ,

			ISNULL(MV.SMECauseCodeID,0) AS SMECauseCodeID,
			
		    CASE 
			WHEN MID.PatternType = 'Old' THEN DCC1.[CauseCode] 
			WHEN ISNULL(MV.SMECauseCodeID,0) > 0 THEN ISNULL(DCC1.[CauseCode],'') 
		    ELSE 'N/A' END AS SMECauseCodeName,

			ISNULL(MV.IsApprovedOrMute,0) AS IsApprovedOrMute,
			ISNULL(MV.IsApprovedOrMute,0) AS IsApproved,
			ISNULL(MV.IsCLSignOff,0) AS IsCLSignOff,
			ISNULL(MV.MLResolutionCodeID,0) AS MLResolutionCodeID,
			ISNULL(MV.ReasonforResidual,'') AS ReasonforResidualID,
			ISNULL(RR.ReasonName,'') AS ReasonforResidual,
			ISNULL(DRC1.ResolutionCode,'') AS MLResolutionCode,
			ISNULL(MV.ExpectedCompletionDate,'') AS ExpectedCompletionDate,
			ISNULL(t.discrepancy,'N') AS Discrepancy
			FROM AVL.ML_TRN_MLPatternValidation_CL(NOLOCK) MV
			INNER JOIN #Debt_MLPatternValidation MID ON MID.ApplicationID =MV.ApplicationID  AND MID.TicketPattern = MV.TicketPattern
			AND MID.ID = MV.ID
			AND MID.ProjectID = MV.ProjectID 
			AND MID.ISDELETED = 0
			left JOIN #tmpDiscrepancy t on ltrim(rtrim(t.ticketpattern)) = ltrim(rtrim(MV.TicketPattern))  
			and t.causecode = mv.MLCauseCodeID and t.resolutioncode = mv.MLResolutionCodeID and t.ApplicationID = mv.ApplicationID
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
			LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] DRC1 ON MV.MLResolutionCodeID=DRC1.[ResolutionID] AND DRC1.ProjectID=@ProjectID AND DRC1.IsDeleted=0
			LEFT JOIN AVL.CL_MAS_ResidualReason RR ON RR.ReasonID = MV.ReasonforResidual 
			where MV.projectid = @ProjectID AND MV.IsDeleted=0 
			--AND MV.ID IN(SELECT TickID FROM #MaxIDs) 
			and MV.TicketPattern <> '0'
			--AND MV.TicketOccurence >0
			and BCM.CustomerID=@CustomerID 
			and AM.IsActive=1
			
				END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_GetMLPatternValidation_CL] ', @ErrorMessage, @ProjectID,@AppID
		
	END CATCH  	
	end




	SET ANSI_NULLS ON
