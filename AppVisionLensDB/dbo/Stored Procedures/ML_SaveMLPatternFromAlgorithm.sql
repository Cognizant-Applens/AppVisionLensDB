
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
-- Author:           Devika 
-- Create date:      11 FEB 2018 
-- Description:      SP for Initial Learning 

-- MODIFICATION HISTORY 
-- USERID    NAME     DATE             REASON 
-- 687591    MENAKA   29-5-2019        Included code for MultiLingual text from extended table 
-- ============================================================================ 
CREATE    PROCEDURE [dbo].[ML_SaveMLPatternFromAlgorithm] -- 3rd mail 
  @ProjectID          BIGINT, 
  @UserID             NVARCHAR(50), 
  @TVP_lstDebtPattern TVP_DEBTMLPATTERN READONLY 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          --creating temp table for patterns 
          CREATE TABLE #DEBTPATTERN 
            ( 
               InitialLearningID             INT NULL, 
               ProjectID                     BIGINT NULL, 
               ApplicationID                 BIGINT NULL, 
               ApplicationTypeID             INT NULL, 
               TechnologyID                  INT NULL, 
               TicketPattern                 NVARCHAR(MAX) NULL, 
               subPattern                    NVARCHAR(MAX) NULL, 
               additionalPattern             NVARCHAR(MAX) NULL, 
               additionalSubPattern          NVARCHAR(MAX) NULL, 
               MLResidualFlagID              INT NULL, 
               MLDebtClassificationID        INT NULL, 
               MLAvoidableFlagID             INT NULL, 
               MLCauseCodeID                 INT NULL, 
               MLResolutionCodeID            INT NULL, 
               MLAccuracy                    DECIMAL(18, 2) NULL, 
               TicketOccurence               INT NULL, 
               AnalystResidualFlagID         INT NULL, 
               AnalystResolutionCodeID       INT NULL, 
               AnalystCauseCodeID            INT NULL, 
               AnalystDebtClassificationID   INT NULL, 
               AnalystAvoidableFlagID        INT NULL, 
               ApplicationName               NVARCHAR(MAX) NULL, 
               ApplicationTypeName           NVARCHAR(1000) NULL, 
               TechnologyName                NVARCHAR(MAX) NULL, 
               AnalystDebtClassificationName NVARCHAR(1000) NULL, 
               AnalystAvoidableFlagName      NVARCHAR(50) NULL, 
               AnalystResidualDebtName       NVARCHAR(50) NULL, 
               AnalystCauseCodeName          NVARCHAR(MAX) NULL, 
               AnalystResolutionCodeName     NVARCHAR(MAX) NULL, 
               MLResidualFlagName            NVARCHAR(MAX) NULL, 
               MLDebtClassificationName      NVARCHAR(50) NULL, 
               MLAvoidableFlagName           NVARCHAR(50) NULL, 
               MLCauseCodeName               NVARCHAR(MAX) NULL, 
               MLResolutionCode              NVARCHAR(MAX) NULL, 
               Classifiedby                  NVARCHAR(MAX) NULL 
            ) 
			--Get the Flag for MultiLingual enabled for the project
			DECLARE @IsMultiLingualEnabled int = 0

           SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster PM
           WHERE PM.ProjectID = @ProjectID
           AND PM.IsDeleted = 0)

          DECLARE @InitialLearningID INT; 
          DECLARE @IsRegenerated INT 

          SET @InitialLearningID=(SELECT TOP 1 ID 
                                  FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                                  WHERE  ProjectID = @ProjectID 
                                  ORDER  BY ID DESC) 
          SET @IsRegenerated = (SELECT ISNULL(IsRegenerated, 0) 
                                FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                                WHERE  ID = @InitialLearningID) 

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

          -- selecting the details from type and inserting into temp table 
          INSERT INTO #DEBTPATTERN 
                      (InitialLearningID, 
                       ProjectID, 
                       ApplicationName, 
                       ApplicationTypeName, 
                       TechnologyName, 
                       TicketPattern, 
                       subPattern, 
                       additionalPattern, 
                       additionalSubPattern, 
                       MLAccuracy, 
                       AnalystDebtClassificationName, 
                       AnalystAvoidableFlagName, 
                       AnalystResidualDebtName, 
                       AnalystCauseCodeName, 
                       AnalystResolutionCodeName, 
                       MLResidualFlagName, 
                       MLDebtClassificationName, 
                       MLAvoidableFlagName, 
                       TicketOccurence, 
                       MLCauseCodeName, 
                       Classifiedby, 
                       MLResolutionCode) 
          SELECT @InitialLearningID, 
                 @ProjectID, 
                 ApplicationName, 
                 ApplicationType, 
                 Technology, 
                 CASE WHEN MLWorkPattern !='' THEN  MLWorkPattern ELSE '0' END, 
                 DescSubPattern, 
                 ResBasePattern, 
                 ResSubPattern, 
                 MLRuleAccuracy, 
                 DebtClassification, 
                 AvoidableFlag, 
                 ResidualDebt, 
                 CauseCode, 
                 ResolutionCode, 
                 MLResidualDebt, 
                 MLDebtClassification, 
                 MLAvoidableFlag, 
                 TicketOccurence, 
                 MLCauseCode, 
                 Classifiedby, 
                 MLResolutionCode 
          FROM   @TVP_lstDebtPattern 

          ---- Debt Classification  Analyst                              
          UPDATE DP 
          SET    DP.AnalystDebtClassificationID = X3.DebtClassificationID 
          FROM   #DEBTPATTERN DP 
                 JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] X3 
                   ON DP.AnalystDebtClassificationName = X3.DebtClassificationName 

          ---- Debt Classification ML                           
          UPDATE DP 
          SET    DP.MLDebtClassificationID = x3.DebtClassificationID 
          FROM   #DEBTPATTERN DP 
                 JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] X3 
                   ON DP.MLDebtClassificationName = X3.DebtClassificationName 

          UPDATE #DEBTPATTERN 
          SET    AnalystAvoidableFlagName = 'Yes' 
          WHERE  AnalystAvoidableFlagName = 'Avoidable' 
                  OR AnalystAvoidableFlagName = 'avoidable' 

          UPDATE #DEBTPATTERN 
          SET    AnalystAvoidableFlagName = 'No' 
          WHERE  AnalystAvoidableFlagName = 'UnAvoidable' 
                  OR AnalystAvoidableFlagName = 'Unavoidable' 

          UPDATE #DEBTPATTERN 
          SET    MLAvoidableFlagName = 'Yes' 
          WHERE  MLAvoidableFlagName = 'Avoidable' 
                  OR AnalystAvoidableFlagName = 'avoidable' 

          UPDATE #DEBTPATTERN 
          SET    MLAvoidableFlagName = 'No' 
          WHERE  MLAvoidableFlagName = 'UnAvoidable' 
                  OR AnalystAvoidableFlagName = 'Unavoidable' 

          ---- Avoidable Flag      Analyst                              
          UPDATE DP 
          SET    DP.AnalystAvoidableFlagID = X3.[AvoidableFlagID] 
          FROM   #DEBTPATTERN DP 
                 JOIN AVL.DEBT_MAS_AVOIDABLEFLAG X3 
                   ON DP.AnalystAvoidableFlagName = X3.[AvoidableFlagName] 

          ---- Avoidable Flag     ML                           
          UPDATE DP 
          SET    DP.MLAvoidableFlagID = X3.[AvoidableFlagID] 
          FROM   #DEBTPATTERN DP 
                 JOIN AVL.DEBT_MAS_AVOIDABLEFLAG X3 
                   ON DP.MLAvoidableFlagName = X3.[AvoidableFlagName] 

          ---- Residual Debt     ML                           
          UPDATE DP 
          SET    DP.MLResidualFlagID = X3.[ResidualDebtID] 
          FROM   #DEBTPATTERN DP 
                 JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] X3 
                   ON DP.MLResidualFlagName = X3.[ResidualDebtName] 

          ---- Residual Debt    analyst                           
          UPDATE DP 
          SET    DP.AnalystResidualFlagID = X3.[ResidualDebtID] 
          FROM   #DEBTPATTERN DP 
                 JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] X3 
                   ON DP.AnalystResidualDebtName = X3.[ResidualDebtName] 

          ---Cause Code  --ML 
          UPDATE DP 
          SET    DP.MLCauseCodeID = DCC.CauseID 
          FROM   #DEBTPATTERN DP 
                 JOIN [AVL].[DEBT_MAP_CAUSECODE] DCC 
                   ON DP.MLCauseCodeName = CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DCC.McauseCode,'') != ''  
				   THEN LTRIM(RTRIM(DCC.Mcausecode)) ELSE DCC.causecode  END 
                      AND DCC.IsDeleted = 0 
          WHERE  DCC.ProjectID = @projectid 

          UPDATE DP 
          SET    DP.AnalystCauseCodeID = DCC.CauseID 
          FROM   #DEBTPATTERN DP 
                 JOIN [AVL].[DEBT_MAP_CAUSECODE] DCC 
                   ON DP.AnalystCauseCodeName = CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DCC.McauseCode,'') != ''  
				   THEN LTRIM(RTRIM(DCC.Mcausecode)) ELSE DCC.causecode  END 
                      AND DCC.IsDeleted = 0 
          WHERE  DCC.ProjectID = @projectid 

          ---Resolution Code  --ML 
          UPDATE DP 
          SET    DP.AnalystResolutionCodeID = DRC.ResolutionID 
          FROM   #DEBTPATTERN DP 
                 JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] DRC 
                   ON DP.AnalystResolutionCodeName =CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DRC.MResolutionCode,'') != ''  
				   THEN LTRIM(RTRIM(DRC.MResolutionCode)) ELSE DRC.ResolutionCode  END 
                      AND DRC.IsDeleted = 0 
          WHERE  DRC.ProjectID = @projectid 

          UPDATE DP 
          SET    DP.MLResolutionCodeID = DRC.ResolutionID 
          FROM   #DEBTPATTERN DP 
                 JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] DRC 
                   ON DP.MLResolutionCode = CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DRC.MResolutionCode,'') != ''  
				   THEN LTRIM(RTRIM(DRC.MResolutionCode)) ELSE DRC.ResolutionCode  END 
                      AND DRC.IsDeleted = 0 
          WHERE  DRC.ProjectID = @projectid 

          --selecting the application details  
          SELECT A.* 
          INTO   #APPINFO 
          FROM   (SELECT AM.ApplicationID, 
                         AM.ApplicationName, 
                         AT.ApplicationTypeId, 
                         AT.ApplicationTypename, 
                         MT.PrimaryTechnologyID, 
                         MT.PrimaryTechnologyName 
                  FROM   [AVL].[APP_MAS_APPLICATIONDETAILS](NOLOCK) AM 
                         INNER JOIN AVL.BUSINESSCLUSTERMAPPING(NOLOCK) BCM 
                                 ON AM.SubBusinessClusterMapID = BCM.BusinessClusterMapID 
                                    AND BCM.IsDeleted = 0 
                                    AND BCM.CustomerID = @CustomerID 
                         LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS](NOLOCK) AT 
                                ON AM.CodeOwnership = AT.ApplicationTypeID 
                                   AND AT.IsDeleted = 0 
                         LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY](NOLOCK) MT 
                                ON AM.PrimaryTechnologyID = MT.PrimaryTechnologyID 
                                   AND MT.IsDeleted = 0 
                  WHERE  AM.APPLICATIONID IS NOT NULL 
                         AND AM.APPLICATIONNAME IS NOT NULL 
                         AND AM.IsActive = 1 
                         AND BCM.CustomerID = @CustomerID) AS A 

          UPDATE DP 
          SET    DP.ApplicationID = AI.ApplicationID 
          FROM   #DEBTPATTERN DP 
                 INNER JOIN #APPINFO AI 
                         ON AI.ApplicationName = DP.ApplicationName 

          UPDATE DP 
          SET    DP.ApplicationTypeID = AI.ApplicationTypeId 
          FROM   #DEBTPATTERN DP 
                 INNER JOIN #APPINFO AI 
                         ON AI.ApplicationTypename = DP.ApplicationTypeName 

          UPDATE DP 
          SET    DP.TechnologyID = AI.PrimaryTechnologyID 
          FROM   #DEBTPATTERN DP 
                 INNER JOIN #APPINFO AI 
                         ON AI.PrimaryTechnologyName = DP.TechnologyName 

          UPDATE #DEBTPATTERN 
          SET    InitialLearningID = @InitialLearningID 

          IF EXISTS(SELECT TOP 1 ProjectID 
                    FROM   #DEBTPATTERN) 
            BEGIN 
                IF( @IsRegenerated = 1 ) 
                  BEGIN 
                      UPDATE p 
                      SET    isdeleted = 1 
                      FROM   AVL.ML_TRN_MLPATTERNVALIDATION P 
                             INNER JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS reg 
                                     ON P.ApplicationID = reg.ApplicationID 
                      WHERE  P.Projectid = @projectid 
                             AND P.isdeleted = 0 
                             AND reg.InitialLearningID = @InitialLearningID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE AVL.ML_TRN_MLPATTERNVALIDATION 
                      SET    IsDeleted = 1 
                      WHERE  ProjectID = @projectid 
                  END 

                -- Inserting the information into pattern validation.   
                INSERT INTO AVL.ML_TRN_MLPATTERNVALIDATION 
                            (ProjectID, 
                             InitialLearningID, 
                             ApplicationID, 
                             TicketOccurence, 
                             ApplicationTypeID, 
                             TechnologyID, 
                             TicketPattern, 
                             subPattern, 
                             additionalPattern, 
                             additionalSubPattern, 
                             MLResidualFlagID, 
                             MLDebtClassificationID, 
                             MLAvoidableFlagID, 
                             MLCauseCodeID, 
                             MLAccuracy, 
                             AnalystResidualFlagID, 
                             AnalystResolutionCodeID, 
                             AnalystDebtClassificationID, 
                             AnalystAvoidableFlagID, 
                             AnalystCauseCodeID, 
                             Classifiedby, 
                             IsDeleted, 
                             CreatedDate, 
                             MLResolutionCode) 
                SELECT DISTINCT @ProjectID, 
                                @InitialLearningID, 
                                ApplicationID, 
                                TicketOccurence, 
                                ApplicationTypeID, 
                                TechnologyID, 
                                TicketPattern, 
                                subPattern, 
                                additionalPattern, 
                                additionalSubPattern, 
                                MLResidualFlagID, 
                                MLDebtClassificationID, 
                                MLAvoidableFlagID, 
                                MLCauseCodeID, 
                                MLAccuracy, 
                                AnalystResidualFlagID, 
                                AnalystResolutionCodeID, 
                                AnalystDebtClassificationID, 
                                AnalystAvoidableFlagID, 
                                AnalystCauseCodeID, 
                                Classifiedby, 
                                0, 
                                GETDATE(), 
                                MLResolutionCodeID 
                FROM   #DEBTPATTERN 
            END 

          --updating the DartProcessed as 'Y' and job type as 'ML' 
          UPDATE AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
          SET    IsDARTProcessed = 'Y' 
          WHERE  ProjectID = @ProjectID 
                 AND JobType = 'ML' 
                 AND ( IsDeleted = 0 
                        OR IsDeleted IS NULL ) 
                 AND InitialLearningID = @InitialLearningID 

          -- updating the IsMLsent as 'Received' 
          UPDATE AVL.ML_PRJ_INITIALLEARNINGSTATE 
          SET    IsMLSentOrReceived = 'Received' 
          WHERE  ProjectID = @ProjectID 
                 AND IsDeleted = 0 
                 AND ID = @InitialLearningID 

          --=================================Mail Content==========================------ 
          SELECT TOP 1 EmployeeEmail, 
                       EmployeeName 
          INTO   #EMPLOYEEDATA 
          FROM   AVL.MAS_LOGINMASTER(NOLOCK) 
          WHERE  employeeid = @UserID 
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

          DECLARE @iscog INT=(SELECT c.IsCognizant 
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

          --print @EmailProjectName 
          SET @Subjecttext = 'Initial Learning Generated : ' 
                             + @EmailProjectName 

          PRINT @Subjecttext 

       
          ----------------------------------------- 
          ---------------mailer body---------------margin-left:170px; 
          SET @tableHTML ='<html style="width:auto !important">' 
                          + '<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" style="text-align:center;width:750">' 
                          + 
          '<table width="750" face="Times New Roman,serif" border="0" cellpadding="0" cellspacing="0" style="margin-left:60px;font-family:sans-serif;font-size:14px;font-weight:normal">' 
                          + '<tbody>' + '<tr>' 
                          + '<td valign="top" style="padding: 0;">' 
                          + '<div align="center" style="text-align: center;">' 
                          + '<table width="750" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">' 
                          + '<tbody>' + '<tr style="height:50px">' 
                          + '<td width="auto" valign="top" align="center">' 
                          + '<img src="\\ctsc01260327301\Banner\ApplensBanner.png" width="750" height="50" style="border-width: 0px;"/>' 
                          + '</td>' + '</tr>' 
                          + '<tr style="background-color:#F0F8FF">' 
                          + '<td valign="top" style="padding: 0;">' 
                          + '<div align="center" style="text-align: center;margin-left:50px">' 
                          + '<table width="750" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">' 
                          + '<tbody>' + '</br></BR>' 
                          + N'<left>  <font-weight:normal>  &nbsp;&nbsp;Dear ' + @UserName 
                          + ' ,' + '</BR>' 
                          + '&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp' 
                          + '</BR>' 
                          + '&nbsp;&nbsp;Request you to review the Initial learning patterns and provide Sign off for   effective auto classification by navigating to ' 
                          + '</BR>' 
                          + '&nbsp;&nbsp;Ticketing Module - > Lead Self Service - > Initial Learning Review.'
                          + '</font>   </Left>' + N'    <p align="left">    <font color="Black" Size = "2" font-weight=bold>    <b>&nbsp;&nbsp;Thanks & Regards,</b>   </font>    </BR>   &nbsp;&nbsp;Solution Zone Team 	   </BR>    </BR>     <p style="text-align: center;">  	  **This is an Auto Generated Mail. Please Do not reply to this Email** </p> </p>' + '</tbody>' 
                          + '</table>' + '</div>' + '</td>' + '</tr>' 
                          + '</tbody>' + '</table>' + '</div>' + '</td>' 
                          + '</tr>' + '</tbody>' + '</table>' + '</body>' 
                          + '</html>' 

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
          --=================================Mail Content End===========================----------------------     
          --END 
          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            ' [dbo].[ML_SaveMLPatternFromAlgorithm] ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END

