/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[GetSOGradeDetails] 
  
  @SOID varchar(50)

AS
BEGIN
				
		             SELECT TOP 1
					 A.[RMG_RR] As [SOID],
					 A.[JobCode] AS[JobCode],
					 B.[Grade] AS [GradeCode],
					 A.[OpenServiceOrder] As [OpenServiceOrder],
					 A.[SO_Line] As [SOLine]
					FROM [dbo].[SOGradeDetails_SyncGateway] A (NOLOCK)
					INNER JOIN [ESA].[Associates] B (NOLOCK)
					ON A.JobCode =B.JobCode
					WHERE (A.[RMG_RR]=@SOID OR A.[OpenServiceOrder]=@SOID)

END
