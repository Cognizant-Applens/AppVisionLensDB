/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[dbo].[GetHierarchyData] 'GetHierarchy',105
CREATE PROCEDURE [dbo].[GetHierarchyData]
@Mode VARCHAR(50)=NULL,
@CustomerId BIGINT=NULL

AS  
BEGIN
BEGIN TRY
SET NOCOUNT ON

declare @HCount int
set @HCount=(select count(*) from AVL.BusinessCluster where CustomerID=@CustomerId and IsDeleted=0)

IF @Mode='GetHierarchyCount'
BEGIN
set @HCount=(select count(*) from AVL.BusinessCluster where CustomerID=@CustomerId and IsDeleted=0)
select @HCount
END

ELSE IF(@Mode='GetHierarchy')
BEGIN
IF @HCount=3

select b1.BusinessClusterBaseName as BusinessClusterBaseName1,b1.BusinessClusterMapID as BusinessClusterBaseId1, b2.BusinessClusterBaseName as BusinessClusterBaseName2,b2.BusinessClusterMapID as BusinessClusterBaseId2,
b3.BusinessClusterBaseName as BusinessClusterBaseName3,b3.BusinessClusterMapID as BusinessClusterBaseId3
from AVL.BusinessClusterMapping b1,AVL.BusinessClusterMapping b2,AVL.BusinessClusterMapping b3
WHERE b1.BusinessClusterMapID=b2.ParentBusinessClusterMapID and
b2.BusinessClusterMapID=b3.ParentBusinessClusterMapID and
b1.CustomerID=@CustomerId
and b1.IsDeleted=0 and b2.IsDeleted=0 and b3.IsDeleted=0 

ELSE IF @HCount=4
select b1.BusinessClusterBaseName as BusinessClusterBaseName1,b1.BusinessClusterMapID as BusinessClusterBaseId1, b2.BusinessClusterBaseName as BusinessClusterBaseName2,b2.BusinessClusterMapID as BusinessClusterBaseId2, b3.BusinessClusterBaseName as BusinessClusterBaseName3,b3.BusinessClusterMapID as BusinessClusterBaseId3,
b4.BusinessClusterBaseName as BusinessClusterBaseName4,b4.BusinessClusterMapID as BusinessClusterBaseId4
from AVL.BusinessClusterMapping b1,AVL.BusinessClusterMapping b2,AVL.BusinessClusterMapping b3,AVL.BusinessClusterMapping b4
WHERE b1.BusinessClusterMapID=b2.ParentBusinessClusterMapID and
b2.BusinessClusterMapID=b3.ParentBusinessClusterMapID and b3.BusinessClusterMapID=b4.ParentBusinessClusterMapID and
b1.CustomerID=@CustomerId
and b1.IsDeleted=0 and b2.IsDeleted=0 and b3.IsDeleted=0 and b4.IsDeleted=0 
ELSE IF @HCount=5
select b1.BusinessClusterBaseName as BusinessClusterBaseName1,b1.BusinessClusterMapID as BusinessClusterBaseId1, b2.BusinessClusterBaseName as BusinessClusterBaseName2,b2.BusinessClusterMapID as BusinessClusterBaseId2, b3.BusinessClusterBaseName as BusinessClusterBaseName3,b3.BusinessClusterMapID as BusinessClusterBaseId3,
b4.BusinessClusterBaseName as BusinessClusterBaseName4,b4.BusinessClusterMapID as BusinessClusterBaseId4,
b5.BusinessClusterBaseName as BusinessClusterBaseName5,b5.BusinessClusterMapID as BusinessClusterBaseId5  from AVL.BusinessClusterMapping b1,AVL.BusinessClusterMapping b2,AVL.BusinessClusterMapping b3,AVL.BusinessClusterMapping b4
,AVL.BusinessClusterMapping b5 WHERE b1.BusinessClusterMapID=b2.ParentBusinessClusterMapID and
b2.BusinessClusterMapID=b3.ParentBusinessClusterMapID and 
b3.BusinessClusterMapID=b4.ParentBusinessClusterMapID and
b4.BusinessClusterMapID=b5.ParentBusinessClusterMapID and b1.CustomerID=@CustomerId
and b1.IsDeleted=0 and b2.IsDeleted=0 and b3.IsDeleted=0 and b4.IsDeleted=0 and b5.IsDeleted=0 
ELSE IF @HCount=6
select b1.BusinessClusterBaseName as BusinessClusterBaseName1,b1.BusinessClusterMapID as BusinessClusterBaseId1,b2.BusinessClusterBaseName as BusinessClusterBaseName2,b2.BusinessClusterMapID as BusinessClusterBaseId2,b3.BusinessClusterBaseName as BusinessClusterBaseName3,b3.BusinessClusterMapID as BusinessClusterBaseId3,b4.BusinessClusterBaseName as BusinessClusterBaseName4,b4.BusinessClusterMapID as BusinessClusterBaseId4,
b5.BusinessClusterBaseName as BusinessClusterBaseName5,b5.BusinessClusterMapID as BusinessClusterBaseId5,b6.BusinessClusterBaseName as BusinessClusterBaseName6,b6.BusinessClusterMapID as BusinessClusterBaseId6 from AVL.BusinessClusterMapping b1,AVL.BusinessClusterMapping b2,AVL.BusinessClusterMapping b3,AVL.BusinessClusterMapping b4,AVL.BusinessClusterMapping b5,AVL.BusinessClusterMapping b6 WHERE b1.BusinessClusterMapID=b2.ParentBusinessClusterMapID and
b2.BusinessClusterMapID=b3.ParentBusinessClusterMapID and b3.BusinessClusterMapID=b4.ParentBusinessClusterMapID and
b4.BusinessClusterMapID=b5.ParentBusinessClusterMapID and b5.BusinessClusterMapID=b6.ParentBusinessClusterMapID AND
b1.CustomerID=@CustomerId 
and b1.IsDeleted=0 and b2.IsDeleted=0 and b3.IsDeleted=0 and b4.IsDeleted=0 and b5.IsDeleted=0 and b6.IsDeleted=0
END
print @HCount
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		
	END CATCH  
END


select * from AVL.BusinessClusterMapping
