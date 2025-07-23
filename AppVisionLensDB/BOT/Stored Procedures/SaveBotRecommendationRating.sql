/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [BOT].[SaveBotRecommendationRating]
@EmployeeID VARCHAR(50),
@ProjectID BIGINT,
@HealingTicketID NVARCHAR(100),
@Mandatory BIT = NULL,
@Ratinglist [BOT].[TVP_SaveBotRecommendationRating] READONLY
AS 
  BEGIN 
      BEGIN TRY
	  BEGIN TRAN
		SET NOCOUNT ON;
		DECLARE @TotalCount NVARCHAR(50)
		DECLARE @Result INT
		CREATE TABLE #Ratings
		(
		ID INT IDENTITY,
		[Rating] [int] NULL,
		[BotTicketID] [bigint] NULL,	
		[mapstatus] [int] NULL
		)
		INSERT INTO #Ratings SELECT Rating,BotTicketID,mapstatus 
		FROM @Ratinglist

		 SET @TotalCount = (SELECT COUNT(ID) FROM #Ratings)
		 --Updating all records as isdeleted -1

		 UPDATE RR SET RR.IsDeleted = 1 
				--RR.ModifiedBy = @EmployeeID,
				--RR.ModifiedOn = GETDATE() 
				FROM BOT.RecommendedRatings RR 
				WHERE RR.HealingTicketID = @HealingTicketID
		
		 UPDATE RD SET RD.IsMapped = 0 FROM BOT.RecommendationDetails RD
				WHERE RD.HealingTicketID = @HealingTicketID		 
				AND RD.ProjectID = @ProjectID

		 UPDATE AVL.DEBT_TRN_HealTicketDetails SET IsMandatory = @Mandatory
				WHERE HealingTicketID = @HealingTicketID
				AND @Mandatory IS NOT NULL
				

		 -- inserting into BOT.RecommendedRatings table one by one
		 WHILE (@TotalCount > 0)
         BEGIN
			DECLARE @ID INT = (SELECT TOP 1 ID FROM #Ratings)

			IF EXISTS(SELECT 1 FROM BOT.RecommendedRatings RR INNER JOIN #Ratings RL 
			ON RR.HealingTicketID = @HealingTicketID AND RR.BotId = RL.BotTicketID AND RL.ID  = @ID)
			BEGIN

			--updating in bot.RecommendedRatings
				UPDATE RR SET RR.Rating = RL.Rating, 
				RR.IsDeleted = 0, 
				RR.ModifiedBy = @EmployeeID,
				RR.ModifiedOn = GETDATE() FROM BOT.RecommendedRatings RR 
				INNER JOIN #Ratings RL ON RR.BotId = RL.BotTicketID
				WHERE RR.HealingTicketID = @HealingTicketID AND RL.ID = @ID	

			END
			ELSE
			BEGIN
				INSERT INTO BOT.RecommendedRatings SELECT @EmployeeID,@HealingTicketID,RL.Rating,RL.BotTicketID,0,@EmployeeID,GETDATE(),NULL,NULL 
				FROM #Ratings RL
			END
			--updating in bot.RecommendationDetails
				UPDATE RD SET RD.IsMapped = 1, 
				RD.ModifiedBy = @EmployeeID,
				RD.ModifiedDate = GETDATE() FROM BOT.RecommendationDetails RD 
				INNER JOIN #Ratings RL ON RD.BotId = RL.BotTicketID
				WHERE RD.HealingTicketID = @HealingTicketID
				AND RD.ProjectID = @ProjectID AND RL.ID = @ID

			DELETE FROM #Ratings WHERE ID = @ID
          --  SELECT * FROM #Ratings
            SET @TotalCount = @TotalCount-1
            PRINT @TotalCount
		 END	
		 DROP TABLE #Ratings
		 SET @Result = 1
		 SELECT @Result AS Result
		SET NOCOUNT OFF; 	
	 COMMIT TRAN
      END TRY 
      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE()   
          EXEC AVL_INSERTERROR '[BOT].[SaveBotRecommendationRating]',  @ErrorMessage, @ProjectID,  0 
		  SET @Result = 0
		  SELECT @Result
		  ROLLBACK TRAN
      END CATCH 
  END
