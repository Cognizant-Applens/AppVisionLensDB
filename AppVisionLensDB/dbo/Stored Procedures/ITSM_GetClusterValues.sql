/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[ITSM_GetClusterValues]
(
@IsCCCluster BIT
)
AS
BEGIN
BEGIN TRY
IF(@IsCCCluster = 1)
BEGIN
SELECT ClusterID,ClusterName from MAS.Cluster (NOLOCK) where IsDeleted = 0 AND CategoryID = 1
END
ELSE
BEGIN
SET NOCOUNT ON;
SELECT ClusterID,ClusterName from MAS.Cluster  (NOLOCK) where IsDeleted = 0 AND CategoryID = 2
END

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[ITSM_GetClusterValues] ', @ErrorMessage, 0,0
		
	END CATCH  
	SET NOCOUNT OFF;
END
