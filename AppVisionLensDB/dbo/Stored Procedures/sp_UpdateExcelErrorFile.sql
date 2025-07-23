/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET          
*Copyright [2018] – [2021] Cognizant. All rights reserved.          
*NOTICE: This unpublished material is proprietary to Cognizant and          
*its suppliers, if any. The methods, techniques and technical          
  concepts herein are considered Cognizant confidential and/or trade secret information.           
            
*This material may be covered by U.S. and/or foreign patents or patent applications.           
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.          
***************************************************************************/          
          
CREATE PROCEDURE [dbo].[sp_UpdateExcelErrorFile]          
 @filename  VARCHAR(100),           
 @ProjectID INT,           
 @userid    VARCHAR(100),    
 @ticketCount INT=0,    
 @failedTicketCount INT=0    
AS           
BEGIN           
      BEGIN try           
          SET nocount ON;           
          
          IF EXISTS(SELECT ProjectID           
                    FROM   avl.ticketdumpuploadstatus (NOLOCK)          
                    WHERE  userid = @userid           
                           AND projectid = @ProjectID           
                           AND errorfilename = ''        
         AND ( Status = 'Failed' OR IsGracePeriodMet=1))           
            BEGIN           
                UPDATE avl.ticketdumpuploadstatus           
                SET    errorfilename = @filename           
                WHERE  userid = @userid           
                       AND projectid = @ProjectID           
                       AND errorfilename = '' and ( Status = 'Failed' OR IsGracePeriodMet=1)          
            END         
  ELSE          
   BEGIN          
    INSERT INTO avl.ticketdumpuploadstatus (UserID, ProjectID, TotalTicketCount,UpdatedticketCount, ReuploadticketCount, FailedticketCount, Uploadstarttime, Uploadendtime, UploadMode, Status, FileName, Remarks, ErrorFileName, IsGracePeriodMet)          
    VALUES (@userid, @ProjectID, 0, 0, 0, @failedTicketCount,GETDATE(), GETDATE(), 'Manual', 'Failed','', 'Upload Failed', @filename, 0)          
   END         
      END try           
          
      BEGIN catch           
          DECLARE @ErrorMessage VARCHAR(max);           
          
          SELECT @ErrorMessage = Error_message()           
          
          EXEC Avl_inserterror           
            '[dbo].[sp_UpdateExcelErrorFile] ',           
            @ErrorMessage,           
            @userid           
      END catch           
  END
