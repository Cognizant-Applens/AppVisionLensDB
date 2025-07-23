/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author		: 803988
-- Create date	: 22-May-2020
-- Description	: Get the mapping details for the project and master details
-- Revision		: 03-Jun-2020
-- Revised By	: 803988
-- =============================================

CREATE PROCEDURE [PP].[ALMFiledsConfigSelect]     
 -- Add the parameters for the stored procedure here    
 @ProjectID BIGINT,    
 @ALMConfigName VARCHAR(50)    
AS    
BEGIN    
 SET NOCOUNT ON;    
 Declare @IsChecked BIT = 1  
 Declare @IsApplensAsALM BIT = 1  

set @IsApplensAsALM =(select top 1 isnull(IsApplensAsALM,0) from PP.ScopeOfWork where ProjectID=@ProjectID and isDeleted=0)

 IF (@ProjectID IS NOT NULL AND @ProjectID > 0)    
 BEGIN    
  IF @ALMConfigName = 'WORKTYPE'    
  BEGIN  
  
  IF @IsApplensAsALM=0
  BEGIN
  SELECT     
   WorkTypeId AS 'StandardFieldId',    
   WorkTypeName AS 'StandardFieldName'     
   FROM PP.ALM_MAS_WorkType WITH (NOLOCK)    
   WHERE IsDeleted = 0 and  WorkTypeId not in(5,6)    
  END
  ELSE
   BEGIN
   SELECT     
   WorkTypeId AS 'StandardFieldId',    
   WorkTypeName AS 'StandardFieldName'     
   FROM PP.ALM_MAS_WorkType WITH (NOLOCK)    
   WHERE IsDeleted = 0   
  END   
        
   SELECT     
   WorkTypeMapId AS 'MappingId',    
   ProjectId AS 'ProjectId',    
   WorkTypeId AS 'StandardFieldId',    
   ProjectWorkTypeName AS 'SourceName',        
   @IsChecked AS 'IsChecked',  
   ISNULL(IsEffortTracking,1) AS 'IsEffort'  
   FROM PP.ALM_MAP_WorkType WITH (NOLOCK)    
   WHERE ProjectId=@ProjectID AND IsDeleted = 0      
  END    
  ELSE IF @ALMConfigName = 'SEVERITY'    
  BEGIN    
   SELECT     
   SeverityId AS 'StandardFieldId',    
   SeverityName AS 'StandardFieldName'     
   FROM PP.ALM_MAS_Severity WITH (NOLOCK)    
   WHERE IsDeleted = 0    
        
   SELECT     
   SeverityMapId AS 'MappingId',    
   ProjectId AS 'ProjectId',    
   SeverityId AS 'StandardFieldId',    
   ProjectSeverityName AS 'SourceName',        
   @IsChecked AS 'IsChecked'   
   FROM PP.ALM_MAP_Severity WITH (NOLOCK)    
   WHERE ProjectId=@ProjectID AND IsDeleted = 0    
  END    
  ELSE IF @ALMConfigName = 'PRIORITY'    
  BEGIN    
   SELECT     
   PriorityId AS 'StandardFieldId',    
   PriorityName AS 'StandardFieldName'     
   FROM PP.ALM_MAS_Priority WITH (NOLOCK)    
   WHERE IsDeleted = 0    
        
   SELECT     
   PriorityMapId AS 'MappingId',    
   ProjectId AS 'ProjectId',    
   PriorityId AS 'StandardFieldId',    
   ProjectPriorityName AS 'SourceName',        
   @IsChecked AS 'IsChecked'   
   FROM PP.ALM_MAP_Priority WITH (NOLOCK)    
   WHERE ProjectId=@ProjectID AND IsDeleted = 0    
  END    
  ELSE IF @ALMConfigName = 'STATUS'    
  BEGIN    
   SELECT     
   StatusId AS 'StandardFieldId',    
   StatusName AS 'StandardFieldName'     
   FROM PP.ALM_MAS_Status WITH (NOLOCK)    
   WHERE IsDeleted = 0    
        
   SELECT     
   StatusMapId AS 'MappingId',    
   ProjectId AS 'ProjectId',    
   StatusId AS 'StandardFieldId',    
   ProjectStatusName AS 'SourceName',        
   @IsChecked AS 'IsChecked'   
   FROM PP.ALM_MAP_Status WITH (NOLOCK)    
   WHERE ProjectId=@ProjectID AND IsDeleted = 0    
  END    
 END    
    
 SET NOCOUNT OFF;    
END
