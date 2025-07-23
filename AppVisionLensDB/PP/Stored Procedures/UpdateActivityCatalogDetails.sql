/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Dhivya Bharathi M
-- Create date : Mar 30, 2020
-- Description : Get Activity Catalog Details]
-- Revision    :
-- Revised By  :
-- [PP].[UpdateActivityCatalogDetails] 4705,266,'471742'
-- ===========================================================================================

CREATE PROCEDURE [PP].[UpdateActivityCatalogDetails]
@ProjectID BIGINT,
@ServiceMapID BIGINT,
@EmployeeID NVARCHAR(50)
AS 
  BEGIN 
	BEGIN TRY 
		BEGIN TRAN

		SET NOCOUNT ON;
		UPDATE AVL.TK_PRJ_ProjectServiceActivityMapping
		SET IsDeleted=1,ModifiedBY=@EmployeeID,ModifiedDateTime=GETDATE()
		WHERE ProjectID=@ProjectID AND ServiceMapID=@ServiceMapID
		COMMIT TRAN

		END TRY
    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
		ROLLBACK TRAN
        --INSERT Error     
        EXEC AVL_INSERTERROR  '[PP].[GetActivityCatalogDetails]', @ErrorMessage,  0, 0 
    END CATCH 
  END
