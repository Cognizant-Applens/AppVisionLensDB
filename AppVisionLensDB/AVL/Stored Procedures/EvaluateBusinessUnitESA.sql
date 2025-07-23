
/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
-- ====================================================================================================================  
-- Author   : Dinesh Babu  
-- Create date  : 24 Dec 2018  
-- Description  : Insert / Update Business Units in Applens  
-- Revision By  : Annadurai.S  
-- Revision Date : 11 Jan 2019  
-- Revision History : During the Esa Job Error, send notifications  
-- ====================================================================================================================   
  
CREATE   PROCEDURE [AVL].[EvaluateBusinessUnitESA]  
  
AS  
  
BEGIN  
  
 BEGIN TRY  
  BEGIN TRAN   
  
   IF EXISTS (SELECT 1 FROM [$(AVMCOEESADB)].[DBO].[ESAJobStatus] WHERE AppvisionProdESARefresh = 1)  
   BEGIN  
  
    SELECT *   
    INTO #ESABUnits   
    FROM [ESA].[BusinessUnits]  
  
    SELECT bu.*   
    INTO #ExistingBUACtive   
    FROM #ESABUNITS ebu   
    JOIN [AVL].[BusinessUnit] bu ON bu.BUName = ebu.BUName AND bu.IsDeleted = 0  
  
    SELECT bu.*   
    INTO #ExistingBUDeActivated   
    FROM #ESABUNITS ebu   
    JOIN [AVL].[BusinessUnit] bu ON bu.BUName = ebu.BUName AND bu.IsDeleted = 1 AND ebu.IsActive = 1  
  
    SELECT ebu.*   
    INTO #NewBU   
    FROM #ESABUNITS ebu   
    WHERE ebu.BUName NOT IN (SELECT bu.BUName FROM [AVL].[BusinessUnit] bu)  
  
    --SELECT ebu.*   
    --INTO #NotAvailBU   
    --FROM [AVL].[BusinessUnit] ebu   
    --WHERE ebu.BUName NOT IN (SELECT bu.BUName FROM #ESABUNITS bu WHERE bu.IsActive = 1)  
  
                SELECT bu.*         
                INTO #ExistingBUDeActivatedinESA         
                FROM #ESABUNITS ebu         
                JOIN [AVL].[BusinessUnit] bu ON bu.BUName = ebu.BUName AND bu.IsDeleted = 0 AND ebu.IsActive = 0   
  
    IF EXISTS (SELECT 1 FROM #NewBU )  
    BEGIN   
  
     INSERT [AVL].[BusinessUnit]   
     (  
      [BUName],   
      [IsDeleted],   
      [BUCode],   
      [CreatedBy],   
      [CreatedDate],  
      [IsHorizontal]  
     )   
     SELECT BUName,  
       CASE WHEN IsActive = 1 THEN 0 ELSE 1 END,  
       PracticeCode,  
       'System',  
       GETDATE(),  
       'N'  
     FROM #NewBU  
      
    END  
  
    --IF EXISTS (SELECT 1 FROM #NotAvailBU)  
    --BEGIN  
    --  
    -- UPDATE bu   
    -- SET bu.IsDeleted = 1,   
    --  bu.BUCode  = nbu.BUCode,  
    --  bu.ModifiedBy = 'System',   
    --  BU.ModifiedDate = GETDATE()   
    -- FROM [AVL].[BusinessUnit] bu   
    -- JOIN #NotAvailBU nbu ON bu.BUName = nbu.buname  
    --  
    --END  
  
    IF EXISTS (SELECT 1 FROM #ExistingBUACtive)  
    BEGIN  
      
     UPDATE bu   
     SET bu.BUCode  = nbu.BUCode,  
      bu.ModifiedBy = 'System',   
      BU.ModifiedDate = GETDATE()   
     FROM [AVL].[BusinessUnit] bu   
     JOIN #ExistingBUACtive nbu ON bu.BUName = nbu.buname  
      
    END  
      
    IF EXISTS (SELECT 1 FROM #ExistingBUDeActivated)  
    BEGIN  
      
     UPDATE bu   
     SET bu.IsDeleted = 0,   
      bu.BUCode  = nbu.BUCode,  
      bu.ModifiedBy = 'System',   
      BU.ModifiedDate = GETDATE()   
     FROM [AVL].[BusinessUnit] bu   
     JOIN #ExistingBUDeActivated nbu ON bu.BUName = nbu.buname  
      
    END  
  
    IF EXISTS (SELECT 1 FROM #ExistingBUDeActivatedinESA)        
                BEGIN        
            
                UPDATE bu         
                SET bu.IsDeleted = 1,         
                bu.BUCode  = nbu.BUCode,        
                bu.ModifiedBy = 'System',         
                BU.ModifiedDate = GETDATE()         
                FROM [AVL].[BusinessUnit] bu         
                JOIN #ExistingBUDeActivatedinESA nbu ON bu.BUName = nbu.buname        
            
                END    
  
  
    DROP TABLE #ESABUnits  
  
    DROP TABLE #ExistingBUACtive  
  
    DROP TABLE #ExistingBUDeActivated  
  
    DROP TABLE #NewBU  
  
    --DROP TABLE #NotAvailBU  
  
    DROP TABLE #ExistingBUDeActivatedinESA   
  
  
   END  
  COMMIT TRAN  
    UPDATE [$(AVMCOEESADB)].[DBO].ESAJobStatus SET AppvisionESALiveRefresh = 1  
  
 END TRY  
 BEGIN CATCH      
    
  ROLLBACK TRAN  
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  DECLARE @MailSubject VARCHAR(MAX);    
  DECLARE @MailBody  VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  SELECT @ErrorMessage AS ErrorMessage  
  
  SELECT @MailSubject = CONCAT(@@SERVERNAME,': ESA Job Failure Notification')  
  
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AppVision ESA  to Live Data Refresh during the ESA Job Execution!<br>  
       <br>Error: ', @ErrorMessage,  
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')  
  
  -- Insert Error Details  
  -- EXEC AVL_InsertESAJobError '[AVL].[EvaluateBusinessUnitESA] ', @ErrorMessage, 0, 'AppVision ESA  to Live Data Refresh', @@SERVERNAME   
  INSERT INTO [$(AVMCOEESADB)].DBO.ESAJobErrors    
  (  
   JobName,  
   ErrorSource,  
   ErrorDescription,  
   CreatedBy,  
   CreatedDate,  
   ServerName  
  )      
  SELECT 'AppVision ESA  to Live Data Refresh', '[AVL].[EvaluateBusinessUnitESA]', @ErrorMessage, '0', GETDATE(), @@SERVERNAME   
    
  ---Mail Option Added by Annadurai on 11.01.2019 to send mail during error ESAJob  
       DECLARE @recipientsAddress NVARCHAR(4000)='';  
       SET @recipientsAddress = (SELECT ConfigValue FROM AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);     
       EXEC [AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody     
         
        ------------------------------------------------------          
    
 END CATCH    
  
END  


