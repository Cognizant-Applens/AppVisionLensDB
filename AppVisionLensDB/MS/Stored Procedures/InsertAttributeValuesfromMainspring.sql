

/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] � [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    
CREATE   PROCEDURE [MS].[InsertAttributeValuesfromMainspring]                
AS                  
BEGIN                     
 BEGIN TRY                    
  BEGIN TRAN                  
 SET NOCOUNT ON;                  
                  
 DECLARE @Archetype INT                
 DECLARE @SubArchetype INT                
 DECLARE @ModernizationScope INT                
 DECLARE @BusinessDriver INT                
 DECLARE @PricingModel INT                
 DECLARE @DeliveryEngagementModel INT                
 DECLARE @Unit INT                
 DECLARE @MainspringPOU INT        
 DECLARE @AdditionalArchetype INT       
                
 SELECT @Archetype= attributeid FROM mas.PPAttributes WITH(NOLOCK) WHERE attributename='TypeofProject' and isdeleted=0                 
 SELECT @SubArchetype=attributeid FROM mas.PPAttributes WITH(NOLOCK) WHERE attributename='ProjectSubType' and isdeleted=0                  
 SELECT @ModernizationScope=attributeid FROM mas.PPAttributes WITH(NOLOCK) WHERE attributename='other type' and isdeleted=0                  
 SELECT @BusinessDriver=attributeid FROM mas.PPAttributes WITH(NOLOCK) WHERE attributename='BusinessDriver' and isdeleted=0                  
 SELECT @PricingModel=attributeid FROM mas.PPAttributes WITH(NOLOCK) WHERE attributename='PricingModel' and isdeleted=0                  
 SELECT @DeliveryEngagementModel=attributeid FROM mas.PPAttributes WITH(NOLOCK) WHERE attributename='DeliveryEngagementModel' and isdeleted=0                  
 SELECT @Unit=attributeid FROM mas.PPAttributes WITH(NOLOCK) WHERE attributename='OPLProjectowningUnit' and isdeleted=0                  
 SELECT @MainspringPOU=attributeid FROM mas.PPAttributes WITH(NOLOCK) WHERE attributename='MainspringPOU' and isdeleted=0      
 SELECT @AdditionalArchetype= attributeid FROM mas.PPAttributes WITH(NOLOCK) WHERE attributename='AdditionalArchetype' and isdeleted=0      
 DECLARE @DataFrom Varchar(20) = 'MainspringFeed';             
           
 --------------- Insert Unit-------------                  
 INSERT INTO mas.ppattributevalues               
 (AttributeValueName,AttributeID,IsDeleted,CreatedBy,CreatedDate,ParentID,AttributeValueOrder)              
 SELECT                   
 MUM.Name,                  
 @Unit,                  
 0,                  
 @DataFrom,                  
 Getdate(),                  
 NULL,                  
 NULL                  
 FROM AVMCOEESA.MS.Unit MUM                  
 WHERE MUM.Name not in (SELECT Attributevaluename FROM mas.ppattributevalues WHERE Attributeid=@Unit)                   
                  
 UPDATE PAV                
 SET PAV.Isdeleted=1                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=0 AND PAV.Attributeid=@Unit AND                
 PAV.Attributevaluename NOT IN (SELECT Name FROM AVMCOEESA.MS.Unit WITH(NOLOCK)WHERE IsDeleted=0)                
                
 UPDATE PAV                
 SET PAV.Isdeleted=0                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=1 AND PAV.Attributeid=@Unit AND                
 PAV.Attributevaluename IN (SELECT Name FROM AVMCOEESA.MS.Unit WITH(NOLOCK) WHERE IsDeleted=0)                
                
 --------------- Insert POU-------------                  
 INSERT INTO mas.ppattributevalues                
 (AttributeValueName,AttributeID,IsDeleted,CreatedBy,CreatedDate,ParentID,AttributeValueOrder)              
 SELECT                   
 MPM.POU,                  
 @MainspringPOU,                  
 0,                  
 @DataFrom,                  
 Getdate(),                  
 (Select AttributeValueID from mas.ppattributevalues WITH(NOLOCK) Where AttributeId = @Unit And AttributeValueName= MPM.UNIT),                  
 NULL                  
 FROM AVMCOEESA.MS.POU MPM                  
 WHERE MPM.POU not in (SELECT Attributevaluename FROM mas.ppattributevalues WITH(NOLOCK) WHERE Attributeid=@MainspringPOU)                  
                 
 UPDATE PAV                
 SET PAV.Isdeleted=1                
 FROM MAS.PPAttributeValues PAV WHERE PAV.Isdeleted=0 AND PAV.Attributeid=@MainspringPOU AND                
 PAV.Attributevaluename NOT IN (SELECT POU FROM AVMCOEESA.MS.POU WITH(NOLOCK) WHERE IsDeleted=0)                
                
 UPDATE PAV                
 SET PAV.Isdeleted=0                
 FROM MAS.PPAttributeValues PAV  WITH(NOLOCK) WHERE PAV.Isdeleted=1 AND PAV.Attributeid=@MainspringPOU AND                
 PAV.Attributevaluename IN (SELECT POU FROM AVMCOEESA.MS.POU WITH(NOLOCK)  WHERE IsDeleted=0)            
  ---------------  Insert ArcheType ---------------                  
                   
 INSERT INTO mas.ppattributevalues               
 (AttributeValueName,AttributeID,IsDeleted,CreatedBy,CreatedDate,ParentID,AttributeValueOrder)              
 SELECT                   
 PAM.Name,                  
 @Archetype,                  
 0,                  
 @DataFrom,                  
 Getdate(),                  
 NULL,                  
 NULL                  
 FROM AVMCOEESA.MS.PrimaryArchetype PAM WITH(NOLOCK)              
 WHERE PAM.Name not in (SELECT Attributevaluename FROM mas.ppattributevalues WITH(NOLOCK) WHERE Attributeid=@Archetype)                
                 
 UPDATE PAV                
 SET PAV.Isdeleted=1                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=0 AND PAV.Attributeid=@Archetype AND                
 PAV.Attributevaluename NOT IN (SELECT Name FROM AVMCOEESA.MS.PrimaryArchetype WITH(NOLOCK) WHERE IsDeleted=0) AND CreatedBy = @DataFrom                
                  
 UPDATE PAV                
 SET PAV.Isdeleted=0                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=1 AND PAV.Attributeid=@Archetype AND                
 PAV.Attributevaluename IN (SELECT Name FROM AVMCOEESA.MS.PrimaryArchetype WITH(NOLOCK) WHERE IsDeleted=0) AND CreatedBy = @DataFrom                
                 
 ----------------- Insert SubArcheType -------------                  
  DECLARE @ProjectSubArcheType [MS].[ArcheSubArchetypeUnitMapping] ;                
  INSERT INTO @ProjectSubArcheType SELECT Unit,Archetype,Subarchetype from AVMCOEESA.MS.ArchetypeSubarchtype_UnitMapping where Unit <>'--None--' AND ISNULL(Unit,'') <>'' AND Archetype<>'--None--' AND ISNULL(Archetype,'') <>''             
   
   
                
 EXEC [MS].[InsertSubArcheTypeAttributeValuesfromMainspring] 1,@ProjectSubArcheType                
                 
 UPDATE PAV                
 SET PAV.Isdeleted=1                
 FROM MAS.PPAttributeValues PAV WHERE PAV.Isdeleted=0 AND PAV.Attributeid=@SubArchetype AND                
 PAV.Attributevaluename NOT IN (SELECT Name FROM AVMCOEESA.MS.SubArchetype WHERE IsDeleted=0)                 
 AND PAV.Attributevaluename  <>'N/A'            
                
 UPDATE PAV                
 SET PAV.Isdeleted=0                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=1 AND PAV.Attributeid=@SubArchetype AND                
 PAV.Attributevaluename IN (SELECT Name FROM AVMCOEESA.MS.SubArchetype WITH(NOLOCK) WHERE IsDeleted=0)               
 AND PAV.Attributevaluename  <>'N/A'   
                
  ----------------- Insert AttributeOwningBUMapping -------------                  
   DECLARE @ArcheSubArcheTypeUnitMap [MS].[ArcheSubArchetypeUnitMapping] ;                
  INSERT INTO @ArcheSubArcheTypeUnitMap SELECT Unit,Archetype,Subarchetype from AVMCOEESA.MS.ArchetypeSubarchtype_UnitMapping              
  where Unit <>'--None--' AND ISNULL(Unit,'') <>'' AND Archetype<>'--None--' AND ISNULL(Archetype,'') <>''                 
                
 EXEC [MS].[InsertSubArcheTypeAttributeValuesfromMainspring] 0,@ArcheSubArcheTypeUnitMap                   
 --------------- Insert Modernization Scope -------------                  
 INSERT INTO mas.ppattributevalues               
 (AttributeValueName,AttributeID,IsDeleted,CreatedBy,CreatedDate,ParentID,AttributeValueOrder)              
 SELECT                   
 MSM.Name,                  
 @ModernizationScope,                  
 0,                  
 @DataFrom,                  
 Getdate(),                  
 NULL,                  
 NULL                  
 FROM AVMCOEESA.MS.Modernizationscope MSM  WITH(NOLOCK)                
 WHERE MSM.Name not in (SELECT Attributevaluename FROM mas.ppattributevalues WITH(NOLOCK) WHERE Attributeid=@ModernizationScope)                  
                  
 UPDATE PAV                
 SET PAV.Isdeleted=1                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=0 AND PAV.Attributeid=@ModernizationScope AND                
 PAV.Attributevaluename NOT IN (SELECT Name FROM AVMCOEESA.MS.Modernizationscope WITH(NOLOCK) WHERE IsDeleted=0) AND CreatedBy = @DataFrom                
                
 UPDATE PAV                
 SET PAV.Isdeleted=0                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=1 AND PAV.Attributeid=@ModernizationScope AND                
 PAV.Attributevaluename IN (SELECT Name FROM AVMCOEESA.MS.Modernizationscope WITH(NOLOCK) WHERE IsDeleted=0) AND CreatedBy = @DataFrom                
                
 --------------- Insert DeliveryEngagementModel-------------                  
 INSERT INTO mas.ppattributevalues          (AttributeValueName,AttributeID,IsDeleted,CreatedBy,CreatedDate,ParentID,AttributeValueOrder)              
 SELECT                   
 DEM.Name,                  
 @DeliveryEngagementModel,                  
 0,                  
 @DataFrom,                  
 Getdate(),                  
 NULL,                  
 NULL                  
 FROM AVMCOEESA.MS.DeliveryEngagementModel DEM WITH(NOLOCK)                 
 WHERE DEM.Name not in (SELECT Attributevaluename FROM mas.ppattributevalues WITH(NOLOCK) WHERE Attributeid=@DeliveryEngagementModel)                  
                 
 UPDATE PAV                
 SET PAV.Isdeleted=1                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=0 AND PAV.Attributeid=@DeliveryEngagementModel AND                
 PAV.Attributevaluename NOT IN (SELECT Name FROM AVMCOEESA.MS.DeliveryEngagementModel WITH(NOLOCK) WHERE IsDeleted=0) AND CreatedBy = @DataFrom                
                
 UPDATE PAV                
 SET PAV.Isdeleted=0                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=1 AND PAV.Attributeid=@DeliveryEngagementModel AND                
 PAV.Attributevaluename IN (SELECT Name FROM AVMCOEESA.MS.DeliveryEngagementModel WITH(NOLOCK) WHERE IsDeleted=0) AND CreatedBy = @DataFrom                
                
 --------------- Insert Business Driver-------------                  
 INSERT INTO mas.ppattributevalues                
 (AttributeValueName,AttributeID,IsDeleted,CreatedBy,CreatedDate,ParentID,AttributeValueOrder)              
 SELECT                   
 BDM.Name,                  
 @BusinessDriver,                  
 0,                  
 @DataFrom,                  
 Getdate(),                  
 NULL,                  
 NULL                  
 FROM AVMCOEESA.MS.BusinessDriver BDM   WITH(NOLOCK)               
 WHERE BDM.Name not in (SELECT Attributevaluename FROM mas.ppattributevalues WITH(NOLOCK) WHERE Attributeid=@BusinessDriver)                  
                 
 UPDATE PAV                
 SET PAV.Isdeleted=1                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=0 AND PAV.Attributeid=@BusinessDriver AND                
 PAV.Attributevaluename NOT IN (SELECT Name FROM AVMCOEESA.MS.BusinessDriver WITH(NOLOCK) WHERE IsDeleted=0)  AND CreatedBy = @DataFrom                
                
 UPDATE PAV                
 SET PAV.Isdeleted=0                
 FROM MAS.PPAttributeValues PAV WITH(NOLOCK) WHERE PAV.Isdeleted=1 AND PAV.Attributeid=@BusinessDriver AND                
 PAV.Attributevaluename IN (SELECT Name FROM AVMCOEESA.MS.BusinessDriver WITH(NOLOCK) WHERE IsDeleted=0) AND CreatedBy = @DataFrom                
                
 --------------- Insert Pricing Model-------------                  
 INSERT INTO mas.ppattributevalues                
 (AttributeValueName,AttributeID,IsDeleted,CreatedBy,CreatedDate,ParentID,AttributeValueOrder)              
 SELECT                   
 PM.Name,                  
 @PricingModel,                  
 0,                  
 @DataFrom,                  
 Getdate(),                  
 NULL,                  
 NULL                  
 FROM AVMCOEESA.MS.PricingModel PM  WITH(NOLOCK)                
 WHERE PM.Name not in (SELECT Attributevaluename FROM mas.ppattributevalues WITH(NOLOCK) WHERE Attributeid=@PricingModel) AND Name <>'Pod based pricing'                 
                  
 UPDATE PAV                
 SET PAV.Isdeleted=1                
 FROM MAS.PPAttributeValues PAV  WITH(NOLOCK)   WHERE PAV.Isdeleted=0 AND PAV.Attributeid=@PricingModel AND                
 PAV.Attributevaluename NOT IN (SELECT Name FROM AVMCOEESA.MS.PricingModel  WITH(NOLOCK)  WHERE IsDeleted=0) AND CreatedBy = @DataFrom                
               
 UPDATE PAV                
 SET PAV.Isdeleted=0                
 FROM MAS.PPAttributeValues PAV  WITH(NOLOCK)  WHERE PAV.Isdeleted=1 AND PAV.Attributeid=@PricingModel AND                
 PAV.Attributevaluename IN (SELECT Name FROM AVMCOEESA.MS.PricingModel  WITH(NOLOCK)  WHERE IsDeleted=0) AND CreatedBy = @DataFrom      
       
---------------  Insert Additional ArcheType ---------------                  
                   
 INSERT INTO mas.ppattributevalues               
 (AttributeValueName,AttributeID,IsDeleted,CreatedBy,CreatedDate,ParentID,AttributeValueOrder)              
 SELECT                   
 PAM.Name,                  
 @AdditionalArchetype,                  
 0,                  
 @DataFrom,                  
 Getdate(),                  
 NULL,                  
 NULL                  
 FROM AVMCOEESA.MS.PrimaryArchetype PAM  WITH(NOLOCK)        
 WHERE PAM.Name not in (SELECT Attributevaluename FROM mas.ppattributevalues WITH(NOLOCK) WHERE Attributeid=@AdditionalArchetype)                
                 
 UPDATE PAV                
 SET PAV.Isdeleted=1                
 FROM MAS.PPAttributeValues PAV  WITH(NOLOCK)  WHERE PAV.Isdeleted=0 AND PAV.Attributeid=@AdditionalArchetype AND                
 PAV.Attributevaluename NOT IN (SELECT Name FROM AVMCOEESA.MS.PrimaryArchetype  WITH(NOLOCK)  WHERE IsDeleted=0) AND CreatedBy = @DataFrom                
                  
 UPDATE PAV                
 SET PAV.Isdeleted=0                
 FROM MAS.PPAttributeValues PAV  WITH(NOLOCK)   WHERE PAV.Isdeleted=1 AND PAV.Attributeid=@AdditionalArchetype AND                
 PAV.Attributevaluename IN (SELECT Name FROM AVMCOEESA.MS.PrimaryArchetype  WITH(NOLOCK)  WHERE IsDeleted=0) AND CreatedBy = @DataFrom                    
               
                 
 COMMIT TRAN                  
 END TRY                   
                  
    BEGIN CATCH                   
                    
        DECLARE @ErrorMessage VARCHAR(MAX);                   
        SELECT @ErrorMessage = ERROR_MESSAGE()                   
        --INSERT Error                     
  ROLLBACK TRAN                  
        EXEC AVL_INSERTERROR  '[MS].[InsertAttributeValuesfromMainspring]', @ErrorMessage,  0, 0           
   --Send Error mail notification          
  DECLARE @MailSubject VARCHAR(MAX);              
  DECLARE @MailBody  VARCHAR(MAX);            
              
  SELECT @MailSubject = CONCAT(@@servername, ': Mainspring Applens Integration Job Failure Notification')            
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in [MS].[InsertAttributeValuesfromMainspring] during the masters integration in Applens from Gateway!<br>            
       <br>Error: ', @ErrorMessage,            
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')            
  DECLARE @recipientAddress NVARCHAR(4000)='';              
   SET @recipientAddress = (SELECT ConfigValue FROM AVL.AppLensConfig  WITH(NOLOCK)  WHERE ConfigName='Mail' AND IsActive=1);         
  EXEC [AVL].[SendDBEmail] @To=@recipientAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody            
    END CATCH                   
  SET NOCOUNT OFF;                
END 