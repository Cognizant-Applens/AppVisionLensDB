
CREATE proc [BOT].[GetDetailsForMyBOT_Customer]     
(    
@UserID NVARCHAR(50)    
)    
AS    
BEGIN     
  BEGIN TRY     
  SET NOCOUNT ON;    
     
 DECLARE @TotalCount INT    
    
 SET @TotalCount = (SELECT COUNT(Id) FROM BOT.MasterRepository)    
 SELECT DISTINCT UR.HealingTicketID,UR.BotID,Rating, UR.BotRatingId INTO #Rating FROM BOT.RecommendationDetails RD     
 INNER JOIN BOT.RecommendedRatings UR ON  RD.BotID=UR.BotId AND UR.HealingTicketID = RD.HealingTicketID    
 and UR.Rating is not null AND UR.IsDeleted<>1    
    
 SELECT  DIStinct MR.Id    
 ,@TotalCount AS 'TotalCount'    
 ,MR.BotName    
 ,MR.Overview    
 ,MR.Description    
 ,MR.BotTargetApplicationId AS ApplicationId    
 ,TA.TargetApplicationName AS 'BotTargetApplicationName'    
 ,MR.TechnologyId    
 ,PT.PrimaryTechnologyName AS 'TechnologyName'    
 ,MR.BotCategoryId AS CategoryId    
 ,BC.CategoryName AS 'BotCategoryName'    
 ,MR.BotNatureId AS 'Nature'    
 ,BN.Nature AS 'BotNatureId'    
 ,MR.BotTypeId    
 ,BT.Type AS 'BotTypeName'    
 ,MR.BotReusabilityId    
 ,BR.Reusability AS 'BotReusabilityValue'    
    

   
 --,CAT.ServiceName as Category    
 ,CAT.ServiceName       
 ,MR.ServiceId    
 ,MR.Author    
 ,MR.ContactDL    
 ,MR.IsManuallyCreated    
 ,Cast(MR.BotStatusId as varchar(10)) AS BotStatusId    
 ,MR.IsDeleted    
 ,MR.CreatedBy    
 ,MR.CreatedOn    
 ,MR.ModifiedBy    
 ,MR.ModifiedOn    
 ,Y.Tag    
 ,0 AS RatingCount    
 ,cast(0 as decimal(18,2)) AS Rating    
 into #Temp    
 FROM BOT.MasterRepository AS MR    
 left JOIN BOT.BotType AS BT ON BT.Id=MR.BotTypeId    
 left JOIN BOT.TargetApplication AS TA ON TA.Id=MR.BotTargetApplicationId    
 left JOIN BOT.Category AS BC ON BC.Id=MR.BotCategoryId    
 left JOIN BOT.Nature AS BN ON BN.Id=MR.BotNatureId    
 left JOIN BOT.Reusability AS BR ON BR.Id=MR.BotReusabilityId    
 left JOIN AVL.APP_MAS_PrimaryTechnology AS PT on PT.PrimaryTechnologyID=MR.TechnologyId    
 left JOIN avl.TK_MAS_Service CAT ON CAT.ServiceID=MR.ServiceId    
 LEFT JOIN BOT.RecommendationDetails RD ON RD.BotID=MR.Id     
 LEFT JOIN #Rating UR ON UR.BotId = MR.Id AND UR.HealingTicketID = RD.HealingTicketID    
 CROSS APPLY    
    (    
     SELECT STUFF (    
      (     
       SELECT ',' +ST.Tag FROM BOT.TAGDetails ST     
       WHERE ST.BotDetailId=MR.Id    
       FOR XML PATH('')     
      )    
     ,1,1,'') as Tag    
    ) as Y    
 WHERE    
 MR.CreatedBy = @UserID    
 group by     
  MR.Id    
 ,MR.BotName    
 ,MR.Overview    
 ,MR.Description    
 ,MR.BotTargetApplicationId    
 ,TA.TargetApplicationName    
 ,MR.TechnologyId    
 ,PT.PrimaryTechnologyName     
 ,MR.BotCategoryId    
 ,BC.CategoryName     
 ,MR.BotNatureId    
 ,BN.Nature    
 ,MR.BotTypeId   ,BT.Type    
 ,MR.BotReusabilityId    
 ,BR.Reusability        
 ,CAT.ServiceName        
 ,MR.ServiceId    
 ,MR.Author    
 ,MR.ContactDL    
 ,MR.IsManuallyCreated    
 ,MR.BotStatusId    
 ,MR.IsDeleted    
 ,MR.CreatedBy    
 ,MR.CreatedOn    
 ,MR.ModifiedBy    
 ,MR.ModifiedOn    
 ,Y.Tag    
    
 select R.BotId, COUNT(DISTINCT R.BotRatingId) AS RatingCount     
 ,ISNULL(CAST(CAST(sum(R.Rating) AS NUMERIC)/CAST(COUNT(R.BotRatingId) AS NUMERIC)AS NUMERIC(18,1)),0) AS Rating into #RatingCount    
  from #Temp T left join #Rating R on T.Id=R.BotId group by R.BotId    
    
 update T set Rating=r.Rating,RatingCount=R.RatingCount from #temp T inner join #RatingCount R on R.BotId=T.Id    
     
 UPDATE #Temp SET RatingCount=0 WHERE RATING=0;    
  --order by rating    
  select * from #Temp order by CreatedOn desc -- Rating desc    
  END TRY    
  BEGIN CATCH    
 DECLARE @ErrorMessage VARCHAR(MAX);    
 SELECT @ErrorMessage = ERROR_MESSAGE()    
 --INSERT Error        
 EXEC AVL_InsertError '[BOT].[GetDetailsForMyBOT]', @ErrorMessage, '',''    
 RETURN @ErrorMessage    
  END CATCH    
END
