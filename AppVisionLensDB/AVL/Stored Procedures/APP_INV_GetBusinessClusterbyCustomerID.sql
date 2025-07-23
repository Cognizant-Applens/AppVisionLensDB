/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[APP_INV_GetBusinessClusterbyCustomerID]
	@CustomerID BIGINT
AS
BEGIN
BEGIN TRY
DECLARE @Count AS INT;
DECLARE @sqlCommand varchar(1000);	
	
	SELECT 
		BusinessClusterID, BusinessClusterName, IsHavingSubBusinesss
	FROM 
		AVL.BusinessCluster 
	WHERE 
		CustomerID = @CustomerID AND IsDeleted=0
	ORDER BY 
		BusinessClusterID
		
	SELECT
		BusinessClusterMapID,BusinessClusterBaseName,BusinessClusterID,ParentBusinessClusterMapID,IsHavingSubBusinesss,
		IsDeleted,CustomerID,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate
	INTO
		#BusinessClusterMapping
	FROM
		AVL.BusinessClusterMapping
	WHERE
		CustomerID = @CustomerID AND IsDeleted=0

	SELECT 
		BusinessClusterBaseName, BusinessClusterMapID, ParentBusinessClusterMapID,BusinessClusterID
	INTO
		#App_level1 
	FROM 
		#BusinessClusterMapping	 
	WHERE 
		CustomerID = @CustomerID AND IsHavingSubBusinesss = 0 
	

	SELECT 
		AL.BusinessClusterBaseName, AL.BusinessClusterMapID,AL.BusinessClusterID,
		BCM.BusinessClusterBaseName AS BusinessClusterBaseName1, BCM.BusinessClusterMapID AS BusinessClusterMapID1, 
		BCM.ParentBusinessClusterMapID AS ParentBusinessClusterMapID1,BCM.BusinessClusterID AS BusinessClusterID1
	INTO
		#App_level2
	FROM 
		#App_level1 AL
	INNER JOIN	
		#BusinessClusterMapping BCM ON BCM.BusinessClusterMapID = AL.ParentBusinessClusterMapID

	SELECT 
		AL.BusinessClusterBaseName, AL.BusinessClusterMapID,AL.BusinessClusterID, 
		AL.BusinessClusterBaseName1, AL.BusinessClusterMapID1, AL.ParentBusinessClusterMapID1,AL.BusinessClusterID1,
		BCM.BusinessClusterBaseName AS BusinessClusterBaseName2, BCM.BusinessClusterMapID AS BusinessClusterMapID2, BCM.ParentBusinessClusterMapID AS ParentBusinessClusterMapID2,BCM.BusinessClusterID AS BusinessClusterID2
	
	INTO
		#App_level3

	FROM 
		#App_level2 AL
	INNER JOIN	
		#BusinessClusterMapping BCM ON BCM.BusinessClusterMapID = AL.ParentBusinessClusterMapID1

		SET @Count=(SELECT count (*) from #App_level3 where ParentBusinessClusterMapID2 IS NOT NULL);

	IF @count >0 
		BEGIN
			SELECT 
				AL.BusinessClusterBaseName, AL.BusinessClusterMapID,AL.BusinessClusterID,
				AL.BusinessClusterBaseName1, AL.BusinessClusterMapID1, AL.ParentBusinessClusterMapID1,AL.BusinessClusterID1,
				AL.BusinessClusterBaseName2, AL.BusinessClusterMapID2, AL.ParentBusinessClusterMapID2,AL.BusinessClusterID2,
				BCM.BusinessClusterBaseName AS BusinessClusterBaseName3, BCM.BusinessClusterMapID AS BusinessClusterMapID3, BCM.ParentBusinessClusterMapID AS ParentBusinessClusterMapID3,BCM.BusinessClusterID AS BusinessClusterID3
			INTO
				#App_level4
			FROM 
				#App_level3 AL
			INNER JOIN	
				#BusinessClusterMapping BCM ON BCM.BusinessClusterMapID = AL.ParentBusinessClusterMapID2

			SET @Count=(SELECT count (*) from #App_level4 where ParentBusinessClusterMapID3 IS NOT NULL);
			
			IF @count >0 
				BEGIN
					SELECT 
							AL.BusinessClusterBaseName, AL.BusinessClusterMapID,AL.BusinessClusterID,
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

					SET @Count=(SELECT count (*) from #App_level5 where ParentBusinessClusterMapID4 IS NOT NULL);
					
					IF @count >0 
						BEGIN
							SELECT 
								AL.BusinessClusterBaseName, AL.BusinessClusterMapID,AL.BusinessClusterID ,
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
								AL.BusinessClusterBaseName5,AL.BusinessClusterMapID5,
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
								AL.BusinessClusterBaseName4,AL.BusinessClusterMapID4,
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
						AL.BusinessClusterBaseName3,AL.BusinessClusterMapID3,
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
				AL.BusinessClusterBaseName2,AL.BusinessClusterMapID2,
				AL.BusinessClusterBaseName1,AL.BusinessClusterMapID1,
				AL.BusinessClusterBaseName,AL.BusinessClusterMapID 
			FROM 
				#App_level3 AL;
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

		   
		EXEC AVL_InsertError ' [AVL].[APP_INV_GetBusinessClusterbyCustomerID]', @ErrorMessage, 0, @CustomerID 
		
	END CATCH  
END
