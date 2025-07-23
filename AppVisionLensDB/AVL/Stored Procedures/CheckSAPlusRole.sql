/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[CheckSAPlusRole]
	@empId int
AS
BEGIN
begin try
	SELECT  assoc.Grade   
   FROM [AVL].[GradeRoleMapping](NOLOCK) grm  
   JOIN [ESA].[ASSOCIATES](NOLOCK) assoc  
   ON grm.Grade = assoc.Grade
   WHERE assoc.AssociateID =@empId
   AND grm.IsActive = 1  
END TRY
BEGIN CATCH
RETURN NULL
END CATCH 

END
