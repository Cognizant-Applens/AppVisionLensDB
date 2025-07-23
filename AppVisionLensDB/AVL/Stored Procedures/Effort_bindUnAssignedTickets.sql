/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Effort_bindUnAssignedTickets] --'T3',515869,4
 @req_no NVARCHAR(1000),
 @EmployeeID int,
 --@date AS DATETIME,
 @ProjectID int
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;

SELECT DISTINCT
--@date AS [Date] ,
B.TicketID AS [TicketNumber] ,
1000 AS Ticket ,
B.TicketDescription as   TicketDescription,
LM.EmployeeID,
CASE WHEN B.ApplicationID IS NULL THEN 0
ELSE B.ApplicationID
END AS ApplicationID ,
DS.StatusID,
DS.StatusName,
B.ActualEffort as ITSMEffort,
SPM.CategoryID as CategoryID,
--SPM.CategoryName as CategoryName,
SPM.ActivityID  as ActivityID,
--SPM.ActivityName as ActivityName,
NULL AS Activity ,
NULL AS Hours ,
NULL AS Remarks ,

B.ServiceID,
ISNULL(B.IsAttributeUpdated,0) AS IsAttributeUpdated,
ISNULL(B.IsSDTicket,0) AS IsSDTicket,
B.TicketTypeMapID AS  TicketTypeID ,
TTM.TicketType AS  TicketTypeName,
B.ProjectID,
B.EffortTilldate ,
B.TicketCreateDate,

--ISNULL(B.IsC20Processed,0) AS IsC20Processed,
 --CASE WHEN (SELECT COUNT(*)     
 --     FROM  MAS.C20Services 
 --     WHERE C20ServiceID =  B.ServiceID       
 --    )=0  
 --         THEN 0    
 --   ELSE 1     
 --   END AS IsSentToC20, 
  ISNULL(SM.ServiceName,'') AS ServiceName    
FROM  AVL.TK_TRN_TicketDetail B  
JOIN AVL.MAS_LoginMaster LM on LM.UserID=B.AssignedTo
JOIN AVL.MAS_ProjectMaster PM ON B.ProjectID = PM.ProjectID
join AVL.TK_MAP_ProjectStatusMapping DS on B.TicketStatusMapID=DS.TicketStatus_ID      
JOIN AVL.TK_MAS_Service SM ON SM.ServiceID = B.ServiceID 
join AVL.TK_PRJ_ServiceProjectMapping SPM on B.ServiceID=SPM.ServiceID AND SPM.ProjectID=@ProjectID 
JOIN AVL.TK_MAP_TicketTypeMapping TTM ON TTM.ProjectID = @ProjectID AND B.TicketTypeMapID = TTM.TicketTypeMappingID
WHERE ISNULL(B.TicketID,'') != ''  AND PM.IsDeleted = 0       
AND PM.IsDeleted = 0 AND B.TicketID IN (  
SELECT  Item  
FROM    dbo.Split(@req_no, ';') ) AND  
 TTM.IsDeleted = 0 AND
B.ProjectID = @ProjectID  
ORDER BY TicketNumber DESC

SET NOCOUNT OFF;
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_bindUnAssignedTickets]', @ErrorMessage, @ProjectID,0
		
	END CATCH  
END
