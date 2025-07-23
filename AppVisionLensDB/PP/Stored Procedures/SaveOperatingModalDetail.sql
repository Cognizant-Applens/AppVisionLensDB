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
-- Author      : V Shankar Ganesh
-- Create date : May 22, 2020
-- Description : Save the Operating Modal details against the project   
-- Revision    :
-- Revised By  :
-- =========================================================================================

CREATE PROCEDURE [PP].[SaveOperatingModalDetail]  
@ProjectID BIGINT,  
@EmployeeID NVARCHAR(20),  
@WorkItemSize INT=null,  
@VendorPresence BIT,  
@TvpProjectOtherAttributeValues as [PP].[TVP_ProjectOtherAttributeValues] READONLY,  
@TvpProjectAttributeValues as [PP].[TVP_OperatingModelAttributeValues] READONLY,    
--@OMExtendedProjectDetails as [PP].[TVP_ExtendedProjectDetails] READONLY,   
--@OMAttributeValues as [PP].[TVP_ProjectAttributeValues] READONLY,  
@OMVendorDetails as [PP].[VendorDetails] READONLY  
AS   
  BEGIN   
 BEGIN TRY    
    BEGIN TRAN  
  SET NOCOUNT ON;  
     
 DECLARE @Result BIT;     
  
 --Inserts the Operating Modal values(Other than Attribute values) >Start<  
  
 IF EXISTS (select TOP 1 1 from [PP].[OperatingModel]   
 where ProjectID = @ProjectID AND ISNULL(IsDeleted,0)=0 )  
 BEGIN  
  UPDATE [PP].[OperatingModel] SET   
  WorkItemSize=@WorkItemSize,  
  VendorPresence=@VendorPresence,  
  [ModifiedBy]=@EmployeeID,  
  [ModifiedDate]=GETDATE()  
  where ProjectID = @ProjectID AND IsDeleted<>1  
 END  
 ELSE  
 BEGIN  
  INSERT INTO [PP].[OperatingModel]  
      (  
   [ProjectID],[WorkItemSize],[VendorPresence]  
     ,[IsDeleted],[CreatedBY],[CreatedDate])  
  VALUES  
   (  
   @ProjectID,@WorkItemSize,@VendorPresence,0,@EmployeeID,GETDATE()  
   )  
 END  
  
   --Inserts the Operating Modal values(Other than Attribute values) >End<  
  
 --Inserts the Attribute values >Start<  
 DECLARE @UpdatedBy VARCHAR(50)  
 DECLARE @UpdatedDate Datetime  
  
   IF NOT EXISTS(SELECT TOP 1 temp.AttributeValue FROM   
        PP.ProjectAttributeValues PA     
     INNER JOIN @TvpProjectAttributeValues Temp     
   ON PA.ProjectID = @ProjectID    
   AND PA.AttributeValueID = Temp.AttributeValue   
   AND PA.AttributeID = Temp.AttributeID    
   AND PA.AttributeID=37 and isdeleted=0)  
   BEGIN  
    UPDATE PP.ProjectAttributeValues   
       SET IsDeleted=1,  
        ModifiedBy = @EmployeeID,    
        ModifiedDate =getdate()    
       WHERE   
       ProjectID=@ProjectID   
       AND  AttributeID in(37)   
       AND IsDeleted<>1  
       
   INSERT INTO PP.ProjectAttributeValues(     
    ProjectID,AttributeValueID  ,AttributeID  ,[IsDeleted]  ,[CreatedBy]     
    ,[CreatedDate]   ,[ModifiedBy]  ,[ModifiedDate]    
   )    
   SELECT     
     @ProjectID   ,AttributeValue,AttributeID   ,0    
    ,@EmployeeID   ,getdate()   ,null  ,null  FROM @TvpProjectAttributeValues WHERE AttributeID=37  
       
      
   END  
  
 UPDATE PP.ProjectAttributeValues  
 SET IsDeleted=1   
 WHERE ProjectID=@ProjectID   
 AND  AttributeID in(26,50)   
 AND IsDeleted<>1  
  
 MERGE PP.ProjectAttributeValues PA     
    using @TvpProjectAttributeValues AS Temp     
    ON PA.ProjectID = @ProjectID    
 and PA.AttributeValueID = Temp.AttributeValue  
 and PA.AttributeID = Temp.AttributeID    
 AND ISNULL(PA.IsDeleted,0)=0   
    WHEN matched and temp.AttributeID  IN(26,50) THEN    
   
  UPDATE SET PA.AttributeValueID = Temp.AttributeValue,    
     PA.ModifiedBy                 =  @EmployeeID,    
     PA.ModifiedDate               =  Getdate(),    
     PA.IsDeleted     =0   
  WHEN NOT matched BY TARGET  and temp.AttributeID  IN(26,50)THEN    
   INSERT (     
      ProjectID,AttributeValueID  ,AttributeID  ,[IsDeleted]  ,[CreatedBy]     
   ,[CreatedDate]   ,[ModifiedBy]  ,[ModifiedDate]    
     )    
      values    
      (     
         @ProjectID   ,Temp.AttributeValue,Temp.AttributeID   ,0    
   ,@EmployeeID   ,getdate()   ,null  ,null    
     );   
    --Inserts the Attribute values >End<  
  
  --Inserts the 'Others' Attribute values >Start<  
  UPDATE  PP.OtherAttributeValues set IsDeleted=1 where AttributeValueID in(194,243) AND ProjectID=@ProjectID AND IsDeleted <>1  
  
  
  MERGE PP.OtherAttributeValues OA     
    using @TvpProjectOtherAttributeValues AS Temp     
    ON OA.ProjectID = @ProjectID  and OA.AttributeValueID = Temp.AttributeValueID   
 AND ISNULL(OA.Isdeleted,0)=0  
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
     
  --Inserts the 'Others' Attribute values >End<  
  
  
  --Inserts the Vendor Details >Start<  
  
      DELETE FROM  PP.Project_VendorDetails WHERE ProjectID = @ProjectID  
  
   INSERT INTO PP.Project_VendorDetails  
   select   
   @ProjectID,LTRIM(RTRIM(Temp.VendorName)),Temp.VendorScopeID,0,@EmployeeID,GetDate(),NULL,NULL  
   from @OMVendorDetails Temp   
   WHERE  Temp.VendorDetailID = 0  AND LTRIM(RTRIM(Temp.VendorName)) NOT IN (SELECT VendorName FROM PP.Project_VendorDetails WHERE ProjectID =@ProjectID AND IsDeleted = 0 )  
  
  
   --UPDATE VD  set  
   --VD.VendorName = LTRIM(RTRIM(Temp.VendorName)),  
   --VD.VendorScopeID = Temp.VendorScopeID,  
   --VD.ModifiedBy = @EmployeeID,  
   --VD.ModifiedDate = GetDate()  
   --from PP.Project_VendorDetails VD  
   --join @OMVendorDetails Temp ON  VD.VendorDetailID = Temp.VendorDetailID  
   --where VD.ProjectId = @ProjectID AND Temp.VendorDetailID != 0  
  
  
   --UPDATE VD SET  
   --VD.IsDeleted=1,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE()   
   --FROM  PP.Project_VendorDetails VD   
   --INNER JOIN @OMVendorDetails AS Temp   
   --ON VD.ProjectID = @ProjectID  and VD.VendorDetailID = Temp.VendorDetailID  
   --and VD.VendorDetailID NOT IN  
   --(SELECT VendorDetailID FROM @OMVendorDetails)  
      
   --Inserts the Vendor Details >End<   
      
  
   SET @Result = 1  
   Select @Result as Result  
  COMMIT TRAN  
 END TRY   
  
    BEGIN CATCH   
  SET @Result = 0  
  Select @Result as Result  
        DECLARE @ErrorMessage VARCHAR(MAX);   
        SELECT @ErrorMessage = ERROR_MESSAGE()   
        --INSERT Error     
  ROLLBACK TRAN  
        EXEC AVL_INSERTERROR  '[PP].[SaveOperatingModalDetail]', @ErrorMessage,  0,   
        0   
    END CATCH   
  END
