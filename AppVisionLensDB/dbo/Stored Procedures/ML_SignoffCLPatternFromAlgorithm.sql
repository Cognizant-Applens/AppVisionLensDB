/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--Exec  [dbo].[ML_SignoffCLPatternFromAlgorithm] 57,'10254,102579'
CREATE  PROCEDURE [dbo].[ML_SignoffCLPatternFromAlgorithm]

@ProjectID nVARCHAR(100),
@TVP_lstDebtPattern AVL.CL_CLSavePatterns READONLY,
@AppID nVARCHAR(MAX),
@EmployeeID nVARCHAR(150),
@IsCLSignOff BIT
AS
BEGIN
BEGIN TRY
BEGIN TRAN


--SELECT * FROM @TVP_lstDebtPattern

--SELECT * FROM TRN.Debt_MLPatternValidation
CREATE TABLE #DebtPattern
(
[ID] [bigint] NULL,
	[AppID] [int]NULL,
	[DebtID] [int] NULL,
	[AvoidableFlagID] [int] NULL,
	[ResidualID] [int] NULL,
	[CauseCodeID] [int] NULL,
	[ApprovedOrMuted] [int] NULL,
	[EmployeeID] [nvarchar](300) NULL,
	[IsCLSignOff] [bit] NULL,
	[ReasonforResidualID] [int] NULL,
	[ExpectedCompletionDate] [datetime] NULL,
	TicketPattern[varchar](Max) NULL
)
DECLARE @InitialLearningID INT;
SET @InitialLearningID=(SELECT TOP 1 ID FROM AVL.ML_PRJ_InitialLearningState
						WHERE ProjectID=@ProjectID ORDER BY ID DESC)

PRINT @AppID 
Create Table #tempid (
  ITEM bigint
)
IF @AppID IS NULL OR LEN(@AppID)>0
BEGIN 
INSERT INTO #tempid SELECT ITEM FROM split(@AppID,',')
END
ELSE
BEGIN
INSERT INTO #tempid SELECT APM.ApplicationID  FROM AVL.APP_MAP_ApplicationProjectMapping APM 
WHERE
 APM.ProjectID=@projectID AND APM.IsDeleted=0

END


--SELECT ITEM INTO #tempid FROM split(@AppID,',')


DECLARE @CustomerID INT=0;
			DECLARE @IsCognizantID INT;
			SET @CustomerID=(SELECT top 1 CustomerID FROM AVL.MAS_LoginMaster WHERE ProjectID=@ProjectID AND IsDeleted=0)
			SET @IsCognizantID=(SELECT top 1 IsCognizant FROM AVL.Customer WHERE CustomerID=@CustomerID AND IsDeleted=0)
			
INSERT INTO #DebtPattern
(ID,DebtID,AvoidableFlagID,ResidualID,CauseCodeID,ApprovedorMuted,EmployeeID,ISCLSignOff--,ReasonforResidualID,ExpectedCompletionDate
)

SELECT ID,DebtID,AvoidableFlagID,ResidualID,CauseCodeID,ApprovedorMuted,EmployeeID,ISCLSignOff--,ReasonforResidualID,ExpectedCompletionDate
FROM @TVP_lstDebtPattern

UPDATE dp 
SET TicketPattern = CL.TicketPattern
from  #DebtPattern dp
INNER JOIN AVL.ML_TRN_MLPatternValidation_CL CL ON CL.ID = DP.ID AND CL.IsDeleted = 0 AND CL.ProjectID = @ProjectID

SELECT  cl.ID,cl.InitialLearningID,cl.ProjectID,cl.ApplicationID,cl.ApplicationTypeID,cl.TechnologyID,cl.TicketPattern,cl.MLResidualFlagID,
cl.MLDebtClassificationID,cl.MLAvoidableFlagID,cl.MLCauseCodeID,cl.MLAccuracy,cl.TicketOccurence,cl.AnalystResidualFlagID,
cl.AnalystResolutionCodeID,cl.AnalystCauseCodeID,cl.AnalystDebtClassificationID,cl.AnalystAvoidableFlagID,cl.SMEComments,cl.SMEResidualFlagID,cl.SMEDebtClassificationID,
cl.SMEAvoidableFlagID,cl.SMECauseCodeID,cl.IsApprovedOrMute,cl.CreatedBy,cl.CreatedDate,cl.ModifiedBy,cl.ModifiedDate,cl.ReasonforResidual,cl.MLResolutionCodeID
INTO #tempContOldPatterns FROM AVL.ML_TRN_MLPatternValidation_cl cl
inner join AVL.ML_TRN_MLPatternValidation ml ON ml.TicketPattern = cl.TicketPattern 
and cl.ApplicationID = ml.ApplicationID and ml.ProjectID = cl.ProjectID and cl.MLCauseCodeID = ml.MLCauseCodeID and cl.MLResolutionCodeID = ml.MLResolutionCode
INNER JOIN #tempid t ON t.item = ML.ApplicationID
WHERE ml.projectid = @ProjectID and CL.ProjectID = @ProjectID AND cl.TicketPattern <> '0' and cl.isdeleted = 0  AND ML.ISDELETED = 0 ORDER BY  ml.ID
 
IF EXISTS(SELECT ID FROM AVL.ML_TRN_MLPatternValidation_CL where ID IN ( SELECT ID FROM #tempContOldPatterns))
BEGIN

UPDATE MLP 
SET MLP.MLResidualFlagID = CL.MLResidualFlagID ,
MLP.MLDebtClassificationID = CL.MLDebtClassificationID,
MLP.MLAvoidableFlagID = CL.MLAvoidableFlagID,
MLP.MLCauseCodeID = CL.MLCauseCodeID,
MLP.IsApprovedOrMute = CL.IsApprovedOrMute,
mlp.ModifiedDate= getdate()
FROM  AVL.ML_TRN_MLPatternValidation MLP 
INNER JOIN AVL.ML_TRN_MLPatternValidation_CL CL ON MLP.TicketPattern = cl.TicketPattern 
and cl.ApplicationID = MLP.ApplicationID and MLP.ProjectID = cl.ProjectID and cl.MLCauseCodeID = MLP.MLCauseCodeID and cl.MLResolutionCodeID = MLP.MLResolutionCode
INNER JOIN #tempid t ON t.item = MLP.ApplicationID
WHERE MLP.projectid = @ProjectID and CL.ProjectID = @ProjectID AND cl.TicketPattern <> '0' and cl.isdeleted = 0  AND MLP.ISDELETED = 0 
AND CL.ID IN (SELECT ID FROM #tempContOldPatterns) 

END

IF EXISTS (SELECT DISTINCT cl.InitialLearningID,cl.ProjectID,cl.ApplicationID,cl.ApplicationTypeID,cl.TechnologyID,cl.TicketPattern,cl.MLResidualFlagID,
cl.MLDebtClassificationID,cl.MLAvoidableFlagID,cl.MLCauseCodeID,cl.MLAccuracy,cl.TicketOccurence,cl.AnalystResidualFlagID,cl.AnalystResolutionCodeID,
cl.AnalystCauseCodeID,cl.AnalystDebtClassificationID,cl.AnalystAvoidableFlagID,cl.SMEComments,cl.SMEResidualFlagID,cl.SMEDebtClassificationID
,cl.SMEAvoidableFlagID,cl.SMECauseCodeID,cl.IsApprovedOrMute,cl.CreatedBy,getdate(),cl.ModifiedBy,null,cl.IsDeleted,cl.Classifiedby,null,
cl.ReasonforResidual,cl.ExpectedCompletionDate,cl.AnalystResolutionCodeID
 FROM AVL.ML_TRN_MLPatternValidation_CL CL 
 WHERE ID NOT IN ( SELECT ID FROM #tempContOldPatterns))

 BEGIN

INSERT INTO AVL.ML_TRN_MLPatternValidation (InitialLearningID,ProjectID,ApplicationID,ApplicationTypeID,TechnologyID,TicketPattern,MLResidualFlagID,
MLDebtClassificationID,MLAvoidableFlagID,MLCauseCodeID,MLAccuracy,TicketOccurence,AnalystResidualFlagID,AnalystResolutionCodeID,
AnalystCauseCodeID,AnalystDebtClassificationID,AnalystAvoidableFlagID,SMEComments,SMEResidualFlagID,SMEDebtClassificationID
,SMEAvoidableFlagID,SMECauseCodeID,IsApprovedOrMute,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,IsDeleted,Classifiedby,SMEResolutionCodeID,ReasonforResidual,ExpectedCompDate,MLResolutionCode)
SELECT DISTINCT cl.InitialLearningID,cl.ProjectID,cl.ApplicationID,cl.ApplicationTypeID,cl.TechnologyID,cl.TicketPattern,cl.MLResidualFlagID,
cl.MLDebtClassificationID,cl.MLAvoidableFlagID,cl.MLCauseCodeID,cl.MLAccuracy,cl.TicketOccurence,cl.AnalystResidualFlagID,cl.AnalystResolutionCodeID,
cl.AnalystCauseCodeID,cl.AnalystDebtClassificationID,cl.AnalystAvoidableFlagID,cl.SMEComments,cl.SMEResidualFlagID,cl.SMEDebtClassificationID
,cl.SMEAvoidableFlagID,cl.SMECauseCodeID,cl.IsApprovedOrMute,cl.CreatedBy,getdate(),cl.ModifiedBy,null,cl.IsDeleted,cl.Classifiedby,null,
cl.ReasonforResidual,cl.ExpectedCompletionDate,cl.AnalystResolutionCodeID
 FROM AVL.ML_TRN_MLPatternValidation_CL CL 
 WHERE ID NOT IN ( SELECT ID FROM #tempContOldPatterns) AND CL.ProjectID = @ProjectID
  AND cl.TicketPattern <> '0' and cl.isdeleted = 0 

  END

BEGIN
DECLARE @DATE DATETIME =GETDATE()
Update avl.MAS_ProjectDebtDetails
set IsCLSignOff=1,
CLSIGNOFFDATE=@date, CLSIGNOFFUSERID=@EmployeeID where ProjectID=@ProjectID  AND IsDeleted=0 --ModifiedBy=@CustomerID
END

--SELECT * FROM #DebtPattern
--UPDATE AVL.ML_TRN_MLSamplingJobStatus SET IsDARTProcessed='Y'
--WHERE ProjectID=@ProjectID AND JobType='ML' AND (IsDeleted=0 OR IsDeleted IS NULL)

--UPDATE AVL.ML_PRJ_InitialLearningState SET IsMLSentOrReceived='Received'
--WHERE ProjectID=@ProjectID AND IsDeleted=0
 
----Mailer Logic
--DECLARE @UserName nVARCHAR(MAX);
--DECLARE @EmailProjectName nVARCHAR(MAX);
----DECLARE @UserEmailID nVARCHAR(MAX);
--DECLARE @tableHTML nVARCHAR(MAX);
--Declare @ESAPid nVARCHAR(MAX);

--DECLARE @Subjecttext nVARCHAR(MAX);
----SET @UserName=(SELECT TOP 1 CognizantName FROM PRJ.LoginMaster(NOLOCK) WHERE ProjectID=@ProjectID AND cognizantID='471742')
----SET @UserEmailID=(SELECT TOP 1 CognizantEmail FROM PRJ.LoginMaster(NOLOCK) WHERE ProjectID=@ProjectID AND cognizantID='471742')


--SET @EmailProjectName=(SELECT TOP 1 ProjectName FROM  [AVL].[MAS_ProjectMaster](NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0)

--SET @ESAPid = (SELECT TOP 1 EsaProjectID FROM [AVL].[MAS_ProjectMaster](NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0)

----Create table #TSM
----(
----CognizantID Varchar(MAX)
----)

----Insert into #TSM
----Select Distinct TsSupervisorID
----from Prj.LoginMaster where ProjectID = @ProjectID and IsDeleted = 'N'

----Insert into #TSM
----Select Distinct ManagerID
----from Prj.LoginMaster where ProjectID = @ProjectID and IsDeleted = 'N' 

----Select Distinct LM.cognizantID, LM.CognizantName, LM.CognizantEmail into #Tmp_Mail from #TSM TS INNER JOIN PRJ.LoginMaster LM on 
----TS.CognizantID = LM.UserID where LM.IsDeleted = 'N'

----DECLARE @ToRecipientList NVARCHAR(MAX);
----SET @ToRecipientList =   (select (STUFF((SELECT distinct ';' +
----								RTRIM(LTRIM(CognizantEmail))
----							  FROM #Tmp_Mail 
----							  FOR XML PATH(''), TYPE
----							 ).value('.', 'NVARCHAR(MAX)') 
----								, 1, 1, '')) as ToList)


--Create table #TSM
--(
--CognizantID nVarchar(MAX)
--)

--Insert into #TSM
--Select Top 1 InitiatedBy from [AVL].[ML_TRN_MLSamplingJobStatus] where ProjectID = @ProjectID and JobType = 'ML' ORDER By ID Desc

--Select Distinct LM.EmployeeID, LM.EmployeeName, LM.EmployeeEmail into #Tmp_Mail from #TSM TS INNER JOIN  [AVL].[MAS_LoginMaster] LM on 
--TS.CognizantID = LM.EmployeeID where LM.IsDeleted = 0

--DECLARE @ToRecipientList NVARCHAR(MAX);
--SET @ToRecipientList =   (Select top 1 EmployeeEmail from #Tmp_Mail)

--DECLARE @CCRecipientList NVARCHAR(MAX);
--SET @CCRecipientList = (Select Distinct top 1 LM.EmployeeEmail from [AVL].[MAS_ProjectDebtDetails] DP
--INNER JOIN [AVL].[MAS_LoginMaster] LM on DP.AutoClassifiedBy = LM.EmployeeID 
--where DP.EsaProjectID = @ESAPid )

--SET @Subjecttext='Notification for the completion of ML Algorithm in AVMDART for the Project - '+@EmailProjectName;
--	SET @tableHTML = N'<left>  
--										<font-weight:normal>
--										 Hi All,'
--										 --+@UserName
--										 + '</BR>'
--										 +'&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp'
--										 +'</BR>'
--										 +'This is to inform you that Initial Learning has been generated for the project - '
--										 +'<font color="#000000"><b>'+@ESAPid+'</b></font>'
--										 +'-'
--										 +'<font color="#000000"><b>'+@EmailProjectName+'</b></font>'
--										 +'</BR>'
--										 +'</BR>'
--										 +'Please navigate to <b> Lead -> Initial Learning Review</b> for reviewal and approval of learnings for Auto Debt Classification.'
--										 +'</font>  
--								</Left>' 
--							 +
--							  N'
							 
--							 <p align="left">  
--							 <font color="Black" face="Arial" Size = "2">  
--							  PS :This is system generated mail,please do not reply to this mail.<br /><br>  
--							   Regards,<br />  
--							   AVMDART Team  
--							  </font>  
--							</p>';   

--EXEC msdb.dbo.sp_send_dbmail @recipients = @ToRecipientList,
--											@profile_name = 'AD Mail Alerts',  
--											@copy_recipients = @CCRecipientList,
--											@subject = @Subjecttext,  
--											@body = @tableHTML,  
--											@body_format = 'HTML'; 	



COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_SaveMLPatternFromAlgorithm] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  



END
