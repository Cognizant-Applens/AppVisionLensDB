/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [AVL].[SendDBEmail_test](
@To varchar(max),
@From varchar(255),
@CC varchar(max)=NULL,
@Subject varchar(255),
@Body varchar(max)

 

)
AS
BEGIN  
       SET NOCOUNT ON;  
       BEGIN TRY 
       DECLARE @Profile varchar(100);
       IF @From = 'ADM Associate Lens'
       BEGIN
       SET @Profile = @From
       END
       ELSE IF(@From='ADM JR Team')
       BEGIN
       SET @Profile = @From
       END
       ELSE
       BEGIN
       SET @Profile = 'ApplensSupport'
       END

        EXEC msdb.dbo.sp_send_dbmail @recipients =@To,  
                         @profile_name = @Profile,    
                         @copy_recipients = @CC,
                         @subject = @Subject,   
                         @body = @Body,    
                         @body_format = 'HTML';     
       END TRY  
       BEGIN CATCH  
       DECLARE @errorMessage VARCHAR(MAX);  
  
         SELECT @errorMessage = ERROR_MESSAGE()  
  
         --INSERT Error      
         EXEC AVL_InsertError 'avl.SendDBEmail_test',@errorMessage,'',0  
       END CATCH  
End
