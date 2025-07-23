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
-- Author:		Sreeya
-- Create date: 11-6-2019
-- Description:	Checks if a project is debt enabled and if services OCM is mapped.
-- =============================================
CREATE PROCEDURE [AVL].[GetProjectDebtServiceMappingDetails] 
	-- Add the parameters for the stored procedure here
@ProjectID BIGINT ,
@UserID NVARCHAR(50)
AS
BEGIN
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
/*Check If project is already Debt Enabled.*/
IF EXISTS(SELECT 1 FROM AVL.MAS_ProjectDebtDetails WITH(NOLOCK) WHERE ISNULL(DebtControlFlag,'N')='Y' AND IsDeleted=0 AND ProjectID=@ProjectID)
BEGIN

SELECT 1 AS 'Result'
END
ELSE
BEGIN
/*IF Not Debt Enabled.Then Check services*/
IF EXISTS (SELECT DISTINCT S.ServiceID,S.ServiceName,ProjectID FROM AVL.TK_PRJ_ProjectServiceActivityMapping PSAM WITH(NOLOCK)
JOIN AVL.TK_MAS_ServiceActivityMapping SAM WITH(NOLOCK) ON PSAM.ServiceMapID =SAM.ServiceMappingID
JOIN AVL.TK_MAS_Service S WITH(NOLOCK) ON S.ServiceID=SAM.ServiceID AND S.ServiceID IN (3,11) WHERE ProjectID=@ProjectID
AND PSAM.IsDeleted=0 AND SAM.IsDeleted=0)
BEGIN
/*Services are enabled.*/
SELECT 1 AS 'Result';
END;
ELSE

BEGIN 
/*Services are not enabled.*/
SELECT 0 AS 'Result'
END
END

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage VARCHAR(MAX);

		SET @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetProjectDebtServiceMappingDetails]', @ErrorMessage, @UserID,@ProjectID

END CATCH

END
