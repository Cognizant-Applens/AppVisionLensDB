/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


-- ============================================================================
-- Author:		 Dhivya        
-- Create Date:  Jan 30 2019
-- Description:  Uploads the excel data to Main datadictionary table
-- DB Name :     AppVisionlens
-- ============================================================================ 
CREATE PROCEDURE [AVL].[DataDictionaryExcelUpload]
	@ProjectID BIGINT =null,
	@EmployeeID NVARCHAR(50),
	@DataDictionaryDetailsUpload [AVL].[TVP_DataDictionaryDetailsUpload]  READONLY,
	@DDUploadID BIGINT=NULL
AS
BEGIN
BEGIN TRY
	BEGIN TRAN
		DECLARE @ApplicationCauseCodeResolutionCodeMessage AS NVARCHAR(1000);
		DECLARE @DuplicatePatternMessage  AS NVARCHAR(1000);
		DECLARE @ResidualDebtMessage AS NVARCHAR(1000);
		DECLARE @AvoidableFlagMessage AS NVARCHAR(1000);
		DECLARE @DebtClassificationMessage AS NVARCHAR(1000);
		DECLARE @ReasonForResidualMessage AS NVARCHAR(1000);
		DECLARE @MandatoryMessage AS NVARCHAR(1000);
		DECLARE @InvalidDateMessage AS NVARCHAR(1000);
		DECLARE @EffectiveDate DATETIME
		DELETE FROM [AVL].[Debt_TRN_DataDictionaryErrorTemp] WHERE ProjectID=@ProjectID
		--DELETE FROM [AVL].[Debt_TRN_DataDictionaryTemp] WHERE ProjectID=@ProjectID
		DECLARE @AllString NVARCHAR(10)='ALL'
		SET @ApplicationCauseCodeResolutionCodeMessage='Application Name (or) Cause Code (or) Resolution Code not configured for the project.';
		SET @DuplicatePatternMessage='Duplicate Pattern.'
		SET @ResidualDebtMessage='Residual Debt should have "Yes" or "No".';
		SET @AvoidableFlagMessage='Avoidable Flag should have "Yes" or "No".'
		SET @DebtClassificationMessage='Debt Classification should only have "Operational", "Technical","Knowledge" or "Functional".';
		SET @ReasonForResidualMessage='Reason for Residual should have valid dropdown values.';
		SET @MandatoryMessage='Please fill all the mandatory columns.';
		SET @InvalidDateMessage='Invalid date captured.';

		DECLARE @ErrorTableDD AS TABLE
		(
		ID BIGINT IDENTITY(1,1),
		DDUploadID BIGINT NULL,
		ApplicationName NVARCHAR(MAX) NULL,
		CauseCodeName NVARCHAR(MAX) NULL,
		ResolutionCodeName NVARCHAR(MAX) NULL,
		DebtCategoryName NVARCHAR(MAX) NULL,
		AvoidableFlagName NVARCHAR(MAX) NULL,
		ResidualFlagName NVARCHAR(MAX) NULL,
		ReasonForResidualName NVARCHAR(MAX) NULL,
		ExpectedCompletionDate  NVARCHAR(MAX) NULL,
		ProjectID BIGINT NULL,
		IsAll INT NULL,
		IsInValid INT NULL,
		Remarks NVARCHAR(MAX) NULL
		)
		CREATE TABLE #Debt_TRN_DataDictionaryTemp(
			[ID] [bigint] IDENTITY(1,1) NOT NULL,
			[ProjectID] [bigint] NOT NULL,
			[DDUploadID] [bigint] NULL,
			[ApplicationID] [bigint] NULL,
			[ApplicationName] [nvarchar](100) NULL,
			[CauseCodeID] [bigint] NULL,
			[CauseCode] [nvarchar](50) NULL,
			[ResolutionCodeID] [bigint] NULL,
			[ResolutionCode] [nvarchar](50) NULL,
			[DebtCategoryID] [bigint] NULL,
			[DebtCategory] [nvarchar](50) NULL,
			[AvoidableFlagID] [bigint] NULL,
			[AvoidableFlag] [nvarchar](50) NULL,
			[ResidualFlagID] [bigint] NULL,
			[ResidualFlag] [nvarchar](50) NULL,
			[ReasonForResidualID] [bigint] NULL,
			[ReasonForResidual] [nvarchar](50) NULL,
			[ExpectedCompletionDate] [nvarchar](100) NULL,
			[IsAll] [int] NULL,
			[IsUpdate] [int] NULL,
			[IsDeleted] [int] NULL,
			[CreatedBy] [nvarchar](50) NULL,
			[CreatedOn] [datetime] NULL,
			[ModifiedBy] [nvarchar](50) NULL,
			[ModifiedOn] [datetime] NULL
		) 
		 --Invalid value is set to numbers to capture all errors in a row
		 --4 for invalid date, 2 for duplicate, 3 for invalid application, cause code and resolution code & finally all set to 1

		INSERT INTO @ErrorTableDD(DDUploadID,ApplicationName,CauseCodeName,ResolutionCodeName,DebtCategoryName,
		AvoidableFlagName,ResidualFlagName,
		ReasonForResidualName,ExpectedCompletionDate,ProjectID,IsInValid,Remarks)
		SELECT
		@DDUploadID,ApplicationName,CauseCode,ResolutionCode,DebtCategory,
		AvoidableFlag,ResidualFlag,
		ReasonForResidual,CONVERT(NVARCHAR(MAX),ExpectedCompletionDate),@ProjectID,NULL,''
		FROM @DataDictionaryDetailsUpload

		UPDATE @ErrorTableDD SET IsInValid=4,Remarks=Remarks+CHAR(13) + @InvalidDateMessage
		WHERE ISDATE(ExpectedCompletionDate) !=1 AND ExpectedCompletionDate IS NOT NULL
		AND ExpectedCompletionDate !=''

		SELECT DISTINCT AD.ApplicationID,AD.ApplicationName
		INTO #ApplicationDetails
		FROM AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM
		INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
		ON APM.ApplicationID=AD.ApplicationID
		WHERE APM.ProjectID=@projectid AND ISNULL(APM.IsDeleted,0)=0 AND AD.IsActive=1

		SELECT DISTINCT CauseID,CauseCode AS CauseCodeName 
		INTO #CauseCodeDetails  FROM [AVL].[DEBT_MAP_CauseCode] 
		WHERE ProjectID = @ProjectID AND ISNULL(IsDeleted,0) =0

		SELECT DISTINCT ResolutionID,ResolutionCode AS ResolutionCodeName 
		INTO #ResolutionCodeDetails
		FROM [AVL].[DEBT_MAP_ResolutionCode] 
		WHERE ProjectID = @ProjectID AND ISNULL(IsDeleted,0) =0

		SELECT DISTINCT DebtClassificationID,DebtClassificationName AS DebtCategoryName  INTO #DebtClassification  
		FROM [AVL].[DEBT_MAS_DebtClassification]
		WHERE ISNULL(IsDeleted,0)=0

		SELECT DISTINCT AvoidableFlagID,AvoidableFlagName AS AvoidableFlagName INTO #AvoidableFlagDetails   
		FROM [AVL].[DEBT_MAS_AvoidableFlag]
		WHERE ISNULL(IsDeleted,0)=0
		SELECT ResidualDebtID,ResidualDebtName AS ResidualDebtName INTO #ResidualDebtDetails FROM AVL.DEBT_MAS_ResidualDebt 
		WHERE ISNULL(IsDeleted,0) =0

		SELECT ReasonResidualID,ReasonResidualName AS ReasonResidualName INTO #ReasonForResiduaDetails 
		FROM [AVL].[TK_MAS_ReasonForResidual] 
		WHERE ISNULL(IsDeleted,0)=0

		SELECT A.* INTO #InValidApplications FROM
		(SELECT DISTINCT ApplicationName FROM @DataDictionaryDetailsUpload WHERE ApplicationName != @AllString
		EXCEPT
		SELECT DISTINCT ApplicationName FROM #ApplicationDetails)AS A

		UPDATE ET SET ET.IsInValid=3
		FROM  #InValidApplications IVA
		INNER JOIN @ErrorTableDD ET 
		ON IVA.ApplicationName=ET.ApplicationName


		SELECT C.* INTO #InValidCauseCode FROM
		(SELECT DISTINCT CONVERT(NVARCHAR(50),CauseCode) AS CauseCodeName FROM @DataDictionaryDetailsUpload
		EXCEPT
		SELECT DISTINCT  CONVERT(NVARCHAR(50),CauseCodeName) AS CauseCodeName  FROM #CauseCodeDetails)AS C
				

		UPDATE ET SET ET.IsInValid=3
		FROM  #InValidCauseCode IVA
		INNER JOIN @ErrorTableDD ET 
		ON IVA.CauseCodeName=ET.CauseCodeName

		SELECT C.* INTO #InValidResolutionCode FROM
		(SELECT DISTINCT ResolutionCode AS ResolutionCodeName FROM @DataDictionaryDetailsUpload
		EXCEPT
		SELECT DISTINCT ResolutionCodeName   FROM #ResolutionCodeDetails )AS C

		UPDATE ET SET ET.IsInValid=3
		FROM  #InValidResolutionCode IVA
		INNER JOIN @ErrorTableDD ET 
		ON IVA.ResolutionCodeName=ET.ResolutionCodeName

		UPDATE  @ErrorTableDD  SET   IsInValid=1,Remarks=Remarks +CHAR(13) + @ApplicationCauseCodeResolutionCodeMessage 
		WHERE IsInValid=3

		SELECT C.* INTO #InValidDebtClassification FROM
		(SELECT DISTINCT DebtCategory AS DebtCategoryName FROM @DataDictionaryDetailsUpload
		EXCEPT
		SELECT DISTINCT DebtCategoryName   FROM #DebtClassification)AS C

		UPDATE ET SET ET.IsInValid=1,Remarks=Remarks + CHAR(13) + @DebtClassificationMessage
		FROM  #InValidDebtClassification IVA
		INNER JOIN @ErrorTableDD ET 
		ON IVA.DebtCategoryName=ET.DebtCategoryName

		SELECT C.* INTO #InValidAvoidableFlag FROM
		(SELECT DISTINCT AvoidableFlag AS AvoidableFlagName FROM @DataDictionaryDetailsUpload
		EXCEPT
		SELECT DISTINCT AvoidableFlagName   FROM #AvoidableFlagDetails )AS C

		UPDATE ET SET ET.IsInValid=1,Remarks=Remarks +CHAR(13) + @AvoidableFlagMessage
		FROM  #InValidAvoidableFlag IVA
		INNER JOIN @ErrorTableDD ET 
		ON IVA.AvoidableFlagName=ET.AvoidableFlagName
	
		SELECT C.* INTO #InValidResidualDebt FROM
		(SELECT DISTINCT ResidualFlag AS ResidualDebtName FROM @DataDictionaryDetailsUpload
		EXCEPT
		SELECT ResidualDebtName FROM #ResidualDebtDetails )AS C

		UPDATE ET SET ET.IsInValid=1,Remarks=Remarks +CHAR(13) + @ResidualDebtMessage
		FROM  #InValidResidualDebt IVA
		INNER JOIN @ErrorTableDD ET 
		ON IVA.ResidualDebtName=ET.ResidualFlagName

		SELECT C.* INTO #InValidReasonForResidual FROM
		(SELECT DISTINCT ReasonForResidual AS ReasonResidualName FROM @DataDictionaryDetailsUpload
		EXCEPT
		SELECT ReasonResidualName FROM #ReasonForResiduaDetails )AS C

		UPDATE ET SET ET.IsInValid=1,Remarks=Remarks  +CHAR(13) +@ReasonForResidualMessage 
		FROM  #InValidReasonForResidual IVA
		INNER JOIN @ErrorTableDD ET 
		ON IVA.ReasonResidualName=ET.ReasonForResidualName

		UPDATE @ErrorTableDD SET IsInValid=1,Remarks=Remarks +CHAR(13) +@MandatoryMessage 
		WHERE ApplicationName IS NULL OR CauseCodeName IS NULL OR ResolutionCodeName IS NULL
		OR DebtCategoryName IS NULL OR AvoidableFlagName IS NULL OR 
		ApplicationName ='' OR CauseCodeName ='' OR ResolutionCodeName =''
		OR DebtCategoryName ='' OR AvoidableFlagName ='' OR ResidualFlagName='' OR ResidualFlagName IS NULL

		UPDATE @ErrorTableDD SET IsAll=1 WHERE ApplicationName =@AllString
	
		SELECT A.* INTO #DuplicatePatternByAll FROM
		(SELECT ApplicationName,CauseCodeName,ResolutionCodeName,COUNT(ID) AS [Count] FROM @ErrorTableDD
		WHERE  ApplicationName =@AllString
		GROUP BY ApplicationName,CauseCodeName,ResolutionCodeName
		HAVING COUNT(*) >1)AS A
	
		UPDATE ET SET ET.IsInvalid=2 FROM #DuplicatePatternByAll DP
		INNER JOIN @ErrorTableDD ET
		ON DP.ApplicationName=ET.ApplicationName AND DP.CauseCodeName=ET.CauseCodeName
		AND DP.ResolutionCodeName=ET.ResolutionCodeName

		INSERT INTO #Debt_TRN_DataDictionaryTemp
		(DDUploadID,ApplicationName,CauseCode,ResolutionCode,DebtCategory,
		AvoidableFlag,ResidualFlag,ReasonForResidual,ExpectedCompletionDate,
		ProjectID,CreatedBy,CreatedOn,IsAll)
		SELECT ETD.DDUploadID,CONVERT(NVARCHAR(100),AD.ApplicationName),CONVERT(NVARCHAR(50),CD.CauseCodeName),
		CONVERT(NVARCHAR(50),RC.ResolutionCodeName),
		DC.DebtCategoryName,AF.AvoidableFlagName,
		RD.ResidualDebtName,RRD.ReasonResidualName,ETD.ExpectedCompletionDate,
		@ProjectID,@EmployeeID,GETDATE(),ETD.IsAll FROM @ErrorTableDD ETD
		INNER JOIN #ApplicationDetails AD ON ETD.ApplicationName <> AD.ApplicationName
		INNER JOIN #CauseCodeDetails CD ON CONVERT(NVARCHAR(50),ETD.CauseCodeName)=CONVERT(NVARCHAR(50),CD.CauseCodeName)
		INNER JOIN #ResolutionCodeDetails RC ON CONVERT(NVARCHAR(50),ETD.ResolutionCodeName)=CONVERT(NVARCHAR(50),RC.ResolutionCodeName)
		INNER JOIN 	#DebtClassification DC ON ETD.DebtCategoryName=DC.DebtCategoryName
		INNER JOIN 	#AvoidableFlagDetails AF ON ETD.AvoidableFlagName=AF.AvoidableFlagName
		INNER JOIN 	#ResidualDebtDetails RD ON ETD.ResidualFlagName=RD.ResidualDebtName
		LEFT JOIN 	#ReasonForResiduaDetails RRD ON ETD.ReasonForResidualName=RRD.ReasonResidualName
		WHERE ISNULL(ETD.IsAll,0) = 1 AND ISNULL(IsInValid,0) NOT IN( 1,4) AND ETD.DDUploadID=@DDUploadID



		INSERT INTO #Debt_TRN_DataDictionaryTemp
		(DDUploadID,ApplicationName,CauseCode,ResolutionCode,DebtCategory,
		AvoidableFlag,ResidualFlag,ReasonForResidual,ExpectedCompletionDate,
		ProjectID,CreatedBy,CreatedOn,IsAll)
		SELECT
		DDUploadID,CONVERT(NVARCHAR(100),ApplicationName),CONVERT(NVARCHAR(50),CauseCodeName),
		CONVERT(NVARCHAR(50),ResolutionCodeName),
		DebtCategoryName,
		AvoidableFlagName,ResidualFlagName,ReasonForResidualName,ExpectedCompletionDate,
		@ProjectID,@EmployeeID,GETDATE(),IsAll
		FROM @ErrorTableDD WHERE  ISNULL(IsAll,0) != 1  AND ISNULL(IsInValid,0) NOT IN( 1,4) AND DDUploadID=@DDUploadID

		UPDATE DDT SET DDT.ApplicationID = AD.ApplicationID 
		FROM #Debt_TRN_DataDictionaryTemp DDT INNER JOIN #ApplicationDetails AD ON CONVERT(NVARCHAR(100),DDT.ApplicationName)=CONVERT(NVARCHAR(100),AD.ApplicationName)
		WHERE DDT.ProjectID=@ProjectID AND DDT.DDUploadID=@DDUploadID

		UPDATE DDT SET DDT.CauseCodeID = AD.CauseID
		FROM #Debt_TRN_DataDictionaryTemp DDT INNER JOIN #CauseCodeDetails AD ON CONVERT(NVARCHAR(50),DDT.CauseCode)=CONVERT(NVARCHAR(50),AD.CauseCodeName)
		WHERE DDT.ProjectID=@ProjectID  AND DDT.DDUploadID=@DDUploadID


		UPDATE DDT SET DDT.ResolutionCodeID = AD.ResolutionID 
		FROM #Debt_TRN_DataDictionaryTemp DDT INNER JOIN #ResolutionCodeDetails AD ON CONVERT(NVARCHAR(50),DDT.ResolutionCode)=CONVERT(NVARCHAR(50),AD.ResolutionCodeName)
		WHERE DDT.ProjectID=@ProjectID AND DDT.DDUploadID=@DDUploadID

		UPDATE DDT SET DDT.DebtCategoryID = AD.DebtClassificationID 
		FROM #Debt_TRN_DataDictionaryTemp DDT INNER JOIN #DebtClassification AD ON DDT.DebtCategory=AD.DebtCategoryName
		WHERE DDT.ProjectID=@ProjectID AND DDT.DDUploadID=@DDUploadID

		UPDATE DDT SET DDT.AvoidableFlagID = AD.AvoidableFlagID 
		FROM #Debt_TRN_DataDictionaryTemp DDT INNER JOIN #AvoidableFlagDetails AD ON DDT.AvoidableFlag=AD.AvoidableFlagName
		WHERE DDT.ProjectID=@ProjectID AND DDT.DDUploadID=@DDUploadID

		UPDATE DDT SET DDT.ResidualFlagID = AD.ResidualDebtID 
		FROM #Debt_TRN_DataDictionaryTemp DDT INNER JOIN #ResidualDebtDetails AD ON DDT.ResidualFlag=AD.ResidualDebtName
		WHERE DDT.ProjectID=@ProjectID AND DDT.DDUploadID=@DDUploadID

		UPDATE DDT SET DDT.ReasonForResidualID = AD.ReasonResidualID 
		FROM #Debt_TRN_DataDictionaryTemp DDT INNER JOIN #ReasonForResiduaDetails AD ON DDT.ReasonForResidual=AD.ReasonResidualName
		WHERE DDT.ProjectID=@ProjectID AND DDT.DDUploadID=@DDUploadID

		SELECT A.* INTO #CommonDebtPatterns  FROM
		(SELECT ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID
		FROM #Debt_TRN_DataDictionaryTemp WHERE ProjectID=@ProjectID AND IsAll=1 AND DDUploadID=@DDUploadID
		INTERSECT
		SELECT ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID
		FROM  #Debt_TRN_DataDictionaryTemp WHERE ProjectID=@ProjectID AND ISNULL(IsAll,0)=0 AND DDUploadID=@DDUploadID) 
		AS A

		--If Common patterns are available make all as deleted and considering only specific records
		UPDATE  DDT SET DDT.IsDeleted=1 FROM #CommonDebtPatterns CDP
		INNER JOIN #Debt_TRN_DataDictionaryTemp DDT  ON CDP.ApplicationID=DDT.ApplicationID AND CDP.ProjectID=DDT.ProjectID 
		AND CDP.CauseCodeID=DDT.CauseCodeID
		AND CDP.ResolutionCodeID=DDT.ResolutionCodeID
		WHERE DDT.ProjectID=@ProjectID and ISNULL(DDT.IsAll,0)=1 AND  DDT.DDUploadID=@DDUploadID

		--Duplicate Pattern when count is same
		SELECT D.* INTO #DuplicateRecords FROM
		(SELECT ProjectID,CauseCodeID,ResolutionCodeID,COUNT(DDT.ID) AS PatternCount
		FROM  #Debt_TRN_DataDictionaryTemp  DDT WHERE ProjectID=@ProjectID and ISNULL(DDT.IsAll,0)=0 
		AND DDT.DDUploadID=@DDUploadID
		GROUP BY  ProjectID,CauseCodeID,ResolutionCodeID
		INTERSECT
		SELECT ProjectID,CauseCodeID,ResolutionCodeID,COUNT(DDT.ID) AS PatternCount
		FROM  #Debt_TRN_DataDictionaryTemp DDT WHERE ProjectID=@ProjectID and ISNULL(DDT.IsAll,0)=1 
		AND DDT.DDUploadID=@DDUploadID
		GROUP BY ProjectID,CauseCodeID,ResolutionCodeID)AS D

		UPDATE DDT SET DDT.IsDeleted=1 FROM #DuplicateRecords CDP
		INNER JOIN #Debt_TRN_DataDictionaryTemp DDT  ON  CDP.ProjectID=DDT.ProjectID 
		AND CDP.CauseCodeID=DDT.CauseCodeID
		AND CDP.ResolutionCodeID=DDT.ResolutionCodeID
		WHERE DDT.ProjectID=@ProjectID  AND DDT.DDUploadID=@DDUploadID

		UPDATE DDE SET IsInValid=2
		 FROM #DuplicateRecords CDP
		INNER JOIN #CauseCodeDetails CCD ON CCD.CauseID=CDP.CauseCodeID
		INNER JOIN #ResolutionCodeDetails RCD ON RCD.ResolutionID=CDP.ResolutionCodeID
		INNER JOIN @ErrorTableDD DDE ON CDP.ProjectID=DDE.ProjectID
		AND CCD.CauseCodeName=DDE.CauseCodeName AND RCD.ResolutionCodeName=DDE.ResolutionCodeName
		WHERE CDP.ProjectID=@ProjectID AND DDE.DDUploadID=@DDUploadID

		SELECT R.* INTO #DuplicateRecordsByApplication FROM
		(SELECT ApplicationID,ProjectID,CauseCodeID,ResolutionCodeID,COUNT(DDT.ID) AS PatternCount
		FROM  #Debt_TRN_DataDictionaryTemp DDT WHERE ProjectID=@ProjectID and ISNULL(DDT.IsDeleted,0)=0
		AND DDT.DDUploadID=@DDUploadID
		GROUP BY ApplicationID,ProjectID,CauseCodeID,ResolutionCodeID HAVING COUNT(DDT.ID) >1)AS R

		UPDATE DDT SET DDT.IsDeleted=1 FROM #DuplicateRecordsByApplication CDP
		INNER JOIN #Debt_TRN_DataDictionaryTemp DDT  ON  CDP.ProjectID=DDT.ProjectID AND CDP.ApplicationID=DDT.ApplicationID
		AND  CDP.CauseCodeID=DDT.CauseCodeID
		AND CDP.ResolutionCodeID=DDT.ResolutionCodeID
		WHERE CDP.ProjectID=@ProjectID  AND DDT.DDUploadID=@DDUploadID

		UPDATE DDE SET IsInValid=2
		 FROM #DuplicateRecordsByApplication CDP
		 INNER JOIN #ApplicationDetails AD ON AD.ApplicationID=CDP.ApplicationID
		INNER JOIN #CauseCodeDetails CCD ON CCD.CauseID=CDP.CauseCodeID
		INNER JOIN #ResolutionCodeDetails RCD ON RCD.ResolutionID=CDP.ResolutionCodeID
		INNER JOIN @ErrorTableDD DDE ON CDP.ProjectID=DDE.ProjectID
		AND CCD.CauseCodeName=DDE.CauseCodeName AND RCD.ResolutionCodeName=DDE.ResolutionCodeName
		AND AD.ApplicationName=DDE.ApplicationName
		WHERE CDP.ProjectID=@ProjectID AND DDE.DDUploadID=@DDUploadID

		UPDATE @ErrorTableDD SET IsInValid=1,Remarks=Remarks+CHAR(13) +@DuplicatePatternMessage WHERE IsInValid=2
	
		UPDATE @ErrorTableDD SET IsInValid=1 WHERE IsInValid=4

		UPDATE DDT SET DDT.Isdeleted=1 FROM   #Debt_TRN_DataDictionaryTemp DDT
		INNER JOIN @ErrorTableDD CDP   ON CDP.ProjectID=DDT.ProjectID
		AND CDP.CauseCodeName=DDT.CauseCode AND CDP.ResolutionCodeName=DDT.ResolutionCode
		AND CDP.ApplicationName=DDT.ApplicationName WHERE DDT.ProjectID=@ProjectID AND CDP.IsInValid=4
		AND DDT.DDUploadID=@DDUploadID

		INSERT INTO [AVL].[Debt_TRN_DataDictionaryErrorTemp]
		(ProjectID,ApplicationName,CauseCode,ResolutionCode,DebtCategory,
		AvoidableFlag,ResidualFlag,ReasonForResidual,ExpectedCompletionDate,Remarks,CreatedBy,CreatedOn)
		SELECT ProjectID,ApplicationName,CauseCodeName,ResolutionCodeName,DebtCategoryName,
		AvoidableFlagName,ResidualFlagName,ReasonForResidualName,CONVERT(NVARCHAR(MAX),ExpectedCompletionDate),Remarks,
		@EmployeeID,GETDATE()
		FROM @ErrorTableDD 
		WHERE IsInValid=1 AND DDUploadID=@DDUploadID

		--To Insert Records
		SELECT A.* INTO #InsertRecords FROM
		(SELECT ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID
		FROM #Debt_TRN_DataDictionaryTemp WHERE ProjectID=@ProjectID AND ISNULL(IsDeleted,0)=0
		AND DDUploadID=@DDUploadID
		EXCEPT
		SELECT ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID
		FROM [AVL].[Debt_MAS_ProjectDataDictionary](NOLOCK) WHERE ProjectID=@ProjectID AND ISNULL(IsDeleted,0)=0)AS A

		--To Update Records
		SELECT A.* INTO #UpdateRecords FROM
		(SELECT ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID
		FROM #Debt_TRN_DataDictionaryTemp WHERE ProjectID=@ProjectID AND ISNULL(IsDeleted,0)=0 
		AND DDUploadID=@DDUploadID
		INTERSECT
		SELECT ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID
		FROM [AVL].[Debt_MAS_ProjectDataDictionary](NOLOCK) WHERE ProjectID=@ProjectID AND ISNULL(IsDeleted,0)=0 )AS A


		UPDATE DDT SET DDT.IsUpdate=2 FROM #InsertRecords IR
		INNER JOIN #Debt_TRN_DataDictionaryTemp DDT ON IR.ProjectID =DDT.ProjectID AND IR.ApplicationID=DDT.ApplicationID
		AND IR.CauseCodeID=DDT.CauseCodeID AND IR.ResolutionCodeID=DDT.ResolutionCodeID
		WHERE  DDT.ProjectID=@ProjectID AND ISNULL(DDT.IsDeleted,0)=0 AND  DDT.ApplicationID IS NOT NULL 
		AND DDT.CauseCodeID IS NOT NULL AND DDT.ResolutionCodeID IS NOT NULL 
		AND DDT.DebtCategoryID IS NOT NULL AND DDT.ResidualFlagID IS NOT NULL AND ISNULL(DDT.IsDeleted,0)=0
		AND DDT.DDUploadID=@DDUploadID

		UPDATE DDT SET DDT.IsUpdate=1 FROM #UpdateRecords UR
		INNER JOIN #Debt_TRN_DataDictionaryTemp DDT ON UR.ProjectID =DDT.ProjectID AND UR.ApplicationID=DDT.ApplicationID
		AND UR.CauseCodeID=DDT.CauseCodeID AND UR.ResolutionCodeID=DDT.ResolutionCodeID
		WHERE  DDT.ProjectID=@ProjectID AND ISNULL(DDT.IsDeleted,0)=0 AND  DDT.ApplicationID IS NOT NULL 
		AND DDT.CauseCodeID IS NOT NULL 
		AND DDT.ResolutionCodeID IS NOT NULL 
		AND DDT.DebtCategoryID IS NOT NULL AND DDT.ResidualFlagID IS NOT NULL  AND ISNULL(DDT.IsDeleted,0)=0
		AND DDT.DDUploadID=@DDUploadID


		IF EXISTS (SELECT 1 FROM AVL.MAS_ProjectDebtDetails(NOLOCK) WHERE ProjectID=@ProjectID 
				   AND IsDDAutoClassifiedDate IS NOT NULL AND IsDeleted=0)
			BEGIN		
				SET @EffectiveDate=GETDATE()
			END
		ELSE
			BEGIN
				SET @EffectiveDate=NULL
			END

		INSERT INTO [AVL].[Debt_MAS_ProjectDataDictionary]
		(ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID,DebtClassificationID,AvoidableFlagID,ResidualDebtID,ReasonForResidual,ExpectedCompletionDate,
		IsDeleted,EffectiveDate,CreatedBy,CreatedDate,IsAll)
		SELECT DDT.ProjectID,DDT.ApplicationID,DDT.CauseCodeID,DDT.ResolutionCodeID,DDT.DebtCategoryID,DDT.AvoidableFlagID,
		DDT.ResidualFlagID,DDT.ReasonForResidualID,DDT.ExpectedCompletionDate,
		0,@EffectiveDate,@EmployeeID,GETDATE(),ISNULL(DDT.IsAll,0) FROM #Debt_TRN_DataDictionaryTemp DDT 
		WHERE ISNULL(DDT.IsDeleted,0)=0
		AND DDT.IsUpdate=2 AND DDT.ProjectID=@ProjectID AND DDT.DDUploadID=@DDUploadID

		UPDATE DDE SET DDE.DebtClassificationID=DDT.DebtCategoryID,DDE.AvoidableFlagID=DDT.AvoidableFlagID,
		DDE.ResidualDebtID=DDT.ResidualFlagID,
		DDE.ReasonForResidual =DDT.ReasonForResidualID,DDE.ExpectedCompletionDate=DDT.ExpectedCompletionDate,
		DDE.IsAll=ISNULL(DDT.IsAll,0),
		DDE.EffectiveDate=ISNULL(DDE.EffectiveDate,@EffectiveDate),
		DDE.ModifiedBy=@EmployeeID, DDE.ModifiedDate=GETDATE()
		FROM [AVL].[Debt_MAS_ProjectDataDictionary] DDE
		INNER JOIN #Debt_TRN_DataDictionaryTemp DDT
		ON DDE.ProjectID =DDT.ProjectID AND DDE.ApplicationID=DDT.ApplicationID
		AND DDE.CauseCodeID=DDT.CauseCodeID AND DDE.ResolutionCodeID=DDT.ResolutionCodeID
		WHERE DDE.ProjectID =@ProjectID AND DDE.IsDeleted=0 AND DDT.IsUpdate=1 AND ISNULL(DDT.IsDeleted,0)=0
		AND DDT.DDUploadID=@DDUploadID

		UPDATE  [AVL].[Debt_MAS_ProjectDataDictionary] SET ExpectedCompletionDate=NULL
		WHERE ProjectID=@ProjectID AND CONVERT(DATE,ExpectedCompletionDate) IN('1900-01-01','1899-12-31')
	
		DECLARE @SaveCauseCodeMapping AS [AVL].[SaveCauseCodeMapping] 
		INSERT INTO @SaveCauseCodeMapping
		SELECT DISTINCT CauseCodeID,ResolutionCodeID FROM  #Debt_TRN_DataDictionaryTemp DDT
		WHERE DDT.ProjectID=@ProjectID AND DDT.DDUploadID=@DDUploadID
		AND  CauseCodeID IS NOT NULL AND ResolutionCodeID IS NOT NULL AND DDT.IsUpdate IN(1,2)

		EXEC [AVL].[SaveCauseCodeMapingDetails] 'DD',@ProjectID,@SaveCauseCodeMapping,@EmployeeID

		DROP TABLE #ApplicationDetails
		DROP TABLE #CauseCodeDetails
		DROP TABLE #ResolutionCodeDetails
		DROP TABLE #DebtClassification
		DROP TABLE #AvoidableFlagDetails
		DROP TABLE #ResidualDebtDetails
		DROP TABLE #ReasonForResiduaDetails
		DROP TABLE #InValidApplications
		DROP TABLE #InValidCauseCode
		DROP TABLE #InValidResolutionCode
		DROP TABLE #InValidDebtClassification
		DROP TABLE #InValidAvoidableFlag
		DROP TABLE #InValidResidualDebt
		DROP TABLE #InValidReasonForResidual

		DROP TABLE #Debt_TRN_DataDictionaryTemp
	COMMIT TRAN
END TRY
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError ' [AVL].[DataDictionaryExcelUpload]', @ErrorMessage, @EmployeeID,0
END CATCH 
END
