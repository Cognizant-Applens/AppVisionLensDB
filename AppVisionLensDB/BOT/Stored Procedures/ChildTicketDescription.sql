/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [BOT].[ChildTicketDescription]
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
DECLARE @jobId NVARCHAR(50) = CAST((SELECT DATEDIFF(second,'2020-01-01 00:00:00.000',GETDATE())) AS NVARCHAR(50))

IF(SELECT COUNT(Id) FROM [BOT].[ChildTicketDescriptionJobMonitor] WHERE JobType='DecryptionJob') = 0
BEGIN
INSERT INTO [BOT].[ChildTicketDescriptionJobMonitor]
VALUES(@jobId,'DecryptionJob','System',GETDATE(),'System',GETDATE())

SELECT td.TimeTickerID,htd.HealingTicketID HealingTicketID,td.TicketID DARTTicketID,td.ApplicationID,td.ProjectID,
td.AssignedTo,td.TicketDescription TicketDescriptionEncrypted,hpc.CreatedBy,hpc.CreatedDate,hpc.ModifiedBy,hpc.ModifiedDate
FROM [AVL].[TK_TRN_TicketDetail] td (NOLOCK)
INNER JOIN [AVL].[DEBT_PRJ_HealParentChild] hpc (NOLOCK) ON hpc.DARTTicketID=td.TicketID 
INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] htd (NOLOCK) ON htd.ProjectPatternMapID=hpc.ProjectPatternMapID
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPPM (NOLOCK) ON HPPM.ProjectPatternMapID = htd.ProjectPatternMapID
AND HPPM.ProjectId = td.ProjectID
WHERE td.TicketDescription !='' AND td.TicketDescription IS NOT NULL AND htd.TicketType in ('A') AND htd.IsDeleted=0 AND hpc.MapStatus=1 
AND hpc.IsDeleted=0 AND td.IsDeleted=0
END

ELSE 
BEGIN
DECLARE @startDate DATETIME, @endDate DATETIME=GETDATE(), @count BIGINT
SET @startDate = (SELECT CreatedDate FROM [BOT].[ChildTicketDescriptionJobMonitor] WHERE Id=(SELECT MAX(Id) FROM [BOT].[ChildTicketDescriptionJobMonitor] WHERE JobType='DecryptionJob'))

SET @count = (SELECT COUNT(TimeTickerID) FROM (SELECT td.TimeTickerID,htd.HealingTicketID HealingTicketID,td.TicketID DARTTicketID,td.ApplicationID,td.ProjectID,
td.AssignedTo,td.TicketDescription TicketDescriptionEncrypted,hpc.CreatedBy,hpc.CreatedDate,hpc.ModifiedBy,hpc.ModifiedDate
FROM [AVL].[TK_TRN_TicketDetail] td (NOLOCK)
INNER JOIN [AVL].[DEBT_PRJ_HealParentChild] hpc (NOLOCK) ON hpc.DARTTicketID=td.TicketID 
INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] htd (NOLOCK) ON htd.ProjectPatternMapID=hpc.ProjectPatternMapID
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPPM (NOLOCK) ON HPPM.ProjectPatternMapID = htd.ProjectPatternMapID
AND HPPM.ProjectId = td.ProjectID
WHERE td.TicketDescription !='' AND td.TicketDescription IS NOT NULL AND htd.TicketType in ('A') AND htd.IsDeleted=0 AND hpc.MapStatus=1 
AND hpc.IsDeleted=0 AND td.IsDeleted=0 AND ((hpc.CreatedDate >= @startDate AND hpc.CreatedDate <= @endDate) OR 
(hpc.ModifiedDate >= @startDate AND hpc.ModifiedDate <= @endDate)))q)  

IF(@count) > 0
BEGIN
INSERT INTO [BOT].[ChildTicketDescriptionJobMonitor]
VALUES(@jobId,'DecryptionJob','System',GETDATE(),'System',GETDATE())

SELECT td.TimeTickerID,htd.HealingTicketID HealingTicketID,td.TicketID DARTTicketID,td.ApplicationID,td.ProjectID,
td.AssignedTo,td.TicketDescription TicketDescriptionEncrypted,hpc.CreatedBy,hpc.CreatedDate,hpc.ModifiedBy,hpc.ModifiedDate
FROM [AVL].[TK_TRN_TicketDetail] td (NOLOCK)
INNER JOIN [AVL].[DEBT_PRJ_HealParentChild] hpc (NOLOCK) ON hpc.DARTTicketID=td.TicketID 
INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] htd (NOLOCK) ON htd.ProjectPatternMapID=hpc.ProjectPatternMapID
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPPM (NOLOCK) ON HPPM.ProjectPatternMapID = htd.ProjectPatternMapID
AND HPPM.ProjectId = td.ProjectID
WHERE td.TicketDescription !='' AND td.TicketDescription IS NOT NULL AND htd.TicketType in ('A') AND htd.IsDeleted=0 AND hpc.MapStatus=1 
AND hpc.IsDeleted=0 AND td.IsDeleted=0 AND ((hpc.CreatedDate >= @startDate AND hpc.CreatedDate <= @endDate) OR 
(hpc.ModifiedDate >= @startDate AND hpc.ModifiedDate <= @endDate))
END 
END
END TRY
BEGIN CATCH
DECLARE @errorMessage VARCHAR(MAX);

		SELECT @errorMessage = ERROR_MESSAGE()
		EXEC [BOT].[InsertError] '[BOT].[ChildTicketDescription]',@errorMessage,0,0
END CATCH
END
