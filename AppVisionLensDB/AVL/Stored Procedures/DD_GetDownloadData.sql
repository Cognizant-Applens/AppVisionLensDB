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
-- Description:  Takes data from Data Dictionary neccessary to bind the excel data
-- DB Name :     AppVisionlens
--[AVL].[DD_GetDownloadData_Test] 14446
--[AVL].[DD_GetDownloadData] 14446
-- ============================================================================ 
CREATE PROCEDURE [AVL].[DD_GetDownloadData]
(
@ProjectID BIGINT
) 
AS
BEGIN
	BEGIN TRY
		SELECT   AD.ApplicationName
		,CC.CauseCode
		,RC.ResolutionCode
		,DC.DebtClassificationName
		,AF.AvoidableFlagName
		,RD.ResidualDebtName
		,RFR.ReasonResidualName
		,CASE WHEN CONVERT(VARCHAR, DD.[ExpectedCompletionDate], 101)='' THEN NULL
		ELSE  CONVERT(VARCHAR, DD.[ExpectedCompletionDate], 101) END AS ExpectedCompletionDate
		FROM AVL.Debt_MAS_ProjectDataDictionary(NOLOCK) DD
		INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.ProjectID=DD.ProjectID
		INNER JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM ON DD.ApplicationID=APM.ApplicationID AND DD.ProjectID=APM.ProjectID
		AND ISNULL(APM.IsDeleted,0)=0
		INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON APM.ApplicationID=AD.ApplicationID AND AD.IsActive=1
		INNER JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC on RC.ResolutionID=DD.ResolutionCodeID AND ISNULL(RC.IsDeleted,0)=0 
		INNER JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC on CC.CauseID=DD.CauseCodeID  AND ISNULL(CC.IsDeleted,0)=0 
		INNER JOIN AVl.DEBT_MAS_DebtClassification(NOLOCK) DC on DC.DebtClassificationID=DD.DebtClassificationID 
		AND ISNULL(DC.IsDeleted,0)=0
		INNER JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AF on AF.AvoidableFlagID=DD.AvoidableFlagID AND ISNULL(AF.IsDeleted,0)=0
		INNER JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RD on RD.ResidualDebtID=DD.ResidualDebtID AND ISNULL(RD.IsDeleted,0)=0
		LEFT JOIN [AVL].[TK_MAS_ReasonForResidual](NOLOCK) RFR on RFR.ReasonResidualID=DD.ReasonForResidual 
		AND ISNULL(RD.IsDeleted,0)=0
		WHERE PM.ProjectID=@ProjectID AND RC.ProjectID=@ProjectID AND CC.ProjectID=@ProjectID AND ISNULL(DD.IsDeleted,0)=0

		CREATE TABLE #AppTemp
		(
		ID INT IDENTITY(1,1),
		ApplicationName NVARCHAR(MAX) NULL,
		ApplicationID BIGINT NULL,
		)

		CREATE TABLE #CauseTemp
		(
		ID INT IDENTITY(1,1),
		CauseCode NVARCHAR(MAX) NULL,
		CauseID BIGINT NULL,
		)
		CREATE TABLE #ResolutionTemp
		(
		ID INT IDENTITY(1,1),
		ResolutionCode NVARCHAR(MAX) NULL,
		ResolutionID BIGINT NULL,
		)
		SELECT DISTINCT AD.ApplicationName,APM.ApplicationID
        INTO #ApplicationDetails
        FROM AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM
        INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
        ON APM.ApplicationID=AD.ApplicationID
        WHERE APM.ProjectID=@ProjectID AND ISNULL(APM.IsDeleted,0)=0 AND AD.IsActive=1
        ORDER BY ApplicationName ASC


              IF EXISTS (SELECT ApplicationID FROM  #ApplicationDetails)
                     BEGIN
						 INSERT INTO #AppTemp
                        SELECT 'ApplicationName' AS ApplicationName,-1 AS ApplicationID

						INSERT INTO #AppTemp
                        SELECT 'All' AS ApplicationName,0 AS ApplicationID

                       	INSERT INTO #AppTemp
						SELECT DISTINCT AD.ApplicationName,APM.ApplicationID
						FROM AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM
						INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
						ON APM.ApplicationID=AD.ApplicationID
						WHERE APM.ProjectID=@ProjectID AND ISNULL(APM.IsDeleted,0)=0 AND AD.IsActive=1
						ORDER BY ApplicationName ASC

                     END
              ELSE
              BEGIN
						INSERT INTO #AppTemp
                        SELECT 'ApplicationName' AS ApplicationName,-1 AS ApplicationID
						 INSERT INTO #AppTemp
						SELECT DISTINCT AD.ApplicationName,APM.ApplicationID
						FROM AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM
						INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
						ON APM.ApplicationID=AD.ApplicationID
						WHERE APM.ProjectID=@ProjectID AND ISNULL(APM.IsDeleted,0)=0 AND AD.IsActive=1
						ORDER BY ApplicationName ASC
              END

		INSERT INTO #CauseTemp
		SELECT 'CauseCode' AS CauseCode,0 AS CauseID

		INSERT INTO #CauseTemp
		SELECT CauseCode,CauseID FROM [AVL].[DEBT_MAP_CauseCode](NOLOCK)  
		WHERE ProjectID = @ProjectID AND ISNULL(IsDeleted,0) =0
		ORDER BY CauseCode ASC


		INSERT INTO #ResolutionTemp
		SELECT  'ResolutionCode' AS ResolutionCode,0 AS ResolutionID

		INSERT INTO #ResolutionTemp
		SELECT ResolutionCode,ResolutionID FROM [AVL].[DEBT_MAP_ResolutionCode](NOLOCK)  
		WHERE ProjectID = @ProjectID AND ISNULL(IsDeleted,0) = 0
		ORDER BY ResolutionCode ASC


		SELECT ApplicationName, ApplicationID FROM #AppTemp
		SELECT CauseCode, CauseID FROM #CauseTemp
		SELECT ResolutionCode, ResolutionID FROM #ResolutionTemp

		SELECT DebtClassificationName,DebtClassificationID FROM [AVL].[DEBT_MAS_DebtClassification] (NOLOCK) 
		WHERE IsDeleted =0 

		SELECT AvoidableFlagName,AvoidableFlagID FROM [AVL].[DEBT_MAS_AvoidableFlag](NOLOCK) 
		WHERE IsDeleted =0 

		SELECT ResidualDebtName,ResidualDebtID FROM AVL.DEBT_MAS_ResidualDebt(NOLOCK)  WHERE IsDeleted =0 

		Select ReasonResidualName,ReasonResidualID from [AVL].[TK_MAS_ReasonForResidual](NOLOCK)  
		WHERE IsDeleted=0 and ReasonResidualName NOT IN ('Others') 
		ORDER BY CreatedDate DESC

		DROP TABLE #AppTemp
		DROP TABLE #CauseTemp
		DROP TABLE #ResolutionTemp

	END TRY
BEGIN CATCH
	DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
	EXEC AVL_InsertError '[AVL].[DD_GetDownloadData]',@ErrorMessage,0,0	
END CATCH
END
