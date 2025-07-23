/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [MS].[InsertSubArcheTypeAttributeValuesfromMainspring]    
 @IsSubarcheInsert BIT,     
 @MainspringAttributes [MS].[ArcheSubArchetypeUnitMapping] READONLY    
AS    
BEGIN    
BEGIN TRY    
SET NOCOUNT ON;    
 DECLARE @i BIGINT=1,    
   @Unit VARCHAR(4000),  
   @ArchetypeID INT,
   @SubarcheTypeValue VARCHAR(4000),    
   @Max BIGINT = (SELECT COUNT(*) FROM @MainspringAttributes),    
   @DataFrom VARCHAR(20) = 'MainSpringFeed',
   @UnitAttributeID INT=(SELECT attributeid FROM mas.PPAttributes WHERE attributename='OPLProjectowningUnit' and isdeleted=0),
   @SubArchetypeAttributeID INT=(SELECT attributeid FROM mas.PPAttributes WHERE attributename='ProjectSubType' and isdeleted=0) ;
 DECLARE @AttributeDetail TABLE    
 (    
  SubArcheValueName VARCHAR(4000)    
 )     

 WHILE(@i <= @Max)    
 BEGIN    
  SET @Unit = (SELECT Unit FROM @MainspringAttributes WHERE ID = @i)    
  SET @SubarcheTypeValue = (SELECT CASE WHEN SubarcheType = '--None--' Then 'N/A' ELSE SubarcheType END FROM @MainspringAttributes WHERE ID = @i) 
  SET @ArchetypeID = (SELECT AttributeValueId from MAS.PPattributeValues(NoLock) where Attributeid=4
					  and AttributeValuename = (SELECT Archetype FROM @MainspringAttributes WHERE ID = @i))
      
  INSERT INTO @AttributeDetail    
  SELECT Item FROM [DBO].[StringSplit](@SubarcheTypeValue,',')    


  IF(@IsSubarcheInsert = 1)  
  BEGIN  
  Insert into MAS.PPAttributeValues
  SELECT DISTINCT
  SubArcheValueName ,
  @SubArchetypeAttributeID,
  0,
  @DataFrom,
  GETDATE(),
  @ArchetypeID,
  NULL
  FROM @AttributeDetail
  WHERE SubArcheValueName NOT IN (SELECT AttributeValuename FROM MAS.PPAttributeValues(NoLock) WHERE AttributeID=@SubArchetypeAttributeID And ParentID=@ArchetypeID) 
  AND ISNULL(SubArcheValueName,'') <>''
  END  

  ELSE

  BEGIN
  Insert into [PP].[AttributeOwningBUMapping] 
  SELECT DISTINCT
  @ArchetypeID ,
  PAV.AttributevalueID,
  0,
  @DataFrom,
  GETDATE(),
  NULL,
  NULL
  FROM MAS.PPAttributeValues PAV 
  WHERE PAV.AttributeValueName = @Unit AND PAV.AttributeID=@UnitAttributeID AND @ArchetypeID IS NOT NULL AND @Unit IS NOT NULL
  AND @ArchetypeID NOT IN (SELECT Attributevalueid from [PP].[AttributeOwningBUMapping](NoLock) 
  where OwningBUID = (Select attributevalueid from MAS.PPAttributeValues(NoLock) where AttributeID=@UnitAttributeID and AttributeValueName = @Unit))


  Insert into [PP].[AttributeOwningBUMapping] 
  SELECT DISTINCT
  PAV.AttributevalueID ,
  (Select AttributevalueID from MAS.PPAttributeValues(NoLock)  WHERE AttributeValueName = @Unit AND AttributeID=@UnitAttributeID),
  0,
  @DataFrom,
  GETDATE(),
  NULL,
  NULL
  FROM @AttributeDetail AD
  INNER JOIN MAS.PPAttributeValues(NoLock) PAV ON PAV.AttributeValueName = AD.SubArcheValueName AND PAV.AttributeID = @SubArchetypeAttributeID
  AND ParentID=@ArchetypeID AND @ArchetypeID  IS NOT NULL  AND @Unit IS NOT NULL
  AND PAV.AttributevalueID NOT IN (SELECT Attributevalueid from [PP].[AttributeOwningBUMapping](NoLock)
  where OwningBUID = (Select attributevalueid from MAS.PPAttributeValues(NoLock) where AttributeID=@UnitAttributeID and AttributeValueName = @Unit))


  END
  DELETE FROM @AttributeDetail
  SET @i = @i + 1    
 END    
END TRY    
BEGIN CATCH    
 DECLARE @ErrorMessage VARCHAR(1000)    
 SET @ErrorMessage = ERROR_MESSAGE()    
 EXEC DBO.AVL_InsertError '[MS].[InsertSubArcheTypeAttributeValuesfromMainspring]', @ErrorMessage, 0,0      
END CATCH;    
SET NOCOUNT OFF    
END