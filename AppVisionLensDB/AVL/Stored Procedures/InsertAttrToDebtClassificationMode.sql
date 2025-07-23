/***************************************************************************        
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET        
*Copyright [2018] – [2021] Cognizant. All rights reserved.        
*NOTICE: This unpublished material is proprietary to Cognizant and        
*its suppliers, if any. The methods, techniques and technical        
  concepts herein are considered Cognizant confidential and/or trade secret information.         
          
*This material may be covered by U.S. and/or foreign patents or patent applications.         
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.        
***************************************************************************/        
CREATE proc [AVL].[InsertAttrToDebtClassificationMode]          
-- [AVL].[InsertAttrToDebtClassificationMode] 'AppLens0000414',10337,627384,1,2          
@TicketID nvarchar(max),          
--@ServiceID int=null,          
--@TicketTypeID int=null,          
@ProjectID bigint=null,          
@UserID nvarchar(max),          
@Source bigint,          
@SupportTypeID INT          
as          
BEGIN        
SET NOCOUNT ON;        
BEGIN TRY          
declare @IsCognizant bit,@TimeTickerID BIGINT, @CustomerID BIGINT,@IsDebtEnabled NVARCHAR(max),@DartStatusID int,@ApplicationID BIGINT,@TowerID BIGINT,@ServiceID int,          
 @TicketTypeID int,@ID BIGINT , @IsAutoClassified nvarchar(max),@IsDDClassified nvarchar(max),@AutoClassificationType tinyint;          
          
DECLARE @AppAlgorithmKey nvarchar(6);      
  DECLARE @InfraAlgorithmKey nvarchar(6);      
  IF((SELECT Count(AlgorithmKey) FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0) > 0 )    
  BEGIN     
  IF EXISTS(SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1)    
  BEGIN    
  SET @AppAlgorithmKey = (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1)    
  END    
  IF EXISTS(SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2)    
  BEGIN    
  SET @InfraAlgorithmKey = (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2)    
  END    
  END    
  ELSE    
  BEGIN    
  SET @AppAlgorithmKey ='AL002'    
  SET @InfraAlgorithmKey='AL002'    
  END                          
           
IF(@SupportTypeID=1 OR @SupportTypeID IS NULL AND (@AppAlgorithmKey='AL001' OR @AppAlgorithmKey='AL002'))          
BEGIN          
           
          
    select @ProjectID=pm.ProjectID,@CustomerID=pm.CustomerID,@ApplicationID=TD.ApplicationID,          
 @TimeTickerID=td.TimeTickerID,@IsCognizant=cu.IsCognizant,@IsDebtEnabled=pm.IsDebtEnabled,@DartStatusID=TD.DARTStatusID           
 from AVL.TK_TRN_TicketDetail TD (NOLOCK)           
 join AVL.MAS_ProjectMaster PM (NOLOCK) on td.ProjectID=pm.ProjectID           
 join AVL.MAS_LoginMaster lm (NOLOCK) on lm.ProjectID=pm.projectid           
 join avl.Customer cu (NOLOCK) on cu.CustomerID=pm.CustomerID           
 where TD.TicketID=@TicketID and lm.EmployeeID=@UserID and td.IsDeleted=0 and lm.IsDeleted=0 and           
 cu.IsDeleted=0 and td.ProjectID=@ProjectID          
          
 set @AutoClassificationType = (SELECT TOP 1 DebtAttributeId FROM [ML].[ConfigurationProgress] (NOLOCK)          
        WHERE PROJECTID=@ProjectID           
        and IsDeleted=0          
        ORDER BY ID ASC)          
          
 print @ProjectID          
          
 SELECT @ApplicationID          
          
 print @CustomerID          
          
 print @TimeTickerID          
 CREATE table #TempDebtClassification          
 (          
   ID BIGINT,          
            
   UserDebtClassificationFlag bigint,          
   UserAvoidableFlag BIGINT,          
   UserResidualFlag BIGINT,          
   DebtClassificatioMode BIGINT,          
   CauseCodeID BIGINT,          
   ResolutionCodeID BIGINT,          
   ModifiedBy nvarchar(max),          
    ModifiedDate datetime          
 )          
          
  set @ID=(SELECT top 1 ID from AVL.TRN_DebtClassificationModeDetails (NOLOCK) where TimeTickerID=@TimeTickerID order          
   by id desc  )          
          
   if( EXISTS(SELECT top 1 ID from AVL.TRN_DebtClassificationModeDetails (NOLOCK) where TimeTickerID=@TimeTickerID order          
   by id desc ))          
   BEGIN          
   IF(@AppAlgorithmKey='AL002')      
   BEGIN      
   insert INTO #TempDebtClassification           
 select @ID,ticket.DebtClassificationMapID,ticket.AvoidableFlag,ticket.ResidualDebtMapID,          
 case when ((debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag              
          
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID) OR (debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag              
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID ))          
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 1              
          
 when ((debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag              
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID) )          
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 2           
                      
          
 when debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag              
          
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID and (debt.DebtClassficationMode=3 or debt.DebtClassficationMode=4) THEN 3              
          
 when (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag              
          
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID) and (debt.DebtClassficationMode=3 or debt.DebtClassficationMode=4) THEN 4              
          
  WHEN debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL            
 AND ticket.DebtClassificationMapID IS  NULL AND ticket.AvoidableFlag IS  NULL  AND ticket.ResidualDebtMapID IS  NULL            
 THEN NULL           
          
 WHEN debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL            
 AND ticket.DebtClassificationMapID IS NOT NULL AND ticket.AvoidableFlag IS NOT NULL  AND ticket.ResidualDebtMapID IS NOT NULL            
 THEN 5 end,ticket.CauseCodeMapID,ticket.ResolutionCodeMapID,          
 @UserID,GETDATE()  from AVL.TK_TRN_TicketDetail ticket (NOLOCK)         
 join AVL.TRN_DebtClassificationModeDetails debt (NOLOCK)  on ticket.TimeTickerID=debt.TimeTickerID         
 where ticket.TimeTickerID=@TimeTickerID and debt.ID=@ID          
   END      
   ELSE      
   BEGIN      
 insert INTO #TempDebtClassification           
 select @ID,ticket.DebtClassificationMapID,ticket.AvoidableFlag,ticket.ResidualDebtMapID,          
 case when ((@AutoClassificationType=1 AND debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag              
          
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID) OR (@AutoClassificationType=2 AND debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag              
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID AND  debt.SystemCauseCodeID=ticket.CauseCodeMapID and debt.SystemResolutionCodeID=ticket.ResolutionCodeMapID))          
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 1              
          
 when (@AutoClassificationType=1 AND (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag              
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID) and (debt.CauseCodeID = ticket.CauseCodeMapID and debt.ResolutionCodeID=ticket.ResolutionCodeMapID ))          
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 2           
           
           
 when(@AutoClassificationType=2 AND (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag              
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID or debt.SystemCauseCodeID<>ticket.CauseCodeMapID or debt.SystemResolutionCodeID<>ticket.ResolutionCodeMapID))            
 and (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) THEN 2          
            
          
 when debt.SystemDebtclassification=ticket.DebtClassificationMapID and debt.SystemAvoidableFlag=ticket.AvoidableFlag              
          
 and debt.SystemResidualDebtFlag=ticket.ResidualDebtMapID and (debt.DebtClassficationMode=3 or debt.DebtClassficationMode=4) THEN 3              
          
 when (debt.SystemDebtclassification<>ticket.DebtClassificationMapID or debt.SystemAvoidableFlag<>ticket.AvoidableFlag              
          
 or debt.SystemResidualDebtFlag<>ticket.ResidualDebtMapID) and (debt.DebtClassficationMode=3 or debt.DebtClassficationMode=4) THEN 4              
          
  WHEN debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL            
 AND ticket.DebtClassificationMapID IS  NULL AND ticket.AvoidableFlag IS  NULL  AND ticket.ResidualDebtMapID IS  NULL            
 THEN NULL           
          
 WHEN debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL            
 AND ticket.DebtClassificationMapID IS NOT NULL AND ticket.AvoidableFlag IS NOT NULL  AND ticket.ResidualDebtMapID IS NOT NULL            
 THEN 5 end,ticket.CauseCodeMapID,ticket.ResolutionCodeMapID,          
 @UserID,GETDATE()  from AVL.TK_TRN_TicketDetail ticket (NOLOCK)         
 join AVL.TRN_DebtClassificationModeDetails debt (NOLOCK)  on ticket.TimeTickerID=debt.TimeTickerID         
 where ticket.TimeTickerID=@TimeTickerID and debt.ID=@ID          
    END      
 END          
 else          
 BEGIN          
          
 INSERT INTO AVL.TRN_DebtClassificationModeDetails          
 (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,DebtClassficationMode          
 ,Isdeleted,CreatedBy,CreatedDate,CauseCodeID,ResolutionCodeID,SystemCauseCodeID, SystemResolutionCodeID)          
          
 SELECT @TimeTickerID,NULL,NULL,NULL,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,          
5,0,@UserID,GETDATE(),CauseCodeMapID,ResolutionCodeMapID,NULL,NULL          
 from AVL.TK_TRN_TicketDetail (NOLOCK)  where TimeTickerID=@TimeTickerID          
 AND  (DebtClassificationMapID is not NULL AND AvoidableFlag is not NULL AND ResidualDebtMapID is not NULL          
 AND CauseCodeMapID IS NOT NULL AND ResolutionCodeMapID IS NOT NULL          
 )          
          
 if exists(select top 1 ProjectID from ml.ConfigurationProgress (NOLOCK) where ProjectID=@ProjectID and DebtAttributeId='2')          
 begin          
 if exists((select TicketID from avl.TK_TRN_TicketDetail (NOLOCK) where TimeTickerID=@TimeTickerID and DebtClassificationMode='1'))          
 begin           
 update AVL.TRN_DebtClassificationModeDetails set DebtClassficationMode='2' where TimeTickerID=@TimeTickerID          
 end          
 end          
          
 END          
          
          
 UPDATE          
    debt          
 SET          
    debt.UserDebtClassificationFlag = debtc.UserDebtClassificationFlag,          
  debt.UserAvoidableFlag = debtc.UserAvoidableFlag,          
  debt.UserResidualDebtFlag=debtc.UserResidualFlag,          
  debt.DebtClassficationMode=debtc.DebtClassificatioMode,          
  debt.ModifiedBy=debtc.ModifiedBy,          
  debt.ModifiedDate=debtc.ModifiedDate,          
  debt.CauseCodeID=debtc.CauseCodeID,          
  debt.ResolutionCodeID=debtc.ResolutionCodeID          
 FROM          
  AVL.TRN_DebtClassificationModeDetails AS debt          
  INNER JOIN #TempDebtClassification  AS debtc          
   ON debt.id = debtc.id          
 WHERE          
  debt.ID= @ID          
         
  UPDATE AppT set  AppT.DebtClassificationMode = ADM.DebtClassficationMode          
  from AVL.TK_TRN_TicketDetail AS AppT          
  join AVL.TRN_DebtClassificationModeDetails ADM on ADM.TimeTickerID = AppT.TimeTickerID          
  where AppT.TimeTickerID = @TimeTickerID          
          
END          
ELSE          
BEGIN       
IF(@InfraAlgorithmKey='AL001' OR @InfraAlgorithmKey='AL002')    
BEGIN    
 set @AutoClassificationType = (SELECT TOP 1 DebtAttributeId FROM [ML].[InfraConfigurationProgress] (NOLOCK)          
        WHERE PROJECTID=@ProjectID           
        and IsDeleted=0          
        ORDER BY ID ASC)          
 select @ProjectID=pm.ProjectID,@CustomerID=pm.CustomerID,@TowerID=TD.TowerID,@TimeTickerID=td.TimeTickerID,@IsCognizant=cu.IsCognizant,          
 @IsDebtEnabled=pm.IsDebtEnabled,@DartStatusID=TD.DARTStatusID           
 from AVL.TK_TRN_InfraTicketDetail TD  (NOLOCK)          
 join AVL.MAS_ProjectMaster PM (NOLOCK) on td.ProjectID=pm.ProjectID           
 join AVL.MAS_LoginMaster lm (NOLOCK) on lm.ProjectID=pm.projectid           
 join avl.Customer cu (NOLOCK) on cu.CustomerID=pm.CustomerID           
 where TD.TicketID=@TicketID and lm.EmployeeID=@UserID and td.IsDeleted=0 and lm.IsDeleted=0           
 and cu.IsDeleted=0 and td.ProjectID=@ProjectID          
          
          
 print @ProjectID          
          
 SELECT @TowerID          
          
 print @CustomerID          
          
 print @TimeTickerID          
 CREATE table #TempDebtClassificationInfra          
 (          
   ID BIGINT,          
            
   UserDebtClassificationFlag bigint,          
   UserAvoidableFlag BIGINT,          
   UserResidualFlag BIGINT,          
   DebtClassificatioMode BIGINT,          
   CauseCodeID BIGINT,          
   ResolutionCodeID BIGINT,          
                 
   ModifiedBy nvarchar(max),          
    ModifiedDate datetime          
 )          
          
  set @ID=(SELECT top 1 ID from AVL.TRN_InfraDebtClassificationModeDetails (NOLOCK) where TimeTickerID=@TimeTickerID order          
   by id desc  )          
          
 if( EXISTS(SELECT top 1 ID from AVL.TRN_InfraDebtClassificationModeDetails (NOLOCK) where TimeTickerID=@TimeTickerID order  by id desc ))          
  BEGIN          
          
    IF(@InfraAlgorithmKey='AL002')      
 BEGIN      
 insert INTO #TempDebtClassificationInfra           
  select @ID,tic.DebtClassificationMapID,tic.AvoidableFlag,tic.ResidualDebtMapID,          
 case when (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2)and            
   (tic.DebtClassificationMapID=debt.SystemDebtclassification and           
   tic.AvoidableFlag=debt.SystemAvoidableFlag and tic.ResidualDebtMapID=debt.SystemResidualDebtFlag) or          
   (tic.DebtClassificationMapID=debt.SystemDebtclassification and           
   tic.AvoidableFlag=debt.SystemAvoidableFlag and tic.ResidualDebtMapID=debt.SystemResidualDebtFlag)          
   then 1           
 when (debt.DebtClassficationMode=3 OR debt.DebtClassficationMode=4) and            
   tic.DebtClassificationMapID=debt.SystemDebtclassification and           
   tic.AvoidableFlag=debt.SystemAvoidableFlag and tic.ResidualDebtMapID=debt.SystemResidualDebtFlag then 3          
          
 --when (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) and           
 --  (@AutoClassificationType = 1 AND tic.CauseCodeMapID=debt.CauseCodeID and tic.ResolutionCodeMapID=debt.ResolutionCodeID and           
 --  (tic.DebtClassificationMapID<>debt.SystemDebtclassification or           
 --  tic.AvoidableFlag<>debt.SystemAvoidableFlag or tic.ResidualDebtMapID<>debt.SystemResidualDebtFlag)) OR          
 --  (@AutoClassificationType = 2 AND (tic.CauseCodeMapID<>debt.SystemCauseCodeID OR tic.ResolutionCodeMapID=debt.SystemResolutionCodeID and           
 --  tic.DebtClassificationMapID<>debt.SystemDebtclassification or           
 --  tic.AvoidableFlag<>debt.SystemAvoidableFlag or tic.ResidualDebtMapID<>debt.SystemResidualDebtFlag))          
 --  then 2            
          
 when (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) and           
   ((tic.DebtClassificationMapID<>debt.SystemDebtclassification or           
   tic.AvoidableFlag<>debt.SystemAvoidableFlag or tic.ResidualDebtMapID<>debt.SystemResidualDebtFlag)) then 2          
          
 when (debt.DebtClassficationMode=3 OR debt.DebtClassficationMode=4) and            
   tic.DebtClassificationMapID<>debt.SystemDebtclassification or           
   tic.AvoidableFlag<>debt.SystemAvoidableFlag or tic.ResidualDebtMapID<>debt.SystemResidualDebtFlag then 4          
 when tic.DebtClassificationMapID IS NULL AND debt.SystemDebtclassification IS NULL AND tic.AvoidableFlag IS NULL AND debt.SystemAvoidableFlag  IS NULL          
   AND  tic.ResidualDebtMapID IS NULL AND debt.SystemResidualDebtFlag IS NULL THEN NULL          
 when debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL and           
   tic.DebtClassificationMapID IS NOT  NULL  AND tic.AvoidableFlag IS NOT NULL AND  tic.ResidualDebtMapID IS NOT NULL          
   --AND tic.CauseCodeMapID IS NOT NULL AND TIC.ResolutionCodeMapID IS NOT NULL           
   THEN 5          
 end,tic.CauseCodeMapID,tic.ResolutionCodeMapID,          
 @UserID,GETDATE()  from AVL.TK_TRN_InfraTicketDetail tic (NOLOCK)         
 join AVL.TRN_InfraDebtClassificationModeDetails debt (NOLOCK)  on tic.TimeTickerID=debt.TimeTickerID         
 where tic.TimeTickerID=@TimeTickerID and debt.ID=@ID          
 END      
 ELSE      
 BEGIN      
 insert INTO #TempDebtClassificationInfra           
  select @ID,tic.DebtClassificationMapID,tic.AvoidableFlag,tic.ResidualDebtMapID,          
 case when (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2)and            
   (@AutoClassificationType = 1 and tic.DebtClassificationMapID=debt.SystemDebtclassification and           
   tic.AvoidableFlag=debt.SystemAvoidableFlag and tic.ResidualDebtMapID=debt.SystemResidualDebtFlag) or          
   (@AutoClassificationType = 2 and tic.DebtClassificationMapID=debt.SystemDebtclassification and           
   tic.AvoidableFlag=debt.SystemAvoidableFlag and tic.ResidualDebtMapID=debt.SystemResidualDebtFlag and          
   tic.CauseCodeMapID = debt.SystemCauseCodeID and tic.ResolutionCodeMapID = debt.SystemResolutionCodeID)          
   then 1           
 when (debt.DebtClassficationMode=3 OR debt.DebtClassficationMode=4) and            
   tic.DebtClassificationMapID=debt.SystemDebtclassification and           
   tic.AvoidableFlag=debt.SystemAvoidableFlag and tic.ResidualDebtMapID=debt.SystemResidualDebtFlag then 3          
          
 --when (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) and           
 --  (@AutoClassificationType = 1 AND tic.CauseCodeMapID=debt.CauseCodeID and tic.ResolutionCodeMapID=debt.ResolutionCodeID and           
 --  (tic.DebtClassificationMapID<>debt.SystemDebtclassification or           
 --  tic.AvoidableFlag<>debt.SystemAvoidableFlag or tic.ResidualDebtMapID<>debt.SystemResidualDebtFlag)) OR          
 --  (@AutoClassificationType = 2 AND (tic.CauseCodeMapID<>debt.SystemCauseCodeID OR tic.ResolutionCodeMapID=debt.SystemResolutionCodeID and           
 --  tic.DebtClassificationMapID<>debt.SystemDebtclassification or           
 --  tic.AvoidableFlag<>debt.SystemAvoidableFlag or tic.ResidualDebtMapID<>debt.SystemResidualDebtFlag))          
 --  then 2            
          
 when (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) and           
   (@AutoClassificationType = 1 AND tic.CauseCodeMapID=debt.CauseCodeID and tic.ResolutionCodeMapID=debt.ResolutionCodeID and           
   (tic.DebtClassificationMapID<>debt.SystemDebtclassification or           
   tic.AvoidableFlag<>debt.SystemAvoidableFlag or tic.ResidualDebtMapID<>debt.SystemResidualDebtFlag)) then 2          
          
          
 when (debt.DebtClassficationMode=1 or debt.DebtClassficationMode=2) and           
        (@AutoClassificationType = 2 or (tic.CauseCodeMapID<>debt.SystemCauseCodeID OR tic.ResolutionCodeMapID=debt.SystemResolutionCodeID and           
   tic.DebtClassificationMapID<>debt.SystemDebtclassification or           
   tic.AvoidableFlag<>debt.SystemAvoidableFlag or tic.ResidualDebtMapID<>debt.SystemResidualDebtFlag))          
   then 2            
          
 when (debt.DebtClassficationMode=3 OR debt.DebtClassficationMode=4) and            
   tic.DebtClassificationMapID<>debt.SystemDebtclassification or           
   tic.AvoidableFlag<>debt.SystemAvoidableFlag or tic.ResidualDebtMapID<>debt.SystemResidualDebtFlag then 4          
 when tic.DebtClassificationMapID IS NULL AND debt.SystemDebtclassification IS NULL AND tic.AvoidableFlag IS NULL AND debt.SystemAvoidableFlag  IS NULL          
   AND  tic.ResidualDebtMapID IS NULL AND debt.SystemResidualDebtFlag IS NULL THEN NULL          
 when debt.SystemDebtclassification IS NULL AND debt.SystemAvoidableFlag IS NULL AND debt.SystemResidualDebtFlag  IS NULL and           
   tic.DebtClassificationMapID IS NOT  NULL  AND tic.AvoidableFlag IS NOT NULL AND  tic.ResidualDebtMapID IS NOT NULL          
   --AND tic.CauseCodeMapID IS NOT NULL AND TIC.ResolutionCodeMapID IS NOT NULL           
   THEN 5          
 end,tic.CauseCodeMapID,tic.ResolutionCodeMapID,          
 @UserID,GETDATE()  from AVL.TK_TRN_InfraTicketDetail tic (NOLOCK)         
 join AVL.TRN_InfraDebtClassificationModeDetails debt (NOLOCK)  on tic.TimeTickerID=debt.TimeTickerID         
 where tic.TimeTickerID=@TimeTickerID and debt.ID=@ID          
 END      
       
          
          
 END           
 else          
 BEGIN          
  INSERT INTO AVL.TRN_InfraDebtClassificationModeDetails          
  (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,DebtClassficationMode,          
  Isdeleted,CreatedBy,CreatedDate,CauseCodeID,ResolutionCodeID,SystemCauseCodeID, SystemResolutionCodeID)          
          
  SELECT @TimeTickerID,NULL,NULL,NULL,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,          
  5,0,@UserID,GETDATE(),CauseCodeMapID,ResolutionCodeMapID,NULL,NULL          
  from AVL.TK_TRN_InfraTicketDetail (NOLOCK)  where TimeTickerID=@TimeTickerID          
  AND  (DebtClassificationMapID is not NULL AND AvoidableFlag is not NULL AND ResidualDebtMapID is not NULL          
  AND CauseCodeMapID IS NOT NULL AND ResolutionCodeMapID IS NOT NULL          
   )          
          
 END          
          
          
 UPDATE          
    debt          
 SET          
    debt.UserDebtClassificationFlag = debtc.UserDebtClassificationFlag,          
  debt.UserAvoidableFlag = debtc.UserAvoidableFlag,          
  debt.UserResidualDebtFlag=debtc.UserResidualFlag,          
  debt.DebtClassficationMode=debtc.DebtClassificatioMode,          
  debt.ModifiedBy=debtc.ModifiedBy,          
  debt.ModifiedDate=debtc.ModifiedDate,          
  debt.CauseCodeID=debtc.CauseCodeID,          
  debt.ResolutionCodeID=debtc.ResolutionCodeID          
 FROM          
  AVL.TRN_InfraDebtClassificationModeDetails AS debt          
  INNER JOIN #TempDebtClassificationInfra  AS debtc          
   ON debt.id = debtc.id          
 WHERE          
  debt.ID= @ID          
          
          
  UPDATE Infra set  Infra.DebtClassificationMode = IDM.DebtClassficationMode          
  from AVL.TK_TRN_InfraTicketDetail AS Infra          
  join AVL.TRN_InfraDebtClassificationModeDetails IDM on IDM.TimeTickerID = Infra.TimeTickerID          
  where Infra.TimeTickerID = @TimeTickerID     
          
            
            
END      
END      
    
END TRY          
BEGIN CATCH          
 DECLARE @ErrorMessage VARCHAR(MAX);          
          
  SELECT @ErrorMessage = ERROR_MESSAGE()          
  ROLLBACK TRAN          
  --INSERT Error              
  EXEC AVL_InsertError '[AVL].[InsertAttrToDebtClassificationMode]', @ErrorMessage, @UserID,0          
END CATCH          
SET NOCOUNT OFF;        
END
