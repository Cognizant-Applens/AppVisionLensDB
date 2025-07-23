
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[MailforTranslationKeyFailure]
@ProjectId VARCHAR(50),
@KeyErrorMessage VARCHAR(max)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;

DECLARE @Key VARCHAR(200)
CREATE TABLE #MailUsers(
EmployeeEmail NVARCHAR(max)
)

SET @Key = (SELECT MSubscriptionKey FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectId AND IsDeleted = 0)

INSERT INTO #MailUsers
SELECT DISTINCT LM.EmployeeEmail
FROM 
AVL.VW_EmployeeCustomerProjectRoleBUMapping VMEC
join AVL.MAS_LoginMaster LM on LM.EmployeeID=VMEC.EmployeeId 
join AVL.Customer C on C.CustomerID=LM.CustomerID and c.CustomerID = VMEC.CustomerID
JOIN avl.MAS_ProjectMaster PM on VMEC.ProjectID = PM.ProjectID
WHERE PM.IsDeleted = 0 and VMEC.RoleId=7 AND VMEC.ProjectID = @ProjectId

DECLARE @tableHTML  VARCHAR(MAX);
DECLARE @EmailProjectName varchar(max);
DECLARE @Subjecttext VARCHAR(max);  	
DECLARE @MailingToList VARCHAR(MAX)
SET @MailingToList = ''
SELECT @MailingToList =  COALESCE(@MailingToList + ';', '') + CAST(RTRIM(ISNULL(EmployeeEmail,';')) AS VARCHAR(200))  
							FROM  #MailUsers

IF NOT EXISTS(SELECT TOP 1 * FROM avl.MultilingualKeyFailureTrace WHERE ProjectID = @ProjectId AND CONVERT(DATE, CreatedDate) = CONVERT(DATE, GETDATE()))
BEGIN
	PRINT 'Mail notification Off'
	
	SET @Subjecttext = ''
	SET @EmailProjectName=(SELECT DISTINCT CONCAT(EsaProjectID, '-', ProjectName) FROM AVL.MAS_ProjectMaster WHERE ProjectId = @ProjectId AND IsDeleted = 0 )
	print @EmailProjectName
	SET @Subjecttext = 'Multilingual Translation key is failure for the project - '+@EmailProjectName;
	print @Subjecttext	
	Print @MailingToList	
	-----------------------------------------
	---------------mailer body---------------

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
									+'Multilingual Translation key <font color="#000000"><b>'+@Key+'</b></font> is failure due to following reason:'
									+'</BR>'
									+'</BR>'
									+'<font color="#000000"><b>'+@KeyErrorMessage+'</b></font>'
									+'</BR>'
									+'</BR>'
									+'Requesting you to navigate to ITSM Configuration and check and validate the subscription key'
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
		EXEC [AVL].[SendDBEmail] @To='ramkumar.v6@cognizant.com;SreeyaPriyadharsini.SureshKumar@cognizant.com;Anitha.P6@cognizant.com;Menaka.Senthilkumar@cognizant.com;',
    @From='ApplensSupport@cognizant.com',
    @Subject =@Subjecttext,
    @Body = @tableHTML		



END
INSERT INTO avl.MultilingualKeyFailureTrace VALUES(@ProjectId,@Key,@MailingToList,'system',GETDATE(),@KeyErrorMessage)

SET NOCOUNT OFF; 	
COMMIT TRAN
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SET @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[MailforTranslationKeyFailure]', @ErrorMessage, 0,0
END CATCH  
END


