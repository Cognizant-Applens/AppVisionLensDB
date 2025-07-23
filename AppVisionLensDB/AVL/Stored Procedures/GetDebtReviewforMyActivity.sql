CREATE PROCEDURE [AVL].[GetDebtReviewforMyActivity] 
(
@StartDate date,
@EndDate date,
@ReviewStatus int,
@IsCognizant int
)
AS
BEGIN
DECLARE @userID NVARCHAR(50)
DECLARE @approveStatus bit
DECLARE @FlexField1 VARCHAR(100),@FlexField2 VARCHAR(100),@FlexField3 VARCHAR(100),@FlexField4 VARCHAR(100)

BEGIN TRY
SET NOCOUNT ON;  

IF (@ReviewStatus = 1) BEGIN  
SET @approvestatus = 1  
END ELSE IF (@ReviewStatus = 0 OR @ReviewStatus = 2) BEGIN  
SET @approvestatus = 0  
END  

create table #ProjectAPP_Patterntemp(ProjectPatternMapID int, ProjectID int,DARTTicketID nvarchar(400))
insert into #ProjectAPP_Patterntemp select HPPM.ProjectPatternMapID, HPPM.ProjectID, HPD.DARTTicketID from [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM 
INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId 
inner JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) HPD ON IHTD.ProjectPatternMapId=HPD.ProjectPatternMapId
	AND HPD.MapStatus=1 AND ISNULL(HPD.IsDeleted,0) != 1

	
create table #ProjectINFRA_Patterntemp(ProjectPatternMapID int, ProjectID int,DARTTicketID nvarchar(400))

insert into #ProjectINFRA_Patterntemp select HPPM.ProjectPatternMapID, HPPM.ProjectID, HPD.DARTTicketId from [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPPM 
INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId 
inner JOIN AVL.DEBT_PRJ_InfraHealParentChild(NOLOCK) HPD ON IHTD.ProjectPatternMapId=HPD.ProjectPatternMapId
	AND HPD.MapStatus=1 AND ISNULL(HPD.IsDeleted,0) != 1



IF (@IsCognizant = 1)
BEGIN
	SELECT DISTINCT  
	 TD.TicketID ,
	 TD.ProjectId,
	 LM.HcmSupervisorID,
	 PM.EsaProjectID
	 ,AD.ApplicationName AS Application  
	 ,IsNull(S.ServiceName,0) AS 'ServiceName'  
	 ,IsNull(LM.EmployeeID,0) AS Assignee  
	 ,CC.CauseCode AS 'CauseCode'  
	 ,RC.ResolutionCode AS 'ResolutionCode'  
	 ,DC.DebtClassificationName AS 'DebtClassification'  
	 ,AF.AvoidableFlagName  
	 ,RD.ResidualDebtName AS 'ResidualDebt'  
	 ,TD.AvoidableFlag AS 'AvoidableFlag'   
	 ,TD.KEDBPath  
	 ,ISNULL(TD.NatureoftheTicket,0) AS NatureoftheTicket
	 ,ISNULL(TD.AssignedTo,0) AS AssignedTo
	 ,ISNULL(TD.IsApproved,0) AS IsApproved
	 ,TD.TicketDescription  
	 ,TD.Closeddate  
	 ,DC.DebtClassificationID  
	 ,TD.ResolutionCodeMapID  
	 ,TD.CauseCodeMapID  
	 ,TD.DebtClassificationMapID  
	 ,TD.ResidualDebtMapID  
	 ,RD.ResidualDebtID  
	 ,RC.ResolutionID  
	 ,cc.CauseID  
	 ,LM.CustomerID  
	 ,TD.ProjectID   ,C.IsCognizant  
	 ,'' TicketType  
	 ,TD.FlexField1 AS 'FlexField1Value'  
	 ,TD.FlexField2 AS 'FlexField2Value'  
	 ,TD.FlexField3 AS 'FlexField3Value'  
	 ,TD.FlexField4 AS 'FlexField4Value'  
	 ,CASE WHEN APP_temp.DARTTicketID IS NOT NULL  
	  THEN 1 ELSE 0 END AS 'IsAHTagged'  
	FROM AVL.[TK_TRN_TicketDetail](NOLOCK) TD  
	JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APPM  
	 ON APPM.ProjectID = TD.ProjectID AND APPM.ApplicationID = TD.ApplicationID AND APPM.IsDeleted = 0  
	JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC  
	 ON TD.CauseCodeMapID = CC.CauseID AND TD.ProjectId = CC.ProjectId AND CC.IsDeleted = 0  
	JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC  
	 ON RC.ResolutionID = TD.ResolutionCodeMapID AND TD.ProjectId = RC.ProjectId AND RC.IsDeleted = 0  
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
	JOIN AVL.MAS_LoginMaster(NOLOCK) LM  
	 ON LM.UserID = TD.AssignedTo  
	 AND LM.ProjectID = TD.ProjectID AND LM.IsDeleted = 0  
	JOIN [AVL].[MAS_ProjectMaster] PM
     ON PM.ProjectID = TD.ProjectID	
	JOIN AVL.Customer(NOLOCK) C  
	 ON C.CustomerID = LM.CustomerID AND C.IsDeleted = 0  
	LEFT JOIN Avl.DEBT_PRJ_HealParentChild(NOLOCK) HPC   
	 ON TD.TicketID = HPC.DARTTicketID  

	left join #ProjectAPP_Patterntemp APP_temp on APP_temp.ProjectID = TD.ProjectID and TD.TicketID = APP_temp.DARTTicketID

  
	WHERE 
	TD.ServiceID IN (1, 4, 10, 7, 5, 8, 6)  
	AND 1 =  
	  CASE  
	   WHEN @approvestatus = 1 AND  
		IsApproved = @approveStatus THEN 1  
	   WHEN @approvestatus = 0 AND  
		(IsApproved = @approveStatus OR  
		IsApproved IS NULL) THEN 1  
	   ELSE 0  
	  END  
	AND TD.DARTStatusID IN (8)  
	AND TD.DebtClassificationMapID IS NOT NULL  
	AND TD.ResidualDebtMapID IS NOT NULL  
	AND TD.AvoidableFlag IS NOT NULL  
	AND TD.CauseCodeMapID IS NOT NULL  
	AND TD.ResolutionCodeMapID IS NOT NULL  
	AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)  
	AND TD.DebtClassificationMode IN (2,4,5) 
END
ELSE
BEGIN
	
	SELECT DISTINCT  
	 TD.TicketID  
	 ,AD.ApplicationName AS Application  
	 ,TTM.TicketType  
	 ,LM.HcmSupervisorID
	 ,PM.EsaProjectID
	 ,ISNULL(LM.EmployeeID,0) AS Assignee  
	 ,CC.CauseCode AS 'CauseCode'  
	 ,RC.ResolutionCode AS 'ResolutionCode'  
	 ,DC.DebtClassificationName AS 'DebtClassification'  
	 ,AF.AvoidableFlagName  
	 ,RD.ResidualDebtName AS 'ResidualDebt'  
	 ,TD.AvoidableFlag AS 'AvoidableFlag'  
	 ,ISNULL(TD.AssignedTo,0) AS AssignedTo
	 ,TD.KEDBPath  
	 ,ISNULL(TD.NatureoftheTicket,0)  AS NatureoftheTicket
	 ,ISNULL(TD.IsApproved,0) AS IsApproved
	 ,TD.TicketDescription  
	 ,TD.Closeddate  
	 ,DC.DebtClassificationID  
	 ,TD.ResolutionCodeMapID  
	 ,TD.DebtClassificationMapID  
	 ,TD.CauseCodeMapID  
	 ,TD.ResidualDebtMapID  
	 ,RD.ResidualDebtID  
	 ,RC.ResolutionID  
	 ,cc.CauseID  
	 ,LM.CustomerID   
	 ,TD.ProjectID,
	 LM.HcmSupervisorID
	 ,C.IsCognizant  
	 ,'' ServiceName  
	 ,TD.FlexField1 AS 'FlexField1Value'  
	 ,TD.FlexField2 AS 'FlexField2Value'  
	 ,TD.FlexField3 AS 'FlexField3Value'  
	 ,TD.FlexField4 AS 'FlexField4Value'  
	 ,CASE WHEN INFRA_temp.DARTTicketID IS NOT NULL  
	 THEN 1 ELSE 0 END AS 'IsAHTagged'  
	FROM AVL.[TK_TRN_TicketDetail](NOLOCK) TD  
	JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC  
	 ON TD.CauseCodeMapID = CC.CauseID AND TD.ProjectId = CC.ProjectId AND CC.IsDeleted = 0  
	JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC  
	 ON RC.ResolutionID = TD.ResolutionCodeMapID AND TD.ProjectId = RC.ProjectId AND RC.IsDeleted = 0  
	JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD  
	 ON AD.ApplicationID = TD.ApplicationID  
	JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APPM  
	 ON APPM.ProjectID = TD.ProjectID AND APPM.ApplicationID = AD.ApplicationID AND APPM.IsDeleted = 0  
	JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DC  
	 ON DC.DebtClassificationID = TD.DebtClassificationMapID  
	JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RD  
	 ON RD.ResidualDebtID = TD.ResidualDebtMapID   
	JOIN AVL.[DEBT_MAS_AvoidableFlag](NOLOCK) AF  
	 ON AF.AvoidableFlagID = TD.AvoidableFlag  
	JOIN AVL.MAS_LoginMaster(NOLOCK) LM  
	 ON LM.UserID = TD.AssignedTo   
	 AND LM.ProjectID = TD.ProjectID AND LM.IsDeleted = 0  
	JOIN [AVL].[MAS_ProjectMaster] PM
     ON PM.ProjectID = TD.ProjectID	
	JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM  
	 ON TTM.ProjectID = TD.ProjectID  
	 AND TTM.TicketTypeMappingID = TD.TicketTypeMapID AND TTM.IsDeleted = 0  
	JOIN AVL.Customer(NOLOCK) C  
	 ON C.CustomerID = LM.CustomerID AND C.IsDeleted = 0  
	left join #ProjectINFRA_Patterntemp INFRA_temp on INFRA_temp.ProjectID = TD.ProjectID and TD.TicketID = INFRA_temp.DARTTicketID
  
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
	AND TD.DARTStatusID IN (8)  
	AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)  
	AND TD.DebtClassificationMapID IS NOT NULL  
	AND TD.ResidualDebtMapID IS NOT NULL  
	AND TD.AvoidableFlag IS NOT NULL  
	AND TD.CauseCodeMapID IS NOT NULL  
	AND TD.ResolutionCodeMapID IS NOT NULL  
	AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)  
	AND TD.DebtClassificationMode IN (2,4,5)  
END 
DROP TABLE #ProjectAPP_Patterntemp
Drop Table #ProjectINFRA_Patterntemp
SET NOCOUNT OFF;
 END TRY  
   BEGIN CATCH  
            DECLARE @ErrorMessage VARCHAR(MAX);
            SELECT @ErrorMessage = ERROR_MESSAGE() 
            EXEC AVL_InsertError '[AVL].[GetDebtReviewforMyActivity]', @ErrorMessage, 0, 0
            RETURN @@ERROR       
   END CATCH 
END
