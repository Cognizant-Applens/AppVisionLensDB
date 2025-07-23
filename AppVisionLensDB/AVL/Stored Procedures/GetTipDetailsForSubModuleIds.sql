/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

Create procedure [AVL].[GetTipDetailsForSubModuleIds](@subModuleIds nvarchar(4000),@moduleIds nvarchar(4000))      
as       
begin try  
--declare @subModuleIds nvarchar(4000), @moduleIds nvarchar(4000)  
--set @subModuleIds = '2,3'  
--set @moduleIds = null      
create table #subModuleTemp(  
[TipID] [int] NOT NULL,  
 [TipName] [varchar](250) NULL,  
 [TipContent] [varchar](4000) NULL,  
 [ModuleID] [int] NULL,  
 [SubModuleID] [int] NULL,  
 [ExpiryDate] [datetime] NULL,  
 [isActive] [bit] NULL,  
 [CreatedDate] [datetime] NULL,  
 [ModifiedDate] [datetime] NULL,  
 [CreatedBy] [varchar](50) NULL,  
 [ModifiedBy] [varchar](50) NULL,  
 [FeatureType] [varchar](25) NULL,  
 [ModuleName] [varchar](50) NULL,  
 [SubModuleName] [varchar](50) NULL  
)  
create table #moduleTemp(  
[TipID] [int] NOT NULL,  
 [TipName] [varchar](250) NULL,  
 [TipContent] [varchar](4000) NULL,  
 [ModuleID] [int] NULL,  
 [SubModuleID] [int] NULL,  
 [ExpiryDate] [datetime] NULL,  
 [isActive] [bit] NULL,  
 [CreatedDate] [datetime] NULL,  
 [ModifiedDate] [datetime] NULL,  
 [CreatedBy] [varchar](50) NULL,  
 [ModifiedBy] [varchar](50) NULL,  
 [FeatureType] [varchar](25) NULL,  
 [ModuleName] [varchar](50) NULL,  
 [SubModuleName] [varchar](50) NULL  
)  
if(@subModuleIds != '')  
begin  
insert into #subModuleTemp select TipID  
,TipName  
,TipContent  
,ModuleID  
,SubModuleID  
,ExpiryDate  
,isActive  
,CreatedDate  
,ModifiedDate  
,CreatedBy  
,ModifiedBy  
,FeatureType  
,(select top 1 AD.ApplicationName from [OneAVM].[AVM].[ApplicationDetails]  AD inner join [OneAVM].[AVM].[SubModuleDetails] sm on ad.ApplicationID=sm.ApplicationID) as ModuleName   
,(select top 1 SD.SubModuleName from [OneAVM].[AVM].[SubModuleDetails]  SD inner join [OneAVM].[AVM].[TipOftheDayDetails] tp on SD.SubModuleId= TM.SubModuleID) as SubmoduleName from [OneAVM].[AVM].[TipOftheDayDetails] TM where SubModuleID in (select * from 
[dbo].[SplitString](@subModuleIds,','))  
  
end  
if(@moduleIds != '')  
begin  
insert into #moduleTemp select TipID  
,TipName  
,TipContent  
,ModuleID  
,0  
,ExpiryDate  
,isActive  
,CreatedDate  
,ModifiedDate  
,CreatedBy  
,ModifiedBy  
,FeatureType  
,(select top 1 AD.ApplicationName from [OneAVM].[AVM].[ApplicationDetails]  AD inner join [OneAVM].[AVM].[SubModuleDetails] sm on ad.ApplicationID=TM.ModuleID) as ModuleName   
,null as SubmoduleName from [OneAVM].[AVM].[TipOftheDayDetails] TM where ModuleID in (select * from [dbo].[SplitString](@moduleIds,','))  
end  
  
select * from #subModuleTemp union   
select * from #moduleTemp  
drop table #subModuleTemp   
drop table #moduleTemp   
end try  
begin catch         
DECLARE @Message VARCHAR(MAX);  
DECLARE @ErrorSource VARCHAR(MAX);      
        
  SELECT @Message = ERROR_MESSAGE()
  select @ErrorSource = ERROR_STATE()        
        
  --INSERT Error            
  EXEC AVL_InsertError 'AVM.GetTipDetailsForSubModuleIds',@ErrorSource, @Message ,null  
end catch
