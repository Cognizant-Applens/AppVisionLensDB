/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [AVL].[APP_INV_SaveHierarchyTreeInsertAndUpdate] 
@treeTable TreeNodes READONLY,
@CustomerID bigint
AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION
DECLARE @outputTbl TABLE (ID int,OrgID nvarchar(300))	

	SET NOCOUNT ON;



	DECLARE @Hierarchy1 AS TABLE
(
	
	HierarchyValue			nVARCHAR(250),
	HierarchyName			nVARCHAR(100),	
	ClusterID				BIGINT,
	CognizantId				[nvarchar](200),
	TreeID					[nvarchar](200),
	NodeParent			[nvarchar](200)
)

DECLARE @Hierarchy2 AS TABLE
(
	
	HierarchyValue			nVARCHAR(250),
	HierarchyName			nVARCHAR(100),
	HierarchyParentName		nVARCHAR(100),
	ClusterID				BIGINT ,
	BusinessClusterMapID	BIGINT,
	CognizantId				[nvarchar](200),
	TreeID					[nvarchar](200),
	NodeParent			[nvarchar](200)
)

DECLARE @Hierarchy3 AS TABLE
(
	
	HierarchyValue		nVARCHAR(250),
	HierarchyName		nVARCHAR(100),
	HierarchyParentName	nVARCHAR(100),
	ClusterID		BIGINT ,
	BusinessClusterMapID	BIGINT,
	CognizantId				[nvarchar](200),
	TreeID				[nvarchar](200),
	NodeParent			[nvarchar](200)
)

DECLARE @Hierarchy4 AS TABLE
(
	
	HierarchyValue		nVARCHAR(250),
	HierarchyName		nVARCHAR(100),
	HierarchyParentName	nVARCHAR(100),
	ClusterID		BIGINT ,
	BusinessClusterMapID	BIGINT,
	CognizantId				[nvarchar](200),
	TreeID			[nvarchar](200),
	NodeParent			[nvarchar](200)
)

DECLARE @Hierarchy5 AS TABLE
(
	
	HierarchyValue		nVARCHAR(250),
	HierarchyName		nVARCHAR(100),
	HierarchyParentName	nVARCHAR(100),
	ClusterID		BIGINT ,
	BusinessClusterMapID	BIGINT,
	CognizantId				[nvarchar](200),
	TreeID			[nvarchar](200),
	NodeParent			[nvarchar](200)
)

DECLARE @Hierarchy6 AS TABLE
(
	
	HierarchyValue		nVARCHAR(250),
	HierarchyName		nVARCHAR(100),
	HierarchyParentName	nVARCHAR(100),
	ClusterID		BIGINT ,
	BusinessClusterMapID	BIGINT,
	CognizantId				[nvarchar](200),
	TreeID			[nvarchar](200),
	NodeParent			[nvarchar](200)
)

DECLARE @Hierarchy1Count BIGINT
DECLARE @Hierarchy2Count BIGINT
DECLARE @Hierarchy3Count BIGINT
DECLARE @Hierarchy4Count BIGINT
DECLARE @Hierarchy5Count BIGINT
DECLARE @Hierarchy6Count BIGINT


DECLARE @Hierarchy1ClusterID BIGINT
DECLARE @Hierarchy2ClusterID BIGINT
DECLARE @Hierarchy3ClusterID BIGINT
DECLARE @Hierarchy4ClusterID BIGINT
DECLARE @Hierarchy5ClusterID BIGINT
DECLARE @Hierarchy6ClusterID BIGINT


 SELECT * INTO #TreeNodes FROM @treeTable   

SELECT @Hierarchy1Count = COUNT(DISTINCT Title) FROM #TreeNodes WHERE [level]=1 

SELECT @Hierarchy2Count = COUNT(DISTINCT Title) FROM #TreeNodes WHERE [level]=2

SELECT @Hierarchy3Count = COUNT(DISTINCT Title) FROM #TreeNodes WHERE [level]=3

SELECT @Hierarchy4Count = COUNT(DISTINCT Title) FROM #TreeNodes WHERE [level]=4

SELECT @Hierarchy5Count = COUNT(DISTINCT Title) FROM #TreeNodes WHERE [level]=5

SELECT @Hierarchy6Count = COUNT(DISTINCT Title) FROM #TreeNodes WHERE [level]=6

INSERT INTO
	@Hierarchy1
SELECT 
	DISTINCT Title, 'H1-' + CONVERT(VARCHAR(10),ID), NULL,UserName,ID,Parent
FROM 
	#TreeNodes 
CROSS APPLY
	dbo.NumbersTable(1,(@Hierarchy1Count),1) WHERE [level]=1



	SELECT @Hierarchy2Count = COUNT(DISTINCT Title) FROM #TreeNodes WHERE [level]=2

INSERT INTO
	@Hierarchy2
SELECT 
	DISTINCT Title, 'H2-' + CONVERT(VARCHAR(10),ID), H1.HierarchyValue, NULL, NULL,UserName,ID,Parent
FROM 
	#TreeNodes
INNER JOIN
	@Hierarchy1 H1 ON H1.TreeID = Parent
CROSS APPLY
	dbo.NumbersTable(1,(@Hierarchy2Count),1) WHERE [level]=2



	SELECT @Hierarchy3Count = COUNT(DISTINCT Title) FROM #TreeNodes

INSERT INTO
	@Hierarchy3
SELECT 
	DISTINCT Title, 'H3-' + CONVERT(VARCHAR(10),ID), H2.HierarchyValue, NULL, NULL,UserName,ID,Parent
FROM 
	#TreeNodes
INNER JOIN
	@Hierarchy2 H2 ON H2.TreeID = Parent
CROSS APPLY
	dbo.NumbersTable(1,(@Hierarchy3Count),1) WHERE [level]=3


	SELECT @Hierarchy4Count = COUNT(DISTINCT Title) FROM #TreeNodes

INSERT INTO
	@Hierarchy4
SELECT 
	DISTINCT Title, 'H4-' + CONVERT(VARCHAR(10),ID), H3.HierarchyValue, NULL, NULL,UserName,ID,Parent
FROM 
	#TreeNodes
INNER JOIN
	@Hierarchy3 H3 ON H3.TreeID = Parent
CROSS APPLY
	dbo.NumbersTable(1,(@Hierarchy4Count),1) WHERE [level]=4


SELECT @Hierarchy5Count = COUNT(DISTINCT Title) FROM #TreeNodes

INSERT INTO
	@Hierarchy5
SELECT 
	DISTINCT Title, 'H5-' + CONVERT(VARCHAR(10),ID), H4.HierarchyValue, NULL, NULL,UserName,ID,Parent
FROM 
	#TreeNodes
INNER JOIN
	@Hierarchy4 H4 ON H4.TreeID = Parent
CROSS APPLY
	dbo.NumbersTable(1,(@Hierarchy5Count),1) WHERE [level]=5


	SELECT @Hierarchy6Count = COUNT(DISTINCT Title) FROM #TreeNodes


INSERT INTO
	@Hierarchy6
SELECT 
	DISTINCT Title, 'H6-' + CONVERT(VARCHAR(10),ID), H5.HierarchyValue, NULL, NULL,UserName,ID,Parent
FROM 
	#TreeNodes
INNER JOIN
	@Hierarchy5 H5 ON  H5.TreeID = Parent
CROSS APPLY
	dbo.NumbersTable(1,(@Hierarchy6Count),1) WHERE [level]=6


	SELECT 
	@Hierarchy1ClusterID = BusinessClusterID 
FROM 
	AVL.BusinessCluster 
WHERE 
	CustomerID = @CustomerID AND ParentBusinessClusterID IS NULL AND IsDeleted=0

	UPDATE
	@Hierarchy1
SET
	ClusterID = @Hierarchy1ClusterID	

SELECT 
	@Hierarchy2ClusterID = BusinessClusterID 
FROM 
	AVL.BusinessCluster 
WHERE 
	ParentBusinessClusterID = @Hierarchy1ClusterID AND IsDeleted=0

	UPDATE
	@Hierarchy2
SET
	ClusterID = @Hierarchy2ClusterID		

SELECT 
	@Hierarchy3ClusterID = BusinessClusterID 
FROM 
	AVL.BusinessCluster 
WHERE 
	ParentBusinessClusterID = @Hierarchy2ClusterID AND IsDeleted=0

	UPDATE
	@Hierarchy3
SET
	ClusterID = @Hierarchy3ClusterID		

SELECT 
	@Hierarchy4ClusterID = BusinessClusterID 
FROM 
	AVL.BusinessCluster 
WHERE 
	ParentBusinessClusterID = @Hierarchy3ClusterID AND IsDeleted=0
	
UPDATE
	@Hierarchy4
SET
	ClusterID = @Hierarchy4ClusterID	

	SELECT 
	@Hierarchy5ClusterID = BusinessClusterID 
FROM 
	AVL.BusinessCluster 
WHERE 
	ParentBusinessClusterID = @Hierarchy4ClusterID AND IsDeleted=0
	
UPDATE
	@Hierarchy5
SET
	ClusterID = @Hierarchy5ClusterID

SELECT 
	@Hierarchy6ClusterID = BusinessClusterID 
FROM 
	AVL.BusinessCluster 
WHERE 
	ParentBusinessClusterID = @Hierarchy5ClusterID AND IsDeleted=0
	
UPDATE
	@Hierarchy6
SET
	ClusterID = @Hierarchy6ClusterID



UPDATE 
	AVL.BusinessClusterMapping 
SET
	IsDeleted=1
WHERE
	CAST(BusinessClusterMapID AS NVARCHAR(MAX)) NOT IN (SELECT ID FROM #TreeNodes)
	AND CustomerID=@CustomerID


		/***PROGRESS****/
IF EXISTS(
			SELECT 
					1 
			FROM 
					AVL.PRJ_ConfigurationProgress 
			WHERE 
					ScreenID=1 AND CustomerID=@CustomerID)
BEGIN
IF NOT EXISTS(SELECT 1 FROM AVL.BusinessClusterMapping where CustomerID=@CustomerID AND IsDeleted=0)
	BEGIN
	DECLARE @CogID nvarchar(100);
	SELECT TOP 1 @CogID=H1.CognizantID from  @Hierarchy1 H1;
	UPDATE AVL.PRJ_ConfigurationProgress SET CompletionPercentage=50,
	ModifiedBy=@CogID,
	ModifiedDate=GETDATE()
	WHERE CustomerID=@CustomerID AND ScreenID=1
	END
	END
/***PROGRESS****/		


MERGE 
	AVL.BusinessClusterMapping BCM              
USING 
	@Hierarchy1 H1 ON H1.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID=@CustomerID AND H1.TreeID = CONVERT(NVARCHAR(200),bcm.BusinessClusterMapID)
WHEN MATCHED THEN              
UPDATE SET 
	BCM.BusinessClusterBaseName=H1.HierarchyValue, 
	BCM.BusinessClusterID=H1.ClusterID,
	BCM.ModifiedBy=H1.CognizantId,
	BCM.ModifiedDate=GETDATE()
WHEN NOT MATCHED THEN
	INSERT (BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)
	VALUES (H1.HierarchyValue, H1.ClusterID, NULL, 1, 0, @CustomerID,H1.CognizantId, GETDATE())
	OUTPUT  Inserted.BusinessClusterMapID,H1.TreeID INTO @outputTbl; 

UPDATE
	H2
SET
	H2.BusinessClusterMapID = H1.ID
FROM
	@Hierarchy2 H2
INNER JOIN
	@outputTbl H1 ON H1.OrgID = H2.NodeParent 

DELETE  FROM @outputTbl

MERGE 
	AVL.BusinessClusterMapping BCM              
USING 
	@Hierarchy2 H2 ON  H2.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID=@CustomerID AND H2.TreeID = CONVERT(NVARCHAR(200),bcm.BusinessClusterMapID)
WHEN MATCHED THEN              
UPDATE SET 
	BCM.BusinessClusterBaseName=H2.HierarchyValue, 
	BCM.BusinessClusterID=H2.ClusterID,
	BCM.ModifiedBy=H2.CognizantId,
	BCM.ModifiedDate=GETDATE(),
	BCM.ParentBusinessClusterMapID=H2.BusinessClusterMapID
WHEN NOT MATCHED THEN
	INSERT (BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)
	VALUES (H2.HierarchyValue, H2.ClusterID, BusinessClusterMapID, 1, 0, @CustomerID, H2.CognizantId, GETDATE())
OUTPUT Inserted.BusinessClusterMapID,H2.TreeID INTO @outputTbl; 


UPDATE
	H3
SET
	H3.BusinessClusterMapID = H2.ID
FROM
	@Hierarchy3 H3
INNER JOIN
	@outputTbl H2 ON H2.OrgID = H3.NodeParent 
	
DELETE  FROM @outputTbl

MERGE 
	AVL.BusinessClusterMapping BCM              
USING 
	@Hierarchy3 H3 ON H3.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID=@CustomerID AND H3.TreeID = CONVERT(NVARCHAR(200),bcm.BusinessClusterMapID)
WHEN MATCHED THEN              
UPDATE SET 
	BCM.BusinessClusterBaseName=H3.HierarchyValue , 
	BCM.BusinessClusterID=H3.ClusterID,
	BCM.ModifiedBy=H3.CognizantId,
	BCM.ModifiedDate=GETDATE(),
	BCM.ParentBusinessClusterMapID=H3.BusinessClusterMapID
WHEN NOT MATCHED THEN
	INSERT (BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)
	Values (H3.HierarchyValue, H3.ClusterID, H3.BusinessClusterMapID,
	CASE WHEN (SELECT COUNT(HierarchyValue) FROM @Hierarchy4 WHERE HierarchyValue IS NOT NULL) > 0 THEN 1 ELSE 0 END, 
	0, @CustomerID, H3.CognizantId, GETDATE())
	OUTPUT Inserted.BusinessClusterMapID,H3.TreeID INTO @outputTbl; 

IF EXISTS(SELECT HierarchyValue FROM @Hierarchy4 WHERE HierarchyValue IS NOT NULL)
	BEGIN	
	
		UPDATE
			H4
		SET
			H4.BusinessClusterMapID = H3.ID
		FROM
			@Hierarchy4 H4
		INNER JOIN
			@outputTbl H3 ON H3.OrgID = H4.NodeParent  

DELETE  FROM @outputTbl
 
MERGE 
	AVL.BusinessClusterMapping BCM              
USING 
	@Hierarchy4 H4 ON  H4.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID=@CustomerID AND H4.TreeID = CONVERT(NVARCHAR(200),bcm.BusinessClusterMapID)
WHEN MATCHED THEN              
UPDATE SET 
	BCM.BusinessClusterBaseName=H4.HierarchyValue, 
	BCM.BusinessClusterID=H4.ClusterID,
	BCM.ModifiedBy=H4.CognizantId,
	BCM.ModifiedDate=GETDATE(),
	BCM.ParentBusinessClusterMapID=H4.BusinessClusterMapID
WHEN NOT MATCHED THEN
	INSERT (BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)
	VALUES (H4.HierarchyValue, H4.ClusterID, H4.BusinessClusterMapID, 			
			CASE WHEN (SELECT COUNT(HierarchyValue) FROM @Hierarchy5 WHERE HierarchyValue IS NOT NULL) > 0 THEN 1 ELSE 0 END,  
			0, @CustomerID, H4.CognizantId, GETDATE())
OUTPUT Inserted.BusinessClusterMapID,H4.TreeID INTO @outputTbl;
						
		IF EXISTS(SELECT HierarchyValue FROM @Hierarchy5 WHERE HierarchyValue IS NOT NULL)
			BEGIN	
				
				UPDATE
					H5
				SET
					H5.BusinessClusterMapID = H4.ID
				FROM
					@Hierarchy5 H5
				INNER JOIN
					@outputTbl H4 ON H4.OrgID = H5.NodeParent  

DELETE  FROM @outputTbl					
			
					
MERGE 
	AVL.BusinessClusterMapping BCM              
USING 
	@Hierarchy5 H5 ON  H5.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID=@CustomerID AND H5.TreeID = CONVERT(NVARCHAR(200),bcm.BusinessClusterMapID)
WHEN MATCHED THEN              
UPDATE SET 
	BCM.BusinessClusterBaseName=H5.HierarchyValue, 
	BCM.BusinessClusterID=H5.ClusterID,
	BCM.ModifiedBy=H5.CognizantId,
	BCM.ModifiedDate=GETDATE(),
	BCM.ParentBusinessClusterMapID=H5.BusinessClusterMapID
WHEN NOT MATCHED THEN
	INSERT (BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)
	VALUES (H5.HierarchyValue, H5.ClusterID, H5.BusinessClusterMapID, 					
	CASE WHEN (SELECT COUNT(HierarchyValue) FROM @Hierarchy6 WHERE HierarchyValue IS NOT NULL) > 0 THEN 1 ELSE 0 END,
	0, @CustomerID, H5.CognizantId, GETDATE())
	OUTPUT Inserted.BusinessClusterMapID,H5.TreeID INTO @outputTbl;


				
				IF EXISTS(SELECT HierarchyValue FROM @Hierarchy6 WHERE HierarchyValue IS NOT NULL)
					BEGIN	
										
				UPDATE
					H6
				SET
					H6.BusinessClusterMapID = H5.ID
				FROM
					@Hierarchy6 H6
				INNER JOIN
					@outputTbl H5 ON H5.OrgID = H6.NodeParent  

DELETE  FROM @outputTbl	
MERGE 
	AVL.BusinessClusterMapping BCM              
USING 
	@Hierarchy6 H6 ON  H6.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID=@CustomerID AND H6.TreeID = CONVERT(NVARCHAR(200),bcm.BusinessClusterMapID)
WHEN MATCHED THEN              
UPDATE SET 
	BCM.BusinessClusterBaseName=H6.HierarchyValue, 
	BCM.BusinessClusterID=H6.ClusterID,
	BCM.ModifiedBy=H6.CognizantId,
	BCM.ModifiedDate=GETDATE(),
	BCM.ParentBusinessClusterMapID=H6.BusinessClusterMapID
WHEN NOT MATCHED THEN
	INSERT (BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)
	VALUES (H6.HierarchyValue, H6.ClusterID, H6.BusinessClusterMapID, 0, 0, @CustomerID, H6.CognizantId, GETDATE()); 

SELECT 1
	


					END
			END
	END




	SELECT * FROM @Hierarchy1 ORDER by HierarchyName
	SELECT * FROM @Hierarchy2 ORDER by HierarchyName	
	SELECT * FROM @Hierarchy3 ORDER by HierarchyName
	SELECT * FROM @Hierarchy4 ORDER by HierarchyName
	SELECT * FROM @Hierarchy5 ORDER by HierarchyName
	SELECT * FROM @Hierarchy6 ORDER by HierarchyName

	DECLARE @CognizantId NVARCHAR(MAX)
	SET @CognizantId= (select TOP 1 UserName from #TreeNodes)

	
	DROP TABLE #TreeNodes
	

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		
		EXEC AVL_InsertError '[AVL].[APP_INV_SaveHierarchyTreeInsertAndUpdate]', @ErrorMessage, '0', @CustomerID 
END CATCH
	
END