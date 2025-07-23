
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		<Saravanan.B>
-- Create date: <12/20/2019>
-- Description:	<RecommendationUsecaseForATicketsJob>
-- =============================================
CREATE PROCEDURE [AVL].[RecommendationUsecaseForATicketsJob]
  
AS
BEGIN  
 BEGIN TRY 
   SET NOCOUNT ON; 
  
    DECLARE @JobName varchar(40)='A Ticket_Recommendation of Usecase'
    DECLARE @ID BIGINT = (SELECT JobID FROM MAS.JobMaster WHERE  JobName = @JobName)
    DECLARE @JobID bigint,@InsertedRecordCount INT
    DECLARE @JobStatusSuccess varchar(10)='Success'
    DECLARE @JobStatusFailed varchar(10)='Failed'
	DECLARE @LastSuccessJobRunDate DATETIME =(SELECT TOP 1 EndDateTime FROM MAS.JobStatus WHERE JobId=@ID AND JobStatus='Success' ORDER BY  ID DESC)

    INSERT INTO  MAS.JobStatus(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate) 
		VALUES (@ID,GETDATE(),'','',GETDATE(),0,@JobName,GETDATE())

		SET @JobID  = (SELECT IDENT_CURRENT('MAS.JobStatus' ))

    SELECT 
		ProjectPatternMapID,
		ProjectID,
		ApplicationID= (SELECT Item FROM [dbo].[StringSplit](HealPattern,'-') WHERE RowNumber = 1),
		ResolutionCode = (SELECT Item FROM [dbo].[StringSplit](HealPattern,'-') WHERE RowNumber = 2),
		CauseCode= (SELECT Item FROM [dbo].[StringSplit](HealPattern,'-') WHERE RowNumber = 3)
    INTO #Heal_ProjectPatternMapping
    FROM  [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) WHERE AvoidableFlag=3 AND IsDeleted=0
    AND ISNULL(ManualNonDebt,0)<>1

    SELECT * INTO #ComparedSystemATicketFields FROM

     (SELECT DISTINCT 
		DHTD.HealingTicketID,
		DHPPM.ProjectID,
		AD.ApplicationName,
		PT.PrimaryTechnologyName,
		MCC.CauseCode,
		DRC.ResolutionCode,
	    AVL.NoiseElimination(DHTD.TicketDescription) AS TicketDescription,
		AVL.NoiseElimination(TD.ResolutionRemarks) AS ResolutionRemarks,
		ACMAS.ActivityName,
        ISNULL(DHTD.ManualNonDebt,0) AS ManualNonDebt
      FROM [AVL].[DEBT_TRN_HealTicketDetails](NOLOCK) DHTD
	   INNER JOIN #Heal_ProjectPatternMapping DHPPM ON DHTD.ProjectPatternMapID=DHPPM.ProjectPatternMapID 
	                                                AND ISNULL(DHTD.IsDeleted,0)=0 AND DHTD.TicketType='A'
       INNER JOIN [AVL].[APP_MAS_ApplicationDetails] (NOLOCK) AD ON DHPPM.ApplicationID = AD.ApplicationID 
	   INNER JOIN [AVL].APP_MAS_PrimaryTechnology (NOLOCK) PT ON PT.PrimaryTechnologyID=AD.PrimaryTechnologyID AND ISNULL(PT.IsDeleted,0)=0
	   INNER JOIN [AVL].[DEBT_MAP_ResolutionCode] (NOLOCK) DRC ON DHPPM.ResolutionCode = DRC.ResolutionID AND DRC.IsDeleted=0 AND DRC.ProjectID=DHPPM.ProjectID
	   INNER JOIN [AVL].[DEBT_MAP_CauseCode](NOLOCK) MCC  ON DHPPM.CauseCode = MCC.CauseID AND MCC.IsDeleted=0 AND MCC.ProjectID=DHPPM.ProjectID
	   INNER JOIN [AVL].[DEBT_PRJ_HealParentChild] (NOLOCK) HPC ON HPC.ProjectPatternMapID = DHTD.ProjectPatternMapID 
	                                                   AND HPC.IsDeleted=0 AND HPC.MapStatus = 1
       INNER JOIN [AVL].[TK_TRN_TicketDetail] (NOLOCK) TD ON TD.TicketID = HPC.DARTTicketID AND ISNULL(TD.IsDeleted,0)=0 AND TD.ProjectID=DHPPM.ProjectID
	   LEFT JOIN [AVL].[TM_TRN_TimesheetDetail](NOLOCK) TS ON TS.TicketID=TD.TicketID AND ISNULL(TS.IsDeleted,0)=0 AND  TS.ProjectId=DHPPM.ProjectID
	   LEFT JOIN [AVL].[TK_MAS_ServiceActivityMapping] (NOLOCK) ACMAS ON ACMAS.ActivityID=TS.ActivityId AND ACMAS.ServiceID=TS.ServiceId
	                                                    AND ISNULL(ACMAS.IsDeleted,0)=0
       WHERE  ISNULL(DHTD.ManualNonDebt,0)<>1  AND  (DHTD.CreatedDate>=@LastSuccessJobRunDate OR DHTD.ModifiedDate>=@LastSuccessJobRunDate)
	   )A

	   --NEW USE CASE DETAILS
	   SELECT
			UC.Id AS UseCaseDetailID,
			UC.UseCaseId,
			UC.UseCaseTitle,
			APP.ApplicationName,
			TECH.PrimaryTechnologyName		
       INTO #NewUseCaseDetails
	   FROM
			AVL.UseCaseDetails(NOLOCK) UC
			JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) APP ON UC.ApplicationID = APP.ApplicationID 
			JOIN AVL.APP_MAS_PrimaryTechnology(NOLOCK) TECH	 ON UC.TechnologyID = TECH.PrimaryTechnologyID			
	   WHERE  UC.IsDeleted = 0 AND TECH.IsDeleted = 0 AND APP.IsActive =1 and UC.UseCaseStatusId=2
	   
	   /*--TAGS
	   SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			T.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.Effort_UseCaseDetails T ON (T.Tags LIKE '%' + C.CauseCode + '%' AND ISNULL(T.Tags,'')!='')
	   UNION 
	   SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			UC.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.UseCaseTagDetail T ON (T.Tag LIKE '%' + C.CauseCode + '%' AND ISNULL(T.Tag,'')!='')
			JOIN  AVL.UseCaseDetails UC ON UC.ID = T.UseCaseDetailId
			*/

	   SELECT DISTINCT * INTO #TempSystemATickets FROM
  
    (SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
    FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.ApplicationName LIKE '%' + C.ApplicationName + '%')
	 UNION
		SELECT
			C.HealingTicketID,
			C.ProjectID,
			UC.UseCaseDetailID AS 'ID',
			UC.UseCaseID ,
			C.ManualNonDebt
		FROM #ComparedSystemATicketFields(NOLOCK) C
			INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON (UC.ApplicationName LIKE '%' + C.ApplicationName + '%')
	 
	 UNION 
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.Technology LIKE '%' + C.PrimaryTechnologyName + '%') 
	  UNION
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		UC.UseCaseDetailID AS 'ID',
		UC.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON ( UC.PrimaryTechnologyName LIKE '%' + C.PrimaryTechnologyName + '%')

	 UNION 

	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseTitle LIKE '%' + C.CauseCode + '%') 
	 UNION
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		UC.UseCaseDetailID AS 'ID',
		UC.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON ( UC.UseCaseTitle LIKE '%' + C.CauseCode + '%')
	 UNION 

	 SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseTitle LIKE '%' + C.ResolutionCode + '%') 
	 UNION
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		UC.UseCaseDetailID AS 'ID',
		UC.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON ( UC.UseCaseTitle LIKE '%' + C.ResolutionCode + '%')
	 UNION

	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseTitle LIKE '%' + C.TicketDescription + '%' AND ISNULL(C.TicketDescription,'')!='') 
	  UNION
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		UC.UseCaseDetailID AS 'ID',
		UC.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON ( UC.UseCaseTitle LIKE '%' + C.TicketDescription + '%' AND ISNULL(C.TicketDescription,'')!='')
	 UNION	
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseTitle LIKE '%' + C.ActivityName + '%' AND ISNULL(C.ActivityName,'')!='')
	   UNION
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		UC.UseCaseDetailID AS 'ID',
		UC.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON ( UC.UseCaseTitle LIKE '%' + C.ActivityName + '%' AND ISNULL(C.ActivityName,'')!='')
	 
	  UNION

	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseTitle LIKE '%' + C.ResolutionRemarks + '%' AND ISNULL(C.ResolutionRemarks,'')!='')
	 UNION
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		UC.UseCaseDetailID AS 'ID',
		UC.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON ( UC.UseCaseTitle LIKE '%' + C.ResolutionRemarks + '%' AND ISNULL(C.ResolutionRemarks,'')!='')
	 
	 UNION

	   SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseDescription LIKE '%' + C.CauseCode + '%') 

	 UNION 

	 SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseDescription LIKE '%' + C.ResolutionCode + '%') 

	 UNION

	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseDescription LIKE '%' + C.TicketDescription + '%' AND ISNULL(C.TicketDescription,'')!='') 

	  UNION

	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseDescription LIKE '%' + C.ActivityName + '%' AND ISNULL(C.ActivityName,'')!='')

	  UNION

	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedSystemATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseDescription LIKE '%' + C.ResolutionRemarks + '%' AND ISNULL(C.ResolutionRemarks,'')!='')
	 UNION 
	 --INCLUDE Tags
	
	 SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			T.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.Effort_UseCaseDetails T ON (T.Tags LIKE '%' + C.CauseCode + '%' AND ISNULL(T.Tags,'')!='')
	   UNION 
	   SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			UC.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.UseCaseTagDetail T ON (T.Tag LIKE '%' + C.CauseCode + '%' AND ISNULL(T.Tag,'')!='')
			JOIN  AVL.UseCaseDetails UC ON UC.ID = T.UseCaseDetailId
	 UNION 
	 SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			T.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.Effort_UseCaseDetails T ON (T.Tags LIKE '%' + C.ResolutionCode + '%' AND ISNULL(T.Tags,'')!='')
	   UNION 
	   SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			UC.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.UseCaseTagDetail T ON (T.Tag LIKE '%' + C.ResolutionCode + '%' AND ISNULL(T.Tag,'')!='')
			JOIN  AVL.UseCaseDetails UC ON UC.ID = T.UseCaseDetailId
			UNION 
	 SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			T.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.Effort_UseCaseDetails T ON (T.Tags LIKE '%' + C.TicketDescription + '%' AND ISNULL(T.Tags,'')!='')
	   UNION 
	   SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			UC.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.UseCaseTagDetail T ON (T.Tag LIKE '%' + C.TicketDescription + '%' AND ISNULL(T.Tag,'')!='')
			JOIN  AVL.UseCaseDetails UC ON UC.ID = T.UseCaseDetailId
			UNION 
	 SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			T.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.Effort_UseCaseDetails T ON (T.Tags LIKE '%' + C.ActivityName + '%' AND ISNULL(T.Tags,'')!='')
	   UNION 
	   SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			UC.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.UseCaseTagDetail T ON (T.Tag LIKE '%' + C.ActivityName + '%' AND ISNULL(T.Tag,'')!='')
			JOIN  AVL.UseCaseDetails UC ON UC.ID = T.UseCaseDetailId
			UNION 
	 SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			T.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.Effort_UseCaseDetails T ON (T.Tags LIKE '%' + C.ResolutionRemarks + '%' AND ISNULL(T.Tags,'')!='')
	   UNION 
	   SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			UC.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedSystemATicketFields  (NOLOCK) C
			JOIN AVL.UseCaseTagDetail T ON (T.Tag LIKE '%' + C.ResolutionRemarks + '%' AND ISNULL(T.Tag,'')!='')
			JOIN  AVL.UseCaseDetails UC ON UC.ID = T.UseCaseDetailId

	   )A

	   /*------------Manual A Tickets------------------*/

     SELECT * INTO #ComparedManualATicketFields FROM

  (SELECT DISTINCT 
		DHTD.HealingTicketID,
		NDC.ProjectID,
		AD.ApplicationName,
	    PT.PrimaryTechnologyName,
		AVL.NoiseElimination(DHTD.TicketDescription) AS TicketDescription,
		NDC.ActivityName,
		ISNULL(DHTD.ManualNonDebt,0) AS ManualNonDebt

     FROM [AVL].[DEBT_TRN_HealTicketDetails](NOLOCK) DHTD
       INNER JOIN [AVL].[DEBT_PRJ_NonDebtParentChild] (NOLOCK) NDC ON DHTD.HealingTicketID=NDC.HealingTicketID AND ISNULL(NDC.IsDeleted,0)=0
	          AND DHTD.TicketType='A' AND NDC.MapStatus=1
	   INNER JOIN [AVL].[APP_MAS_ApplicationDetails] (NOLOCK) AD ON NDC.ApplicationID = AD.ApplicationID 
	   INNER JOIN [AVL].APP_MAS_PrimaryTechnology (NOLOCK) PT ON PT.PrimaryTechnologyID=AD.PrimaryTechnologyID AND ISNULL(PT.IsDeleted,0)=0

     WHERE  ISNULL(DHTD.ManualNonDebt,0)=1 AND  (DHTD.CreatedDate>=@LastSuccessJobRunDate OR DHTD.ModifiedDate>=@LastSuccessJobRunDate)
    )B

	SELECT DISTINCT * INTO #TempManualATickets FROM
  
  (SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
    FROM #ComparedManualATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.ApplicationName LIKE '%' + C.ApplicationName + '%') 
	 UNION
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		UC.UseCaseDetailID AS 'ID',
		UC.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedManualATicketFields(NOLOCK) C
     INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON ( UC.ApplicationName LIKE '%' + C.ApplicationName + '%')
	 UNION 
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedManualATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.Technology LIKE '%' + C.PrimaryTechnologyName + '%') 
	  UNION
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		UC.UseCaseDetailID AS 'ID',
		UC.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedManualATicketFields(NOLOCK) C
     INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON ( UC.PrimaryTechnologyName LIKE '%' + C.PrimaryTechnologyName + '%')
	 
	  UNION

	  SELECT DISTINCT 
		C.HealingTicketID,
	    C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedManualATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseTitle LIKE '%' + C.TicketDescription + '%' AND ISNULL(C.TicketDescription,'')!='') 
	   UNION
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		UC.UseCaseDetailID AS 'ID',
		UC.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedManualATicketFields(NOLOCK) C
     INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON ( UC.UseCaseTitle LIKE '%' + C.TicketDescription + '%' AND ISNULL(C.TicketDescription,'')!='') 
	 
	 UNION

	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedManualATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseTitle LIKE '%' + C.ActivityName + '%' AND ISNULL(C.ActivityName,'')!='')
	   UNION
	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		UC.UseCaseDetailID AS 'ID',
		UC.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedManualATicketFields(NOLOCK) C
     INNER JOIN #NewUseCaseDetails (NOLOCK) UC ON ( UC.UseCaseTitle LIKE '%' + C.ActivityName + '%' AND ISNULL(C.ActivityName,'')!='') 
	 
	  UNION

	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedManualATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseDescription LIKE '%' + C.TicketDescription + '%' AND ISNULL(C.TicketDescription,'')!='') 

	  UNION

	  SELECT DISTINCT 
		C.HealingTicketID,
		C.ProjectID,
		US.UseCaseDetailID AS 'ID',
		US.UseCaseID ,
        C.ManualNonDebt
     FROM #ComparedManualATicketFields(NOLOCK) C
     INNER JOIN [AVL].Effort_UseCaseDetails (NOLOCK) US ON ( US.NoiseEliminatedUseCaseDescription LIKE '%' + C.ActivityName + '%' AND ISNULL(C.ActivityName,'')!='')
 		UNION 
	 SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			T.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedManualATicketFields  (NOLOCK) C
			JOIN AVL.Effort_UseCaseDetails T ON (T.Tags LIKE '%' + C.ActivityName + '%' AND ISNULL(T.Tags,'')!='')
	   UNION 
	   SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			UC.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedManualATicketFields  (NOLOCK) C
			JOIN AVL.UseCaseTagDetail T ON (T.Tag LIKE '%' + C.ActivityName + '%' AND ISNULL(T.Tag,'')!='')
			JOIN  AVL.UseCaseDetails UC ON UC.ID = T.UseCaseDetailId
			UNION 
	 SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			T.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedManualATicketFields  (NOLOCK) C
			JOIN AVL.Effort_UseCaseDetails T ON (T.Tags LIKE '%' + C.TicketDescription + '%' AND ISNULL(T.Tags,'')!='')
	   UNION 
	   SELECT
			C.HealingTicketID,
			C.ProjectID,
			T.UseCaseDetailID AS 'ID',
			UC.UseCaseID ,
			C.ManualNonDebt
	   FROM
			#ComparedManualATicketFields  (NOLOCK) C
			JOIN AVL.UseCaseTagDetail T ON (T.Tag LIKE '%' + C.TicketDescription + '%' AND ISNULL(T.Tag,'')!='')
			JOIN  AVL.UseCaseDetails UC ON UC.ID = T.UseCaseDetailId
 )M


   SELECT DISTINCT *,'System' AS CreatedBy,GETDATE() AS CreatedOn INTO #TempFinalResult FROM
     (SELECT TS.*,DU.IsMappedSolution FROM #TempSystemATickets TS
	    LEFT JOIN [AVL].[DEBT_UseCaseSolutionIdentificationDetails] (NOLOCK) DU ON DU.UseCaseSolutionMapId=TS.ID AND DU.HealingTicketID=TS.HealingTicketID
		AND ISNULL(DU.IsDeleted,0)=0
	    UNION
      SELECT TM.*,DU.IsMappedSolution FROM #TempManualATickets TM
	  	  LEFT JOIN [AVL].[DEBT_UseCaseSolutionIdentificationDetails] (NOLOCK) DU ON DU.UseCaseSolutionMapId=TM.ID AND DU.HealingTicketID=TM.HealingTicketID
		  AND ISNULL(DU.IsDeleted,0)=0
	  ) F


     DELETE DU FROM [AVL].[DEBT_UseCaseSolutionIdentificationDetails] DU
         INNER JOIN #TempFinalResult T
          ON T.HealingTicketID=DU.HealingTicketID
          WHERE ISNULL(DU.IsMappedSolution,0)=0 

   INSERT INTO [AVL].[DEBT_UseCaseSolutionIdentificationDetails] (UseCaseID,HealingTicketID, UseCaseSolutionMapId,CreatedBy,CreatedOn,ProjectID)
	  SELECT UseCaseID,HealingTicketID,ID,CreatedBy,CreatedOn,ProjectID  FROM  #TempFinalResult WHERE ISNULL(IsMappedSolution,0)=0

	SELECT @InsertedRecordCount=COUNT(HealingTicketID) FROM #TempFinalResult WHERE ISNULL(IsMappedSolution,0)=0

    DROP TABLE #TempSystemATickets
    DROP TABLE #TempManualATickets
	DROP TABLE #TempFinalResult
	DROP TABLE #ComparedSystemATicketFields
	DROP TABLE #ComparedManualATicketFields
    DROP TABLE #Heal_ProjectPatternMapping
	DROP TABLE #NewUseCaseDetails

     --Job Status Update
			UPDATE MAS.JobStatus set EndDateTime = GETDATE(),JobStatus = @JobStatusSuccess, InsertedRecordCount=@InsertedRecordCount where ID  = @JobID

  SET NOCOUNT OFF;
  
  END TRY
  BEGIN CATCH
  UPDATE MAS.JobStatus set EndDateTime = GETDATE(),JobStatus = @JobStatusFailed where ID  = @JobID
	DECLARE @ErrorMessage VARCHAR(MAX);
	DECLARE @MailSubject	NVARCHAR(500);		
		DECLARE @MailBody		NVARCHAR(MAX);
		DECLARE @MailRecipients NVARCHAR(MAX);
		DECLARE @MailContent	NVARCHAR(500);
		DECLARE @Status CHAR(1)
		DECLARE @ScriptName  NVARCHAR(100)
		
		SELECT @MailSubject = CONCAT(@@servername, ': Use Case Refresh Job Failure Notification')			
		SELECT @ErrorMessage = ERROR_MESSAGE()	
		SET @MailContent = 'Oops! Error Occurred in Use Case Refresh!'
		SET @Status = 'E'	
		SET @ScriptName = '[AVL].[RecommendationUsecaseForATicketsJob]'
		SELECT @MailBody =[dbo].[fn_FormatEmailBody](@ErrorMessage,@MailContent,@Status,@ScriptName)
		SET @MailRecipients=(SELECT ConfigValue FROM [AVL].[AppLensConfig] WHERE ConfigId = 1 )
		---Mail Option Added by Annadurai on 11.01.2019 to send mail during error Job
		EXEC [AVL].[SendDBEmail] @To=@MailRecipients,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody
  END CATCH   
END


