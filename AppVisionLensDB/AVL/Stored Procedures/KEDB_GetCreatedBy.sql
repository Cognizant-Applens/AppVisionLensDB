/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetCreatedBy]
(        
@projectid bigint
 ) 

as

BEGIN 
BEGIN TRY
	SET NOCOUNT ON;
		 select distinct ka.CreatedBy as CreatedBy, AuthorName AS EmployeeName from [AVL].[KEDB_TRN_KATicketDetails] ka
		-- join [AVL].[MAS_LoginMaster] lm on (ka.CreatedBy = lm.EmployeeID ) 
		 --and ka.ProjectId = lm.ProjectID and ka.IsDeleted = lm.IsDeleted) // KArticles should be visible irrespective of projectid and inactive employees, so excluding projectid mapping 
		 where ka.ProjectId =@projectid and ka.IsDeleted=0 --and lm.IsDeleted=0
	SET NOCOUNT OFF;        
END TRY
BEGIN CATCH

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetCreatedBy]', @ErrorMessage, 0
END CATCH

END
