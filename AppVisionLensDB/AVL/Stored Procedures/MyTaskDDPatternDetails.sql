/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
  
-- =============================================  
-- Author:  PriyaDharshini.D  
-- Create date: 25-09-2019  
-- Description: Gets the tasks for DD Pattern Details  
-- =============================================  
  
CREATE PROCEDURE [AVL].[MyTaskDDPatternDetails]  
AS  
BEGIN  
BEGIN TRY  
  
	SELECT   
		UserId AS'UserId',  
		TaskId AS 'TaskId',  
		TaskName AS 'TaskName',   
		TaskUrl  AS 'TaskUrl',  
		TaskDetails  AS 'TaskDetails',  
		[Application] AS 'Application',  
		[Status] AS 'Status',  
		RefreshedTime AS 'RefreshedTime',  
		CreatedBy AS 'CreatedBy',  
		CreatedTime  AS 'CreatedTime',  
		ModifiedBy  AS 'ModifiedBy',  
		ModifiedTime AS 'ModifiedTime',   
		TaskType  AS 'TaskType',  
		ExpiryDate  AS 'ExpiryDate',  
		DueDate  AS 'DueDate',  
		[Read] AS 'Read',   
		ExpiryAfterRead  AS 'ExpiryAfterRead',  
		Accountid  AS 'Accountid'  
	FROM [AVL].[MyTasksCLInDD]   
  
  
END TRY  
  
  BEGIN CATCH  
    
   DECLARE @ErrorMessage VARCHAR(MAX);  
   SELECT @ErrorMessage = ERROR_MESSAGE()  
    
   --INSERT Error  
   EXEC AVL_InsertError '[AVL].[MyTaskDDPatternDetails]', @ErrorMessage, 0,  0  
       
  END CATCH  
END
