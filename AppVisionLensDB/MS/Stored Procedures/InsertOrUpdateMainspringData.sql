/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [MS].[InsertOrUpdateMainspringData]        
 @AttributeId int,         
 @ProjectAttributes MS.ProjectAttributes READONLY        
AS        
BEGIN        
BEGIN TRY        
 SET NOCOUNT ON;        
 DECLARE @i BIGINT=1,        
   @ProjectId BIGINT,        
   @AttributeValue VARCHAR(4000),        
   @Max BIGINT = (SELECT COUNT(*) FROM @ProjectAttributes),        
   @DataFrom VARCHAR(20) = 'MainSpringFeed',      
   @IsUserIntervention BIT,    
   @ArchetypeID INT;    
    
 DECLARE @AttributeDetail TABLE        
 (        
  AttributeValueID INT,        
  AttributeValueName VARCHAR(200)        
 )         
    
 WHILE(@i <= @Max)        
 BEGIN        
  SET @ProjectId = (SELECT ProjectID FROM @ProjectAttributes WHERE ID = @i)        
  SET @AttributeValue = (SELECT AttributeValue FROM @ProjectAttributes WHERE ID = @i)     
  SET @ArchetypeID = (SELECT AttributeValueId from MAS.PPattributeValues where Attributeid=4    
       and AttributeValuename = (SELECT Archetype FROM @ProjectAttributes WHERE ID = @i))    
          
  INSERT INTO @AttributeDetail        
  SELECT null, TRIM(Item) FROM [DBO].[StringSplit](@AttributeValue,',')        
    
  IF(@AttributeId=51)      
  BEGIN      
  UPDATE SA        
  SET SA.AttributeValueID = PAV.AttributeValueID        
  FROM @AttributeDetail SA        
   INNER JOIN MAS.PPAttributeValues PAV WITH (NOLOCK)        
   ON SA.AttributeValueName = PAV.AttributeValueName        
   AND PAV.AttributeID = @AttributeId    
   AND PAV.IsDeleted = 0     
  IF EXISTS(SELECT TOP 1 ID FROM PP.ProjectAttributeValues PAV  WITH (NOLOCK) WHERE PAV.ProjectID = @ProjectId        
  AND PAV.AttributeID = 51 AND (PAV.Createdby not like '%MainSpringFeed%' OR PAV.ModifiedBy not like '%MainSpringFeed%'))      
  BEGIN      
  SET @IsUserIntervention = 1      
  END      
  ELSE      
  BEGIN      
  SET @IsUserIntervention = 0      
  END      
  END    
      
  ELSE      
  BEGIN     
  UPDATE SA        
  SET SA.AttributeValueID = PAV.AttributeValueID        
  FROM @AttributeDetail SA
   INNER JOIN MAS.PPAttributeValues PAV WITH (NOLOCK)        
   ON SA.AttributeValueName = PAV.AttributeValueName        
   AND PAV.AttributeID = @AttributeId    
   AND PAV.ParentID = @ArchetypeID    
   AND PAV.IsDeleted = 0     
    
  SET @IsUserIntervention = 0      
  END      
      
  IF(@IsUserIntervention = 0)      
  BEGIN      
  --update MS.ProjectScopeDetails set SUBWorkCategory=(Select top 1 AttributeValueID FROM @AttributeDetail) where Registrationid=61060    
  UPDATE PP.ProjectAttributeValues        
  SET IsDeleted = 1,        
   ModifiedBy = @DataFrom,        
   ModifiedDate = GETDATE()        
  WHERE ProjectID = @ProjectId        
  AND AttributeID = @AttributeId         
  AND IsDeleted = 0       
  AND NOT EXISTS        
  (        
   SELECT TOP 1 SA.AttributeValueID FROM @AttributeDetail SA        
   WHERE SA.AttributeValueID = ProjectAttributeValues.AttributeValueID        
  )          
      
  UPDATE PP.ProjectAttributeValues        
  SET IsDeleted = 0,        
   ModifiedBy = @DataFrom,        
   ModifiedDate = GETDATE()        
  WHERE ProjectID = @ProjectId        
  AND AttributeID = @AttributeId         
  AND IsDeleted = 1        
  AND EXISTS        
  (        
   SELECT TOP 1 SA.AttributeValueID FROM @AttributeDetail SA        
   WHERE SA.AttributeValueID = ProjectAttributeValues.AttributeValueID        
  )        
        
  INSERT INTO PP.ProjectAttributeValues        
  SELECT @ProjectId,        
    AttributeValueID,        
    @AttributeId,         
    0,        
    @DataFrom,        
    GETDATE(),        
    NULL,        
    NULL        
    FROM         
  @AttributeDetail SA        
  WHERE ISNULL(SA.AttributeValueID,'') <> '' AND    
  NOT EXISTS(        
  SELECT TOP 1 ID FROM PP.ProjectAttributeValues PAV  WITH (NOLOCK) WHERE PAV.ProjectID = @ProjectId        
  AND PAV.AttributeID = @AttributeId AND PAV.AttributeValueID = SA.AttributeValueID)        
  END      
  DELETE FROM  @AttributeDetail    
  SET @i = @i + 1        
 END        
END TRY        
BEGIN CATCH       
 DECLARE @ErrorMessage VARCHAR(1000)        
 SET @ErrorMessage = ERROR_MESSAGE()        
 EXEC DBO.AVL_InsertError '[MS].[InsertOrUpdateMainspringData]', @ErrorMessage, 0,0          
END CATCH;        
SET NOCOUNT OFF;        
END