/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
                  
-- =========================================================================================    
-- Author      : 823144    
-- Create date : April 20, 2021   
-- Description : Save the Project Details of Scope       
-- Revision    :    
-- Revised By  :    
-- =========================================================================================    
     
 CREATE PROCEDURE [PP].[SaveProjectDetails]    
@ProjectID BIGINT,    
@EmployeeID NVARCHAR(50),    
@Shortdescription NVARCHAR(500),    
@ProjectCategory INT,    
@TvpProjectOtherAttributeValues AS [PP].[TVP_ProjectOtherAttributeValues] READONLY,    
@TvpProjectAttributeValues as [PP].[TVP_ProjectAttributeValues] READONLY    
AS     
  BEGIN     
 BEGIN TRY      
    BEGIN TRAN    
  SET NOCOUNT ON;    
      
  --Short Description and Project Category    
  DECLARE @IsCognizant BIT    
    
  DECLARE @Count int=(SELECT COUNT(ProjectID) FROM PP.ProjectDetails(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0)    
  SELECT @IsCognizant = IsCoginzant FROM AVL.MAS_ProjectMaster WITH (NOLOCK) WHERE ProjectId = @ProjectID AND IsDeleted = 0     
       
    
  IF(@ProjectCategory=0)    
  BEGIN    
   SET @ProjectCategory=NULL;    
  END    
    
  DECLARE @UpdatedBy NVARCHAR(50)    
  DECLARE @UpdatedDate Datetime    
  --Shotdescription comparision with Mainspring table    
  if(@IsCognizant=1)    
  BEGIN    
  DECLARE @MainspringDesc VARCHAR(2000)    
  DECLARE @IsSameDesc BIT    
  DECLARE @IsMainspring BIT    
  DECLARE @CreatedBy  NVARCHAR(50)    
    
  SELECT Top 1 @MainspringDesc=  ISNULL(PDD.ShortDescriptionofProject,'')      
  FROM     
  MS.ProjectDemographicDetails PDD (NOLOCK)             
  INNER JOIN MS.ProjectRegistrationDetails PRD (NOLOCK) ON PRD.RegistrationId = PDD.RegistrationId              
  INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON PM.EsaProjectID = PRD.EsaProjectId              
  WHERE PM.projectid = @ProjectID AND PRD.IsDeleted = 0 AND PRD.Type='Predominant' AND PRD.TypeOfProject in ('Project','Group Project')   
       
  SELECT @IsSameDesc = dbo.fnStringCompare(@MainspringDesc,@Shortdescription)    
        
  IF(@IsSameDesc=0) --User Updated    
  BEGIN    
   SET @UpdatedBy =@EmployeeID     
   SET @UpdatedDate=Getdate()    
   SET @IsMainspring=0    
   SET @CreatedBy =@EmployeeID    
  END    
  ELSE  --Mainspring feed user didn't updated    
  BEGIN    
   SET @UpdatedBy =NULL     
   SET @UpdatedDate=NULL    
   SET @CreatedBy ='MainSpringFeed'    
   --SET @CreatedDate=Getdate()    
   SET @IsMainspring=1    
  END    
  IF (@Count>0 )    
    BEGIN    
    UPDATE PP.ProjectDetails    
    SET ProjectShortDescription=@Shortdescription,    
    ProjectCategoryID=@ProjectCategory,    
    IsDeleted=0,    
    ModifiedBY=@UpdatedBy,    
    ModifiedDate=@UpdatedDate,    
    ismainspring=@IsMainspring    
    WHERE     
    ProjectID=@ProjectID AND IsDeleted=0    
   END    
   ELSE    
   BEGIN    
    INSERT INTO PP.ProjectDetails    
    (    
    ProjectID,    
    ProjectShortDescription,    
    ProjectCategoryID,    
    IsDeleted,    
    CreatedBY,    
    CreatedDate,    
    ModifiedBY,    
    ModifiedDate,    
    ismainspring    
    ) VALUES(    
    @ProjectID,    
    @Shortdescription,    
    @ProjectCategory,    
    0,    
    @CreatedBy,    
    GETDATE(),    
    NULL,    
    NULL,    
    @IsMainspring    
    )    
   END    
    
  END    
  ELSE  --Customer flow no changes    
  BEGIN    
  IF (@Count>0 )    
    BEGIN    
    UPDATE PP.ProjectDetails    
    SET ProjectShortDescription=@Shortdescription,    
    ProjectCategoryID=@ProjectCategory,    
    IsDeleted=0,    
    ModifiedBY=@EmployeeID,    
    ModifiedDate=GETDATE()    
    WHERE     
    ProjectID=@ProjectID AND IsDeleted=0    
   END    
   ELSE    
   BEGIN    
    INSERT INTO PP.ProjectDetails    
    (    
    ProjectID,    
    ProjectShortDescription,    
    ProjectCategoryID,    
    IsDeleted,    
    CreatedBY,    
    CreatedDate,    
    ModifiedBY,    
    ModifiedDate    
    ) VALUES(    
    @ProjectID,    
    @Shortdescription,    
    @ProjectCategory,    
    0,    
    @EmployeeID,   
    GETDATE(),    
    NULL,    
    NULL    
    )    
   END    
   END    
    
   --Other Field values    
    
   UPDATE PP.OtherAttributeValues SET IsDeleted=1 WHERE ProjectID=@ProjectID AND AttributeValueID IN (37,46);    
    
   MERGE PP.OtherAttributeValues OAV       
            USING @TvpProjectOtherAttributeValues AS Temp       
            ON OAV.ProjectID = @ProjectID  AND OAV.AttributeValueID = Temp.AttributeValueID     
            WHEN MATCHED THEN       
            UPDATE SET     
   OAV.AttributeValueID = Temp.AttributeValueID,      
   OAV.OtherFieldValue = Temp.OtherFieldValue,    
   OAV.ModifiedBy = @EmployeeID,      
   OAV.ModifiedDate = GETDATE(),      
   OAV.IsDeleted =0      
   WHEN NOT MATCHED THEN       
   INSERT    
         (       
      ProjectID,    
   AttributeValueID,    
   OtherFieldvalue,    
   Isdeleted,    
   CreatedBY,    
   CreatedDate,    
   ModifiedBY,    
   ModifiedDate    
         )      
   VALUES      
   (       
    @ProjectID,    
    Temp.AttributeValueID,    
    Temp.OtherFieldValue,    
    0,    
    @EmployeeID,    
    GETDATE(),    
    NULL,    
    NULL    
   );    
    
   --Attribute Values of  Multi Select    
   DECLARE @UpdatedByEModel NVARCHAR(50)    
   DECLARE @UpdatedDateEModel Datetime    
   DECLARE @UpdatedByBuDriver NVARCHAR(50)    
   DECLARE @UpdatedDateBuDriver Datetime    
       
   IF EXISTS    
   (SELECT TOP 1 temp.AttributeValueID     
   FROM     
     PP.ProjectAttributeValues PA  (NOLOCK)     
   INNER JOIN @TvpProjectAttributeValues Temp       
   ON PA.ProjectID = @ProjectID      
   AND PA.AttributeValueID = Temp.AttributeValueID     
   AND PA.AttributeID = Temp.AttributeID      
    AND PA.AttributeID=9 AND createdBy like '%MainSpringFeed%'       
    AND ModifiedBy IS NULL AND Isdeleted=0)--9-Engagment Model      
   BEGIN    
    set @UpdatedByEModel=null    
    set @UpdatedDateEModel=null    
   END    
   ELSE    
   BEGIN    
     set @UpdatedByEModel=@EmployeeID    
    set @UpdatedDateEModel=getdate()    
   END    
    
   IF EXISTS    
   (SELECT TOP 1 temp.AttributeValueID     
   FROM     
     PP.ProjectAttributeValues PA   (NOLOCK)    
   INNER JOIN @TvpProjectAttributeValues Temp       
   ON PA.ProjectID = @ProjectID      
   AND PA.AttributeValueID = Temp.AttributeValueID     
   AND PA.AttributeID = Temp.AttributeID      
   AND PA.AttributeID=19 AND createdBy like '%MainSpringFeed%'       
    AND ModifiedBy IS NULL AND Isdeleted=0)--Business Driver    
   BEGIN    
    set @UpdatedByBuDriver=null    
    set @UpdatedDateBuDriver=null    
   END    
   ELSE    
   BEGIN    
   set @UpdatedByBuDriver=@EmployeeID    
    set @UpdatedDateBuDriver=getdate()    
   END    
    
   UPDATE PP.ProjectAttributeValues     
   SET IsDeleted=1,    
   modifiedBy=@employeeID,    
   modifiedDate=getdate()    
   WHERE ProjectID=@ProjectID AND AttributeID IN (9,19);    
    
   UPDATE PP.ProjectAttributeValues     
   SET IsDeleted=1    
   WHERE ProjectID=@ProjectID AND AttributeID IN (21,52);    
    
            
   MERGE PP.ProjectAttributeValues PA       
   USING @TvpProjectAttributeValues AS Temp       
   ON PA.ProjectID = @ProjectID      
   AND PA.AttributeValueID = Temp.AttributeValueID     
   AND PA.AttributeID = Temp.AttributeID      
   AND PA.AttributeID IN(19,9,21,52)    
   WHEN MATCHED THEN      
   UPDATE SET     
   PA.AttributeValueID = Temp.AttributeValueID,      
   PA.ModifiedBy= CASE WHEN PA.AttributeID=9 THEN  @UpdatedByEModel    
           WHEN PA.AttributeID=19 THEN  @UpdatedByBuDriver    
        ELSE @EmployeeID END,     
   PA.ModifiedDate = CASE WHEN PA.AttributeID=9 THEN  @UpdatedDateEModel    
         WHEN PA.AttributeID=19 THEN  @UpdatedDateBuDriver    
         ELSE Getdate() END,     
   PA.IsDeleted = 0     
   WHEN NOT MATCHED THEN       
   INSERT (    
    ProjectID,    
    AttributeValueID,    
    AttributeID,    
    IsDeleted,    
    CreatedBy,    
    CreatedDate,    
    ModifiedBy,    
    ModifiedDate    
             )      
   VALUES      
   (       
   @ProjectID    
   ,Temp.AttributeValueID    
   ,Temp.AttributeID       
   ,0      
   ,@EmployeeID       
   ,getdate()       
   ,NULL      
   ,NULL      
   );    
    
        COMMIT TRAN   
		SET NOCOUNT OFF
 END TRY     
    
    BEGIN CATCH     
      
        DECLARE @ErrorMessage VARCHAR(MAX);     
        SELECT @ErrorMessage = ERROR_MESSAGE()     
        --INSERT Error       
  ROLLBACK TRAN    
        EXEC AVL_INSERTERROR  '[PP].[SaveProjectDetails]', @ErrorMessage,  0, 0     
    END CATCH     
  END
