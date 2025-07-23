
CREATE FUNCTION [dbo].[fn_FmtEmailBody_Message]   
(
	@Message Varchar(Max)
	
)
RETURNS VARCHAR(MAX)
AS
BEGIN      
	DECLARE @tableHTML  VARCHAR(MAX);	
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
														+'<font color="#000000"><b> '+ @Message +'  </b></font>'
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

		RETURN @tableHTML
	END
