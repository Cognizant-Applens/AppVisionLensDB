/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [AVL].[Infra_SaveTaskMappingDetails]
@InfraSaveTaskMappingDetails AVL.TVP_InfraSaveTaskMappingDetails READONLY,
@CustomerID BIGINT,
@UserID Nvarchar(max)
AS
BEGIN

BEGIN TRY
MERGE AVL.InfraTaskTransaction IT USING (SELECT InfraTransactionTaskID,InfraTaskName FROM @InfraSaveTaskMappingDetails 
GROUP BY InfraTransactionTaskID,InfraTaskName) Infra
ON IT.InfraTransactionTaskID = Infra.InfraTransactionTaskID AND IT.isdeleted=0 And CustomerID=@CustomerID
WHEN MATCHED
    THEN 
	UPDATE SET 
        IT.InfraTaskName = Infra.InfraTaskName
		,IT.ModifiedBy = @UserID
		,IT.ModifiedDate = GETDATE()
WHEN NOT MATCHED
    THEN 
	INSERT 
(Customerid,[InfraTaskName],[IsDeleted],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate])
	values(@CustomerID,Infra.InfraTaskName,0,@UserID,getdate(),NULL,NULL);

---Save Update mapping Transaction

SELECT [InfraTaskID],
	[TechnologyTowerID],
	[TechnologyTower],
	[ServiceLevelID],
	[ServiceLevelName],
	[InfraTransactionTaskID],
	[InfraTaskName],
	[IsEnabled],
	[IsMaster] INTO #InfraSaveTaskMappingDetails 
	FROM @InfraSaveTaskMappingDetails

UPDATE STM
SET STM.InfraTransactionTaskID = IT.InfraTransactionTaskID
FROM #InfraSaveTaskMappingDetails STM
JOIN AVL.InfraTaskTransaction IT
	ON IT.CustomerID = @CustomerID
	AND IT.InfraTaskName = STM.InfraTaskName
	AND (IT.InfraTransactionTaskID = STM.InfraTransactionTaskID OR  STM.InfraTransactionTaskID=0)
	AND IT.IsDeleted = 0


MERGE AVL.InfraTaskMappingTransaction IMT USING #InfraSaveTaskMappingDetails Infra
ON IMT.InfraTaskID=Infra.InfraTaskID
AND IMT.InfraTransactionTaskID = Infra.InfraTransactionTaskID 
AND IMT.isdeleted=0 And CustomerID=@CustomerID
WHEN MATCHED
    THEN 
	UPDATE SET 
         IMT.TechnologyTowerID = Infra.TechnologyTowerID
		,IMT.SupportLevelID = Infra.ServiceLevelID
		,IMT.InfraTransactionTaskID = Infra.InfraTransactionTaskID
		,IMT.IsEnabled = Infra.IsEnabled
		,IMT.ModifiedBy = @UserID
		,IMT.ModifiedDate = GETDATE()
WHEN NOT MATCHED
    THEN 
	INSERT 
(CUSTOMERID,[InfraMasterTaskMappingID],[TechnologyTowerID],[SupportLevelID],[InfraTransactionTaskID],[IsMaster],[IsEnabled],[IsDeleted]
,[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate])
VALUES(@CustomerID,NULL,INFRA.TechnologyTowerID,INFRA.ServiceLevelID,INFRA.InfraTransactionTaskID,INFRA.IsMaster,INFRA.IsEnabled,0
		,@UserID,GETDATE(),NULL,NULL);

END TRY BEGIN CATCH

DECLARE @ErrorMessage VARCHAR(MAX);
SELECT
	@ErrorMessage = ERROR_MESSAGE()
EXEC AVL_InsertError	'AVL.Infra_SaveTaskMappingDetails'
						,@ErrorMessage
						,0
						,0

END CATCH


END
