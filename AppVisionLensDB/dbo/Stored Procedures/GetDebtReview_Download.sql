/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Proc [dbo].[GetDebtReview_Download]
(
@StartDate date,
@EndDate date,
@CustomerID bigint,
@EmployeeID NVARCHAR(50),
@ProjectID bigint,
@ReviewStatus int
)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;
DECLARE @userID NVARCHAR(50)
DECLARE @approveStatus bit
--DECLARE @NatureOfTheTicket INT;
--DECLARE @KEDBPath VARCHAR(500);
DECLARE @FlexField1 VARCHAR(100),@FlexField2 VARCHAR(100),@FlexField3 VARCHAR(100),@FlexField4 VARCHAR(100)

SET @FlexField1 = (SELECT TOP 1
		SCM.ProjectColumn
	FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP
	JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC
		ON HPP.ColumnID = MC.ColumnID
		AND MC.IsActive = 1
	JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM
		ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')
		AND SCM.ProjectID = @ProjectID AND IsDeleted = 0
	WHERE HPP.ColumnID = 11
	AND HPP.IsActive = 1
	AND HPP.ProjectID = @ProjectID);

SET @FlexField2 = (SELECT TOP 1
		SCM.ProjectColumn
	FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP
	JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC
		ON HPP.ColumnID = MC.ColumnID
	AND MC.IsActive = 1 
	JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM
		ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')
		AND SCM.ProjectID = @ProjectID AND IsDeleted = 0
	WHERE HPP.ColumnID = 12
	AND HPP.IsActive = 1 
	AND HPP.ProjectID = @ProjectID);

SET @FlexField3 = (SELECT TOP 1
		SCM.ProjectColumn
	FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP
	JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC
		ON HPP.ColumnID = MC.ColumnID
		AND MC.IsActive = 1
	JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM
		ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')
		AND SCM.ProjectID = @ProjectID AND IsDeleted = 0
	WHERE HPP.ColumnID = 13
	AND HPP.IsActive = 1 
	AND HPP.ProjectID = @ProjectID);

SET @FlexField4 = (SELECT TOP 1
		SCM.ProjectColumn
	FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP
	JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC
		ON HPP.ColumnID = MC.ColumnID
		AND MC.IsActive = 1
	JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM
		ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')
		AND SCM.ProjectID = @ProjectID AND IsDeleted = 0
	WHERE HPP.ColumnID = 14
	AND HPP.IsActive = 1
	AND HPP.ProjectID = @ProjectID);

IF (@ReviewStatus = 1) BEGIN
SET @approvestatus = 1
END ELSE IF (@ReviewStatus = 0 OR @ReviewStatus = 2) BEGIN
SET @approvestatus = 0
END

PRINT @approveStatus
SELECT
	@userID = EmployeeID
FROM avl.MAS_LoginMaster(NOLOCK)
WHERE EmployeeID = @EmployeeID
AND CustomerID = @CustomerID AND ProjectID = @ProjectID
AND IsDeleted = 0
PRINT @userID

IF EXISTS (SELECT
		C.CustomerID
	FROM AVL.Customer C
	WHERE C.CustomerID = @CustomerID AND IsDeleted = 0 AND C.IsCognizant = 1) BEGIN
PRINT 'Cuurent1'
SELECT
	TicketID
	,Application
	,ServiceName
	,Assignee
	,CauseCode
	,ResolutionCode
	,DebtClassification
	,AvoidableFlagName
	,ResidualDebt
	,AvoidableFlag
	,AssignedTo
	--,NatureOfTheTicketName
	--,KEDBPath
	--,NatureoftheTicket
	,IsApproved
	,TicketDescription
	,Closeddate
	,DebtClassificationID
	,ResolutionCodeMapID
	,DebtClassificationMapID
	,CauseCodeMapID
	,ResidualDebtMapID
	,ResidualDebtID
	,ResolutionID
	,CauseID
	,CustomerID
	,TicketType
	,FlexField1
	,FlexField2
	,FlexField3
	,FlexField4
	--,NatureOfTheTicketProjectWise
	--,KEDBPathProjectWise
	,FlexField1ProjectWise
	,FlexField2ProjectWise
	,FlexField3ProjectWise
	,FlexField4ProjectWise
	,ProjectID
	,IsCognizant
FROM (SELECT
		0 SLNo
		,'TicketID' AS TicketID
		,'Application Name' AS Application
		,'Service Name' AS ServiceName
		,'Assignee' AS Assignee
		,'Cause Code' AS CauseCode
		,'Resolution Code' AS ResolutionCode
		,'Debt Category' AS DebtClassification
		,'Avoidable Flag' AS AvoidableFlagName
		,'Residual Debt' AS ResidualDebt
		,'Avoidable Flag' AS AvoidableFlag
		,'AssignedTo' AS AssignedTo
		--,'Nature Of The Ticket'	as NatureOfTheTicketName
		--,'KEDB Path'					as KEDBPath
		--,'NatureoftheTicket'		as NatureoftheTicket
		,'IsApproved' AS IsApproved
		,'TicketDescription' AS TicketDescription
		,'Closeddate' AS Closeddate
		,'DebtClassificationID' AS DebtClassificationID
		,'ResolutionCodeMapID' AS ResolutionCodeMapID
		,'DebtClassificationMapID' AS DebtClassificationMapID
		,'CauseCodeMapID' AS CauseCodeMapID
		,'ResidualDebtMapID' AS ResidualDebtMapID
		,'ResidualDebtID' AS ResidualDebtID
		,'ResolutionID' AS ResolutionID
		,'CauseID' AS CauseID
		,'CustomerID' AS CustomerID
		,'TicketType' AS TicketType
		--,'FlexField1' as FlexField1
		--,'FlexField2' as FlexField2
		--,'FlexField3' as FlexField3
		--,'FlexField4' as FlexField4
		,ISNULL(@FlexField1, 'FlexField1') AS FlexField1
		,ISNULL(@FlexField2, 'FlexField2') AS FlexField2
		,ISNULL(@FlexField3, 'FlexField3') AS FlexField3
		,ISNULL(@FlexField4, 'FlexField4') AS FlexField4
		--,'NatureOfTheTicketProjectWise' as NatureOfTheTicketProjectWise
		--,'KEDBPathProjectWise' as KEDBPathProjectWise
		,'FlexField1ProjectWise' AS FlexField1ProjectWise
		,'FlexField2ProjectWise' AS FlexField2ProjectWise
		,'FlexField3ProjectWise' AS FlexField3ProjectWise
		,'FlexField4ProjectWise' AS FlexField4ProjectWise
		,'ProjectID' AS ProjectID
		,'IsCognizant' AS IsCognizant UNION ALL SELECT DISTINCT
		1 SLNo
		,TD.TicketID
		,AD.ApplicationName AS Application
		,S.ServiceName AS ServiceName
		,LM.EmployeeID AS Assignee
		,CC.CauseCode AS CauseCode
		,RC.ResolutionCode AS ResolutionCode
		,DC.DebtClassificationName AS DebtClassification
		,AF.AvoidableFlagName
		,RD.ResidualDebtName AS ResidualDebt
		,CONVERT(VARCHAR, TD.AvoidableFlag) AS AvoidableFlag
		,AssignedTo
		--,ITSMNT.[Nature Of The Ticket] AS NatureOfTheTicketName
		--,TD.KEDBPath
		--,TD.NatureoftheTicket
		,CONVERT(VARCHAR, TD.IsApproved) AS IsApproved
		,TD.TicketDescription
		,CONVERT(VARCHAR, TD.Closeddate) AS Closeddate
		,CONVERT(VARCHAR, DC.DebtClassificationID) AS DebtClassificationID
		,CONVERT(VARCHAR, TD.ResolutionCodeMapID) AS ResolutionCodeMapID
		,CONVERT(VARCHAR, TD.DebtClassificationMapID) AS DebtClassificationMapID
		,CONVERT(VARCHAR, TD.CauseCodeMapID) AS CauseCodeMapID
		,CONVERT(VARCHAR, TD.ResidualDebtMapID) AS ResidualDebtMapID
		,CONVERT(VARCHAR, RD.ResidualDebtID) AS ResidualDebtID
		,CONVERT(VARCHAR, RC.ResolutionID) AS ResolutionID
		,CONVERT(VARCHAR, cc.CauseID) AS CauseID
		,CONVERT(VARCHAR, LM.CustomerID) AS CustomerID
		,'' TicketType
		,CONVERT(NVARCHAR(MAX), TD.FlexField1) AS FlexField1
		,CONVERT(NVARCHAR(MAX), TD.FlexField2) AS FlexField2
		,CONVERT(NVARCHAR(MAX), TD.FlexField3) AS FlexField3
		,CONVERT(NVARCHAR(MAX), TD.FlexField4) AS FlexField4
		--,ISNULL(CONVERT(VARCHAR, @NatureOfTheTicket),'0') AS NatureOfTheTicketProjectWise
		--,ISNULL(CONVERT(VARCHAR,@KEDBPath),'0') AS KEDBPathProjectWise
		,ISNULL(CONVERT(VARCHAR, @FlexField1), '0') AS FlexField1ProjectWise
		,ISNULL(CONVERT(VARCHAR, @FlexField2), '0') AS FlexField2ProjectWise
		,ISNULL(CONVERT(VARCHAR, @FlexField3), '0') AS FlexField3ProjectWise
		,ISNULL(CONVERT(VARCHAR, @FlexField4), '0') AS FlexField4ProjectWise
		,CONVERT(VARCHAR, TD.ProjectID) AS ProjectID
		,CONVERT(VARCHAR, C.IsCognizant) AS IsCognizant
	FROM AVL.[TK_TRN_TicketDetail](NOLOCK) TD
	JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APPM
		ON TD.ApplicationID = APPM.ApplicationID AND APPM.ProjectID = TD.ProjectID AND APPM.IsDeleted = 0
	JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC
		ON TD.CauseCodeMapID = CC.CauseID AND TD.ProjectID = CC.ProjectID AND CC.IsDeleted = 0
	JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC
		ON RC.ResolutionID = TD.ResolutionCodeMapID AND TD.ProjectID = RC.ProjectID AND RC.IsDeleted = 0
	JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
		ON AD.ApplicationID = TD.ApplicationID 
	JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DC
		ON DC.DebtClassificationID = TD.DebtClassificationMapID
	JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RD
		ON RD.ResidualDebtID = TD.ResidualDebtMapID
	JOIN AVL.TK_MAS_Service(NOLOCK) S
		ON S.ServiceID = TD.ServiceID
	JOIN AVL.[DEBT_MAS_AvoidableFlag](NOLOCK) AF
		ON AF.AvoidableFlagID = TD.AvoidableFlag
	--LEFT JOIN AVL.ITSM_MAS_Natureoftheticket ITSMNT 
	--    ON ITSMNT.NatureOfTheTicketId=TD.NatureoftheTicket
	JOIN AVL.MAS_LoginMaster(NOLOCK) LM
		ON LM.UserID = TD.AssignedTo
		AND Lm.CustomerID = @CustomerID
		AND LM.ProjectID = TD.ProjectID AND LM.IsDeleted = 0
	JOIN AVL.Customer(NOLOCK) C
		ON C.CustomerID = LM.CustomerID AND C.IsDeleted = 0
	WHERE TD.ServiceID IN (1, 4, 10, 7, 5, 8, 6)
	AND 1 =
			CASE
				WHEN @approvestatus = 1 AND
					IsApproved = @approveStatus THEN 1
				WHEN @approvestatus = 0 AND
					(IsApproved = @approveStatus OR
					IsApproved IS NULL) THEN 1
				ELSE 0
			END
	AND TD.ProjectID = @ProjectID
	AND TD.DARTStatusID IN (8)
	AND TD.AssignedTo IN (SELECT
			LM.UserID
		FROM avl.MAS_LoginMaster LM (NOLOCK)
		WHERE LM.HcmSupervisorID = @userID
		OR LM.TSApproverID = @userID
		AND LM.IsDeleted = 0)
	AND C.CustomerID = @CustomerID
	AND TD.DebtClassificationMapID IS NOT NULL
	AND TD.ResidualDebtMapID IS NOT NULL
	AND TD.AvoidableFlag IS NOT NULL
	AND TD.CauseCodeMapID IS NOT NULL
	AND TD.ResolutionCodeMapID IS NOT NULL
	AND TD.DebtClassificationMode IN (2,4,5)
	AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)) K
ORDER BY K.SLNo


PRINT '1'
END ELSE BEGIN

PRINT 'Cuurent2'
SELECT

	TicketID
	,Application
	,TicketType
	,Assignee
	,CauseCode
	,ResolutionCode
	,DebtClassification
	,AvoidableFlagName
	,ResidualDebt
	,AvoidableFlag
	,AssignedTo
	--,NatureOfTheTicketName
	--,KEDBPath
	--,NatureoftheTicket
	,IsApproved
	,TicketDescription
	,Closeddate
	,DebtClassificationID
	,ResolutionCodeMapID
	,DebtClassificationMapID
	,CauseCodeMapID
	,ResidualDebtMapID
	,ResidualDebtID
	,ResolutionID
	,CauseID
	,CustomerID
	,ServiceName
	,FlexField1
	,FlexField2
	,FlexField3
	,FlexField4
	--,NatureOfTheTicketProjectWise
	--,KEDBPathProjectWise
	,FlexField1ProjectWise
	,FlexField2ProjectWise
	,FlexField3ProjectWise
	,FlexField4ProjectWise
	,ProjectID
	,IsCognizant
FROM (SELECT
		0 SLNo
		,'TicketID' AS TicketID
		,'Application Name' AS Application
		,'Ticket Type' AS TicketType
		,'Assignee' AS Assignee
		,'Cause Code' AS CauseCode
		,'Resolution Code' AS ResolutionCode
		,'Debt Category' AS DebtClassification
		,'Avoidable Flag' AS AvoidableFlagName
		,'Residual Debt' AS ResidualDebt
		,'Avoidable Flag' AS AvoidableFlag
		,'AssignedTo' AS AssignedTo
		--,'Nature Of The Ticket'	    as NatureOfTheTicketName
		--,'KEDB Path'				as KEDBPath
		--,'NatureoftheTicket'		as NatureoftheTicket
		,'IsApproved' AS IsApproved
		,'TicketDescription' AS TicketDescription
		,'Closeddate' AS Closeddate
		,'DebtClassificationID' AS DebtClassificationID
		,'ResolutionCodeMapID' AS ResolutionCodeMapID
		,'DebtClassificationMapID' AS DebtClassificationMapID
		,'CauseCodeMapID' AS CauseCodeMapID
		,'ResidualDebtMapID' AS ResidualDebtMapID
		,'ResidualDebtID' AS ResidualDebtID
		,'ResolutionID' AS ResolutionID
		,'CauseID' AS CauseID
		,'CustomerID' AS CustomerID
		,'ServiceName' AS ServiceName
		--,'FlexField1' as FlexField1
		--,'FlexField2' as FlexField2
		--,'FlexField3' as FlexField3
		--,'FlexField4'  as FlexField4
		,ISNULL(@FlexField1, 'FlexField1') AS FlexField1
		,ISNULL(@FlexField2, 'FlexField2') AS FlexField2
		,ISNULL(@FlexField3, 'FlexField3') AS FlexField3
		,ISNULL(@FlexField4, 'FlexField4') AS FlexField4
		--,'NatureOfTheTicketProjectWise' as NatureOfTheTicketProjectWise
		--,'KEDBPathProjectWise' as KEDBPathProjectWise
		,'FlexField1ProjectWise' AS FlexField1ProjectWise
		,'FlexField2ProjectWise' AS FlexField2ProjectWise
		,'FlexField3ProjectWise' AS FlexField3ProjectWise
		,'FlexField4ProjectWise' AS FlexField4ProjectWise
		,'ProjectID' AS ProjectID
		,'IsCognizant' AS IsCognizant UNION ALL SELECT DISTINCT
		1 SLNo
		,TD.TicketID
		,AD.ApplicationName AS Application
		,TTM.TicketType
		,LM.EmployeeID AS Assignee
		,CC.CauseCode AS CauseCode
		,RC.ResolutionCode AS ResolutionCode
		,DC.DebtClassificationName AS DebtClassification
		,AF.AvoidableFlagName
		,RD.ResidualDebtName AS ResidualDebt
		,CONVERT(VARCHAR, TD.AvoidableFlag) AS AvoidableFlag
		,AssignedTo
		,CONVERT(VARCHAR, TD.IsApproved) AS IsApproved
		,TD.TicketDescription
		,CONVERT(VARCHAR, TD.Closeddate) AS Closeddate
		,CONVERT(VARCHAR, DC.DebtClassificationID) AS DebtClassificationID
		,CONVERT(VARCHAR, TD.ResolutionCodeMapID) AS ResolutionCodeMapID
		,CONVERT(VARCHAR, TD.DebtClassificationMapID) AS DebtClassificationMapID
		,CONVERT(VARCHAR, TD.CauseCodeMapID) AS CauseCodeMapID
		,CONVERT(VARCHAR, TD.ResidualDebtMapID) AS ResidualDebtMapID
		,CONVERT(VARCHAR, RD.ResidualDebtID) AS ResidualDebtID
		,CONVERT(VARCHAR, RC.ResolutionID) AS ResolutionID
		,CONVERT(VARCHAR, cc.CauseID) AS CauseID
		,CONVERT(VARCHAR, LM.CustomerID) AS CustomerID
		,'' ServiceName
		,CONVERT(NVARCHAR(MAX), TD.FlexField1) AS FlexField1
		,CONVERT(NVARCHAR(MAX), TD.FlexField2) AS FlexField2
		,CONVERT(NVARCHAR(MAX), TD.FlexField3) AS FlexField3
		,CONVERT(NVARCHAR(MAX), TD.FlexField4) AS FlexField4
		,ISNULL(CONVERT(VARCHAR, @FlexField1), '0') AS FlexField1ProjectWise
		,ISNULL(CONVERT(VARCHAR, @FlexField2), '0') AS FlexField2ProjectWise
		,ISNULL(CONVERT(VARCHAR, @FlexField3), '0') AS FlexField3ProjectWise
		,ISNULL(CONVERT(VARCHAR, @FlexField4), '0') AS FlexField4ProjectWise
		,CONVERT(VARCHAR, TD.ProjectID) AS ProjectID
		,CONVERT(VARCHAR, C.IsCognizant) AS IsCognizant

	FROM AVL.[TK_TRN_TicketDetail](NOLOCK) TD
	JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC
		ON TD.CauseCodeMapID = CC.CauseID AND TD.ProjectID = CC.ProjectID AND CC.IsDeleted = 0
	JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC
		ON RC.ResolutionID = TD.ResolutionCodeMapID AND TD.ProjectID = RC.ProjectID AND RC.IsDeleted = 0
	JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
		ON AD.ApplicationID = TD.ApplicationID
	JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APPM
		ON APPM.ProjectID = TD.ProjectID AND APPM.ApplicationID = TD.ApplicationID AND APPM.IsDeleted = 0
	JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DC
		ON DC.DebtClassificationID = TD.DebtClassificationMapID
	JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RD
		ON RD.ResidualDebtID = TD.ResidualDebtMapID
	--JOIN AVL.TK_MAS_Service S on S.ServiceID=TD.ServiceID 
	JOIN AVL.[DEBT_MAS_AvoidableFlag](NOLOCK) AF
		ON AF.AvoidableFlagID = TD.AvoidableFlag
	--LEFT JOIN AVL.ITSM_MAS_Natureoftheticket ITSMNT 
	--    ON ITSMNT.NatureOfTheTicketId=TD.NatureoftheTicket
	JOIN AVL.MAS_LoginMaster(NOLOCK) LM
		ON LM.UserID = TD.AssignedTo
		AND LM.CustomerID = @CustomerID
		AND LM.ProjectID = TD.ProjectID
	JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM
		ON TTM.ProjectID = TD.ProjectID
		AND TTM.TicketTypeMappingID = TD.TicketTypeMapID
	JOIN AVL.Customer(NOLOCK) C
		ON C.CustomerID = LM.CustomerID
	WHERE TTM.DebtConsidered = 'Y'
	AND TTM.TicketType NOT IN ('A', 'H' , 'K')
	AND 1 =
			CASE
				WHEN @approvestatus = 1 AND
					IsApproved = @approveStatus THEN 1
				WHEN @approvestatus = 0 AND
					(IsApproved = @approveStatus OR
					IsApproved IS NULL) THEN 1
				ELSE 0
			END
	-- IsApproved=@approvestatus 
	AND TD.ProjectID = @ProjectID
	AND TD.DARTStatusID IN (8)
	AND TD.AssignedTo IN (SELECT
			LM.UserID
		FROM avl.MAS_LoginMaster LM (NOLOCK)
		WHERE LM.HcmSupervisorID = @EmployeeID
		OR LM.TSApproverID = @EmployeeID
		AND LM.IsDeleted = 0
		AND LM.CustomerID = @CustomerID)
	AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)
	AND TD.DebtClassificationMapID IS NOT NULL
	AND TD.ResidualDebtMapID IS NOT NULL
	AND TD.AvoidableFlag IS NOT NULL
	AND TD.CauseCodeMapID IS NOT NULL
	AND TD.ResolutionCodeMapID IS NOT NULL
	AND TD.DebtClassificationMode IN (2,4,5)
	AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)) K
ORDER BY K.SLNo

END
SET NOCOUNT OFF;
END TRY BEGIN CATCH

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

SELECT
	@ErrorMessage = ERROR_MESSAGE()
SELECT
	@ErrorSeverity = ERROR_SEVERITY()
SELECT
	@ErrorState = ERROR_STATE()

-- ROLLBACK TRAN

--INSERT Error    
EXEC AVL_InsertError	'[dbo].[GetDebtReview_Download]',@ErrorMessage,0,0

END CATCH

END
