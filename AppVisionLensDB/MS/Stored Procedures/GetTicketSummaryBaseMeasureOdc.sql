/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--exec [MS].[GetTicketSummaryBaseMeasureOdc] 19602,4,'',62018 
CREATE PROCEDURE [MS].[GetTicketSummaryBaseMeasureOdc] 
	@ProjectID INT,
	@FrequencyID INT=NULL,
	@ServiceIDs VARCHAR(500)=NULL,
	@ReportFrequencyID INT=NULL
AS
BEGIN
SET NOCOUNT ON;

	BEGIN
		SELECT 
		S.ServiceID AS ServiceID,
		S.ServiceName AS ServiceName,
		MPM.MainspringPriorityID AS PRIORITYID,
		MPM.MainspringPriorityName AS MainspringPriorityName,
		MSC.MainspringSUPPORTCATEGORYID AS SUPPORTCATEGORY,
		MSC.MainspringSUPPORTCATEGORYName AS MainspringSUPPORTCATEGORYName,
		TSM.TicketSummaryBaseID AS TicketSummaryBaseID,
		TSM.TicketSummaryBaseName AS TicketSummaryBaseName,
		0 AS TicketSummaryValue,
		@ProjectID AS ProjectID,
		@ReportFrequencyID AS ReportPeriodID,
		@FrequencyID AS FrequencyID
		INTO #TicketStaging
			FROM  MS.MAP_TicketSummary_Stage_Mapping(NOLOCK) TS
			INNER JOIN MS.MAS_TicketSummaryBase_Master TSM ON TS.TicketSummaryBaseID = TSM.TicketSummaryBaseID
			--INNER join AVL.MAS_ProjectMaster Prj on prj.ProjectID=TS.ProjectID
			--INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSAM ON prj.ProjectID = PSAM.ProjectID
			--INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM ON  PSAM.ServiceMapID =SAM.ServiceMappingID
			INNER JOIN AVL.TK_MAS_Service s on s.ServiceID=TS.ServiceID
			LEFT JOIN MS.MAS_Priority_Master (NOLOCK) MPM
				ON MPM.MainspringPriorityID = TS.M_PRIORITYID
			LEFT JOIN MS.MAS_SUPPORTCATEGORY_Master (NOLOCK) MSC
				ON MSC.MainspringSUPPORTCATEGORYID = TS.M_SUPPORTCATEGORY
			WHERE TS.ProjectID = @ProjectID
			AND TS.IsDeleted=0
			
			UPDATE MS.TRN_ManualTicketSummaryBaseMeasureData SET Priority=NULL
			WHERE Priority='' and  ProjectID=@ProjectID and ReportPeriodID=@ReportFrequencyID
			UPDATE MS.TRN_ManualTicketSummaryBaseMeasureData SET SUPPORTCATEGORY=NULL
			WHERE SUPPORTCATEGORY='' and  ProjectID=@ProjectID and ReportPeriodID=@ReportFrequencyID
	
	
		SELECT 
			T.ServiceID,T.ServiceName,T.TicketSummaryBaseID,T.TicketSummaryBaseName,
			T.PRIORITYID,T.MainspringPriorityName,T.SUPPORTCATEGORY,
			T.MainspringSUPPORTCATEGORYName,
			U.TicketBaseMeasureValue AS TicketSummaryValue
			FROM #TicketStaging T
			 left JOIN MS.TRN_ManualTicketSummaryBaseMeasureData U
			ON T.ServiceID=U.ServiceID
			AND T.TicketSummaryBaseID=U.TicketSummaryBaseMeasureID
			AND isnull(T.PRIORITYID,1)=isnull(U.Priority,1) --OR( T.MainspringPriorityID IS NULL) --OR (T.MainspringPriorityID IS NULL AND U.Priority IS NULL))
			AND isnull(T.SUPPORTCATEGORY,1)=isnull(U.SupportCategory,1)-- OR  (T.MainspringSUPPORTCATEGORYID is NULL)--OR (T.MainspringSUPPORTCATEGORYID IS NULL AND U.SupportCategory IS NULL))
			AND T.FrequencyID=U.FrequencyID
			AND T.ReportPeriodID=U.ReportPeriodID
			AND T.ProjectID=U.ProjectID
			WHERE T.ServiceID IN(SELECT DISTINCT
			SM.ServiceID
		FROM AVL.MAS_ProjectMaster PM
		INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSAM
			ON PM.ProjectID = PSAM.ProjectID
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM
			ON  PSAM.ServiceMapID =SAM.ServiceMappingID
		INNER JOIN AVL.TK_MAS_Service SM
			ON SM.ServiceID = SAM.ServiceID WHERE PSAM.ProjectID=@ProjectID AND IsMainspringData='Y')
			
			DROP Table #TicketStaging

		
	END
END

