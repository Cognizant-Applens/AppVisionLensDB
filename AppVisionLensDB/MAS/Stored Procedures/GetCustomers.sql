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
-- Author:		Team SunRays
-- Create date: 09-25-2020
-- Description:	EXEC [MAS].[GetCustomers] 2 - Get all the Market Master details
-- =============================================

CREATE PROCEDURE [MAS].[GetCustomers] 
(
	@CustomerID INT = NULL,
	@ParentCustomerID INT = NULL,
	@SBU1ID INT = NULL,
	@SBU2ID INT = NULL,
	@VerticalID INT = NULL,
	@SubVerticalID INT = NULL
)
AS
BEGIN
		SET NOCOUNT ON

		SELECT	cu.CustomerID,cu.CustomerName,cu.ESA_AccountID ESACustomerID
				,pc.ParentCustomerID,pc.ParentCustomerName
				,sbu1.SBU1ID,sbu1.SBU1Name
				,sbu2.SBU2ID,sbu2.SBU2Name
				,v.VerticalID,v.VerticalName
				,sv.SubVerticalID,sv.SubVerticalName
				,ins.IndustrySegmentId, ins.IndustrySegmentName
		FROM	[AVL].[Customer] cu
				LEFT JOIN MAS.ParentCustomers pc ON pc.ParentCustomerID = cu.ParentCustomerID AND pc.IsDeleted = 0
				LEFT JOIN MAS.SubBusinessUnits1 sbu1 ON sbu1.SBU1ID = cu.SBU1ID AND sbu1.IsDeleted = 0
				LEFT JOIN MAS.SubBusinessUnits2 sbu2 on sbu2.SBU2ID = cu.SBU2ID AND sbu2.IsDeleted = 0
					 JOIN MAS.Verticals v ON v.VerticalID = cu.VerticalID AND v.IsDeleted = 0
				LEFT JOIN MAS.SubVerticals sv ON sv.SubVerticalID = cu.SubVerticalID AND sv.IsDeleted = 0
					 JOIN MAS.IndustrySegments ins on ins.IndustrySegmentId = v.IndustrySegmentId AND ins.IsDeleted = 0
		WHERE	cu.IsDeleted = 0
				AND (cu.CustomerID = ISNULL(@CustomerID,'')
				OR cu.ParentCustomerID = ISNULL(@ParentCustomerID,'')
				OR cu.SBU1ID = ISNULL(@SBU1ID,'')
				OR cu.SBU2ID = ISNULL(@SBU2ID,'')
				OR cu.VerticalID = ISNULL(@VerticalID,'')
				OR cu.SubVerticalID = ISNULL(@SubVerticalID,''))

END
