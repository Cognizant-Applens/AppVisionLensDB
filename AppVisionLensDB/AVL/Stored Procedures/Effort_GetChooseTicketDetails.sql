/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Effort_GetChooseTicketDetails] -- 10337,'','','','','','','','','','',1  
	 @ProjectID INT ,      
	 @req NVARCHAR(MAX)=null ,      
	 @AssignedTo NVARCHAR(MAX)=null ,           
	 @applicationID NVARCHAR(MAX)=null , 
	 @TowerIDs NVARCHAR(MAX)=null,
	 @AssignmentGroupIds NVARCHAR(MAX)=null,     
	 @create_date_begin DATETIME =null,      
	 @create_date_end DATETIME =null, 
	 @close_date_begin DATETIME =null ,      
	 @close_date_end DATETIME =null ,      
	 @StatusIDs NVARCHAR(MAX) =null,
	 @IsDARTTicket INT,      
	 @TicketingDetails [dbo].[TVP_TicketID] readonly,
	@ServiceDetails [AVL].[IDList] readonly
 WITH RECOMPILE      
AS       
BEGIN     
BEGIN TRY      
SET NOCOUNT ON;      

 DECLARE @datebegin DATETIME         
 DECLARE @dateend DATETIME          
 DECLARE @flgDate INT          
 DECLARE @closebegin DATETIME        
 DECLARE @closeend DATETIME            
 DECLARE @flgendDate INT         
 DECLARE @flag INT   
 DECLARE @flagTower INT  
 DECLARE @supportTypeId INT
 SELECT @supportTypeId=ISNULL(SupportTypeId,1) from AVL.MAP_ProjectConfig where ProjectID=@ProjectID

 DECLARE @TicketCount AS INT=0;
 DECLARE @ServiceCount AS INT=0;
 SELECT @TicketCount=ISNULL(COUNT(TicketID),0) FROM @TicketingDetails;
 SELECT @ServiceCount=ISNULL(COUNT(ID),0) FROM @ServiceDetails;

	CREATE TABLE #Result
	(
	AssigneeID				NVARCHAR(200),
	AssigneeName				NVARCHAR(50),
	ProjectID				BIGINT,
	AssignmentGroupMapID			BIGINT,
	AssignmentGroupName			NVARCHAR(1000),
	ApplicationID				BIGINT,
	ApplicationName				NVARCHAR(1000),
	TowerID					BIGINT,
	TowerName				NVARCHAR(1000),				
	req_no					NVARCHAR(50),	
	TicketDescription			NVARCHAR(MAX),
	ServiceID				BIGINT,
	ServiceName				NVARCHAR(1000),
	CategoryID				BIGINT,
	ActivityID				BIGINT,
	StatusID				BIGINT,
	DartStatusID				BIGINT,
	TicketTypeID				BIGINT,
	StatusName				NVARCHAR(100),
	EffortTillDate				DECIMAL(25,2),
	ITSMEffort				DECIMAL(25,2),
	IsMainSpringConfig			CHAR(1),
	IsDebtEnabled				CHAR(1)	,				
	IsSDTicket				BIT,
	create_Date				DATETIME,
	resolved_date				DATETIME,
	TicketCreateDate			DATETIME,
	IsAttributeUpdated			BIT,
	SupportTypeID				INT,
	SupportTypeName				VARCHAR(100)
	)
      
   SET @req = REPLACE(REPLACE(REPLACE(@req, '[', '[[]'), '_', '[_]'), '%', '[%]')                
             
          
    IF ( @create_date_begin <> '' AND @create_date_end <> '')             
      BEGIN              
        SET @datebegin = CONVERT(DATETIME, @create_date_begin) + '00:00:00'                  
        SET @dateend = CONVERT(DATETIME, @create_date_end) + '23:59:59'              
        SET @flgDate = 1              
    END              
            
    ELSE IF ( @create_date_begin = '' AND @create_date_end = '')             
     BEGIN              
     SET @datebegin = NULL;              
     SET @dateend = NULL;              
     SET @flgDate = 4              
     END               
          
  IF(@close_date_begin<>'' AND @close_date_end<>'')              
    BEGIN              
    SET @closebegin=CONVERT(DATETIME,@close_date_begin) + '00:00:00'              
    SET @closeend=CONVERT(DATETIME,@close_date_end) + '23:59:59'              
    SET @flgendDate=1              
    END              
 ELSE              
   BEGIN              
   IF(@close_date_begin='' AND @close_date_end='')              
     BEGIN              
     SET @closebegin=NULL;              
     SET @closeend=NULL;              
     SET @flgendDate=4              
    END              
  END      
  DECLARE @assignmentgrpcount BIGINT         
  SELECT Item as AssignmentgrpIds INTO #tmpAssignment FROM dbo.Split(@AssignmentGroupIds,',') where Item<>''      
  SET @assignmentgrpcount=(SELECT COUNT(AssignmentgrpIds) from #tmpAssignment )       
  DECLARE @towerDetailscount BIGINT       
  SELECT Item as Towerids INTO #tmpTowerids FROM dbo.Split(@TowerIDs,',') where Item<>''      
  SET @towerDetailscount=(SELECT COUNT(Towerids) from #tmpTowerids)      
  IF(@towerDetailscount>0 and @supportTypeId<>1)      
  BEGIN      
  SET @flagTower=1      
      
  END      
  ELSE       
  BEGIN      
      
  SET @flagTower=2      
      
  END
  IF (@applicationID <> '')               
   SET @flag = 1                                          
  ELSE           
   SET @flag = 2                
 IF @IsDARTTicket=0      
  BEGIN         
    INSERT INTO #Result      
 select  Distinct      
 ISNULL(TD.AssignedTo,'') as AssigneeID,      
 ISNULL(LM.EmployeeName,'') as AssigneeName,      
 TD.ProjectID as ProjectID,      
 AG.AssignmentGroupMapID ,      
 AG.AssignmentGroupName,      
 TD.ApplicationID as ApplicationID,      
 AD.ApplicationName as ApplicationName,      
 '' as TowerID,      
 '' as TowerName,      
 TD.TicketID as req_no,      
 TD.TicketDescription as TicketDescription,      
 TD.ServiceId as ServiceID,      
 MASS.ServiceName as ServiceName,      
 0 as CategoryID,      
 0 as ActivityID,      
 TD.TicketStatusMapID as StatusID,      
 TD.DARTStatusID AS DartStatusID,      
 TD.TicketTypeMapID AS TicketTypeID,      
 PSM.StatusName as StatusName,      
 TD.EffortTillDate as EffortTillDate,      
 TD.ActualEffort as ITSMEffort,      
 PM.IsMainSpringConfigured as IsMainSpringConfig,      
 PM.IsDebtEnabled as IsDebtEnabled,      
 TD.IsSDTicket,      
 TD.OpenDateTime AS create_Date ,            
    TD.Closeddate AS resolved_date,      
 TD.TicketCreateDate AS TicketCreateDate,      
 ISNULL(TD.IsAttributeUpdated,0) AS IsAttributeUpdated       
 ,1 AS 'SupportTypeID','App' as 'SupportTypeName'      
      
 from AVL.TK_TRN_TicketDetail(NOLOCK) TD      
 LEFT join  AVL.MAS_LoginMaster(NOLOCK) LM on LM.UserID=TD.AssignedTo AND TD.ProjectID=LM.ProjectID      
 left join AVL.APP_MAS_ApplicationDetails(NOLOCK) AD on AD.ApplicationID=TD.ApplicationID      
       
 left join AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM on TD.TicketTypeMapID=TTM.TicketTypeMappingID AND TD.ProjectID=TTM.ProjectID AND TD.IsDeleted=0      
 Left join AVL.BOTAssignmentGroupMapping AG ON TD.AssignmentGroupID=AG.AssignmentGroupMapID AND AG.ProjectID=TD.ProjectID      
 left join AVL.TK_MAS_Service(NOLOCK) MASS on TD.ServiceID=MASS.ServiceID      
 left join AVL.TK_MAP_ProjectStatusMapping(NOLOCK) PSM on  PSM.StatusID=TD.TicketStatusMapID AND  PSM.IsDeleted = 0           
         
 left join AVL.MAS_ProjectMaster(NOLOCK) PM on TD.ProjectID= PM.ProjectID       
 left join AVL.TK_PRJ_ServiceProjectMapping(NOLOCK) SPM on SPM.ServiceID=TD.ServiceID and SPM.ProjectID=TD.ProjectID      
  WHERE PM.IsDeleted = 0       
   AND (LM.EmployeeID LIKE '%' + @AssignedTo + '%'OR @AssignedTo = '' OR @AssignedTo IS NULL)       
        
   AND ((TD.TicketID LIKE '%' + @req + '%' OR @req = '' OR @req IS NULL)       
   )                  
    AND (((@flag = 1) AND (EXISTS (SELECT 1 FROM dbo.Split(@applicationID,',') WHERE TD.ApplicationID = Item)))       
      OR ((@flag = 2 and @flagTower = 2)))                       
      AND ((ISNULL(@StatusIDs,'')= '' AND TD.TicketStatusMapID=TD.TicketStatusMapID) OR (TD.TicketStatusMapID IN(SELECT Item  FROM dbo.Split(@StatusIDs,','))))                       
    AND ((@flgDate=1 AND ((TD.OpenDateTime BETWEEN @datebegin AND @dateend))) OR (@flgDate=4 AND (1=1)))              
     AND ((@flgendDate=1 AND (TD.Closeddate BETWEEN @closebegin AND @closeend)) OR (@flgendDate=4 AND (1=1)))      
   AND TD.ProjectID = @ProjectID                                                
      AND TD.IsDeleted = 0              
      AND TD.IsSDTicket=0         
   and @supportTypeId<>2      
   AND ( ((@assignmentgrpcount>0  and ag.SupportTypeID=1 AND AG.AssignmentGroupMapID IN(SELECT AssignmentgrpIds from #tmpAssignment) and ag.IsBOTGroup=0) OR @assignmentgrpcount=0))    
      
   UNION      
      
   SELECT       
   Distinct      
 ISNULL(it.AssignedTo,'') as AssigneeID,      
 ISNULL(LM.EmployeeName,'') as AssigneeName,      
 IT.ProjectID as ProjectID,      
 AG.AssignmentGroupMapID ,      
 AG.AssignmentGroupName,      
 '' as ApplicationID,      
 '' as ApplicationName,      
 IT.TowerID as TowerID,      
 TDD.TowerName as TowerName,      
 IT.TicketID as req_no,      
 IT.TicketDescription as TicketDescription,      
 '' as ServiceID,      
 '' as ServiceName,      
 0 as CategoryID,      
 0 as ActivityID,      
 IT.TicketStatusMapID as StatusID,      
 IT.DARTStatusID AS DartStatusID,      
 IT.TicketTypeMapID AS TicketTypeID,      
 PSM.StatusName as StatusName,      
 IT.EffortTillDate as EffortTillDate,      
 IT.ActualEffort as ITSMEffort,      
 PM.IsMainSpringConfigured as IsMainSpringConfig,      
 PM.IsDebtEnabled as IsDebtEnabled,      
 IT.IsSDTicket,      
 IT.OpenDateTime AS create_Date ,            
    IT.Closeddate AS resolved_date,      
 IT.TicketCreateDate AS TicketCreateDate,      
 ISNULL(IT.IsAttributeUpdated,0) AS IsAttributeUpdated       
         
   ,2 AS 'SupportTypeID','Infra' as 'SupportTypeName'      
         
    from AVL.TK_TRN_InfraTicketDetail IT       
   LEFT JOIN      
   AVL.MAS_LoginMaster(NOLOCK) LM on LM.UserID=IT.AssignedTo AND IT.ProjectID=LM.ProjectID      
 left join AVL.InfraTowerDetailsTransaction(NOLOCK) TDD on IT.TowerID=TDD.InfraTowerTransactionID        
       
 left join AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM on IT.TicketTypeMapID=TTM.TicketTypeMappingID AND IT.ProjectID=TTM.ProjectID AND IT.IsDeleted=0      
 Left join AVL.BOTAssignmentGroupMapping AG ON IT.AssignmentGroupID=AG.AssignmentGroupMapID AND AG.ProjectID=IT.ProjectID      
       
 left join AVL.TK_MAP_ProjectStatusMapping(NOLOCK) PSM on  PSM.StatusID=IT.TicketStatusMapID AND  PSM.IsDeleted = 0           
         
 left join AVL.MAS_ProjectMaster(NOLOCK) PM on IT.ProjectID= PM.ProjectID       
       
  WHERE PM.IsDeleted = 0       
   AND (LM.EmployeeID LIKE '%' + @AssignedTo + '%'OR @AssignedTo = '' OR @AssignedTo IS NULL)       
        
   AND ((IT.TicketID LIKE '%' + @req + '%' OR @req = '' OR @req IS NULL)       
   )                  
    AND (((@flagTower = 1) AND (EXISTS ( SELECT 1 FROM #tmpTowerids where Towerids=IT.TowerID)))       
      OR ((@flagTower = 2  and @flag = 2)))                       
      AND ((ISNULL(@StatusIDs,'')= '' AND IT.TicketStatusMapID=IT.TicketStatusMapID) OR (IT.TicketStatusMapID IN(SELECT Item  FROM dbo.Split(@StatusIDs,','))))                       
    AND ((@flgDate=1 AND ((IT.OpenDateTime BETWEEN @datebegin AND @dateend))) OR (@flgDate=4 AND (1=1)))              
     AND ((@flgendDate=1 AND (IT.Closeddate BETWEEN @closebegin AND @closeend)) OR (@flgendDate=4 AND (1=1)))      
   AND IT.ProjectID = @ProjectID                                                
      AND IT.IsDeleted = 0              
      AND IT.IsSDTicket=0         
   AND @supportTypeId<>1      
   AND ( ((@assignmentgrpcount>0 and AG.SupportTypeID=2  AND AG.AssignmentGroupMapID IN(SELECT AssignmentgrpIds from #tmpAssignment) and ag.IsBOTGroup=0) OR @assignmentgrpcount=0))      
      
      
      
   END            
  ELSE            
   BEGIN       
   INSERT INTO #Result      
    select  Distinct      
 ISNULL(TD.AssignedTo,'') as AssigneeID,      
 ISNULL(LM.EmployeeName,'') as AssigneeName,      
 TD.ProjectID as ProjectID,      
 AG.AssignmentGroupMapID ,      
 AG.AssignmentGroupName,      
 TD.ApplicationID as ApplicationID,      
 AD.ApplicationName as ApplicationName,      
 '' as TowerID,      
 '' as TowerName,      
 TD.TicketID as req_no,      
 TD.TicketDescription as TicketDescription,      
 TD.ServiceId as ServiceID,      
 MASS.ServiceName as ServiceName,      
 0 as CategoryID,      
 0 as ActivityID,       
      
 TD.TicketStatusMapID as StatusID,      
 TD.DARTStatusID AS DartStatusID,      
 TD.TicketTypeMapID AS TicketTypeID,      
 PSM.StatusName as StatusName,      
 TD.EffortTillDate as EffortTillDate,      
 TD.ActualEffort as ITSMEffort,      
 PM.IsMainSpringConfigured as IsMainSpringConfig,      
 PM.IsDebtEnabled as IsDebtEnabled,      
 TD.IsSDTicket,      
 TD.OpenDateTime AS create_Date ,            
    TD.Closeddate AS resolved_date,      
 TD.TicketCreateDate AS TicketCreateDate,      
 ISNULL(TD.IsAttributeUpdated,0) AS IsAttributeUpdated        
 ,1 AS 'SupportTypeID','App' as 'SupportTypeName'      
 from AVL.TK_TRN_TicketDetail(NOLOCK) TD       
 left join  AVL.MAS_LoginMaster(NOLOCK) LM on LM.UserID=TD.AssignedTo      
 left join AVL.APP_MAS_ApplicationDetails(NOLOCK) AD on AD.ApplicationID=TD.ApplicationID      
 left join AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM on TD.TicketTypeMapID=TTM.TicketTypeMappingID AND TD.ProjectID=TTM.ProjectID AND TD.IsDeleted=0      
 Left join AVL.BOTAssignmentGroupMapping AG ON TD.AssignmentGroupID=AG.AssignmentGroupMapID AND AG.ProjectID=TD.ProjectID      
 left join AVL.TK_MAS_Service MASS(NOLOCK) on TD.ServiceID=MASS.ServiceID      
 left join AVL.TK_MAP_ProjectStatusMapping(NOLOCK) PSM on PSM.StatusID=TD.TicketStatusMapID AND  PSM.IsDeleted = 0           
       
 left join AVL.MAS_ProjectMaster(NOLOCK) PM on TD.ProjectID= PM.ProjectID       
 left join AVL.TK_PRJ_ServiceProjectMapping(NOLOCK) SPM on SPM.ServiceID=TD.ServiceID and SPM.ProjectID=TD.ProjectID      
      
      
   WHERE PM.IsDeleted = 0       
   AND (LM.EmployeeID LIKE '%' + @AssignedTo + '%'OR @AssignedTo = '' OR @AssignedTo IS NULL)       
             
    AND ((TD.TicketID LIKE '%' + @req + '%' OR @req = '' OR @req IS NULL)       
    )       
    AND (((@flag = 1) AND (EXISTS (SELECT 1 FROM dbo.Split(@applicationID,',') WHERE TD.ApplicationID = Item)))       
       OR ((@flagTower = 2  and @flag = 2)))           
   AND (isnull(@StatusIDs,'')= '' OR (TD.TicketStatusMapID IN(SELECT Item  FROM dbo.Split(@StatusIDs,','))))               
                       
    AND ((@flgDate=1 AND ((TD.OpenDateTime BETWEEN @datebegin AND @dateend))) OR (@flgDate=4 AND (1=1)))              
     AND ((@flgendDate=1 AND (TD.Closeddate BETWEEN @closebegin AND @closeend)) OR (@flgendDate=4 AND (1=1)))      
   AND TD.ProjectID = @ProjectID                                                
      AND TD.IsDeleted = 0              
      AND TD.IsSDTicket=1      
   and @supportTypeId<>2      
    AND (((@assignmentgrpcount>0 AND AG.SupportTypeID=1 AND  AG.AssignmentGroupMapID IN(SELECT AssignmentgrpIds from #tmpAssignment)and ag.IsBOTGroup=0) OR @assignmentgrpcount=0))      
      
      
     UNION      
      
   SELECT ISNULL(it.AssignedTo,'') as AssigneeID,      
 ISNULL(LM.EmployeeName,'') as AssigneeName,      
 IT.ProjectID as ProjectID,      
 AG.AssignmentGroupMapID ,      
 AG.AssignmentGroupName,      
 '' as ApplicationID,      
 '' as ApplicationName,      
 IT.TowerID as TowerID,      
 TDD.TowerName as TowerName,      
 IT.TicketID as req_no,      
 IT.TicketDescription as TicketDescription,      
 '' as ServiceID,      
 '' as ServiceName,      
 0 as CategoryID,      
 0 as ActivityID,      
 IT.TicketStatusMapID as StatusID,      
 IT.DARTStatusID AS DartStatusID,      
 IT.TicketTypeMapID AS TicketTypeID,      
 PSM.StatusName as StatusName,      
 IT.EffortTillDate as EffortTillDate,      
 IT.ActualEffort as ITSMEffort,      
 PM.IsMainSpringConfigured as IsMainSpringConfig,      
 PM.IsDebtEnabled as IsDebtEnabled,      
 IT.IsSDTicket,      
 IT.OpenDateTime AS create_Date ,            
    IT.Closeddate AS resolved_date,      
 IT.TicketCreateDate AS TicketCreateDate,      
 ISNULL(IT.IsAttributeUpdated,0) AS IsAttributeUpdated       
 ,2 AS 'SupportTypeID','Infra' as 'SupportTypeName'      
    from AVL.TK_TRN_InfraTicketDetail IT       
   LEFT JOIN      
   AVL.MAS_LoginMaster(NOLOCK) LM on LM.UserID=IT.AssignedTo AND IT.ProjectID=LM.ProjectID      
 left join AVL.InfraTowerDetailsTransaction(NOLOCK) TDD on IT.TowerID=TDD.InfraTowerTransactionID        
       
 left join AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM on IT.TicketTypeMapID=TTM.TicketTypeMappingID AND IT.ProjectID=TTM.ProjectID AND IT.IsDeleted=0      
 Left join AVL.BOTAssignmentGroupMapping AG ON IT.AssignmentGroupID=AG.AssignmentGroupMapID AND AG.ProjectID=IT.ProjectID      
       
 left join AVL.TK_MAP_ProjectStatusMapping(NOLOCK) PSM on  PSM.StatusID=IT.TicketStatusMapID AND  PSM.IsDeleted = 0           
         
 left join AVL.MAS_ProjectMaster(NOLOCK) PM on IT.ProjectID= PM.ProjectID       
       
  WHERE PM.IsDeleted = 0       
   AND (LM.EmployeeID LIKE '%' + @AssignedTo + '%'OR @AssignedTo = '' OR @AssignedTo IS NULL)       
        
   AND ((IT.TicketID LIKE '%' + @req + '%' OR @req = '' OR @req IS NULL)      
    )                  
    AND (((@flagTower = 1) AND (EXISTS ( SELECT 1 FROM #tmpTowerids where Towerids=IT.TowerID)))       
       OR ((@flagTower = 2  and @flag = 2)))                       
      AND ((ISNULL(@StatusIDs,'')= '' AND IT.TicketStatusMapID=IT.TicketStatusMapID) OR (IT.TicketStatusMapID IN(SELECT Item  FROM dbo.Split(@StatusIDs,','))))                       
    AND ((@flgDate=1 AND ((IT.OpenDateTime BETWEEN @datebegin AND @dateend))) OR (@flgDate=4 AND (1=1)))              
     AND ((@flgendDate=1 AND (IT.Closeddate BETWEEN @closebegin AND @closeend)) OR (@flgendDate=4 AND (1=1)))      
   AND IT.ProjectID = @ProjectID                                                
      AND IT.IsDeleted = 0              
      AND IT.IsSDTicket=1        
   and @supportTypeId<>1      
   AND ( ((@assignmentgrpcount>0 AND AG.SupportTypeID=2 AND AG.AssignmentGroupMapID IN(SELECT AssignmentgrpIds from #tmpAssignment) and AG.IsBOTGroup=0) OR @assignmentgrpcount=0))         
       
   END       
      
    IF @TicketCount=0 AND @ServiceCount=0      
   BEGIN      
  SELECT * FROM #Result   ORDER BY create_date    
   END      
   ELSE IF @TicketCount>0 AND @ServiceCount>0      
   BEGIN       
   SELECT * FROM #Result      
   R INNER JOIN @TicketingDetails T ON R.req_no=T.TicketID      
   INNER JOIN @ServiceDetails S ON R.ServiceID=S.ID    
   ORDER BY create_date    
   END      
   ELSE IF @TicketCount>0       
   BEGIN       
   SELECT * FROM #Result      
   R INNER JOIN @TicketingDetails T ON R.req_no=T.TicketID      
   ORDER BY create_date    
   END      
   ELSE       
   BEGIN       
   SELECT * FROM #Result R      
   INNER JOIN @ServiceDetails S ON R.ServiceID=S.ID      
   ORDER BY create_date    
   END      
        
   DROP TABLE #Result;                             
SET NOCOUNT OFF;                      
END TRY        
BEGIN CATCH        
      
  DECLARE @ErrorMessage VARCHAR(MAX);      
      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
      
  --INSERT Error          
  EXEC AVL_InsertError '[AVL].[Effort_GetChooseTicketDetails] ', @ErrorMessage, @ProjectID,0      
        
 END CATCH              
END
