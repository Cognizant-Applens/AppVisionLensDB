/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[BCS_ColumnDataMerge]
@userid int,
@esaprojectid bigint
AS
  SELECT DM.ApplensColumnID,AC.ApplensColumns,CM.RemedyColumn,CM.ServiceNowColumn,CM.OtherITSMColumn,DM.ApplensDataID,TK.TicketTypeName DataName,DM.RemedyData,DM.ServiceData,DM.OtherData,cm.CreatedAt,dm.CreatedAt
FROM [BCS].[DataMapping] DM 
JOIN BCS.ColumnMapping  CM ON CM.ApplensColumnID=DM.applenscolumnid and CM.UserId = DM.UserID
JOIN BCS.TicketTemplateApplensColumns AC ON DM.ApplensColumnID = AC.ApplensColumnID
JOIN [AVL].[TK_MAS_TicketType] TK ON TK.TicketTypeID = DM.ApplensDataID
WHERE DM.ApplensColumnID = 4 and CM.UserId= @userid and CM.ESAProjectID = @esaprojectid and
dm.CreatedAt = (select distinct top(1) CreatedAt as DataCreatedAt from [BCS].[DataMapping] where DM.UserId= @userid and DM.ESAProjectID = @esaprojectid order by CreatedAt desc)
and cm.CreatedAt = (select distinct top(1) CreatedAt as ColumnCreatedAt from [BCS].[ColumnMapping] where CM.UserId= @userid and CM.ESAProjectID = @esaprojectid order by CreatedAt desc)

UNION ALL (
SELECT DM.ApplensColumnID,AC.ApplensColumns,CM.RemedyColumn,CM.ServiceNowColumn,CM.OtherITSMColumn,DM.ApplensDataID,DT.DARTStatusName DataName,DM.RemedyData,DM.ServiceData,DM.OtherData,cm.CreatedAt,dm.CreatedAt
FROM [BCS].[DataMapping] DM 
JOIN BCS.ColumnMapping  CM ON CM.ApplensColumnID=DM.applenscolumnid and CM.UserId = DM.UserID
JOIN BCS.TicketTemplateApplensColumns AC ON DM.ApplensColumnID = AC.ApplensColumnID
JOIN [AVL].[TK_MAS_DARTTicketStatus] DT ON DT.DARTStatusID = DM.ApplensDataID
WHERE DM.ApplensColumnID = 5 and CM.UserId= @userid and CM.ESAProjectID = @esaprojectid and
dm.CreatedAt = (select distinct top(1) CreatedAt as DataCreatedAt from [BCS].[DataMapping] where DM.UserId= @userid and DM.ESAProjectID = @esaprojectid order by CreatedAt desc)
and cm.CreatedAt = (select distinct top(1) CreatedAt as ColumnCreatedAt from [BCS].[ColumnMapping] where CM.UserId= @userid and CM.ESAProjectID = @esaprojectid order by CreatedAt desc) 
)
UNION ALL 
(
SELECT DM.ApplensColumnID,AC.ApplensColumns,CM.RemedyColumn,CM.ServiceNowColumn,CM.OtherITSMColumn,DM.ApplensDataID,PT.PriorityName DataName,DM.RemedyData,DM.ServiceData,DM.OtherData,cm.CreatedAt,dm.CreatedAt
FROM [BCS].[DataMapping] DM 
JOIN BCS.ColumnMapping  CM ON CM.ApplensColumnID=DM.applenscolumnid and CM.UserId = DM.UserID
JOIN BCS.TicketTemplateApplensColumns AC ON DM.ApplensColumnID = AC.ApplensColumnID
JOIN [AVL].[TK_MAS_Priority]  PT ON PT.PriorityID = DM.ApplensDataID
WHERE DM.ApplensColumnID = 13 and CM.UserId= @userid and CM.ESAProjectID = @esaprojectid and dm.CreatedAt = (select distinct top(1) CreatedAt as DataCreatedAt from [BCS].[DataMapping] where DM.UserId= @userid and DM.ESAProjectID = @esaprojectid order by CreatedAt desc)
and cm.CreatedAt = (select distinct top(1) CreatedAt as ColumnCreatedAt from [BCS].[ColumnMapping] where CM.UserId= @userid and CM.ESAProjectID = @esaprojectid order by CreatedAt desc) 
)