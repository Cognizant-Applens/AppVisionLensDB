/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/*DECLARE @RoleKeys AS [RLE].[StringList]
DECLARE @EsaProjectIds AS  [RLE].[StringList]
INSERT INTO @RoleKeys VALUES ( 'RLE009')
INSERT INTO @EsaProjectIds VALUES ( '1000279125')
INSERT INTO @EsaProjectIds VALUES ( '1000086888')
EXECUTE [RLE].[GetMultipleLevelAccessDetailByProjectAndRole] @RoleKeys, @EsaProjectIds*/
CREATE PROCEDURE [RLE].[GetMultipleLevelAccessDetailByProjectAndRole]
@RoleKeys [RLE].[StringList] READONLY,
@EsaProjectIds [RLE].[StringList] READONLY
AS
BEGIN
	
	WITH Projects as (
	SELECT DISTINCT ProjectID, ESAProjectID, ProjectName FROM RLE.MasterHierarchy mh (NOLOCK)
	JOIN @EsaProjectIds ep on mh.EsaProjectId = ep.[Value])
	SELECT	DISTINCT RTRIM(LTRIM(rm.AssociateId)) AssociateId,RTRIM(LTRIM(a.AssociateName)) AssociateName,RTRIM(LTRIM(a.Email)) Email,
	p.ProjectID,RTRIM(LTRIM(p.ESAProjectID)) ESAProjectID,RTRIM(LTRIM(p.ProjectName)) ProjectName, ro.ApplensRoleID,
	RTRIM(LTRIM(ro.RoleKey)) RoleKey, RTRIM(LTRIM(Ro.RoleName)) RoleName,
	rd.DataSource,MIN(COALESCE(rd.ModifiedDate, rd.CreatedDate)) LastUpdatedDate
	FROM	RLE.UserRoleMapping rm (NOLOCK)
	JOIN ESA.Associates a (NOLOCK) ON a.AssociateID = rm.AssociateID
	JOIN RLE.UserRoleDataAccess rd (NOLOCK) ON rd.RoleMappingID = rm.RoleMappingID AND rd.IsDeleted = 0
	JOIN MAS.RLE_Roles ro (NOLOCK) ON ro.ApplensRoleID = rm.ApplensRoleID AND ro.IsDeleted = 0
	JOIN @RoleKeys rk ON ro.RoleKey = rk.[Value]
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
	JOIN Projects p on qd.ProjectId = p.ProjectId
	WHERE	rm.IsDeleted = 0
	GROUP BY rm.AssociateId,a.AssociateName,a.Email,p.ProjectID,p.ESAProjectID,p.ProjectName, ro.ApplensRoleID, ro.RoleKey, Ro.RoleName,rd.DataSource
END
