

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
-- Create date   : 02 Apr 2019      
-- Description   : Move the Location Details from AVMCOEESA DB to App Vision Lens ESA Location table.      
-- Revision By   : Annadurai.S      
-- Revision Date : 14 Jan 2019      
-- ====================================================================================================================       
CREATE   PROCEDURE [AVL].[ESALocationDetailsDataRefresh]      
AS      
BEGIN  
SET NOCOUNT ON;  
 BEGIN TRY      
    BEGIN TRAN      
      
     IF EXISTS (SELECT 1 FROM [$(AVMCOEESADB)].DBO.ESAJobStatus WHERE ESADataUpdate = 1)      
  BEGIN      
         
   CREATE TABLE #LocationMaster      
   (      
    [ID] [int]    IDENTITY(1,1) NOT NULL,      
    [Assignment_Location] [NVARCHAR](12) NULL,      
    [City]     [NVARCHAR](50) NULL,      
    [State]     [NVARCHAR](6) NULL,      
    [Country]    [NVARCHAR](5) NULL      
   )       
      
   SELECT DISTINCT Assignment_Location       
   INTO #Location      
   FROM [$(AVMCOEESADB)].dbo.GMSPMO_Associate      
   WHERE Assignment_Location IS NOT NULL      
      
   SELECT DISTINCT Assignment_Location, Country, [state], city       
   INTO #LocationDetails      
  FROM [$(AVMCOEESADB)].dbo.GMSPMO_Associate     
   WHERE Assignment_Location IS NOT NULL AND Country IS NOT NULL        
    AND [state] IS NOT NULL AND city IS NOT NULL      
      
   INSERT INTO #LocationMaster ([Assignment_Location], [City], [State], [Country])      
    SELECT l.Assignment_Location, ld.city, ld.[state], ld.Country       
    FROM #Location l (NOLOCK)       
    LEFT JOIN #LocationDetails ld (NOLOCK)       
     ON l.Assignment_Location = ld.Assignment_Location       
    ORDER BY l.Assignment_Location      
      
   DROP TABLE #Location      
   DROP TABLE #LocationDetails      
      
   IF EXISTS (SELECT 1 FROM #LocationMaster (NOLOCK))      
   BEGIN      
      
    DECLARE @TotalCount INT      
    DECLARE @location   INT      
      
    SELECT @TotalCount = COUNT(1) FROM #LocationMaster (NOLOCK)     
      
    SET @location = 1      
      
    WHILE (@location <= @TotalCount)      
    BEGIN      
      
     DECLARE @ALocation [NVARCHAR](12)      
     DECLARE @City  [NVARCHAR](50)      
     DECLARE @State  [NVARCHAR](6)       
     DECLARE @Country [NVARCHAR](5)      
           
     SELECT @ALocation = [Assignment_Location],       
       @City  = City,      
       @State  = [State],      
       @Country = Country       
     FROM #LocationMaster (NOLOCK)       
     WHERE ID = @location      
      
     IF EXISTS (SELECT 1 FROM ESA.LocationMaster (NOLOCK) WHERE [Assignment_Location] = @ALocation)      
     BEGIN      
      
      UPDATE lm       
      SET lm.City  = @City,      
       lm.[State] = @State,      
       lm.Country = @Country       
      FROM ESA.LocationMaster lm       
      WHERE lm.[Assignment_Location] = @ALocation      
           
     END      
     ELSE      
     BEGIN      
      
      INSERT INTO ESA.LocationMaster      
      (      
       [Assignment_Location],      
       City,      
       [State],      
       Country      
      )      
      VALUES      
      (      
       @ALocation,      
       @City,   
       @State,      
       @Country      
      )      
      
     END      
         
     SET @location = @location + 1      
      
    END      
      
    DROP TABLE #LocationMaster      
      
   END      
        
         
       
  END       
      
  COMMIT TRAN      
  UPDATE [$(AVMCOEESADB)].[DBO].[ESAJobStatus] SET AppvisionProdESARefresh = 1  
 END TRY      
 BEGIN CATCH          
      
  ROLLBACK TRAN      
      
  DECLARE @ErrorMessage VARCHAR(MAX);      
      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
  SELECT @ErrorMessage AS ErrorMessage      
      
  DECLARE @MailSubject VARCHAR(MAX);        
  DECLARE @MailBody    VARCHAR(MAX);      
      
  SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ESA Job Failure Notification')      
      
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AppVision PROD ESA Refresh during the ESA Job Execution!<br>      
       <br>Error: ', @ErrorMessage,      
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')      
      
  -- Insert Error Details        
  --EXEC AVL_InsertESAJobError '[AVL].[ESALocationDetailsDataRefresh] ', @ErrorMessage, 0,'AppVision PROD ESA Refresh', @@SERVERNAME      
 INSERT INTO [$(AVMCOEESADB)].DBO.ESAJobErrors    
  (      
   JobName,      
   ErrorSource,      
   ErrorDescription,      
   CreatedBy,      
   CreatedDate,      
   ServerName      
  )        
  SELECT 'AppVision PROD ESA Refresh', '[AVL].[ESALocationDetailsDataRefresh]', @ErrorMessage, '0', GETDATE(), @@SERVERNAME       
        
  ---Mail Option Added by Annadurai on 14.01.2019 to send mail during error ESAJob      
             DECLARE @recipientsAddress NVARCHAR(4000)='';      
             SET @recipientsAddress = (SELECT ConfigValue FROM AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);         
             EXEC [AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody        
             
  ------------------------------------------------------              
        
 END CATCH        
 SET NOCOUNT OFF;   
END

