create   PROCEDURE [AVL].[KEDB_GetKTicketSearchDetails] --'1,22,679','10337','1,2','','',1,1,10      
  (                       
                         
    @AppID VARCHAR(1000),                      
    @ProjectID BIGINT,      
 @DartStatusID VARCHAR(200) = '',      
 @DateFrom datetime=null,      
 @DateTo datetime=null,      
 @IsCognizant bit,      
 @KALinked  varchar(10)=null,      
 @PageNumber int,      
 @RowspPage int      
  )      
AS      
BEGIN        
BEGIN TRY       
  SET NOCOUNT ON;      
        
        
  DECLARE @NotAssignedDartStatus Varchar(20)=''      
  DECLARE @AppIDs TABLE(ApplicationId BIGINT)      
  DECLARE @DartStatusIDs TABLE(StatusId BIGINT)      
  DECLARE @TicketType char(1) = 'K'      
              
  IF @DateFrom IS NULL OR @DateFrom = ''      
  BEGIN      
       SET @DateFrom = DATEADD(month, -1, GETDATE())       
  END      
  IF @DateTo IS NULL OR @DateTo = ''      
  BEGIN      
       SET @DateTo = GETDATE()      
  END      
      
      
  INSERT INTO @AppIDs      
    SELECT Item  FROM dbo.Split(@AppID,',')      
      
  INSERT INTO @DartStatusIDs      
     SELECT Item  FROM dbo.Split(@DartStatusID,',')      
      
  --GEt the ProjectPattern Map id for the project and application      
  SELECT ProjectID,a.ApplicationID,ProjectPatternMapID INTO #ProjectPatternMapping FROM       
  avl.DEBT_PRJ_HealProjectPatternMappingDynamic  HPPMD  With (nolock)      
  inner JOIN  @AppIDs a  on a.ApplicationId = HPPMD.ApplicationID      
  WHERE projectid = @ProjectID AND HPPMD.ResidualDebtId = 1 and PatternStatus=1 and isdeleted=0      
      
 -- select * from #ProjectPatternMapping      
      
SELECT DISTINCT HTD.HealingTicketID,HTD.TicketDescription,DARTStatusName,ApplicationName,      
DARTTicketID, ISNULL(PriorityID,0) PriorityID into #KTickets      
 FROM avl.DEBT_TRN_HealTicketDetails  HTD With (nolock)      
 INNER JOIN #ProjectPatternMapping PPM ON HTD.ProjectPatternMapID=PPM.ProjectPatternMapID       
 inner join avl.DEBT_PRJ_HealParentChild HPC (nolock) on      
  --HPC.HealingTicketId = HTD.HealingTicketID --and      
   HPC.ProjectPatternMapID =HTD.ProjectPatternMapID      
   inner join  avl.TK_MAS_DARTTicketStatus DTS (nolock) on       
  HTD.DARTStatusID = DTS.DARTStatusID       
  INNER JOIN AVL.APP_MAP_ApplicationProjectMapping  APM (nolock) on       
  APM.ApplicationID = PPM.ApplicationId and APM.IsDeleted=0      
  INNER JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) ON       
  APM.ApplicationID=AD.ApplicationID AND AD.IsActive=1      
   inner join @AppIDs  App on App.ApplicationId = APM.ApplicationID      
  inner join @DartStatusIDs  S on S.StatusId = DTS.DartStatusID      
   WHERE HTD.TicketType =@TicketType and HPC.IsDeleted=0 and HPC.MapStatus =1      
   AND HTD.DARTStatusID NOT IN(5,7,13)  -- cancelled / rejected      
  -- and HPC.pro = @ProjectID       
  and  (CONVERT(DATE, DATEADD(HOUR, 5, DATEADD(MINUTE, 30, HTD.CreatedDate)))  BETWEEN CONVERT(DATE, @DateFrom)  AND CONVERT(DATE, @DateTo))    and HTD.IsDeleted=0  
        
      
--select * from #KTickets      
  SELECT DISTINCT HealingTicketID,k.TicketDescription,DARTStatusName,ApplicationName,      
  count(DARTTicketID) as Occurrence,sum(TM.EffortTillDate) Effort,PriorityId,      
   Case       
    when KATicketId != '' then 'Yes'      
 else  'No'      
 end as  KALinked,KATicketId      
  FROM #KTickets k With (NOLOCK)     
  INNER JOIN [AVL].[TK_TRN_TicketDetail]  TM (NOLOCK) ON TM.TicketID = DARTTicketID       
  AND TM.ProjectID = @ProjectID    AND TM.IsDeleted = 0       
  LEFT JOIN AVL.KEDB_TRN_KTicketMapping KTM (NOLOCK) on KTM.KTicketId = K.HealingTicketID and IsMapped=1      
  AND KTM.IsDeleted=0      
  GROUP BY HealingTicketID,k.TicketDescription,      
   DARTStatusName,ApplicationName,PriorityID,KATicketId      
         
   ORDER BY HealingTicketID       
  -- OFFSET ((@PageNumber - 1) * @RowspPage) ROWS      
  -- FETCH NEXT @RowspPage ROWS ONLY;      
      
      
  drop table #ProjectPatternMapping      
  drop table #KTickets      
     SET NOCOUNT OFF      
  END TRY      
  BEGIN CATCH      
  DECLARE @ErrorMessage VARCHAR(4000);      
 SELECT @ErrorMessage = ERROR_MESSAGE()      
  --INSERT Error          
  EXEC AVL_InsertError '[AVL].[KEDB_GetKTicketSearchDetails] ', @ErrorMessage, 0,@ProjectID      
  RETURN @ErrorMessage      
  END CATCH         
END 
