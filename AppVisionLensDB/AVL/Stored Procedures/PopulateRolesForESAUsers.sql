/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
  
  
CREATE PROCEDURE [AVL].[PopulateRolesForESAUsers]      
 AS       
  BEGIN
  SET NOCOUNT ON;
   BEGIN TRY      
    
    DECLARE @CreatedBy VARCHAR(50) = 'SYSTEM'     
    DECLARE @ModifiedBy VARCHAR(50) = ''    
    DECLARE @DataSource VARCHAR(50) = 'ESA'      
    DECLARE @RoleName VARCHAR(50) = 'Operational'    
    DECLARE @AccessLevel VARCHAR(50) = 'Project'    
    DECLARE @RoleID INT    
    DECLARE @AccessLevelSourceID INT    
    
    CREATE TABLE #tempProject(      
     EmployeeID [nvarchar](50) NOT NULL,     
     RoleID [int] NOT NULL,     
     AccessLevelSourceID [int] NOT NULL,    
  AccessLevelID [bigint] NULL,     
  IsActive [bit] NOT NULL,       
  CreatedBy [nvarchar](50) NULL,     
  CreatedDate [smalldatetime] NULL,      
  ModifiedBy [nvarchar](50) NULL,     
  ModifiedDate [smalldatetime] NULL,     
  DataSource [varchar](100) NULL     
  )    
    
    SELECT @RoleID = RoleID     
   FROM [AVL].[RoleMaster] (NOLOCK) WHERE RoleName = @RoleName    
    
    SELECT @AccessLevelSourceID = AccessLevelSourceID     
   FROM [AVL].[ACCESSLEVELSOURCEMASTER] (NOLOCK) WHERE AccessLevel = @AccessLevel    
      
    INSERT INTO #tempProject    
    SELECT DISTINCT assoc.AssociateID as EmployeeID, @RoleID as RoleID,    
     @AccessLevelSourceID as AccessLevelSourceID,  pm.ProjectID as AccesslevelID,    
     assoc.IsActive as IsActive, @CreatedBy as CreatedBy, GETDATE() as CreatedDate,     
     @ModifiedBy as ModifiedBy, GETDATE() as ModifiedDate, @DataSource as DataSource      
   FROM [AVL].[GradeRoleMapping] grm (NOLOCK)    
   JOIN [ESA].[ASSOCIATES] assoc (NOLOCK)    
   ON grm.Grade = assoc.Grade    
   JOIN [ESA].[PROJECTASSOCIATES] pa (NOLOCK)    
   ON assoc.AssociateID = pa.AssociateID    
   JOIN [AVL].[MAS_ProjectMaster] pm (NOLOCK)    
   ON pa.ProjectID = pm.EsaProjectID    
   WHERE --pa.Dept_Name like 'AVM%' OR pa.Dept_Name like 'AVM-%' AND   
   grm.IsActive = 1         
    
   INSERT INTO [AVL].[UserRoleMapping](EmployeeID, RoleID, AccessLevelSourceID,    
            AccessLevelID, IsActive, CreatedBy,CreatedDate,    
            ModifiedBy, ModifiedDate, DataSource)      
   SELECT EmployeeID, RoleID, AccessLevelSourceID, AccesslevelID, IsActive, CreatedBy, CreatedDate,     
    ModifiedBy, ModifiedDate,DataSource     
    FROM #tempProject src      
   WHERE NOT EXISTS (      
   SELECT *    
    FROM [AVL].[UserRoleMapping] tgt (NOLOCK)      
   WHERE tgt.RoleID = src.RoleID      
     AND tgt.AccessLevelSourceID = src.AccessLevelSourceID     
     AND tgt.EmployeeID = src.EmployeeID      
     AND (tgt.AccessLevelID = src.AccesslevelID  OR COALESCE(tgt.AccessLevelID, src.AccesslevelID) IS NULL)    
   )     
  
   /****** Update associates who are existing in UserRoleMapping table ******/  
 UPDATE urm SET    
 IsActive = 1,    
 ModifiedBy = 'SYSTEM',    
 ModifiedDate = GETDATE()     
 FROM [AVL].[UserRoleMapping] urm   
 WHERE EXISTS (   
 SELECT * FROM #tempProject tp      
 WHERE tp.RoleID = urm.RoleID  
 AND   tp.AccessLevelSourceID = urm.AccessLevelSourceID     
 AND   tp.EmployeeID = urm.EmployeeID  
 AND  (tp.AccesslevelID = urm.AccessLevelID  OR COALESCE(tp.AccesslevelID, urm.AccessLevelID) IS NULL)    
 ) AND urm.DataSource = 'ESA' AND  urm.IsActive = 0   
 /****** End ******/  
    
  /****** Update DataSource as ESA for the records which are inserted through UI or Manually if records exist ******/    
  UPDATE urm SET    
   urm.DataSource = @DataSource,    
   urm.ModifiedBy = 'SYSTEM',    
   urm.ModifiedDate = GETDATE()     
   FROM [AVL].[UserRoleMapping] urm    
   WHERE EXISTS (      
   SELECT * FROM #tempProject tp      
   WHERE tp.RoleID = urm.RoleID    
   AND   tp.AccessLevelSourceID = urm.AccessLevelSourceID    
   AND   tp.EmployeeID = urm.EmployeeID    
   AND  (tp.AccesslevelID = urm.AccessLevelID  OR COALESCE(tp.AccesslevelID, urm.AccessLevelID) IS NULL)    
   ) AND (urm.DataSource = 'UI' OR urm.DataSource = 'Manual')    
  /****** End ******/    
    
  /****** Handling inactive associates ******/    
  UPDATE urm SET    
   IsActive = 0,    
   ModifiedBy = 'SYSTEM',    
   ModifiedDate = GETDATE()     
   FROM [AVL].[UserRoleMapping] urm    
   WHERE NOT EXISTS (      
   SELECT * FROM #tempProject tp      
   WHERE RoleID = tp.RoleID      
   AND  urm.AccessLevelSourceID = tp.AccessLevelSourceID     
   AND  urm.EmployeeID = tp.EmployeeID      
   AND (urm.AccessLevelID = tp.AccesslevelID  OR COALESCE(urm.AccessLevelID, tp.AccesslevelID) IS NULL)    
   ) AND urm.DataSource = 'ESA' AND  urm.IsActive = 1 AND  urm.RoleID = 3  
  /****** End ******/    
    
  DROP TABLE #tempProject    
    
   END TRY       
    
   BEGIN CATCH        
         
   DECLARE @ErrorMessage VARCHAR(MAX);        
   SELECT @ErrorMessage = ERROR_MESSAGE()        
   --INSERT Error            
   EXEC AVL_InsertError '[AVL].[PopulateRolesForESAUsers]', @ErrorMessage,0      
      END CATCH  
	  SET NOCOUNT OFF;
   END
