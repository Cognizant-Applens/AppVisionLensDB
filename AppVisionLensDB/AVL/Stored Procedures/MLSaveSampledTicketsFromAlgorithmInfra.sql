
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[MLSaveSampledTicketsFromAlgorithmInfra] @ProjectID                NVARCHAR(100), 
                                                      @TVP_lstDebtSampleTickets [AVL].[TVPDebtSampledTicketsInfra] READONLY,
                                                      @UserID                   NVARCHAR(MAX) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

--Get the Flag for MultiLingual enabled for the project
DECLARE @IsMultiLingualEnabled int = 0

SELECT * FROM @TVP_lstDebtSampleTickets
SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster PM
WHERE PM.ProjectID = @ProjectID
AND PM.IsDeleted = 0)

SELECT MLT.ID,MLT.TimeTickerID,MLT.TicketDescription,MLT.IsTicketDescriptionUpdated,MLT.ResolutionRemarks,MLT.TicketSummary,MLT.Category,MLT.Comments,
MLT.IsCategoryUpdated,MLT.IsCommentsUpdated,MLT.IsTicketSummaryUpdated,MLT.IsFlexField1Updated,
MLT.IsFlexField2Updated,MLT.IsFlexField3Updated,MLT.IsFlexField4Updated,MLT.IsTypeUpdated,T.TicketID
INTO
#tmpMultilingualTranslatedValues 
FROM [AVL].[TK_TRN_Multilingual_TranslatedInfraTicketDetails] MLT
JOIN AVL.TK_TRN_InfraTicketDetail T ON MLT.TimeTickerID= T.TimeTickerID 
WHERE  MLT.IsTicketDescriptionUpdated = 0

--------------------------------------------------------------------------------------- 
          -- Insert sampled tickets from hivepath to ticketsaftersampling   
          CREATE TABLE #DEBTSAMPLEDTICKETS 
            ( 
               InitialLearningId      INT NULL, 
               ProjectId              BIGINT NULL, 
               TicketId               NVARCHAR(MAX) NULL, 
               TicketDescription      NVARCHAR(MAX) NULL, 
               AdditionalText         NVARCHAR(MAX), 
               TowerId                BIGINT NULL, 
               --applicationtypeid      INT NULL, 
               --Technologyid           INT NULL, 
               DebtClassificationId   INT NULL, 
               AvoidableFlagId        INT NULL, 
               ResidualFlagId         INT NULL, 
               CauseCodeId            INT NULL, 
               ResolutionCodeId       INT NULL, 
               TowerName              NVARCHAR(MAX) NULL, 
               --applicationtypename    NVARCHAR(MAX) NULL, 
               --technologyname         NVARCHAR(MAX) NULL, 
               DebtClassificationName NVARCHAR(MAX) NULL, 
               AvoidableFlagName      NVARCHAR(50) NULL, 
               ResidualDebtName       NVARCHAR(50) NULL, 
               DescBaseWorkPattern    NVARCHAR(MAX), 
               DescSubWorkPattern     NVARCHAR(MAX), 
               ResBaseWorkPattern     NVARCHAR(MAX), 
               ResSubWorkPattern      NVARCHAR(MAX), 
               CauseCodeName          NVARCHAR(MAX) NULL, 
               ResolutionCodeName     NVARCHAR(MAX) NULL, 
            ) 

         
          DECLARE @InitialLearningID INT; 
          DECLARE @OptField INT; 

          --latest transaction id for initial learning   
          SET @InitialLearningID=(SELECT TOP 1 id 
                                  FROM   AVL.ML_PRJ_InitialLearningStateInfra 
                                  WHERE  ProjectID = @ProjectID 
                                  ORDER  BY ID DESC) 
          SET @OptField=(SELECT OptionalFieldID 
                         FROM   AVL.ML_MAP_OptionalProjMappingInfra 
                         WHERE  ProjectId = @ProjectID 
                                AND IsDeleted = 0) 

          DECLARE @CustomerID INT=0; 
          DECLARE @IsCognizantID INT; 

          SET @CustomerID=(SELECT TOP 1 CustomerID 
                           FROM   AVL.MAS_LOGINMASTER(NOLOCK) 
                           WHERE  ProjectID = @ProjectID 
                                  AND IsDeleted = 0) 
          SET @IsCognizantID=(SELECT TOP 1 IsCognizant 
                              FROM   AVL.CUSTOMER(NOLOCK) 
                              WHERE  CustomerID = @CustomerID 
                                     AND IsDeleted = 0) 

          DECLARE @InitialLearningID2 INT 

          SET @InitialLearningID2= (SELECT TOP 1 InitialLearningID 
                                    FROM   AVL.ML_TRN_RegeneratedTowerDetails 
                                    WHERE  ProjectID = @ProjectID) 

          --IF @IsCognizantID=0   
          --BEGIN   
          INSERT INTO #DEBTSAMPLEDTICKETS 
                      (InitialLearningId, 
                       ProjectId, 
                       TicketId, 
                       TicketDescription, 
                       TowerName,                        
                       DebtClassificationName, 
                       AvoidableFlagName, 
                       ResidualDebtName, 
                       CauseCodeName, 
                       ResolutionCodeName, 
                       DescBaseWorkPattern, 
                       DescSubWorkPattern, 
                       ResBaseWorkPattern, 
                       ResSubWorkPattern) 
          SELECT @InitialLearningID, 
                 @ProjectID, 
                 TicketID, 
                 TicketDescription, 
                 TowerName,                  
                 DebtClassification, 
                 AvoidableFlag, 
                 ResidualDebt, 
                 CauseCode, 
                 ResolutionCode, 
                 DescBaseWorkPattern,
	             DescSubWorkPattern,
	             ResBaseWorkPattern,
	             ResSubWorkPattern
          FROM   @TVP_lstDebtSampleTickets 

          --updating temp table with ids of the master values for resp projectid   
          --  ---- Debt Classification                              
          UPDATE DP 
          SET    DP.DebtClassificationId = X3.DebtClassificationID 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 JOIN AVL.DEBT_MAS_DebtClassificationInfra X3 
                   ON DP.DebtClassificationName = X3.DebtClassificationName 

          UPDATE #DEBTSAMPLEDTICKETS 
          SET    AvoidableFlagName = 'Yes' 
          WHERE  AvoidableFlagName = 'Avoidable' 
                  OR AvoidableFlagName = 'avoidable' 

          UPDATE #DEBTSAMPLEDTICKETS 
          SET    AvoidableFlagName = 'No' 
          WHERE  AvoidableFlagName = 'UnAvoidable' 
                  OR AvoidableFlagName = 'Unavoidable' 

          ---- Avoidable Flag                                 
          UPDATE DP 
          SET    DP.AvoidableFlagId = X3.AvoidableFlagID 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 JOIN AVL.DEBT_MAS_AVOIDABLEFLAG X3 
                   ON DP.AvoidableFlagName = X3.AvoidableFlagName 

          ---- Residual Debt     ML                             
          UPDATE DP 
          SET    DP.ResidualFlagId = x3.ResidualDebtID 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] X3 
                   ON DP.ResidualDebtName = X3.ResidualDebtName 

          --      ---Cause Code  --ML   
          UPDATE DP 
          SET    DP.CauseCodeId = DCC.CauseID 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 JOIN [AVL].[DEBT_MAP_CAUSECODE] DCC 
                   ON LTRIM(RTRIM(DP.CauseCodeName)) =  CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DCC.McauseCode,'') != ''  
				   THEN LTRIM(RTRIM(DCC.Mcausecode)) ELSE DCC.causecode  END 
                      AND DCC.IsDeleted = 0 
          WHERE  DCC.ProjectID = @projectid 
         --     ---Resolution Code  --ML   
          UPDATE DP 
          SET    DP.ResolutionCodeId = DRC.ResolutionID 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] DRC 
                   ON DP.ResolutionCodeName =  CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DRC.MResolutionCode,'') != ''  
				   THEN LTRIM(RTRIM(DRC.MResolutionCode)) ELSE DRC.ResolutionCode  END 
                      AND DRC.IsDeleted = 0 
          WHERE  DRC.ProjectID = @projectid 

          --application id update       
SELECT A.* 
          INTO   #APPINFO 
          FROM   (SELECT AMR.InfraTowerTransactionID,AMR.TowerName,	IPM.TowerID,	  
		  IOT.HierarchyOneTransactionID,
		  IOT.HierarchyName AS Hierarchy1Name,
		  ITT.HierarchyTwoTransactionID,
		  ITT.HierarchyName AS Hierarchy2Name FROM AVL.InfraTowerDetailsTransaction(NOLOCK) AMR
INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) IPM  
    ON AMR.InfraTowerTransactionID=IPM.TowerID AND IPM.ProjectID=@projectid AND ISNULL(IPM.IsDeleted,0)=0
LEFT JOIN AVL.InfraHierarchyMappingTransaction(NOLOCK) IHT
    ON IHT.CustomerID=AMR.CustomerID
	AND IHT.InfraTransMappingID=AMR.InfraTransMappingID
	AND ISNULL(IHT.IsDeleted,0)=0  
LEFT JOIN  AVL.InfraHierarchyOneTransaction(NOLOCK) IOT
    ON IHT.CustomerID=IOT.CustomerID 
    AND IHT.HierarchyOneTransactionID=IOT.HierarchyOneTransactionID 
	AND IOT.IsDeleted=0
LEFT JOIN AVL.InfraHierarchyTwoTransaction(NOLOCK) ITT 
    ON IHT.CustomerID=ITT.CustomerID 
    AND IHT.HierarchyTwoTransactionID=ITT.HierarchyTwoTransactionID 
	AND ITT.IsDeleted=0 

                  WHERE  AMR.InfraTowerTransactionID IS NOT NULL 
                         AND AMR.TowerName IS NOT NULL 
                         AND AMR.IsDeleted = 0
                         AND AMR.CustomerID = @CustomerID) AS A 

          UPDATE DP 
          SET    DP.TowerId = AI.TowerId
          FROM   #DEBTSAMPLEDTICKETS DP 
                 INNER JOIN #APPINFO AI 
                         ON AI.TowerName = DP.TowerName 
SELECT * FROM #DEBTSAMPLEDTICKETS

SELECT * FROM #APPINFO
          --UPDATE DP 
          --SET    DP.applicationtypeid = AI.applicationtypeid 
          --FROM   #DEBTSAMPLEDTICKETS DP 
          --       INNER JOIN #APPINFO AI 
          --               ON AI.applicationtypename = DP.applicationtypename 

          --UPDATE DP 
          --SET    DP.technologyid = AI.primarytechnologyid 
          --FROM   #DEBTSAMPLEDTICKETS DP 
          --       INNER JOIN #APPINFO AI 
          --               ON AI.primarytechnologyname = DP.technologyname 

          --initial learning id update   
          UPDATE #DEBTSAMPLEDTICKETS 
          SET    InitialLearningId = @InitialLearningID 

		    UPDATE ST 
          SET    ST.TicketDescription =TM.TicketDescription
          FROM   #DEBTSAMPLEDTICKETS ST 
                 INNER JOIN [AVL].[TK_TRN_InfraTicketDetail](NOLOCK) TM 
                         ON ST.ProjectId = TM.ProjectID  AND ST.TicketId=TM.TicketID
          WHERE  TM.ProjectID = @projectid 


		IF @IsMultiLingualEnabled=1
		BEGIN
          UPDATE ST 
          SET    ST.TicketDescription = CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(MLT.TicketDescription,'') != ''  THEN MLT.TicketDescription ELSE TM.TicketDescription END 
          FROM   #DEBTSAMPLEDTICKETS ST 
                 INNER JOIN [AVL].[TK_TRN_InfraTicketDetail](NOLOCK) TM 
                         ON ST.ProjectId = TM.ProjectID 
				INNER JOIN #tmpMultilingualTranslatedValues MLT
                    ON MLT.TicketID = TM.TicketID
					AND MLT.TimeTickerID = TM.TimeTickerID
          WHERE  TM.ProjectID = @projectid 
		END

          -- update additional text if optional field is for the specific project   
          UPDATE ST 
          SET    ST.additionaltext = CASE WHEN @OptField = 2 THEN TM.ticketsummary 
                                       WHEN @OptField = 1 THEN TM.resolutionremarks 
                                       WHEN @OptField = 3 THEN TM.comments 
                                       ELSE '' 
                                     END 
          FROM   #DEBTSAMPLEDTICKETS ST 
                 INNER JOIN [AVL].TK_TRN_InfraTicketDetail(NOLOCK) TM 
                         ON ST.ProjectId = TM.ProjectID 
				

          WHERE  TM.projectid = @projectid 

          UPDATE ST 
          SET    ST.ticketdescription = CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(MLT.TicketDescription,'') != ''  THEN MLT.TicketDescription ELSE PM.TicketDescription END 
          FROM   #DEBTSAMPLEDTICKETS ST 
                 INNER JOIN [AVL].[TK_TRN_InfraTicketDetail](NOLOCK) PM 
                         ON ST.projectid = PM.projectid 
                            AND ST.ticketid = PM.ticketid 
                 LEFT JOIN #tmpMultilingualTranslatedValues MLT
                    ON  MLT.TimeTickerID = PM.TimeTickerID
	                AND MLT.TicketID = PM.TicketID
         
          IF EXISTS(SELECT TicketId 
                    FROM   #DEBTSAMPLEDTICKETS) 
            BEGIN 
                IF( (SELECT IsRegenerated 
                     FROM   AVL.ML_PRJ_InitialLearningStateInfra 
                     WHERE  ProjectID = @ProjectID 
                            AND ID = @initiallearningID) = 1 ) 
                  BEGIN 
                      --if it is regenerated then tickets of only that specific tower will be deleted   
                      UPDATE TS 
                      SET    TS.IsDeleted = 1 
                      FROM   AVL.ML_TRN_TicketsAfterSamplingInfra TS 
                             JOIN AVL.ML_TRN_RegeneratedTowerDetails RAD 
                               ON TS.TowerID = RAD.TowerID 
                                  AND RAD.ProjectID = TS.ProjectID 
                                  AND RAD.InitialLearningID = @initiallearningID 
                                  AND RAD.ProjectID = @ProjectID 

                      --and tickets of that particular tower ids will be inserted   
                      INSERT INTO AVL.ML_TRN_TicketsAfterSamplingInfra 
                                  (InitialLearningId, 
                                   ProjectID, 
                                   TicketID, 
                                   TicketDescription, 
                                   AdditionalText, 
                                   TowerID, 
                                   --applicationtype, 
                                   --technologyid, 
                                   DebtClassificationID, 
                                   AvoidableFlagID, 
                                   ResidualDebtID, 
                                   Desc_Base_WorkPattern, 
                                   Desc_Sub_WorkPattern, 
                                   Res_Base_WorkPattern, 
                                   Res_Sub_WorkPattern, 
                                   CauseCodeID, 
                                   ResolutionCodeID, 
                                   IsDeleted) 
                      SELECT @InitialLearningID, 
                             @ProjectID, 
                             DS.TicketId, 
                             DS.TicketDescription, 
                             DS.AdditionalText, 
                             DS.TowerId, 
                             --applicationtypeid, 
                             --technologyid, 
                             DS.DebtClassificationId, 
                             DS.AvoidableFlagId, 
                             DS.ResidualFlagId, 
                             DS.DescBaseWorkPattern, 
                             DS.DescSubWorkPattern, 
                             DS.ResBaseWorkPattern, 
                             DS.ResSubWorkPattern, 
                             DS.CauseCodeId, 
                             DS.ResolutionCodeId, 
                             0 
                      FROM   #DEBTSAMPLEDTICKETS DS 
                             JOIN AVL.ML_TRN_RegeneratedTowerDetails RAD 
                               ON DS.TowerId = RAD.TowerID 
                                  AND RAD.ProjectID = DS.ProjectId 
                                  AND RAD.InitialLearningID = @initiallearningID 
                                  AND RAD.ProjectID = @ProjectID 

                      UPDATE SJS 
                      SET    SJS.IsDARTProcessed = 'Y' 
                      FROM   AVL.ML_TRN_MLSamplingJobStatusInfra SJS 
                             JOIN AVL.ML_TRN_RegeneratedTowerDetails RAD 
                               ON RAD.ProjectID = SJS.ProjectID 
                                  AND RAD.InitialLearningID = @initiallearningID 
                                  AND RAD.ProjectID = @ProjectID 
                      WHERE  SJS.ProjectID = @ProjectID 
                             AND SJS.JobType = 'Sampling' 
                             AND ( SJS.IsDeleted = 0 
                                    OR SJS.IsDeleted IS NULL ) 

                      UPDATE ILS 
                      SET    ILS.IsSamplingSentOrReceived = 'Received' 
                      FROM   AVL.ML_PRJ_InitialLearningStateInfra ILS 
                             JOIN AVL.ML_TRN_RegeneratedTowerDetails RAD 
                               ON RAD.ProjectID = ILS.ProjectID 
                                  AND RAD.InitialLearningID = @initiallearningID 
                                  AND RAD.ProjectID = @ProjectID 
                      WHERE  ILS.ProjectID = @ProjectID 
                             AND ILS.IsDeleted = 0 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE AVL.ML_TRN_TicketsAfterSamplingInfra 
                      SET    IsDeleted = 1 
                      WHERE  ProjectID = @projectid 

                      INSERT INTO AVL.ML_TRN_TicketsAfterSamplingInfra 
                                  (InitialLearningId, 
                                   ProjectID, 
                                   TicketID, 
                                   TicketDescription, 
                                   additionaltext, 
                                   TowerID, 
                                   --applicationtype, 
                                   --technologyid, 
                                   DebtClassificationID, 
                                   AvoidableFlagID, 
                                   ResidualDebtID, 
                                   Desc_Base_WorkPattern, 
                                   Desc_Sub_WorkPattern, 
                                   Res_Base_WorkPattern, 
                                   Res_Sub_WorkPattern, 
                                   CauseCodeID, 
                                   ResolutionCodeID, 
                                   IsDeleted) 
                      SELECT @InitialLearningID, 
                             @ProjectID, 
                             TicketId, 
                             TicketDescription, 
                             AdditionalText, 
                             TowerId, 
                             --applicationtypeid, 
                             --technologyid, 
                             DebtClassificationId, 
                             AvoidableFlagId, 
                             ResidualFlagId, 
                             DescBaseWorkPattern, 
                             DescSubWorkPattern, 
                             ResBaseWorkPattern, 
                             ResSubWorkPattern, 
                             CauseCodeId, 
                             ResolutionCodeId, 
                             0 
                      FROM   #DEBTSAMPLEDTICKETS 

                      UPDATE AVL.ML_TRN_MLSamplingJobStatusInfra 
                      SET    IsDARTProcessed = 'Y' 
                      WHERE  ProjectID = @ProjectID 
                             AND JobType = 'Sampling' 
                             AND ( IsDeleted = 0 
                                    OR IsDeleted IS NULL ) 

                      UPDATE AVL.ML_PRJ_InitialLearningStateInfra 
                      SET    IsSamplingSentOrReceived = 'Received' 
                      WHERE  ProjectID = @ProjectID 
                             AND IsDeleted = 0 
                  END 

                --=================================Mail Content==========================------   
                SELECT TOP 1 EmployeeEmail, 
                             EmployeeName 
                INTO   #EMPLOYEEDATA 
                FROM   AVL.MAS_LOGINMASTER(NOLOCK) 
                WHERE  EmployeeID = @UserID 
                       AND ProjectID = @ProjectID 
                       AND IsDeleted = 0 

                DECLARE @tableHTML VARCHAR(MAX); 
                DECLARE @EmailProjectName VARCHAR(MAX); 
                DECLARE @Subjecttext VARCHAR(MAX); 
                DECLARE @MailingToList VARCHAR(MAX); 
                DECLARE @UserName VARCHAR(MAX); 

                SET @MailingToList = (SELECT EmployeeEmail 
                                      FROM   #EMPLOYEEDATA) 
                SET @UserName=(SELECT EmployeeName 
                               FROM   #EMPLOYEEDATA) 

                DECLARE @iscog INT=(SELECT c.iscognizant 
                  FROM   AVL.MAS_PROJECTMASTER(NOLOCK) pm 
                         JOIN AVL.CUSTOMER(NOLOCK) c 
                           ON c.CustomerID = pm.CustomerID 
                  WHERE  pm.ProjectID = @ProjectID 
                         AND pm.IsDeleted = 0 
                         AND c.IsDeleted = 0) 

                IF( ( @iscog ) = 1 ) 
                  BEGIN 
                      SET @EmailProjectName=(SELECT DISTINCT CONCAT(PM.EsaProjectID, '-', PM.ProjectName) 
                                             FROM   AVL.MAS_PROJECTMASTER(NOLOCK) PM 
                                             WHERE  PM.ProjectID = @ProjectID) 
                  END 
                ELSE 
                  BEGIN 
                      SET @EmailProjectName=(SELECT DISTINCT PM.ProjectName 
                                             FROM   AVL.MAS_PROJECTMASTER(NOLOCK) PM 
                                             WHERE  PM.ProjectID = @ProjectID) 
                  END 

             
                SET @Subjecttext = 'Initial Learning - Sampling : ' 
                                   + @EmailProjectName 

                PRINT @Subjecttext 

                -----------------------------------------   
                ---------------mailer body---------------margin-left:170px;   
                SET @tableHTML ='<html style="width:auto !important">' 
                                + '<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" style="text-align:center;width:840">' 
                                + 
                '<table width="840" face="Times New Roman,serif" border="0" cellpadding="0" cellspacing="0" style="margin-left:60px;font-family:sans-serif;font-size:14px;font-weight:normal">' 
                                + '<tbody>' + '<tr>' 
                                + '<td valign="top" style="padding: 0;">' 
                                + '<div align="center" style="text-align: center;">' 
                                + '<table width="840" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">' 
                                + '<tbody>' + '<tr style="height:50px">' 
                                + '<td width="auto" valign="top" align="center">' 
                                + '<img src="\\ctsc01260327301\Banner\ApplensBanner.png" width="840" height="50" style="border-width: 0px;"/>' 
                                + '</td>' + '</tr>' 
                                + '<tr style="background-color:#F0F8FF">' 
                                + '<td valign="top" style="padding: 0;">' 
                                + '<div align="center" style="text-align: center;margin-left:50px">' 
                                + '<table width="840" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">' 
                                + '<tbody>' + '</br></BR>' 
                                + N'<left>  <font-weight:normal>  &nbsp;&nbsp;Dear ' 
                                + @UserName + ' ,' + '</BR>' 
                                + '&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp' 
                                + '</BR>' 
                                + '&nbsp;&nbsp;Request you to navigate to Ticketing Module - > Lead Self Service - >   Initial Learning Review and do the Debt classification for the'
                                + '</BR>' 
                                + '&nbsp;&nbsp;tickets which are identified for Sampling.' 
                                + '</font>   </Left>' 
                                + N'    <p align="left">    <font color="Black" Size = "2" font-weight=bold>    <b>&nbsp;&nbsp;Thanks & Regards,</b>   </font>    </BR>   &nbsp;&nbsp;Solution Zone Team 	   </BR>    </BR>     <p style="text-align: center;">     **This is an Auto Generated Mail. Please Do not reply to this Email** </p> </p>'
                + '</tbody>' + '</table>' + '</div>' + '</td>' 
                + '</tr>' + '</tbody>' + '</table>' + '</div>' 
                + '</td>' + '</tr>' + '</tbody>' + '</table>' 
                + '</body>' + '</html>' 

    INSERT INTO DBO.EMAILCOLLECTION 
    SELECT @MailingToList, 
           '', 
           '', 
           @Subjecttext, 
           @tableHTML, 
           0, 
           2, 
           Getdate(), 
           '' 

    -------------executing mail------------- 
	EXEC [AVL].[SendDBEmail] @To=@MailingToList,
    @From='ApplensSupport@cognizant.com',
    @Subject =@Subjecttext,
    @Body = @tableHTML

END 

    COMMIT TRAN 
END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 

        SELECT @ErrorMessage = ERROR_MESSAGE() 

        ROLLBACK TRAN 

        --INSERT Error       
        EXEC AVL_INSERTERROR 
          '[AVL].[MLSaveSampledTicketsFromAlgorithmInfra]', 
          @ErrorMessage, 
          @ProjectID, 
          0 
    END CATCH 
END


