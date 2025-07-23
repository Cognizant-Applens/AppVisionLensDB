/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================------ 
--  Modified date:    May 17 2019    
-- ============================================================================

CREATE PROCEDURE [AVL].[APP_INV_GetProjectAppSuppHierarchyValues]
@CustomerID bigint,
@ProjectID bigint
AS
BEGIN
BEGIN TRY
DECLARE @Count AS INT;
DECLARE @sqlCommand varchar(1000);
		
	SELECT
		BusinessClusterMapID,BusinessClusterBaseName,BusinessClusterID,ParentBusinessClusterMapID,IsHavingSubBusinesss,
		IsDeleted,CustomerID,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate
	INTO
		#BusinessClusterMapping
	FROM
		AVL.BusinessClusterMapping With (NoLock)
	WHERE
		CustomerID = @CustomerID AND IsDeleted=0

	

		CREATE TABLE #App_level1
		(
		ApplicationID BIGINT,
		ApplicationName VARCHAR(500),
		MainspringSUPPORTCATEGORYID BIGINT,
		MainspringSUPPORTCATEGORYName VARCHAR(500),
		BusinessClusterBaseName VARCHAR(500),
		BusinessClusterMapID BIGINT,
		ParentBusinessClusterMapID BIGINT,
		BusinessClusterID BIGINT,
		Checked INT
		)

		INSERT INTO #App_level1(ApplicationID,ApplicationName,BusinessClusterBaseName,BusinessClusterMapID,ParentBusinessClusterMapID
		,BusinessClusterID,Checked)
		SELECT 
		AD.ApplicationID,AD.ApplicationName,BusinessClusterBaseName, BusinessClusterMapID, ParentBusinessClusterMapID,BusinessClusterID 
		,CASE WHEN EXISTS (SELECT 1 FROM  
						AVL.APP_MAP_ApplicationProjectMapping MP With (NoLock)
						WHERE MP.ApplicationID = AD.ApplicationID
						AND ProjectID=@ProjectID AND MP.IsDeleted=0)
       THEN 1 
       ELSE 0
		END AS 'Checked'	
	FROM 
		#BusinessClusterMapping	 AL With (NoLock)
	JOIN
		AVL.APP_MAS_ApplicationDetails AD With (NoLock)
	ON
		AD.SubBusinessClusterMapID=AL.BusinessClusterMapID
	WHERE 
		CustomerID = @CustomerID AND IsHavingSubBusinesss = 0 
	AND AD.IsActive = 1
	

	UPDATE #App_level1 SET #App_level1.MainspringSUPPORTCATEGORYID=AP.MainspringSUPPORTCATEGORYID
		FROM #App_level1 AD
    LEFT JOIN AVL.APP_MAP_ApplicationProjectMapping AP With (NoLock) ON AD.ApplicationID=AP.ApplicationID	and ProjectID=@ProjectID 
   

UPDATE #App_level1 SET #App_level1.MainspringSUPPORTCATEGORYName=SM.MainspringSUPPORTCATEGORYName
FROM #App_level1 AD LEFT JOIN MS.MAP_ProjectSUPPORTCATEGORY_Mapping B With (NoLock) ON AD.MainspringSUPPORTCATEGORYID=B.MainSpringProjectSUPPORTCATEGORYID
LEFT JOIN
MS.MAS_SUPPORTCATEGORY_Master SM With (NoLock) ON B.SUPPORTCATEGORYID=SM.MainspringSUPPORTCATEGORYID


	SELECT 
		Checked,AL.ApplicationID,AL.ApplicationName,AL.MainspringSUPPORTCATEGORYID,AL.MainspringSUPPORTCATEGORYName,AL.BusinessClusterBaseName, AL.BusinessClusterMapID,AL.BusinessClusterID,
		BCM.BusinessClusterBaseName AS BusinessClusterBaseName1, BCM.BusinessClusterMapID AS BusinessClusterMapID1, 
		BCM.ParentBusinessClusterMapID AS ParentBusinessClusterMapID1,BCM.BusinessClusterID AS BusinessClusterID1
		
	INTO
		#App_level2
	FROM 
		#App_level1 AL
	INNER JOIN	
		#BusinessClusterMapping BCM ON BCM.BusinessClusterMapID = AL.ParentBusinessClusterMapID

	SELECT 
		Checked,AL.ApplicationID,AL.ApplicationName,AL.MainspringSUPPORTCATEGORYID,AL.MainspringSUPPORTCATEGORYName,AL.BusinessClusterBaseName, AL.BusinessClusterMapID,AL.BusinessClusterID, 
		AL.BusinessClusterBaseName1, AL.BusinessClusterMapID1, AL.ParentBusinessClusterMapID1,AL.BusinessClusterID1,
		BCM.BusinessClusterBaseName AS BusinessClusterBaseName2, BCM.BusinessClusterMapID AS BusinessClusterMapID2, BCM.ParentBusinessClusterMapID AS ParentBusinessClusterMapID2,BCM.BusinessClusterID AS BusinessClusterID2
		
	INTO
		#App_level3

	FROM 
		#App_level2 AL
	INNER JOIN	
		#BusinessClusterMapping BCM ON BCM.BusinessClusterMapID = AL.ParentBusinessClusterMapID1

		SET @Count=(SELECT count (1) from #App_level3 where ParentBusinessClusterMapID2 IS NOT NULL);

	IF @count >0 
		BEGIN
			SELECT 
				Checked,AL.ApplicationID,AL.ApplicationName,AL.MainspringSUPPORTCATEGORYID,AL.MainspringSUPPORTCATEGORYName,AL.BusinessClusterBaseName, AL.BusinessClusterMapID,AL.BusinessClusterID,
				AL.BusinessClusterBaseName1, AL.BusinessClusterMapID1, AL.ParentBusinessClusterMapID1,AL.BusinessClusterID1,
				AL.BusinessClusterBaseName2, AL.BusinessClusterMapID2, AL.ParentBusinessClusterMapID2,AL.BusinessClusterID2,
				BCM.BusinessClusterBaseName AS BusinessClusterBaseName3, BCM.BusinessClusterMapID AS BusinessClusterMapID3, BCM.ParentBusinessClusterMapID AS ParentBusinessClusterMapID3,BCM.BusinessClusterID AS BusinessClusterID3
				
			INTO
				#App_level4
			FROM 
				#App_level3 AL
			INNER JOIN	
				#BusinessClusterMapping BCM ON BCM.BusinessClusterMapID = AL.ParentBusinessClusterMapID2

			SET @Count=(SELECT count (1) from #App_level4 where ParentBusinessClusterMapID3 IS NOT NULL);
			
			IF @count >0 
				BEGIN
					SELECT 
							Checked,AL.ApplicationID,AL.ApplicationName,AL.MainspringSUPPORTCATEGORYID,AL.MainspringSUPPORTCATEGORYName,AL.BusinessClusterBaseName, AL.BusinessClusterMapID,AL.BusinessClusterID,
							AL.BusinessClusterBaseName1, AL.BusinessClusterMapID1, AL.ParentBusinessClusterMapID1,AL.BusinessClusterID1,
							AL.BusinessClusterBaseName2, AL.BusinessClusterMapID2, AL.ParentBusinessClusterMapID2,AL.BusinessClusterID2,
							AL.BusinessClusterBaseName3, AL.BusinessClusterMapID3, AL.ParentBusinessClusterMapID3,AL.BusinessClusterID3,
							BCM.BusinessClusterBaseName AS BusinessClusterBaseName4, BCM.BusinessClusterMapID AS BusinessClusterMapID4, BCM.ParentBusinessClusterMapID AS ParentBusinessClusterMapID4,BCM.BusinessClusterID AS BusinessClusterID4
							
					INTO
							#App_level5
					FROM 
							#App_level4 AL
					INNER JOIN	
							#BusinessClusterMapping BCM ON BCM.BusinessClusterMapID = AL.ParentBusinessClusterMapID3

					SET @Count=(SELECT count (1) from #App_level5 where ParentBusinessClusterMapID4 IS NOT NULL);
					
					IF @count >0 
						BEGIN
							SELECT 
								Checked,AL.ApplicationID,AL.ApplicationName,AL.MainspringSUPPORTCATEGORYID,AL.MainspringSUPPORTCATEGORYName,AL.BusinessClusterBaseName, AL.BusinessClusterMapID,AL.BusinessClusterID ,
								AL.BusinessClusterBaseName1, AL.BusinessClusterMapID1, AL.ParentBusinessClusterMapID1,AL.BusinessClusterID1,
								AL.BusinessClusterBaseName2, AL.BusinessClusterMapID2, AL.ParentBusinessClusterMapID2,AL.BusinessClusterID2,
								AL.BusinessClusterBaseName3, AL.BusinessClusterMapID3, AL.ParentBusinessClusterMapID3,AL.BusinessClusterID3,
								AL.BusinessClusterBaseName4, AL.BusinessClusterMapID4, AL.ParentBusinessClusterMapID4,AL.BusinessClusterID4,
								BCM.BusinessClusterBaseName AS BusinessClusterBaseName5, BCM.BusinessClusterMapID AS BusinessClusterMapID5, BCM.ParentBusinessClusterMapID AS ParentBusinessClusterMapID5,BCM.BusinessClusterID AS BusinessClusterID5
								
							INTO
								#App_level6
							FROM 
								#App_level5 AL
							INNER JOIN	
								#BusinessClusterMapping BCM ON BCM.BusinessClusterMapID = AL.ParentBusinessClusterMapID4		


							SELECT 
								Checked,AL.ApplicationID,AL.ApplicationName,AL.MainspringSUPPORTCATEGORYID,AL.MainspringSUPPORTCATEGORYName,AL.BusinessClusterBaseName5,AL.BusinessClusterMapID5,
								AL.BusinessClusterBaseName4,AL.BusinessClusterMapID4,
								AL.BusinessClusterBaseName3,AL.BusinessClusterMapID3,
								AL.BusinessClusterBaseName2,AL.BusinessClusterMapID2,
								AL.BusinessClusterBaseName1,AL.BusinessClusterMapID1,
								AL.BusinessClusterBaseName,AL.BusinessClusterMapID
								
							FROM 
								#App_level6 AL;
						END
					ELSE
						BEGIN
							SELECT 
								Checked,AL.ApplicationID,AL.ApplicationName,AL.MainspringSUPPORTCATEGORYID,AL.MainspringSUPPORTCATEGORYName,AL.BusinessClusterBaseName4,AL.BusinessClusterMapID4,
								AL.BusinessClusterBaseName3,AL.BusinessClusterMapID3,
								AL.BusinessClusterBaseName2,AL.BusinessClusterMapID2,
								AL.BusinessClusterBaseName1,AL.BusinessClusterMapID1,
								AL.BusinessClusterBaseName,AL.BusinessClusterMapID

							FROM 
								#App_level5 AL;
						END				
				END
			ELSE
				BEGIN
					SELECT 
						Checked,AL.ApplicationID,AL.ApplicationName,AL.MainspringSUPPORTCATEGORYID,AL.MainspringSUPPORTCATEGORYName,AL.BusinessClusterBaseName3,AL.BusinessClusterMapID3,
						AL.BusinessClusterBaseName2,AL.BusinessClusterMapID2,
						AL.BusinessClusterBaseName1,AL.BusinessClusterMapID1,
						AL.BusinessClusterBaseName,AL.BusinessClusterMapID
					FROM 
						#App_level4 AL;
				END
		END
	ELSE
		BEGIN
			SELECT 
				Checked,AL.ApplicationID,AL.ApplicationName,AL.MainspringSUPPORTCATEGORYID,AL.MainspringSUPPORTCATEGORYName,AL.BusinessClusterBaseName2,AL.BusinessClusterMapID2,
				AL.BusinessClusterBaseName1,AL.BusinessClusterMapID1,
				AL.BusinessClusterBaseName,AL.BusinessClusterMapID 
			FROM 
				#App_level3 AL ORDER BY AL.ApplicationName ASC;
		END



	IF OBJECT_ID('tempdb..#App_level1') IS NOT NULL 
	DROP TABLE #App_level1
	IF OBJECT_ID('tempdb..#App_level2') IS NOT NULL
	DROP TABLE #App_level2
	IF OBJECT_ID('tempdb..#App_level3') IS NOT NULL
	DROP TABLE #App_level3
	IF OBJECT_ID('tempdb..#App_level4') IS NOT NULL
	DROP TABLE #App_level4
	IF OBJECT_ID('tempdb..#App_level5') IS NOT NULL
	DROP TABLE #App_level5
	IF OBJECT_ID('tempdb..#App_level6') IS NOT NULL
	DROP TABLE #App_level6
	IF OBJECT_ID('tempdb..#BusinessClusterMapping') IS NOT NULL
	DROP TABLE #BusinessClusterMapping
		
		END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[APP_INV_GetProjectAppSuppHierarchyValues] ', @ErrorMessage, 0, @CustomerID 
		
	END CATCH  
END
