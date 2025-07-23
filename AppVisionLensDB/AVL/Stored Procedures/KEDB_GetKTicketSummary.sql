/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetKTicketSummary]
  (	                
   @AppID VARCHAR(1000) ,                
    @ProjectID BIGINT  ,
	@DartStatusID VARCHAR(200) = '',
	@DateFrom datetime=null,
	@DateTo datetime=null,
	@KALinked  varchar(10)=null 
  )
AS
BEGIN  
BEGIN TRY 
  SET NOCOUNT ON;
  DECLARE @TicketType char(1) = 'K'


   IF @DateFrom IS NULL OR @DateFrom = ''
  BEGIN
       SET @DateFrom = DATEADD(month, -1, GETDATE()) 
  END
  IF @DateTo IS NULL OR @DateTo = ''
  BEGIN
       SET @DateTo = GETDATE()
  END

  SELECT Item INTO #AppIDs FROM dbo.Split(@AppID,',')
  SELECT Item INTO #DartStatusIDs FROM dbo.Split(@DartStatusID,',')

  --Get the ProjectPattern Map id for the project and application
  SELECT ProjectID,ApplicationID,ProjectPatternMapID into #ProjectPatternMapping FROM 
  avl.DEBT_PRJ_HealProjectPatternMappingDynamic  HPPMD (nolock)
  join #AppIDs a on a.Item = HPPMD.ApplicationID
  WHERE projectid = @ProjectID and HPPMD.ResidualDebtId = 1 and PatternStatus=1 and isdeleted=0
-- select * from #ProjectPatternMapping

SELECT distinct HTD.HealingTicketID ,DARTStatusName,DartTicketId --sum(EffortTillDate) Effort 
 INTO #Final
 FROM avl.DEBT_TRN_HealTicketDetails  HTD (nolock)
  INNER JOIN #ProjectPatternMapping PPM ON HTD.ProjectPatternMapID=PPM.ProjectPatternMapID  	   
 inner join avl.DEBT_PRJ_HealParentChild HPC (nolock) ON
  --HPC.HealingTicketID = HTD.HealingTicketID and
  HPC.ProjectPatternMapID =HTD.ProjectPatternMapID
   inner join  avl.TK_MAS_DARTTicketStatus DTS (nolock) on 
  HTD.DARTStatusID = DTS.DARTStatusID 
  INNER JOIN AVL.APP_MAP_ApplicationProjectMapping  APM (nolock) on 
  APM.ApplicationID = PPM.ApplicationID and APM.IsDeleted=0
  INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON 
  APM.ApplicationID=AD.ApplicationID AND AD.IsActive=1 
  inner join #AppIDs  App on App.Item = APM.ApplicationID
  inner join #DartStatusIDs  S on S.Item = DTS.DartStatusID
  WHERE HTD.TicketType =@TicketType and HPC.IsDeleted=0 and HPC.MapStatus = 1
    and PPM.ProjectID = @ProjectID-- 44639 --20063  
  and 	(CONVERT(DATE, HTD.CreatedDate) BETWEEN CONVERT(DATE, @DateFrom)  AND CONVERT(DATE, @DateTo))
 
 SELECT distinct HealingTicketID ,DARTStatusName,sum(EffortTillDate) Effort  into #EffortTable
  from  #Final F
  INNER JOIN [AVL].[TK_TRN_TicketDetail] (NOLOCK) TM ON TM.TicketID = F.DARTTicketID 
 AND TM.ProjectID = @ProjectID 
 AND TM.IsDeleted = 0 
  GROUP BY HealingTicketID ,DARTStatusName
 
 
 declare @KTicketCount int
 declare @KTicketEffort varchar(10)
 declare @OpenTicketCount int
 declare @OpenTicketEffort varchar(10) 
 declare @KACount int

 SELECT @KTicketCount =count(HealingTicketID) ,@KTicketEffort =sum(Effort) 
  FROM #EffortTable

   SELECT @OpenTicketCount =count(HealingTicketID) ,@OpenTicketEffort =isnull(sum(Effort),0) 
  FROM #EffortTable where (DARTStatusName ='Open' Or DARTStatusName = 'Not Assigned')

   SELECT @KTicketCount as KTicketCount,@KTicketEffort as KTicketEffort,
   @OpenTicketCount as OpenTicketCount, @OpenTicketEffort as OpenTicketEffort,
   @KTicketCount as KACount

  drop table #AppIDs
  drop table #DartStatusIDs
  drop table #ProjectPatternMapping
  drop table #Final
  drop table #EffortTable

  END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[KEDB_GetKTicketSummary]', @ErrorMessage, @ProjectID,@AppID
		RETURN @ErrorMessage
  END CATCH   
END
