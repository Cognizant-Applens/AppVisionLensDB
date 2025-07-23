
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
-- 687591    MENAKA   20-2-2019        Formatted the procedure 
-- 687591    MENAKA   29-5-2019        Included code for MultiLingual text from extended table 
-- ============================================================================   
CREATE PROCEDURE [dbo].[ML_SaveSampledTicketsFromAlgorithm] @ProjectID                NVARCHAR(100), 
                                                      @TVP_lstDebtSampleTickets TVP_DEBTSAMPLEDTICKETS READONLY,
                                                      @UserID                   NVARCHAR(MAX) 
AS 
  BEGIN 
      BEGIN TRY 
	  

--Get the Flag for MultiLingual enabled for the project
DECLARE @IsMultiLingualEnabled int = 0

SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster PM
WHERE PM.ProjectID = @ProjectID
AND PM.IsDeleted = 0)

SELECT MLT.ID,MLT.TimeTickerID,MLT.TicketDescription,MLT.IsTicketDescriptionUpdated,MLT.ResolutionRemarks,MLT.TicketSummary,MLT.Category,MLT.Comments,
MLT.IsCategoryUpdated,MLT.IsCommentsUpdated,MLT.IsTicketSummaryUpdated,MLT.IsFlexField1Updated,
MLT.IsFlexField2Updated,MLT.IsFlexField3Updated,MLT.IsFlexField4Updated,MLT.IsTypeUpdated,T.TicketID
INTO
#tmpMultilingualTranslatedValues 
FROM [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails] MLT
JOIN AVL.TK_TRN_TicketDetail T ON MLT.TimeTickerID= T.TimeTickerID 
WHERE  MLT.IsTicketDescriptionUpdated = 0

--------------------------------------------------------------------------------------- 
          -- Insert sampled tickets from hivepath to ticketsaftersampling   
          CREATE TABLE #DEBTSAMPLEDTICKETS 
            ( 
               initiallearningid      INT NULL, 
               projectid              BIGINT NULL, 
               ticketid               NVARCHAR(MAX) NULL, 
               ticketdescription      NVARCHAR(MAX) NULL, 
               additionaltext         NVARCHAR(MAX), 
               applicationid          BIGINT NULL, 
               applicationtypeid      INT NULL, 
               technologyid           INT NULL, 
               debtclassificationid   INT NULL, 
               avoidableflagid        INT NULL, 
               residualflagid         INT NULL, 
               causecodeid            INT NULL, 
               resolutioncodeid       INT NULL, 
               applicationname        NVARCHAR(MAX) NULL, 
               applicationtypename    NVARCHAR(MAX) NULL, 
               technologyname         NVARCHAR(MAX) NULL, 
               debtclassificationname NVARCHAR(MAX) NULL, 
               avoidableflagname      NVARCHAR(50) NULL, 
               residualdebtname       NVARCHAR(50) NULL, 
               descbaseworkpattern    NVARCHAR(MAX), 
               descsubworkpattern     NVARCHAR(MAX), 
               resbaseworkpattern     NVARCHAR(MAX), 
               ressubworkpattern      NVARCHAR(MAX), 
               causecodename          NVARCHAR(MAX) NULL, 
               resolutioncodename     NVARCHAR(MAX) NULL, 
            ) 

      
          DECLARE @InitialLearningID INT; 
          DECLARE @OptField INT; 

          --latest transaction id for initial learning   
          SET @InitialLearningID=(SELECT TOP 1 id 
                                  FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                                  WHERE  projectid = @ProjectID 
                                  ORDER  BY id DESC) 
          SET @OptField=(SELECT optionalfieldid 
                         FROM   AVL.ML_MAP_OPTIONALPROJMAPPING 
                         WHERE  projectid = @ProjectID 
                                AND isactive = 1) 

          DECLARE @CustomerID INT=0; 
          DECLARE @IsCognizantID INT; 

          SET @CustomerID=(SELECT TOP 1 customerid 
                           FROM   AVL.MAS_LOGINMASTER(NOLOCK) 
                           WHERE  projectid = @ProjectID 
                                  AND isdeleted = 0) 
          SET @IsCognizantID=(SELECT TOP 1 iscognizant 
                              FROM   AVL.CUSTOMER(NOLOCK) 
                              WHERE  customerid = @CustomerID 
                                     AND isdeleted = 0) 

          DECLARE @initiallearningID2 INT 

          SET @initiallearningID2= (SELECT TOP 1 initiallearningid 
                                    FROM   AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS 
                                    WHERE  projectid = @ProjectID) 

          --IF @IsCognizantID=0   
          --BEGIN   
          INSERT INTO #DEBTSAMPLEDTICKETS 
                      (initiallearningid, 
                       projectid, 
                       ticketid, 
                       ticketdescription, 
                       applicationname, 
                       applicationtypename, 
                       technologyname, 
                       debtclassificationname, 
                       avoidableflagname, 
                       residualdebtname, 
                       causecodename, 
                       resolutioncodename, 
                       descbaseworkpattern, 
                       descsubworkpattern, 
                       resbaseworkpattern, 
                       ressubworkpattern) 
          SELECT @InitialLearningID, 
                 @ProjectID, 
                 ticketid, 
                 ticketdescription, 
                 applicationname, 
                 applicationtype, 
                 technology, 
                 debtclassification, 
                 avoidableflag, 
                 residualdebt, 
                 causecode, 
                 resolutioncode, 
                 descbaseworkpattern, 
                 descsubworkpattern, 
                 resbaseworkpattern, 
                 ressubworkpattern 
          FROM   @TVP_lstDebtSampleTickets 

          --updating temp table with ids of the master values for resp projectid   
          --  ---- Debt Classification                              
          UPDATE DP 
          SET    DP.debtclassificationid = X3.debtclassificationid 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] X3 
                   ON DP.debtclassificationname = X3.debtclassificationname 

          UPDATE #DEBTSAMPLEDTICKETS 
          SET    avoidableflagname = 'Yes' 
          WHERE  avoidableflagname = 'Avoidable' 
                  OR avoidableflagname = 'avoidable' 

          UPDATE #DEBTSAMPLEDTICKETS 
          SET    avoidableflagname = 'No' 
          WHERE  avoidableflagname = 'UnAvoidable' 
                  OR avoidableflagname = 'Unavoidable' 

          ---- Avoidable Flag                                 
          UPDATE DP 
          SET    DP.avoidableflagid = X3.[avoidableflagid] 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 JOIN AVL.DEBT_MAS_AVOIDABLEFLAG X3 
                   ON DP.avoidableflagname = X3.[avoidableflagname] 

          ---- Residual Debt     ML                             
          UPDATE DP 
          SET    DP.residualflagid = x3.[residualdebtid] 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] X3 
                   ON DP.residualdebtname = X3.[residualdebtname] 

          --      ---Cause Code  --ML   
          UPDATE DP 
          SET    DP.causecodeid = DCC.causeid 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 JOIN [AVL].[DEBT_MAP_CAUSECODE] DCC 
                   ON LTRIM(RTRIM(DP.causecodename)) =  CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DCC.McauseCode,'') != ''  
				   THEN LTRIM(RTRIM(DCC.Mcausecode)) ELSE DCC.causecode  END 
                      AND DCC.isdeleted = 0 
          WHERE  DCC.projectid = @projectid 
         --     ---Resolution Code  --ML   
          UPDATE DP 
          SET    DP.resolutioncodeid = DRC.resolutionid 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] DRC 
                   ON DP.resolutioncodename =  CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DRC.MResolutionCode,'') != ''  
				   THEN LTRIM(RTRIM(DRC.MResolutionCode)) ELSE DRC.ResolutionCode  END 
                      AND DRC.isdeleted = 0 
          WHERE  DRC.projectid = @projectid 

          --application id update       
          SELECT A.* 
          INTO   #APPINFO 
          FROM   (SELECT AM.applicationid, 
                         AM.applicationname, 
                         AT.applicationtypeid, 
                         AT.applicationtypename, 
                         MT.primarytechnologyid, 
                         MT.primarytechnologyname 
                  FROM   [AVL].[APP_MAS_APPLICATIONDETAILS] AM 
                         INNER JOIN AVL.BUSINESSCLUSTERMAPPING(NOLOCK) BCM 
                                 ON AM.subbusinessclustermapid = BCM.businessclustermapid 
                                    AND BCM.isdeleted = 0 
                                    AND BCM.customerid = @CustomerID
						INNER JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK)  APM
									ON AM.ApplicationID=APM.ApplicationID AND APM.ProjectID=@ProjectID
									AND ISNULL(APM.IsDeleted,0)=0 
                         LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS](NOLOCK) AT 
                                ON AM.codeownership = AT.applicationtypeid 
                                   AND AT.isdeleted = 0 
                         LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY](NOLOCK) MT 
                                ON AM.primarytechnologyid = MT.primarytechnologyid 
                                   AND MT.isdeleted = 0 
                  WHERE  AM.applicationid IS NOT NULL 
                         AND AM.applicationname IS NOT NULL 
                         AND AM.isactive = 1 
                         AND BCM.customerid = @CustomerID) AS A 

          UPDATE DP 
          SET    DP.applicationid = AI.applicationid 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 INNER JOIN #APPINFO AI 
                         ON AI.applicationname = DP.applicationname 

          UPDATE DP 
          SET    DP.applicationtypeid = AI.applicationtypeid 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 INNER JOIN #APPINFO AI 
                         ON AI.applicationtypename = DP.applicationtypename 

          UPDATE DP 
          SET    DP.technologyid = AI.primarytechnologyid 
          FROM   #DEBTSAMPLEDTICKETS DP 
                 INNER JOIN #APPINFO AI 
                         ON AI.primarytechnologyname = DP.technologyname 

          --initial learning id update   
          UPDATE #DEBTSAMPLEDTICKETS 
          SET    initiallearningid = @InitialLearningID 

          UPDATE ST 
          SET    ST.ticketdescription = TM.TicketDescription
          FROM   #DEBTSAMPLEDTICKETS ST 
                 INNER JOIN [AVL].[TK_TRN_TICKETDETAIL](NOLOCK) TM 
                         ON ST.projectid = TM.projectid  AND ST.TicketID=TM.TicketID
          WHERE  TM.projectid = @projectid 
		
		IF @IsMultiLingualEnabled=1
		BEGIN
			 UPDATE ST 
          SET    ST.ticketdescription = CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(MLT.TicketDescription,'') != ''  THEN MLT.TicketDescription ELSE TM.TicketDescription END 
          FROM   #DEBTSAMPLEDTICKETS ST 
                 INNER JOIN [AVL].[TK_TRN_TICKETDETAIL](NOLOCK) TM 
                         ON ST.projectid = TM.projectid 
				INNER JOIN #tmpMultilingualTranslatedValues MLT
                    ON MLT.TicketID = TM.TicketID
					AND MLT.TimeTickerID = TM.TimeTickerID
          WHERE  TM.projectid = @projectid 
		END

          -- update additional text if optional field is for the specific project   
          UPDATE ST 
          SET    ST.additionaltext = CASE WHEN @OptField = 2 THEN TM.ticketsummary 
                                       WHEN @OptField = 1 THEN TM.resolutionremarks 
                                       WHEN @OptField = 3 THEN TM.comments 
                                       ELSE '' 
                                     END 
          FROM   #DEBTSAMPLEDTICKETS ST 
                 INNER JOIN [AVL].[TK_TRN_TICKETDETAIL](NOLOCK) TM 
                         ON ST.projectid = TM.projectid 
				

          WHERE  TM.projectid = @projectid 

        
         
          IF EXISTS(SELECT * 
                    FROM   #DEBTSAMPLEDTICKETS) 
            BEGIN 
                IF( (SELECT isregenerated 
                     FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                     WHERE  projectid = @ProjectID 
                            AND id = @initiallearningID) = 1 ) 
                  BEGIN 
                      --if it is regenerated then tickets of only that specific application will be deleted   
                      UPDATE TS 
                      SET    TS.isdeleted = 1 
                      FROM   AVL.ML_TRN_TICKETSAFTERSAMPLING TS 
                             JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS RAD 
                               ON TS.applicationid = rad.applicationid 
                                  AND RAD.projectid = TS.projectid 
                                  AND RAD.initiallearningid = @initiallearningID 
                                  AND rad.projectid = @ProjectID 

                      --and tickets of that particular application ids will be inserted   
                      INSERT INTO AVL.ML_TRN_TICKETSAFTERSAMPLING 
                                  (initiallearningid, 
                                   projectid, 
                                   ticketid, 
                                   ticketdescription, 
                                   additionaltext, 
                                   applicationid, 
                                   applicationtype, 
                                   technologyid, 
                                   debtclassificationid, 
                                   avoidableflagid, 
                                   residualdebtid, 
                                   desc_base_workpattern, 
                                   desc_sub_workpattern, 
                                   res_base_workpattern, 
                                   res_sub_workpattern, 
                                   causecodeid, 
                                   resolutioncodeid, 
                                   isdeleted) 
                      SELECT @InitialLearningID, 
                             @ProjectID, 
                             ticketid, 
                             ticketdescription, 
                             additionaltext, 
                             DS.applicationid, 
                             applicationtypeid, 
                             technologyid, 
                             debtclassificationid, 
                             avoidableflagid, 
                             residualflagid, 
                             descbaseworkpattern, 
                             descsubworkpattern, 
                             resbaseworkpattern, 
                             ressubworkpattern, 
                             causecodeid, 
                             resolutioncodeid, 
                             0 
                      FROM   #DEBTSAMPLEDTICKETS DS 
                             JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS RAD 
                               ON DS.applicationid = rad.applicationid 
                                  AND RAD.projectid = DS.projectid 
                                  AND RAD.initiallearningid = @initiallearningID 
                                  AND rad.projectid = @ProjectID 

                      UPDATE SJS 
                      SET    SJS.isdartprocessed = 'Y' 
                      FROM   AVL.ML_TRN_MLSAMPLINGJOBSTATUS SJS 
                             JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS RAD 
                               ON RAD.projectid = SJS.projectid 
                                  AND RAD.initiallearningid = @initiallearningID 
                                  AND rad.projectid = @ProjectID 
                      WHERE  SJS.projectid = @ProjectID 
                             AND SJS.jobtype = 'Sampling' 
                             AND ( SJS.isdeleted = 0 
                                    OR SJS.isdeleted IS NULL ) 

                      UPDATE ILS 
                      SET    ILS.issamplingsentorreceived = 'Received' 
                      FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE ILS 
                             JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS RAD 
                               ON RAD.projectid = ILS.projectid 
                                  AND RAD.initiallearningid = @initiallearningID 
                                  AND rad.projectid = @ProjectID 
                      WHERE  ILS.projectid = @ProjectID 
                             AND ILS.isdeleted = 0 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE AVL.ML_TRN_TICKETSAFTERSAMPLING 
                      SET    isdeleted = 1 
                      WHERE  projectid = @projectid 

                      INSERT INTO AVL.ML_TRN_TICKETSAFTERSAMPLING 
                                  (initiallearningid, 
                                   projectid, 
                                   ticketid, 
                                   ticketdescription, 
                                   additionaltext, 
                                   applicationid, 
                                   applicationtype, 
                                   technologyid, 
                                   debtclassificationid, 
                                   avoidableflagid, 
                                   residualdebtid, 
                                   desc_base_workpattern, 
                                   desc_sub_workpattern, 
                                   res_base_workpattern, 
                                   res_sub_workpattern, 
                                   causecodeid, 
                                   resolutioncodeid, 
                                   isdeleted) 
                      SELECT @InitialLearningID, 
                             @ProjectID, 
                             ticketid, 
                             ticketdescription, 
                             additionaltext, 
                             applicationid, 
                             applicationtypeid, 
                             technologyid, 
                             debtclassificationid, 
                             avoidableflagid, 
                             residualflagid, 
                             descbaseworkpattern, 
                             descsubworkpattern, 
                             resbaseworkpattern, 
                             ressubworkpattern, 
                             causecodeid, 
                             resolutioncodeid, 
                             0 
                      FROM   #DEBTSAMPLEDTICKETS 

                      UPDATE AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                      SET    isdartprocessed = 'Y' 
                      WHERE  projectid = @ProjectID 
                             AND jobtype = 'Sampling' 
                             AND ( isdeleted = 0 
                                    OR isdeleted IS NULL ) 

                      UPDATE AVL.ML_PRJ_INITIALLEARNINGSTATE 
                      SET    issamplingsentorreceived = 'Received' 
                      WHERE  projectid = @ProjectID 
                             AND isdeleted = 0 
                  END 

                --=================================Mail Content==========================------   
                SELECT TOP 1 employeeemail, 
                             employeename 
                INTO   #EMPLOYEEDATA 
                FROM   AVL.MAS_LOGINMASTER(NOLOCK) 
                WHERE  employeeid = @UserID 
                       AND projectid = @ProjectID 
                       AND isdeleted = 0 

                DECLARE @tableHTML VARCHAR(MAX); 
                DECLARE @EmailProjectName VARCHAR(MAX); 
                DECLARE @Subjecttext VARCHAR(MAX); 
                DECLARE @MailingToList VARCHAR(MAX); 
                DECLARE @UserName VARCHAR(MAX); 

                SET @MailingToList = (SELECT employeeemail 
                                      FROM   #EMPLOYEEDATA) 
                SET @UserName=(SELECT employeename 
                               FROM   #EMPLOYEEDATA) 

                DECLARE @iscog INT=(SELECT c.iscognizant 
                  FROM   AVL.MAS_PROJECTMASTER(NOLOCK) pm 
                         JOIN AVL.CUSTOMER(NOLOCK) c 
                           ON c.customerid = pm.customerid 
                  WHERE  pm.projectid = @ProjectID 
                         AND pm.isdeleted = 0 
                         AND c.isdeleted = 0) 

                IF( ( @iscog ) = 1 ) 
                  BEGIN 
                      SET @EmailProjectName=(SELECT DISTINCT CONCAT(PM.esaprojectid, '-', PM.projectname) 
                                             FROM   AVL.MAS_PROJECTMASTER(NOLOCK) PM 
                                             WHERE  PM.projectid = @ProjectID) 
                  END 
                ELSE 
                  BEGIN 
                      SET @EmailProjectName=(SELECT DISTINCT PM.projectname 
                                             FROM   AVL.MAS_PROJECTMASTER(NOLOCK) PM 
                                             WHERE  PM.projectid = @ProjectID) 
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

END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 

        SELECT @ErrorMessage = ERROR_MESSAGE() 


        --INSERT Error       
        EXEC AVL_INSERTERROR 
          '[dbo].[ML_SaveSampledTicketsFromAlgorithm]  ', 
          @ErrorMessage, 
          @ProjectID, 
          0 
    END CATCH 
END

