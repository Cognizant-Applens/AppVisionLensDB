/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [AVL].[SaveOrUpdateTipDetails] @tipsModel [AVL].[TipsModel] readonly    
as    
Begin try  
declare @tipId int,@tipName [varchar](250),    
@tipContent [varchar](4000),    
@ModuleID int,    
@subModuleID int,    
@expiryDate datetime,    
@isActive bit,    
@createdDate datetime,    
@modifiedDate datetime,    
@createdBy varchar(50),    
@modifiedBy varchar(50),    
@featureType varchar(25),    
@moduleName varchar(25),    
@subModuleName varchar(25)    
    
select @tipId = TipID,@tipName = TipName, @tipContent = TipContent, @ModuleID = ModuleID,@subModuleID = SubModuleID,@expiryDate = ExpiryDate,@isActive = isActive,@createdDate = CreatedDate,@modifiedDate = ModifiedDate,@createdBy = CreatedBy,@modifiedBy = 
ModifiedBy,@featureType = FeatureType from @tipsModel    
begin    
if(@tipId = 0)    
begin    
insert into [OneAVM].[AVM].[TipOftheDayDetails] values (@tipName,@tipContent,@ModuleID,@SubModuleID,@ExpiryDate,1,GETDATE(),GETDATE(),@CreatedBy,@ModifiedBy,@FeatureType)    
end   
else  
begin  
update [OneAVM].[AVM].[TipOftheDayDetails] set TipName = @tipName,TipContent = @tipContent, ModuleID = @ModuleID, SubModuleID = @subModuleID,ExpiryDate = @expiryDate, isActive = @isActive,CreatedDate = @createdDate,ModifiedDate = @modifiedDate, CreatedBy = @createdBy, ModifiedBy = @modifiedBy, FeatureType = @featureType where TipID = @tipId  
end  
  
end    
end try   
begin catch  
DECLARE @Message VARCHAR(MAX);  
DECLARE @ErrorSource VARCHAR(MAX);      
        
  SELECT @Message = ERROR_MESSAGE()
  select @ErrorSource = ERROR_STATE()  
EXEC AVL_InsertError '[AVL].[SaveOrUpdateTipDetails]',@ErrorSource,@Message,0  
end catch
