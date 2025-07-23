

  
  
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description ,,>  
-- =============================================  
  
  
 -- @LeadId int =null,  
 --DECLARE @ProjectID nvarchar(100)='83',  
 -- @EmployeeID nvarchar (100)='245829'  
 -- @DebitReviewDetailsUpload DebitReviewDetailsUpload READONLY    
 --EXEC [AVL].[UploadAndUpdateDebtReview_Test] '83','245829'  
CREATE PROCEDURE [AVL].[UploadAndUpdateDebtReviewAlgoTwo]   
 -- @LeadId int =null,  
  @ProjectID nvarchar(100),  
  @EmployeeID nvarchar (100)  
 -- @DebitReviewDetailsUpload DebitReviewDetailsUpload READONLY    
AS  
BEGIN  
 BEGIN TRY  
 BEGIN TRAN  
SET NOCOUNT ON;  
DECLARE @Result NVARCHAR(100)  
DECLARE @AssigneeName NVARCHAR(100)  
DECLARE @ApproverName NVARCHAR(100)  
--DECLARE @tableHTML  VARCHAR(MAX);  
DECLARE @Subjecttext VARCHAR(MAX);  
DECLARE @MinCount INT  
DECLARE @MaxCount INT  
DECLARE @AssigneeEmailName VARCHAR(MAX);  
DECLARE @IsCognizant INT;  
DECLARE @NatureOfTheTicket INT;  
DECLARE @KEDBPath VARCHAR(500);  
DECLARE @FlexField1 INT,@FlexField2 INT,@FlexField3 INT,@FlexField4 INT  
DECLARE @TicketTaggedStatus bit =1  
  
--DELETE FT FROM [dbo].[DebtReviewTemp]  FT    
--INNER JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) HPD    
--ON HPD.ProjectID=@ProjectID     
-- AND FT.TicketID=HPD.DARTTicketID     
-- AND HPD.MapStatus=@TicketTaggedStatus AND ISNULL(HPD.IsDeleted,0) != 1    
    
DELETE FT FROM [dbo].[DebtReviewTemp]  FT      
--INNER JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) HPD ON     
-- FT.TicketID=HPD.DARTTicketID       
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM ON HPPM.ProjectID = @ProjectID   
INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId   
INNER JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) IHPD ON HPPM.ProjectPatternMapId=IHPD.ProjectPatternMapId      
AND ISNULL(HPPM.IsDeleted,0) != 1  AND FT.TicketID=IHPD.DARTTicketID  
 AND IHPD.MapStatus=@TicketTaggedStatus AND ISNULL(IHPD.IsDeleted,0) != 1   
  
SET @NatureOfTheTicket = (SELECT TOP 1  
  ColumnID  
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)  
 WHERE ColumnID = 7  
 AND IsActive = 1  
 AND ProjectID = @ProjectID);  
  
SET @KEDBPath = (SELECT TOP 1  
  ColumnID  
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)  
 WHERE ColumnID = 9  
 AND IsActive = 1  
 AND ProjectID = @ProjectID);  
  
SET @FlexField1 = (SELECT  
  ColumnID  
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)  
 WHERE ColumnID = 11  
 AND IsActive = 1  
 AND ProjectID = @ProjectID);  
  
 SET @FlexField2 = (SELECT  
  ColumnID  
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)  
 WHERE ColumnID = 12  
 AND IsActive = 1  
 AND ProjectID = @ProjectID);  
  
 SET @FlexField3 = (SELECT  
  ColumnID  
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)  
 WHERE ColumnID = 13  
 AND IsActive = 1  
 AND ProjectID = @ProjectID);  
  
  SET @FlexField4 = (SELECT  
  ColumnID  
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)  
 WHERE ColumnID = 14  
 AND IsActive = 1  
 AND ProjectID = @ProjectID);  
  
SET @IsCognizant = (SELECT TOP 1  
  C.IsCognizant  
 FROM AVL.Customer C  
 JOIN AVL.MAS_LoginMaster LM  
  ON LM.CustomerID = C.CustomerID  
 WHERE LM.ProjectID = @ProjectID  
 AND LM.EmployeeID = @EmployeeID  
 AND LM.IsDeleted = 0)  
SET @AssigneeName = (SELECT TOP 1  
  LM.EmployeeName  
 FROM DebtReviewTemp DRT  
 JOIN AVL.MAS_LoginMaster LM  
  ON LM.EmployeeID = DRT.Assignee  
 WHERE LM.ProjectID = @ProjectID  
 AND (LM.TSApproverID = @EmployeeID  
 OR LM.HcmSupervisorID = @EmployeeID))  
SET @ApproverName = (SELECT TOP 1  
  LM.EmployeeName  
 FROM AVL.MAS_LoginMaster LM  
 WHERE LM.ProjectID = @ProjectID  
 AND (LM.TSApproverID = @EmployeeID  
 OR LM.HcmSupervisorID = @EmployeeID))  
--SELECT @IsCognizant as IsCog  
UPDATE DR  
SET DR.CauseCodeMapID = CC.CauseID  
FROM DebtReviewTemp DR  
LEFT JOIN AVL.DEBT_MAP_CauseCode CC  
 ON CC.CauseCode = DR.[Cause Code]  
 AND DR.ProjectID = CC.ProjectID  
WHERE DR.ProjectID = @ProjectID  
  
UPDATE DR  
SET DR.ResolutionCodeMapID = RC.ResolutionID  
FROM DebtReviewTemp DR  
LEFT JOIN AVL.DEBT_MAP_ResolutionCode RC  
 ON RC.ResolutionCode = DR.[Resolution Code]  
 AND DR.ProjectID = RC.ProjectID  
WHERE DR.ProjectID = @ProjectID  
  
UPDATE DR  
SET DR.AvoidableFlagID = AF.AvoidableFlagID  
FROM DebtReviewTemp DR  
JOIN AVL.DEBT_MAS_AvoidableFlag AF  
 ON AF.AvoidableFlagName = DR.[Avoidable Flag]  
  
UPDATE DR  
SET DR.DebtClassificationMapID = DC.DebtClassificationID  
FROM DebtReviewTemp DR  
JOIN AVL.DEBT_MAS_DebtClassification DC  
 ON DC.DebtClassificationName = DR.[Debt Category]  
  
UPDATE DR  
SET DR.ResidualDebtMapID = RD.ResidualDebtID  
FROM DebtReviewTemp DR  
JOIN AVL.DEBT_MAS_ResidualDebt RD  
 ON RD.ResidualDebtName = DR.[Residual Debt]  
  
UPDATE DR  
SET DR.NatureoftheTicket = NT.NatureOfTheTicketId  
FROM DebtReviewTemp DR  
JOIN AVL.ITSM_MAS_Natureoftheticket NT  
 ON NT.[Nature Of The Ticket] = DR.[Nature Of The Ticket]  
  
IF EXISTS (SELECT TOP 1  
  tD.IsApproved  
 FROM AVL.TK_TRN_TicketDetail TD  
 JOIN DebtReviewTemp DRT  
  ON TD.TicketID = DRT.TicketID  
 WHERE TD.IsApproved = 1  
 AND TD.ProjectID = DRT.ProjectID) BEGIN  
SET @Result = 'Exists'  
  
END ELSE BEGIN  
SET @Result = 'NotExists'  
END  
  
DECLARE @CCRecipientList NVARCHAR(MAX);  
  
IF (@IsCognizant = 1) BEGIN  
DECLARE @CountOld INT  
DECLARE @CountNew INT  
Declare @cogMail INT  
SELECT DISTINCT  
 TicketID AS TicketID  
 ,[Application Name] AS Application  
 ,[Assignee] AS Assignee  
 ,[Cause Code] AS 'CauseCode'  
 ,[Resolution Code] AS 'ResolutionCode'  
 ,[Debt Category] AS 'DebtClassificationName'  
 ,[Avoidable Flag] AS AvoidableFlagName  
 ,[Service Name] AS ServiceName  
 ,[Residual Debt] AS 'ResidualDebtName'  
 ,[Nature Of The Ticket] AS 'NatureOfTheTicket'  
 ,[KEDB Path] AS KEDBPath  
 ,[FlexField1] AS FlexField1  
 ,[FlexField2] AS FlexField2  
 ,[FlexField3] AS FlexField3  
 ,[FlexField4] AS FlexField4  
  
  INTO #NewData1  
FROM DebtReviewTemp-- WHERE ProjectID=@ProjectID  
  
SELECT DISTINCT  
 TD.TicketID  
 ,AD.ApplicationName AS Application  
 ,LM.EmployeeID AS Assignee  
 ,CC.CauseCode AS 'CauseCode'  
 ,RC.ResolutionCode AS 'ResolutionCode'  
 ,DC.DebtClassificationName AS 'DebtClassificationName'  
 ,AF.AvoidableFlagName  
 ,S.ServiceName  
 ,RD.ResidualDebtName AS 'ResidualDebtName'  
 ,NT.[Nature Of The Ticket] AS 'NatureOfTheTicket'  
 ,TD.KEDBPath   
 ,TD.FlexField1  
 ,TD.FlexField2  
 ,TD.FlexField3  
 ,TD.FlexField4  
  
 INTO #OldData1  
FROM AVL.TK_TRN_TicketDetail TD  
JOIN #NewData1 ND  
 ON TD.TicketID = ND.TicketID  
JOIN AVL.MAS_LoginMaster LM  
 ON LM.UserID = TD.AssignedTo  
LEFT JOIN AVL.DEBT_MAP_CauseCode CC  
 ON TD.CauseCodeMapID = CC.CauseID  
 AND TD.ProjectID = CC.ProjectID  
LEFT JOIN AVL.DEBT_MAP_ResolutionCode RC  
 ON RC.ResolutionID = TD.ResolutionCodeMapID  
 AND TD.ProjectID = RC.ProjectID  
--JOIN AVL.TK_MAP_TicketTypeMapping TTM ON TTM.ProjectID = TD.ProjectID AND TTM.TicketTypeMappingID = TD.TicketTypeMapID  
JOIN AVL.TK_MAS_Service S  
 ON S.ServiceID = TD.ServiceID  
JOIN AVL.APP_MAS_ApplicationDetails AD  
 ON AD.ApplicationID = TD.ApplicationID  
JOIN AVL.APP_MAP_ApplicationProjectMapping APPM  
 ON APPM.ProjectID = TD.ProjectID  
JOIN AVL.DEBT_MAS_DebtClassification DC  
 ON DC.DebtClassificationID = TD.DebtClassificationMapID  
JOIN AVL.DEBT_MAS_ResidualDebt RD  
 ON RD.ResidualDebtID = TD.ResidualDebtMapID  
JOIN AVL.[DEBT_MAS_AvoidableFlag] AF  
 ON AF.AvoidableFlagID = TD.AvoidableFlag  
LEFT JOIN AVL.ITSM_MAS_Natureoftheticket NT  
 ON NT.NatureOfTheTicketId = TD.NatureoftheTicket  
WHERE td.ProjectID = @ProjectID  
SET @CountOld = 0  
  
SELECT  
 A.* INTO #OldData  
FROM (SELECT DISTINCT  
  TicketID  
  ,Application  
  ,Assignee  
  ,CauseCode  
  ,ResolutionCode  
  ,DebtClassificationName  
  ,AvoidableFlagName  
  ,ServiceName  
  ,ResidualDebtName  
  --,ISNULL(NatureOfTheTicket, '') AS NatureOfTheTicket  
  --,ISNULL(KEDBPath, '') AS KEDBPath  
  ,ISNULL(FlexField1, '') AS FlexField1  
  ,ISNULL(FlexField2, '') AS FlexField2  
  ,ISNULL(FlexField3, '') AS FlexField3  
  ,ISNULL(FlexField4, '') AS FlexField4  
  
 FROM #OldData1 EXCEPT SELECT  
  TicketID  
  ,Application  
  ,Assignee  
  ,CauseCode  
  ,ResolutionCode  
  ,DebtClassificationName  
  ,AvoidableFlagName  
  ,ServiceName  
  ,ResidualDebtName  
  --,ISNULL(NatureOfTheTicket, '') AS NatureOfTheTicket  
  --,ISNULL(KEDBPath, '') AS KEDBPath  
  ,ISNULL(FlexField1, '') AS FlexField1  
  ,ISNULL(FlexField2, '') AS FlexField2  
  ,ISNULL(FlexField3, '') AS FlexField3  
  ,ISNULL(FlexField4, '') AS FlexField4  
 FROM #NewData1) AS A  
  
SELECT  
 B.* INTO #NewData  
FROM (SELECT DISTINCT  
  TicketID  
  ,Application  
  ,Assignee  
  ,CauseCode  
  ,ResolutionCode  
  ,DebtClassificationName  
  ,AvoidableFlagName  
  ,ServiceName  
  ,ResidualDebtName  
  --,ISNULL(NatureOfTheTicket, '') AS NatureOfTheTicket  
  --,ISNULL(KEDBPath, '') AS KEDBPath  
  ,ISNULL(FlexField1, '') AS FlexField1  
  ,ISNULL(FlexField2, '') AS FlexField2  
  ,ISNULL(FlexField3, '') AS FlexField3  
  ,ISNULL(FlexField4, '') AS FlexField4  
  
 FROM #NewData1 EXCEPT SELECT  
  TicketID  
  ,Application  
  ,Assignee  
  ,CauseCode  
  ,ResolutionCode  
  ,DebtClassificationName  
  ,AvoidableFlagName  
  ,ServiceName  
  ,ResidualDebtName  
  --,ISNULL(NatureOfTheTicket, '') AS NatureOfTheTicket  
  --,ISNULL(KEDBPath, '') AS KEDBPath  
  ,ISNULL(FlexField1, '') AS FlexField1  
  ,ISNULL(FlexField2, '') AS FlexField2  
  ,ISNULL(FlexField3, '') AS FlexField3  
  ,ISNULL(FlexField4, '') AS FlexField4  
 FROM #OldData1) AS B  
  
 create table #AssigneeEmailTemp(  
 EmployeeEmail varchar(100)  
 )  
 insert into #AssigneeEmailTemp SELECT DISTINCT  
  LM.EmployeeEmail    
 FROM #NewData TempNew  
 JOIN AVL.MAS_LoginMaster LM  
  ON LM.EmployeeID = TempNew.Assignee  
 WHERE LM.ProjectID = @ProjectID  
 AND (LM.TSApproverID = @EmployeeID  
 OR LM.HcmSupervisorID = @EmployeeID)  
  
set @AssigneeEmailName= (SELECT  
  (STUFF((SELECT DISTINCT  
    ';' + RTRIM(LTRIM(EmployeeEmail))  
   FROM #AssigneeEmailTemp  
   FOR XML PATH (''), TYPE)  
  .value('.', 'NVARCHAR(MAX)'), 1, 1, '')) AS ToList)  
  
--CC Lead List  
CREATE TABLE #TSM(CognizantID NVARCHAR(MAX))  
INSERT INTO #TSM  
 SELECT DISTINCT  
  HcmSupervisorID  
 FROM AVL.MAS_LoginMaster  
 WHERE ProjectID = @ProjectID AND EmployeeID IN (SELECT DISTINCT Assignee FROM #NewData)  
 AND IsDeleted = 0  
INSERT INTO #TSM  
 SELECT DISTINCT  
  TSApproverID  
 FROM AVL.MAS_LoginMaster  
 WHERE ProjectID = @ProjectID AND EmployeeID IN (SELECT DISTINCT Assignee FROM #NewData)  
 AND IsDeleted = 0  
  
  
SELECT DISTINCT  
 LM.EmployeeID  
 ,LM.EmployeeName  
 ,LM.EmployeeEmail INTO #Tmp_Mail  
FROM #TSM TS  
INNER JOIN [AVL].[MAS_LoginMaster] LM  
 ON TS.CognizantID = LM.EmployeeID  
WHERE LM.IsDeleted = 0  
  
SET @CCRecipientList = (SELECT  
  (STUFF((SELECT DISTINCT  
    ';' + RTRIM(LTRIM(EmployeeEmail))  
   FROM #Tmp_Mail  
   FOR XML PATH (''), TYPE)  
  .value('.', 'NVARCHAR(MAX)'), 1, 1, '')) AS ToList)  
  
SET @CountOld = (SELECT  
  COUNT(*)  
 FROM #OldData)  
 SET @CountNew = (SELECT  
  COUNT(*)  
 FROM #NewData)  
 if(@CountOld>0 AND @CountNew>0)  
 BEGIN  
 set @cogMail=1  
 END  
END ELSE BEGIN  
DECLARE @CountOldCust INT;  
DECLARE @CountNewCust INT;  
DECLARE @CustMail INT;  
SELECT DISTINCT  
 TicketID  
 ,[Application Name] AS Application  
 ,Assignee AS Assignee  
 ,[Cause Code] AS 'CauseCode'  
 ,[Resolution Code] AS 'ResolutionCode'  
 ,[Debt Category] AS 'DebtClassificationName'  
 ,[Avoidable Flag] AS AvoidableFlagName  
 ,[Residual Debt] AS 'ResidualDebtName'  
 ,[Nature Of The Ticket] AS 'NatureOfTheTicket'  
 ,[KEDB Path] AS KEDBPath  
 ,[Ticket Type] AS 'TicketType'  
 ,FlexField1 AS FlexField1  
 ,FlexField2 AS FlexField2  
 ,FlexField3 AS FlexField3  
 ,FlexField4 AS FlexField4  
   
 INTO #NewDataCust1 FROM DebtReviewTemp  
  
SELECT DISTINCT  
 TD.TicketID  
 ,AD.ApplicationName AS Application  
 ,LM.EmployeeID AS Assignee  
 ,CC.CauseCode AS 'CauseCode'  
 ,RC.ResolutionCode AS 'ResolutionCode'  
 ,DC.DebtClassificationName AS 'DebtClassificationName'  
 ,AF.AvoidableFlagName  
 ,TTM.TicketType AS 'TicketType'  
 ,RD.ResidualDebtName AS 'ResidualDebtName'  
 ,NT.[Nature Of The Ticket] AS 'NatureOfTheTicket'  
 ,TD.KEDBPath  
 ,TD.FlexField1  
 ,TD.FlexField2  
 ,TD.FlexField3  
 ,TD.FlexField4  
  INTO #OldDataCust1 FROM AVL.TK_TRN_TicketDetail TD  
JOIN #NewDataCust1 ND  
 ON TD.TicketID = ND.TicketID  
JOIN AVL.MAS_LoginMaster LM  
 ON LM.UserID = TD.AssignedTo  
LEFT JOIN AVL.DEBT_MAP_CauseCode CC  
 ON TD.CauseCodeMapID = CC.CauseID  
 AND TD.ProjectID = CC.ProjectID  
LEFT JOIN AVL.DEBT_MAP_ResolutionCode RC  
 ON RC.ResolutionID = TD.ResolutionCodeMapID  
 AND TD.ProjectID = RC.ProjectID  
JOIN AVL.TK_MAP_TicketTypeMapping TTM  
 ON TTM.ProjectID = TD.ProjectID  
 AND TTM.TicketTypeMappingID = TD.TicketTypeMapID  
--JOIN AVL.TK_MAS_Service S ON S.ServiceID = TD.ServiceID  
JOIN AVL.APP_MAS_ApplicationDetails AD  
 ON AD.ApplicationID = TD.ApplicationID  
JOIN AVL.APP_MAP_ApplicationProjectMapping APPM  
 ON APPM.ProjectID = TD.ProjectID  
JOIN AVL.DEBT_MAS_DebtClassification DC  
 ON DC.DebtClassificationID = TD.DebtClassificationMapID  
JOIN AVL.DEBT_MAS_ResidualDebt RD  
 ON RD.ResidualDebtID = TD.ResidualDebtMapID  
JOIN AVL.[DEBT_MAS_AvoidableFlag] AF  
 ON AF.AvoidableFlagID = TD.AvoidableFlag  
LEFT JOIN AVL.ITSM_MAS_Natureoftheticket NT  
 ON NT.NatureOfTheTicketId = TD.NatureoftheTicket  
WHERE td.ProjectID = @ProjectID  
  
SELECT  
 A.* INTO #OldDataCust  
FROM (SELECT DISTINCT  
  TicketID  
  ,Application  
  ,Assignee  
  ,CauseCode  
  ,ResolutionCode  
  ,DebtClassificationName  
  ,AvoidableFlagName  
  ,TicketType  
  ,ResidualDebtName  
  --,ISNULL(NatureOfTheTicket, '') AS NatureOfTheTicket  
  --,ISNULL(KEDBPath, '') AS KEDBPath  
  ,ISNULL(FlexField1, '') AS FlexField1  
  ,ISNULL(FlexField2, '') AS FlexField2  
  ,ISNULL(FlexField3, '') AS FlexField3  
  ,ISNULL(FlexField4, '') AS FlexField4  
  
 FROM #OldDataCust1 EXCEPT SELECT  
  TicketID  
  ,Application  
  ,Assignee  
  ,CauseCode  
  ,ResolutionCode  
  ,DebtClassificationName  
  ,AvoidableFlagName  
  ,TicketType  
  ,ResidualDebtName  
  --,ISNULL(NatureOfTheTicket, '') AS NatureOfTheTicket  
  --,ISNULL(KEDBPath, '') AS KEDBPath  
  ,ISNULL(FlexField1, '') AS FlexField1  
  ,ISNULL(FlexField2, '') AS FlexField2  
  ,ISNULL(FlexField3, '') AS FlexField3  
  ,ISNULL(FlexField4, '') AS FlexField4  
 FROM #NewDataCust1) AS A  
-----  
SELECT B.* INTO #NewDataCust  
FROM (SELECT DISTINCT  
  TicketID  
  ,Application  
  ,Assignee  
  ,CauseCode  
  ,ResolutionCode  
  ,DebtClassificationName  
  ,AvoidableFlagName  
  ,TicketType  
  ,ResidualDebtName  
  --,ISNULL(NatureOfTheTicket, '') AS NatureOfTheTicket  
  --,ISNULL(KEDBPath, '') AS KEDBPath  
  ,ISNULL(FlexField1, '') AS FlexField1  
  ,ISNULL(FlexField2, '') AS FlexField2  
  ,ISNULL(FlexField3, '') AS FlexField3  
  ,ISNULL(FlexField4, '') AS FlexField4  
 FROM #NewDataCust1 EXCEPT SELECT  
  TicketID  
  ,Application  
  ,Assignee  
  ,CauseCode  
  ,ResolutionCode  
  ,DebtClassificationName  
  ,AvoidableFlagName  
  ,TicketType  
  ,ResidualDebtName  
  --,ISNULL(NatureOfTheTicket, '') AS NatureOfTheTicket  
  --,ISNULL(KEDBPath, '') AS KEDBPath  
  ,ISNULL(FlexField1, '') AS FlexField1  
  ,ISNULL(FlexField2, '') AS FlexField2  
  ,ISNULL(FlexField3, '') AS FlexField3  
  ,ISNULL(FlexField4, '') AS FlexField4  
 FROM #OldDataCust1) AS B  
  
  
 --select * from #OldDataCust  
 --select * from #NewDataCust  
 --select * from #NewDataCust1  
 --select * from #OldDataCust1  
  
--SELECT  
-- * INTO #OldDataCust  
--FROM #OldDataCust1 EXCEPT SELECT  
-- *  
--FROM #NewDataCust1  
--SELECT  
-- * INTO #NewDataCust  
--FROM #NewDataCust1 EXCEPT SELECT  
-- *  
--FROM #OldDataCust1  
SET @AssigneeEmailName = (SELECT DISTINCT  
  LM.EmployeeEmail  
 FROM #NewDataCust TempNew  
 JOIN AVL.MAS_LoginMaster LM  
  ON LM.EmployeeID = TempNew.Assignee  
 WHERE LM.ProjectID = @ProjectID  
 AND (LM.TSApproverID = @EmployeeID  
 OR LM.HcmSupervisorID = @EmployeeID))  
  
 create table #AssigneeEmailCustTemp(  
 EmployeeEmail varchar(100)  
 )  
 insert into #AssigneeEmailCustTemp SELECT DISTINCT  
  LM.EmployeeEmail  
 FROM #NewDataCust TempNew1  
 JOIN AVL.MAS_LoginMaster LM  
  ON LM.EmployeeID = TempNew1.Assignee  
 WHERE LM.ProjectID = @ProjectID  
 AND (LM.TSApproverID = @EmployeeID  
 OR LM.HcmSupervisorID = @EmployeeID)  
  
set @AssigneeEmailName= (SELECT  
  (STUFF((SELECT DISTINCT  
    ';' + RTRIM(LTRIM(EmployeeEmail))  
   FROM #AssigneeEmailCustTemp  
   FOR XML PATH (''), TYPE)  
  .value('.', 'NVARCHAR(MAX)'), 1, 1, '')) AS ToList)  
  
  --CC Lead List  
CREATE TABLE #TSMCust(CognizantID NVARCHAR(MAX))  
INSERT INTO #TSMCust  
 SELECT DISTINCT  
  HcmSupervisorID  
 FROM AVL.MAS_LoginMaster  
 WHERE ProjectID = @ProjectID AND EmployeeID IN (SELECT DISTINCT Assignee FROM #NewDataCust1)  
 AND IsDeleted = 0  
INSERT INTO #TSMCust  
 SELECT DISTINCT  
  TSApproverID  
 FROM AVL.MAS_LoginMaster  
 WHERE ProjectID = @ProjectID AND EmployeeID IN (SELECT DISTINCT Assignee FROM #NewDataCust1)  
 AND IsDeleted = 0  
  
  
SELECT DISTINCT  
 LM.EmployeeID  
 ,LM.EmployeeName  
 ,LM.EmployeeEmail INTO #Tmp_MailCust  
FROM #TSMCust TS  
INNER JOIN [AVL].[MAS_LoginMaster] LM  
 ON TS.CognizantID = LM.EmployeeID  
WHERE LM.IsDeleted = 0  
  
SET @CCRecipientList = (SELECT  
  (STUFF((SELECT DISTINCT  
    ';' + RTRIM(LTRIM(EmployeeEmail))  
   FROM #Tmp_MailCust  
   FOR XML PATH (''), TYPE)  
  .value('.', 'NVARCHAR(MAX)'), 1, 1, '')) AS ToList)  
  
  
SET @CountOldCust = (SELECT  
  COUNT(*)  
 FROM #OldDataCust)  
  
 SET @CountNewCust = (SELECT  
  COUNT(*)  
 FROM #NewDataCust)  
  
 if(@CountOldCust>0 AND @CountNewCust>0)  
 BEGIN  
 set @CustMail=1  
 END  
END  
  
 /*****************************Multilingual******************************/  
  DECLARE @isMultiLingual INT=0;  
  DECLARE @IsFlexField1 [BIT]=0,  
    @IsFlexField2 [BIT]=0,  
    @IsFlexField3 [BIT]=0,  
    @IsFlexField4 [BIT]=0;  
  
 SELECT @isMultiLingual=1 FROM AVL.MAS_ProjectMaster WITH (NOLOCK) WHERE ProjectID=@ProjectID AND  
 IsDeleted=0 AND IsMultilingualEnabled=1;  
   
 IF(@isMultiLingual=1)  
  BEGIN  
  PRINT 'Inside Multilingual 1';  
  SELECT DISTINCT MCM.ColumnID INTO #Columns FROM AVL.MAS_MultilingualColumnMaster MCM WITH (NOLOCK)   
  JOIN AVL.PRJ_MultilingualColumnMapping MCP WITH(NOLOCK) ON MCM.ColumnID=MCP.ColumnID  
  WHERE MCM.IsActive=1 AND MCP.IsActive=1  
  AND MCP.ProjectID=@ProjectID;  
  
  --SELECT * FROM #Columns;  
    SELECT @IsFlexField1=1 FROM #Columns WHERE ColumnID=7;  
     SELECT @IsFlexField2=1 FROM #Columns WHERE ColumnID=8;  
      SELECT @IsFlexField3=1 FROM #Columns WHERE ColumnID=9;  
       SELECT @IsFlexField4=1 FROM #Columns WHERE ColumnID=10;  
  
    
  SELECT DISTINCT ITD.[TicketID],TD.TimeTickerID,  
   CASE WHEN @IsFlexField1 = 1 AND (ITD.IsFlexField1Modified='1')   
    THEN 1 ELSE 0 END AS 'IsFlexField1Modified',  
   CASE WHEN @IsFlexField2 = 1 AND (ITD.IsFlexField2Modified='1')   
    THEN 1 ELSE 0 END AS 'IsFlexField2Modified',  
   CASE WHEN @IsFlexField3 = 1 AND (ITD.IsFlexField3Modified='1')   
    THEN 1 ELSE 0 END AS 'IsFlexField3Modified',  
   CASE WHEN @IsFlexField4 = 1 AND (ITD.IsFlexField4Modified='1')   
    THEN 1 ELSE 0 END AS 'IsFlexField4Modified'  
  INTO #MultilingualTbl2  
  FROM  DebtReviewTemp ITD JOIN AVL.TK_TRN_TicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[TicketID]   
  AND TD.ProjectID=@ProjectID AND TD.IsDeleted=0;  
  
  
  MERGE [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails] AS TARGET  
  USING #MultilingualTbl2 AS SOURCE  
  ON (Target.TimeTickerID=SOURCE.TimeTickerID)  
  WHEN MATCHED    
  THEN   
  UPDATE SET TARGET.IsFlexField1Updated=(CASE WHEN SOURCE.IsFlexField1Modified=1 THEN 1 ELSE TARGET.IsFlexField1Updated END),  
  TARGET.IsFlexField2Updated=(CASE WHEN SOURCE.IsFlexField2Modified=1 THEN 1 ELSE TARGET.IsFlexField2Updated END),  
  TARGET.IsFlexField3Updated=(CASE WHEN SOURCE.IsFlexField3Modified=1 THEN 1 ELSE TARGET.IsFlexField3Updated END),  
  TARGET.IsFlexField4Updated=(CASE WHEN SOURCE.IsFlexField4Modified=1 THEN 1 ELSE TARGET.IsFlexField4Updated END),  
  TARGET.ModifiedBy=@EmployeeID,  
  TARGET.ModifiedDate=GETDATE(),  
  TARGET.TicketCreatedType=6  
  WHEN NOT MATCHED BY TARGET   
  THEN   
  INSERT (TimeTickerID,IsFlexField1Updated,IsFlexField2Updated,IsFlexField3Updated,  
  IsFlexField4Updated,Isdeleted,CreatedBy,CreatedDate,TicketCreatedType)   
  VALUES (SOURCE.TimeTickerID,SOURCE.IsFlexField1Modified,SOURCE.IsFlexField2Modified,SOURCE.IsFlexField3Modified,  
  SOURCE.IsFlexField4Modified,0,@EmployeeID,GETDATE(),6);  
END  
  
 /**********************************************************************/  
------Master Table Update-----  
UPDATE TTD  
SET TTD.CauseCodeMapID = DRT.CauseCodeMapID  
 ,TTD.ResolutionCodeMapID = DRT.ResolutionCodeMapID  
 ,TTD.DebtClassificationMapID = DRT.DebtClassificationMapID  
 ,TTD.AvoidableFlag = DRT.AvoidableFlagID  
 ,TTD.ResidualDebtMapID = DRT.ResidualDebtMapID  
 ,TTD.NatureoftheTicket = DRT.NatureoftheTicket  
 ,TTD.KEDBPath = DRT.[KEDB Path]  
 ,TTD.IsApproved = 1  
 ,TTD.ModifiedBy = @EmployeeID  
 ,TTD.ModifiedDate = GETDATE()  
 ,TTD.LastUpdatedDate=GETDATE()  
 ,TTD.FlexField1=DRT.FlexField1  
 ,TTD.FlexField2=DRT.FlexField2  
 ,TTD.FlexField3=DRT.FlexField3  
 ,TTD.FlexField4=DRT.FlexField4  
 ,TTD.LastModifiedSource = 9  
  
FROM AVL.TK_TRN_TicketDetail TTD  
JOIN DebtReviewTemp DRT  
 ON TTD.TicketID = DRT.TicketID  
WHERE TTD.ProjectID = @ProjectID  
AND TTD.IsApproved = 0  
OR TTD.IsApproved IS NULL  
  
  
DECLARE @TicketidTemp VARCHAR(MAX)  
DECLARE @ApplicationNameTemp VARCHAR(MAX)  
  
--DECLARE @CountNew INT;  
DECLARE @NewCount INT;  
DECLARE @OldCount INT;  
  
SET @OldCount = 0  
SET @NewCount = 0  
  
  
--SET @CountNew = (SELECT  
--  COUNT(*)  
-- FROM #NewData)  
  
  
  
--SET @ToRecipientList = (Select top 1 EmployeeEmail from AVL.MAS_LoginMaster where EmployeeID=@EmployeeID and ProjectID=@ProjectID and IsDeleted=0)    
  
DECLARE @tableHTML NVARCHAR(MAX)  
SET @Subjecttext = 'Notification for the Overridden Debt values for your Tickets';  
IF (@IsCognizant = 1) BEGIN  
SET @tableHTML = N'<left>    
          <font-weight:normal>  
           Hi all,'  
+ '</BR>'  
+ '&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp'  
+ '</BR>'  
+ '&nbsp;&nbsp&nbsp;&nbsp;&nbsp&nbsp;This is to inform you that the below'  
+ ' debt related fields for the mentioned tickets has been updated by ' + @ApproverName  
+ '.Going further request you to fill in the correct values for the tickets.'  
+ '</BR>'  
+ '</BR>'  
+ '<b><u>Existing Values</u>:</b>'  
+ '</BR></BR>'  
+ '<table border="1" bordercolor="black">'  
+ '<thead  style="background-color:#001a66;">'  
+ '<tr>'  
+ '<th align=center><b><font color="white">Service</font></b></th>'  
--+'<th align=center><b><font color="white">Ticket Type</font></b></th>'   
+ '<th align=center><b><font color="white">Ticket ID</font></b></th>'  
+ '<th align=center><b><font color="white">Assignee</font></b></th>'  
+ '<th align=center><b><font color="white">Application</font></b></th>'  
+ '<th align=center><b><font color="white">Debt Classification</font></b></th>'  
+ '<th align=center><b><font color="white">Residual Debt</font></b></th>'  
+ '<th align=center><b><font color="white">Avoidable Flag</font></b></th>'  
+ '<th align=center><b><font color="white">Resolution Code</font></b></th>'  
+ '<th align=center><b><font color="white">Cause Code</font></b></th>'  
  
--IF (@NatureOfTheTicket > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">Nature Of The Ticket</font></b></th>'  
--END  
--IF (@KEDBPath > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">KEDB Path</font></b></th>'  
--END  
  
IF (@FlexField1 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField1</font></b></th>'  
END  
IF (@FlexField2 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField2</font></b></th>'  
END  
IF (@FlexField3 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField3</font></b></th>'  
END  
IF (@FlexField4 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField4</font></b></th>'  
END  
  
SET @tableHTML = @tableHTML + '</thead>'  
+ '<tbody>'  
  
WHILE (@CountOld>0) BEGIN  
SET @tableHTML = @tableHTML + '<tr>'  
+ '<td>' + (SELECT TOP 1  
  (ServiceName)  
 FROM #OldData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (TicketID)  
 FROM #OldData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (Assignee)  
 FROM #OldData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (Application)  
 FROM #OldData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (DebtClassificationName)  
 FROM #OldData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (ResidualDebtName)  
 FROM #OldData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (AvoidableFlagName)  
 FROM #OldData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (ResolutionCode)  
 FROM #OldData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (CauseCode)  
 FROM #OldData)  
+ '</td>'  
  
--IF (@NatureOfTheTicket > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
--  ([NatureOfTheTicket])  
-- FROM #OldData)  
--+ '</td>'  
--END  
--IF (@KEDBPath > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
--  ([KEDBPath])  
-- FROM #OldData)  
--+ '</td>'  
--END  
IF (@FlexField1 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField1])  
 FROM #OldData)  
+ '</td>'  
END  
IF (@FlexField2 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField2])  
 FROM #OldData)  
+ '</td>'  
END  
IF (@FlexField3 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField3])  
 FROM #OldData)  
+ '</td>'  
END  
IF (@FlexField4 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField3])  
 FROM #OldData)  
+ '</td>'  
END  
  
SET @tableHTML = @tableHTML + '</tr>'  
SET @TicketidTemp = (SELECT TOP 1  
  (TicketID)  
 FROM #OldData)  
SET @ApplicationNameTemp = (SELECT TOP 1  
  (Application)  
 FROM #OldData)  
DELETE FROM #OldData  
WHERE TicketID = @TicketidTemp  
 AND Application = @ApplicationNameTemp  
SET @CountOld = (SELECT  
  COUNT(*)  
 FROM #OldData)  
SET @OldCount = 1  
END  
SET @tableHTML = @tableHTML + '</tbody>'  
+ '</table>'  
+ '</BR>'  
+ '<b><u>Revised Values</u>:</b>'  
+ '</BR></BR>'  
+ '<table border="1" bordercolor="black">'  
+ '<thead  style="background-color:#001a66;">'  
+ '<tr>'  
+ '<th align=center><b><font color="white">Service</font></b></th>'  
--+'<th align=center><b><font color="white">Ticket Type</font></b></th>'   
+ '<th align=center><b><font color="white">Ticket ID</font></b></th>'  
+ '<th align=center><b><font color="white">Assignee</font></b></th>'  
+ '<th align=center><b><font color="white">Application</font></b></th>'  
+ '<th align=center><b><font color="white">Debt Classification</font></b></th>'  
+ '<th align=center><b><font color="white">Residual Debt</font></b></th>'  
+ '<th align=center><b><font color="white">Avoidable Flag</font></b></th>'  
+ '<th align=center><b><font color="white">Resolution Code</font></b></th>'  
+ '<th align=center><b><font color="white">Cause Code</font></b></th>'  
  
--IF (@NatureOfTheTicket > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">Nature Of The Ticket</font></b></th>'  
--END  
--IF (@KEDBPath > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">KEDB Path</font></b></th>'  
--END  
  
IF (@FlexField1 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField1</font></b></th>'  
END  
IF (@FlexField2 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField2</font></b></th>'  
END  
IF (@FlexField3 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField3</font></b></th>'  
END  
IF (@FlexField4 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField4</font></b></th>'  
END  
  
SET @tableHTML = @tableHTML + '</thead>'  
+ '<tbody>'  
  
WHILE (@CountNew>0) BEGIN  
SET @tableHTML = @tableHTML + '<tr>'  
+ '<td>' + (SELECT TOP 1  
  ([ServiceName])  
 FROM #NewData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (TicketID)  
 FROM #NewData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (Assignee)  
 FROM #NewData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([Application])  
 FROM #NewData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([DebtClassificationName])  
 FROM #NewData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([ResidualDebtName])  
 FROM #NewData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([AvoidableFlagName])  
 FROM #NewData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([ResolutionCode])  
 FROM #NewData)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([CauseCode])  
 FROM #NewData)  
+ '</td>'  
  
--IF (@NatureOfTheTicket > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
--  ([NatureOfTheTicket])  
-- FROM #NewData)  
--+ '</td>'  
--END  
--IF (@KEDBPath > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
--  ([KEDBPath])  
-- FROM #NewData)  
--+ '</td>'  
--END  
  
IF (@FlexField1 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField1])  
 FROM #NewData)  
+ '</td>'  
END  
IF (@FlexField2 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField2])  
 FROM #NewData)  
+ '</td>'  
END  
  
IF (@FlexField3 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField3])  
 FROM #NewData)  
+ '</td>'  
END  
IF (@FlexField4 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField4])  
 FROM #NewData)  
+ '</td>'  
END  
  
SET @tableHTML = @tableHTML + '</tr>'  
SET @TicketidTemp = (SELECT TOP 1  
  (TicketID)  
 FROM #NewData)  
SET @ApplicationNameTemp = (SELECT TOP 1  
  ([Application])  
 FROM #NewData)  
DELETE FROM #NewData  
WHERE TicketID = @TicketidTemp  
 AND [Application] = @ApplicationNameTemp  
SET @CountNew = (SELECT  
  COUNT(*)  
 FROM #NewData)  
SET @NewCount = 1  
END  
SET @tableHTML = @tableHTML + '</tbody>'  
+ '</table>'  
  
+ '</Left>'  
+  
N'  
          
        <p align="left">    
        <font color="Black" face="Arial" Size = "2">    
         PS :This is system generated mail,please do not reply to this mail.<br /><br>    
          Regards,<br />    
          Solution Zone Team   
         </font>    
       </p>';  
END ELSE BEGIN  
SET @tableHTML = N'<left>    
          <font-weight:normal>  
           Hi ' + @AssigneeName + ','  
+ '</BR>'  
+ '&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp'  
+ '</BR>'  
+ '&nbsp;&nbsp&nbsp;&nbsp;&nbsp&nbsp;This is to inform you that the below'  
+ ' debt related fields for the mentioned tickets has been updated by ' + @ApproverName  
+ '.Going further request you to fill in the correct values for the tickets.'  
+ '</BR>'  
+ '</BR>'  
+ '<b><u>Existing Values</u>:</b>'  
+ '</BR></BR>'  
+ '<table border="1" bordercolor="black">'  
+ '<thead  style="background-color:#001a66;">'  
+ '<tr>'  
--+ '<th align=center><b><font color="white">Service</font></b></th>'   
+ '<th align=center><b><font color="white">Ticket Type</font></b></th>'  
+ '<th align=center><b><font color="white">Ticket ID</font></b></th>'  
+ '<th align=center><b><font color="white">Assignee</font></b></th>'  
+ '<th align=center><b><font color="white">Application</font></b></th>'  
+ '<th align=center><b><font color="white">Debt Classification</font></b></th>'  
+ '<th align=center><b><font color="white">Residual Debt</font></b></th>'  
+ '<th align=center><b><font color="white">Avoidable Flag</font></b></th>'  
+ '<th align=center><b><font color="white">Resolution Code</font></b></th>'  
+ '<th align=center><b><font color="white">Cause Code</font></b></th>'  
  
IF (@NatureOfTheTicket > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">Nature Of The Ticket</font></b></th>'  
END  
IF (@KEDBPath > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">KEDB Path</font></b></th>'  
END  
  
SET @tableHTML = @tableHTML + '</thead>'  
+ '<tbody>'  
  
WHILE (@CountOldCust>0) BEGIN  
SET @tableHTML = @tableHTML + '<tr>'  
+ '<td>' + (SELECT TOP 1  
  (TicketType)  
 FROM #OldDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (TicketID)  
 FROM #OldDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (Assignee)  
 FROM #OldDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (Application)  
 FROM #OldDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (DebtClassificationName)  
 FROM #OldDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (ResidualDebtName)  
 FROM #OldDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (AvoidableFlagName)  
 FROM #OldDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (ResolutionCode)  
 FROM #OldDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (CauseCode)  
 FROM #OldDataCust)  
+ '</td>'  
  
--IF (@NatureOfTheTicket > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
--  ([NatureOfTheTicket])  
-- FROM #OldDataCust)  
--+ '</td>'  
--END  
--IF (@KEDBPath > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
--  ([KEDBPath])  
-- FROM #OldDataCust)  
--+ '</td>'  
--END  
  
IF (@FlexField1 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField1])  
 FROM #OldDataCust)  
+ '</td>'  
END  
IF (@FlexField2 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField2])  
 FROM #OldDataCust)  
+ '</td>'  
END  
IF (@FlexField3 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField3])  
 FROM #OldDataCust)  
+ '</td>'  
END  
IF (@FlexField4 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField4])  
 FROM #OldDataCust)  
+ '</td>'  
END  
  
SET @tableHTML = @tableHTML + '</tr>'  
SET @TicketidTemp = (SELECT TOP 1  
  (TicketID)  
 FROM #OldDataCust)  
SET @ApplicationNameTemp = (SELECT TOP 1  
  ([Application])  
 FROM #OldDataCust)  
DELETE FROM #OldDataCust  
WHERE TicketID = @TicketidTemp  
 AND [Application] = @ApplicationNameTemp  
SET @CountOldCust = (SELECT  
  COUNT(*)  
 FROM #OldDataCust)  
SET @OldCount = 1  
END  
SET @tableHTML = @tableHTML + '</tbody>'  
+ '</table>'  
+ '</BR>'  
+ '<b><u>Revised Values</u>:</b>'  
+ '</BR></BR>'  
+ '<table border="1" bordercolor="black">'  
+ '<thead  style="background-color:#001a66;">'  
+ '<tr>'  
--+ '<th align=center><b><font color="white">Service</font></b></th>'   
+ '<th align=center><b><font color="white">Ticket Type</font></b></th>'  
+ '<th align=center><b><font color="white">Ticket ID</font></b></th>'  
+ '<th align=center><b><font color="white">Assignee</font></b></th>'  
+ '<th align=center><b><font color="white">Application</font></b></th>'  
+ '<th align=center><b><font color="white">Debt Classification</font></b></th>'  
+ '<th align=center><b><font color="white">Residual Debt</font></b></th>'  
+ '<th align=center><b><font color="white">Avoidable Flag</font></b></th>'  
+ '<th align=center><b><font color="white">Resolution Code</font></b></th>'  
+ '<th align=center><b><font color="white">Cause Code</font></b></th>'  
  
--IF (@NatureOfTheTicket > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">Nature Of The Ticket</font></b></th>'  
--END  
--IF (@KEDBPath > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">KEDB Path</font></b></th>'  
--END  
  
IF (@FlexField1 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField1</font></b></th>'  
END  
IF (@FlexField2 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField2</font></b></th>'  
END  
IF (@FlexField3 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField3</font></b></th>'  
END  
IF (@FlexField4 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">FlexField14</font></b></th>'  
END  
  
SET @tableHTML = @tableHTML + '</thead>'  
+ '<tbody>'  
  
WHILE (@CountNewCust > 0) BEGIN  
SET @tableHTML = @tableHTML + '<tr>'  
+ '<td>' + (SELECT TOP 1  
  ([TicketType])  
 FROM #NewDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (TicketID)  
 FROM #NewDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  (Assignee)  
 FROM #NewDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([Application])  
 FROM #NewDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([DebtClassificationName])  
 FROM #NewDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([ResidualDebtName])  
 FROM #NewDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([AvoidableFlagName])  
 FROM #NewDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([ResolutionCode])  
 FROM #NewDataCust)  
+ '</td>'  
+ '<td>' + (SELECT TOP 1  
  ([CauseCode])  
 FROM #NewDataCust)  
+ '</td>'  
  
--IF (@NatureOfTheTicket > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
--  ([NatureOfTheTicket])  
-- FROM #NewDataCust)  
--+ '</td>'  
--END  
--IF (@KEDBPath > 0) BEGIN  
--SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
--  ([KEDBPath])  
-- FROM #NewDataCust)  
--+ '</td>'  
--END  
IF (@FlexField1 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  (FlexField1)  
 FROM #NewDataCust)  
+ '</td>'  
END  
IF (@FlexField2 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField2])  
 FROM #NewDataCust)  
+ '</td>'  
END  
IF (@FlexField3 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField3])  
 FROM #NewDataCust)  
+ '</td>'  
END  
IF (@FlexField4 > 0) BEGIN  
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1  
  ([FlexField4])  
 FROM #NewDataCust)  
+ '</td>'  
END  
  
SET @tableHTML = @tableHTML + '</tr>'  
SET @TicketidTemp = (SELECT TOP 1  
  (TicketID)  
 FROM #NewDataCust)  
SET @ApplicationNameTemp = (SELECT TOP 1  
  ([Application])  
 FROM #NewDataCust)  
DELETE FROM #NewDataCust  
WHERE TicketID = @TicketidTemp  
 AND [Application] = @ApplicationNameTemp  
SET @CountNewCust = (SELECT  
  COUNT(*)  
 FROM #NewDataCust)  
SET @NewCount = 1  
END  
SET @tableHTML = @tableHTML + '</tbody>'  
+ '</table>'  
  
+ '</Left>'  
+  
N'  
          
        <p align="left">    
        <font color="Black" face="Arial" Size = "2">    
         PS :This is system generated mail,please do not reply to this mail.<br /><br>    
          Regards,<br />    
          Solution Zone Team
         </font>    
       </p>';  
END  
SELECT  
 @tableHTML;  
IF (@CustMail =1 OR @CogMail =1)  
 BEGIN  
 EXEC [AVL].[SendDBEmail] @To=@AssigneeEmailName,
    @From='ApplensSupport@cognizant.com',
    @Subject =@Subjecttext,
    @Body = @tableHTML,
	@CC=@CCRecipientList
 
  
END  
IF (@IsCognizant = 1) BEGIN  
DROP TABLE #OldData  
DROP TABLE #NewData  
DROP TABLE #OldData1  
DROP TABLE #NewData1  
END ELSE BEGIN  
DROP TABLE #OldDataCust  
DROP TABLE #NewDataCust  
DROP TABLE #NewDataCust1  
DROP TABLE #OldDataCust1  
END  
--DROP TABLE #NewData  
TRUNCATE TABLE DebtReviewTemp  
SET @MinCount = @MinCount + 1  
  
SELECT  
 @Result AS Result  
SET NOCOUNT OFF;  
COMMIT TRAN  
END TRY BEGIN CATCH  
  
DECLARE @ErrorMessage VARCHAR(MAX);  
  
SELECT  
 @ErrorMessage = ERROR_MESSAGE()  
PRINT @ErrorMessage  
TRUNCATE TABLE DebtReviewTemp  
ROLLBACK TRAN  
--INSERT Error      
EXEC AVL_InsertError '[AVL].[UploadAndUpdateDebtReviewAlgoTwo]'  
      ,@ErrorMessage  
      ,0  
  
END CATCH  
END


