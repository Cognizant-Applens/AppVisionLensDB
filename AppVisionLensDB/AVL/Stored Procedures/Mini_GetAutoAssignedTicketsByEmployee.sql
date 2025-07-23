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
-- Description:    auto assigned tickets
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
--  [AVL].[Mini_GetAutoAssignedTicketsByEmployee]  '471742','2018-11-26'

-- ============================================================================ 
-- [AVL].[Mini_GetAutoAssignedTicketsByEmployee]  '471742','2018-11-26'
CREATE Procedure [AVL].[Mini_GetAutoAssignedTicketsByEmployee] 
@EmployeeID NVARCHAR(50)=null,
@CurrentDate DATETIME
AS
BEGIN
	BEGIN TRY

	SELECT UserID,ProjectID,EmployeeID,TimeZoneId,CustomerID,IsDeleted INTO #MAS_LoginMaster FROM AVL.MAS_LoginMaster(NOLOCK) WHERE EmployeeID=@EmployeeID AND IsDeleted=0
	AND isnull(IsMiniConfigured,1)=1

	
				select distinct top 100 LM.CustomerID,TD.ProjectID, TD.ApplicationID,TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket
	,PM.ProjectName AS ProjectName
			,null as ActivityId,
			ZM.TZoneName AS UserTimeZoneName,
			TD.OpenDateTime,
			TD.ServiceID,S.ServiceName AS ServiceName,
			TD.TicketTypeMapID AS TicketTypeID,TTM.TicketType AS TicketTypeName,
			ISNULL(C.IsCognizant,0) AS IsCognizant, ISNULL(AD.ApplicationName,'') AS ApplicationName
			INTO #AutoAssignedTicketTemp 
			from [AVL].[TK_TRN_TicketDetail](NOLOCK) TD 
			INNER JOIN #MAS_LoginMaster LM ON TD.AssignedTo=LM.UserID and LM.IsDeleted=0
			INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID
			INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=C.CustomerID and PM.ProjectID=LM.ProjectID
			INNER JOIN [AVL].[BusinessClusterMapping](NOLOCK)  BCM ON  BCM.CustomerId=C.CustomerID
			INNER JOIN [AVL].[APP_MAS_ApplicationDetails](NOLOCK) AD ON AD.SubBusinessClusterMapID=BCM.BusinessClusterMapID AND TD.ApplicationID=AD.ApplicationID
			INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) APM  ON APM.ApplicationID=AD.ApplicationID and APM.ProjectID=PM.ProjectID
			LEFT JOIN AVL.MAS_TimeZoneMaster ZM ON LM.TimeZoneId=ZM.TimeZoneID
			LEFT JOIN AVL.TK_MAS_Service S ON TD.ServiceID=S.ServiceID
			LEFT JOIN AVL.TK_MAP_TicketTypeMapping TTM ON TD.ProjectID=TTM.ProjectID AND TD.TicketTypeMapID=TTM.TicketTypeMappingID
			WHERE LM.EmployeeID = @EmployeeID 
			AND  CONVERT(DATE,TD.OpenDateTime) <= CONVERT(DATE,@CurrentDate) 
			AND ((ISNULL(TD.DARTStatusID,0) <> 8) OR (ISNULL(TD.DARTStatusID,0) = 8 AND ISNULL(TD.EffortTillDate,0) =0))
			AND CONVERT(DATE,TD.OpenDateTime) >= DATEADD(DAY,-6,CONVERT(DATE,@CurrentDate))
			ORDER BY TD.OpenDateTime DESC
				
	SELECT * FROM #AutoAssignedTicketTemp

	END TRY  

BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Mini_GetAutoAssignedTicketsByEmployee]', @ErrorMessage, @EmployeeID,0
END CATCH  

END
