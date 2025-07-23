CREATE PROCEDURE [dbo].[GetDebtReview] --'8/24/2022 12:18:02 PM','9/24/2022 12:18:02 PM',11558,'878110',99812,2      
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
DECLARE @userID NVARCHAR(50)      
DECLARE @approveStatus bit      
--DECLARE @NatureOfTheTicket INT;      
--DECLARE @KEDBPath VARCHAR(500);      
DECLARE @FlexField1 VARCHAR(100),@FlexField2 VARCHAR(100),@FlexField3 VARCHAR(100),@FlexField4 VARCHAR(100)      
      
BEGIN TRY      
SET NOCOUNT ON;      
--SET @NatureOfTheTicket = (SELECT      
--  ColumnID      
-- FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)      
-- WHERE ColumnID = 7      
-- AND       
-- IsActive = 1      
-- AND ProjectID = @ProjectID);      
       
--SET @KEDBPath = (SELECT      
--  ColumnID      
-- FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)      
-- WHERE ColumnID = 9      
-- AND IsActive = 1      
-- AND ProjectID = @ProjectID);      
      
DECLARE @AppAlgorithmKey nvarchar(6);        
  DECLARE @InfraAlgorithmKey nvarchar(6);        
  IF((SELECT Count(AlgorithmKey) FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0) > 0 )      
  BEGIN       
  IF EXISTS(SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1)      
  BEGIN      
  SET @AppAlgorithmKey = (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1)      
  END      
  IF EXISTS(SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2)      
  BEGIN      
  SET @InfraAlgorithmKey = (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2)      
  END      
  END      
  ELSE      
  BEGIN      
  SET @AppAlgorithmKey ='AL002'      
  SET @InfraAlgorithmKey='AL002'      
  END            
      
create table #ProjectAPP_Patterntemp(ProjectPatternMapID int, ProjectID int,DARTTicketID nvarchar(400))      
      
insert into #ProjectAPP_Patterntemp select HPPM.ProjectPatternMapID, HPPM.ProjectID, HPD.DARTTicketID from [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM       
INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId       
      
inner JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) HPD ON IHTD.ProjectPatternMapId=HPD.ProjectPatternMapId      
 AND HPD.MapStatus=1 AND ISNULL(HPD.IsDeleted,0) != 1      
where HPPM.ProjectID = @ProjectID      
      
create table #ProjectINFRA_Patterntemp(ProjectPatternMapID int, ProjectID int,DARTTicketID nvarchar(400))      
      
insert into #ProjectINFRA_Patterntemp select HPPM.ProjectPatternMapID, HPPM.ProjectID, HPD.DARTTicketId from [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPPM       
INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId       
inner JOIN AVL.DEBT_PRJ_InfraHealParentChild(NOLOCK) HPD ON IHTD.ProjectPatternMapId=HPD.ProjectPatternMapId      
 AND HPD.MapStatus=1 AND ISNULL(HPD.IsDeleted,0) != 1      
where HPPM.ProjectID = @ProjectID      
 --AND HPPM.MapStatus=1 AND ISNULL(IHTD.IsDeleted,0) != 1      
      
 SET @FlexField1 = (SELECT TOP 1 SCM.ProjectColumn      
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP      
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC ON HPP.ColumnID=MC.ColumnID AND MC.IsActive=1       
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '') and SCM.ProjectID=@ProjectID AND SCM.IsDeleted = 0      
 WHERE HPP.ColumnID = 11      
 AND HPP.IsActive = 1      
 AND HPP.ProjectID = @ProjectID);      
      
 SET @FlexField2 = (SELECT TOP 1 SCM.ProjectColumn      
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP      
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC ON HPP.ColumnID=MC.ColumnID AND MC.IsActive=1      
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '') and SCM.ProjectID=@ProjectID AND SCM.IsDeleted = 0      
 WHERE HPP.ColumnID = 12      
 AND HPP.IsActive = 1      
 AND HPP.ProjectID = @ProjectID);      
      
 SET @FlexField3 = (SELECT TOP 1 SCM.ProjectColumn      
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP      
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC ON HPP.ColumnID=MC.ColumnID AND MC.IsActive=1      
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '') and SCM.ProjectID=@ProjectID AND SCM.IsDeleted = 0      
 WHERE HPP.ColumnID = 13      
 AND HPP.IsActive = 1      
 AND HPP.ProjectID = @ProjectID);      
      
 SET @FlexField4 = (SELECT TOP 1 SCM.ProjectColumn      
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP      
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC ON HPP.ColumnID=MC.ColumnID AND MC.IsActive=1      
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '') and SCM.ProjectID=@ProjectID AND SCM.IsDeleted = 0      
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
AND CustomerID = @CustomerID AND ProjectId = @ProjectId      
AND IsDeleted = 0      
PRINT @userID      
--SELECT * INTO #TicketDetailsTEMP FROM AVL.[TK_TRN_TicketDetail] WHERE ProjectID = @ProjectID      
IF EXISTS (SELECT      
  C.CustomerID      
 FROM AVL.Customer(NOLOCK) C      
 WHERE C.IsCognizant = 1      
 AND C.CustomerID = @CustomerID AND IsDeleted = 0) BEGIN      
      
IF(@AppAlgorithmKey='AL001')      
BEGIN       
SELECT DISTINCT      
 TD.TicketID      
 ,AD.ApplicationName AS Application      
 ,S.ServiceName AS 'ServiceName'      
 ,LM.EmployeeID AS Assignee      
 ,CC.CauseCode AS 'CauseCode'      
 ,RC.ResolutionCode AS 'ResolutionCode'      
 ,DC.DebtClassificationName AS 'DebtClassification'      
 ,AF.AvoidableFlagName      
 ,RD.ResidualDebtName AS 'ResidualDebt'      
 ,TD.AvoidableFlag AS 'AvoidableFlag'      
 --,ITSMNT.[Nature Of The Ticket] AS 'NatureOfTheTicket'      
 ,TD.KEDBPath      
 ,TD.NatureoftheTicket       
 ,TD.AssignedTo      
 ,TD.IsApproved      
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
 ,TD.ProjectID      
 ,C.IsCognizant      
 ,'' TicketType      
 ,TD.FlexField1 AS 'FlexField1Value'      
 ,TD.FlexField2 AS 'FlexField2Value'      
 ,TD.FlexField3 AS 'FlexField3Value'   
 ,TD.FlexField4 AS 'FlexField4Value'      
 --,ISNULL(CONVERT(VARCHAR, @NatureOfTheTicket),'0') AS NatureOfTheTicketProjectWise      
 --,ISNULL(CONVERT(VARCHAR,@KEDBPath),'0') AS KEDBPathProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField1),'0') AS FlexField1ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField2),'0') AS FlexField2ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField3),'0') AS FlexField3ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField4),'0') AS FlexField4ProjectWise      
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
 AND Lm.CustomerID = @CustomerID      
 AND LM.ProjectID = TD.ProjectID AND LM.IsDeleted = 0      
JOIN AVL.Customer(NOLOCK) C      
 ON C.CustomerID = LM.CustomerID AND C.IsDeleted = 0      
--LEFT JOIN Avl.DEBT_PRJ_HealParentChild(NOLOCK) HPC       
-- ON TD.TicketID = HPC.DARTTicketID      
 --AND TD.ProjectID =HPC.ProjectID       
 left join #ProjectAPP_Patterntemp APP_temp on APP_temp.ProjectID = TD.ProjectID and TD.TicketID = APP_temp.DARTTicketID      
-- INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM ON TD.ProjectID=HPPM.ProjectID      
--INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId      
      
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
 FROM avl.MAS_LoginMaster(NOLOCK) LM      
 WHERE LM.HcmSupervisorID = @userID      
 OR LM.TSApproverID = @userID      
 AND LM.IsDeleted = 0)      
AND C.CustomerID = @CustomerID      
AND TD.DebtClassificationMapID IS NOT NULL      
AND TD.ResidualDebtMapID IS NOT NULL      
AND TD.AvoidableFlag IS NOT NULL      
AND TD.CauseCodeMapID IS NOT NULL      
AND TD.ResolutionCodeMapID IS NOT NULL      
AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)      
AND TD.DebtClassificationMode IN (2,4,5)      
END      
IF(@AppAlgorithmKey='AL002')      
BEGIN     
SELECT DISTINCT      
 TD.TicketID      
 ,AD.ApplicationName AS Application      
 ,S.ServiceName AS 'ServiceName'      
 ,LM.EmployeeID AS Assignee      
 ,CC.CauseCode AS 'CauseCode'      
 ,RC.ResolutionCode AS 'ResolutionCode'      
 ,DC.DebtClassificationName AS 'DebtClassification'      
 ,AF.AvoidableFlagName      
 ,RD.ResidualDebtName AS 'ResidualDebt'      
 ,TD.AvoidableFlag AS 'AvoidableFlag'      
 --,ITSMNT.[Nature Of The Ticket] AS 'NatureOfTheTicket'      
 ,TD.KEDBPath      
 ,TD.NatureoftheTicket       
 ,TD.AssignedTo      
 ,TD.IsApproved      
 ,TD.TicketDescription      
 ,TD.Closeddate      
 ,DC.DebtClassificationID      
 ,ISNULL(TD.ResolutionCodeMapID, 0) as ResolutionCodeMapID      
 ,ISNULL(TD.CauseCodeMapID, 0) as CauseCodeMapID      
 ,TD.DebtClassificationMapID      
 ,TD.ResidualDebtMapID      
 ,RD.ResidualDebtID      
 ,ISNULL(RC.ResolutionID,0) AS ResolutionID      
 ,ISNULL(cc.CauseID,0) AS CauseID      
 ,LM.CustomerID      
 ,TD.ProjectID      
 ,C.IsCognizant      
 ,'' TicketType      
 ,TD.FlexField1 AS 'FlexField1Value'      
 ,TD.FlexField2 AS 'FlexField2Value'      
 ,TD.FlexField3 AS 'FlexField3Value'      
 ,TD.FlexField4 AS 'FlexField4Value'      
 --,ISNULL(CONVERT(VARCHAR, @NatureOfTheTicket),'0') AS NatureOfTheTicketProjectWise      
 --,ISNULL(CONVERT(VARCHAR,@KEDBPath),'0') AS KEDBPathProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField1),'0') AS FlexField1ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField2),'0') AS FlexField2ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField3),'0') AS FlexField3ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField4),'0') AS FlexField4ProjectWise      
 ,CASE WHEN APP_temp.DARTTicketID IS NOT NULL      
  THEN 1 ELSE 0 END AS 'IsAHTagged'      
FROM AVL.[TK_TRN_TicketDetail](NOLOCK) TD      
JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APPM      
 ON APPM.ProjectID = TD.ProjectID AND APPM.ApplicationID = TD.ApplicationID AND APPM.IsDeleted = 0      
LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC      
 ON TD.CauseCodeMapID = CC.CauseID AND TD.ProjectId = CC.ProjectId AND CC.IsDeleted = 0      
LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC      
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
 AND Lm.CustomerID = @CustomerID      
 AND LM.ProjectID = TD.ProjectID AND LM.IsDeleted = 0      
JOIN AVL.Customer(NOLOCK) C      
 ON C.CustomerID = LM.CustomerID AND C.IsDeleted = 0      
--LEFT JOIN Avl.DEBT_PRJ_HealParentChild(NOLOCK) HPC       
-- ON TD.TicketID = HPC.DARTTicketID      
 --AND TD.ProjectID =HPC.ProjectID       
 left join #ProjectAPP_Patterntemp APP_temp on APP_temp.ProjectID = TD.ProjectID and TD.TicketID = APP_temp.DARTTicketID      
-- INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM ON TD.ProjectID=HPPM.ProjectID      
--INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId      
      
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
 FROM avl.MAS_LoginMaster(NOLOCK) LM      
 WHERE LM.HcmSupervisorID = @userID      
 OR LM.TSApproverID = @userID      
 AND LM.IsDeleted = 0)      
AND C.CustomerID = @CustomerID      
AND TD.DebtClassificationMapID IS NOT NULL      
AND TD.ResidualDebtMapID IS NOT NULL      
AND TD.AvoidableFlag IS NOT NULL      
--AND TD.CauseCodeMapID IS NOT NULL      
--AND TD.ResolutionCodeMapID IS NOT NULL      
AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)      
AND TD.DebtClassificationMode IN (2,4,5)      
      
END      
END       
ELSE      
BEGIN      
IF(@AppAlgorithmKey='AL001' OR @InfraAlgorithmKey='AL001')      
BEGIN    
SELECT DISTINCT      
 TD.TicketID      
 ,AD.ApplicationName AS Application      
 ,TTM.TicketType      
 ,LM.EmployeeID AS Assignee      
 ,CC.CauseCode AS 'CauseCode'      
 ,RC.ResolutionCode AS 'ResolutionCode'      
 ,DC.DebtClassificationName AS 'DebtClassification'      
 ,AF.AvoidableFlagName      
 ,RD.ResidualDebtName AS 'ResidualDebt'      
 ,TD.AvoidableFlag AS 'AvoidableFlag'      
 ,TD.AssignedTo      
 --,ITSMNT.[Nature Of The Ticket] AS 'NatureOfTheTicket'      
 ,TD.KEDBPath      
 ,TD.NatureoftheTicket      
 ,TD.IsApproved      
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
 ,TD.ProjectID      
 ,C.IsCognizant      
 ,'' ServiceName      
 ,TD.FlexField1 AS 'FlexField1Value'      
 ,TD.FlexField2 AS 'FlexField2Value'      
 ,TD.FlexField3 AS 'FlexField3Value'      
 ,TD.FlexField4 AS 'FlexField4Value'      
 --,ISNULL(CONVERT(VARCHAR, @NatureOfTheTicket),'0') AS NatureOfTheTicketProjectWise      
 --,ISNULL(CONVERT(VARCHAR,@KEDBPath),'0') AS KEDBPathProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField1),'0') AS FlexField1ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField2),'0') AS FlexField2ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField3),'0') AS FlexField3ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField4),'0') AS FlexField4ProjectWise      
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
--JOIN AVL.TK_MAS_Service S on S.ServiceID=TD.ServiceID       
JOIN AVL.[DEBT_MAS_AvoidableFlag](NOLOCK) AF      
 ON AF.AvoidableFlagID = TD.AvoidableFlag      
--LEFT JOIN AVL.ITSM_MAS_Natureoftheticket ITSMNT       
--    ON ITSMNT.NatureOfTheTicketId=TD.NatureoftheTicket      
JOIN AVL.MAS_LoginMaster(NOLOCK) LM      
 ON LM.UserID = TD.AssignedTo      
 AND LM.CustomerID = @CustomerID      
 AND LM.ProjectID = TD.ProjectID AND LM.IsDeleted = 0      
JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM      
 ON TTM.ProjectID = TD.ProjectID      
 AND TTM.TicketTypeMappingID = TD.TicketTypeMapID AND TTM.IsDeleted = 0      
JOIN AVL.Customer(NOLOCK) C      
 ON C.CustomerID = LM.CustomerID AND C.IsDeleted = 0      
--LEFT JOIN Avl.DEBT_PRJ_HealParentChild(NOLOCK) HPC       
-- ON TD.TicketID = HPC.DARTTicketID      
 --AND TD.ProjectID =HPC.ProjectID      
 --AND HPC.MapStatus='Active' AND ISNULL(HPC.IsDeleted,0) != 1      
 left join #ProjectINFRA_Patterntemp INFRA_temp on INFRA_temp.ProjectID = TD.ProjectID and TD.TicketID = INFRA_temp.DARTTicketID      
-- INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM ON TD.ProjectID=HPPM.ProjectID      
--INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId      
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
 FROM avl.MAS_LoginMaster(NOLOCK) LM      
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
AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)      
AND TD.DebtClassificationMode IN (2,4,5)      
END      
ELSE IF(@AppAlgorithmKey='AL002' OR @InfraAlgorithmKey='AL002')      
BEGIN       
SELECT DISTINCT      
 TD.TicketID      
 ,AD.ApplicationName AS Application      
 ,TTM.TicketType      
 ,LM.EmployeeID AS Assignee      
 ,CC.CauseCode AS 'CauseCode'      
 ,RC.ResolutionCode AS 'ResolutionCode'      
 ,DC.DebtClassificationName AS 'DebtClassification'      
 ,AF.AvoidableFlagName      
 ,RD.ResidualDebtName AS 'ResidualDebt'      
 ,TD.AvoidableFlag AS 'AvoidableFlag'      
 ,TD.AssignedTo      
 --,ITSMNT.[Nature Of The Ticket] AS 'NatureOfTheTicket'      
 ,TD.KEDBPath      
 ,TD.NatureoftheTicket      
 ,TD.IsApproved      
 ,TD.TicketDescription      
 ,TD.Closeddate      
 ,DC.DebtClassificationID      
 ,ISNULL(TD.ResolutionCodeMapID,0) as ResolutionCodeMapID      
 ,TD.DebtClassificationMapID      
 ,ISNULL(TD.CauseCodeMapID,0) as CauseCodeMapID      
 ,TD.ResidualDebtMapID      
 ,RD.ResidualDebtID      
 ,ISNULL(RC.ResolutionID,0) AS ResolutionID      
 ,ISNULL(cc.CauseID,0) AS CauseID      
 ,LM.CustomerID       
 ,TD.ProjectID      
 ,C.IsCognizant      
 ,'' ServiceName      
 ,TD.FlexField1 AS 'FlexField1Value'      
 ,TD.FlexField2 AS 'FlexField2Value'      
 ,TD.FlexField3 AS 'FlexField3Value'      
 ,TD.FlexField4 AS 'FlexField4Value'      
 --,ISNULL(CONVERT(VARCHAR, @NatureOfTheTicket),'0') AS NatureOfTheTicketProjectWise      
 --,ISNULL(CONVERT(VARCHAR,@KEDBPath),'0') AS KEDBPathProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField1),'0') AS FlexField1ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField2),'0') AS FlexField2ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField3),'0') AS FlexField3ProjectWise      
 ,ISNULL(CONVERT(VARCHAR,@FlexField4),'0') AS FlexField4ProjectWise      
 ,CASE WHEN INFRA_temp.DARTTicketID IS NOT NULL      
 THEN 1 ELSE 0 END AS 'IsAHTagged'      
FROM AVL.[TK_TRN_TicketDetail](NOLOCK) TD      
LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC      
 ON TD.CauseCodeMapID = CC.CauseID AND TD.ProjectId = CC.ProjectId AND CC.IsDeleted = 0      
LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC      
 ON RC.ResolutionID = TD.ResolutionCodeMapID AND TD.ProjectId = RC.ProjectId AND RC.IsDeleted = 0      
JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD      
 ON AD.ApplicationID = TD.ApplicationID      
JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APPM      
 ON APPM.ProjectID = TD.ProjectID AND APPM.ApplicationID = AD.ApplicationID AND APPM.IsDeleted = 0      
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
 AND LM.ProjectID = TD.ProjectID AND LM.IsDeleted = 0      
JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM      
 ON TTM.ProjectID = TD.ProjectID      
 AND TTM.TicketTypeMappingID = TD.TicketTypeMapID AND TTM.IsDeleted = 0      
JOIN AVL.Customer(NOLOCK) C      
 ON C.CustomerID = LM.CustomerID AND C.IsDeleted = 0      
--LEFT JOIN Avl.DEBT_PRJ_HealParentChild(NOLOCK) HPC       
-- ON TD.TicketID = HPC.DARTTicketID      
 --AND TD.ProjectID =HPC.ProjectID      
 --AND HPC.MapStatus='Active' AND ISNULL(HPC.IsDeleted,0) != 1      
 left join #ProjectINFRA_Patterntemp INFRA_temp on INFRA_temp.ProjectID = TD.ProjectID and TD.TicketID = INFRA_temp.DARTTicketID      
-- INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM ON TD.ProjectID=HPPM.ProjectID      
--INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId      
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
 FROM avl.MAS_LoginMaster(NOLOCK) LM      
 WHERE LM.HcmSupervisorID = @EmployeeID      
 OR LM.TSApproverID = @EmployeeID      
 AND LM.IsDeleted = 0      
 AND LM.CustomerID = @CustomerID)      
AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)      
AND TD.DebtClassificationMapID IS NOT NULL      
AND TD.ResidualDebtMapID IS NOT NULL      
AND TD.AvoidableFlag IS NOT NULL      
--AND TD.CauseCodeMapID IS NOT NULL      
--AND TD.ResolutionCodeMapID IS NOT NULL      
AND CAST(TD.Closeddate AS DATE) BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)      
AND TD.DebtClassificationMode IN (2,4,5)      
      
END      
END      
      
Drop table #ProjectAPP_Patterntemp      
Drop table #ProjectINFRA_Patterntemp      
--DROP TABLE #TicketDetailsTEMP      
SET NOCOUNT OFF;      
 END TRY        
      
   BEGIN CATCH        
      
              DECLARE @ErrorMessage VARCHAR(MAX);      
      
              SELECT @ErrorMessage = ERROR_MESSAGE()      
              --Insert Error          
              EXEC AVL_InsertError '[dbo].[GetDebtReview]', @ErrorMessage, 0, 0      
      
              RETURN @@ERROR      
             
   END CATCH       
END
