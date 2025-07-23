/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetOperatingModalDetail]
@ProjectID BIGINT  
AS   
  BEGIN   
 BEGIN TRY   
  SET NOCOUNT ON;  
     DECLARE @IScognizant BIT;         
     SELECT TOP 1 @IScognizant=IsCoginzant FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectId = @ProjectID AND IsDeleted = 0    
   --GET THE ATTRIBUTES FOR THE UI ENABLE DISABLE (ProjectScope on behalf of Vendor Scope,WorkItemMeasurement,PricingModel)   
   SELECT  AttributeID  
       ,AttributeName  
       ,SourceID  
       ,ScopeID  
       ,IsPrepopulate  
       ,IsCognizant   
       ,IsMandatory  
     FROM MAS.PPAttributes(NOLOCK) PPA   
     WHERE PPA.IsDeleted = 0 and AttributeName in ('ProjectScope','WorkItemMeasurement','PricingModel','Executionlevers')  
     
   --GET ALL THE ATTRIBUTE VALUES (ProjectScope on behalf of Vendor Scope,WorkItemMeasurement,PricingModel)   
   IF(@IScognizant =0)
   BEGIN
   SELECT           AttributeValueID  
                   ,AttributeValueName  
                   ,PPAV.AttributeID   
                   ,ParentID  
                    FROM mas.PPAttributeValues(NOLOCK) PPAV  
     INNER JOIN mas.PPAttributes PPA ON PPA.AttributeID = PPAV.AttributeID  
     WHERE PPAV.IsDeleted = 0 and PPA.AttributeName in ('ProjectScope','WorkItemMeasurement','PricingModel','Executionlevers')  
	 AND PPAV.CreatedBy <>'MainspringFeed'
	 ORDER BY AttributeValueName ASC 
   END

   ELSE
   BEGIN
      SELECT        AttributeValueID  
                   ,AttributeValueName  
                   ,PPAV.AttributeID   
                   ,ParentID  
                    FROM mas.PPAttributeValues(NOLOCK) PPAV  
     INNER JOIN mas.PPAttributes PPA ON PPA.AttributeID = PPAV.AttributeID  
     WHERE PPAV.IsDeleted = 0 and PPA.AttributeName in ('ProjectScope','WorkItemMeasurement','PricingModel','Executionlevers')  
	 ORDER BY AttributeValueName ASC 
   END
      
  
   --GET ALL ATTRIBUTE VALUES SAVED FOR OPERATING MODAL AGAINST THE PROJECT  
     
   SELECT pav.ProjectID,pav.AttributeID,pa.AttributeName,pav.AttributeValueID as AttributeValue,pv.AttributeValueName  
   FROM [PP].[ProjectAttributeValues] pav  
   INNER JOIN MAS.PPAttributes pa ON pa.AttributeID = pav.AttributeID  
   INNER JOIN mas.PPAttributeValues pv ON pv.AttributeValueID = pav.AttributeValueID  
   WHERE pav.ProjectID=@ProjectID AND pav.IsDeleted = 0  and pv.IsDeleted = 0 and pa.AttributeName in ('WorkItemMeasurement','PricingModel','Executionlevers')--For WorkItemMeasurement & PricingModel  
  
   --GET OTHER OPERATING MODAL DETAILS BASED ON PROJECTID  (Class 'ExtendedProjectDetails' is used for this)  
   SELECT   
   OM.ProjectID,  
   (select Ot.OtherFieldValue from pp.OtherAttributeValues ot  
   inner join mas.PPAttributeValues pv on pv.AttributeValueID = ot.AttributeValueID  
   inner join mas.PPAttributes PPA ON PPA.AttributeID = pv.AttributeID  
   where ot.ProjectID=@ProjectID and PPA.AttributeName = 'WorkItemMeasurement' and ot.IsDeleted=0) as OtherWorkItemMeasurement,  
   OM.WorkItemSize,  
   (select Ot.OtherFieldValue from pp.OtherAttributeValues ot  
   inner join mas.PPAttributeValues pv on pv.AttributeValueID = ot.AttributeValueID  
   inner join mas.PPAttributes PPA ON PPA.AttributeID = pv.AttributeID  
   where ot.ProjectID=@ProjectID and PPA.AttributeName = 'PricingModel' and ot.IsDeleted=0)as OtherPricingModel,  
   OM.VendorPresence  
   FROM PP.OperatingModel OM   
   WHERE OM.ProjectID = @ProjectID and OM.IsDeleted =0  
  
   --GET VENDOR DETAILS IN OPERATING MODAL  
   SELECT   
      VendorDetailID  
   ,VendorName  
   ,VendorScopeID  
   FROM PP.Project_VendorDetails(NOLOCK)  where ProjectID = @ProjectID AND IsDeleted = 0  
  
  
    
    
  
 END TRY   
  
    BEGIN CATCH   
        DECLARE @ErrorMessage VARCHAR(MAX);   
        SELECT @ErrorMessage = ERROR_MESSAGE()   
        --INSERT Error       
        EXEC AVL_INSERTERROR  '[PP].[GetOperatingModalDetail]', @ErrorMessage,  0,   
        0   
    END CATCH   
  END
