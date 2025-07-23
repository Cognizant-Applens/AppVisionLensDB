/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetAssignedTicketsBySearch] 
  (                
   	 @TicketFilters [AVL].[TVP_KEDB_TicketSearchFilters]  READONLY	    
  )
AS
BEGIN  
 
BEGIN TRY 
  SET NOCOUNT ON;

  --inserting into temp table  multiple comma separated values
   DECLARE @Projects TABLE(ProjectId BIGINT)
   DECLARE @AppIDs TABLE(ApplicationId BIGINT)
   DECLARE @StatusDetails TABLE(Status NVarchar(20))
   DECLARE @ServiceIDs TABLE(ServiceId BIGINT)
   DECLARE @Prioritys TABLE(PriorityId BIGINT)
   DECLARE @DateFrom datetime=null
   DECLARE @DateTo datetime=null
   DECLARE @UserId  varchar(50)=null 
   DECLARE @TotalTickets  INT
   DECLARE @TicketReferred INT
 
 DECLARE @KA_Rate TABLE( TimeTickerID BIGINT, TicketID nvarchar(100),TicketDescription nvarchar(MAX),ApplicationID BIGINT,ApplicationName nvarchar(500),
			TicketTypeID BIGINT, ServiceID INT, ServiceName nvarchar(100),PriorityName varchar(200),StatusName varchar(200),
		   OpenDateTime DATETIME,OpenDays INT,  KAID BIGINT, KATicketID nvarchar(100),ISLINKED int) 


  SELECT @DateFrom = DateFrom, @DateTo = DateTo,@UserId = UserId from  @TicketFilters
 INSERT INTO @AppIDs
     SELECT Item  FROM dbo.Split((SELECT [Application]  FROM   @TicketFilters),',')

  INSERT INTO @StatusDetails
     SELECT Item  FROM dbo.Split((SELECT [Status]  FROM   @TicketFilters),',')

   INSERT INTO @ServiceIDs
    SELECT Item  FROM dbo.Split((SELECT [Service]  FROM   @TicketFilters),',')

  INSERT INTO @Projects
     SELECT Item  FROM dbo.Split((SELECT [ProjectId]  FROM   @TicketFilters),',')

  INSERT INTO @Prioritys
     SELECT Item  FROM dbo.Split((SELECT [Priority]  FROM   @TicketFilters),',')

	 INSERT INTO  @ServiceIDs values(0) -- for tickets without serviceid
SELECT Distinct TimeTickerID,TicketId,TD.ProjectId,TicketDescription,TD.ApplicationID,ApplicationName,TicketTypeID,
   TD.ServiceID,ISNULL(Servicename,'') ServiceName,prioritymapid,PriorityName,PSM.statusid, PSM.StatusName AS StatusName,
   OpenDateTime,DATEDIFF(day,ISNULL(OpenDateTime,getdate()),getdate()) as OpenDays
   into #temp FROM [AVL].[TK_TRN_TicketDetail]  TD (nolock)
        INNER JOIN  @Projects  P on P.ProjectId= TD.ProjectID
        INNER JOIN AVL.[TK_MAP_PriorityMapping] PM  (nolock)
                   ON TD.prioritymapid = PM.priorityidmapid  AND TD.projectid = pm.projectid 
				   AND PM.IsDeleted=0				
        INNER JOIN AVL.[APP_MAS_ApplicationDetails]  AD  (nolock)
                   ON TD.applicationid = AD.applicationid AND AD.IsActive=1	
        INNER JOIN [AVL].[TK_MAP_TicketTypeMapping]  TTM ( nolock)
                   ON TD.tickettypemapid = TTM.tickettypemappingid   
				   AND td.projectid = ttm.projectid AND TTM.IsDeleted=0
		INNER JOIN [AVL].[TK_MAS_TicketType] TT (nolock)
		           ON TT.tickettypeid = TTM.avmtickettype AND (TTM.avmtickettype = 1 OR TTM.avmtickettype = 2) AND TT.IsDeleted=0
		LEFT JOIN [AVL].[TK_MAS_Service] S (nolock)
		           ON S.ServiceID = TD.ServiceID  AND S.IsDeleted=0
		INNER JOIN [AVL].[mas_loginmaster] LM (nolock)  
		           ON LM.userid = TD.assignedto  AND LM.EmployeeID = @UserId 
				   AND LM.ProjectId=TD.ProjectID  AND LM.IsDeleted=0
	    INNER JOIN [AVL].[TK_MAP_ProjectStatusMapping] PSM  ( nolock)
		           ON PSM.statusid = TD.ticketstatusmapid AND td.projectid = psm.projectid 
				   AND PSM.IsDeleted=0
        INNER JOIN [AVL].[TK_Mas_dartticketstatus] DT ( nolock)
                   ON PSM.ticketstatus_id = DT.dartstatusid  AND dt.isdeleted = 0
		
           WHERE  TD.isdeleted = 0 AND --TD.ProjectId=10337  AND
		           ( ISNULL(DT.dartstatusid,0) = 2 OR
					ISNULL(DT.dartstatusid,0) = 3  OR
					ISNULL(DT.dartstatusid,0) = 4  OR
					ISNULL(DT.dartstatusid,0) = 6  OR
					ISNULL(DT.dartstatusid,0) = 10 OR
					ISNULL(DT.dartstatusid,0) = 11 OR
					ISNULL(DT.dartstatusid,0) = 13 )
           --Order By TT.tickettypeid desc  handle in c#

IF(@DateFrom IS NOT NULL AND  @DateTo IS NOT NULL) 
  BEGIN
  INSERT INTO @KA_Rate 
	  SELECT TimeTickerID,t.TicketID,TicketDescription,t.ApplicationID,ApplicationName,TicketTypeID,
	   t.ServiceID,ISNULL(Servicename,'') ServiceName,PriorityName,StatusName,
	   OpenDateTime,OpenDays, 
	   KA.KAID, KA.KATicketID,M.IsLinked   		
	   FROM #temp  t (NOLOCK)
		INNER JOIN  @AppIDs  A  on A.ApplicationId= t.ApplicationId
		INNER JOIN  @StatusDetails  S on S.Status= t.StatusID
		INNER JOIN  @ServiceIDs  Ser on Ser.ServiceId= t.ServiceId	
		INNER JOIN  @Prioritys  Pr on Pr.PriorityId= t.prioritymapid
		LEFT JOIN  [AVL].[KEDB_TRN_KARating_MapTicketId] M  (NOLOCK) on M.TicketId = t.TicketId --AND M.Projectid= t.ProjectID
		LEFT JOIN [AVL].[KEDB_TRN_KATicketDetails]  KA (NOLOCK) ON M.KAID = KA.KAId  AND KA.IsDeleted =0
		WHERE  (CONVERT(DATE, t.OpenDateTime) BETWEEN CONVERT(DATE, @DateFrom) 
		 AND CONVERT(DATE, @DateTo))
			
  END
  ELSE
      BEGIN
	  INSERT INTO  @KA_Rate 
		  SELECT TimeTickerID,t.TicketID,TicketDescription,t.ApplicationID,ApplicationName,TicketTypeID,
		   t.ServiceID,ISNULL(Servicename,'') ServiceName,PriorityName,StatusName,
		   OpenDateTime,OpenDays,
		   KA.KAID, KA.KATicketID,M.IsLinked
		   FROM #temp  t  (NOLOCK)
			INNER JOIN  @AppIDs  A on A.ApplicationId= t.ApplicationId
			INNER JOIN  @StatusDetails  S on S.Status= t.StatusID
			INNER JOIN  @ServiceIDs  Ser on Ser.ServiceId= t.ServiceId	
			INNER JOIN  @Prioritys  Pr on Pr.PriorityId= t.prioritymapid
			LEFT JOIN  [AVL].[KEDB_TRN_KARating_MapTicketId] M  (NOLOCK) on M.TicketId = t.TicketId --AND M.Projectid= t.ProjectID
			LEFT JOIN [AVL].[KEDB_TRN_KATicketDetails]  KA (NOLOCK) ON M.KAID = KA.KAId  AND KA.IsDeleted =0
					
	  END

	  SELECT 
 DISTINCT  R.TimeTickerID, TicketID,TicketDescription,ApplicationID,ApplicationName,TicketTypeID,
 ServiceID, ServiceName,PriorityName,StatusName,
 OpenDateTime as TicketCreateDate,OpenDays , 
		0 as KAReferred,
		 -- R.TicketID,				  
    KAReferredName = STUFF
			((
				SELECT ','+ CAST(KATicketID AS VARCHAR(400))           			
				   from @KA_Rate  tp 				  
				   Where tp.TicketID =  R.TicketID AND tp.ISLINKED=1
      			FOR XMl PATH('') 
   			  ),1,1,''
			 )
   FROM @KA_Rate R 			
   	SET NOCOUNT OFF
 END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		EXEC AVL_InsertError '[AVL].[KEDB_GetAssignedTicketsBySearch] ', @ErrorMessage, @UserId,''
		RETURN @ErrorMessage
  END CATCH
END
