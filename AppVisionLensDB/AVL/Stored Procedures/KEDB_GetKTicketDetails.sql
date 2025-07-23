/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    
--[AVL].[KEDB_GetKTicketDetails]  '103127','K4347800000004','761638'    
CREATE PROCEDURE [AVL].[KEDB_GetKTicketDetails]         
  (                         
    @ProjectID BIGINT  ,        
 @HealingTicketID NVARCHAR(100),        
 @UserId NVARCHAR(50)        
  )        
AS        
BEGIN       
  SET NOCOUNT ON;           
BEGIN TRY         
        
DECLARE @TicketType char(1) = 'K'        
        
CREATE TABLE #KTicket_ProjectPatternMapping(        
 [ProjectPatternMapID] [bigint] NULL,        
 [ProjectID] [bigint] NOT NULL,        
 [ApplicationID] [bigint] NULL,         
 [ResolutionCode] [varchar](50) NULL,        
 [CauseCode] [varchar](50) NULL,        
 [DebtClassificationId]  [varchar](50) NULL,        
 [AvoidableFlag]  [varchar](50) NULL,         
 --[TicketType] [char](1) NULL,        
 [PatternFrequency] [int] NULL,        
 [PatternStatus] [int] NULL,        
 [IsDeleted] bit NULL,        
 [IsManual] bit NULL        
 )        
        
 INSERT INTO #KTicket_ProjectPatternMapping        
    Select ProjectPatternMapID,ProjectID,        
    ApplicationID = xDim.value('/x[1]','varchar(max)')         
    , ResolutionCode = xDim.value('/x[2]','varchar(max)')         
    ,CauseCode= xDim.value('/x[3]','varchar(max)')        
    ,DebtClassificationId = xDim.value('/x[4]','varchar(max)')        
    ,AvoidableFlag = xDim.value('/x[5]','varchar(max)')         
    --,A.TicketType        
    ,A.PatternFrequency        
    ,A.PatternStatus,        
    A.IsDeleted        
    ,A.IsManual        
    From  (Select ProjectPatternMapID AS ProjectPatternMapID,ProjectID AS ProjectID,Cast('<x>' + replace(HealPattern,'-','</x><x>')+'</x>' as xml) as xDim,        
      --TicketType AS TicketType,        
      PatternFrequency,PatternStatus,IsManual,IsDeleted        
      FROM [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) WHERE ProjectID=@ProjectID        
       AND ISNULL(ManualNonDebt,0) != 1 and ResidualDebtId = 1 and patternstatus=1 and IsDeleted=0        
      ) as A         
        
      
  SELECT     
  --Top 1        
  HTD.HealingTicketID        
  ,HPC.DARTTicketID          
  ,AM.ApplicationName        
  ,DRS.ResolutionCode AS ResolutionCode        
  ,DCS.CauseCode AS CauseCode        
  ,DCM.DebtClassificationName AS DebtClassificationName        
  ,AFM.AvoidableFlagName AS AvoidableFlagname        
  ,isnull(HTD.PriorityID,0) PriorityID          
  --,sum(TM.EffortTilldate) as Effort        
  ,HTD.DARTStatusID AS StatusID        
  ,SM.DARTStatusName         
  ,HTD.TicketDescription        
  --,count(DISTINCT DARTTicketID) as Occurrence        
  ,HTD.CreatedDate        
  ,HTd.Closeddate,    
  CASE WHEN  KATicketId != '' and datediff(day,HTD.CreatedDate,Getdate())>30 then 1    
  WHEN (KATicketId is null or KATicketId='') and datediff(day,HTD.CreatedDate,Getdate())>30  then 2    
  WHEN (KATicketId is not null or KATicketId !='') and datediff(day,HTD.CreatedDate,Getdate())<30  then 3    
  WHEN (KATicketId is null or KATicketId='') and datediff(day,HTD.CreatedDate,Getdate())<30  then 0     
  else -1 end as [Kcancelmsg],    
 (SELECT OptionID FROM [AVL].[MAS_KTicketCancelOptions] WHERE OptionName=HTD.ReasonForCancellation) as [CancelOptionId],    
  HTD.Comments as CancelReason,    
  HTD.CancellationDate as CancelDate    
  INTO #HealTickets    
  FROM [AVL].[DEBT_TRN_HealTicketDetails] HTD (NOLOCK) INNER JOIN #KTicket_ProjectPatternMapping HPPM         
  ON HTD.ProjectPatternMapID = HPPM.ProjectPatternMapID        
  INNER JOIN [AVL].[DEBT_MAP_CauseCode] DCS (nolock) ON DCS.CauseID = HPPM.CauseCode AND DCS.IsDeleted=0        INNER JOIN [AVL].[APP_MAS_ApplicationDetails] AM (NOLOCK) ON HPPM.ApplicationID = AM.ApplicationID --AND AM.IsDeleted=0            
  INNER JOIN [AVL].[DEBT_MAP_ResolutionCode] DRS (NOLOCK) ON DRS.ResolutionID = HPPM.ResolutionCode AND DRS.IsDeleted =0        
  INNER JOIN [AVL].[DEBT_PRJ_HealParentChild] HPC (NOLOCK) ON HPC.ProjectPatternMapID = HTD.ProjectPatternMapID AND HPC.IsDeleted=0           
    -- INNER JOIN #TicketMasterDetails TM (NOLOCK) ON  TM.TicketID = HPC.DARTTicketID AND  TM.IsDeleted =0 AND TM.ProjectID = @ProjectID        
  LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] AFM (NOLOCK) ON HPPM.AvoidableFlag = AFM.AvoidableFlagID AND AFM.IsDeleted=0        
  LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] (NOLOCK) DCM ON HPPM.DebtClassificationId = DCM.DebtClassificationID AND DCM.IsDeleted=0               
  LEFT JOIN [AVL].[TK_MAS_DARTTicketStatus] SM (NOLOCK) ON SM.DARTStatusID = HTD.DARTStatusID AND SM.IsDeleted=0        
  LEFT JOIN [AVL].[TK_MAP_PriorityMapping] PM (NOLOCK) ON PM.PriorityIDMapID = HTD.PriorityID AND PM.IsDeleted=0        
  LEFT JOIN AVL.KEDB_TRN_KTicketMapping KTM (NOLOCK) on KTM.KTicketId = HTD.HealingTicketID and IsMapped=1 AND KTM.IsDeleted=0    
  --LEFT JOIN [AVL].[KEDB_KTicketCanceldetails] KC(NOLOCK) on  KC.KTicketId = HTD.HealingTicketID-- and IsMapped=1      
  WHERE HPPM.ProjectID = @ProjectID AND HTD.HealingTicketID = @HealingTicketID AND ((HTD.DARTStatusID in(8))       
           OR (ISNULL(HTD.DARTStatusID,0)<>8 AND HPC.MapStatus=1)) AND ISNULL(HTD.ManualNonDebt,0) != 1  AND HPC.isdeleted=0        
    
    
  SELECT TOP 1 HD.HealingTicketID        
  ,HD.ApplicationName        
  ,HD.ResolutionCode        
  ,HD.CauseCode        
  ,HD.DebtClassificationName        
  ,HD.AvoidableFlagname        
  ,HD.PriorityID        
  ,sum(TD.EffortTilldate) as Effort       
  ,HD.StatusID         
  ,HD.DARTStatusName         
  ,HD.TicketDescription       
  ,count(DISTINCT DARTTicketID) as Occurrence        
  ,HD.CreatedDate        
  ,HD.Closeddate       
  ,Case HD.StatusID        
    When  8 then  datediff(d,HD.createddate,HD.closeddate)        
    else         
        datediff(d,HD.createddate,getdate())         
     end  OpenDuration        
  , 'Yes' as Residual    
  ,Kcancelmsg    
  ,isnull(CancelOptionId,0)[CancelOptionId]    
  ,CancelReason    
  ,CancelDate    
  FROM  #HealTickets HD  (NOLOCK)     
  INNER JOIN [AVL].[TK_TRN_TicketDetail] TD  ON  TD.TicketID = HD.DARTTicketID AND  TD.IsDeleted =0 --AND TD.ProjectID = @ProjectID    
  WHERE    
  TD.ProjectID = @ProjectId    AND    
  HD.HealingTicketID = @HealingTicketID    
   GROUP BY HD.HealingTicketID        
  ,HD.ApplicationName        
  ,HD.ResolutionCode        
  ,HD.CauseCode        
  ,HD.DebtClassificationName        
  ,HD.AvoidableFlagName        
  ,HD.PriorityID         
  ,HD.StatusID         
  ,HD.DARTStatusName         
  ,HD.TicketDescription        
  ,HD.CreatedDate        
  ,HD.Closeddate      
 ,Kcancelmsg    
  ,CancelOptionId    
  ,CancelReason    
  ,CancelDate    
        
  drop table #KTicket_ProjectPatternMapping             
  drop table #HealTickets     
        
   END TRY        
  BEGIN CATCH        
  DECLARE @ErrorMessage VARCHAR(4000);        
 SELECT @ErrorMessage = ERROR_MESSAGE()        
  --INSERT Error            
  EXEC AVL_InsertError '[AVL].[KEDB_GetKTicketDetails] ', @ErrorMessage,@UserId,@ProjectID        
  RETURN @ErrorMessage        
  END CATCH     
  SET NOCOUNT OFF;    
END
