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
--	Author: Dhivya Bharathi M          
--  Create date:    July 1 2019   
--  EXEC  [AVL].[Effort_AppInfraSyncUpJob]  
-- ============================================================================
CREATE PROCEDURE [AVL].[Effort_AppInfraSyncUpJob]         
AS        
BEGIN     
BEGIN TRY   
	SET NOCOUNT ON;     

	BEGIN   
	DECLARE @LastJobRunTime DATETIME ;
	DECLARE @JobID BIGINT;
	SET @LastJobRunTime=(SELECT TOP 1 EndTime FROM AVL.AppInfraTicketsSyncUpStatus(NOLOCK) ORDER BY ID DESC)
	INSERT INTO AVL.AppInfraTicketsSyncUpStatus (StartTime,ISDELETED,IsProcessed,CreatedDate,CreatedBy) 
	VALUES(GETDATE(),0,0,GETDATE(),'System')
	SET @JobID=SCOPE_IDENTITY();

	CREATE TABLE #TicketsEligible
	(
	ProjectID BIGINT NOT NULL,
	TicketID NVARCHAR(100) NULL,
	AppDARTStatusID INT NULL,
	AppStatusID BIGINT NULL,
	InfraDARTStatusID INT NULL,
	InfraStatusID BIGINT NULL,
	AppLastUpdatedDate DATETIME NULL,
	InfraLastUpdatedDate DATETIME NULL,
	AppTimeTickerID BIGINT NULL,
	InfraTimeTickerID BIGINT NULL
	)

	--Modified Ticket detail
	INSERT INTO #TicketsEligible
	SELECT TD.ProjectID,TD.TicketID,TD.DARTStatusID AS AppDARTStatusID,TD.TicketStatusMapID AS AppStatusID,
	ITD.DARTStatusID AS InfraDARTStatusID,ITD.TicketStatusMapID AS InfraStatusID,
	TD.LastUpdatedDate AS AppLastUpdatedDate,
	ITD.LastUpdatedDate AS InfraLastUpdatedDate,TD.TimeTickerID AS AppTimeTickerID,
	ITD.TimeTickerID AS InfraTimeTickerID FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD
	INNER JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) ITD ON TD.ProjectID=ITD.ProjectID
	AND TD.TicketID=ITD.TicketID
	WHERE (TD.LastUpdatedDate >= @LastJobRunTime OR ITD.LastUpdatedDate >= @LastJobRunTime)

	CREATE TABLE #ToModify
	(
	AppTimeTickerID BIGINT NULL,
	InfraTimeTickerID BIGINT NULL,
	ProjectID BIGINT NULL,
	TicketID NVARCHAR(100) NULL,
	DARTStatusID INT NULL,
	StatusID BIGINT NULL,
	SupportTypeID  INT NULL
	)

	--Check For App Tickets that are modified after Infra Tickets
	INSERT INTO #ToModify
	SELECT AppTimeTickerID,InfraTimeTickerID,ProjectID,TicketID,AppDARTStatusID,AppStatusID,1
	FROM #TicketsEligible 
	WHERE AppLastUpdatedDate >= InfraLastUpdatedDate
	AND AppDARTStatusID IN(8,9) AND InfraDARTStatusID != 8


	--Check for Infra Tickets that are modified after App Tickets with status Closed
	INSERT INTO #ToModify
	SELECT AppTimeTickerID,InfraTimeTickerID,ProjectID,TicketID,InfraDARTStatusID,InfraStatusID ,2
	 FROM #TicketsEligible 
	WHERE   InfraLastUpdatedDate >= AppLastUpdatedDate
	AND InfraDARTStatusID IN( 8,9) and AppDARTStatusID != 8  

	UPDATE TD  SET TD.DartStatusID=MP.DARTStatusID,TD.TicketStatusMapID=MP.StatusID,
	LastUpdatedDate=GETDATE(),LastModifiedSource=10
	 FROM AVL.TK_TRN_TicketDetail TD
	INNER JOIN #ToModify MP ON TD.ProjectID=MP.ProjectID AND TD.TicketID =MP.TicketID
	WHERE  MP.SupportTypeID=2

	UPDATE TD  SET TD.DartStatusID=MP.DARTStatusID,TD.TicketStatusMapID=StatusID,LastUpdatedDate=GETDATE(),
	LastModifiedSource=10
	 FROM AVL.TK_TRN_InfraTicketDetail TD
	INNER JOIN #ToModify MP ON TD.ProjectID=MP.ProjectID AND TD.TicketID =MP.TicketID
	WHERE  MP.SupportTypeID=1

	UPDATE AVL.AppInfraTicketsSyncUpStatus SET EndTime=GETDATE(),IsProcessed=1 WHERE ID= @JobID
	
	INSERT INTO AVL.AppInfraStatusSyncUpLog
	(JobID,TimeTickerID,SupportTypeID,ProjectID,TicketID,CreatedDate,CreatedBy)
	SELECT DISTINCT @JobID,AppTimeTickerID,SupportTypeID,ProjectID,TicketID,GETDATE(),'System'   FROM  #ToModify




	IF OBJECT_ID('tempdb..#TicketsEligible', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #TicketsEligible
	END
	
	IF OBJECT_ID('tempdb..#ToModify', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #ToModify
	END

     
	END   
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Effort_AppInfraSyncUpJob]', @ErrorMessage, 0 ,0
		
	END CATCH   
END
