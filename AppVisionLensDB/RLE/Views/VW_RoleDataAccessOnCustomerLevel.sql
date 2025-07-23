


CREATE View [RLE].[VW_RoleDataAccessOnCustomerLevel]
AS
--RHMS Access
SELECT	DISTINCT 
		rm.AssociateId,a.AssociateName, a.Email, g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority],
		qd.CustomerID,qd.ESACustomerID,qd.CustomerName			
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
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
WHERE	rm.IsDeleted = 0 AND rm.DataSource = 'RHMS'
UNION
--Market access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]					
,m.CustomerID,m.ESACustomerID,m.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy m (NOLOCK) ON rd.MarketId = m.MarketId  
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--MarketUnit access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]					
,mu.CustomerID,mu.ESACustomerID,mu.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy mu (NOLOCK) ON rd.MarketUnitId = mu.MarketUnitId
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--BU access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]					
,bu.CustomerID,bu.ESACustomerID,bu.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy bu (NOLOCK) ON  rd.BusinessUnitID = bu.BusinessUnitID
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--Sbu1 access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]					
,sbu1.CustomerID,sbu1.ESACustomerID,sbu1.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy sbu1 (NOLOCK) ON rd.SBU1ID = sbu1.SBU1ID
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--Industry segment access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]					
,i.CustomerID,i.ESACustomerID,i.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy i (NOLOCK) ON rd.IndustrySegmentId = i.IndustrySegmentId
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--Customer access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]					
,c.CustomerID,c.ESACustomerID,c.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy c (NOLOCK) ON (rd.CustomerID = c.CustomerID) 
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--Project access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]					
,p.CustomerID,p.ESACustomerID,p.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy p (NOLOCK) ON (rd.ProjectID = p.ProjectID) 
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--practice access
SELECT	 DISTINCT rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]		
		,pc.CustomerID,pc.ESACustomerID,pc.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.PracticeID = pc.PracticeID 
WHERE	rm.IsDeleted = 0 AND rm.DataSource = 'UI'
AND rd.MarketID Is NULL AND rd.MarketUnitID IS NULL AND rd.BusinessUnitID IS NULL AND rd.SBU1ID IS NULL AND rd.SBU2ID IS NULL AND rd.IndustrySegmentId IS NULL
AND rd.VerticalID IS NULL AND rd.SubVerticalID IS NULL AND rd.CustomerID IS NULL AND rd.ParentCustomerID IS NULL AND rd.ProjectID IS NULL
AND rd.PracticeID IS NOT NULL
UNION
--BU access with practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]
		,pc.CustomerID,pc.ESACustomerID,pc.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.BusinessUnitID = pc.BusinessUnitID AND rd.PracticeID = pc.PracticeID 
WHERE	rm.IsDeleted = 0 AND rm.DataSource = 'UI'
AND rd.BusinessUnitID IS NOT NULL AND rd.PracticeID IS NOT NULL
UNION
--Customer access with practice
SELECT	 DISTINCT rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]				
		,pc.CustomerID,pc.ESACustomerID,pc.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.CustomerID = pc.CustomerID AND rd.PracticeID = pc.PracticeID 
WHERE	rm.IsDeleted = 0 AND rm.DataSource = 'UI'
AND rd.CustomerID IS NOT NULL AND rd.PracticeID IS NOT NULL
UNION
--Project access with practice
SELECT	 DISTINCT rm.AssociateId,a.AssociateName, a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]				
		,pc.CustomerID,pc.ESACustomerID,pc.CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.ProjectID = pc.ProjectID AND rd.PracticeID = pc.PracticeID 
WHERE	rm.IsDeleted = 0 AND rm.DataSource = 'UI'
AND rd.ProjectID IS NOT NULL AND rd.PracticeID IS NOT NULL
UNION
--Role access without data
SELECT	DISTINCT 
		rm.AssociateId,a.AssociateName, a.Email,g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]	
		,NULL CustomerID,NULL ESACustomerID,NULL CustomerName
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
LEFT JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
WHERE	rm.IsDeleted = 0 AND rm.DataSource = 'UI' AND rd.RoleMappingID IS NULL
