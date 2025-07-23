/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE   Proc [BOT].[CreateBOTMaster](  
   @BotId   BIGINT  
     ,@BotName  NVARCHAR(100)   
           ,@Overview  NVARCHAR(500)=NULL  
           ,@Description  NVARCHAR(4000)=NULL  
           ,@BotTargetApplicationId  NVARCHAR(MAX) = null--swap
		   ,@TechnologyId  NVARCHAR(MAX)= null
           ,@BotCategoryId      varchar(10)=NULL  
           ,@BotNatureId            varchar(10)=NULL  
           ,@BotTypeId              varchar(10)=NULL  
           ,@BotReusabilityId       varchar(10)=NULL  
           ,@BusinessProcessId      varchar(10)=NULL  
           ,@SubBusinessProcessId   varchar(10)=NULL  
           ,@ServiceId              varchar(10)=NULL  
           ,@Author   NVARCHAR(50)=NULL  
           ,@ContactDL       NVARCHAR(255)=NULL  
           ,@BotStatusId    int  
           ,@CreatedBy  NVARCHAR(50)
           ,@tags nvarchar(255)=null 
           ,@AutomationTechnology nvarchar(255)=null 
	       ,@domain nvarchar(255)=null
	       ,@Benefits nvarchar(255)=null
	       ,@ProblemType nvarchar(255)=null
	       ,@ActionType nvarchar(255)=null
	       ,@ExecutionSubType nvarchar(255)=null
	       ,@MakeVisible bit

	 )  
AS  
Begin  
 Begin TRY  
 DECLARE @IsManuallyCreated BIT=1  
 DECLARE @IsDeleted  BIT =0  
   
 IF EXISTS(SELECT Id FROM BOT.MasterRepository WHERE Id=@BotId)  
  BEGIN  
   UPDATE [BOT].[MasterRepository]  
      SET [BotName] = @BotName  
      ,[Overview] = @Overview  
      ,[Description] = @Description  
      ,[BotTargetApplicationId] =null
      ,[TechnologyId] =null
      ,[BotCategoryId] = @BotCategoryId  
      ,[BotNatureId] = @BotNatureId  
      ,[BotTypeId] = @BotTypeId  
      ,[BotReusabilityId] = @BotReusabilityId  
      ,[BusinessProcessId] = @BusinessProcessId  
      ,[SubBusinessProcessId] = @SubBusinessProcessId  
      ,[ServiceId] = @ServiceId  
      ,[Author] = @Author  
      ,[ContactDL] = @ContactDL  
      ,[IsManuallyCreated] = @IsManuallyCreated  
      ,[BotStatusId] = @BotStatusId  
      ,[IsDeleted] = @IsDeleted  
      ,[ModifiedBy] =@CreatedBy  
      ,[ModifiedOn] = GETDATE()  
      ,[AutomationTechnology] = @AutomationTechnology
	  ,[DomainId] = @domain
      ,[Benefits] = @Benefits
	  ,[ProblemTypeId] = @ProblemType
	  ,[ActionType] = @ActionType
	  ,[ExecutionSubTypeId] = @ExecutionSubType 
	  ,[Source]='BoTs Added via Applens'
	  ,[DownloadCount] ='NA'
      ,[IsPackOnlyBot] ='NA'
	  ,[IsAvailableinCognizantAutomationCenter] ='NA'
	  ,[MakeVisible] = @MakeVisible
	  

    WHERE ID=@BOTId  
    DELETE FROM BOT.TAGDetails WHERE BotDetailId = @BotId  
  
 END  
 ELSE  
  BEGIN  
   INSERT INTO [BOT].[MasterRepository]  
        ([BotName]  
        ,[Overview]  
        ,[Description]  
        ,[BotTargetApplicationId]  
        ,[TechnologyId]  
        ,[BotCategoryId]  
        ,[BotNatureId]  
        ,[BotTypeId]  
        ,[BotReusabilityId]  
        ,[BusinessProcessId]  
        ,[SubBusinessProcessId]  
        ,[ServiceId]  
        ,[Author]  
        ,[ContactDL]  
        ,[IsManuallyCreated]  
        ,[BotStatusId]  
        ,[IsDeleted]  
        ,[CreatedBy]  
        ,[CreatedOn] 
		,[AutomationTechnology] 
	    ,[DomainId] 
        ,[Benefits] 
	    ,[ProblemTypeId] 
	    ,[ActionType]
	    ,[ExecutionSubTypeId] 
	    ,[MakeVisible]
		,[Source]
		,[DownloadCount]
		,[IsPackOnlyBot] 
	    ,[IsAvailableinCognizantAutomationCenter] 
        )  
     VALUES  
        (@BotName  
        ,@Overview  
        ,@Description  
        ,null  
        ,null  
        ,@BotCategoryId  
        ,@BotNatureId  
        ,@BotTypeId  
        ,@BotReusabilityId  
        ,@BusinessProcessId  
        ,@SubBusinessProcessId  
        ,@ServiceId  
        ,@Author  
        ,@ContactDL  
        ,@IsManuallyCreated  
        ,@BotStatusId  
        ,@IsDeleted  
        ,@CreatedBy
        ,getdate()  
		,@AutomationTechnology
	    ,@domain
       ,@Benefits
	   ,@ProblemType
	   ,@ActionType
	   ,@ExecutionSubType 
	   ,@MakeVisible
	   ,'BoTs Added via Applens'
	   ,'NA'
	   ,'NA'
	   ,'NA'
       )  
       set @BotId = @@IDENTITY;         
  END     
 INSERT INTO BOT.TAGDetails  
     (BotDetailId,[Tag],[IsDeleted],[CreatedBy],[CreatedDate])  
     select @BotId,tag.item,@IsDeleted,@CreatedBy,GETDATE()  
     from dbo.SplitString(@tags, ',') tag where tag.Item is not null;  
     SELECT @BotId As BotId
	 
   IF not EXISTS(SELECT Id FROM BOT.[BotTargetApplicationMapping] WHERE BotId=@BotId) 
	 BEGIN
	 INSERT INTO [BOT].[BotTargetApplicationMapping]
			SELECT 
				 @BotId
				,TargetAppID.Item
				,0
				,@CreatedBy
				,GETDATE()
				,@CreatedBy
				,GETDATE()
			from dbo.SplitString(@BotTargetApplicationId, ',') TargetAppID where TargetAppID.item is not null
	 END

	ELSE
	BEGIN
	delete from [BOT].[BotTargetApplicationMapping] where BotId= @BotId
	
	INSERT INTO [BOT].[BotTargetApplicationMapping]
			SELECT 
				 @BotId
				,TargetAppID.Item
				,0
				,@CreatedBy
				,GETDATE()
				,@CreatedBy
				,GETDATE()
			from dbo.SplitString(@BotTargetApplicationId, ',') TargetAppID where TargetAppID.item is not null
		end


	IF not EXISTS(SELECT Id FROM BOT.[BotTechnologyMapping] WHERE BotId=@BotId) 
	BEGIN
			INSERT INTO [BOT].[BotTechnologyMapping]
			SELECT 
				 @BotId
				,TechID.item
				,0
				,@CreatedBy
				,GETDATE()
				,@CreatedBy
				,GETDATE()
			FROM dbo.SplitString(@TechnologyId, ',') TechID where TechID.item is not null;
    END
	ELSE
	BEGIN
	Delete from BOT.[BotTechnologyMapping] WHERE BotId=@BotId
	INSERT INTO [BOT].[BotTechnologyMapping]
			SELECT 
				 @BotId
				,TechID.item
				,0
				,@CreatedBy
				,GETDATE()
				,@CreatedBy
				,GETDATE()
			FROM dbo.SplitString(@TechnologyId, ',') TechID where TechID.item is not null;
	END

END TRY  
 BEGIN CATCH   
    DECLARE @ErrorMessage VARCHAR(MAX);   
  
          SELECT @ErrorMessage = ERROR_MESSAGE()   
          --ROLLBACK TRAN   
  
          -- Insert Error       
          EXEC AVL_INSERTERROR '[BOT].[CreateBOTMaster]',@ErrorMessage,0,0   
  END CATCH  
End