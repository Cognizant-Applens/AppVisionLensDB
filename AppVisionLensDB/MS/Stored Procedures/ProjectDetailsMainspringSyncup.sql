/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] ? [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
CREATE PROCEDURE [MS].[ProjectDetailsMainspringSyncup]                              
AS                              
BEGIN                              
SET NOCOUNT ON                              
BEGIN TRY         
  BEGIN TRAN          
 DECLARE @ExecutionAttributeId INT,                              
   @ProjectArchType INT,                              
   @ProjectSubArchTypeId INT,                              
   @ModernizationScopeId INT,                              
   @AgileMethod VARCHAR(20) = 'Agile',                              
   @TraditionalMethod VARCHAR(20) = 'Traditional',                              
   @OthersMethod VARCHAR(20) = 'Others',    
   @AdditionalArchetype INT,    
   @DataFrom VARCHAR(20) = 'MainSpringFeed'                            
                              
 SELECT TOP 1 @ExecutionAttributeId = AttributeID FROM MAS.PPAttributes WITH (NOLOCK)                              
 WHERE AttributeName = 'ExecutionMethod'                              
 SELECT TOP 1 @ProjectArchType = AttributeID FROM MAS.PPAttributes WITH (NOLOCK)                              
 WHERE AttributeName = 'TypeofProject'                              
 SELECT TOP 1 @ProjectSubArchTypeId = AttributeID FROM MAS.PPAttributes WITH (NOLOCK)                              
 WHERE AttributeName = 'ProjectSubType'                              
 SELECT TOP 1 @ModernizationScopeId = AttributeID FROM MAS.PPAttributes WITH (NOLOCK)                              
 WHERE AttributeName = 'Other Type'                              
 SELECT TOP 1 @AdditionalArchetype = AttributeID FROM MAS.PPAttributes WITH (NOLOCK)                              
 WHERE AttributeName = 'AdditionalArchetype'                           
                              
 ;WITH CTEExecutionMethod AS                              
 (                              
  SELECT DISTINCT PM.ProjectID,PM.EsaProjectID,                              
  PP.GetExecutionMethodIdByName(                              
   CASE WHEN PSD.ExecutionMethodology like '%Agile%'                               
      AND ISNULL(PSD.TypeofAgileMethodology,'') <> ''                              
    THEN PSD.TypeofAgileMethodology                              
   ELSE (CASE WHEN PSD.ExecutionMethodology like '%Agile%' THEN 'Agile' ELSE PSD.ExecutionMethodology END) END) AS ExecutionId                               
  FROM                              
  AVL.MAS_ProjectMaster PM WITH (NOLOCK)                              
  INNER JOIN MS.ProjectRegistrationDetails PRD WITH (NOLOCK)                              
  ON PRD.EsaProjectID = PM.EsaProjectID AND PM.IsDeleted = 0 AND PRD.Type='Predominant' AND PRD.TypeOfProject in ('Project','Group Project')                            
  INNER JOIN MS.ProjectScopeDetails PSD WITH (NOLOCK)                              
  ON PRD.RegistrationId = PSD.RegistrationId                              
  INNER JOIN MAS.PPAttributeValues AV1 WITH (NOLOCK) ON AV1.AttributeValueName = PRD.ProjectOwningUnit                              
  INNER JOIN MAS.PPAttributes A1 WITH (NOLOCK) ON A1.AttributeID = AV1.AttributeID AND A1.AttributeName = 'MainspringPOU'                              
  INNER JOIN MAS.PPAttributeValues AV2 WITH (NOLOCK) ON AV2.AttributeValueName = PRD.Unit                              
  INNER JOIN MAS.PPAttributes A2 WITH (NOLOCK) ON A2.AttributeID = AV2.AttributeID AND A2.AttributeName = 'OPLProjectOwningUnit'                              
  WHERE ISNULL(PSD.ExecutionMethodology,'') <> ''                              
  AND PSD.ExecutionMethodology <> @TraditionalMethod AND PSD.ExecutionMethodology <> @OthersMethod                              
  AND NOT EXISTS(                              
  SELECT TOP 1 PAV.ProjectID FROM PP.ProjectAttributeValues PAV WITH (NOLOCK)                              
  WHERE PAV.ProjectID = PM.ProjectID                              
  AND PAV.AttributeID = @ExecutionAttributeId                     
  AND PAV.AttributeValueid= PP.GetExecutionMethodIdByName(CASE WHEN PSD.ExecutionMethodology like '%Agile%'     AND ISNULL(PSD.TypeofAgileMethodology,'') <> ''                              
                            THEN PSD.TypeofAgileMethodology ELSE (CASE WHEN PSD.ExecutionMethodology like '%Agile%' THEN 'Agile' ELSE PSD.ExecutionMethodology END) END)                  
  AND PAV.CreatedBy  LIKE '%MainSpringFeed%'                               
  AND PAV.ModifiedBy IS NOT NULL AND PAV.ModifiedBy NOT LIKE '%MainSpringFeed%'                             
  AND PAV.IsDeleted = 1)                           --AND pm.esaprojectid='1000179367'                              
 )                              
                              
 SELECT ProjectID,ExecutionId INTO #MainSpringExecution FROM CTEExecutionMethod CEM                              
 WHERE NOT EXISTS(                              
 SELECT TOP 1 ID FROM PP.ProjectAttributeValues PAV WITH(NOLOCK)                              
 WHERE CEM.ProjectID = PAV.ProjectID AND PAV.AttributeID = @ExecutionAttributeId                              
 AND CEM.ExecutionId = PAV.AttributeValueID AND PAV.IsDeleted = 0)  AND CEM.ExecutionId IS NOT NULL                             
                              
                              
 UPDATE PAV                              
  SET IsDeleted = 1,                             
   ModifiedBy = @DataFrom,                              
   ModifiedDate = GETDATE()                              
  FROM PP.ProjectAttributeValues PAV  WITH (NOLOCK)                            
  INNER JOIN #MainSpringExecution MSE WITH (NOLOCK)                                 
  ON PAV.ProjectID = MSE.ProjectID                               
  AND PAV.AttributeID= @ExecutionAttributeId                              
  AND PAV.AttributeValueID <> MSE.ExecutionId                              
  AND PAV.IsDeleted = 0                              
  AND PAV.CreatedBy LIKE '%MainSpringFeed%'                                    
  AND (PAV.ModifiedBy IS NULL OR ISNULL(PAV.ModifiedBy,'') LIKE '%MainSpringFeed%')                              
                                
                              
 UPDATE PAV                              
  SET IsDeleted = 0,                              
   ModifiedBy = @DataFrom,                              
   ModifiedDate = GETDATE()                              
  FROM PP.ProjectAttributeValues PAV WITH (NOLOCK)                                
  INNER JOIN #MainSpringExecution MSE WITH (NOLOCK)                                 
  ON PAV.ProjectID = MSE.ProjectID                               
  AND PAV.AttributeID= @ExecutionAttributeId                              
  AND PAV.AttributeValueID = MSE.ExecutionId                              
  AND PAV.IsDeleted = 1                              
  AND PAV.CreatedBy LIKE '%MainSpringFeed%'                                    
  AND (PAV.ModifiedBy IS NULL OR ISNULL(PAV.ModifiedBy,'') LIKE '%MainSpringFeed%')                            
                              
 INSERT INTO PP.ProjectAttributeValues                              
 SELECT ProjectID,                              
     ExecutionId,                              
     @ExecutionAttributeId,                               
     0,                              
     @DataFrom,                              
     GETDATE(),                              
     NULL,                              
     NULL                              
     FROM                               
#MainSpringExecution MSE                              
 WHERE NOT EXISTS(                              
 SELECT TOP 1 ID FROM PP.ProjectAttributeValues PAV WITH (NOLOCK) WHERE PAV.ProjectID = MSE.ProjectID                              
 AND PAV.AttributeID = @ExecutionAttributeId AND PAV.AttributeValueID = MSE.ExecutionId)                              
                              
 --Update Project Description                              
 UPDATE PD                              
 SET PD.ProjectShortDescription = PDD.ShortDescriptionOfProject,                              
  PD.IsMainSpring = 1    FROM                              
  AVL.MAS_ProjectMaster PM WITH (NOLOCK)                              
  INNER JOIN PP.ProjectDetails PD WITH (NOLOCK)                              
  ON PM.ProjectID = PD.ProjectID                               
  AND PM.IsDeleted = 0 AND PD.IsDeleted = 0                              
  INNER JOIN MS.ProjectRegistrationDetails PRD WITH (NOLOCK)                              
  ON PRD.EsaProjectID = PM.EsaProjectID                               
  INNER JOIN MS.ProjectDemographicDetails PDD WITH (NOLOCK)                              
  ON PRD.RegistrationId = PDD.RegistrationId                            
  AND PD.ProjectShortDescription <> PDD.ShortDescriptionOfProject                              
  --INNER JOIN MAS.PPAttributeValues AV1 ON AV1.AttributeValueName = PRD.ProjectOwningUnit                              
  --INNER JOIN MAS.PPAttributes A1 ON A1.AttributeID = AV1.AttributeID AND A1.AttributeName = 'MainspringPOU'            
  --INNER JOIN MAS.PPAttributeValues AV2 ON AV2.AttributeValueName = PRD.Unit                              
  --INNER JOIN MAS.PPAttributes A2 ON A2.AttributeID = AV2.AttributeID AND A2.AttributeName = 'OPLProjectOwningUnit'                              
  WHERE ISNULL(PDD.ShortDescriptionOfProject,'') <>''  AND PRD.Type='Predominant' AND PRD.TypeOfProject in ('Project','Group Project')                            
  AND PD.IsMainSpring = 1                              
                            
 --Update Project Archetype                      
 UPDATE SW                              
 SET SW.ProjectTypeId = PV.AttributeValueID,                              
  SW.ModifiedBy = @DataFrom,                              
  SW.ModifiedDate = GETDATE()                              
 FROM                              
  AVL.MAS_ProjectMaster PM WITH (NOLOCK)                              
  INNER JOIN PP.scopeofwork SW WITH (NOLOCK)                              
  ON PM.ProjectID = SW.ProjectID                               
  AND PM.IsDeleted = 0 AND SW.IsDeleted = 0                              
  INNER JOIN MS.ProjectRegistrationDetails PRD WITH (NOLOCK)                              
  ON PRD.EsaProjectID = PM.EsaProjectID                               
  INNER JOIN MS.ProjectScopeDetails PSD WITH (NOLOCK)                              
  ON PRD.RegistrationId = PSD.RegistrationId                              
  INNER JOIN MAS.PPAttributevalues PV WITH (NOLOCK)                              
  ON PV.AttributeID = @ProjectArchType                               
  AND PSD.Archetype = PV.AttributeValueName                              
  AND PV.AttributeValueID <> SW.ProjectTypeId                              
  AND PV.IsDeleted = 0                             
  INNER JOIN MAS.PPAttributeValues AV1 WITH (NOLOCK) ON AV1.AttributeValueName = PRD.ProjectOwningUnit                              
  INNER JOIN MAS.PPAttributes A1 WITH (NOLOCK) ON A1.AttributeID = AV1.AttributeID AND A1.AttributeName = 'MainspringPOU'                              
  INNER JOIN MAS.PPAttributeValues AV2 WITH (NOLOCK)  ON AV2.AttributeValueName = PRD.Unit                              
  INNER JOIN MAS.PPAttributes A2 WITH (NOLOCK) ON A2.AttributeID = AV2.AttributeID AND A2.AttributeName = 'OPLProjectOwningUnit'                              
  WHERE ISNULL(PSD.Archetype,'') <>'' AND  PSD.Archetype NOT LIKE '%--None--%'  AND PRD.Type='Predominant' AND PRD.TypeOfProject in ('Project','Group Project')         
      
 --Update IsTransitionInScope                      
 UPDATE SW                              
 SET SW.IsTransitionInScope = CASE WHEN PDD.IsTransitionInScope = 'Y' Then 1    
                                   WHEN PDD.IsTransitionInScope = 'N' Then 0     
           Else NULL END    
  FROM                              
  AVL.MAS_ProjectMaster PM WITH (NOLOCK)              
  INNER JOIN PP.scopeofwork SW WITH (NOLOCK) ON PM.ProjectID = SW.ProjectID AND PM.IsDeleted = 0 AND SW.IsDeleted = 0                              
  INNER JOIN MS.ProjectRegistrationDetails PRD WITH (NOLOCK) ON PRD.EsaProjectID = PM.EsaProjectID                               
  INNER JOIN MS.ProjectDemographicDetails PDD WITH (NOLOCK) ON PRD.RegistrationId = PDD.RegistrationId                                                     
  INNER JOIN MAS.PPAttributeValues AV1 WITH (NOLOCK)  ON AV1.AttributeValueName = PRD.ProjectOwningUnit                              
  INNER JOIN MAS.PPAttributes A1 WITH (NOLOCK)  ON A1.AttributeID = AV1.AttributeID AND A1.AttributeName = 'MainspringPOU'                              
  INNER JOIN MAS.PPAttributeValues AV2 WITH (NOLOCK) ON AV2.AttributeValueName = PRD.Unit                              
  INNER JOIN MAS.PPAttributes A2 WITH (NOLOCK) ON A2.AttributeID = AV2.AttributeID AND A2.AttributeName = 'OPLProjectOwningUnit'                              
  WHERE PRD.Type='Predominant' AND PRD.TypeOfProject in ('Project','Group Project')                
                              
 DECLARE @ProjectSubArcheType [MS].[ProjectAttributes]                              
 DECLARE @ProjectModernizationScope [MS].[ProjectAttributes]                              
                               
 INSERT INTO @ProjectSubArcheType                              
 SELECT DISTINCT PM.ProjectID,                              
 PSD.WorkCategory,                            
 PSD.Archetype                            
 FROM                              
 AVL.MAS_ProjectMaster PM WITH (NOLOCK)                              
 INNER JOIN MS.ProjectRegistrationDetails PRD WITH (NOLOCK)                              
 ON PRD.EsaProjectID = PM.EsaProjectID AND PM.IsDeleted = 0 AND PRD.Type='Predominant'                             
 AND PRD.TypeOfProject in ('Project','Group Project')                              
 INNER JOIN MS.ProjectScopeDetails PSD WITH (NOLOCK)                              
 ON PRD.RegistrationId = PSD.RegistrationId                              
  INNER JOIN MAS.PPAttributeValues AV1 WITH (NOLOCK) ON AV1.AttributeValueName = PRD.ProjectOwningUnit                              
  INNER JOIN MAS.PPAttributes A1 WITH (NOLOCK) ON A1.AttributeID = AV1.AttributeID AND A1.AttributeName = 'MainspringPOU'                              
  INNER JOIN MAS.PPAttributeValues AV2 WITH (NOLOCK) ON AV2.AttributeValueName = PRD.Unit                              
  INNER JOIN MAS.PPAttributes A2 WITH (NOLOCK) ON A2.AttributeID = AV2.AttributeID AND A2.AttributeName = 'OPLProjectOwningUnit'                             
 WHERE ISNULL(PSD.WorkCategory,'') <> ''   AND   ISNULL(PSD.Archetype,'') <> ''  AND PSD.WorkCategory NOT LIKE '%--None--%'                 
   AND PSD.Archetype NOT LIKE '%--None--%'                 
                               
 INSERT INTO @ProjectModernizationScope                              
 SELECT DISTINCT PM.ProjectID,                              
 PSD.ModernizationScope,                            
 PSD.Archetype                              
 FROM                              
 AVL.MAS_ProjectMaster PM WITH (NOLOCK)                              
 INNER JOIN MS.ProjectRegistrationDetails PRD WITH (NOLOCK)                              
 ON PRD.EsaProjectID = PM.EsaProjectID AND PM.IsDeleted = 0 AND PRD.Type='Predominant'                             
 AND PRD.TypeOfProject in ('Project','Group Project')                                
 INNER JOIN MS.ProjectScopeDetails PSD WITH (NOLOCK)                              
 ON PRD.RegistrationId = PSD.RegistrationId                              
  INNER JOIN MAS.PPAttributeValues AV1 ON AV1.AttributeValueName = PRD.ProjectOwningUnit                 
  INNER JOIN MAS.PPAttributes A1 ON A1.AttributeID = AV1.AttributeID AND A1.AttributeName = 'MainspringPOU'                              
  INNER JOIN MAS.PPAttributeValues AV2 ON AV2.AttributeValueName = PRD.Unit                              
  INNER JOIN MAS.PPAttributes A2 ON A2.AttributeID = AV2.AttributeID AND A2.AttributeName = 'OPLProjectOwningUnit'                             
 WHERE ISNULL(PSD.ModernizationScope,'') <> ''   AND   ISNULL(PSD.Archetype,'') <> ''  AND PSD.ModernizationScope NOT LIKE '%--None--%'                 
 AND PSD.Archetype NOT LIKE '%--None--%'                                
                            
 EXEC [MS].[InsertOrUpdateMainspringData] @ProjectSubArchTypeId,@ProjectSubArcheType                              
 EXEC [MS].[InsertOrUpdateMainspringData] @ModernizationScopeId,@ProjectModernizationScope                               
                              
 ;WITH CTEMainspring AS                              
 (                              
  SELECT DISTINCT EsaProjectId, PA.AttributeID, unpvt.AttributeName, unpvt.AttributeValue     
  FROM                               
     (SELECT PRD.EsaProjectId,                                
     CAST(PSD.EngagementModel as NVARCHAR(2000)) AS 'DeliveryEngagementModel',                              
     CAST(POM.TypeofPricingModel as NVARCHAR(2000)) AS 'PricingModel',                              
     CAST(PSD.BusinessDriver as NVARCHAR(2000))  as 'BusinessDriver'                                
     FROM AVL.MAS_ProjectMaster PM                               
     INNER JOIN  MS.ProjectRegistrationDetails PRD WITH (NOLOCK)                              
     ON PM.EsaProjectId = PRD.EsaProjectId                               
     AND PM.IsDeleted = 0  AND PRD.Type='Predominant' AND PRD.TypeOfProject in ('Project','Group Project')                              
     INNER JOIN MS.ProjectOperatingModel POM WITH (NOLOCK)                              
     ON PRD.RegistrationId = POM.RegistrationId                              
     INNER JOIN MS.ProjectScopeDetails PSD WITH (NOLOCK)                              
     ON PRD.RegistrationId = PSD.RegistrationId                              
  INNER JOIN MAS.PPAttributeValues AV1 WITH (NOLOCK) ON AV1.AttributeValueName = PRD.ProjectOwningUnit                              
  INNER JOIN MAS.PPAttributes A1 WITH (NOLOCK) ON A1.AttributeID = AV1.AttributeID AND A1.AttributeName = 'MainspringPOU'                              
  INNER JOIN MAS.PPAttributeValues AV2 WITH (NOLOCK) ON AV2.AttributeValueName = PRD.Unit                              
  INNER JOIN MAS.PPAttributes A2  WITH (NOLOCK) ON A2.AttributeID = AV2.AttributeID AND A2.AttributeName = 'OPLProjectOwningUnit'                             
     --where PRD.EsaProjectId='1000179367'                            
  ) p                              
  UNPIVOT                              
     (AttributeValue FOR AttributeName IN                               
     (DeliveryEngagementModel,[PricingModel]                              
     ,BusinessDriver)                              
  )AS unpvt                                
  INNER JOIN MAS.PPAttributes PA WITH (NOLOCK) ON unpvt.AttributeName = PA.AttributeName AND PA.IsDeleted=0                              
  WHERE unpvt.AttributeValue IS NOT NULL AND AttributeValue <> ''                              
 ), CTEProjectAttributes AS                              
 (                              
 select pm.EsaProjectID,A.AttributeID,A.AttributeName,                              
   CASE WHEN PAV.CreatedBy IS NOT NULL AND                          ((PAV.ModifiedBy IS NOT NULL AND PAV.ModifiedBy NOT LIKE '%MainSpringFeed%')                              
    OR (PAV.ModifiedBy IS NULL AND PAV.CreatedBy  NOT LIKE '%MainSpringFeed%'))                             
   THEN '-1'                              
  ELSE AV.[AttributeValueName]  END AS AttributeValueName from MAS.PPATTRIBUTES A WITH (NOLOCK)                            
 INNER JOIN  MAS.PPAttributeValues AV WITH (NOLOCK) on A.AttributeID = AV.AttributeID and A.IsDeleted=0 AND AV.IsDeleted=0                              
 INNER JOIN  PP.ProjectAttributeValues PAV  WITH (NOLOCK) on PAV.AttributeID = A.AttributeID AND AV.AttributeValueID = PAV.AttributeValueID                              
 INNER JOIN AVL.MAS_ProjectMaster pm WITH (NOLOCK) ON pm.ProjectID = PAV.ProjectID --and pm.ProjectID=9829                             
 AND PAV.IsDeleted=0                             
 WHERE                               
  A.AttributeName IN (                              
  'DeliveryEngagementModel','PricingModel','BusinessDriver')                              
  )                   
                              
                               
 SELECT                               
 DISTINCT PM.ProjectId,PM.EsaProjectID,CM.AttributeID,PAV.AttributeValueID,                              
 CASE WHEN ISNULL(CPA.AttributeValueName, '0') <> '-1' and                              
  ISNULL(CPA.AttributeValueName, '0') <> CM.AttributeValue                              
  THEN 1                                 
  ELSE 0                              
  END AS IsEligibletoInsertOrUpdate                              
  INTO #MainspringAttibuteValues                              
 FROM AVL.MAS_ProjectMaster PM                             
 INNER JOIN CTEMainspring CM WITH (NOLOCK) ON  PM.EsaProjectID = CM.EsaProjectID AND PM.IsDeleted=0                              
 INNER JOIN MAS.PPAttributeValues PAV WITH (NOLOCK) ON CM.AttributeID = PAV.AttributeID                               
 AND PAV.AttributeValueName = CM.AttributeValue                              
 AND PAV.IsDeleted = 0                              
 LEFT JOIN CTEProjectAttributes CPA WITH (NOLOCK) ON CM.EsaProjectID = CPA.EsaProjectID                               
 AND CM.AttributeID = CPA.AttributeID AND CM.AttributeName = CPA.AttributeName                              
                               
                              
  UPDATE PAV                              
  SET PAV.IsDeleted = 1, ModifiedBy=@DataFrom, ModifiedDate=GETDATE()                              
  FROM                              
  PP.ProjectAttributeValues PAV                              
  INNER JOIN #MainspringAttibuteValues MAV ON MAV.IsEligibletoInsertOrUpdate = 1                              
  AND PAV.ProjectId = MAV.ProjectId                              
  AND PAV.AttributeID = MAV.AttributeID                              
  AND PAV.AttributeValueID <> MAV.AttributeValueID                              
  AND PAV.IsDeleted = 0                              
  WHERE CreatedBy LIKE '%MainSpringFeed%'                             
                              
  UPDATE PAV                              
  SET PAV.IsDeleted = 0, ModifiedBy=@DataFrom, ModifiedDate=GETDATE()                              
  FROM                              
  PP.ProjectAttributeValues PAV                              
  INNER JOIN #MainspringAttibuteValues MAV ON MAV.IsEligibletoInsertOrUpdate = 1                              
  AND PAV.ProjectId = MAV.ProjectId                              
  AND PAV.AttributeID = MAV.AttributeID                              
  AND PAV.AttributeValueID = MAV.AttributeValueID                              
  AND PAV.IsDeleted = 1                              
  WHERE CreatedBy LIKE '%MainSpringFeed%'                               
                              
                               
 INSERT INTO PP.ProjectAttributeValues                              
 SELECT ProjectID,                              
     AttributeValueID,                              
     AttributeID,                               
     0,                              
     @DataFrom,                              
     GETDATE(),                              
     NULL,                              
     NULL                              
     FROM                               
 #MainspringAttibuteValues MAV WITH (NOLOCK)   
 WHERE MAV.IsEligibletoInsertOrUpdate = 1 AND NOT EXISTS(                              
 SELECT TOP 1 ID FROM PP.ProjectAttributeValues PAV WITH (NOLOCK) WHERE PAV.ProjectID = MAV.ProjectID                              
 AND PAV.AttributeID = MAV.AttributeID AND PAV.AttributeValueID = MAV.AttributeValueID)                       
                       
 -- Updating isdeleted=1 for OtherAttributeValues for BusinessDriver & PricingModel                      
 Update OAV                      
 SET  OAV.Isdeleted=1                      
 FROM PP.OtherAttributeValues OAV                      
 INNER JOIN MAS.PPAttributeValues PAV ON PAV.AttributeValueID = OAV.AttributeValueID                      
 INNER JOIN MAS.PPAttributes PA ON PA.AttributeID = PAV.AttributeID AND PA.AttributeName='BusinessDriver'                      
 INNER JOIN #MainspringAttibuteValues MAV ON MAV.ProjectID = OAV.ProjectID AND MAV.AttributeID = PA.AttributeID AND MAV.IsEligibletoInsertOrUpdate = 1                       
 WHERE  MAV.AttributeValueID <> (Select AttributeValueID from MAS.PPAttributeValues where Attributevaluename='Others' and AttributeId = 19)                      
                      
                      
  Update OAV                      
 SET  OAV.Isdeleted=1                      
 FROM PP.OtherAttributeValues OAV                      
 INNER JOIN MAS.PPAttributeValues PAV ON PAV.AttributeValueID = OAV.AttributeValueID                      
 INNER JOIN MAS.PPAttributes PA ON PA.AttributeID = PAV.AttributeID AND PA.AttributeName='PricingModel'                      
 INNER JOIN #MainspringAttibuteValues MAV ON MAV.ProjectID = OAV.ProjectID AND MAV.AttributeID = PA.AttributeID AND MAV.IsEligibletoInsertOrUpdate = 1                       
 WHERE MAV.AttributeValueID <> (Select AttributeValueID from MAS.PPAttributeValues where Attributevaluename='Others' and AttributeId = 37)                      
                      
-- Updating isdeleted=0 for OtherAttributeValues for BusinessDriver & PricingModel                      
  Update OAV                      
 SET  OAV.Isdeleted=0                      
 FROM PP.OtherAttributeValues OAV                      
 INNER JOIN MAS.PPAttributeValues PAV ON PAV.AttributeValueID = OAV.AttributeValueID                      
 INNER JOIN MAS.PPAttributes PA ON PA.AttributeID = PAV.AttributeID AND PA.AttributeName='BusinessDriver'                      
 INNER JOIN #MainspringAttibuteValues MAV ON MAV.ProjectID = OAV.ProjectID AND MAV.AttributeID = PA.AttributeID AND MAV.IsEligibletoInsertOrUpdate = 1                       
 WHERE  MAV.AttributeValueID = (Select AttributeValueID from MAS.PPAttributeValues where Attributevaluename='Others' and AttributeId = 19)                      
                      
                      
  Update OAV                      
 SET  OAV.Isdeleted=0                      
 FROM PP.OtherAttributeValues OAV                      
 INNER JOIN MAS.PPAttributeValues PAV ON PAV.AttributeValueID = OAV.AttributeValueID                      
 INNER JOIN MAS.PPAttributes PA ON PA.AttributeID = PAV.AttributeID AND PA.AttributeName='PricingModel'                    
 INNER JOIN #MainspringAttibuteValues MAV ON MAV.ProjectID = OAV.ProjectID AND MAV.AttributeID = PA.AttributeID AND MAV.IsEligibletoInsertOrUpdate = 1                       
 WHERE MAV.AttributeValueID = (Select AttributeValueID from MAS.PPAttributeValues where Attributevaluename='Others' and AttributeId = 37)       
     
--Insert/Update Additional Archetypes    
;WITH CTEAdditionalArchetype AS                              
 (                              
  SELECT DISTINCT PM.ProjectID,PM.EsaProjectID,PV.AttributeValueId AS AddArchetypeId                               
  FROM AVL.MAS_ProjectMaster PM WITH (NOLOCK)                              
  INNER JOIN MS.ProjectRegistrationDetails PRD WITH (NOLOCK) ON PRD.EsaProjectID = PM.EsaProjectID AND PM.IsDeleted = 0     
  AND PRD.Type='Additional' AND PRD.TypeOfProject in ('Project','Group Project') AND PRD.IsDeleted = 0                          
  INNER JOIN MS.ProjectScopeDetails PSD WITH (NOLOCK) ON PRD.RegistrationId = PSD.RegistrationId  AND PSD.IsDeleted = 0      
  INNER JOIN MAS.PPAttributevalues PV WITH (NOLOCK) ON PV.AttributeID = @AdditionalArchetype AND PSD.Archetype = PV.AttributeValueName AND PV.IsDeleted = 0    
  INNER JOIN MAS.PPAttributeValues AV1 WITH (NOLOCK) ON AV1.AttributeValueName = PRD.ProjectOwningUnit                              
  INNER JOIN MAS.PPAttributes A1 WITH (NOLOCK) ON A1.AttributeID = AV1.AttributeID AND A1.AttributeName = 'MainspringPOU'                              
  INNER JOIN MAS.PPAttributeValues AV2 WITH (NOLOCK) ON AV2.AttributeValueName = PRD.Unit                              
  INNER JOIN MAS.PPAttributes A2 WITH (NOLOCK) ON A2.AttributeID = AV2.AttributeID AND A2.AttributeName = 'OPLProjectOwningUnit'                              
  WHERE ISNULL(PSD.Archetype,'') <> ''                         
 )                              
                              
 SELECT ProjectID,AddArchetypeId INTO #MainSpringAddArchetype FROM CTEAdditionalArchetype CAA                              
                            
                              
                              
 UPDATE PAV                              
  SET IsDeleted = 1,                             
  ModifiedBy = @DataFrom,                              
  ModifiedDate = GETDATE()                              
  FROM PP.ProjectAttributeValues PAV                              
  INNER JOIN #MainSpringAddArchetype MSA                             
  ON PAV.ProjectID = MSA.ProjectID                               
  AND PAV.AttributeID= @AdditionalArchetype                  
  AND PAV.AttributeValueID <> MSA.AddArchetypeId                              
  AND PAV.IsDeleted = 0                      
                                
                              
 UPDATE PAV                              
  SET IsDeleted = 0,                              
   ModifiedBy = @DataFrom,                              
   ModifiedDate = GETDATE()                              
  FROM PP.ProjectAttributeValues PAV                              
  INNER JOIN #MainSpringAddArchetype MSA                              
  ON PAV.ProjectID = MSA.ProjectID                               
  AND PAV.AttributeID= @AdditionalArchetype                              
  AND PAV.AttributeValueID = MSA.AddArchetypeId                              
  AND PAV.IsDeleted = 1                         
                              
 INSERT INTO PP.ProjectAttributeValues                              
 SELECT ProjectID,                              
     AddArchetypeId,                              
     @AdditionalArchetype,                               
     0,                              
     @DataFrom,                              
     GETDATE(),                              
     NULL,                              
     NULL                              
     FROM                               
 #MainSpringAddArchetype MSA                              
 WHERE NOT EXISTS(                              
 SELECT TOP 1 ID FROM PP.ProjectAttributeValues PAV WHERE PAV.ProjectID = MSA.ProjectID                              
 AND PAV.AttributeID = @AdditionalArchetype AND PAV.AttributeValueID = MSA.AddArchetypeId)        
    
COMMIT TRAN                        
END TRY                              
BEGIN CATCH         
ROLLBACK TRAN         
 DECLARE @ErrorMessage VARCHAR(1000)                              
 SET @ErrorMessage = ERROR_MESSAGE()                              
 EXEC DBO.AVL_InsertError 'PP.ProjectDetailsMainspringSyncup', @ErrorMessage, 0,0          
    --Send Error mail notification        
  DECLARE @MailSubject VARCHAR(MAX);            
  DECLARE @MailBody  VARCHAR(MAX);          
            
  SELECT @MailSubject = CONCAT(@@servername, ': Mainspring Applens Integration Job Failure Notification')          
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in [PP].[ProjectDetailsMainspringSyncup] during the Project Data integration in Applens from Mainspring!<br>          
       <br>Error: ', @ErrorMessage,          
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')          
   DECLARE @recipientAddress NVARCHAR(4000)='';            
             SET @recipientAddress = (SELECT ConfigValue FROM AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);       
  EXEC [AVL].[SendDBEmail] @To=@recipientAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody       
END CATCH;                              
SET NOCOUNT OFF;                              
END