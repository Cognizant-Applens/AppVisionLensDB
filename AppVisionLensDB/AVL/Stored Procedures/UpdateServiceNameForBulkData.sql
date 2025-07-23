/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[UpdateServiceNameForBulkData] 
@BulkServiceName [AVL].[BulkServiceName] READONLY,
@BulkTimeTickerID [AVL].[DeleteServiceClassificationTempTable] READONLY  
AS 
  BEGIN 
      BEGIN TRY 

	  CREATE TABLE #ServiceNameBulkUpdate
	  (
			TimeTickerID BIGINT,
			ServiceName NVARCHAR(200)			
	  )

	  CREATE TABLE #DeleteServiceClassifiationUpload
	  (
		TimeTickerID BIGINT		
	  )

	  INSERT INTO #ServiceNameBulkUpdate(TimeTickerID,ServiceName)
	  SELECT TimeTickerID,ServiceName FROM @BulkServiceName

	  INSERT INTO #DeleteServiceClassifiationUpload(TimeTickerID)
	  SELECT TimeTickerID FROM @BulkTimeTickerID

	  UPDATE  TD SET TD.ServiceID = MS.ServiceID, TD.ServiceClassificationMode = 5
		FROM [AVL].[TK_TRN_TicketDetail] TD  INNER JOIN #ServiceNameBulkUpdate BU
			ON TD.TimeTickerID = BU.TimeTickerID
		INNER JOIN AVL.MAS_ProjectMaster PM 
			ON PM.ProjectID = TD.ProjectID
		INNER JOIN AVL.TK_MAS_Service MS
			ON BU.ServiceName = MS.ServiceName		
		INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSM
			ON PSM.ProjectID = TD.ProjectID 
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM
			ON SAM.ServiceMappingID = PSM.ServiceMapID AND MS.ServiceID = SAM.ServiceID 
		INNER JOIN AVL.TK_MAP_TicketTypeMapping TTM
			ON TD.ProjectID = TTM.ProjectID AND TD.TicketTypeMapID = TTM.TicketTypeMappingID AND TTM.SupportTypeID = 1
		INNER JOIN AVL.TK_MAP_TicketTypeServiceMapping TSM
			ON TTM.TicketTypeMappingID = TSM.TicketTypeMappingID AND MS.ServiceID = TSM.ServiceID 
		AND TD.IsDeleted = 0 AND TD.ServiceID = 0 AND TD.ServiceClassificationMode = 3
		AND MS.IsDeleted = 0 AND PSM.IsDeleted = 0 AND SAM.IsDeleted = 0 AND TTM.IsDeleted = 0
		AND TSM.IsDeleted = 0	

	DELETE SCT FROM
	AVL.ServiceAutoClassification_TicketUpload SCT INNER JOIN [AVL].[TK_TRN_TicketDetail] TD
		ON SCT.ProjectID = TD.ProjectID AND SCT.[Ticket ID] = TD.TicketID
	INNER JOIN #DeleteServiceClassifiationUpload SCU ON TD.TimeTickerID = SCU.TimeTickerID
		
		
   END TRY 

   BEGIN CATCH 
          DECLARE @ErrorMessage1 VARCHAR(MAX); 

          SELECT @ErrorMessage1 = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[AVL].[UpdateServiceNameForBulkData]', 
            @ErrorMessage1, 
           NULL,
            0 
      END CATCH 
  END
