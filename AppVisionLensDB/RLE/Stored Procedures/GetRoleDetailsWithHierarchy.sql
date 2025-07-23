/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    
CREATE PROCEDURE [RLE].[GetRoleDetailsWithHierarchy]   
(    
 @AssociateId NVARCHAR(50),    
 @GroupName NVARCHAR(100)    
)    
AS    
BEGIN    
   SET NOCOUNT ON    
    
      
   BEGIN --DECLRATION    
    DECLARE @AssociateName NVARCHAR(255) = NULL,@Email NVARCHAR(255) = NULL    
    DECLARE @GroupID INT    
   END    
    
   BEGIN --Selecting AssociateName and Email    
    SELECT @AssociateName = AssociateName,@Email = Email     
    FROM ESA.Associates (NOLOCK)    
    WHERE IsActive = 1 AND AssociateID = CONVERT(CHAR(11),@AssociateId)    
   END    
    
   --Returning nothing, If AssociateName and EmailID of AssociateId is null    
   IF(ISNULL(@AssociateName,'') <> '' AND ISNULL(@Email,'') <> '')    
   BEGIN    
         
    BEGIN --VALUE ASSIGNING    
         
     SELECT @GroupID = GroupID    
     FROM MAS.RLE_Groups (NOLOCK)    
     WHERE IsDeleted = 0 AND GroupName = @GroupName    
    
    END    
    SELECT  rm.AssociateId, g.GroupID,g.GroupName,rm.ApplensRoleID AS RoleID,ro.RoleName, ro.RoleKey, rd.MarketId, rd.MarketUnitId,     
    rd.BusinessUnitID, rd.SBU1ID,rd.SBU2ID, rd.IndustrySegmentId, rd.VerticalID, rd.SubVerticalID, rd.CustomerID, rd.ParentCustomerID,    
    rd.ProjectID, rd.PracticeID, rm.DataSource into #tempRoleData    
    FROM RLE.UserRoleMapping rm (NOLOCK)    
    JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0    
    JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0    
    JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0      
    WHERE rm.IsDeleted = 0 AND rm.AssociateID = @AssociateId AND g.GroupID = @GroupID    
    
    BEGIN     
     --Selese roles for RHMS datasource    
     SELECT DISTINCT     
       @AssociateId AS AssociateId,@AssociateName AS AssociateName,@Email AS Email    
       ,rd.GroupID,rd.GroupName    
       ,rd.RoleID,rd.RoleName, rd.RoleKey       
       ,qd.MarketID,qd.MarketName    
       ,qd.MarketUnitID,qd.MarketUnitName    
       ,qd.BusinessUnitID,qd.BusinessUnitName    
       ,qd.SBU1ID,qd.SBU1Name     
       ,qd.SBU2ID,qd.SBU2Name     
       ,qd.IndustrySegmentId, qd.IndustrySegmentName    
       ,qd.VerticalID,qd.VerticalName    
       ,qd.SubVerticalID,qd.SubVerticalName    
       ,qd.CustomerID,qd.ESACustomerID,qd.CustomerName    
       ,qd.ParentCustomerID,qd.ParentCustomerName    
       ,qd.PracticeID,qd.PracticeName      
     FROM #tempRoleData rd    
       LEFT JOIN RLE.MasterHierarchy qd (NOLOCK) ON ISNULL(rd.MarketId, ISNULL(qd.MarketID,'')) = ISNULL(qd.MarketID,'')    
            AND ISNULL(rd.MarketUnitId, ISNULL(qd.MarketUnitId, '')) = ISNULL(qd.MarketUnitId,'')    
            AND ISNULL(rd.BusinessUnitID, ISNULL(qd.BusinessUnitID, '')) = ISNULL(qd.BusinessUnitID,'')    
            AND ISNULL(rd.SBU1ID, ISNULL(qd.SBU1ID, '')) = ISNULL(qd.SBU1ID,'')    
            AND ISNULL(rd.SBU2ID, ISNULL(qd.SBU2ID, '')) = ISNULL(qd.SBU2ID,'')    
            AND ISNULL(rd.IndustrySegmentId, ISNULL(qd.IndustrySegmentId, '')) = ISNULL(qd.IndustrySegmentId,'')    
            AND ISNULL(rd.VerticalID, ISNULL(qd.VerticalID, '')) = ISNULL(qd.VerticalID,'')    
            AND ISNULL(rd.SubVerticalID, ISNULL(qd.SubVerticalID, '')) = ISNULL(qd.SubVerticalID,'')    
            AND ISNULL(rd.ParentCustomerID, ISNULL(qd.ParentCustomerID, '')) = ISNULL(qd.ParentCustomerID,'')    
            AND ISNULL(rd.CustomerID, ISNULL(qd.CustomerID, '')) = ISNULL(qd.CustomerID,'')    
            AND ISNULL(rd.PracticeID, ISNULL(qd.PracticeID, '')) = ISNULL(qd.PracticeID,'')    
            AND ISNULL(rd.ProjectID, ISNULL(qd.ProjectID, '')) = ISNULL(qd.ProjectID,'')    
     WHERE rd.DataSource = 'RHMS'    
     UNION    
     --Select role data for UI and PP data source only with single combination without practice    
     SELECT DISTINCT  @AssociateId AS AssociateId,@AssociateName AS AssociateName,@Email AS Email,rd.GroupID,rd.GroupName,rd.RoleID,rd.RoleName, rd.RoleKey         
     ,COALESCE(m.MarketID, mu.MarketID, bu.MarketID, sbu1.MarketID, i.MarketID, c.MarketId, p.MarketID) MarketID    
     ,COALESCE(m.MarketName, mu.MarketName, bu.MarketName, sbu1.MarketName, i.MarketName, c.MarketName, p.MarketName) MarketName    
     ,COALESCE(m.MarketUnitID, mu.MarketUnitID, bu.MarketUnitID, sbu1.MarketUnitID, i.MarketUnitID, c.MarketUnitId, p.MarketUnitID) MarketUnitID    
     ,COALESCE(m.MarketUnitName, mu.MarketUnitName, bu.MarketUnitName, sbu1.MarketUnitName, i.MarketUnitName, c.MarketUnitName, p.MarketUnitName) MarketUnitName    
     ,COALESCE(m.BusinessUnitID, mu.BusinessUnitID, bu.BusinessUnitID, sbu1.BusinessUnitID, i.BusinessUnitID, c.BusinessUnitID, p.BusinessUnitID) BusinessUnitID    
     ,COALESCE(m.BusinessUnitName, mu.BusinessUnitName, bu.BusinessUnitName, sbu1.BusinessUnitName, i.BusinessUnitName, c.BusinessUnitName, p.BusinessUnitName) BusinessUnitName    
     ,COALESCE(m.SBU1ID, mu.SBU1ID, bu.SBU1ID, sbu1.SBU1ID, i.SBU1ID, c.SBU1ID, p.SBU1ID) SBU1ID    
     ,COALESCE(m.SBU1Name, mu.SBU1Name, bu.SBU1Name, sbu1.SBU1Name, i.SBU1Name, c.SBU1Name, p.SBU1Name) SBU1Name    
     ,COALESCE(m.SBU2ID, mu.SBU2ID, bu.SBU2ID, sbu1.SBU2ID, i.SBU2ID, c.SBU2ID, p.SBU2ID) SBU2ID    
     ,COALESCE(m.SBU2Name, mu.SBU2Name, bu.SBU2Name, sbu1.SBU2Name, i.SBU2Name, c.SBU2Name, p.SBU2Name) SBU2Name    
     ,COALESCE(m.IndustrySegmentId, mu.IndustrySegmentId, bu.IndustrySegmentId, sbu1.IndustrySegmentId, i.IndustrySegmentId, c.IndustrySegmentId, p.IndustrySegmentId) IndustrySegmentId    
     ,COALESCE(m.IndustrySegmentName, mu.IndustrySegmentName, bu.IndustrySegmentName, sbu1.IndustrySegmentName, i.IndustrySegmentName, c.IndustrySegmentName, p.IndustrySegmentName) IndustrySegmentName    
     ,COALESCE(m.VerticalID, mu.VerticalID, bu.VerticalID, sbu1.VerticalID, i.VerticalID, c.VerticalID, p.VerticalID) VerticalID    
     ,COALESCE(m.VerticalName, mu.VerticalName, bu.VerticalName, sbu1.VerticalName, i.VerticalName, c.VerticalName, p.VerticalName) VerticalName    
     ,COALESCE(m.SubVerticalID, mu.SubVerticalID, bu.SubVerticalID, sbu1.SubVerticalID, i.SubVerticalID, c.SubVerticalID, p.SubVerticalID) SubVerticalID    
     ,COALESCE(m.SubVerticalName, mu.SubVerticalName, bu.SubVerticalName, sbu1.SubVerticalName, i.SubVerticalName, c.SubVerticalName, p.SubVerticalName) SubVerticalName    
     ,COALESCE(m.CustomerID, mu.CustomerID, bu.CustomerID, sbu1.CustomerID, i.CustomerID, c.CustomerID, p.CustomerID) CustomerID    
     ,COALESCE(m.ESACustomerID, mu.ESACustomerID, bu.ESACustomerID, sbu1.ESACustomerID, i.ESACustomerID, c.ESACustomerID, p.ESACustomerID) ESACustomerID    
     ,COALESCE(m.CustomerName, mu.CustomerName, bu.CustomerName, sbu1.CustomerName, i.CustomerName, c.CustomerName, p.CustomerName) CustomerName    
     ,COALESCE(m.ParentCustomerID, mu.ParentCustomerID, bu.ParentCustomerID, sbu1.ParentCustomerID, i.ParentCustomerID, c.ParentCustomerID, p.ParentCustomerID) ParentCustomerID    
     ,COALESCE(m.ParentCustomerName, mu.ParentCustomerName, bu.ParentCustomerName, sbu1.ParentCustomerName, i.ParentCustomerName, c.ParentCustomerName, p.ParentCustomerName) ParentCustomerName    
     ,COALESCE(m.PracticeID, mu.PracticeID, bu.PracticeID, sbu1.PracticeID, i.PracticeID, c.PracticeID, p.PracticeID) PracticeID    
     ,COALESCE(m.PracticeName, mu.PracticeName, bu.PracticeName, sbu1.PracticeName, i.PracticeName, c.PracticeName, p.PracticeName) PracticeName     
     FROM #tempRoleData rd    
     LEFT JOIN RLE.MasterHierarchy m (NOLOCK) ON rd.MarketId = m.MarketId      
     LEFT JOIN RLE.MasterHierarchy mu (NOLOCK) ON rd.MarketUnitId = mu.MarketUnitId    
     LEFT JOIN RLE.MasterHierarchy bu (NOLOCK) ON rd.BusinessUnitID = bu.BusinessUnitID    
     LEFT JOIN RLE.MasterHierarchy sbu1 (NOLOCK) ON rd.SBU1ID = sbu1.SBU1ID    
     LEFT JOIN RLE.MasterHierarchy i (NOLOCK) ON rd.IndustrySegmentId = i.IndustrySegmentId    
     LEFT JOIN RLE.MasterHierarchy c (NOLOCK) ON (rd.CustomerID = c.CustomerID)     
     LEFT JOIN RLE.MasterHierarchy p (NOLOCK) ON (rd.ProjectID = p.ProjectID)     
     Where rd.DataSource IN ('UI', 'PP', 'ESA') AND rd.PracticeId is null    
     UNION    
     --Select role data for UI and PP data source only with single combination as practice    
     SELECT DISTINCT  @AssociateId AS AssociateId,@AssociateName AS AssociateName,@Email AS Email,rd.GroupID,rd.GroupName,rd.RoleID,rd.RoleName, rd.RoleKey        
       ,pc.MarketID,pc.MarketName    
       ,pc.MarketUnitID,pc.MarketUnitName    
       ,pc.BusinessUnitID,pc.BusinessUnitName    
       ,pc.SBU1ID,pc.SBU1Name     
       ,pc.SBU2ID,pc.SBU2Name     
       ,pc.IndustrySegmentId, pc.IndustrySegmentName    
       ,pc.VerticalID,pc.VerticalName    
       ,pc.SubVerticalID,pc.SubVerticalName    
       ,pc.CustomerID,pc.ESACustomerID,pc.CustomerName    
       ,pc.ParentCustomerID,pc.ParentCustomerName    
       ,pc.PracticeID,pc.PracticeName      
     FROM #tempRoleData rd    
     JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.PracticeID = pc.PracticeID     
     Where rd.DataSource = 'UI' AND rd.MarketID Is NULL AND rd.MarketUnitID IS NULL AND rd.BusinessUnitID IS NULL     
     AND rd.SBU1ID IS NULL AND rd.SBU2ID IS NULL AND rd.IndustrySegmentId IS NULL AND rd.VerticalID IS NULL AND rd.SubVerticalID IS NULL     
     AND rd.CustomerID IS NULL AND rd.ParentCustomerID IS NULL AND rd.ProjectID IS NULL AND rd.PracticeID IS NOT NULL    
     UNION    
     --Select role data for UI data source only with combination of Businessunit and practice    
     SELECT DISTINCT  @AssociateId AS AssociateId,@AssociateName AS AssociateName,@Email AS Email,rd.GroupID,rd.GroupName,rd.RoleID,rd.RoleName, rd.RoleKey             
       ,pc.MarketID,pc.MarketName    
       ,pc.MarketUnitID,pc.MarketUnitName    
       ,pc.BusinessUnitID,pc.BusinessUnitName    
       ,pc.SBU1ID,pc.SBU1Name     
       ,pc.SBU2ID,pc.SBU2Name     
       ,pc.IndustrySegmentId, pc.IndustrySegmentName    
       ,pc.VerticalID,pc.VerticalName    
       ,pc.SubVerticalID,pc.SubVerticalName    
       ,pc.CustomerID,pc.ESACustomerID,pc.CustomerName    
       ,pc.ParentCustomerID,pc.ParentCustomerName    
       ,pc.PracticeID,pc.PracticeName      
     FROM #tempRoleData rd    
     JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.BusinessUnitID = pc.BusinessUnitID AND rd.PracticeID = pc.PracticeID     
     Where rd.DataSource = 'UI' AND rd.BusinessUnitID IS NOT NULL AND rd.PracticeID IS NOT NULL    
     UNION    
     --Select role data for UI data source only with combination of Customer and practice    
     SELECT  DISTINCT  @AssociateId AS AssociateId,@AssociateName AS AssociateName,@Email AS Email,rd.GroupID,rd.GroupName,rd.RoleID,rd.RoleName, rd.RoleKey             
       ,pc.MarketID,pc.MarketName    
       ,pc.MarketUnitID,pc.MarketUnitName    
       ,pc.BusinessUnitID,pc.BusinessUnitName    
       ,pc.SBU1ID,pc.SBU1Name     
       ,pc.SBU2ID,pc.SBU2Name     
       ,pc.IndustrySegmentId, pc.IndustrySegmentName    
       ,pc.VerticalID,pc.VerticalName    
       ,pc.SubVerticalID,pc.SubVerticalName    
       ,pc.CustomerID,pc.ESACustomerID,pc.CustomerName    
       ,pc.ParentCustomerID,pc.ParentCustomerName    
       ,pc.PracticeID,pc.PracticeName      
     FROM #tempRoleData rd    
     JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.CustomerID = pc.CustomerID AND rd.PracticeID = pc.PracticeID     
     Where rd.DataSource = 'UI' AND rd.CustomerID IS NOT NULL AND rd.PracticeID IS NOT NULL    
     UNION    
     --Select role data for UI data source only with combination of project and practice    
     SELECT  DISTINCT  @AssociateId AS AssociateId,@AssociateName AS AssociateName,@Email AS Email,rd.GroupID,rd.GroupName,rd.RoleID,rd.RoleName, rd.RoleKey             
       ,pc.MarketID,pc.MarketName    
       ,pc.MarketUnitID,pc.MarketUnitName    
       ,pc.BusinessUnitID,pc.BusinessUnitName    
       ,pc.SBU1ID,pc.SBU1Name     
       ,pc.SBU2ID,pc.SBU2Name     
       ,pc.IndustrySegmentId, pc.IndustrySegmentName    
       ,pc.VerticalID,pc.VerticalName    
       ,pc.SubVerticalID,pc.SubVerticalName    
       ,pc.CustomerID,pc.ESACustomerID,pc.CustomerName    
       ,pc.ParentCustomerID,pc.ParentCustomerName    
       ,pc.PracticeID,pc.PracticeName      
     FROM #tempRoleData rd    
     JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.ProjectID = pc.ProjectID AND rd.PracticeID = pc.PracticeID     
     Where rd.DataSource = 'UI' AND rd.ProjectID IS NOT NULL AND rd.PracticeID IS NOT NULL    
     UNION    
     --Select role data for UI data source only with combination of Customer and practice    
     SELECT DISTINCT     
       @AssociateId AS AssociateId,@AssociateName AS AssociateName,@Email AS Email    
       ,g.GroupID,g.GroupName,rm.ApplensRoleID AS RoleID,ro.RoleName, ro.RoleKey         
       ,NULL MarketID,NULL MarketName    
       ,NULL MarketUnitID,NULL MarketUnitName    
       ,NULL BusinessUnitID,NULL BusinessUnitName    
       ,NULL SBU1ID,NULL SBU1Name     
       ,NULL SBU2ID,NULL SBU2Name     
       ,NULL IndustrySegmentId, NULL IndustrySegmentName    
       ,NULL VerticalID,NULL VerticalName    
       ,NULL SubVerticalID,NULL SubVerticalName    
       ,NULL CustomerID,NULL ESACustomerID,NULL CustomerName    
       ,NULL ParentCustomerID,NULL ParentCustomerName    
       ,NULL PracticeID,NULL PracticeName      
     FROM RLE.UserRoleMapping rm (NOLOCK)    
       JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0    
       JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0    
       LEFT JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.AssociateID = rm.AssociateID AND rd.IsDeleted = 0    
     WHERE rm.IsDeleted = 0 AND rm.DataSource = 'UI' AND rm.AssociateID = @AssociateId AND g.GroupID = @GroupID     
     AND rd.RoleMappingID IS NULL    
    END    
    drop table #tempRoleData    
   END    
 END
