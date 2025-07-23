/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[SaveGenericWorkItemConfig] 
@ProjectID INT,
@ExecutionID INT,
@CustomerID INT=NULL,
@WorkItemIDs VARCHAR(300),
@CreatedBy VARCHAR(100)=NULL
AS  	 
BEGIN  
	BEGIN TRY

	UPDATE [PP].[ALM_MAP_GenericWorkItemConfig] SET IsDeleted=1 WHERE ProjectID=@ProjectID AND ExecutionId=@ExecutionID
	
	MERGE [PP].[ALM_MAP_GenericWorkItemConfig] T
	USING (SELECT @ProjectID AS ProjectId,@ExecutionID AS ExecutionID,CAST(SD.Value AS BIGINT) WorkItemTypeId FROM STRING_SPLIT(@WorkItemIDs, ',')SD) S
	ON (S.WorkItemTypeId = T.WorkItemTypeId AND S.ProjectId=T.ProjectId AND S.ExecutionId=T.ExecutionId)  
	WHEN MATCHED 
		 THEN UPDATE
		 SET  T.IsDeleted=0
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (ProjectId,ExecutionId,WorkItemTypeId,IsDeleted,CreatedDate,CreatedBy)
	VALUES (S.ProjectId,S.ExecutionId,S.WorkItemTypeId,0,getdate(),@CreatedBy);

	END TRY
	BEGIN CATCH
	DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
	--INSERT Error    
	EXEC AVL_InsertError '[PP].[SaveGenericWorkItemConfig]', @ErrorMessage, '',''
	RETURN @ErrorMessage
    END CATCH
END
