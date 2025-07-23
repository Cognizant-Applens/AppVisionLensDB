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
-- Description:   get mini session data
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- EXEC [AVL].[Mini_GetMiniSessionsByEmployeeID] '471742','11-26-2018'

-- ============================================================================ 


CREATE PROCEDURE [AVL].[Mini_GetMiniSessionsByEmployeeID] 
(
@EmployeeID varchar(50),
@CurrentDate DATETIME
)
AS
BEGIN
BEGIN TRY
SELECT ProjectID,TimeZoneId INTO #MAS_LoginMaster FROM AVL.MAS_LoginMaster
  WHERE EmployeeID=@EmployeeID AND IsDeleted=0

SELECT ProjectID INTO #MAS_ConfiguredProjects FROM AVL.MAS_LoginMaster
  WHERE EmployeeID=@EmployeeID AND IsDeleted=0 AND ISNULL(IsMiniConfigured,1)=1

SELECT LM.ProjectID,LM.TimeZoneId,TZM.TZoneName as UserTimeZone,
TZM1.TZoneName AS ProjectTimeZone INTO #TimeZones FROM #MAS_LoginMaster LM
INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
ON LM.ProjectID =PM.ProjectID
LEFT JOIN AVL.MAP_ProjectConfig PC ON PM.ProjectID=PC.ProjectID
LEFT JOIN AVL.MAS_TimeZoneMaster TZM ON LM.TIMEZONEid=TZM.TimeZoneID
LEFT JOIN AVL.MAS_TimeZoneMaster TZM1 ON ISNULL(PC.TimeZoneId,32)=TZM1.TimeZoneID


--Hemanth

declare @Time table
(
SessionID varchar(max),
Hours int,
Min int,
Sec int
)

INSERT INTO @Time
SELECT SessionID, 
convert(varchar(5),DateDiff(s, StartTime, GETDATE())/3600),
convert(varchar(5),DateDiff(s, StartTime, GETDATE())%3600/60),
convert(varchar(5),(DateDiff(s, StartTime, getdate())%60))  
  from AVL.TK_Mini_Sessions(NOLOCK) where isrunning=0 and CONVERT(date,usercreatedtimedate)=CONVERT(date,@CurrentDate) 

update M set M.Hours=T.Hours,M.Minutes=T.Min,M.Seconds=T.Sec from AVL.TK_Mini_Sessions(NOLOCK) M 
join @Time T on T.SessionID=M.SessionID 

--select * from AVL.MAS_TimeZoneMaster 
	SELECT SessionID,isnull(UserID,0) AS UserID,MS.ProjectID,MS.TicketID,ISNULL(TD.TicketDescription,'') AS TicketDesc,TicketOpenDate,ISNULL(MS.ApplicationID,0) AS ApplicationID,
	ISNULL(MS.ServiceID,0) AS ServiceID,
	ISNULL(MS.ActivityID,0) AS ActivityID,ISNULL(MS.TicketTypeMapID,0)AS TicketTypeMapID,ISNULL(MS.PriorityMapID,0) AS PriorityMapID,MS.TicketStatusMapID,StartTime,EndTime,
	IsAuto,[Hours],[Minutes],Seconds,ISNULL(IsProcessed,0) AS IsProcessed,EmployeeID,RequestSource,
	ISNULL(MS.IsSDTicket,0) AS IsSDTicket ,IsNonDelivery,NonDeliveryActivityType,MS.IsDeleted,MS.CreatedBy,CreatedOn,MS.TimeTickerID,IsRunning,ISNULL(NonTicketDescription,'') AS NonTicketDescription,
	ISNULL(TD.IsAttributeUpdated,0) AS IsAttributeUpdated,
	UserTimeZone AS UserTimeZoneName, ProjectTimeZone  AS ProjectTimeZoneName,SuggestedActivityName AS SuggestedActivity
						FROM AVL.TK_Mini_Sessions(NOLOCK) MS 
						LEFT JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD
						ON MS.TicketID=TD.TicketID AND MS.ProjectID=TD.ProjectID
						LEFT JOIN #TimeZones TZ ON MS.ProjectID=TZ.ProjectID
						WHERE EmployeeID=@EmployeeID
						AND CONVERT(DATE,MS.UserCreatedTimeDate)=CONVERT(DATE,@CurrentDate)
						AND ((MS.ProjectID IN(SELECT PROJECTID FROM #MAS_ConfiguredProjects) AND MS.IsRunning=1) OR 
						ISNULL(MS.IsRunning,0)=0)
						AND ISNULL(MS.IsDeleted,0)=0
						--ORDER BY MS.SessionID DESC

		END TRY  

BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Mini_GetMiniSessionsByEmployeeID]', @ErrorMessage, @EmployeeID,0
END CATCH  

END
