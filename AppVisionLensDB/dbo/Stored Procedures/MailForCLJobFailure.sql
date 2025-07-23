
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

 --EXEC [dbo].[MailForCLJobFailure] 10337,'Step1','Job failure when inserting','Applens ML Continuous Learning Export'
CREATE PROCEDURE [dbo].[MailForCLJobFailure]
@ProjectID BIGINT = null,
@Step NVARCHAR(max),
@ErrorMessage NVARCHAR(max),
@Source NVARCHAR(max) = null
AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;  
DECLARE @ESAProjectID  NVARCHAR(max)
	
SET @ESAProjectID = (SELECT DISTINCT CONCAT(PM.EsaProjectID, '-', PM.ProjectName) 
					 FROM  AVL.MAS_ProjectMaster PM 
					 WHERE PM.ProjectID=@ProjectID AND IsDeleted=0)
					 
IF (@ESAProjectID IS NULL OR @ESAProjectID = '')
	BEGIN
SET @ESAProjectID ='';
	END

DECLARE @Subjecttext VARCHAR(max);  
DECLARE @tableHTML  VARCHAR(MAX);

IF (@ProjectID IS NULL OR @ProjectID = 0)
	BEGIN
		SET @Subjecttext = 'Production - '+@Source+' Job failed in '+@Step+'';
	END
ELSE
	BEGIN
		SET @Subjecttext = 'Production - '+@Source+' Job failure in '+@Step+' for the Project - '+@ESAProjectID;
	END

SET @tableHTML ='<html style="width:auto !important">'+
			'<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">'+
			'<table width="650" face="Times New Roman,serif" border="0" cellpadding="0" cellspacing="0" style="margin-left:60px;font-family:sans-serif;font-size:14px;font-weight:normal">'+
			'<tbody>'+
			'<tr>'+
			'<td valign="top" style="padding: 0;">'+
			'<div align="center" style="text-align: center;">'+
			'<table width="650" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">'+
			'<tbody>'+
			  '<tr style="height:50px">'+
                                    '<td width="auto" valign="top" align="center">'+
                                     '<img src="\\CTSC01165050301\WeeklyUAT\ApplensBanner.png" width="700" height="50" style="border-width: 0px;"/>'+
                                    '</td>'+
			 '</tr>'+
			 
			  '<tr style="background-color:#F0F8FF">'+
                                    '<td valign="top" style="padding: 0;">'+
                                        '<div align="center" style="text-align: center;margin-left:50px">'+
                                            '<table width="650" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">'+
                                               
											  '<tbody>'+
												 '</br>'+
                                                  
													N'<left> 
												
										<font-weight:normal>
										
										 Hi All,'
										 + '</BR>'
										 +'&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp'
										 +'</BR>'
										 +'Production - CL Job failure for '+@ESAProjectID+' in'
										  +'<font color="#000000"><b> '+@Step+'</b></font>'
										 +'</BR>'
										 +'</BR>'
										 +'Exception Message: '+@ErrorMessage+
										 +'</BR>'
										 +'</BR>'
										 +'Requesting you to check this issue details in Error log table'
										 +'</BR>'
										 +'</BR>'
										 +'PS : This is system generated mail, please do not reply to this mail.'
										 +'</font>  
								</Left>' 
							           +
										N'
							 
							 <p align="left">  
							 <font color="Black" Size = "2" font-weight=bold>  
							 <b> Thanks & Regards,</b>
							  </font> 
							  </BR>
							  Solution Zone Team 		
							   </BR>
							   </BR>
							    <font size="1">  					 
							**This is an Auto Generated Mail. Please Do not reply to this mail**
							</font>
							</p>' +   
							

                                                '</tbody>'+
                                            '</table>'+
                                        '</div>'+
                                   '</td>'+
                                '</tr>'+
			'</tbody>'+
			'</table>'+
			'</div>'+
			'</td>'+
			'</tr>'+
			'</tbody>'+
			'</table>'+
			'</body>' +
			'</html>'
			
			-------------executing mail-------------
			DECLARE @recipientsAddress NVARCHAR(4000)='';
			SET @recipientsAddress = (SELECT ConfigValue FROM AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);  
			EXEC [AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@Subjecttext,
    @Body = @tableHTML

SET NOCOUNT OFF; 	
COMMIT TRAN
END TRY  
BEGIN CATCH  

		SET @ErrorMessage = ERROR_MESSAGE()
		SELECT @ErrorMessage
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'MailForCLJobFailure', @ErrorMessage, 0,0
END CATCH  
END


