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
-- Author      : 
-- Create date : 04/08/2020
-- Description : Procedure to Get Ticket/Effort Upload config Details
-- Revision    :
-- Revised By  :
-- ========================================================================================= 
CREATE PROCEDURE [AVL].[GetUploadConfigDetails] 
(
@ProjectId BIGINT,
@EmployeeId NVARCHAR(50)
)
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
								 
	SELECT SharePath,TicketSharePathUsers
	FROM [dbo].[TicketUploadProjectConfiguration]
	WHERE ProjectID=@ProjectId AND IsDeleted=0

	SELECT SharePathName 
	FROM AVL.EffortUploadConfiguration
	WHERE ProjectID=@ProjectId AND IsActive=1
	
END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[GetUploadConfigDetails]', @ErrorMessage,@EmployeeId,@ProjectId
  END CATCH
END
