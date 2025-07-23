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
-- Author      : 803988    
-- Create date : 22-May-2020    
-- Description : Procedure to map standard fields (WorkType, Severity, Status, Priority)      
--     and source fields (custom project fields) againt respective project.    
-- Revision    :    
-- Revised By  :    
-- =========================================================================================     
    
CREATE PROC [PP].[ALMFiledsConfigMappingProcess]     
(    
@ProjectId   BIGINT,     
@EmployeeId  NVARCHAR(100),    
@ALMConfigName VARCHAR(50),    
@FieldMapping AS [PP].[FieldProjectMapping] READONLY    
)    
    
AS     
  BEGIN      
  SET NOCOUNT ON    
    DECLARE @NoOfRows INT     
    DECLARE @DisProjCount INT     
 DECLARE @Result BIT = 0    
  Declare @Delete bit = 0  
    
 -- Logic Explanation    
 -- --------------------------------------------------------------------------------------------------    
 -- The rows which has MappingId = -1 and IsChecked = 1 will be inserted    
 -- The matching row of the MappingId and ProjectId and IsChecked = 1  will be updated    
 -- The row of source table which has IsChecked = 0 and contains MappingId in the target table mapping column     
 -- of the respective table (Priority or Status or Priority or Severity) will be deleted from target table    
 -- --------------------------------------------------------------------------------------------------    
    
    SELECT @NoOfRows = COUNT(1) FROM @FieldMapping     
    SELECT @DisProjCount = COUNT(DISTINCT ProjectId) FROM @FieldMapping    
     
 BEGIN TRY    
  IF @NoOfRows > 0 AND @DisProjCount = 1    
  BEGIN    
   IF @ALMConfigName = 'WORKTYPE'     
    BEGIN    
    BEGIN TRAN    
     MERGE [PP].[ALM_MAP_WorkType] mapt     
     USING @FieldMapping maps     
     ON mapt.WorkTypeMapId = maps.MappingId     
      AND mapt.ProjectId = maps.ProjectId     
      AND maps.IsChecked = 1     
     WHEN MATCHED THEN     
      UPDATE SET mapt.WorkTypeId = maps.StandardFieldId,     
         mapt.ProjectWorkTypeName = maps.SourceName,     
         mapt.ModifiedBy = @EmployeeId,     
         mapt.ModifiedDate = GETDATE(),    
         mapt.IsDeleted = 0,
		 mapt.IsEffortTracking = maps.IsEffort
     WHEN NOT MATCHED AND maps.MappingId = -1 AND maps.IsChecked = 1 THEN     
      INSERT     
      (WorkTypeId, ProjectId, ProjectWorkTypeName, IsDeleted, CreatedBy, CreatedDate, IsEffortTracking)     
      VALUES     
      (maps.StandardFieldId, maps.ProjectId, maps.SourceName, 0, @EmployeeId, GETDATE(),maps.IsEffort);  
     --WHEN NOT MATCHED BY SOURCE AND mapt.ProjectId = @ProjectId     
     --AND mapt.WorkTypeMapId IN (SELECT MappingId FROM @FieldMapping) THEN     
     -- DELETE;     
If not exists(select distinct WorkTypeMapId from ADM.ALM_TRN_WorkItem_Details where WorkTypeMapId in     
(SELECT MappingId FROM @FieldMapping where IsChecked=0))      
begin      
      
delete from [PP].[ALM_MAP_WorkType] where  WorkTypeMapId in (SELECT MappingId FROM @FieldMapping where IsChecked=0)      
  
set @Delete=1  
end       
      
    COMMIT TRAN        
    SET @Result = 1   
  
 if(exists(SELECT MappingId FROM @FieldMapping where IsChecked=0) and @Delete=0)  
  begin  
    SET @Result = 0  
  end   
    END    
   ELSE IF @ALMConfigName = 'PRIORITY'     
    BEGIN    
    BEGIN TRAN    
     MERGE [PP].[ALM_MAP_Priority] mapt     
     USING @FieldMapping maps     
     ON mapt.PriorityMapId = maps.MappingId     
      AND mapt.ProjectId = maps.ProjectId     
      AND maps.IsChecked = 1     
     WHEN MATCHED THEN     
      UPDATE SET mapt.PriorityId = maps.StandardFieldId,     
         mapt.ProjectPriorityName = maps.SourceName,     
         mapt.ModifiedBy = @EmployeeId,     
         mapt.ModifiedDate = GETDATE(),    
         mapt.IsDeleted = 0    
     WHEN NOT MATCHED AND maps.MappingId = -1 AND maps.IsChecked = 1 THEN     
      INSERT     
      (PriorityId, ProjectId, ProjectPriorityName, IsDeleted, CreatedBy, CreatedDate)     
      VALUES     
      (maps.StandardFieldId, maps.ProjectId, maps.SourceName, 0, @EmployeeId, GETDATE()) ;    
     --WHEN NOT MATCHED BY SOURCE AND mapt.ProjectId = @ProjectId     
     --AND mapt.PriorityMapId IN (SELECT MappingId FROM @FieldMapping) THEN     
     -- DELETE;     
    
   If not exists(select distinct WorkTypeMapId from ADM.ALM_TRN_WorkItem_Details where PriorityMapId in       
(SELECT MappingId FROM @FieldMapping where IsChecked=0))      
begin      
      
delete from PP.ALM_MAP_Priority where  PriorityMapId in (SELECT MappingId FROM @FieldMapping where IsChecked=0)    
  
set @Delete=1  
end      
    
    
    COMMIT TRAN        
    SET @Result = 1    
 if(exists(SELECT MappingId FROM @FieldMapping where IsChecked=0) and @Delete=0)  
  begin  
    SET @Result = 0  
  end  
  
  
    END    
   ELSE IF @ALMConfigName = 'SEVERITY'     
    BEGIN    
    BEGIN TRAN    
     MERGE [PP].[ALM_MAP_Severity] mapt     
     USING @FieldMapping maps     
     ON mapt.SeverityMapId = maps.MappingId     
      AND mapt.ProjectId = maps.ProjectId     
      AND maps.IsChecked = 1     
     WHEN MATCHED THEN     
      UPDATE SET mapt.SeverityId = maps.StandardFieldId,     
         mapt.ProjectSeverityName = maps.SourceName,     
         mapt.ModifiedBy = @EmployeeId,     
         mapt.ModifiedDate = GETDATE(),    
         mapt.IsDeleted = 0    
     WHEN NOT MATCHED AND maps.MappingId = -1 AND maps.IsChecked = 1 THEN     
      INSERT     
      (SeverityId, ProjectId, ProjectSeverityName, IsDeleted, CreatedBy, CreatedDate)     
      VALUES     
      (maps.StandardFieldId, maps.ProjectId, maps.SourceName, 0, @EmployeeId, GETDATE());     
     --WHEN NOT MATCHED BY SOURCE AND mapt.ProjectId = @ProjectId     
     --AND mapt.SeverityMapId IN (SELECT MappingId FROM @FieldMapping) THEN     
     -- DELETE;    
    
    If not exists(select distinct WorkTypeMapId from ADM.ALM_TRN_WorkItem_Details where SeverityMapId in       
(SELECT MappingId FROM @FieldMapping where IsChecked=0))      
begin      
      
delete from PP.ALM_MAP_Severity where  SeverityMapId in (SELECT MappingId FROM @FieldMapping where IsChecked=0)   
set @Delete=1  
end      
    
    
    COMMIT TRAN        
    SET @Result = 1    
 if(exists(SELECT MappingId FROM @FieldMapping where IsChecked=0) and @Delete=0)  
  begin  
    SET @Result = 0  
  end  
       
    END    
   ELSE IF @ALMConfigName = 'STATUS'     
    BEGIN    
    BEGIN TRAN    
     MERGE [PP].[ALM_MAP_Status] mapt     
     USING @FieldMapping maps     
     ON mapt.StatusMapId = maps.MappingId     
      AND mapt.ProjectId = maps.ProjectId     
      AND maps.IsChecked = 1     
     WHEN MATCHED THEN     
      UPDATE SET mapt.StatusId = maps.StandardFieldId,     
         mapt.ProjectStatusName = maps.SourceName,     
         mapt.ModifiedBy = @EmployeeId,     
         mapt.ModifiedDate = GETDATE(),    
         mapt.IsDeleted = 0    
     WHEN NOT MATCHED AND maps.MappingId = -1 AND maps.IsChecked = 1 THEN     
      INSERT     
      (StatusId, ProjectId, ProjectStatusName, IsDeleted, CreatedBy, CreatedDate)     
      VALUES     
      (maps.StandardFieldId, maps.ProjectId, maps.SourceName, 0, @EmployeeId, GETDATE());  
     --WHEN NOT MATCHED BY SOURCE AND mapt.ProjectId = @ProjectId     
     --AND mapt.StatusMapId IN (SELECT MappingId FROM @FieldMapping) THEN     
     -- DELETE;     
  
  
   If not exists(select distinct WorkTypeMapId from ADM.ALM_TRN_WorkItem_Details where StatusMapId in       
(SELECT MappingId FROM @FieldMapping where IsChecked=0))      
begin      
      
delete from PP.ALM_MAP_Status where  StatusMapId in (SELECT MappingId FROM @FieldMapping where IsChecked=0)   
set @Delete=1  
end      
    
    
    COMMIT TRAN        
    SET @Result = 1        
 if(exists(SELECT MappingId FROM @FieldMapping where IsChecked=0) and @Delete=0)  
  begin  
    SET @Result = 0  
  end  
       
    END    
  SELECT @Result AS Result    
    
  EXEC [PP].[SaveAdapterTileProgressPercentage] @ProjectId,@EmployeeId    
    
  END    
 END TRY    
  BEGIN CATCH    
   SET @Result = 0    
   DECLARE @ErrorMessage VARCHAR(MAX);    
   SELECT @ErrorMessage = ERROR_MESSAGE()    
   ROLLBACK TRAN    
   SELECT @Result AS Result    
   EXEC AVL_InsertError '[PP].[ALMFiledsConfigMappingProcess]', @ErrorMessage, 0 ,0    
  END CATCH    
  END
