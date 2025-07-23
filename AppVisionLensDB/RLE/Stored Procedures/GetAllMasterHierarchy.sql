/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [RLE].[GetAllMasterHierarchy]
As	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	  
 SELECT DISTINCT m.MarketID, m.MarketName, mu.MarketUnitID, mu.MarketUnitName,       
   bu.BusinessUnitID, bu.BusinessUnitName,       
   sbu1.SBU1ID, sbu1.SBU1Name, sbu2.SBU2ID, sbu2.SBU2Name,      
   v.VerticalID, v.VerticalName,sv.SubVerticalID, sv.SubVerticalName,      
   pcu.ParentCustomerID, pcu.ParentCustomerName, cu.CustomerID, cu.CustomerName,      
   cu.ESA_AccountId ESACustomerID,pc.PracticeID,pc.PracticeName,      
   p.ProjectID, p.ProjectName, p.ESAProjectID, ins.IndustrySegmentId, ins.IndustrySegmentName,
   cu.IsDeleted as CustomerIsDeleted,pcu.IsDeleted as ParentCustomerIsDeleted,p.IsDeleted as ProjectIsDeleted
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
END