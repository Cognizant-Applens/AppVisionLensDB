/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetMasterIDswithRoleAPIValues] 
	(@EsaProject [AVL].[TVP_KEDB_EsaProject] READONLY )
AS
BEGIN

 BEGIN TRY

 BEGIN 
	select distinct ProjectID,ProjectName,C.CustomerID,  c.CustomerName , c.BusinessUnitID , bu.BusinessUnitName,p.ESAProjectID, c.ESA_AccountID ESAAccountID
	from [AVL].[MAS_ProjectMaster] p
	join [AVL].[Customer] c  on p.customerid=c.customerid
	join [MAS].[BusinessUnits] bu on c.BusinessUnitID = bu.BusinessUnitID 
	join @EsaProject esa on esa.EsaProjectId=p.esaprojectid and esa.EsaCustomerId = c.esa_accountid
	where bu.isdeleted = 0 and c.isdeleted=0 and p.isdeleted=0 
END

END TRY

BEGIN CATCH 
 DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		EXEC AVL_InsertError '[AVL].[KEDB_GetMasterIDswithRoleAPIValues] ', @ErrorMessage, '',''
		RETURN @ErrorMessage 
END CATCH

END
