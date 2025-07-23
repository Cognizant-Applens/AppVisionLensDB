/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE View RLE.VW_RoleDataAccessWithAllHierarchy
AS
--RHMS Access
SELECT	DISTINCT rm.AssociateId,a.AssociateName,a.Email,g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]		
,qd.MarketID,qd.MarketName,qd.MarketUnitID,qd.MarketUnitName,qd.BusinessUnitID,qd.BusinessUnitName,qd.SBU1ID,qd.SBU1Name ,qd.SBU2ID,qd.SBU2Name 
,qd.IndustrySegmentId, qd.IndustrySegmentName,qd.VerticalID,qd.VerticalName,qd.SubVerticalID,qd.SubVerticalName
,qd.CustomerID,qd.ESACustomerID,qd.CustomerName,qd.ParentCustomerID,qd.ParentCustomerName,qd.ProjectID,qd.ESAProjectID,qd.ProjectName
,qd.PracticeID,qd.PracticeName,rm.DataSource				
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID
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
SELECT DISTINCT	 rm.AssociateId,a.AssociateName,a.Email,g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]		
,mh.MarketID,mh.MarketName,mh.MarketUnitID,mh.MarketUnitName,mh.BusinessUnitID,mh.BusinessUnitName,mh.SBU1ID,mh.SBU1Name ,mh.SBU2ID,mh.SBU2Name 
,mh.IndustrySegmentId, mh.IndustrySegmentName,mh.VerticalID,mh.VerticalName,mh.SubVerticalID,mh.SubVerticalName
,mh.CustomerID,mh.ESACustomerID,mh.CustomerName,mh.ParentCustomerID,mh.ParentCustomerName,mh.ProjectID,mh.ESAProjectID,mh.ProjectName
,mh.PracticeID,mh.PracticeName,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy mh (NOLOCK) ON rd.MarketId = mh.MarketId  
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--MarketUnit access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName,a.Email,g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]		
,mh.MarketID,mh.MarketName,mh.MarketUnitID,mh.MarketUnitName,mh.BusinessUnitID,mh.BusinessUnitName,mh.SBU1ID,mh.SBU1Name ,mh.SBU2ID,mh.SBU2Name 
,mh.IndustrySegmentId, mh.IndustrySegmentName,mh.VerticalID,mh.VerticalName,mh.SubVerticalID,mh.SubVerticalName
,mh.CustomerID,mh.ESACustomerID,mh.CustomerName,mh.ParentCustomerID,mh.ParentCustomerName,mh.ProjectID,mh.ESAProjectID,mh.ProjectName
,mh.PracticeID,mh.PracticeName,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy mh (NOLOCK) ON rd.MarketUnitId = mh.MarketUnitId
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--BU access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName,a.Email,g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]		
,mh.MarketID,mh.MarketName,mh.MarketUnitID,mh.MarketUnitName,mh.BusinessUnitID,mh.BusinessUnitName,mh.SBU1ID,mh.SBU1Name ,mh.SBU2ID,mh.SBU2Name 
,mh.IndustrySegmentId, mh.IndustrySegmentName,mh.VerticalID,mh.VerticalName,mh.SubVerticalID,mh.SubVerticalName
,mh.CustomerID,mh.ESACustomerID,mh.CustomerName,mh.ParentCustomerID,mh.ParentCustomerName,mh.ProjectID,mh.ESAProjectID,mh.ProjectName
,mh.PracticeID,mh.PracticeName,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy mh (NOLOCK) ON  rd.BusinessUnitID = mh.BusinessUnitID
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--SBU1 access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName,a.Email,g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]		
,mh.MarketID,mh.MarketName,mh.MarketUnitID,mh.MarketUnitName,mh.BusinessUnitID,mh.BusinessUnitName,mh.SBU1ID,mh.SBU1Name ,mh.SBU2ID,mh.SBU2Name 
,mh.IndustrySegmentId, mh.IndustrySegmentName,mh.VerticalID,mh.VerticalName,mh.SubVerticalID,mh.SubVerticalName
,mh.CustomerID,mh.ESACustomerID,mh.CustomerName,mh.ParentCustomerID,mh.ParentCustomerName,mh.ProjectID,mh.ESAProjectID,mh.ProjectName
,mh.PracticeID,mh.PracticeName,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy mh (NOLOCK) ON rd.SBU1ID = mh.SBU1ID
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--Industry segment access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName,a.Email,g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]		
,mh.MarketID,mh.MarketName,mh.MarketUnitID,mh.MarketUnitName,mh.BusinessUnitID,mh.BusinessUnitName,mh.SBU1ID,mh.SBU1Name ,mh.SBU2ID,mh.SBU2Name 
,mh.IndustrySegmentId, mh.IndustrySegmentName,mh.VerticalID,mh.VerticalName,mh.SubVerticalID,mh.SubVerticalName
,mh.CustomerID,mh.ESACustomerID,mh.CustomerName,mh.ParentCustomerID,mh.ParentCustomerName,mh.ProjectID,mh.ESAProjectID,mh.ProjectName
,mh.PracticeID,mh.PracticeName,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy mh (NOLOCK) ON rd.IndustrySegmentId = mh.IndustrySegmentId
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--Customer access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName,a.Email,g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]		
,mh.MarketID,mh.MarketName,mh.MarketUnitID,mh.MarketUnitName,mh.BusinessUnitID,mh.BusinessUnitName,mh.SBU1ID,mh.SBU1Name ,mh.SBU2ID,mh.SBU2Name 
,mh.IndustrySegmentId, mh.IndustrySegmentName,mh.VerticalID,mh.VerticalName,mh.SubVerticalID,mh.SubVerticalName
,mh.CustomerID,mh.ESACustomerID,mh.CustomerName,mh.ParentCustomerID,mh.ParentCustomerName,mh.ProjectID,mh.ESAProjectID,mh.ProjectName
,mh.PracticeID,mh.PracticeName,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy mh (NOLOCK) ON rd.CustomerID = mh.CustomerID 
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--Project access without practice
SELECT DISTINCT	 rm.AssociateId,a.AssociateName,a.Email,g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]		
,mh.MarketID,mh.MarketName,mh.MarketUnitID,mh.MarketUnitName,mh.BusinessUnitID,mh.BusinessUnitName,mh.SBU1ID,mh.SBU1Name ,mh.SBU2ID,mh.SBU2Name 
,mh.IndustrySegmentId, mh.IndustrySegmentName,mh.VerticalID,mh.VerticalName,mh.SubVerticalID,mh.SubVerticalName
,mh.CustomerID,mh.ESACustomerID,mh.CustomerName,mh.ParentCustomerID,mh.ParentCustomerName,mh.ProjectID,mh.ESAProjectID,mh.ProjectName
,mh.PracticeID,mh.PracticeName,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID AND a.IsActive = 1
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy mh (NOLOCK) ON (rd.ProjectID = mh.ProjectID) 
WHERE	rm.IsDeleted = 0 AND rm.DataSource IN ('UI', 'PP', 'ESA')
AND rd.PracticeId is null
UNION
--practice access
SELECT	 DISTINCT rm.AssociateId,a.AssociateName,a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]		
,pc.MarketID,pc.MarketName,pc.MarketUnitID,pc.MarketUnitName,pc.BusinessUnitID,pc.BusinessUnitName,pc.SBU1ID,pc.SBU1Name ,pc.SBU2ID,pc.SBU2Name 
,pc.IndustrySegmentId, pc.IndustrySegmentName,pc.VerticalID,pc.VerticalName,pc.SubVerticalID,pc.SubVerticalName
,pc.CustomerID,pc.ESACustomerID,pc.CustomerName,pc.ParentCustomerID,pc.ParentCustomerName,pc.ProjectID,pc.ESAProjectID,pc.ProjectName
,pc.PracticeID,pc.PracticeName,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID
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
SELECT DISTINCT	 rm.AssociateId,a.AssociateName,a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]
,pc.MarketID,pc.MarketName,pc.MarketUnitID,pc.MarketUnitName,pc.BusinessUnitID,pc.BusinessUnitName,pc.SBU1ID,pc.SBU1Name ,pc.SBU2ID,pc.SBU2Name 
,pc.IndustrySegmentId, pc.IndustrySegmentName,pc.VerticalID,pc.VerticalName,pc.SubVerticalID,pc.SubVerticalName
,pc.CustomerID,pc.ESACustomerID,pc.CustomerName,pc.ParentCustomerID,pc.ParentCustomerName,pc.ProjectID,pc.ESAProjectID,pc.ProjectName
,pc.PracticeID,pc.PracticeName,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.BusinessUnitID = pc.BusinessUnitID AND rd.PracticeID = pc.PracticeID 
WHERE	rm.IsDeleted = 0 AND rm.DataSource = 'UI'
AND rd.BusinessUnitID IS NOT NULL AND rd.PracticeID IS NOT NULL
UNION
--Customer access with practice
SELECT	 DISTINCT rm.AssociateId,a.AssociateName,a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]				
,pc.MarketID,pc.MarketName,pc.MarketUnitID,pc.MarketUnitName,pc.BusinessUnitID,pc.BusinessUnitName,pc.SBU1ID,pc.SBU1Name,pc.SBU2ID,pc.SBU2Name 
,pc.IndustrySegmentId, pc.IndustrySegmentName,pc.VerticalID,pc.VerticalName,pc.SubVerticalID,pc.SubVerticalName
,pc.CustomerID,pc.ESACustomerID,pc.CustomerName,pc.ParentCustomerID,pc.ParentCustomerName,pc.ProjectID,pc.ESAProjectID,pc.ProjectName
,pc.PracticeID,pc.PracticeName ,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.CustomerID = pc.CustomerID AND rd.PracticeID = pc.PracticeID 
WHERE	rm.IsDeleted = 0 AND rm.DataSource = 'UI'
AND rd.CustomerID IS NOT NULL AND rd.PracticeID IS NOT NULL
UNION
--Project access with practice
SELECT	 DISTINCT rm.AssociateId,a.AssociateName,a.Email,rm.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]				
,pc.MarketID,pc.MarketName,pc.MarketUnitID,pc.MarketUnitName,pc.BusinessUnitID,pc.BusinessUnitName,pc.SBU1ID,pc.SBU1Name ,pc.SBU2ID,pc.SBU2Name 
,pc.IndustrySegmentId, pc.IndustrySegmentName,pc.VerticalID,pc.VerticalName,pc.SubVerticalID,pc.SubVerticalName
,pc.CustomerID,pc.ESACustomerID,pc.CustomerName,pc.ParentCustomerID,pc.ParentCustomerName,pc.ProjectID,pc.ESAProjectID,pc.ProjectName
,pc.PracticeID,pc.PracticeName,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID
JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
JOIN RLE.MasterHierarchy pc (NOLOCK) ON rd.ProjectID = pc.ProjectID AND rd.PracticeID = pc.PracticeID 
WHERE	rm.IsDeleted = 0 AND rm.DataSource = 'UI'
AND rd.ProjectID IS NOT NULL AND rd.PracticeID IS NOT NULL
UNION
--Role access without data
SELECT	DISTINCT rm.AssociateId,a.AssociateName,a.Email,g.GroupID,g.GroupName,rm.ApplensRoleID,ro.RoleName, ro.RoleKey, ro.[Priority]	
,NULL MarketID,NULL MarketName,NULL MarketUnitID,NULL MarketUnitName,NULL BusinessUnitID,NULL BusinessUnitName,NULL SBU1ID,NULL SBU1Name 
,NULL SBU2ID,NULL SBU2Name,NULL IndustrySegmentId, NULL IndustrySegmentName,NULL VerticalID,NULL VerticalName,NULL SubVerticalID,NULL SubVerticalName
,NULL CustomerID,NULL ESACustomerID,NULL CustomerName,NULL ParentCustomerID,NULL ParentCustomerName,NULL ProjectID,NULL ESAProjectID,NULL ProjectName
,NULL PracticeID,NULL PracticeName ,rm.DataSource
FROM	RLE.UserRoleMapping rm (NOLOCK)
JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID
JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
JOIN MAS.RLE_Groups g (NOLOCK) ON g.GroupID = rm.GroupID AND g.IsDeleted = 0
LEFT JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
WHERE	rm.IsDeleted = 0 AND rm.DataSource = 'UI' AND rd.RoleMappingID IS NULL
