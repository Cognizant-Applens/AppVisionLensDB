/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ADM_ProgressBarAppInfraDetails] (    
@ProjectID BIGINT    
)    
    
AS    
BEGIN    
SET NOCOUNT ON;  
          DECLARE @AppInvPercentage INT;    
    DECLARE @UserCount INT;         
          DECLARE @IsCognizant INT=0;         
          DECLARE @AppInvProgress AS INT=0;      
          DECLARE @InFraInvProgress AS INT=0;      
    DECLARE @CustomerId BIGINT = 0;    
    DECLARE @TaskMapping INT = 1;     
    
  SET @CustomerId=(SELECT CustomerID         
                            FROM   avl.MAS_ProjectMaster (NOLOCK)         
                            WHERE  ProjectID = @ProjectId)        
      
          SET @IsCognizant=(SELECT Count(1)         
                            FROM   avl.customer (NOLOCK)          
                            WHERE  customerid = @CustomerId         
                                   AND iscognizant = 1         
                                   AND isdeleted = 0)           
        
   /***PROGRESS Based on Support Type****/        
   DECLARE @SupportType INT = (SELECT ISNULL(SupportTypeId,0)     
   FROM AVL.MAP_ProjectConfig (NOLOCK)  WHERE ProjectID = @ProjectID)      
       
   IF @IsCognizant = 1      
   BEGIN      
    SET @TaskMapping = (SELECT Count(ISNULL(InfraTaskID,0)) FROM AVL.InfraTaskMappingTransaction (NOLOCK)      
   where CustomerID = @CustomerId AND IsDeleted=0)       
   END     
       
   -- App Inventory Percentage Calculation    
   -- Support Type --> 1 - Pure App (Maintenance), 3 - Both App & Infra (CIS), 4 - Dev / Testing    
   IF (@SupportType = 1  OR @SupportType = 3 OR @SupportType = 4)    
   BEGIN    
        
    SET @AppInvProgress=(SELECT TOP 1 completionpercentage         
     FROM   avl.prj_configurationprogress (NOLOCK)          
      WHERE  customerid = @CustomerId AND screenid = 1);         
    
    IF EXISTS(SELECT 1 FROM AVL.APP_MAP_ApplicationProjectMapping PM (NOLOCK)          
    WHERE PM.ProjectID = @ProjectID AND PM.IsDeleted = 0)        
    BEGIN        
    
    IF @AppInvProgress < 100        
    BEGIN        
     SET @AppInvProgress = @AppInvProgress + 25;        
    END       
          
    END         
    
  END    
       
  -- Infra Inventory Percentage Calculation    
  -- Support Type --> 2 - Pure Infra (CIS), 3 - Both App & Infra (CIS)    
   IF (@SupportType = 2  OR @SupportType = 3)    
   BEGIN    
    
   SET @InFraInvProgress=(SELECT TOP 1 completionpercentage         
    FROM   avl.prj_configurationprogress (NOLOCK)         
    WHERE  screenid = 17 AND customerid = @CustomerId AND IsDeleted =0);      
      
   IF EXISTS (SELECT 1 FROM AVL.InfraTowerProjectMapping IPM (NOLOCK)           
       WHERE IPM.ProjectID=@ProjectID AND IPM.IsEnabled = 1 AND IPM.IsDeleted=0)      
   BEGIN    
      
    IF @InFraInvProgress < 100        
    BEGIN        
     SET @InFraInvProgress = @InFraInvProgress + 25;        
    END      
       
   END    
          
   SET @InFraInvProgress = CASE WHEN (@TaskMapping <> 0 and @InFraInvProgress >= 50 and @InFraInvProgress <= 75)     
         THEN @InFraInvProgress + 25 ELSE @InFraInvProgress  END      
   SET @InFraInvProgress =  CASE WHEN (@InFraInvProgress > 100) THEN 100 ELSE @InFraInvProgress END      
       
  END    
    
  SET @AppInvPercentage = CASE WHEN @SupportType = 1 OR @SupportType = 4 THEN @AppInvProgress    
          WHEN @SupportType = 2 THEN @InFraInvProgress    
          WHEN @SupportType = 3 THEN (@AppInvProgress + @InFraInvProgress) / 2    
        END    
        
    -- User Details Percentage Calculation    
    SET @UserCount= (SELECT COUNT(UserRoleMappingID) FROM AVL.UserRoleMapping (NOLOCK)      
    WHERE RoleID!=1 AND AccessLevelID=@ProjectId AND IsActive=1  AND AccessLevelSourceID=4)      
    
          SELECT DISTINCT CASE WHEN @AppInvPercentage = 100 THEN @AppInvPercentage         
                            ELSE 0         
                          END       AS AppInvPercentage,         
                          CASE WHEN @UserCount > 0 THEN 100         
                            ELSE 0         
                          END                        AS UserCount       
    
SET NOCOUNT OFF;    
END
