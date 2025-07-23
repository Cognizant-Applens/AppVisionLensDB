/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
-- ============================================================================------    
-- Author    :    Dhivya Bharathi M      
--  Create date:    June 24 2019       
-- ============================================================================    
  
--[AVL].[Effort_GetMasterDetailsForTimesheet_ADM] 7097,'471742','05/12/2020','05/20/2020'  
CREATE Procedure [AVL].[Effort_GetMasterDetailsForTimesheet]  
@CustomerID BIGINT,  
@EmployeeID NVARCHAR(50)=null ,  
@FirstDateOfWeek VARCHAR(30)=null,  
@LastDateOfWeek VARCHAR(30)=null  
AS   
BEGIN  
BEGIN TRY  
 SET NOCOUNT ON;  
 CREATE TABLE #MAS_LoginMaster  
 (  
  [UserID] [int]  NOT NULL,  
  [EmployeeID] [nvarchar](50) NOT NULL,  
  [EmployeeName] [nvarchar](100) NULL,  
  [ProjectID] [int] NOT NULL,  
  [CustomerID] [bigint] NOT NULL,  
  [TimeZoneId] [int] NULL  
 )  
 INSERT INTO #MAS_LoginMaster  
 ( UserID,EmployeeID,EmployeeName,ProjectID,CustomerID,TimeZoneId)  
 SELECT UserID,EmployeeID,EmployeeName,ProjectID,CustomerID,TimeZoneId   
 FROM [AVL].[MAS_LoginMaster](NOLOCK)   
 WHERE EmployeeID = @EmployeeID AND CustomerID=@CustomerID AND ISNULL(IsDeleted,0)=0  
  
  
 SELECT DISTINCT  
 C.CustomerId AS CustomerId,PM.ProjectID,  
 ISNULL(CASE WHEN C.IsCognizant='0' THEN 0 ELSE 1 END,1)   AS IsCustomer,  
 ISNULL(CASE WHEN C.IsCognizant='0' THEN 0 ELSE 1 END,1)   AS IsCognizant,  
 ISNULL(C.IsEffortConfigured,0)  AS IsEfforTracked,  
 ISNULL(CASE WHEN PM.IsDebtEnabled='Y' THEN 1 ELSE 0 END,0)   AS IsDebtEnabled,  
 ISNULL(CASE WHEN PM.IsMainspringConfigured='Y' THEN 1 ELSE 0 END,0) AS IsMainSpringConfigured,  
 C.IsDaily,TM.TZoneName AS ProjectTimeZoneName Into #ConfigTemp  
 FROM AVL.Customer C ( NOLOCK )   
 INNER JOIN AVL.MAS_ProjectMaster PM ( NOLOCK ) ON C.CustomerID=PM.CustomerID AND PM.IsDeleted = 0  
 INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.CustomerID=C.CustomerID AND LM.ProjectID=PM.ProjectID   
 LEFT JOIN AVL.MAP_ProjectConfig( NOLOCK ) PC ON PM.ProjectID=PC.ProjectID  
 LEFT JOIN AVL.MAS_TimeZoneMaster( NOLOCK ) TM ON ISNULL(PC.TimeZoneId,32)=TM.TimeZoneID  
 WHERE C.CustomerID=@CustomerID AND LM.EmployeeID=@EmployeeID  AND C.IsDeleted = 0   
  
 DECLARE @S_data DATETIME,@E_data DATETIME  
 SET @S_data = CONVERT(VARCHAR(30),@FirstDateOfWeek,103)  
 SET @E_data = CONVERT(VARCHAR(30),@LastDateOfWeek,103)  
  
 SELECT DISTINCT LM.CustomerID,PSAM.ProjectID,SM.ServiceID,SM.ServiceName,STM.ServiceTypeID,SAM.ActivityID,SAM.ActivityName,  
 ISNULL(SM.ServiceLevelID,0) AS ServiceLevelID,ISNULL(SM.ScopeID,0) AS ScopeID  
 from avl.TK_MAS_Service (NOLOCK)  SM  
 INNER JOIN AVL.TK_MAS_ServiceType (NOLOCK) STM ON STM.ServiceTypeID=SM.ServiceType  
 INNER JOIN AVL.TK_MAS_ServiceActivityMapping(NOLOCK) SAM ON SAM.ServiceTypeID = STM.ServiceTypeID AND SAM.ServiceID = SM.ServiceID  
 INNER JOIN avl.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) PSAM ON PSAM.ServiceMapID=SAM.ServiceMappingID and PSAM.IsDeleted=0  
 INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=PSAM.ProjectID   
 WHERE LM.CustomerID=@CustomerID AND SM.ServiceID <> 41   
 and (@S_data <= PSAM.EffectiveDate or PSAM.EffectiveDate is NULL)  
 AND SM.ScopeID IS NOT NULL  
 ORDER BY SM.ServiceName,SAM.ActivityName ASC  
  -----To pick Ticket Type id------------------  
 SELECT DISTINCT LM.CustomerID ,TTM.ProjectID, TTM.AVMTicketType,TTM.TicketTypeMappingID,TT.TicketTypeID,TT.TicketTypeName,TTM.TicketType   
 FROM [AVL].[TK_MAP_TicketTypeMapping](NOLOCK) TTM  
 LEFT JOIN [AVL].[TK_MAS_TicketType](NOLOCK) TT ON TTM.AVMTicketType=TT.TicketTypeID  
 INNER JOIN #MAS_LoginMaster LM ON LM.ProjectID=TTM.ProjectID   
 WHERE LM.CustomerID=@CustomerID AND LM.EmployeeID=@EmployeeID AND ISNULL(TTM.IsDeleted,0)=0 AND ISNULL(TT.TicketTypeID,0) NOT IN(9,10,20)  
  
 SELECT DISTINCT LM.CustomerID ,PSM.ProjectID, PSM.TicketStatus_ID  AS DARTStatusID,DT.DARTStatusName,PSM.StatusID AS TicketStatus_ID,PSM.StatusName  
 FROM [AVL].[TK_MAP_ProjectStatusMapping](NOLOCK) PSM  
 INNER JOIN [AVL].[TK_MAS_DARTTicketStatus](NOLOCK) DT ON DT.DARTStatusID = PSM.TicketStatus_ID  
 INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=PSM.ProjectID  
 WHERE LM.CustomerID=@CustomerID AND LM.EmployeeID=@EmployeeID  
 AND ISNULL(PSM.IsDeleted,0)=0  
 ORDER BY PSM.StatusName  
  
 SELECT DISTINCT CustomerId,IsCustomer,IsCognizant,IsEfforTracked AS IsEffortTracked,  
 IsDaily as IsDaily  FROM #ConfigTemp  
  
 SELECT DISTINCT LM.CustomerID,PSAM.ProjectID,  
 ISNULL(TTSM.TicketTypeMappingID,0) AS TicketTypeMappingID,SM.ServiceID,  
 ISNULL(STM.ServiceTypeID,0) AS ServiceTypeID,ISNULL(SM.ScopeID,0) AS ScopeID  
 FROM avl.TK_MAS_Service (NOLOCK)  SM  
 INNER JOIN AVL.TK_MAS_ServiceType (NOLOCK) STM ON STM.ServiceTypeID=SM.ServiceType  
 INNER JOIN AVL.TK_MAS_ServiceActivityMapping (NOLOCK) SAM ON SAM.ServiceID = SM.ServiceID AND SAM.ServiceTypeID = STM.ServiceTypeID   
 INNER JOIN avl.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) PSAM ON PSAM.ServiceMapID=SAM.ServiceMappingID and PSAM.IsDeleted=0  
 INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=PSAM.ProjectID    
 LEFT JOIN AVL.TK_MAP_TicketTypeServiceMapping(NOLOCK) TTSM ON  PSAM.ProjectID=TTSM.ProjectID AND SAM.ServiceID=TTSM.ServiceID  
 WHERE LM.CustomerID=@CustomerID AND TTSM.TicketTypeMappingID IS NOT NULL AND TTSM.IsDeleted=0  
 AND SM.ScopeID IS NOT NULL  
  
 --selecting project based services  
 SELECT DISTINCT USM.CustomerID AS CustomerID,USM.ServiceLevelID AS ServiceLevelID,  
 USM.ProjectID AS ProjectID FROM [avl].UserServiceLevelMapping (NOLOCK) USM   
 INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=USM.ProjectID  
 WHERE USM.EmployeeID=@EmployeeID AND USM.CustomerID = @CustomerID AND ISNULL(USM.ServiceLevelID,0) <> 0  
  
 SELECT  DISTINCT IHMT.CustomerID,IPM.ProjectID,ITDT.InfraTowerTransactionID,ITDT.TowerName,ITT.InfraTransactionTaskID,  
 ITT.InfraTaskName,ITMT.SupportLevelID AS ServiceLevelID   
 FROM  AVL.InfraHierarchyMappingTransaction(NOLOCK) IHMT  
 INNER JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) ITDT ON IHMT.CustomerID=ITDT.CustomerID   
 AND IHMT.InfraTransMappingID = ITDT.InfraTransMappingID  
 INNER JOIN AVL.InfraTaskMappingTransaction(NOLOCK) ITMT ON ITDT.CustomerID=ITMT.CustomerID   
 AND IHMT.HierarchyTwoTransactionID=ITMT.TechnologyTowerID AND ITMT.IsEnabled=1  
 INNER JOIN AVL.InfraTaskTransaction(NOLOCK) ITT ON ITT.CustomerID=ITMT.CustomerID   
 AND ITT.InfraTransactionTaskID = ITMT.InfraTransactionTaskID  
 INNER JOIN AVL.InfraHierarchyThreeTransaction(NOLOCK) HTT ON IHMT.CustomerID=HTT.CustomerID   
 AND HTT.HierarchyThreeTransactionID=IHMT.HierarchyThreeTransactionID  
 INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) IPM ON IPM.TowerID=ITDT.InfraTowerTransactionID  
 INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=IPM.ProjectID AND LM.ProjectID=IPM.ProjectID AND IPM.IsEnabled=1  
 WHERE ITDT.CustomerID=@CustomerID AND LM.EmployeeID=@EmployeeID  
 ORDER BY ITT.InfraTaskName  
  
 SELECT  LM.CustomerID,MS.ProjectId,MS.StatusId,MS.StatusMapId,MS.ProjectStatusName   
 FROM [PP].[ALM_MAP_Status](NOLOCK) MS  
 INNER JOIN #MAS_LoginMaster LM ON LM.ProjectID=MS.ProjectID AND ISNULL(MS.IsDeleted,0)=0  
 WHERE  LM.CustomerID=@CustomerID AND LM.EmployeeID=@EmployeeID  
   
  
 SELECT StatusId,ProjectStatusName  
 FROM [PP].[ALM_MAP_Status](NOLOCK) WHERE IsDefault='Y'  
  
 SELECT LM.CustomerID,SW.ProjectId,SW.IsApplensAsALM FROM PP.ScopeOfWork(NOLOCK) SW  
 INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=SW.ProjectID  
 WHERE  LM.CustomerID=@CustomerID AND LM.EmployeeID=@EmployeeID  
 AND ISNULL(SW.IsDeleted,0)=0  
  
  
IF OBJECT_ID('tempdb..#MAS_LoginMaster', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #MAS_LoginMaster  
END  
END TRY   
BEGIN CATCH    
  DECLARE @ErrorMessage VARCHAR(MAX);  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  EXEC AVL_InsertError '[AVL].[Effort_GetMasterDetailsForTimesheet]', @ErrorMessage, @EmployeeID,0  
 END CATCH    
END
