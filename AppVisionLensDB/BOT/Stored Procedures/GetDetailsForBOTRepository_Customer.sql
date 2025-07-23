/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/    
CREATE proc [BOT].[GetDetailsForBOTRepository_Customer] --'','','',''    
(    
@BotType NVARCHAR(MAX)='',    
@TargetApplication NVARCHAR(MAX)='',    
@Technology NVARCHAR(MAX)='',    
@Tags nvarchar(max)='',    
@Source nvarchar(max)=''    
)    
AS    
BEGIN     
  BEGIN TRY     
  SET NOCOUNT ON;    
    
   CREATE TABLE #TempSourceType    
 (    
 SourceType VARCHAR(500)    
 )    
    
 INSERT INTO #TempSourceType    
 SELECT * FROM dbo.Split(@Source,'~')    
    
 DECLARE @SourceTypeFlag BIT    
    
 SET @SourceTypeFlag = (SELECT COUNT(SourceType) FROM #TempSourceType)    
    
    CREATE TABLE #TempBotType    
 (    
 BotType VARCHAR(500)    
 )    
    
 INSERT INTO #TempBotType    
 SELECT * FROM dbo.Split(@BotType,'~')    
    
 DECLARE @BotTypeFlag BIT    
    
 SET @BotTypeFlag = (SELECT COUNT(BotType) FROM #TempBotType)    
    
 CREATE TABLE #TempTargetApplication    
 (    
 ApplicationID VARCHAR(500)    
 )    
    
 INSERT INTO #TempTargetApplication    
 SELECT * FROM dbo.Split(@TargetApplication,'~')    
    
 DECLARE @ApplicationFlag BIT    
    
 SET @ApplicationFlag = (SELECT COUNT(ApplicationID) FROM #TempTargetApplication)    
     
 CREATE TABLE #TempTechnology    
 (    
 TechID VARCHAR(500)    
 )    
    
 INSERT INTO #TempTechnology    
 SELECT * FROM dbo.Split(@Technology,'~')    
    
 DECLARE @TechFlag BIT    
    
 SET @TechFlag = (SELECT COUNT(TechID) FROM #TempTechnology)     
     
 CREATE TABLE #TempTags    
 (    
 ID INT IDENTITY(1,1),    
 TagsID VARCHAR(500)    
 )    
    
 INSERT INTO #TempTags    
 SELECT * FROM dbo.Split(@Tags,'~')    
    
 DECLARE @TagsCount BIT    
    
 SET @TagsCount = (SELECT COUNT(TagsID) FROM #TempTags)    
    
 DECLARE @TotalCount INT    
    
 SET @TotalCount = (SELECT COUNT(Id) FROM BOT.MasterRepository where IsDeleted=0 AND BotStatusId=2 OR BotStatusId IS NULL)    
     
 SELECT DISTINCT UR.HealingTicketID,UR.BotID, UR.BotRatingId, ur.Rating INTO #Rating FROM BOT.RecommendationDetails RD (NOLOCK)     
 INNER JOIN BOT.RecommendedRatings UR (NOLOCK) ON  RD.BotID=UR.BotId AND UR.HealingTicketID = RD.HealingTicketID    
 and UR.Rating is not null     
 AND UR.IsDeleted<>1    
    
 SELECT  DIStinct MR.Id    
 ,@TotalCount AS 'TotalCount'    
 ,MR.BotName    
 ,MR.Overview    
 ,MR.Description    
 --,TA.TargetApplicationName AS 'BotTargetApplicationName'    
 --,Z.BotTargetApplicationName AS 'BotTargetApplicationName'    
 ,case when Z.BotTargetApplicationName is null then TA.TargetApplicationName else Z.BotTargetApplicationName end 'BotTargetApplicationName'    
 ,case when X.PrimaryTechnologyName is null then PT.PrimaryTechnologyName else X.PrimaryTechnologyName  end 'TechnologyName'    
 --,PT.PrimaryTechnologyName AS 'TechnologyName'    
 --,X.PrimaryTechnologyName as 'TechnologyName'    
 ,BC.CategoryName AS 'BotCategoryName'    
 ,BN.Nature AS 'BotNatureId'    
 ,BT.Type AS 'BotTypeName'    
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
 ,MR.MakeVisible    
 ,MR.Source    
 ,MR.AutomationTechnology    
 ,MR.DomainID    
 ,MR.Benefits    
 ,MR.ProblemTypeID    
 ,MR.ActionType     
 ,MR.ExecutionSubTypeID    
 --,MR.AutomationTechnology    
 --,BDO.Domain    
 --,MR.Benefits    
 --,BPT.ProblemType    
 --,MR.ActionType     
 --,BEST.ExecutionSubType    
         
 INTO #Temp    
 FROM BOT.MasterRepository AS MR (NOLOCK)    
 LEFT JOIN BOT.BotType AS BT (NOLOCK) ON BT.Id=MR.BotTypeId    
 LEFT JOIN BOT.TargetApplication AS TA (NOLOCK) ON TA.Id=MR.BotTargetApplicationId    
 LEFT JOIN BOT.Category AS BC (NOLOCK) ON BC.Id=MR.BotCategoryId    
 LEFT JOIN BOT.Nature AS BN (NOLOCK) ON BN.Id=MR.BotNatureId    
 LEFT JOIN BOT.Reusability AS BR (NOLOCK) ON BR.Id=MR.BotReusabilityId    
 LEFT JOIN AVL.APP_MAS_PrimaryTechnology AS PT (NOLOCK) on PT.PrimaryTechnologyID=MR.TechnologyId    
 LEFT JOIN BOT.RecommendationDetails RD (NOLOCK) ON RD.BotID=MR.Id     
 LEFT JOIN #Rating UR (NOLOCK) ON UR.BotId = MR.Id AND UR.HealingTicketID = RD.HealingTicketID    
 JOIN avl.TK_MAS_Service CAT ON CAT.ServiceID=MR.ServiceId        
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
    
    CROSS APPLY    
    (    
     SELECT STUFF (    
      (     
       SELECT ',' +TA.TargetApplicationName FROM BOT.BotTargetApplicationMapping BT (NOLOCK)    
          join BOT.TargetApplication AS TA (NOLOCK) ON TA.Id=BT.BotTargetApplicationId    
       WHERE BT.BotTargetApplicationId =TA.Id and MR.Id =BT.BotId    
       FOR XML PATH('')     
      )    
     ,1,1,'') as BotTargetApplicationName    
    ) as Z    
    CROSS APPLY    
    (    
     SELECT STUFF (    
      (     
       SELECT ',' + MPT.PrimaryTechnologyName FROM BOT.[BotTechnologyMapping] BT (NOLOCK)    
          join AVL.APP_MAS_PrimaryTechnology AS MPT (NOLOCK) ON MPT.PrimaryTechnologyID=BT.[BotTechnologyId]    
       WHERE BT.[BotTechnologyId] =MPT.PrimaryTechnologyID and MR.Id =BT.BotId    
       FOR XML PATH('')     
      )    
     ,1,1,'') as PrimaryTechnologyName    
    ) as X    
 WHERE    
 ((BT.Id IN(SELECT BotType FROM #TempBotType (NOLOCK)) or @BotTypeFlag=0) AND     
 (TA.Id IN(SELECT ApplicationID FROM #TempTargetApplication (NOLOCK)) or @ApplicationFlag=0) AND     
 (MR.TechnologyId IN(SELECT TechID FROM #TempTechnology (NOLOCK)) or  @TechFlag=0 )AND      
 (MR.Source IN(SELECT Source FROM #TempSourceType (NOLOCK)) or  @SourceTypeFlag=0 )) AND      
    
 (MR.BotStatusId is null OR MR.BotStatusId=2 and (MakeVisible is null or MakeVisible=1  ))    
 --(SupportType IN(SELECT TagsID FROM #TempTags) or @TagsCount= 0))    
 --and MR.Id in(5042, 5021)    
     
     
 group by     
  MR.Id    
 ,MR.BotName    
 ,MR.Overview    
 ,MR.Description    
 --,TA.TargetApplicationName     
 ,TA.TargetApplicationName    
 ,Z.BotTargetApplicationName    
 ,PT.PrimaryTechnologyName     
 ,X.PrimaryTechnologyName    
 ,BC.CategoryName     
 ,BN.Nature    
 ,BT.Type    
 ,BR.Reusability    
 ,CAT.ServiceName     
 ,MR.BusinessProcessId    
 ,MR.SubBusinessProcessId    
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
 ,MR.MakeVisible    
 ,MR.source    
 ,MR.AutomationTechnology    
 ,MR.DomainID    
 ,MR.Benefits    
 ,MR.ProblemTypeID    
 ,MR.ActionType     
 ,MR.ExecutionSubTypeID    
 --,MR.AutomationTechnology    
 --,BDO.Domain    
 --,MR.Benefits    
 --,BPT.ProblemType    
 --,MR.ActionType     
 --,BEST.ExecutionSubType    
    
     
  select R.BotId, COUNT(DISTINCT R.BotRatingId) AS RatingCount     
 ,ISNULL(CAST(CAST(sum(R.Rating) AS NUMERIC)/CAST(COUNT(R.BotRatingId) AS NUMERIC)AS NUMERIC(18,1)),0) AS Rating into #RatingCount    
  from #Temp T (NOLOCK) left join #Rating R (NOLOCK) on T.Id=R.BotId group by R.BotId    
    
 update T set Rating=r.Rating,RatingCount=R.RatingCount from #temp T inner join #RatingCount R on R.BotId=T.Id    
    
 UPDATE #Temp SET RatingCount=0 WHERE RATING=0;    
 DECLARE @TotalTemp INT    
    
 SET @TotalTemp = (SELECT COUNT(Id) FROM #Temp (NOLOCK))    
    
 IF(@TotalTemp=0)    
     BEGIN    
  SELECT @TotalCount As TotalCount    
  END    
  ELSE    
  BEGIN    
   IF(@TagsCount>0)    
     BEGIN    
  ;with CTE(Tag)    
  as    
  (    
  SELECT '%'+(SELECT TagsID FROM #TempTags (NOLOCK) WHERE ID=1)+'%'    
  UNION ALL    
  SELECT '%'+(SELECT TagsID FROM #TempTags (NOLOCK) WHERE ID=2)+'%'    
  UNION ALL    
  SELECT '%'+(SELECT TagsID FROM #TempTags (NOLOCK) WHERE ID=3)+'%'     
  )    
  SELECT T.Id    
  ,T.TotalCount    
  ,T.BotName    
  ,T.Overview    
  ,T.Description    
  ,T.BotTargetApplicationName    
  ,T.TechnologyName    
  ,T.BotCategoryName    
  ,T.BotNatureId    
  ,T.BotTypeName    
 --- ,replace(T.BotReusabilityValue,'>=','') BotReusabilityValue    
     ,T.BotReusabilityValue    
  ,T.BotReusabilityValue       
  ,T.ServiceName       
  ,T.ServiceId    
  ,T.Author    
  ,T.ContactDL    
  ,T.IsManuallyCreated    
  ,T.BotStatusId    
  ,T.Tag    
  ,T.RatingCount    
  ,T.Rating    
  ,T.IsDeleted    
  ,T.CreatedBy    
  ,T.CreatedOn    
  ,T.ModifiedBy    
  ,T.ModifiedOn    
  ,T.MakeVisible    
  ,T.source    
  ,T.AutomationTechnology    
     ,T.Domain     
        ,T.Benefits    
     ,T.ProblemType    
     ,T.ActionType    
     ,T.ExecutionSubType    
  FROM #Temp AS T (NOLOCK)    
  where exists ((select Tag from CTE  where T.TotalCount LIKE Tag     
  OR T.BotName LIKE Tag    
  OR T.Overview LIKE Tag    
  OR T.Description LIKE Tag    
  OR T.BotTargetApplicationName LIKE Tag    
  OR T.TechnologyName LIKE Tag    
  OR T.BotCategoryName LIKE Tag    
  OR T.BotNatureId LIKE Tag    
  OR T.BotTypeName LIKE Tag    
  OR T.BotReusabilityValue LIKE Tag    
  OR T.BotReusabilityValue LIKE Tag    
  OR T.ServiceName LIKE Tag        
  OR T.ServiceId LIKE Tag    
  OR T.Author LIKE Tag    
  OR T.ContactDL LIKE Tag    
  OR T.ServiceId LIKE Tag    
  OR T.Tag LIKE Tag    
  OR T.AutomationTechnology Like Tag    
     OR T.DomainID  like Tag    
        OR T.Benefits like Tag    
     OR T.ProblemTypeID like Tag    
     OR T.ActionType like Tag    
     OR T.ExecutionSubTypeID like Tag))    
  order by Rating desc--,CreatedOn desc    
  END    
 ELSE    
  BEGIN    
  SELECT T.Id    
  ,T.TotalCount    
  ,T.BotName    
  ,T.Overview    
  ,T.Description    
  ,T.BotTargetApplicationName    
  ,T.TechnologyName    
  ,T.BotCategoryName    
  ,T.BotNatureId    
  ,T.BotTypeName    
  --,replace(T.BotReusabilityValue,'>=','') BotReusabilityValue    
  ,T.BotReusabilityValue    
  ,T.BotReusabilityValue     
  ,T.ServiceName        
  ,T.ServiceId    
  ,T.Author    
  ,T.ContactDL    
  ,T.IsManuallyCreated    
  ,T.BotStatusId    
  ,T.Tag    
  ,T.RatingCount    
  ,T.Rating    
  ,T.IsDeleted    
  ,T.CreatedBy    
  ,T.CreatedOn    
  ,T.ModifiedBy    
  ,T.ModifiedOn    
  ,T.MakeVisible    
  ,T.source    
  ,T.AutomationTechnology    
     ,T.DomainID     
        ,T.Benefits    
     ,T.ProblemTypeID    
     ,T.ActionType    
     ,T.ExecutionSubTypeID    
  FROM #Temp AS T (NOLOCK)    
  order by Rating desc--,CreatedOn desc    
  END    
  END    
    
    
      
  SET NOCOUNT OFF;    
  END TRY    
  BEGIN CATCH    
 DECLARE @ErrorMessage VARCHAR(MAX);    
 SELECT @ErrorMessage = ERROR_MESSAGE()    
 --INSERT Error        
 EXEC AVL_InsertError '[BOT].[GetDetailsForBOTRepository]', @ErrorMessage, '',''    
 RETURN @ErrorMessage    
  END CATCH    
END
