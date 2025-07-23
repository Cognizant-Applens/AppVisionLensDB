/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [dbo].[GetErrorLogConfigDetails]
	@ProjectID varchar(50)
as
begin

SET nocount ON; 
BEGIN TRY
	
	declare @Modules Table 
	(
		Module varchar(50),
		IsActive varchar(10)
	)
	insert into @Modules
	select 'EffortUpload' as Module, case when COUNT(ProjectID) = 1 then '1' else '0' end from AVL.EffortUploadConfiguration (NOLOCK) where ProjectID = @ProjectID and EffortUploadType = 'A' and IsActive = 1
	insert into @Modules
	select 'TicketUpload' as Module, case when COUNT(ProjectID) = 1 then '1' else '0' end from TicketUploadProjectConfiguration (NOLOCK) where ProjectID = @ProjectID and IsDeleted= 0

	select Module,IsActive from @Modules

	
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[GetErrorLogConfigDetails]', @ErrorMessage, @ProjectID,0
		
END CATCH  
SET nocount OFF; 
end
