/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[RegexTicketUpload]
@RegexTicketMapJSONData NVARCHAR(MAX),
@SupportTypeID INT,
@UserId NVARCHAR(20)
AS
BEGIN 
SET NOCOUNT ON;
	BEGIN TRY  
	BEGIN TRAN
		CREATE TABLE #TEMPREGEXTICKETMAPDETAILS
		(
			TimeTickerID   BIGINT,
			KeyWordID      INT,
			ConditionID    INT,
			RegexWord      NVARCHAR(MAX),
			Isdeleted      BIT
		)
	
		INSERT INTO #TEMPREGEXTICKETMAPDETAILS                    
		SELECT TimeTickerID,KeyWordID,ConditionID,RegexWord,0 FROM OPENJSON(@RegexTicketMapJSONData)
		WITH
		(
			TimeTickerID BIGINT        '$.TimeTickerId',
			KeyWordID    INT           '$.KeywordId',         
			ConditionID  INT           '$.ConditionId',
			RegexWord    NVARCHAR(MAX) '$.RegexWord'
		) AS JSONVALUES

		IF @SupportTypeID=1
		BEGIN    

			IF EXISTS(SELECT TOP 11 a.TimeTickerid from #TEMPREGEXTICKETMAPDETAILS a
			INNER JOIN Avl.TicketRegexMapping b on  a.TimeTickerID=b.TimeTickerID 
			WHERE a.Regexword IS NULL)
			BEGIN
			UPDATE b SET b.isdeleted=1 from #TEMPREGEXTICKETMAPDETAILS a 
				INNER JOIN Avl.TicketRegexMapping b on  a.TimeTickerID=b.TimeTickerID 
				WHERE a.RegexWord IS NULL
			UPDATE b SET b.isdeleted=0 from #TEMPREGEXTICKETMAPDETAILS a 
				INNER JOIN Avl.TicketRegexMapping b on  a.TimeTickerID=b.TimeTickerID 
				AND a.RegexWord=b.RegexWord
			END
			DELETE #TEMPREGEXTICKETMAPDETAILS WHERE RegexWord IS NULL

			MERGE [AVL].[TicketRegexMapping] AS TARGET
			USING #TEMPREGEXTICKETMAPDETAILS AS SOURCE
			ON TARGET.TimeTickerID=SOURCE.TimeTickerID AND TARGET.RegexWord=Source.RegexWord AND ISNULL(TARGET.KeywordID,0)= ISNULL(SOURCE.KeywordID,0) 
			AND ISNULL(TARGET.ConditionId,0)=ISNULL(SOURCE.ConditionId,0) AND TARGET.Isdeleted=SOURCE.Isdeleted
			WHEN NOT MATCHED BY TARGET  
			THEN 
			INSERT (TimeTickerID,KeywordID,ConditionID,RegexWord,IsDeleted,CreatedBy,CreatedDate)
			VALUES (SOURCE.TimeTickerID,SOURCE.KeyWordID,SOURCE.ConditionID,SOURCE.RegexWord,0,@UserId,getdate())
			WHEN NOT MATCHED BY SOURCE AND TARGET.TimeTickerID IN(SELECT TimeTickerID FROM #TEMPREGEXTICKETMAPDETAILS)   
			AND TARGET.Isdeleted=0
			THEN        
			UPDATE SET TARGET.IsDeleted=1,Target.ModifiedBy=@UserId,Target.ModifiedDate=getdate();
		END
		ELSE IF @SupportTypeID=2
		BEGIN

			IF EXISTS(SELECT TOP 11 a.TimeTickerid from #TEMPREGEXTICKETMAPDETAILS a
			INNER JOIN Avl.InfraTicketRegexMapping b on  a.TimeTickerID=b.TimeTickerID 
			WHERE a.Regexword IS NULL)
			BEGIN
			UPDATE b SET b.isdeleted=1 from #TEMPREGEXTICKETMAPDETAILS a 
				INNER JOIN Avl.InfraTicketRegexMapping b on  a.TimeTickerID=b.TimeTickerID 
				WHERE a.RegexWord IS NULL
			UPDATE b SET b.isdeleted=0 from #TEMPREGEXTICKETMAPDETAILS a 
				INNER JOIN Avl.InfraTicketRegexMapping b on  a.TimeTickerID=b.TimeTickerID 
				AND a.RegexWord=b.RegexWord
			END

			DELETE #TEMPREGEXTICKETMAPDETAILS where RegexWord IS NULL

			MERGE [AVL].[InfraTicketRegexMapping] AS TARGET
			USING #TEMPREGEXTICKETMAPDETAILS AS SOURCE
			ON TARGET.TimeTickerID=SOURCE.TimeTickerID AND TARGET.RegexWord=Source.RegexWord AND ISNULL(TARGET.KeywordID,0)= ISNULL(SOURCE.KeywordID,0) 
			AND ISNULL(TARGET.ConditionId,0)=ISNULL(SOURCE.ConditionId,0) AND TARGET.Isdeleted=SOURCE.Isdeleted
			WHEN NOT MATCHED BY TARGET  
			THEN 
			INSERT (TimeTickerID,KeywordID,ConditionID,RegexWord,IsDeleted,CreatedBy,CreatedDate)
			VALUES (SOURCE.TimeTickerID,SOURCE.KeyWordID,SOURCE.ConditionID,SOURCE.RegexWord,0,@UserId,getdate())
			WHEN NOT MATCHED BY SOURCE AND TARGET.TimeTickerID IN(SELECT TimeTickerID FROM #TEMPREGEXTICKETMAPDETAILS)   
			AND TARGET.Isdeleted=0
			THEN        
			UPDATE SET TARGET.IsDeleted=1,Target.ModifiedBy=@UserId,Target.ModifiedDate=getdate();
		END

	COMMIT TRAN
	END TRY 
    BEGIN CATCH 		
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error   
		ROLLBACK TRAN
        EXEC AVL_INSERTERROR  '[AVL].[RegexTicketUpload]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
