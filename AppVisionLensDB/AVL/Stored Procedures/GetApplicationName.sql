/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [AVL].[GetApplicationName] (@UserID nvarchar(50))         
as          
begin         
BEGIN TRY         
select AD.ApplicationID,ApplicationName,sm.submoduleId as 'SubModuleID',sm.[SubModuleName] from OneAVM.[AVM].[ApplicationDetails]  AD         
left join [OneAVM].[AVM].[SubModuleDetails] sm on ad.ApplicationID=sm.ApplicationID        
END TRY        
BEGIN CATCH               
DECLARE @Message VARCHAR(MAX);  
DECLARE @ErrorSource VARCHAR(MAX);      
        
  SELECT @Message = ERROR_MESSAGE()
  select @ErrorSource = ERROR_STATE()  
EXEC AVL_InsertError '[AVL].[SaveOrUpdateTipDetails]',@ErrorSource,@Message,0               
END CATCH           
end
