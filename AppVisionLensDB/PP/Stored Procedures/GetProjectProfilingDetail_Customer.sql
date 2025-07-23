/***************************************************************************              
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET              
*Copyright [2018] – [2021] Cognizant. All rights reserved.              
*NOTICE: This unpublished material is proprietary to Cognizant and              
*its suppliers, if any. The methods, techniques and technical              
  concepts herein are considered Cognizant confidential and/or trade secret information.               
                
*This material may be covered by U.S. and/or foreign patents or patent applications.               
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.              
***************************************************************************/              
              
CREATE PROCEDURE [PP].[GetProjectProfilingDetail_Customer]                                     
                                
@ProjectID BIGINT,                                                      
@Mode VARCHAR(20)                                      
AS                                
BEGIN                                                         
                                                       
 BEGIN TRY                                                       
  SET NOCOUNT ON;                                                      
  DECLARE @OwningBUId BIGINT=NULL;                                                       
  DECLARE @ADMId BIGINT=NULL;                                                         
  DECLARE @IsOplData INT = 1 ;                                                        
  DECLARE @IsProjectData INT =2 ;                                                        
  DECLARE @COUNT INT;                                                        
  DECLARE @IScognizant BIT;                                                 
  DECLARE @IsMainspringBUCount INT=0;                                                
  DECLARE @IsNonBU INT=0;                                                
  DECLARE @MainspringArchType INT;                                                
  DECLARE @MSUnit nvarchar(250)=NULL;                         
  DECLARE @ProjectType nvarchar(50)=NULL;                          
  DECLARE @AdditionalArchetype nvarchar(max)=NULL;                         
  SELECT TOP 1 @IScognizant=IsCoginzant FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectId = @ProjectID AND IsDeleted = 0                                                   
                                                  
  IF @Mode = 'ScopeOfWork'                                                      
  BEGIN                                                      
     CREATE TABLE #MasterDropdownValues                                
  (                                
    AttributeValueID INT NULL                                                  
      ,AttributeValueName  NVARCHAR(200) NULL                                                     
      ,AttributeID SMALLINT NULL                                                       
      ,AttributeName   NVARCHAR(200) NULL                                                          
      ,ParentID   INT   NULL                                                  
      ,AttributeValueOrder SMALLINT NULL                                 
  );                                
   --GET THE ATTRIBUTES NAMES                                                       
    SELECT  AttributeID                                                      
     ,AttributeName                                                      
     ,SourceID                                                      
     ,ScopeID                              
     ,IsPrepopulate                                                      
     ,IsCognizant                               
     ,IsMandatory                                                      
    FROM MAS.PPAttributes(NOLOCK) PPA                                          
     WHERE PPA.IsDeleted = 0 AND AttributeID IN  (1,3,4,34,35,51)                                                      
     order by AttributeID,AttributeName ASC                                                      
                                                         
   --GET ATTRIBUTE MASTER VALUES                                                    
    SELECT DISTINCT  AttributeValueID                                                      
     ,AttributeValueName                                                      
     ,PPA.AttributeID                                    ,PPA.AttributeName                                                      
     ,ParentID                                                      
     ,AttributeValueOrder                                          
     INTO                                                      
     #TempnoOwningUnit                                                      
      FROM mas.PPAttributeValues(NOLOCK) PPAV                                       
      INNER JOIN  MAS.PPAttributes(NOLOCK) PPA on PPAV.AttributeId=PPA.AttributeId                                                      
      WHERE PPAV.IsDeleted = 0 and PPA.IsDeleted=0                                                      
      AND PPA.AttributeID IN (1,3,35)                                                      
      AND AttributeValueID NOT IN (258,259)                                                      
      ORDER BY AttributeValueOrder,PPA.AttributeID,AttributeValueName ASC                                                      
                                                  
                                 
       Select Top 1 @ADMId=PAV.AttributeValueId from MAS.PPAttributeValues PAV (NOLOCK)                                                
    INNER JOIN MAS.PPAttributes PA (NOLOCK) on PA.AttributeId = PAV.AttributeId and PA.AttributeName = 'OPLProjectOwningUnit'                             
       WHERE PAV.AttributeValueName='ADM' AND PAV.isdeleted=0 AND PA.IsDeleted=0                                     
                                    
    INSERT  INTO #MasterDropdownValues                                                 
   SELECT * FROM(                                                    
       SELECT   DISTINCT                                                  
         PPAV.AttributeValueID                                                      
        ,AttributeValueName                                                      
         ,PPA.AttributeID                                                      
        ,PPA.AttributeName                                                      
        ,ParentID                                                      
     ,AttributeValueOrder                                                      
     FROM                                   
     mas.PPAttributeValues(NOLOCK) PPAV                                                      
     INNER JOIN [PP].[AttributeOwningBUMapping](NOLOCK)  OW                                                      
     on PPAV.Attributevalueid=OW.Attributevalueid                                                      
     INNER JOIN  MAS.PPAttributes(NOLOCK) PPA on                                   
     PPAV.AttributeId=PPA.AttributeId                                                      
     WHERE  PPAV.IsDeleted = 0  AND OW.IsDeleted=0 AND PPA.IsDeleted=0         
     AND OwningBUId=@ADMId                                                         
     AND PPA.AttributeID IN (4,34,51)                                                      
   UNION ALL                                                       
       SELECT DISTINCT                                                       
       AttributeValueID                                                      
       ,AttributeValueName                                                      
       ,AttributeID                                                      
       ,AttributeName                                                      
      ,ParentID                                             
     ,AttributeValueOrder                                                      
    FROM                                                      
     #TempnoOwningUnit ) TEMP                                                    
     ORDER BY AttributeValueOrder,AttributeID,AttributeValueName ASC                                                      
      SELECT * FROM #MasterDropdownValues(NOLOCK) ORDER BY AttributeValueOrder,AttributeID,AttributeValueName ASC;                                        
                                                   
                                                      
   CREATE TABLE #OPLDataInsert                                                      
   (                                                      
   ProjectID BIGINT,                                                      
   AttributeValue INT,                                                      
   AttributeID INT,                                                      
   AttributeName varchar(50),                                                      
   SourceOfData INT,                                                      
   CreatedBy NVARCHAR(50)                                                      
   )                                                      
                                                      
   SET @COUNT =(SELECT COUNT(AttributeValueID) FROM PP.ProjectAttributeValues (NOLOCK)                                                      
       WHERE ProjectID=@ProjectID AND AttributeID=1                                                       
       AND ((CreatedBy='Migrated' AND ModifiedDate IS NOT NULL) OR (CreatedBy<>'Migrated')))                                                      
   IF(@COUNT = 0)                                                      
   BEGIN                                                      
    INSERT INTO #OPLDataInsert                                                      
    SELECT DISTINCT ProjectID,ProjectScope,PPA.AttributeID,PPA.AttributeName,@IsOplData AS SourceOfData,OED.CreatedBy FROM pp.OplEsaData(NOLOCK) OED                                                      
    JOIN MAS.PPAttributeValues(NOLOCK) PPAV ON PPAV.AttributeValueID = OED.ProjectScope                                                    
    INNER JOIN  MAS.PPAttributes(NOLOCK) PPA on PPAV.AttributeId=PPA.AttributeId                                                      
    WHERE projectID = @ProjectID and PPAV.AttributeID = 1 and PPAV.IsDeleted = 0 and PPA.IsDeleted=0                                                      
   END                                                      
                                                      
   --GET DATA                                                      
   --MULTISELECT DROPDOWN VALUES                                                      
   SELECT scope.ProjectID,scope.AttributeValue AS AttributeValue,AttributeID,scope.AttributeName,SourceOfData,CreatedBy FROM (                                                      
    SELECT DISTINCT ProjectID,AttributeValue,AttributeID,AttributeName,@IsOplData AS SourceOfData,CreatedBy FROM #OPLDataInsert (NOLOCK)                                                     
    UNION                                                 
    SELECT pav.ProjectID,pav.AttributeValueID,PPAV.AttributeID,PPA.AttributeName,@IsProjectData AS SourceOfData,PAV.CreatedBy                                                       
    FROM mas.PPAttributeValues PPAV (NOLOCK)                                                      
    JOIN pp.ProjectAttributeValues(NOLOCK) PAV ON PAV.AttributeValueID = ppav.AttributeValueID                                                      
    INNER JOIN  MAS.PPAttributes(NOLOCK) PPA on PPAV.AttributeId=PPA.AttributeId                                                      
    WHERE ProjectID = @ProjectID and PPAV.AttributeID = 1 and PAV.IsDeleted = 0 and PPAV.IsDeleted = 0 and PPA.IsDeleted=0              
    UNION                                                      
    SELECT pav.ProjectID,pav.AttributeValueID,PPAV.AttributeID,PPA.AttributeName,@IsProjectData AS SourceOfData,PAV.CreatedBy FROM mas.PPAttributeValues(NOLOCK)  PPAV     
 JOIN pp.ProjectAttributeValues(NOLOCK)  PAV ON PAV.AttributeValueID = ppav.AttributeValueID                                                      
    INNER JOIN  MAS.PPAttributes(NOLOCK) PPA on PPAV.AttributeId=PPA.AttributeId                                                      
    WHERE ProjectID = @ProjectID and PPAV.AttributeID = 3 and PAV.IsDeleted = 0  and PPAV.IsDeleted = 0 and PPA.IsDeleted=0                                                  
    UNION                                                
    SELECT pav.ProjectID,pav.AttributeValueID,PPAV.AttributeID,PPA.AttributeName,@IsProjectData AS SourceOfData,PAV.CreatedBy FROM mas.PPAttributeValues(NOLOCK)  PPAV                                                       
    JOIN pp.ProjectAttributeValues(NOLOCK)  PAV ON PAV.AttributeValueID = ppav.AttributeValueID                                                    
    INNER JOIN  MAS.PPAttributes(NOLOCK) PPA on PPAV.AttributeId=PPA.AttributeId                                                      
    WHERE ProjectID = @ProjectID and PPAV.AttributeID = 34 and PAV.IsDeleted = 0                                  
 and PPAV.IsDeleted = 0  and PPA.IsDeleted=0 -- and(@IScognizant=0 or ISNULL(@MSUnit,'')!='')                                  
 and pav.attributevalueID in (Select AttributeValueID from #MasterDropdownValues)                                
    UNION                                                      
    SELECT pav.ProjectID,pav.AttributeValueID,PPAV.AttributeID,PPA.AttributeName,@IsProjectData AS SourceOfData,PAV.CreatedBy FROM mas.PPAttributeValues(NOLOCK)  PPAV                                                       
    JOIN pp.ProjectAttributeValues(NOLOCK)  PAV ON PAV.AttributeValueID = ppav.AttributeValueID                                                      
    INNER JOIN  MAS.PPAttributes(NOLOCK) PPA on PPAV.AttributeId=PPA.AttributeId                                                      
    WHERE ProjectID = @ProjectID and PPAV.AttributeID = 51 and PAV.IsDeleted = 0                                  
 and PPAV.IsDeleted = 0  and PPA.IsDeleted=0 -- and(@IScognizant=0 or ISNULL(@MSUnit,'')!='')                                  
 and pav.attributevalueID in (Select AttributeValueID from #MasterDropdownValues)                                
   ) scope                                                   
                                                         
    --OTHERS FIELD VALUES                                                      
    SELECT ProjectID,OtherFieldValue,AttributeValueID FROM PP.OtherAttributeValues (NOLOCK)                                                      
    WHERE ProjectID = @ProjectID AND IsDeleted = 0                                                      
                                                          
    --FIELD VALUES                                                      
 IF((SELECT COUNT(ProjectID) FROM PP.ScopeOfWork (NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0)  > 0)                                                
 BEGIN                                 SELECT ProjectID,IsApplensAsALM,IsExternalALM,ALMToolID,                                 
                                 
 --CASE WHEN @IsMainspringBUCount > 0 then @MainspringArchType                                 
 --else (CASE WHEN (@IScognizant=0 or ISNULL(@MSUnit,'')!='')                           
 --THEN (Select AttributeValueID From #MasterDropdownValues Where AttributeId=4 and AttributeValueId = ProjectTypeId) ELSE NULL END)                                 
 --end as ProjectTypeId,                                 
 CASE WHEN @IsMainspringBUCount > 0 then @MainspringArchType                                 
 else (Select AttributeValueID From #MasterDropdownValues(NOLOCK) Where AttributeId=4 and AttributeValueId = ProjectTypeId)                          
 end as ProjectTypeId,                                
 IsSubmit, ProjectTypeSource, ProjectTypeTarget                         
 ,Case When IsTransitionInScope = 1 Then 'Transition'                          
       When IsTransitionInScope = 0 Then 'Steady State'                   
    Else 'Not Applicable' End as ProjectType,                        
CASE WHEN @IsMainspringBUCount > 0 then ISNULL(@AdditionalArchetype,'Not Available') Else ISNULL(@AdditionalArchetype,'') End as AdditionalArchetype                        
 FROM PP.ScopeOfWork(NOLOCK)                                                     
 WHERE ProjectID = @ProjectID AND IsDeleted = 0   --and(@IScognizant=0 or ISNULL(@MSUnit,'')!='')                                                 
 END                                                
                                                
 ELSE                                                
 BEGIN                                                
 SELECT @ProjectID AS  ProjectID,NULL ASIsApplensAsALM,NULL AS IsExternalALM,NULL AS ALMToolID,                                                
 CASE WHEN @IsMainspringBUCount > 0 then @MainspringArchType else NULL end as ProjectTypeId,                                               
 NULL AS IsSubmit,NULL AS ProjectTypeSource,NULL AS ProjectTypeTarget,                          
 CASE WHEN @IsMainspringBUCount > 0 then @ProjectType else 'Not Applicable' end as ProjectType  ,                        
 CASE WHEN @IsMainspringBUCount > 0 then ISNULL(@AdditionalArchetype,'Not Available') Else ISNULL(@AdditionalArchetype,'') End as AdditionalArchetype                                                
 END                                                
                                  
    DROP TABLE #OPLDataInsert                                                      
    DROP TABLE #TempnoOwningUnit                                     
 DROP TABLE #MasterDropdownValues                                
  END                                                     
  ELSE IF @Mode = 'ProjectDetails'                                                      
  BEGIN                                                      
  --GET THE ATTRIBUTES NAMES                                                       
   SELECT  AttributeID                                                      
       ,AttributeName                                                      
       ,SourceID                                                      
       ,ScopeID                                                      
       ,IsPrepopulate                                    
       ,IsCognizant                                                       
       ,IsMandatory                                                      
     FROM MAS.PPAttributes(NOLOCK) PPA                                                       
     WHERE PPA.IsDeleted = 0 AND AttributeID IN  (8,9,19,21,52)                                                      
     order by AttributeID,AttributeName ASC                                                      
                                                           
  --GET ATTRIBUTE MASTER VALUES                                            
   IF(@IScognizant =0)                                        
   BEGIN                                        
   SELECT  AttributeValueID                                                      
                   ,AttributeValueName                                                      
             ,AttributeID                                                      
                   ,ParentID                                                      
       ,AttributeValueOrder                                                      
                    FROM mas.PPAttributeValues(NOLOCK) PPAV                                                      
     WHERE PPAV.IsDeleted = 0                                                       
     AND AttributeID IN (8,9,19,21,52) AND PPAV.CreatedBy <>'MainspringFeed'                         
     ORDER BY AttributeValueOrder,AttributeID,AttributeValueName ASC                                         
   END                         
   ELSE                                        
   BEGIN                                        
   SELECT  AttributeValueID                                                      
                   ,AttributeValueName                                                      
                   ,AttributeID                                                      
                   ,ParentID                                                      
       ,AttributeValueOrder                                                      
         FROM mas.PPAttributeValues(NOLOCK) PPAV                                                      
     WHERE PPAV.IsDeleted = 0                             
     AND AttributeID IN (8,9,19,21,52)                                                   
   ORDER BY AttributeValueOrder,AttributeID,AttributeValueName ASC                                         
   END                                        
                                                         
  --GET DATA                                                      
  --MULTISELECT DROPDOWN VALUES                                                      
    CREATE TABLE #DeliveryManagement(                                                      
    AttributeValue int,                                                      
    AttributeID int,                                  
 CreatedBy nvarchar(50)                                  
    )                                      
          IF((SELECT COUNT(*) FROM PP.ProjectAttributeValues where ProjectID = @ProjectID and AttributeID = 9)=0)                                       
    BEGIN                              
 INSERT INTO #DeliveryManagement                                                      
     SELECT PAV.AttributeValueID AS AttributeValue,AV.AttributeID,PAV.CreatedBy FROM MAS.PPAttributeValues AV (NOLOCK)                                                     
     JOIN PP.ProjectAttributeValues PAV (NOLOCK) ON AV.AttributeValueID=PAV.AttributeValueID                                                      
     JOIN  PP.OplEsaData OP (NOLOCK) ON  OP.DeliveryEngagementModel=AV.AttributeValueName                                                       
     WHERE OP.ProjectID=@ProjectID AND AV.AttributeID=9 AND PAV.IsDeleted=0                                                      
    END                                                      
    ELSE                                    
    BEGIN                      
     INSERT INTO #DeliveryManagement                                                      
     SELECT pav.AttributeValueID AS AttributeValue,PPAV.AttributeID,PAV.CreatedBy FROM mas.PPAttributeValues(NOLOCK)  PPAV                                                       
     JOIN pp.ProjectAttributeValues(NOLOCK)  PAV ON PAV.AttributeValueID = ppav.AttributeValueID                                                      
     WHERE ProjectID = @ProjectID AND PPAV.AttributeID = 9 AND PAV.IsDeleted = 0  AND PPAV.IsDeleted = 0                                                        
    END                                                      
     select pav.AttributeValueID AS AttributeValue,PPAV.AttributeID,PAV.CreatedBy from mas.PPAttributeValues(NOLOCK)  PPAV                                                       
     join pp.ProjectAttributeValues(NOLOCK)  PAV on PAV.AttributeValueID = ppav.AttributeValueID                                                      
     where ProjectID = @ProjectID and PPAV.AttributeID = 19 and PAV.IsDeleted = 0  and PPAV.IsDeleted = 0                                                      
    UNION                                                      
     select pav.AttributeValueID AS AttributeValue,PPAV.AttributeID,PAV.CreatedBy from mas.PPAttributeValues(NOLOCK)  PPAV                                  
     join pp.ProjectAttributeValues(NOLOCK)  PAV on PAV.AttributeValueID = ppav.AttributeValueID                                              
     where ProjectID = @ProjectID and PPAV.AttributeID = 21 and PAV.IsDeleted = 0  and PPAV.IsDeleted = 0                        
    UNION                                                      
     select pav.AttributeValueID AS AttributeValue,PPAV.AttributeID,PAV.CreatedBy from mas.PPAttributeValues(NOLOCK)  PPAV                                                  
     join pp.ProjectAttributeValues(NOLOCK)  PAV on PAV.AttributeValueID = ppav.AttributeValueID                                                      
     where ProjectID = @ProjectID and PPAV.AttributeID = 52 and PAV.IsDeleted = 0  and PPAV.IsDeleted = 0                                                      
    UNION                                    
    SELECT AttributeValue,AttributeID,CreatedBy FROM #DeliveryManagement (NOLOCK)                 
                         
  --OTHER FIELD VALUES                                                      
    SELECT ProjectID,OtherFieldValue,AttributeValueID FROM PP.OtherAttributeValues (NOLOCK)                                                       
    WHERE ProjectID = @ProjectID AND IsDeleted = 0 and AttributeValueID in (37,46)                                                      
                                                        
  --OPL FIELD VALUES                                                      
   DECLARE @ShortDescription varchar(250),@MainspringShortDescription varchar(250),@ProjectCategory int,@Vertical varchar(250),                                                
   @MSProjectEndDate datetime,@MSOwningBu nvarchar(250),@MSTechnology nvarchar(4000),@MSVertical varchar(250);                                                      
                                                
                                                       
     SET @ProjectCategory=(                                                      
     SELECT ProjectCategoryID FROM PP.ProjectDetails(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0                                                      
     )                                                      
          
     SET @ShortDescription=(SELECT ProjectShortDescription FROM PP.ProjectDetails(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0)                                           
    
                                                         
   SELECT @ProjectID AS ProjectID,NULL AS Billability,NULL AS ContractYear,NULL AS ContractValue,                                                      
   @MSProjectEndDate AS ProjectEndDate,NULL AS TotalFTE,NULL AS  OnsiteFTE                                                      
   ,NULL AS OffshoreFTE,@MSVertical AS Vertical,@MSOwningBu AS  LineofService,@ShortDescription AS ShortDescription                                                      
   ,@ProjectCategory AS ProjectCategory,@MSTechnology AS Technology,@MSUnit AS Unit                                                    
                                                    
                                                                                                      
  DROP TABLE #DeliveryManagement                                                      
  END                                
                                        
  --GET EXCLUDEWORDS                                                       
   SELECT ExcludedWordName AS Name FROM mas.ExcludedWords (NOLOCK) WHERE IsDeleted = 0                                                       
                                                           
  --Scope Enabled/Disabled based on AppInv/InfraInv                                                      
                                                        
  DECLARE @IsDevTestExists INT = 0, @IsSupportExists INT = 0, @IsCISExists INT = 0                                                      
                 
  SET @IsDevTestExists = (SELECT TOP 1 1 from AVL.APP_MAP_ApplicationProjectMapping APM(NOLOCK)                                     
  INNER JOIN ADM.AppApplicationScope AAS(NOLOCK) ON AAS.ApplicationId = APM.ApplicationID AND APM.IsDeleted = 0 AND AAS.IsDeleted = 0                                                      
  WHERE ProjectID = @ProjectID and ApplicationScopeId = 1)                                                      
                                                      
  SET @IsSupportExists = (SELECT TOP 1 1 from AVL.APP_MAP_ApplicationProjectMapping APM(NOLOCK)                                                      
  INNER JOIN ADM.AppApplicationScope AAS(NOLOCK) ON AAS.ApplicationId = APM.ApplicationID AND APM.IsDeleted = 0 AND AAS.IsDeleted = 0                                                      
  WHERE ProjectID = @ProjectID and ApplicationScopeId = 2)                                                      
                                                      
  SET @IsCISExists = (select TOP 1 1 from AVL.InfraTowerProjectMapping(NOLOCK) where ProjectID = @ProjectID and IsDeleted = 0 AND IsEnabled = 1)                                          
                                                      
  SELECT ISNULL(@IsDevTestExists, 0) AS IsDevTestExists, ISNULL(@IsSupportExists,0) AS IsSupportExists, ISNULL(@IsCISExists,0) AS IsCISExists                                                
  ,CASE WHEN (@IsMainspringBUCount > 0) then 0 else 1 end AS IsNonBU;                                                  
 SET NOCOUNT OFF;                                                    
 END TRY                                                       
                                                      
    BEGIN CATCH                                                       
        DECLARE @ErrorMessage VARCHAR(MAX);              
        SELECT @ErrorMessage = ERROR_MESSAGE()                                                       
        --INSERT Error                                                           
        EXEC AVL_INSERTERROR  '[PP].[GetProjectProfilingDetail]', @ErrorMessage,  0, 0                                                       
    END CATCH                                     
  END
