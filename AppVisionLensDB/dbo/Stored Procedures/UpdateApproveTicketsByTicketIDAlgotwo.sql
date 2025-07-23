
    
/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
-- declare @ticketDetails UpdateApproveTicketList    
-- insert into @ticketDetails(TicketID,DebtClassificationMapID,ResolutionCodeMapID,ResidualDebtMapID,CauseCodeMapID,AvoidableFlag,AssignedTo,    
--EmployeeID,FlexField1,FlexField2,FlexField3,FlexField4,IsFlexField1Modified,IsFlexField2Modified,IsFlexField3Modified,IsFlexField4Modified)    
--values('test06242019',1,2,2,2,2,'687591','687591','El servicio gratuito de Applens traduce instantáneamente palabras, frases y páginas web entre el inglés y más de 100 idiomas diferentes.',    
--'try','ytry','El servicio gratuito de Applens traduce instantáneamente palabras, frases y páginas web entre el inglés y más de 100 idiomas diferentes.','1','0','0','1')    
--EXEC [dbo].[UpdateApproveTicketsByTicketID] '687591',10337,@ticketDetails    
CREATE PROCEDURE [dbo].[UpdateApproveTicketsByTicketIDAlgotwo]     
(    
@EmployeeID Varchar(100),    
@ProjectID BigInt,    
@ticketDetails UpdateApproveTicketList READONLY    
)    
AS    
BEGIN    
BEGIN TRY    
BEGIN TRAN    
SET NOCOUNT ON;      
DECLARE @result bit    
--DECLARE @NatureOfTheTicket INT;    
--DECLARE @KEDBPath VARCHAR(500);    
DECLARE @FlexField1 VARCHAR(500);    
DECLARE @FlexField2 VARCHAR(500);    
DECLARE @FlexField3 VARCHAR(500);    
DECLARE @FlexField4 VARCHAR(500);    
DECLARE @FlexField1ProjectName VARCHAR(500);    
DECLARE @FlexField2ProjectName VARCHAR(500);    
DECLARE @FlexField3ProjectName VARCHAR(500);    
DECLARE @FlexField4ProjectName VARCHAR(500);    
DECLARE @TicketidTemp VARCHAR(MAX)    
DECLARE @ApplicationNameTemp VARCHAR(MAX)    
DECLARE @AssigneeName NVARCHAR(100)    
DECLARE @ApproverName NVARCHAR(100)    
DECLARE @userID BIGINT    
DECLARE @tableHTML NVARCHAR(MAX);    
DECLARE @Subjecttext VARCHAR(MAX);    
DECLARE @MinCount INT    
DECLARE @MaxCount INT    
DECLARE @AssigneeEmailName VARCHAR(MAX);    
DECLARE @CCRecipientList NVARCHAR(MAX);    
DECLARE @IsCognizant INT;    
DECLARE @NewCount INT;    
DECLARE @OldCount INT;    
    
SET @OldCount = 0    
SET @NewCount = 0    
SET @FlexField1 = (SELECT    
  ColumnID    
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)    
 WHERE ColumnID = 11    
 AND IsActive = 1    
 AND ProjectID = @ProjectID);    
    
SET @FlexField1ProjectName = (SELECT    
  ProjectColumn    
 FROM AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK)    
 WHERE ServiceDartColumn = 'Flex Field (1)'    
 AND IsDeleted = 0    
 AND ProjectID = @ProjectID);    
    
SET @FlexField2 = (SELECT    
  ColumnID    
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)    
 WHERE ColumnID = 12    
 AND IsActive = 1    
 AND ProjectID = @ProjectID);    
    
SET @FlexField2ProjectName = (SELECT    
  ProjectColumn    
 FROM AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK)    
 WHERE ServiceDartColumn = 'Flex Field (2)'    
 AND IsDeleted = 0    
 AND ProjectID = @ProjectID);    
    
SET @FlexField3 = (SELECT    
  ColumnID    
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)    
 WHERE ColumnID = 13    
 AND IsActive = 1    
 AND ProjectID = @ProjectID);    
    
SET @FlexField3ProjectName = (SELECT    
  ProjectColumn    
 FROM AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK)    
 WHERE ServiceDartColumn = 'Flex Field (3)'    
 AND IsDeleted = 0    
 AND ProjectID = @ProjectID);    
    
SET @FlexField4 = (SELECT    
  ColumnID    
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)    
 WHERE ColumnID = 14    
 AND IsActive = 1    
 AND ProjectID = @ProjectID);    
    
SET @FlexField4ProjectName = (SELECT    
  ProjectColumn    
 FROM AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK)    
 WHERE ServiceDartColumn = 'Flex Field (4)'    
 AND IsDeleted = 0    
 AND ProjectID = @ProjectID);    
    
SET @IsCognizant = (SELECT TOP 1 C.IsCognizant FROM AVL.Customer C (NOLOCK) JOIN AVL.MAS_LoginMaster LM (NOLOCK) ON LM.CustomerID = C.CustomerID    
 WHERE LM.ProjectID = @ProjectID AND LM.EmployeeID = @EmployeeID AND LM.IsDeleted = 0)    
SET @AssigneeName = (SELECT TOP 1 LM.EmployeeName FROM DebtReviewTemp DRT (NOLOCK) JOIN AVL.MAS_LoginMaster LM (NOLOCK) ON LM.EmployeeID = DRT.Assignee    
WHERE LM.ProjectID = @ProjectID AND (LM.TSApproverID = @EmployeeID OR LM.HcmSupervisorID = @EmployeeID))    
SET @ApproverName = (SELECT TOP 1 LM.EmployeeName FROM AVL.MAS_LoginMaster LM (NOLOCK) WHERE LM.ProjectID = @ProjectID AND (LM.TSApproverID = @EmployeeID    
 OR LM.HcmSupervisorID = @EmployeeID))    
-----------------------------------------------------Cognizant Scenario Start----------------------------------------------------------------------    
IF (@IsCognizant = 1) BEGIN    
DECLARE @CountOld INT    
DECLARE @CountNew INT    
Declare @cogMail INT    
-------------------------------------------------------------- Cognizant new Data start------------------------------------------------------------------------    
 SELECT DISTINCT    
 AD.ApplicationName AS Application    
 ,LM.UserID AS AssigneeUserID    
 ,CC.CauseCode AS 'CauseCode'    
 ,RC.ResolutionCode AS 'ResolutionCode'    
 ,DC.DebtClassificationName AS 'DebtClassificationName'    
 ,AF.AvoidableFlagName    
 ,RD.ResidualDebtName AS 'ResidualDebtName'    
 --,ISNULL(NT.[Nature Of The Ticket], '') AS NatureOfTheTicketName    
 --,NT.[Nature Of The Ticket] AS 'NatureOfTheTicketName'    
 ,S.ServiceName    
 --,TD.KEDBPath    
 ,TD.TicketID    
 ,TD.DebtClassificationMapID    
 ,ISNULL(TD.ResolutionCodeMapID,0) AS ResolutionCodeMapID    
 ,ISNULL(TD.CauseCodeMapID,0) AS CauseCodeMapID    
 ,TD.ResidualDebtMapID    
 ,TD.AvoidableFlag     
 ,TD.AssignedTo    
 --,IIF(TD.NatureoftheTicket=0,'', CONVERT(varchar(10), TD.NatureoftheTicket)) as NatureoftheTicket    
 --,TD.KEDBPath,    
 ,TD.FlexField1    
 ,TD.FlexField2    
 ,TD.FlexField3    
 ,TD.FlexField4    
 ,TD.IsFlexField1Modified    
 ,TD.IsFlexField2Modified    
 ,TD.IsFlexField3Modified    
 ,TD.IsFlexField4Modified    
    INTO #NewData1  FROM @ticketDetails TD    
JOIN AVL.MAS_LoginMaster LM (NOLOCK)     
 ON LM.EmployeeID = TD.AssignedTo    
LEFT JOIN AVL.DEBT_MAP_CauseCode CC (NOLOCK)     
 ON TD.CauseCodeMapID = CC.CauseID    
 AND CC.ProjectID=@ProjectID    
LEFT JOIN AVL.DEBT_MAP_ResolutionCode RC (NOLOCK)     
 ON RC.ResolutionID = TD.ResolutionCodeMapID    
 AND  RC.ProjectID=@ProjectID    
JOIN AVL.TK_TRN_TicketDetail TRD (NOLOCK)  ON TRD.TicketID=TD.TicketID AND TRD.ProjectID=@ProjectID    
JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK)  ON AD.ApplicationID = TRD.ApplicationID    
JOIN AVL.APP_MAP_ApplicationProjectMapping APPM (NOLOCK)  ON APPM.ProjectID = @ProjectID    
JOIN AVL.TK_MAS_Service S (NOLOCK)  ON S.ServiceID = TRD.ServiceID    
JOIN AVL.DEBT_MAS_DebtClassification DC (NOLOCK)     
 ON DC.DebtClassificationID = TD.DebtClassificationMapID    
JOIN AVL.DEBT_MAS_ResidualDebt RD (NOLOCK)     
 ON RD.ResidualDebtID = TD.ResidualDebtMapID    
JOIN AVL.[DEBT_MAS_AvoidableFlag] AF (NOLOCK)     
 ON AF.AvoidableFlagID = TD.AvoidableFlag    
--LEFT JOIN AVL.ITSM_MAS_Natureoftheticket NT    
-- ON NT.NatureOfTheTicketId = TD.NatureoftheTicket    
-------------------------------------------------------------- Cognizant new Data end------------------------------------------------------------------------    
-------------------------------------------------------------- Cognizant Old Data start------------------------------------------------------------------------     
 SELECT DISTINCT    
 TD.TicketID    
 ,AD.ApplicationName AS Application    
 ,TD.AssignedTo AS AssigneeUserID    
 ,CC.CauseCode AS 'CauseCode'    
 ,RC.ResolutionCode AS 'ResolutionCode'    
 ,DC.DebtClassificationName AS 'DebtClassificationName'    
 ,AF.AvoidableFlagName    
 ,S.ServiceName    
 ,RD.ResidualDebtName AS 'ResidualDebtName'    
 --,ISNULL(NT.[Nature Of The Ticket], '') AS NatureOfTheTicket    
 --,NT.[Nature Of The Ticket] AS 'NatureOfTheTicketName'    
 --,TD.KEDBPath    
 ,TD.FlexField1    
 ,TD.FlexField2    
 ,TD.FlexField3    
 ,TD.FlexField4    
 ,ND.IsFlexField1Modified    
 ,ND.IsFlexField2Modified    
 ,ND.IsFlexField3Modified    
 ,ND.IsFlexField4Modified     
 ,LM.EmployeeID as AssignedTo INTO #OldData1    
FROM AVL.TK_TRN_TicketDetail TD (NOLOCK)    
JOIN #NewData1 ND (NOLOCK)    
 ON TD.TicketID = ND.TicketID    
JOIN AVL.MAS_LoginMaster LM (NOLOCK)    
 ON LM.UserID = TD.AssignedTo    
LEFT JOIN AVL.DEBT_MAP_CauseCode CC (NOLOCK)    
 ON TD.CauseCodeMapID = CC.CauseID    
 AND TD.ProjectID = CC.ProjectID    
LEFT JOIN AVL.DEBT_MAP_ResolutionCode RC (NOLOCK)    
 ON RC.ResolutionID = TD.ResolutionCodeMapID    
 AND TD.ProjectID = RC.ProjectID    
--JOIN AVL.TK_MAP_TicketTypeMapping TTM ON TTM.ProjectID = TD.ProjectID AND TTM.TicketTypeMappingID = TD.TicketTypeMapID    
JOIN AVL.TK_MAS_Service S (NOLOCK)    
 ON S.ServiceID = TD.ServiceID    
JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK)    
 ON AD.ApplicationID = TD.ApplicationID    
JOIN AVL.APP_MAP_ApplicationProjectMapping APPM (NOLOCK)    
 ON APPM.ProjectID = TD.ProjectID    
JOIN AVL.DEBT_MAS_DebtClassification DC (NOLOCK)    
 ON DC.DebtClassificationID = TD.DebtClassificationMapID    
JOIN AVL.DEBT_MAS_ResidualDebt RD (NOLOCK)    
 ON RD.ResidualDebtID = TD.ResidualDebtMapID    
JOIN AVL.[DEBT_MAS_AvoidableFlag] AF (NOLOCK)    
 ON AF.AvoidableFlagID = TD.AvoidableFlag    
--LEFT JOIN AVL.ITSM_MAS_Natureoftheticket NT    
-- ON NT.NatureOfTheTicketId = TD.NatureoftheTicket    
WHERE TD.ProjectID = @ProjectID    
-------------------------------------------------------------- Cognizant Old Data end------------------------------------------------------------------------    
---------------------------------------------------------------Mail Data for cognizant start---------------------------------------------------------------    
SELECT DISTINCT    
 A.* INTO #OldData    
FROM (SELECT DISTINCT    
  TicketID    
  ,Application    
  ,AssignedTo    
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
  ,AssignedTo    
  ,CauseCode    
  ,ResolutionCode    
  ,DebtClassificationName    
  ,AvoidableFlagName    
  ,ServiceName    
  ,ResidualDebtName    
  --,ISNULL(NatureOfTheTicketName, '') AS NatureOfTheTicket    
  --,ISNULL(KEDBPath, '') AS KEDBPath    
  ,ISNULL(FlexField1, '') AS FlexField1    
  ,ISNULL(FlexField2, '') AS FlexField2    
  ,ISNULL(FlexField3, '') AS FlexField3    
  ,ISNULL(FlexField4, '') AS FlexField4    
 FROM #NewData1) AS A    
    
SELECT DISTINCT    
 B.* INTO #NewData    
FROM (SELECT DISTINCT    
  TicketID    
  ,Application    
  ,AssignedTo    
  ,CauseCode    
  ,ResolutionCode    
  ,DebtClassificationName    
  ,AvoidableFlagName    
  ,ServiceName    
  ,ResidualDebtName    
  --,ISNULL(NatureOfTheTicketName, '') AS NatureOfTheTicket    
  --,ISNULL(KEDBPath, '') AS KEDBPath    
  ,ISNULL(FlexField1, '') AS FlexField1    
  ,ISNULL(FlexField2, '') AS FlexField2    
  ,ISNULL(FlexField3, '') AS FlexField3    
  ,ISNULL(FlexField4, '') AS FlexField4    
 FROM #NewData1 EXCEPT SELECT    
  TicketID    
  ,Application    
  ,AssignedTo    
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
---------------------------------------------------------------Mail Data for cognizant end---------------------------------------------------------------    
-----------------------------------------------------Cognizant To and CC List Start---------------------------------------------------    
create table #AssigneeEmailTemp(    
 EmployeeEmail varchar(100)    
 )    
 insert into #AssigneeEmailTemp SELECT DISTINCT    
  LM.EmployeeEmail      
 FROM #NewData TempNew    
 JOIN AVL.MAS_LoginMaster LM    
  ON LM.EmployeeID = TempNew.AssignedTo    
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
 WHERE ProjectID = @ProjectID AND EmployeeID IN (SELECT DISTINCT AssignedTo FROM #NewData)    
 AND IsDeleted = 0    
INSERT INTO #TSM    
 SELECT DISTINCT    
  TSApproverID    
 FROM AVL.MAS_LoginMaster    
 WHERE ProjectID = @ProjectID AND EmployeeID IN (SELECT DISTINCT AssignedTo FROM #NewData)    
 AND IsDeleted = 0    
    
    
SELECT DISTINCT    
 LM.EmployeeID    
 ,LM.EmployeeName    
 ,LM.EmployeeEmail INTO #Tmp_Mail    
FROM #TSM TS (NOLOCK)    
INNER JOIN [AVL].[MAS_LoginMaster] LM (NOLOCK)    
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
 --select * from #OldData    
 --select * from #NewData    
 --select * from #OldData1    
 --select * from #NewData1    
     
 SET @Subjecttext = 'Notification for the Overridden Debt values for your Tickets';    
     
-----------------------------------------------------Cognizant To and CC List End---------------------------------------------------    
-----------------------------------------------------Cognizant Mail Body Start--------------------------------------------------------------------------------    
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
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField1ProjectName +'</font></b></th>'    
END    
IF (@FlexField2 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField2ProjectName +'</font></b></th>'    
END    
IF (@FlexField3 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField3ProjectName +'</font></b></th>'    
END    
IF (@FlexField4 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField4ProjectName +'</font></b></th>'    
END    
SET @tableHTML = @tableHTML + '</thead>'    
+ '<tbody>'    
    
WHILE (@CountOld>0) BEGIN    
SET @tableHTML = @tableHTML + '<tr>'    
+ '<td>' + (SELECT TOP 1(ServiceName) FROM #OldData)+ '</td>'    
+ '<td>' + (SELECT TOP 1(TicketID) FROM #OldData)+'</td>'    
+ '<td>' + (SELECT TOP 1(AssignedTo) FROM #OldData)+ '</td>'    
+ '<td>' + (SELECT TOP 1(Application) FROM #OldData)+ '</td>'    
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
  ([FlexField4])    
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
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField1ProjectName +'</font></b></th>'    
END    
IF (@FlexField2 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField2ProjectName +'</font></b></th>'    
END    
IF (@FlexField3 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField3ProjectName +'</font></b></th>'    
END    
IF (@FlexField4 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField4ProjectName +'</font></b></th>'    
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
  (AssignedTo)    
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
+ '<td>' + (SELECT TOP 1([CauseCode])    
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
+N'    
            
        <p align="left">      
        <font color="Black" face="Arial" Size = "2">      
         PS :This is system generated mail,please do not reply to this mail.<br /><br>      
          Regards,<br />      
          Solution Zone Support      
         </font>      
       </p>';    
          
    
-----------------------------------------------------Cognizant Mail Body End  ---------------------------------------------------------------------------    
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
  FROM  #NewData1 ITD (NOLOCK) JOIN AVL.TK_TRN_TicketDetail TD  (NOLOCK) ON TD.TicketID=ITD.[TicketID]     
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
  INSERT (TimeTickerID,IsTicketDescriptionUpdated,IsResolutionRemarksUpdated,IsTicketSummaryUpdated,    
  IsCommentsUpdated,Isdeleted,CreatedBy,CreatedDate,TicketCreatedType)     
  VALUES (SOURCE.TimeTickerID,0,0,0,0,0,@EmployeeID,GETDATE(),6);    
END    
    
 /**********************************************************************/    
    
 SET @userID =(SELECT top 1 LM.UserID FROM AVL.MAS_LoginMaster LM (NOLOCK) JOIN #NewData1 N (NOLOCK) ON Lm.EmployeeID=N.AssignedTo AND Lm.ProjectID=@ProjectID and lm.IsDeleted=0)    
     
     UPDATE [AVL].[TK_TRN_TicketDetail] SET     
   --AssignedTo=NULLIF(t2.UserID,0),    
    DebtClassificationMapID=NULLIF(t2.DebtClassificationMapID,0),ResolutionCodeMapID=NULLIF(t2.ResolutionCodeMapID,0),    
    CauseCodeMapID=NULLIF(t2.CauseCodeMapID,0),ResidualDebtMapID=NULLIF(t2.ResidualDebtMapID,0),    
    AvoidableFlag=NULLIF(t2.AvoidableFlag,0),IsApproved=1,LastUpdatedDate=GETDATE(),ModifiedBy=t2.AssignedTo    
    --,ModifiedDate=GETDATE(),NatureoftheTicket=NULLIF(t2.NatureoftheTicket,0),KEDBPath=t2.KEDBPath    
    ,ModifiedDate=GETDATE(),    
    FlexField1=t2.FlexField1,    
    FlexField2=t2.FlexField2,    
    FlexField3=t2.FlexField3,    
    FlexField4=t2.FlexField4,    
    LastModifiedSource = 9    
          FROM [AVL].[TK_TRN_TicketDetail] t1 (NOLOCK)    
     JOIN #NewData1 t2 (NOLOCK) ON t1.AssignedTo=@userID where t1.TicketID=t2.TicketID and t1.IsDeleted=0    
     
 END    
 ELSE    
 BEGIN    
------------------------------------------------------Customer Scenario starts--------------------------------------------------------------------------------------------------------------    
DECLARE @CountOldCust INT;    
DECLARE @CountNewCust INT;    
DECLARE @CustMail INT;    
SELECT DISTINCT    
 AD.ApplicationName AS Application    
 ,LM.UserID AS AssigneeUserID    
 ,CC.CauseCode AS 'CauseCode'    
 ,RC.ResolutionCode AS 'ResolutionCode'    
 ,DC.DebtClassificationName AS 'DebtClassificationName'    
 ,AF.AvoidableFlagName    
 ,RD.ResidualDebtName AS 'ResidualDebtName'    
 --,ISNULL(NT.[Nature Of The Ticket], '') AS NatureOfTheTicket    
 --,NT.[Nature Of The Ticket] AS 'NatureOfTheTicketName'    
 --,S.ServiceName    
 --,TD.KEDBPath    
 ,TD.TicketID    
 ,TD.DebtClassificationMapID    
 ,ISNULL(TD.ResolutionCodeMapID,0) AS ResolutionCodeMapID    
 ,ISNULL(TD.CauseCodeMapID,0) AS CauseCodeMapID    
 ,TD.ResidualDebtMapID    
 ,TD.AvoidableFlag     
 ,TD.AssignedTo    
 --,TD.NatureoftheTicket as NatureoftheTicketID    
 ,TD.FlexField1    
 ,TD.FlexField2    
 ,TD.FlexField3    
 ,TD.FlexField4    
 ,TD.IsFlexField1Modified    
 ,TD.IsFlexField2Modified    
 ,TD.IsFlexField3Modified    
 ,TD.IsFlexField4Modified    
 ,TicketType AS 'TicketType' INTO #NewDataCust1 FROM @ticketDetails TD    
JOIN AVL.MAS_LoginMaster LM (NOLOCK)    
 ON LM.EmployeeID = TD.AssignedTo    
LEFT JOIN AVL.DEBT_MAP_CauseCode CC (NOLOCK)    
 ON TD.CauseCodeMapID = CC.CauseID    
 AND CC.ProjectID=@ProjectID    
LEFT JOIN AVL.DEBT_MAP_ResolutionCode RC (NOLOCK)    
 ON RC.ResolutionID = TD.ResolutionCodeMapID    
 AND  RC.ProjectID=@ProjectID    
JOIN AVL.TK_TRN_TicketDetail TRD (NOLOCK) ON TRD.TicketID=TD.TicketID AND TRD.ProjectID=@ProjectID    
JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) ON AD.ApplicationID = TRD.ApplicationID    
JOIN AVL.APP_MAP_ApplicationProjectMapping APPM (NOLOCK) ON APPM.ProjectID = @ProjectID    
JOIN AVL.TK_MAP_TicketTypeMapping TTM (NOLOCK)    
 ON TTM.ProjectID = @ProjectID    
 AND TTM.TicketTypeMappingID = TRD.TicketTypeMapID    
JOIN AVL.DEBT_MAS_DebtClassification DC (NOLOCK)     
 ON DC.DebtClassificationID = TD.DebtClassificationMapID    
JOIN AVL.DEBT_MAS_ResidualDebt RD (NOLOCK)     
 ON RD.ResidualDebtID = TD.ResidualDebtMapID    
JOIN AVL.[DEBT_MAS_AvoidableFlag] AF (NOLOCK)    
 ON AF.AvoidableFlagID = TD.AvoidableFlag    
--LEFT JOIN AVL.ITSM_MAS_Natureoftheticket NT    
-- ON NT.NatureOfTheTicketId = TD.NatureoftheTicket    
    
    
SELECT DISTINCT    
 TD.TicketID    
 ,AD.ApplicationName AS Application    
 ,TD.AssignedTo AS AssigneeUserID    
 ,CC.CauseCode AS 'CauseCode'    
 ,RC.ResolutionCode AS 'ResolutionCode'    
 ,DC.DebtClassificationName AS 'DebtClassificationName'    
 ,AF.AvoidableFlagName    
 ,TTM.TicketType AS 'TicketType'    
 ,RD.ResidualDebtName AS 'ResidualDebtName'    
 --,NT.[Nature Of The Ticket] AS 'NatureOfTheTicket'    
 --,TD.KEDBPath    
 ,TD.FlexField1    
 ,TD.FlexField2    
 ,TD.FlexField3    
 ,TD.FlexField4    
 ,ND.IsFlexField1Modified    
 ,ND.IsFlexField2Modified    
 ,ND.IsFlexField3Modified    
 ,ND.IsFlexField4Modified    
 ,LM.EmployeeID as AssignedTo INTO #OldDataCust1 FROM AVL.TK_TRN_TicketDetail TD    
     JOIN #NewDataCust1 ND (NOLOCK)    
 ON TD.TicketID = ND.TicketID    
JOIN AVL.MAS_LoginMaster LM (NOLOCK)    
 ON LM.UserID = TD.AssignedTo    
LEFT JOIN AVL.DEBT_MAP_CauseCode CC (NOLOCK)    
 ON TD.CauseCodeMapID = CC.CauseID    
 AND TD.ProjectID = CC.ProjectID    
LEFT JOIN AVL.DEBT_MAP_ResolutionCode RC (NOLOCK)    
 ON RC.ResolutionID = TD.ResolutionCodeMapID    
 AND TD.ProjectID = RC.ProjectID    
JOIN AVL.TK_MAP_TicketTypeMapping TTM (NOLOCK)    
 ON TTM.ProjectID = TD.ProjectID    
 AND TTM.TicketTypeMappingID = TD.TicketTypeMapID    
--JOIN AVL.TK_MAS_Service S ON S.ServiceID = TD.ServiceID    
JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK)    
 ON AD.ApplicationID = TD.ApplicationID    
JOIN AVL.APP_MAP_ApplicationProjectMapping APPM (NOLOCK)    
 ON APPM.ProjectID = TD.ProjectID    
JOIN AVL.DEBT_MAS_DebtClassification DC (NOLOCK)    
 ON DC.DebtClassificationID = TD.DebtClassificationMapID    
JOIN AVL.DEBT_MAS_ResidualDebt RD (NOLOCK)    
 ON RD.ResidualDebtID = TD.ResidualDebtMapID    
JOIN AVL.[DEBT_MAS_AvoidableFlag] AF (NOLOCK)    
 ON AF.AvoidableFlagID = TD.AvoidableFlag    
--LEFT JOIN AVL.ITSM_MAS_Natureoftheticket NT    
-- ON NT.NatureOfTheTicketId = TD.NatureoftheTicket    
WHERE td.ProjectID = @ProjectID    
    
SELECT    
 A.* INTO #OldDataCust    
FROM (SELECT DISTINCT    
  TicketID    
  ,Application    
  ,AssignedTo    
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
  ,AssignedTo    
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
  ,AssignedTo    
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
  ,AssignedTo    
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
    
SET @AssigneeEmailName = (SELECT DISTINCT    
  LM.EmployeeEmail    
 FROM #NewDataCust TempNew    
 JOIN AVL.MAS_LoginMaster LM    
  ON LM.EmployeeID = TempNew.AssignedTo    
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
  ON LM.EmployeeID = TempNew1.AssignedTo    
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
 WHERE ProjectID = @ProjectID AND EmployeeID IN (SELECT DISTINCT AssignedTo FROM #NewDataCust1)    
 AND IsDeleted = 0    
INSERT INTO #TSMCust    
 SELECT DISTINCT    
  TSApproverID    
 FROM AVL.MAS_LoginMaster    
 WHERE ProjectID = @ProjectID AND EmployeeID IN (SELECT DISTINCT AssignedTo FROM #NewDataCust1)    
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
 --select @CountOldCust    
 --select @CountNewCust    
 if(@CountOldCust>0 AND @CountNewCust>0)    
 BEGIN    
 set @CustMail=1    
 END    
 --select @CustMail    
     
-------------------------------------------------------------------------------Customer Mail Start-----------------------------------------------------------------------    
SET @Subjecttext = 'Notification for the Overridden Debt values for your Tickets';    
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
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField1ProjectName +'</font></b></th>'    
END    
IF (@FlexField1 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField2ProjectName +'</font></b></th>'    
END    
IF (@FlexField3 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField3ProjectName +'</font></b></th>'    
END    
IF (@FlexField4 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField4ProjectName +'</font></b></th>'    
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
  (AssignedTo)    
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
--SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1([NatureOfTheTicket]) FROM #OldDataCust)+ '</td>'    
--END    
--IF (@KEDBPath > 0) BEGIN    
--SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1([KEDBPath]) FROM #OldDataCust)+ '</td>'    
--END    
IF (@FlexField1 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1([FlexField1]) FROM #OldDataCust)+ '</td>'    
END    
IF (@FlexField2 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1([FlexField2]) FROM #OldDataCust)+ '</td>'    
END    
IF (@FlexField3 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1([FlexField3]) FROM #OldDataCust)+ '</td>'    
END    
IF (@FlexField4 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<td>' + (SELECT TOP 1([FlexField4]) FROM #OldDataCust)+ '</td>'    
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
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField1ProjectName +'</font></b></th>'    
END    
IF (@FlexField2 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField2ProjectName +'</font></b></th>'    
END    
IF (@FlexField3 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField3ProjectName +'</font></b></th>'    
END    
IF (@FlexField4 > 0) BEGIN    
SET @tableHTML = @tableHTML + '<th align=center><b><font color="white">'+ @FlexField4ProjectName +'</font></b></th>'    
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
  (AssignedTo)    
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
  ([FlexField1])    
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
          Solution Zone Support      
         </font>      
       </p>';    
-----------------------------------------------------------------------------------Customer Mail End--------------------------------------------------------------------    
 /*****************************Multilingual******************************/    
  DECLARE @isCustMultiLingual INT=0;    
  DECLARE @IsCustFlexField1 [BIT]=0,    
    @IsCustFlexField2 [BIT]=0,    
    @IsCustFlexField3 [BIT]=0,    
    @IsCustFlexField4 [BIT]=0;    
    
 SELECT @isCustMultiLingual=1 FROM AVL.MAS_ProjectMaster (NOLOCK) WHERE ProjectID=@ProjectID AND    
 IsDeleted=0 AND IsMultilingualEnabled=1;    
     
 IF(@isCustMultiLingual=1)    
  BEGIN    
  PRINT 'Inside Multilingual 1';    
  SELECT DISTINCT MCM.ColumnID INTO #CustColumns FROM AVL.MAS_MultilingualColumnMaster MCM  (NOLOCK)     
  JOIN AVL.PRJ_MultilingualColumnMapping MCP WITH(NOLOCK) ON MCM.ColumnID=MCP.ColumnID    
  WHERE MCM.IsActive=1 AND MCP.IsActive=1    
  AND MCP.ProjectID=@ProjectID;    
    
  --SELECT * FROM #CustColumns;    
    SELECT @IsCustFlexField1=1 FROM #CustColumns WHERE ColumnID=7;    
     SELECT @IsCustFlexField2=1 FROM #CustColumns WHERE ColumnID=8;    
      SELECT @IsCustFlexField3=1 FROM #CustColumns WHERE ColumnID=9;    
       SELECT @IsCustFlexField4=1 FROM #CustColumns WHERE ColumnID=10;    
    
      
  SELECT DISTINCT ITD.[TicketID],TD.TimeTickerID,    
   CASE WHEN @IsCustFlexField1 = 1 AND (ITD.IsFlexField1Modified='1')     
    THEN 1 ELSE 0 END AS 'IsFlexField1Modified',    
   CASE WHEN @IsCustFlexField2 = 1 AND (ITD.IsFlexField2Modified='1')     
    THEN 1 ELSE 0 END AS 'IsFlexField2Modified',    
   CASE WHEN @IsCustFlexField3 = 1 AND (ITD.IsFlexField3Modified='1')     
    THEN 1 ELSE 0 END AS 'IsFlexField3Modified',    
   CASE WHEN @IsCustFlexField4 = 1 AND (ITD.IsFlexField4Modified='1')     
    THEN 1 ELSE 0 END AS 'IsFlexField4Modified'    
  INTO #MultilingualTbl3    
  FROM  #NewDataCust1 ITD JOIN AVL.TK_TRN_TicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[TicketID]     
  AND TD.ProjectID=@ProjectID AND TD.IsDeleted=0;    
    
    
  MERGE [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails] AS TARGET    
  USING #MultilingualTbl3 AS SOURCE    
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
  VALUES (SOURCE.TimeTickerID,SOURCE.IsFlexField1Modified,SOURCE.IsFlexField2Modified,SOURCE.IsFlexField3Modified,SOURCE.IsFlexField4Modified,0,@EmployeeID,GETDATE(),6);    
END    
    
 /**********************************************************************/    
    
 SET @userID =(SELECT top 1 LM.UserID FROM AVL.MAS_LoginMaster LM (NOLOCK) JOIN #NewDataCust1 N (NOLOCK) ON Lm.EmployeeID=N.AssignedTo AND Lm.ProjectID=@ProjectID and lm.IsDeleted=0)    
     UPDATE [AVL].[TK_TRN_TicketDetail] SET     
   --AssignedTo=NULLIF(t2.UserID,0),    
    DebtClassificationMapID=NULLIF(t2.DebtClassificationMapID,0),ResolutionCodeMapID=NULLIF(t2.ResolutionCodeMapID,0),    
    CauseCodeMapID=NULLIF(t2.CauseCodeMapID,0),ResidualDebtMapID=NULLIF(t2.ResidualDebtMapID,0),    
    AvoidableFlag=NULLIF(t2.AvoidableFlag,0),IsApproved=1,LastUpdatedDate=GETDATE(),ModifiedBy=t2.AssignedTo    
    --,ModifiedDate=GETDATE(),NatureoftheTicket=NULLIF(t2.NatureoftheTicketID,0),KEDBPath=t2.KEDBPath    
    ,FlexField1=t2.FlexField1    
    ,FlexField2=t2.FlexField2    
    ,FlexField3=t2.FlexField3    
    ,FlexField4=t2.FlexField4    
    ,LastModifiedSource = 9    
          FROM [AVL].[TK_TRN_TicketDetail] t1 (NOLOCK)    
     JOIN #NewDataCust1 t2 (NOLOCK) ON t1.AssignedTo=@userID where t1.TicketID=t2.TicketID and t1.IsDeleted=0    
      
--------------------------------------------------------Customer Scenario end------------------------------------------------------------------------------------------    
 END    
 --select @CogMail    
 --select @CustMail    
------------------------------------------------------------Mail Triggering Start---------------------------------------------------------------------------    
    
------------------------------------------------------------Mail Triggering End----------------------------------------------------------------------------    
    
IF(@IsCognizant = 1)     
BEGIN    
DROP TABLE #OldData    
DROP TABLE #NewData    
DROP TABLE #OldData1    
DROP TABLE #NewData1    
END    
ELSE    
BEGIN    
DROP TABLE #OldDataCust    
DROP TABLE #NewDataCust    
DROP TABLE #OldDataCust1    
DROP TABLE #NewDataCust1    
END    
    
   SET @result= 1    
  SELECT @result AS RESULT    
     
    SET NOCOUNT OFF;      
 COMMIT TRAN    
    
 -- Temporary fix due to mail access denied    
  IF (@CustMail =1 OR @CogMail =1)    
     
 BEGIN    
 EXEC [AVL].[SendDBEmail] @To=@AssigneeEmailName,
    @From='ApplensSupport@cognizant.com',
    @Subject =@Subjecttext,
    @Body = @tableHTML
    
END    
    
END TRY      
BEGIN CATCH      
  IF @@TRANCOUNT > 0    
      BEGIN    
      ROLLBACK TRAN    
      SET @result= 0     
      END    
  DECLARE @ErrorMessage VARCHAR(MAX);    
      
  SELECT @ErrorMessage = ERROR_MESSAGE()     
  print @ErrorMessage     
  --INSERT Error        
  EXEC AVL_InsertError 'UpdateApproveTicketsByTicketID', @ErrorMessage, 0,0    
      
 END CATCH      
END


