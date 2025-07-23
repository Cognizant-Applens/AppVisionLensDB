-- =============================================  
-- Author:  <Author,663960,Arul>  
-- Create date: <02/27/2020>  
-- Description: <Description,,>  
--[BOT].[ProjectBotRecommendationDetails] 41318,'A2639600000024',1  
-- =============================================  
CREATE PROCEDURE [BOT].[ProjectBotRecommendationDetails]  
@ProjectID  BIGINT,  
@HealTicketID NVARCHAR(200),  
@ATicketType int  
AS  
BEGIN
SET NOCOUNT ON;  
BEGIN TRY  
 if @ATicketType=1  
 begin  
  select distinct MR.ID,RD.BotId,RD.ProjectID,isnull(sum(RD.SimilarityScore),0)as SimilarityScore,RD.IsMapped,RD.HealingTicketID,MR.BotName  
  ,MR.Overview,MR.[Description],TA.TargetApplicationName as TargetApplication  
  ,TECH.PrimaryTechnologyName AS Technology,CAT.CategoryName AS Category,NAT.Nature,BT.[Type] BotType,REU.Reusability  
  ,BPM.BusinessProcessName as BusinessProcess,BPS.BusinessProcessName AS SubBusinessProcess  
  ,SCAT.ServiceName ServiceCatalog,MR.Author,MR.ContactDL,RAT.Rating   
  from BOT.MasterRepository MR (NOLOCK) 
  join [BOT].[RecommendationDetails] RD (NOLOCK) on RD.BotID=MR.Id and isnull(RD.IsDeleted,0)=0 and RD.ProjectID=@ProjectID  
  INNER JOIN AVL.DEBT_TRN_HealTicketDetails H (NOLOCK) ON H.HealingTicketID = RD.HealingTicketID and H.IsDeleted=0 AND ISNULL(H.ManualNonDebt,0) = 0  
  INNER JOIN AVL.DEBT_PRJ_HealParentChild  NDC (NOLOCK) ON NDC.ProjectPatternMapId = H.ProjectPatternMapId and NDC.IsDeleted=0 and NDC.MapStatus=1  
  left join BOT.TargetApplication TA (NOLOCK) on TA.Id=MR.BotTargetApplicationId and isnull(TA.IsDeleted,0)=0  
  LEFT JOIN AVL.APP_MAS_PrimaryTechnology TECH (NOLOCK) on MR.TechnologyId=TECH.PrimaryTechnologyID and isnull(TECH.IsDeleted,0)=0  
  left join BOT.Category CAT (NOLOCK) ON CAT.Id=MR.BotCategoryId and isnull(CAT.IsDeleted,0)=0  
  left join BOT.Nature NAT (NOLOCK) on NAT.Id=MR.BotNatureId and isnull(NAT.IsDeleted,0)=0  
  left join BOT.BotType BT (NOLOCK) on BT.Id=MR.BotTypeId and isnull(RD.IsDeleted,0)=0  
  left join BOT.Reusability REU (NOLOCK) on MR.BotReusabilityId=REU.Id and isnull(REU.IsDeleted,0)=0  
  LEFT JOIN BusinessOutCome.MAS.BusinessProcessMaster BPM (NOLOCK) ON BPM.BusinessProcessId=MR.BusinessProcessID and isnull(BPM.IsActive,0)=0  
  LEFT JOIN BusinessOutCome.mas.BusinessProcessMaster BPS (NOLOCK) ON BPS.BusinessProcessId = MR.SubBusinessProcessID and isnull(BPS.IsActive,0)=0  
  LEFT JOIN AVL.TK_MAS_Service SCAT (NOLOCK) ON SCAT.ServiceID=MR.ServiceId and isnull(SCAT.IsDeleted,0)=0  
  left join BOT.RecommendedRatings RAT (NOLOCK) ON RAT.BotId=MR.Id and  RD.HealingTicketID = RAT.HealingTicketID and isnull(RAT.IsDeleted,0)=0  
  WHERE RD.HealingTicketID = @HealTicketID AND RD.ProjectID = @ProjectID   
  group by  
  MR.ID,RD.BotId,RD.ProjectID,RD.IsMapped,RD.HealingTicketID,MR.BotName,MR.Overview,MR.[Description],TA.TargetApplicationName  
  ,TECH.PrimaryTechnologyName ,CAT.CategoryName ,NAT.Nature,BT.[Type] ,REU.Reusability  
  ,BPM.BusinessProcessName ,BPS.BusinessProcessName   
  ,SCAT.ServiceName ,MR.Author,MR.ContactDL,RAT.Rating   
  order by RD.IsMapped desc ,SimilarityScore DESC  
 end  
 else if @ATicketType=2  
  select distinct MR.ID,RD.BotId,RD.ProjectID,isnull(sum(RD.SimilarityScore),0)as SimilarityScore,RD.IsMapped,RD.HealingTicketID,MR.BotName,MR.Overview,MR.[Description],TA.TargetApplicationName as TargetApplication  
  ,TECH.PrimaryTechnologyName AS Technology,CAT.CategoryName AS Category,NAT.Nature,BT.[Type] BotType,REU.Reusability  
  ,BPM.BusinessProcessName as BusinessProcess,BPS.BusinessProcessName AS SubBusinessProcess  
  ,SCAT.ServiceName ServiceCatalog,MR.Author,MR.ContactDL,RAT.Rating   
  from BOT.MasterRepository MR (NOLOCK) 
  join [BOT].[RecommendationDetails] RD (NOLOCK) on RD.BotID=MR.Id and isnull(RD.IsDeleted,0)=0 and RD.ProjectID=@ProjectID  
  INNER JOIN AVL.DEBT_TRN_HealTicketDetails DTHTD (NOLOCK) ON DTHTD.HealingTicketID = RD.HealingTicketID and DTHTD.IsDeleted=0 AND ISNULL(DTHTD.ManualNonDebt,0) = 1  
     INNER JOIN AVL.DEBT_PRJ_NonDebtParentChild NDC (NOLOCK) ON NDC.ProjectPatternMapId = DTHTD.ProjectPatternMapId and NDC.IsDeleted=0 and isnull(NDC.MapStatus,0)=1  
  join BOT.TargetApplication TA (NOLOCK) on TA.Id=MR.BotTargetApplicationId and isnull(TA.IsDeleted,0)=0  
  LEFT JOIN AVL.APP_MAS_PrimaryTechnology TECH (NOLOCK) on MR.TechnologyId=TECH.PrimaryTechnologyID and isnull(TECH.IsDeleted,0)=0  
  left join BOT.Category CAT (NOLOCK) ON CAT.Id=MR.BotCategoryId and isnull(CAT.IsDeleted,0)=0  
  left join BOT.Nature NAT (NOLOCK) on NAT.Id=MR.BotNatureId and isnull(NAT.IsDeleted,0)=0  
  left join BOT.BotType BT (NOLOCK) on BT.Id=MR.BotTypeId and isnull(RD.IsDeleted,0)=0  
  left join BOT.Reusability REU (NOLOCK) on MR.BotReusabilityId=REU.Id and isnull(REU.IsDeleted,0)=0  
  LEFT JOIN BusinessOutCome.MAS.BusinessProcessMaster BPM (NOLOCK) ON BPM.BusinessProcessId=MR.BusinessProcessID and isnull(BPM.IsActive,0)=0  
  LEFT JOIN BusinessOutCome.mas.BusinessProcessMaster BPS (NOLOCK) ON BPS.BusinessProcessId = MR.SubBusinessProcessID and isnull(BPS.IsActive,0)=0  
  LEFT JOIN AVL.TK_MAS_Service SCAT (NOLOCK) ON SCAT.ServiceID=MR.ServiceId and isnull(SCAT.IsDeleted,0)=0  
  left join BOT.RecommendedRatings RAT (NOLOCK) ON RAT.BotId=MR.Id and  RD.HealingTicketID = RAT.HealingTicketID and isnull(RAT.IsDeleted,0)=0  
  WHERE RD.HealingTicketID = @HealTicketID AND RD.ProjectID = @ProjectID   
  group by  
  MR.ID,RD.BotId,RD.ProjectID,RD.IsMapped,RD.HealingTicketID,MR.BotName,MR.Overview,MR.[Description],TA.TargetApplicationName  
  ,TECH.PrimaryTechnologyName ,CAT.CategoryName ,NAT.Nature,BT.[Type] ,REU.Reusability  
  ,BPM.BusinessProcessName ,BPS.BusinessProcessName   
  ,SCAT.ServiceName ,MR.Author,MR.ContactDL,RAT.Rating   
  order by RD.IsMapped desc ,SimilarityScore DESC
SET NOCOUNT OFF;  
END TRY  
  
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  EXEC AVL_InsertError '[BOT].[ProjectBotRecommendationDetails]', @ErrorMessage, '', ''   
    
 END CATCH    
END
