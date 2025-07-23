

 
  
CREATE   PROCEDURE [AVL].[KEDB_GetReMapKTicketDetails]   
  (                   
    @ProjectID BIGINT,  
 @DateFrom datetime=null,  
 @DateTo datetime=null,                 
    @AppID VARCHAR(1000) ,  
 @ServiceID VARCHAR(1000),  
 @CauseID VARCHAR(1000),  
 @ResolutionID VARCHAR(1000)  
  )  
AS  
BEGIN    
BEGIN TRY   
  SET NOCOUNT ON;  
    
    
  DECLARE @NotAssignedDartStatus Varchar(20)=''  
  DECLARE @AppIDs TABLE(ApplicationId BIGINT)  
  DECLARE @ServiceIDs TABLE(ServiceId BIGINT)  
  DECLARE @CauseIDs TABLE(CauseId BIGINT)  
  DECLARE @ResolutionIDs TABLE(ResolutionId BIGINT)  
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
  
  INSERT INTO @ServiceIDs  
    SELECT Item  FROM dbo.Split(@ServiceID,',')  
  
  INSERT INTO @CauseIDs  
    SELECT Item  FROM dbo.Split(@CauseID,',')  
  
  INSERT INTO @ResolutionIDs  
    SELECT Item  FROM dbo.Split(@ResolutionID,',')  
  
  CREATE TABLE #ProjectPatternMapping(  
 [ProjectID] [int] NOT NULL,  
 [ApplicationID] [int] NULL,   
 [ProjectPatternMapID] bigint not null,  
 [ResolutionCodeId] [varchar](50) NULL,  
 [CauseCodeId] [varchar](50) NULL,  
)  
  
  --GEt the ProjectPattern Map id,resolution,causecode for the project and application   
   INSERT INTO #ProjectPatternMapping  
    Select ProjectID,a.ApplicationID,ProjectPatternMapID,  
     ResolutionCodeId = xDim.value('/x[2]','varchar(max)')   
    ,CauseCodeId= xDim.value('/x[3]','varchar(max)')     
    From  (  
      SELECT ProjectID,a.ApplicationID,ProjectPatternMapID,  
      CAST('<x>' + replace(HealPattern,'-','</x><x>')+'</x>' as xml) as xDim FROM   
      avl.DEBT_PRJ_HealProjectPatternMappingDynamic  HPPMD (nolock)  
      JOIN  @AppIDs a on a.ApplicationId = HPPMD.ApplicationID  
      WHERE projectid = @ProjectID and ResidualDebtId = 1 and PatternStatus=1 and isdeleted=0  
  ) as A  
  
 -- filter #ProjectPatternMapping with applciatonid,causeid,rolutionid  
SELECT DISTINCT HTD.HealingTicketID,ApplicationName,CauseCode,ResolutionCode into #KTickets  
 FROM avl.DEBT_TRN_HealTicketDetails  HTD (nolock)  
 INNER JOIN #ProjectPatternMapping PPM ON HTD.ProjectPatternMapID=PPM.ProjectPatternMapID   
 inner join avl.DEBT_PRJ_HealParentChild HPC (nolock) on  
  --HPC.HealingTicketID = HTD.HealingTicketID and   
  HPC.ProjectPatternMapID =HTD.ProjectPatternMapID  
  --applicaiton join  
  INNER JOIN AVL.APP_MAP_ApplicationProjectMapping  APM (nolock) on   
  APM.ApplicationID = PPM.ApplicationID and APM.IsDeleted=0  
  INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON   
  APM.ApplicationID=AD.ApplicationID AND AD.IsActive=1  
   inner join @AppIDs  App on App.ApplicationId = APM.ApplicationID  
  --cause code  
  inner join [AVL].[DEBT_MAP_CauseCode] DMC (nolock) on DMC.CauseID= PPM.CauseCodeId and DMC.IsDeleted=0  
  inner join @CauseIDs cau on cau.CauseId= PPM.CauseCodeId  
  --resolution code  
  inner join [AVL].[DEBT_MAP_ResolutionCode] DMR (nolock) on DMR.ResolutionID=PPM.ResolutionCodeId and DMR.IsDeleted=0  
  inner join @ResolutionIDs res on res.ResolutionId= PPM.ResolutionCodeId  
  --inner join @DartStatusIDs  S on S.StatusId = DTS.DartStatusID  
  
   WHERE HTD.TicketType =@TicketType and HPC.IsDeleted=0 and HPC.MapStatus = 1  
   AND HTD.DARTStatusID NOT IN(5,7,13)  -- cancelled / rejected  
   and PPM.ProjectID = @ProjectID   
  and  (CONVERT(DATE, DATEADD(HOUR, 5, DATEADD(MINUTE, 30, HTD.CreatedDate))) BETWEEN CONVERT(DATE, @DateFrom)  AND CONVERT(DATE, @DateTo))  
  
--select all service id of k-ticket   
  SELECT DISTINCT HealingTicketID,ApplicationName,CauseCode,ResolutionCode,  
   Case   
    when KATicketId != '' then 'Yes'  
 else  'No'  
 end as  KALinked,KATicketId,ServiceId= STUFF  
    ((  
  SELECT DISTINCT ','+ CAST(ServiceID AS VARCHAR(400))   
      FROM  [AVL].[DEBT_PRJ_HealParentChild] HPC (nolock)  
     Inner Join avl.DEBT_TRN_HealTicketDetails  HTD on HTD.ProjectPatternMapID = Hpc.ProjectPatternMapID        
          INNER JOIN [AVL].[TK_TRN_TicketDetail] TM ON  TM.TicketID = HPC.DARTTicketID AND   
       TM.IsDeleted =0 AND TM.ProjectID = @ProjectID AND HPC.IsDeleted=0 AND TM.IsDeleted=0   
      Where Htd.HealingTicketID = k.HealingTicketID    
       FOR XMl PATH('')   
      ),1,1,''  
  )  
  FROM #KTickets k  
  LEFT JOIN AVL.KEDB_TRN_KTicketMapping KTM on KTM.KTicketId = K.HealingTicketID and IsMapped=1  
  AND KTM.IsDeleted=0  
  GROUP BY HealingTicketID,ApplicationName,CauseCode,ResolutionCode,KATicketId  
   ORDER BY HealingTicketID   
  
  drop table #ProjectPatternMapping  
  drop table #KTickets  
       
  END TRY  
  BEGIN CATCH  
  DECLARE @ErrorMessage VARCHAR(4000);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[KEDB_GetReMapKTicketDetails] ', @ErrorMessage, 0,@ProjectID  
  RETURN @ErrorMessage  
  END CATCH     
END 
