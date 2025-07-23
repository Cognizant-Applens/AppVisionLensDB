/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Effort_GetSearchTicketDetails]  
--[dbo].[Effort_GetSearchTicketDetails] '','',4,'D94','515869','3','','',6,0
--[dbo].[Effort_GetSearchTicketDetails] '','2/28/2018',4,'D94','515869','3','','',6,0
--[dbo].[Effort_GetSearchTicketDetails] '','',4,'','515869','3','','','',1



 @daterangebegin DATETIME ,      
 @daterangeend DATETIME ,      
 @ProjectID INT ,      
 @req NVARCHAR(MAX) ,      
 @AssignedTo NVARCHAR(MAX) ,           
 @applicationID NVARCHAR(MAX) ,      
 @create_date_begin DATETIME ,      
 @create_date_end DATETIME ,      
 @StatusIDs NVARCHAR(MAX),
 @IsDARTTicket INT 
--@TimesheetDate DATETIME            
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
   SET @req = REPLACE(REPLACE(REPLACE(@req, '[', '[[]'), '_', '[_]'), '%', '[%]')          
    
 IF(@daterangebegin<>'' AND @daterangeend<>'')        
  BEGIN        
   SET @closebegin=CONVERT(DATETIME,@daterangebegin) + '00:00:00'        
   SET @closeend=CONVERT(DATETIME,@daterangeend) + '23:59:59'        
   SET @flgendDate=1        
  END        
 ELSE        
  BEGIN        
   IF(@daterangebegin='' AND @daterangeend='')        
    BEGIN        
     SET @closebegin=NULL;        
     SET @closeend=NULL;        
     SET @flgendDate=4        
    END        
  END        
    
 IF ( @create_date_begin <> '' AND @create_date_end <> '')       
  BEGIN        
   SET @datebegin = CONVERT(DATETIME, @create_date_begin)      
   + '00:00:00'            
   SET @dateend = CONVERT(DATETIME, @create_date_end)      
   + '23:59:59'        
   SET @flgDate = 1        
  END        
      
 ELSE IF ( @create_date_begin = '' AND @create_date_end = '')       
  BEGIN        
   SET @datebegin = NULL;        
   SET @dateend = NULL;        
   SET @flgDate = 4        
  END         
       
  IF (@applicationID <> '')     
   SET @flag = 1                                    
  ELSE     
   SET @flag = 2          
    
	--SELECT @StatusIDs

  IF @IsDARTTicket=0
  BEGIN      
  SELECT   distinct  
      TM.TicketID AS req_no ,      
      TM.TicketDescription AS TicketDescription,
	  TTM.TicketType AS TicketType,
	  TM.ServiceId as ServiceID, 
	  SPM.ServiceName as ServiceName,
	  TM.TicketStatusMapID as StatusID,    
     --'TicketDescription'as TicketDescription,    
      LM.EmployeeID AS AssigneeID , 
      LM.EmployeeName AS AssigneeName ,      
      status= DS.DARTStatusName ,      
      TM.OpenDateTime ,      
      TM.Closeddate ,
	  TM.TicketCreateDate AS TicketCreateDate,          
      ASM.ApplicationName AS applicationName ,      
      TM.ApplicationID ,          
      TM.OpenDateTime AS create_Date ,      
      TM.Closeddate AS resolved_date ,      
      TM.IsManual ,      
      TM.ProjectID ,
	  TM.IsSDTicket, 
	  TM.EffortTillDate as EffortTillDate,
	  TM.ActualEffort as ITSMEffort,
	  PM.IsMainSpringConfigured as IsMainSpringConfig,
	  PM.IsDebtEnabled as IsDebtEnabled,
	 SPM.CategoryID,
	 SPM.CategoryName,
	 SPM.ActivityID,
	 SPM.ActivityName,
      CASE WHEN TM.TicketDescription <> ''      
      THEN ISNULL(TM.TicketDescription, 'No Description')      
      ELSE 'No Description'      
      END AS Description	   
    FROM  AVL.TK_TRN_TicketDetail TM (NOLOCK)                     
    JOIN [AVL].[MAS_ProjectMaster] PM (NOLOCK) ON TM.ProjectID = PM.ProjectID 
	join [AVL].[TK_MAS_DARTTicketStatus] DS on TM.TicketStatusMapID=DS.DARTStatusID  
      --JOIN [AVL].[TK_MAS_DARTTicketStatus] DS (NOLOCK) ON TM.DARTStatusID=DS.DARTStatusID
	  join AVL.TK_PRJ_ServiceProjectMapping SPM on TM.ServiceID=SPM.ServiceID AND SPM.ProjectID=@ProjectID 
	  --JOIN AVL.TK_MAS_Service MASS ON SPM.ServiceID=MASS.ServiceID          
      JOIN [AVL].[APP_MAS_ApplicationDetails] ASM (NOLOCK) ON ASM.ApplicationID = TM.ApplicationID           
      JOIN [AVL].[MAS_LoginMaster] LM (NOLOCK) ON LM.UserID  = TM.AssignedTo 
	  JOIN AVL.TK_MAP_TicketTypeMapping TTM (NOLOCK) ON TM.ProjectID = TTM.ProjectID and TM.TicketTypeMapID = TTM.TicketTypeMappingID   
      WHERE PM.IsDeleted = 0 AND LM.EmployeeID=@AssignedTo
	  AND ((TM.TicketID LIKE '%' + @req + '%' OR @req = '' OR @req IS NULL) OR (TM.TicketDescription LIKE '%' + @req + '%' OR @req = '' OR @req IS NULL))            
      AND (LM.EmployeeID LIKE '%' + @AssignedTo + '%'OR @AssignedTo = '' OR @AssignedTo IS NULL)      
      AND LM.ProjectID = @ProjectID
	  AND LM.UserID =TM.AssignedTo 
	   AND (((@flag = 1) AND (EXISTS (SELECT 1 FROM dbo.Split(@applicationID,',') WHERE TM.ApplicationID = Item))) 
	     OR ((@flag = 2 )))                 
      AND ((@StatusIDs='' AND TM.TicketStatusMapID=TM.TicketStatusMapID) OR (TM.TicketStatusMapID IN(SELECT Item  FROM dbo.Split(@StatusIDs,','))))                 
	   AND ((@flgDate=1 AND ((TM.OpenDateTime BETWEEN @datebegin AND @dateend))) OR (@flgDate=4 AND (1=1)))        
      AND ((@flgendDate=1 AND (TM.Closeddate BETWEEN @closebegin AND @closeend)) OR (@flgendDate=4 AND (1=1)))  
	  AND TM.ProjectID = @ProjectID                    
      AND DS.IsDeleted = 0                           
      AND TM.IsDeleted = 0        
      AND TM.IsSDTicket=0            

   END      
  ELSE      
   BEGIN 
    SELECT   distinct 
      TM.TicketID AS req_no ,      
      TM.TicketDescription AS TicketDescription,
	  TTM.TicketType AS TicketType,
	  TM.ServiceId as ServiceID, 
	  SPM.ServiceName as ServiceName,
	  TM.TicketStatusMapID as StatusID,    
     --'TicketDescription'as TicketDescription,    
      LM.EmployeeID AS AssigneeID , 
      LM.EmployeeName AS AssigneeName ,      
      status= DS.DARTStatusName ,      
      TM.OpenDateTime ,      
      TM.Closeddate ,
	  TM.TicketCreateDate AS TicketCreateDate,          
      ASM.ApplicationName AS applicationName ,      
      TM.ApplicationID ,          
      TM.OpenDateTime AS create_Date ,      
      TM.Closeddate AS resolved_date ,      
      TM.IsManual ,      
      TM.ProjectID ,
	  TM.IsSDTicket, 
	  TM.EffortTillDate as EffortTillDate,
	  TM.ActualEffort as ITSMEffort,
	  PM.IsMainSpringConfigured as IsMainSpringConfig,
	  PM.IsDebtEnabled as IsDebtEnabled,
	 SPM.CategoryID,
	 SPM.CategoryName,
	 SPM.ActivityID,
	 SPM.ActivityName,
      CASE WHEN TM.TicketDescription <> ''      
      THEN ISNULL(TM.TicketDescription, 'No Description')      
      ELSE 'No Description'      
      END AS Description	   
    FROM  AVL.TK_TRN_TicketDetail TM (NOLOCK)                     
    JOIN [AVL].[MAS_ProjectMaster] PM (NOLOCK) ON TM.ProjectID = PM.ProjectID 
	join [AVL].[TK_MAS_DARTTicketStatus] DS on TM.TicketStatusMapID=DS.DARTStatusID   
      --JOIN [AVL].[TK_MAS_DARTTicketStatus] DS (NOLOCK) ON TM.DARTStatusID=DS.DARTStatusID 
	  join AVL.TK_PRJ_ServiceProjectMapping SPM on TM.ServiceID=SPM.ServiceID AND SPM.ProjectID=@ProjectID 
	  --JOIN AVL.TK_MAS_Service MASS ON SPM.ServiceID=MASS.ServiceID       
      JOIN [AVL].[APP_MAS_ApplicationDetails] ASM (NOLOCK) ON ASM.ApplicationID = TM.ApplicationID           
      JOIN [AVL].[MAS_LoginMaster] LM (NOLOCK) ON LM.UserID  = TM.AssignedTo 
	  JOIN AVL.TK_MAP_TicketTypeMapping TTM (NOLOCK) ON TM.ProjectID = TTM.ProjectID and TM.TicketTypeMapID = TTM.TicketTypeMappingID             
      WHERE PM.IsDeleted = 0  AND LM.EmployeeID=@AssignedTo
	  AND ((TM.TicketID LIKE '%' + @req + '%' OR @req = '' OR @req IS NULL) OR (TM.TicketDescription LIKE '%' + @req + '%' OR @req = '' OR @req IS NULL))            
      AND (LM.EmployeeID LIKE '%' + @AssignedTo + '%'OR @AssignedTo = '' OR @AssignedTo IS NULL)      
      AND LM.ProjectID = @ProjectID
	  AND LM.UserID =TM.AssignedTo 
	   AND (((@flag = 1) AND (EXISTS (SELECT 1 FROM dbo.Split(@applicationID,',') WHERE TM.ApplicationID = Item))) 
	     OR ((@flag = 2 )))                 
      AND ((@StatusIDs='' AND TM.TicketStatusMapID=TM.TicketStatusMapID) OR (TM.TicketStatusMapID IN(SELECT Item  FROM dbo.Split(@StatusIDs,','))))                 
	   AND ((@flgDate=1 AND ((TM.OpenDateTime BETWEEN @datebegin AND @dateend))) OR (@flgDate=4 AND (1=1)))        
      AND ((@flgendDate=1 AND (TM.Closeddate BETWEEN @closebegin AND @closeend)) OR (@flgendDate=4 AND (1=1)))  
	  AND TM.ProjectID = @ProjectID                    
      AND DS.IsDeleted = 0                           
      AND TM.IsDeleted = 0        
      AND TM.IsSDTicket=1         
    
   END                        
SET NOCOUNT OFF;                      
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[Effort_GetSearchTicketDetails] ', @ErrorMessage, @ProjectID,0
	END CATCH  
END
