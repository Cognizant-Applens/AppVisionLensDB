    
/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] � [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
             
                  
CREATE PROCEDURE [PP].[SaveProjectProfilingScopeOfWorkDetail_Customer]                  
@ProjectID BIGINT,                    
@EmployeeID NVARCHAR(20),                    
@TvpProjectOtherAttributeValues as [PP].[TVP_ProjectOtherAttributeValues] READONLY,                  
@TvpProjectAttributeValues as [PP].[TVP_ProjectAttributeValues] READONLY,                    
@Percentage INT,                  
@IsApplensAsALM bit=null,                  
@IsExternalALM bit=null,                  
@ALMToolID int=null,                  
@ProjectTypeID int=null,                  
@ProjectTypeSource VARCHAR(250) = NULL,                  
@ProjectTypeTarget VARCHAR(250) = NULL ,                 
@IsNonBU bit=null                
AS                     
  BEGIN                     
 BEGIN TRY                      
    BEGIN TRAN                    
  SET NOCOUNT ON;                    
                       
 DECLARE @Result BIT;                 
 DECLARE @IsCognizant nvarchar(20),@ProjectType BIT = NULL;                 
                
 SELECT @IsCognizant=Iscoginzant from AVL.MAS_Projectmaster(NOLOCK) WHERE PROJECTID=@ProjectID                
     
 IF @Percentage>100 SET @Percentage = 100                        
                   
 IF EXISTS (select 1 from [PP].[ScopeOfWork] (NOLOCK) where ProjectID = @ProjectID)                  
 BEGIN                  
  UPDATE [PP].[ScopeOfWork] SET                   
  [IsApplensAsALM]=@IsApplensAsALM,[IsExternalALM]=@IsExternalALM,[ALMToolID]=@ALMToolID,                  
  [ProjectTypeID]=@ProjectTypeID,[ModifiedBy]=@EmployeeID,[ModifiedDate]=GETDATE(),                  
  ProjectTypeSource = @ProjectTypeSource, ProjectTypeTarget = @ProjectTypeTarget                  
  where ProjectID = @ProjectID                  
 END                  
 ELSE                  
 BEGIN                  
  INSERT INTO [PP].[ScopeOfWork]                  
      (                  
   --[ID],                  
   [ProjectID],[IsApplensAsALM],[IsExternalALM],[ALMToolID],[ProjectTypeID]                  
     ,[IsDeleted],[CreatedBY],[CreatedDate], ProjectTypeSource, ProjectTypeTarget,IsTransitionInScope)                  
  VALUES                  
   (                  
   --(select isnull(max(ID),0)+1 from [PP].[ScopeOfWork]),                   
   @ProjectID,@IsApplensAsALM,@IsExternalALM,@ALMToolID,@ProjectTypeID                  
   ,0,@EmployeeID,GETDATE(), @ProjectTypeSource, @ProjectTypeTarget,@ProjectType       
)                  
 END                  
                  
--Update scope of work details as deleted                  
--1->Scope of project, 3->excution method,4-type of project 34- project sub type 35-External ALM tool? 51 - Other Type                  
                 
                 
 DECLARE @UpdatedBy NVARCHAR(50)                
 DECLARE @UpdatedDate Datetime                
 DECLARE  @UpdatedByExecution NVARCHAR(50)                
 DECLARE  @UpdatedDateExecution datetime                
                   
                
  IF EXISTS              
   (SELECT TOP 1 temp.AttributeValueid FROM               
      PP.ProjectAttributeValues PA                 
     INNER JOIN @TvpProjectAttributeValues Temp                 
   ON PA.ProjectID = @ProjectID                
   AND PA.AttributeValueID = Temp.AttributeValueid               
   AND PA.AttributeID = Temp.AttributeID                
   AND PA.AttributeID=51 AND createdBy like '%MainSpringFeed%'  --51-Modernization Scope               
    AND ModifiedBy IS NULL AND Isdeleted=0)              
   BEGIN              
    SET @UpdatedBy=null              
    SET @UpdatedDate=null              
   END              
   ELSE              
   BEGIN              
    SET @UpdatedBy=@EmployeeID              
    SET @UpdatedDate=getdate()              
   END              
                
   IF EXISTS                
   (SELECT TOP 1 temp.AttributeValueid FROM                 
      PP.ProjectAttributeValues PA (NOLOCK)                  
     INNER JOIN @TvpProjectAttributeValues Temp                   
   ON PA.ProjectID = @ProjectID                  
   AND PA.AttributeValueID = Temp.AttributeValueid             
   AND PA.AttributeID = Temp.AttributeID                  
   AND PA.AttributeID=3 AND createdBy like '%MainSpringFeed%'  --3--Execution Method                
    AND ModifiedBy IS NULL AND Isdeleted=0)                
   BEGIN                
    SET @UpdatedByExecution=null                
    SET @UpdatedDateExecution=null                
   END                
   ELSE                
   BEGIN                
    SET @UpdatedByExecution=@EmployeeID                
 SET @UpdatedDateExecution=getdate()                
   END                
                
                
                
if(@IsCognizant=0 or @IsNonBU=1)                
BEGIN                
                
  UPDATE  PP.ProjectAttributeValues  SET                   
    ModifiedBy  = @EmployeeID,                    
          ModifiedDate  = getdate(),                         
          IsDeleted = 1  where AttributeID in(1,3,4,34,35,51) and ProjectID = @ProjectID;                 
END                
ELSE                 
BEGIN                
  UPDATE  PP.ProjectAttributeValues  SET                   
          ModifiedBy = @EmployeeID,                    
          ModifiedDate = getdate(),                    
          IsDeleted =1  where AttributeID in(1,35,34,51,3) and ProjectID = @ProjectID;               
              
                
                   
                   
END                
--new values save                  
                  
SELECT DISTINCT * INTO #TvpProjectAttributeValues FROM @TvpProjectAttributeValues                
                  
if(@IsCognizant=0 or @IsNonBU=1)                
BEGIN                
 MERGE PP.ProjectAttributeValues PA                   
    using #TvpProjectAttributeValues AS Temp                   
    ON PA.ProjectID = @ProjectID  and PA.AttributeValueID = Temp.AttributeValueID                 
    and PA.AttributeID = Temp.AttributeID                  
    WHEN matched THEN                   
      UPDATE SET PA.AttributeValueID           = Temp.AttributeValueID,                  
     PA.ModifiedBy                 = @EmployeeID,                  
     PA.ModifiedDate               = getdate(),                  
     PA.IsDeleted     =0                  
    WHEN NOT matched THEN                   
      INSERT (                   
      ProjectID,AttributeValueID  ,AttributeID  ,[IsDeleted]  ,[CreatedBy]                   
   ,[CreatedDate]   ,[ModifiedBy]  ,[ModifiedDate]                  
     )                  
      values                  
      (                   
         @ProjectID   ,Temp.AttributeValueID,Temp.AttributeID   ,0                  
   ,@EmployeeID   ,getdate()   ,null  ,null                  
     );                  
  END                
  ELSE                
  BEGIN                
             
    MERGE PP.ProjectAttributeValues PA                 
    using #TvpProjectAttributeValues AS Temp                 
    ON PA.ProjectID = @ProjectID and PA.AttributeValueID = Temp.AttributeValueID and PA.AttributeID = Temp.AttributeID               
    WHEN matched and temp.AttributeID  IN(1,35,34,51,3) THEN                 
      UPDATE SET PA.AttributeValueID = Temp.AttributeValueID,                
 PA.ModifiedBy = CASE  WHEN PA.AttributeID=51 THEN  @UpdatedBy               
                            WHEN PA.AttributeID=3 THEN  @UpdatedByExecution             
       WHEN PA.AttributeID=34 THEN  NULL             
                            ELSE @EmployeeID END,              
      PA.ModifiedDate = CASE WHEN PA.AttributeID=51 THEN  @UpdatedDate               
                             WHEN PA.AttributeID=3 THEN  @UpdatedDateExecution              
        WHEN PA.AttributeID=34 THEN  NULL            
                             ELSE Getdate() END,              
      PA.IsDeleted     = 0                
    WHEN NOT matched BY TARGET  and temp.AttributeID  IN(1,35,34,51,3) THEN                 
      INSERT (                 
      ProjectID,AttributeValueID  ,AttributeID  ,[IsDeleted]  ,[CreatedBy]                 
   ,[CreatedDate]   ,[ModifiedBy]  ,[ModifiedDate]                
     )                
      values                
      (                 
         @ProjectID   ,Temp.AttributeValueID,Temp.AttributeID   ,0                
   ,CASE WHEN Temp.AttributeID = 34 THEN 'MainspringFeed' Else @EmployeeID End  ,getdate()   ,null  ,null);                
  END                
                
                
                
                
 --Soft delete existing others                
  UPDATE  PP.OtherAttributeValues  SET                 
     ModifiedBy = @EmployeeID,                  
     ModifiedDate               = getdate(),                  
     IsDeleted     =1  where AttributeValueID in                 
  --(15,23)                
  -------OR---------                
  (                
  select PA.AttributeValueID from mas.PPAttributeValues PA (NOLOCK)                 
  join mas.PPAttributes MA(NOLOCK) on PA.AttributeID=ma.AttributeID                
  where --lower(trim(AttributeValueName)) like 'others' and                 
  PA.IsDeleted=0 AND MA.AttributeID IN(1,3,4,34,35)                
  )                 
  and ProjectID = @ProjectID;                
                
--save others values                
 MERGE PP.OtherAttributeValues OA                   
    using @TvpProjectOtherAttributeValues AS Temp                   
    ON OA.ProjectID = @ProjectID  and OA.AttributeValueID = Temp.AttributeValueID                 
    WHEN matched THEN                   
      UPDATE SET OA.AttributeValueID           = Temp.AttributeValueID,                  
  OA.OtherFieldValue   =Temp.OtherFieldValue,                
     OA.ModifiedBy                 = @EmployeeID,                  
     OA.ModifiedDate               = getdate(),                  
     OA.IsDeleted     =0                  
    WHEN NOT matched THEN                   
      INSERT                 
   (                   
   ProjectID,AttributeValueID  ,[OtherFieldValue]  ,[IsDeleted]  ,[CreatedBy]                   
    ,[CreatedDate]   ,[ModifiedBy]  ,[ModifiedDate]                  
   )                  
      values                  
      (                   
         @ProjectID   ,Temp.AttributeValueID,Temp.OtherFieldValue   ,0                  
   ,@EmployeeID   ,getdate()   ,null  ,null                  
      );                
                  
                
 SET @Result = 1                  
 Select @Result as Result                  
 DROP TABLE #TvpProjectAttributeValues                
 EXEC [PP].[SaveAdapterTileProgressPercentage] @ProjectID,@EmployeeID            
           
   --update supporttypeid            
            
  Declare @scopecount int,@projectscope int=0;              
  IF EXISTS (select ProjectID from pp.ProjectAttributeValues (NOLOCK) where ProjectID=@ProjectID and AttributeID=1 and IsDeleted=0)              
  BEGIN               
  if exists (select ProjectID from PP.ProjectAttributeValues (NOLOCK)  where  AttributeID=1 and ProjectID=@ProjectID and AttributeValueID in (2,3) and IsDeleted=0)              
  begin              
  select @scopecount= Count(ProjectID) from PP.ProjectAttributeValues (NOLOCK)  where  AttributeID=1 and ProjectID=@ProjectID and AttributeValueID in (2,3) and IsDeleted=0              
              
  if (@scopecount=2)              
  begin              
  select @projectscope=3;--IF BOTH MAINTANANCE & CIS HAD BEEN SELECTED              
  end              
              
  else if(@scopecount=1)              
  Begin              
              
  select @projectscope= case               
  when AttributeValueID = 2 Then 1 --IF MAINTANANCE WAS SELECTED              
  when AttributeValueID = 3 Then 2 --IF CIS WAS SELECTED     
  end               
  from PP.ProjectAttributeValues(NOLOCK)  where  AttributeID=1 and ProjectID=@ProjectID and AttributeValueID in (2,3) and IsDeleted=0              
  end              
  end              
              
  else              
  begin              
  select @projectscope=4;-- IF DEVELOPMENT/TESTING HAD BEEN SELECTED              
  end              
              
  IF EXISTS (SELECT ProjectID FROM [AVL].[MAP_ProjectConfig](NOLOCK) WHERE ProjectID = @ProjectID)              
  BEGIN               
  UPDATE [AVL].[MAP_ProjectConfig] SET SupportTypeID = @projectscope  WHERE ProjectID = @ProjectID              
  END              
              
  ELSE              
  BEGIN              
  Insert into [AVL].[MAP_ProjectConfig] (ProjectID,SupportTypeId) values (@ProjectID,@projectscope)              
  END              
              
  END              
            
  IF(@ProjectID > 0 AND @ALMToolID > 0 AND @EmployeeID IS NOT NULL AND @EmployeeID <> '')            
  BEGIN            
 EXEC ToolsCatalog.dbo.SaveALMToolBasedOnProjectProfiling @ProjectID, @ALMToolID, @EmployeeID            
  END            
                
 COMMIT TRAN    
 SET NOCOUNT OFF;                  
 END TRY                   
   BEGIN CATCH                   
  SET @Result = 0                  
  Select @Result as Result                  
        DECLARE @ErrorMessage VARCHAR(MAX);                   
        SELECT @ErrorMessage = ERROR_MESSAGE()                   
        --INSERT Error                     
   ROLLBACK TRAN                  
        EXEC AVL_INSERTERROR  '[PP].[SaveProjectProfilingScopeOfWorkDetail_Customer]', @ErrorMessage,  0,0                   
   END CATCH                   
  END
