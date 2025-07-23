/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[CheckForHierarchyDeletion] 
@HierarchyID bigint,
@CustomerID bigint
AS
BEGIN
BEGIN TRY
DECLARE @Tmp1 table (ID int)
DECLARE @Tmp2 table (ID int)
DECLARE @Tmp3 table (ID int)
DECLARE @Tmp4 table (ID int)
DECLARE @Tmp5 table (ID int)
DECLARE @Tmp6 table (ID int)
DECLARE @count bigint

INSERT 
	INTO 
		@Tmp1
	SELECT 
		BusinessClusterMapID 
	FROM 
		AVL.BusinessClusterMapping 
	WHERE 
		ParentBusinessClusterMapID=@HierarchyID;
IF NOT EXISTS (SELECT * FROM @tmp1)
	BEGIN
	SELECT
		 @count=count(*)  
	FROM 
		AVL.APP_MAS_ApplicationDetails WHERE
		 SubBusinessClusterMapID=@HierarchyID
	END
	ELSE
		BEGIN
			INSERT 
				INTO 
					@Tmp2
				SELECT 
					BusinessClusterMapID 
				FROM 
					AVL.BusinessClusterMapping 
				WHERE 
					ParentBusinessClusterMapID IN 
												(SELECT * FROM @Tmp1)
			IF NOT EXISTS (SELECT * FROM @tmp2)
					BEGIN
						SELECT 
								@count=count(*) 
						FROM 
								AVL.APP_MAS_ApplicationDetails 
						WHERE SubBusinessClusterMapID 
						IN 
								(SELECT * FROM @Tmp1)
					END
					ELSE
						BEGIN
								INSERT
									INTO 
										@Tmp3
								SELECT 
									BusinessClusterMapID 
								FROM 
									AVL.BusinessClusterMapping
								 WHERE ParentBusinessClusterMapID 
										IN (SELECT * FROM @Tmp2)	
								IF NOT EXISTS (SELECT * FROM @tmp3)
									BEGIN
										SELECT 
											@count=count(*) 
										FROM 
											AVL.APP_MAS_ApplicationDetails 
										WHERE SubBusinessClusterMapID 
											IN (select * from @Tmp2)
									END
									ELSE
										BEGIN
											INSERT 
												INTO 
													@Tmp4
											SELECT 
												BusinessClusterMapID 
											FROM 
												AVL.BusinessClusterMapping 
											WHERE 
												ParentBusinessClusterMapID
												 IN (SELECT * FROM @Tmp3)
											IF NOT EXISTS (SELECT * FROM @tmp4)
												BEGIN
													SELECT 
															@count=count(*) 
												FROM 
													AVL.APP_MAS_ApplicationDetails 
												WHERE 
													SubBusinessClusterMapID 
															IN (SELECT * FROM @Tmp3)
												END
												ELSE
													BEGIN

														INSERT INTO @Tmp5
															SELECT 
																BusinessClusterMapID 
															FROM 
																AVL.BusinessClusterMapping 
															WHERE 
																ParentBusinessClusterMapID 
																	IN (SELECT * FROM @Tmp4)
													IF NOT EXISTS (SELECT * FROM @tmp5)
														BEGIN
															SELECT
																 @count=count(*) 
															FROM
																 AVL.APP_MAS_ApplicationDetails 
															WHERE SubBusinessClusterMapID IN 																				
																				(SELECT * FROM @Tmp4)
														END
														ELSE
															BEGIN
																INSERT INTO @Tmp6 
																SELECT BusinessClusterMapID FROM AVL.BusinessClusterMapping
																WHERE ParentBusinessClusterMapID IN (SELECT * FROM @Tmp5)
																IF NOT EXISTS(SELECT * FROM @Tmp6)
																BEGIN
																SELECT @count=count(*) FROM AVL.APP_MAS_ApplicationDetails
																WHERE SubBusinessClusterMapID IN (SELECT * FROM @Tmp5)
																END
																ELSE
																BEGIN
																SET @count=-1
																END
																END

																 
															END
													
								END		
					END

		END
SELECT @count AS 'COUNT';
END TRY

BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		
		EXEC AVL_InsertError '[AVL].[CheckForHierarchyDeletion] ', @ErrorMessage, @HierarchyID, @CustomerID 
		
	END CATCH  
END
