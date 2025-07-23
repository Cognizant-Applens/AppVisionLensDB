/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetRHMSHierarchyData]
@EmployeeID VARCHAR(50)=NULL,
@CustomerId BIGINT=NULL

AS  
BEGIN
BEGIN TRY
SET NOCOUNT ON

declare @HCount int
set @HCount=(select count(*) from AVL.BusinessCluster where CustomerID=@CustomerId and IsDeleted=0)

IF @HCount=3

select b1.BusinessClusterBaseName as Hierarchy1Name,b1.BusinessClusterMapID as Hierarchy1ID, b2.BusinessClusterBaseName as Hierarchy2Name,b2.BusinessClusterMapID as Hierarchy2ID,
b3.BusinessClusterBaseName as Hierarchy3Name,b3.BusinessClusterMapID as Hierarchy3ID,
'' as Hierarchy4Name,0 as Hierarchy4ID,
'' as Hierarchy5Name,0 as Hierarchy5ID,'' as Hierarchy6Name,0 as Hierarchy6ID,
CASE WHEN ESCM.SubClusterId IS NULL THEN 0 ELSE 1 END AS IsChecked
from AVL.BusinessClusterMapping b1 With (NOLOCK),AVL.BusinessClusterMapping b2 With (NOLOCK),AVL.BusinessClusterMapping b3 With (NOLOCK)
left JOIN AVL.EmployeeSubClusterMapping ESCM (NOLOCK) ON ESCM.CustomerID=@CustomerId and ESCM.EmployeeID=@EmployeeID
AND ESCM.SubClusterId=b3.BusinessClusterMapID
WHERE b1.BusinessClusterMapID=b2.ParentBusinessClusterMapID and
b2.BusinessClusterMapID=b3.ParentBusinessClusterMapID and
b1.CustomerID=@CustomerId
and b1.IsDeleted=0 and b2.IsDeleted=0 and b3.IsDeleted=0 

ELSE IF @HCount=4
select b1.BusinessClusterBaseName as Hierarchy1Name,b1.BusinessClusterMapID as Hierarchy1ID, b2.BusinessClusterBaseName as Hierarchy2Name,b2.BusinessClusterMapID as Hierarchy2ID, b3.BusinessClusterBaseName as Hierarchy3Name,b3.BusinessClusterMapID as Hierarchy3ID,
b4.BusinessClusterBaseName as Hierarchy4Name,b4.BusinessClusterMapID as Hierarchy4ID,
'' as Hierarchy5Name,0 as Hierarchy5ID,'' as Hierarchy6Name,0 as Hierarchy6ID,
CASE WHEN ESCM.SubClusterId IS NULL THEN 0 ELSE 1 END AS IsChecked
from AVL.BusinessClusterMapping b1 With (NOLOCK),AVL.BusinessClusterMapping b2 With (NOLOCK),AVL.BusinessClusterMapping b3 With (NOLOCK),AVL.BusinessClusterMapping b4 With (NOLOCK)
left JOIN AVL.EmployeeSubClusterMapping ESCM (NOLOCK) ON ESCM.CustomerID=@CustomerId and ESCM.EmployeeID=@EmployeeID
AND ESCM.SubClusterId=b4.BusinessClusterMapID
WHERE b1.BusinessClusterMapID=b2.ParentBusinessClusterMapID and
b2.BusinessClusterMapID=b3.ParentBusinessClusterMapID and b3.BusinessClusterMapID=b4.ParentBusinessClusterMapID and
b1.CustomerID=@CustomerId
and b1.IsDeleted=0 and b2.IsDeleted=0 and b3.IsDeleted=0 and b4.IsDeleted=0 
ELSE IF @HCount=5
select b1.BusinessClusterBaseName as Hierarchy1Name,b1.BusinessClusterMapID as Hierarchy1ID, b2.BusinessClusterBaseName as Hierarchy2Name,b2.BusinessClusterMapID as Hierarchy2ID, b3.BusinessClusterBaseName as Hierarchy3Name,b3.BusinessClusterMapID as Hierarchy3ID,
b4.BusinessClusterBaseName as Hierarchy4Name,b4.BusinessClusterMapID as Hierarchy4ID,
b5.BusinessClusterBaseName as Hierarchy5Name,b5.BusinessClusterMapID as Hierarchy5ID,
'' as Hierarchy6Name,0 as Hierarchy6ID,
CASE WHEN ESCM.SubClusterId IS NULL THEN 0 ELSE 1 END AS IsChecked
  from AVL.BusinessClusterMapping b1 With (NOLOCK),AVL.BusinessClusterMapping b2 With (NOLOCK),AVL.BusinessClusterMapping b3 With (NOLOCK),AVL.BusinessClusterMapping b4 With (NOLOCK)
,AVL.BusinessClusterMapping b5 
left JOIN AVL.EmployeeSubClusterMapping ESCM (NOLOCK) ON ESCM.CustomerID=@CustomerId and ESCM.EmployeeID=@EmployeeID
AND ESCM.SubClusterId=b5.BusinessClusterMapID
WHERE b1.BusinessClusterMapID=b2.ParentBusinessClusterMapID and
b2.BusinessClusterMapID=b3.ParentBusinessClusterMapID and 
b3.BusinessClusterMapID=b4.ParentBusinessClusterMapID and
b4.BusinessClusterMapID=b5.ParentBusinessClusterMapID and b1.CustomerID=@CustomerId
and b1.IsDeleted=0 and b2.IsDeleted=0 and b3.IsDeleted=0 and b4.IsDeleted=0 and b5.IsDeleted=0 
ELSE IF @HCount=6
select b1.BusinessClusterBaseName as Hierarchy1Name,b1.BusinessClusterMapID as Hierarchy1ID,b2.BusinessClusterBaseName as Hierarchy2Name,b2.BusinessClusterMapID as Hierarchy2ID,b3.BusinessClusterBaseName as Hierarchy3Name,b3.BusinessClusterMapID as Hierarchy3ID,
b4.BusinessClusterBaseName as Hierarchy4Name,b4.BusinessClusterMapID as Hierarchy4ID,
b5.BusinessClusterBaseName as Hierarchy5Name,b5.BusinessClusterMapID as Hierarchy5ID,b6.BusinessClusterBaseName as Hierarchy6Name,b6.BusinessClusterMapID as Hierarchy6ID
,CASE WHEN ESCM.SubClusterId IS NULL THEN 0 ELSE 1 END AS IsChecked
from AVL.BusinessClusterMapping b1 With (NOLOCK),AVL.BusinessClusterMapping b2 With (NOLOCK),AVL.BusinessClusterMapping b3 With (NOLOCK),AVL.BusinessClusterMapping b4 With (NOLOCK),AVL.BusinessClusterMapping b5 With (NOLOCK),AVL.BusinessClusterMapping b6 With (NOLOCK) 
left JOIN AVL.EmployeeSubClusterMapping ESCM (NOLOCK) ON ESCM.CustomerID=@CustomerId and ESCM.EmployeeID=@EmployeeID
AND ESCM.SubClusterId=b6.BusinessClusterMapID
WHERE b1.BusinessClusterMapID=b2.ParentBusinessClusterMapID and
b2.BusinessClusterMapID=b3.ParentBusinessClusterMapID and b3.BusinessClusterMapID=b4.ParentBusinessClusterMapID and
b4.BusinessClusterMapID=b5.ParentBusinessClusterMapID and b5.BusinessClusterMapID=b6.ParentBusinessClusterMapID AND
b1.CustomerID=@CustomerId 
and b1.IsDeleted=0 and b2.IsDeleted=0 and b3.IsDeleted=0 and b4.IsDeleted=0 and b5.IsDeleted=0 and b6.IsDeleted=0
SET NOCOUNT OFF
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		 EXEC AVL_InsertError '[AVL].[GetRHMSHierarchyData]', @ErrorMessage,0    
	END CATCH  
END
