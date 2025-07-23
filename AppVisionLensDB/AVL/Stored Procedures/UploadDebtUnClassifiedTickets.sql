/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [AVL].[UploadDebtUnClassifiedTickets]  
(  
@ProjectId BIGINT,  
@SupportType INT,  
@UserId NVARCHAR(50),  
@TVP_DebtUnclassifiedTicketDetails AVL.DebtUnclassifiedTicketDetails READONLY)  
AS   
BEGIN  
BEGIN TRY  
DECLARE @Result BIT;  
DECLARE @IsCognizant BIT;  
SET @IsCognizant  = (SELECT DISTINCT IsCognizant   
      FROM AVL.CUSTOMER(NOLOCK)  C   
      JOIN AVL.MAS_ProjectMaster (NOLOCK) PM   
         ON PM.CustomerId = C.CustomerId  and PM.projectId = @ProjectId AND PM.IsDeleted = 0 AND C.IsDeleted = 0);  
  
IF(@SupportType = 1)  
BEGIN  
 SELECT TVP.TicketId,CC.CauseID,RC.ResolutionID,DC.DebtClassificationID,AF.AvoidableFlagID,RD.ResidualDebtID,  
 TVP.FlexField1,TVP.FlexField2,TVP.FlexField3,TVP.FlexField4  
 INTO #DebtUnclassifiedTicketDetails   
 FROM @TVP_DebtUnclassifiedTicketDetails TVP  
 JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) CC     
 ON CC.CauseCode=TVP.CauseCode AND CC.ProjectId = @ProjectId AND CC.Isdeleted = 0    
 JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) RC     
 ON RC.ResolutionCode=TVP.ResolutionCode AND RC.ProjectId = @ProjectId AND RC.Isdeleted = 0    
 JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RD     
   ON RD.ResidualDebtName=TVP.ResidualDebt AND RD.Isdeleted = 0    
 JOIN AVL.DEBT_MAS_DebtClassification (NOLOCK) DC     
   ON DC.DebtClassificationName = TVP.DebtClassificationName AND DC.Isdeleted = 0    
 JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AF     
   ON AF.AvoidableFlagName = TVP.AvoidableFlag AND AF.Isdeleted = 0   
 JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TK   
  ON TK.TicketID = TVP.TicketId AND TK.IsDeleted = 0  
 WHERE TK.ProjectID = @ProjectId   
  
--AH MET Tickets  
 SELECT DISTINCT IT.TicketId   
 INTO #AHMetTickets  
 FROM #DebtUnclassifiedTicketDetails IT  
 INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON TD.ProjectID =@ProjectId  AND IT.TicketID=TD.TicketID AND TD.IsDeleted=0      
 INNER JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic(nolock) HPP on TD.ProjectID=HPP.ProjectID    
 INNER JOIN AVL.DEBT_TRN_HealTicketDetails(nolock) HTD on HPP.ProjectPatternMapID=HTD.ProjectPatternMapID     
 INNER JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) HPD ON  HTD.ProjectPatternMapID=HPD.ProjectPatternMapID  --TD.ProjectID=HPD.ProjectID      
 AND TD.TicketID=HPD.DARTTicketID AND HPD.MapStatus=1       
 AND ISNULL(HPD.IsDeleted,0)!=1 AND  HTD.HealingTicketID!='0'     
 INNER JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) TM   ON TM.ProjectID   = @ProjectId    
 AND TD.TicketTypeMapID=TM.TicketTypeMappingID      
 WHERE ((TD.DARTStatusID=8 AND TD.Closeddate IS NOT NULL) OR (TD.DARTStatusID=9 AND TD.CompletedDateTime IS NOT NULL))      
 AND ISNULL(TD.TicketTypeMapID,0) != 0    
  
 DELETE  DC  
 FROM #DebtUnclassifiedTicketDetails DC  
 JOIN #AHMetTickets AHT  
 ON AHT.TicketId = DC.TicketId  
  
--GRACE PERIOD CUstomer  
IF(@IsCognizant = 1)  
BEGIN  
 SELECT DISTINCT ServiceID,ServiceName   
 INTO #ServiceList       
 FROM AVL.TK_MAS_ServiceActivityMapping(NOLOCK)   
 WHERE ISNULL(IsDeleted,0)=0   
  
 SELECT DISTINCT IT.TicketId     
 INTO #GracePeriodMetCog  
 FROM #DebtUnclassifiedTicketDetails IT       
 INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON TD.ProjectID = @ProjectId AND IT.TicketID=TD.TicketID AND  TD.IsDeleted=0        
 INNER JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDB ON PDB.ProjectID = @ProjectId    
 INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PDB.ProjectID=PM.ProjectID AND ISNULL(PM.IsDebtEnabled,'N')='Y'       
 LEFT JOIN #ServiceList MAS ON TD.ServiceID=MAS.ServiceID       
 WHERE PM.ProjectID = @ProjectId AND (TD.DARTStatusID = 8 AND TD.Closeddate IS NOT NULL AND GETDATE() > (ISNULL(PDB.GracePeriod,365) +TD.Closeddate)      
 OR      
 (TD.DARTStatusID = 9 AND TD.CompletedDateTime IS NOT NULL AND GETDATE() > (ISNULL(PDB.GracePeriod,365) +TD.CompletedDateTime)      
 ))  AND ISNULL(TD.ServiceID,0) != 0   
  
 DELETE  DC  
 FROM #DebtUnclassifiedTicketDetails DC  
 JOIN #GracePeriodMetCog GM  
 ON GM.TicketId = DC.TicketId  
   
END  
ELSE  
BEGIN  
 SELECT DISTINCT IT.TicketId  
 INTO #GracePeriodMetCustomer  
 FROM #DebtUnclassifiedTicketDetails IT       
  INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON TD.ProjectID = @ProjectId AND IT.TicketID=TD.TicketID AND     ISNULL(TD.IsDeleted,0)=0        
  INNER JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDB ON PDB.ProjectID = @ProjectId    
  INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PDB.ProjectID=PM.ProjectID AND ISNULL(PM.IsDebtEnabled,'N')='Y'      
  INNER JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) TM   ON TM.ProjectID = @ProjectId   
  WHERE PM.ProjectID = @ProjectId AND (TD.DARTStatusID = 8 AND TD.Closeddate IS NOT NULL AND GETDATE() > (ISNULL(PDB.GracePeriod,365) +TD.Closeddate)      
  OR      
  (TD.DARTStatusID = 9 AND TD.CompletedDateTime IS NOT NULL AND GETDATE() > (ISNULL(PDB.GracePeriod,365) +TD.CompletedDateTime)      
  )) AND ISNULL(TD.TicketTypeMapID,0) != 0   
   
 DELETE  DC  
 FROM #DebtUnclassifiedTicketDetails DC  
 JOIN #GracePeriodMetCustomer GMC  
 ON GMC.TicketId = DC.TicketId  
      
END  
  
 UPDATE TD  
 SET  
 TD.CauseCodeMapID = DC.CauseID,  
 TD.ResolutionCodeMapId = DC.ResolutionId,  
 TD.DebtClassificationMapID = DC.DebtClassificationID,  
 TD.ResidualDebtMapID = DC.ResidualDebtID,  
 TD.AvoidableFlag = DC.AvoidableFlagID,  
 TD.FlexField1 = DC.FlexField1,  
 TD.FlexField2 = DC.FlexField2,  
 TD.FlexField3 = DC.FlexField3,  
 TD.FlexField4 = DC.FlexField4,  
 TD.ModifiedBy = @UserId,  
 TD.ModifiedDate = GetDate(),  
 TD.LastUpdatedDate = GetDate(),  
 TD.DebtClassificationMode = 5  
 FROM AVL.TK_TRN_TicketDetail TD  
 JOIN #DebtUnclassifiedTicketDetails (NOLOCK) DC  
 ON DC.TicketId = TD.TicketID AND TD.ProjectID = @ProjectId  
  
END  
  
ELSE  
BEGIN  
  
 SELECT TVP.TicketId,CC.CauseID,RC.ResolutionID,DC.DebtClassificationID,AF.AvoidableFlagID,RD.ResidualDebtID,  
 TVP.FlexField1,TVP.FlexField2,TVP.FlexField3,TVP.FlexField4  
 INTO #DebtUnclassifiedTicketDetailsInfra  
 FROM @TVP_DebtUnclassifiedTicketDetails TVP  
 JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) CC     
 ON CC.CauseCode=TVP.CauseCode AND CC.ProjectId = @ProjectId AND CC.Isdeleted = 0    
 JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) RC     
 ON RC.ResolutionCode=TVP.ResolutionCode AND RC.ProjectId = @ProjectId AND RC.Isdeleted = 0    
 JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RD     
   ON RD.ResidualDebtName=TVP.ResidualDebt AND RD.Isdeleted = 0    
 JOIN AVL.DEBT_MAS_DebtClassificationInfra (NOLOCK) DC     
   ON DC.DebtClassificationName = TVP.DebtClassificationName AND DC.Isdeleted = 0    
 JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AF     
   ON AF.AvoidableFlagName = TVP.AvoidableFlag AND AF.Isdeleted = 0   
 JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) TK   
  ON TK.TicketID = TVP.TicketId AND TK.IsDeleted = 0  
 WHERE TK.ProjectID = @ProjectId   
  
--AH MET Tickets Infra  
 SELECT DISTINCT IT.TicketId   
 INTO #AHMetTicketsInfra  
 FROM #DebtUnclassifiedTicketDetailsInfra IT  
 INNER JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD ON TD.ProjectID =@ProjectId  AND IT.TicketID=TD.TicketID AND TD.IsDeleted=0      
 INNER JOIN AVL.DEBT_PRJ_InfraHealProjectPatternMappingDynamic(nolock) HPP on TD.ProjectID=HPP.ProjectID    
 INNER JOIN AVL.DEBT_TRN_InfraHealTicketDetails(nolock) HTD on HPP.ProjectPatternMapID=HTD.ProjectPatternMapID     
 INNER JOIN AVL.DEBT_PRJ_InfraHealParentChild(NOLOCK) HPD ON  HTD.ProjectPatternMapID=HPD.ProjectPatternMapID  --TD.ProjectID=HPD.ProjectID      
 AND TD.TicketID=HPD.DARTTicketID AND HPD.MapStatus=1       
 AND ISNULL(HPD.IsDeleted,0)!=1 AND  HTD.HealingTicketID!='0'     
 INNER JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) TM   ON TM.ProjectID   = @ProjectId    
 AND TD.TicketTypeMapID=TM.TicketTypeMappingID      
 WHERE ((TD.DARTStatusID=8 AND TD.Closeddate IS NOT NULL) OR (TD.DARTStatusID=9 AND TD.CompletedDateTime IS NOT NULL))      
 AND ISNULL(TD.TicketTypeMapID,0) != 0    
  
 DELETE  DC  
 FROM #DebtUnclassifiedTicketDetailsInfra DC  
 JOIN #AHMetTicketsInfra AHT  
 ON AHT.TicketId = DC.TicketId  
  
 SELECT DISTINCT IT.TicketId  
 INTO #GracePeriodMetInfra  
 FROM #DebtUnclassifiedTicketDetailsInfra IT       
  INNER JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD ON TD.ProjectID = @ProjectId AND IT.TicketID=TD.TicketID AND     ISNULL(TD.IsDeleted,0)=0        
  INNER JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDB ON PDB.ProjectID = @ProjectId    
  INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PDB.ProjectID=PM.ProjectID AND ISNULL(PM.IsDebtEnabled,'N')='Y'      
  INNER JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) TM   ON TM.ProjectID = @ProjectId   
  WHERE PM.ProjectID = @ProjectId AND (TD.DARTStatusID = 8 AND TD.Closeddate IS NOT NULL AND GETDATE() > (ISNULL(PDB.GracePeriod,365) +TD.Closeddate)      
  OR      
  (TD.DARTStatusID = 9 AND TD.CompletedDateTime IS NOT NULL AND GETDATE() > (ISNULL(PDB.GracePeriod,365) +TD.CompletedDateTime)      
  )) AND ISNULL(TD.TicketTypeMapID,0) != 0  
    
  DELETE  DC  
 FROM #DebtUnclassifiedTicketDetailsInfra DC  
 JOIN #GracePeriodMetInfra GMC  
 ON GMC.TicketId = DC.TicketId  
   
 UPDATE TD  
 SET  
 TD.CauseCodeMapID = DC.CauseID,  
 TD.ResolutionCodeMapId = DC.ResolutionId,  
 TD.DebtClassificationMapID = DC.DebtClassificationID,  
 TD.ResidualDebtMapID = DC.ResidualDebtID,  
 TD.AvoidableFlag = DC.AvoidableFlagID,  
 TD.FlexField1 = DC.FlexField1,  
 TD.FlexField2 = DC.FlexField2,  
 TD.FlexField3 = DC.FlexField3,  
 TD.FlexField4 = DC.FlexField4,  
 TD.ModifiedBy = @UserId,  
 TD.ModifiedDate = GetDate(),  
 TD.LastUpdatedDate = GetDate(),  
 TD.DebtClassificationMode = 5  
 FROM AVL.TK_TRN_InfraTicketDetail TD  
 JOIN #DebtUnclassifiedTicketDetailsInfra (NOLOCK) DC  
 ON DC.TicketId = TD.TicketID AND TD.ProjectID = @ProjectId  
  
END  
  
SET @Result = 1  
SELECT @Result  
END TRY  
BEGIN CATCH  
    
  DECLARE @ErrorMessage VARCHAR(4000);    
    
  SELECT @ErrorMessage = ERROR_MESSAGE()    
    
  --INSERT Error                                        
  EXEC AVL_InsertError '[AVL].[UploadDebtUnClassifiedTickets]',@ErrorMessage,0    
 SET @Result = 0  
 SELECT @Result  
    
END CATCH  
END
