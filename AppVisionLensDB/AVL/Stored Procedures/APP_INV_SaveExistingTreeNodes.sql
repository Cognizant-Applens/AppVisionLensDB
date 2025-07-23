/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[APP_INV_SaveExistingTreeNodes]

@treeTable TreeNodes READONLY,
@customerID bigint
AS
BEGIN
BEGIN TRY

					UPDATE  
							BCM

					SET 
							BCM.BusinessClusterBaseName= TT.Title , 
							BCM.ModifiedBy=TT.UserName,
							BCM.ModifiedDate=GETDATE()
					FROM 
							AVL.BusinessClusterMappingTemp1 AS BCM

					JOIN

							@treeTable AS TT

					ON 
							BCM.BusinessClusterMapID=CONVERT(int,TT.ID)



					DELETE 
					FROM 
							AVL.BusinessClusterMappingTemp1
					WHERE 
							BusinessClusterMapID 
					NOT IN
							(SELECT 
									CONVERT(int,TT.ID) 
							FROM 
									@treeTable TT)
					AND
							CustomerID=@customerID

END TRY
BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
 
		EXEC AVL_InsertError '[AVL].[APP_INV_SaveExistingTreeNodes]', @ErrorMessage, NULL, @customerID 
END CATCH
END
