/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


-- ============================================================================
-- Author:      Prakash     
-- Create date:      23 Nov 2018
-- Description:   get todays report status
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
--  EXEC [AVL].[Mini_GetTodaysReportStatus]'471742','2018-11-30'

-- ============================================================================ 

-- EXEC [AVL].[Mini_GetTodaysReportStatus]'471742','2018-12-11'
CREATE PROCEDURE [AVL].[Mini_GetTodaysReportStatus]
(
@EmployeeID NVARCHAR(50),
@CurrentDate DATETIME =NULL
)
AS
BEGIN
SET NOCOUNT ON; 
BEGIN TRY
	
	IF @CurrentDate= NULL
	BEGIN
		SET @CurrentDate=GETDATE()
	END
	DECLARE @PreviousDate DATE;
	SET @PreviousDate=@CurrentDate-1

	--SELECT @PreviousDate

		SELECT MS.SessionID,MS.UserID,MS.ProjectID,MS.TicketID,MS.ApplicationID,MS.ServiceID, 
		ad.ApplicationName,sam.ServiceName,sam.ActivityID,sam.ActivityName,MS.EmployeeID,
		pm.ProjectName,RTRIM(LTRIM(pm.IsCoginzant)) as IsCoginzant,ttm.TicketTypeMappingID,ttm.TicketType AS TicketTypeName,
		((ISNULL(ms.[hours],0)*3600)+ (ISNULL(ms.[minutes],0)*60)+ISNULL(ms.[seconds],0)) AS TotalSeconds
		,nda.NonTicketedActivity AS NonDeliveryActivityName,ISNULL(MS.IsNonDelivery,0) AS IsNonDelivery,
		CONVERT(DATE,MS.UserCreatedTimeDate) AS UserCreatedTimeDate,ISNULL(MS.IsProcessed,0) AS IsProcessed
		INTO #MiniSessions
		FROM AVL.TK_Mini_Sessions (NOLOCK) MS 
		LEFT JOIN avl.TK_MAS_ServiceActivityMapping sam on MS.ServiceID=sam.ServiceID and MS.ActivityID=sam.ActivityID
		LEFT JOIN AVL.MAS_ProjectMaster pm on ms.ProjectID=pm.ProjectID
		LEFT JOIN AVL.TK_MAP_TicketTypeMapping ttm on ms.TicketTypeMapID = ttm.TicketTypeMappingID
		left join AVL.MAS_NonDeliveryActivity NDA ON NDA.ID=MS.NonDeliveryActivityType
		LEFT JOIN AVL.TK_TRN_TicketDetail(NOLOCK)  TD ON MS.ProjectID=TD.ProjectID
		AND MS.TicketID=TD.TicketID
		LEFT JOIN avl.APP_MAS_ApplicationDetails ad on TD.ApplicationID=ad.ApplicationID and ad.IsActive=1
		WHERE MS.EmployeeID=@EmployeeID AND
		CONVERT(DATE,MS.UserCreatedTimeDate) IN (CONVERT(DATE,@CurrentDate),CONVERT(DATE,@PreviousDate)) AND 
		(MS.IsDeleted IS NULL OR MS.IsDeleted = 0) 

				UPDATE MS SET MS.ServiceName=sam.ServiceName
		from #MiniSessions MS
		INNER JOIN avl.TK_MAS_ServiceActivityMapping sam on MS.ServiceID=sam.ServiceID 

		SELECT MS.SessionID,MS.UserID,MS.ProjectID,MS.TicketID,MS.ApplicationID,MS.ServiceID, 
				MS.ApplicationName,MS.ServiceName,MS.ActivityID,MS.ActivityName,MS.EmployeeID,
				MS.ProjectName,MS.IsCoginzant,MS.TicketTypeMappingID,MS.TicketTypeName,
				cast(ROUND(ms.TotalSeconds/3600+((((ms.TotalSeconds%3600)/60.00)/60.00)),2)as numeric(8,2)) AS TotalHours,
				MS.NonDeliveryActivityName,ISNULL(MS.IsNonDelivery,0) AS IsNonDelivery,UserCreatedTimeDate,
				ISNULL(MS.IsProcessed,0) AS IsProcessed
				into #FinalSessions
				FROM #MiniSessions MS

		SELECT MS.UserID,MS.ProjectID,MS.TicketID,MS.EmployeeID,UserCreatedTimeDate,				
				SUM(ISNULL(TotalHours,0)) AS TotalHours,
				Max(sessionID) as SessionID 
				INTO #GroupedTickets
				FROM #FinalSessions MS
				GROUP By MS.ProjectID,MS.TicketID,MS.EmployeeID,MS.UserID,MS.UserCreatedTimeDate

		SELECT MS.SessionID,MS.UserID,MS.ProjectID,MS.TicketID,MS.ApplicationID,MS.ServiceID, 
				ISNULL(MS.ApplicationName,'NA') AS ApplicationName,ISNULL(MS.ServiceName,'NA') AS ServiceName,MS.ActivityID,ISNULL(MS.ActivityName,'NA') AS ActivityName,MS.EmployeeID,
				MS.ProjectName,MS.IsCoginzant,MS.TicketTypeMappingID,MS.TicketTypeName,
				MS.NonDeliveryActivityName,
				GT.TotalHours,ISNULL(MS.IsNonDelivery,0) AS IsNonDelivery,ISNULL(MS.IsProcessed,0) AS IsProcessed
				FROM #FinalSessions MS
				join #GroupedTickets gt on MS.SessionID = gt.SessionID
				WHERE MS.UserCreatedTimeDate=CONVERT(DATE,@CurrentDate)
				ORDER BY SessionID

		SELECT MS.SessionID,MS.UserID,MS.ProjectID,MS.TicketID,MS.ApplicationID,MS.ServiceID, 
				ISNULL(MS.ApplicationName,'NA') AS ApplicationName,ISNULL(MS.ServiceName,'NA') AS ServiceName,MS.ActivityID,ISNULL(MS.ActivityName,'NA') AS ActivityName,MS.EmployeeID,
				MS.ProjectName,MS.IsCoginzant,MS.TicketTypeMappingID,MS.TicketTypeName,
				MS.NonDeliveryActivityName,
				GT.TotalHours,ISNULL(MS.IsNonDelivery,0) AS IsNonDelivery,ISNULL(MS.IsProcessed,0) AS IsProcessed
				FROM #FinalSessions MS
				join #GroupedTickets gt on MS.SessionID = gt.SessionID
				WHERE MS.UserCreatedTimeDate=CONVERT(DATE,@PreviousDate)
				ORDER BY SessionID

		DROP TABLE #MiniSessions
		DROP TABLE #GroupedTickets
		DROP TABLE #FinalSessions
		
		SET NOCOUNT OFF;   
END TRY
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Mini_GetTodaysReportStatus]', @ErrorMessage, @EmployeeID,0
END CATCH 


END
