/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[SaveMultilingualConfigDetails]
	@customerID nvarchar(50),
	@projectID nvarchar(50),
	@employeeID nvarchar(50),
	@isEnabled nvarchar(1),
	@isSingleOrMulti nvarchar(1),
	@subscriptionkey nvarchar(200),
	@TranslateColumnId nvarchar(100),
	@preferredlang nvarchar(100)
AS
BEGIN

BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;

--Multilingual config update in AVL.MAS_ProjectMaster

IF EXISTS(SELECT ProjectID FROM AVL.MAS_ProjectMaster WHERE ProjectID=@projectID AND IsDeleted=0)
	BEGIN
		UPDATE AVL.MAS_ProjectMaster
		SET IsMultilingualEnabled=@isEnabled,IsSingleORMulti=@isSingleOrMulti,
		MSubscriptionKey=LTRIM(RTRIM(@subscriptionkey)),ModifiedDate=GETDATE(),ModifiedBY=@employeeID 
		WHERE ProjectID=@projectID AND CustomerID=@customerID and IsDeleted=0	
	END


---Insertion for Multilingual Language selection
IF EXISTS(SELECT ProjectID FROM AVL.PRJ_MAP_MultilingualLanguage WHERE ProjectID=@projectID AND Isdeleted=0)
BEGIN 
DELETE FROM AVL.PRJ_MAP_MultilingualLanguage WHERE ProjectID=@projectID
END
DECLARE @LanguageID TABLE
	( 
	ID INT IDENTITY(1,1) NOT NUll,
	LanguageID int
	 )

	 Insert INTO @LanguageID
	 SELECT * from [dbo].[Split](@preferredlang,',')

DECLARE @Count INT
DECLARE @i INT=1
SELECT @Count=Count(*) FROM @LanguageID 

WHILE @i<=@Count 
BEGIN
	INSERT INTO AVL.PRJ_MAP_MultilingualLanguage (ProjectID,LanguageID,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,Isdeleted)
	VALUES (@projectID,(Select LID.LanguageID FROM @LanguageID LID
	JOIN MAS.MAS_LanguageMaster LM ON LID.LanguageID=LM.LanguageID WHERE LM.ContentIsActive=1 AND LID.ID=@i
	),@employeeID,GETDATE(),NULL,NULL,0) 

	SET @i=@i+1
END

---insertion for fields selection for text translation 
IF EXISTS(SELECT ColumnID FROM AVL.PRJ_MultilingualColumnMapping WHERE ProjectID=@projectID)
BEGIN
DELETE FROM AVL.PRJ_MultilingualColumnMapping WHERE ProjectID=@projectID
END

DECLARE @Fields TABLE
(
ID INT IDENTITY(1,1) NOT NUll,
ColumnID int
)

INSERT INTO @Fields
SELECT * FROM [dbo].[Split](@TranslateColumnId,',')

DECLARE @FieldCount INT
DECLARE @j INT=1
SELECT @FieldCount=Count(*) FROM @Fields 

WHILE @j<=@FieldCount
BEGIN
	INSERT INTO AVL.PRJ_MultilingualColumnMapping
	(ProjectID,ColumnID,IsActive,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
	VALUES(@projectID,(SELECT FID.ColumnID FROM @Fields FID
	JOIN AVL.MAS_MultilingualColumnMaster MC 
	ON FID.ColumnID=MC.ColumnID 
	WHERE MC.IsActive=1 AND FID.ID=@j),1,@employeeID,GETDATE(),NULL,NULL)

	SET @j=@j+1
END

select 1

COMMIT TRAN
END TRY 
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[SaveMultilingualConfigDetails]', 
@ErrorMessage, @employeeID ,@projectID		
	END CATCH  
END
