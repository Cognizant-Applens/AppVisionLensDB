CREATE procedure [RLE].[GetAllRoleDetails]
AS  
Begin  
  
  
SELECT DISTINCT m.MarketID, m.MarketName, mu.MarketUnitID, mu.MarketUnitName,       
   bu.BusinessUnitID, bu.BusinessUnitName,       
   sbu1.SBU1ID, sbu1.SBU1Name, sbu2.SBU2ID, sbu2.SBU2Name,      
   v.VerticalID, v.VerticalName,sv.SubVerticalID, sv.SubVerticalName,      
   pcu.ParentCustomerID, pcu.ParentCustomerName, cu.CustomerID, cu.CustomerName,      
   cu.ESA_AccountId ESACustomerID,pc.PracticeID,pc.PracticeName,      
   p.ProjectID, p.ProjectName, p.ESAProjectID, ins.IndustrySegmentId, ins.IndustrySegmentName,
   cu.IsDeleted as CustomerIsDeleted,pcu.IsDeleted as ParentCustomerIsDeleted,p.IsDeleted as ProjectIsDeleted
   into #tempHierarchy     
   FROM    MAS.Markets m (NOLOCK)     
   JOIN MAS.MarketUnits mu (NOLOCK) ON m.MarketID = mu.MarketID AND mu.IsDeleted = 0      
   JOIN MAS.BusinessUnits bu (NOLOCK) ON mu.MarketUnitID = bu.MarketUnitID AND bu.IsDeleted = 0      
   JOIN MAS.SubBusinessUnits1 sbu1 (NOLOCK) ON bu.BusinessUnitID = sbu1.BusinessUnitID AND sbu1.IsDeleted = 0      
   JOIN AVL.Customer cu (NOLOCK) ON cu.SBU1ID = sbu1.SBU1ID  
   JOIN MAS.Verticals v (NOLOCK) ON cu.VerticalID = v.VerticalID AND v.IsDeleted = 0      
   JOIN MAS.IndustrySegments ins (NOLOCK) ON ins.IndustrySegmentId = v.IndustrySegmentId AND ins.IsDeleted = 0      
   LEFT JOIN MAS.SubBusinessUnits2 sbu2 (NOLOCK) ON cu.SBU2ID = sbu2.SBU2ID AND sbu2.IsDeleted = 0                      
   LEFT JOIN MAS.ParentCustomers pcu (NOLOCK) ON cu.ParentCustomerID = pcu.ParentCustomerID    
   LEFT JOIN MAS.SubVerticals sv (NOLOCK) ON cu.SubVerticalID = sv.SubVerticalID AND sv.IsDeleted = 0      
   LEFT JOIN AVL.MAS_projectMaster p (NOLOCK) ON cu.CustomerID = p.CustomerID    
   LEFT JOIN MAS.ProjectPracticeMapping ppm (NOLOCK) ON p.ProjectID = ppm.ProjectID AND ppm.IsDeleted=0      
   LEFT JOIN MAS.Practices pc (NOLOCK) ON ppm.PracticeID = pc.PracticeID AND pc.IsDeleted = 0      
   WHERE M.IsDeleted = 0   
   
  
SELECT DISTINCT   
  rm.AssociateId  
  ,a.AssociateName,a.Email  
  ,g.GroupID,g.GroupName  
  ,rm.ApplensRoleID AS RoleID,ro.RoleName       
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
  ,qd.ProjectID,qd.ESAProjectID,qd.ProjectName  
  ,qd.PracticeID,qd.PracticeName  
  ,rm.DataSource,
  qd.CustomerIsDeleted,
  qd.ParentCustomerIsDeleted,
  qd.ProjectIsDeleted
FROM RLE.UserRoleMapping rm (NOLOCK)  
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID  
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0  
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0  
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0  
LEFT JOIN #tempHierarchy qd (NOLOCK) ON ISNULL(rd.MarketId, ISNULL(qd.MarketID,'')) = ISNULL(qd.MarketID,'')  
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
WHERE rm.IsDeleted = 0 AND rm.DataSource = 'RHMS'  
UNION  
SELECT DISTINCT  rm.AssociateId,a.AssociateName,a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID RoleId,ro.RoleName       
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
,COALESCE(m.ProjectID, mu.ProjectID, bu.ProjectID, sbu1.ProjectID, i.ProjectID, c.ProjectID, p.ProjectID) ProjectID  
,COALESCE(m.ESAProjectID, mu.ESAProjectID, bu.ESAProjectID, sbu1.ESAProjectID, i.ESAProjectID, c.ESAProjectID, p.ESAProjectID) ESAProjectID  
,COALESCE(m.ProjectName, mu.ProjectName, bu.ProjectName, sbu1.ProjectName, i.ProjectName, c.ProjectName, p.ProjectName) ProjectName  
,COALESCE(m.PracticeID, mu.PracticeID, bu.PracticeID, sbu1.PracticeID, i.PracticeID, c.PracticeID, p.PracticeID) PracticeID  
,COALESCE(m.PracticeName, mu.PracticeName, bu.PracticeName, sbu1.PracticeName, i.PracticeName, c.PracticeName, p.PracticeName) PracticeName   
,rm.DataSource ,
COALESCE(m.CustomerIsDeleted, mu.CustomerIsDeleted, bu.CustomerIsDeleted, sbu1.CustomerIsDeleted, i.CustomerIsDeleted, c.CustomerIsDeleted, p.CustomerIsDeleted) CustomerIsDeleted  ,
COALESCE(m.ParentCustomerIsDeleted, mu.ParentCustomerIsDeleted, bu.ParentCustomerIsDeleted, sbu1.ParentCustomerIsDeleted, i.ParentCustomerIsDeleted, c.ParentCustomerIsDeleted, p.ParentCustomerIsDeleted) ParentCustomerIsDeleted,
COALESCE(m.ProjectIsDeleted, mu.ProjectIsDeleted, bu.ProjectIsDeleted, sbu1.ProjectIsDeleted, i.ProjectIsDeleted, c.ProjectIsDeleted, p.ProjectIsDeleted) ProjectIsDeleted 

FROM RLE.UserRoleMapping rm (NOLOCK)  
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID  
LEFT JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0  
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0  
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0  
LEFT JOIN #tempHierarchy m (NOLOCK) ON rd.MarketId = m.MarketId    
LEFT JOIN #tempHierarchy mu (NOLOCK) ON rd.MarketUnitId = mu.MarketUnitId  
LEFT JOIN #tempHierarchy bu (NOLOCK) ON  rd.BusinessUnitID = bu.BusinessUnitID  
LEFT JOIN #tempHierarchy sbu1 (NOLOCK) ON rd.SBU1ID = sbu1.SBU1ID  
LEFT JOIN #tempHierarchy i (NOLOCK) ON rd.IndustrySegmentId = i.IndustrySegmentId  
LEFT JOIN #tempHierarchy c (NOLOCK) ON (rd.CustomerID = c.CustomerID)   
LEFT JOIN #tempHierarchy p (NOLOCK) ON (rd.ProjectID = p.ProjectID)   
WHERE rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')  
AND rd.PracticeId is null  
UNION  
SELECT  DISTINCT rm.AssociateId,a.AssociateName,a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID RoleId,ro.RoleName      
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
  ,pc.ProjectID,pc.ESAProjectID,pc.ProjectName  
  ,pc.PracticeID,pc.PracticeName    
  ,rm.DataSource,
  pc.CustomerIsDeleted,
  pc.ParentCustomerIsDeleted,
  pc.ProjectIsDeleted
FROM RLE.UserRoleMapping rm (NOLOCK)  
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID  
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0  
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0  
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0  
JOIN #tempHierarchy pc (NOLOCK) ON rd.PracticeID = pc.PracticeID   
WHERE rm.IsDeleted = 0 AND rm.DataSource = 'UI'  
AND rd.MarketID Is NULL AND rd.MarketUnitID IS NULL AND rd.BusinessUnitID IS NULL AND rd.SBU1ID IS NULL AND rd.SBU2ID IS NULL AND rd.IndustrySegmentId IS NULL  
AND rd.VerticalID IS NULL AND rd.SubVerticalID IS NULL AND rd.CustomerID IS NULL AND rd.ParentCustomerID IS NULL AND rd.ProjectID IS NULL  
AND rd.PracticeID IS NOT NULL  
UNION  
SELECT DISTINCT  rm.AssociateId,a.AssociateName,a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID RoleId,ro.RoleName  
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
  ,pc.ProjectID,pc.ESAProjectID,pc.ProjectName  
  ,pc.PracticeID,pc.PracticeName    
  ,rm.DataSource,
  pc.CustomerIsDeleted,
  pc.ParentCustomerIsDeleted,
  pc.ProjectIsDeleted
FROM RLE.UserRoleMapping rm (NOLOCK)  
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID  
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0  
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0  
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0  
JOIN #tempHierarchy pc (NOLOCK) ON rd.BusinessUnitID = pc.BusinessUnitID AND rd.PracticeID = pc.PracticeID   
WHERE rm.IsDeleted = 0 AND rm.DataSource = 'UI'  
AND rd.BusinessUnitID IS NOT NULL AND rd.PracticeID IS NOT NULL  
UNION  
SELECT  DISTINCT rm.AssociateId,a.AssociateName,a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID RoleId,ro.RoleName      
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
  ,pc.ProjectID,pc.ESAProjectID,pc.ProjectName  
  ,pc.PracticeID,pc.PracticeName    
  ,rm.DataSource,
  pc.CustomerIsDeleted,
  pc.ParentCustomerIsDeleted,
  pc.ProjectIsDeleted
FROM RLE.UserRoleMapping rm (NOLOCK)  
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID  
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0  
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0  
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0  
JOIN #tempHierarchy pc (NOLOCK) ON rd.CustomerID = pc.CustomerID AND rd.PracticeID = pc.PracticeID   
WHERE rm.IsDeleted = 0 AND rm.DataSource = 'UI'  
AND rd.CustomerID IS NOT NULL AND rd.PracticeID IS NOT NULL  
UNION  
SELECT  DISTINCT rm.AssociateId,a.AssociateName,a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID RoleId,ro.RoleName      
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
  ,pc.ProjectID,pc.ESAProjectID,pc.ProjectName  
  ,pc.PracticeID,pc.PracticeName    
  ,rm.DataSource,
  pc.CustomerIsDeleted,
  pc.ParentCustomerIsDeleted,
  pc.ProjectIsDeleted
FROM RLE.UserRoleMapping rm (NOLOCK)  
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID  
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0  
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0  
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0  
JOIN #tempHierarchy pc (NOLOCK) ON rd.ProjectID = pc.ProjectID AND rd.PracticeID = pc.PracticeID   
WHERE rm.IsDeleted = 0 AND rm.DataSource = 'UI'  
AND rd.ProjectID IS NOT NULL AND rd.PracticeID IS NOT NULL  
UNION  
SELECT DISTINCT   
  rm.AssociateId  
  ,a.AssociateName,a.Email  
  ,g.GroupID,g.GroupName  
  ,rm.ApplensRoleID AS RoleID,ro.RoleName       
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
  ,NULL ProjectID,NULL ESAProjectID,NULL ProjectName  
  ,NULL PracticeID,NULL PracticeName    
  ,rm.DataSource ,
  0 CustomerIsDeleted ,
  0 ParentCustomerIsDeleted,
  0 ProjectIsDeleted
FROM RLE.UserRoleMapping rm (NOLOCK)  
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID  
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0  
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0  
LEFT JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0  
WHERE rm.IsDeleted = 0 AND rm.DataSource = 'UI' AND rd.RoleMappingID IS NULL  
  
  
Drop table #tempHierarchy  
  
END