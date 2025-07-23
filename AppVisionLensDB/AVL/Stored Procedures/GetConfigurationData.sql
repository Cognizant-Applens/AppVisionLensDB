/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC AVL.GetConfigurationData 110
CREATE Procedure [AVL].[GetConfigurationData] @CustomerID INT
AS 
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
			SELECT 
			C.CustomerId						AS CustomerId,
			ISNULL(CASE WHEN  C.IsCognizant=0 THEN 0 ELSE 1 END,0)			AS IsCognizant,
			ISNULL(C.IsEffortConfigured,0)		AS IsEfforTracked,
			ISNULL(C.IsITSMEffortConfigured,0)	AS IsITSMLinked,
			ISNULL(CASE WHEN PM.IsDebtEnabled='Y' THEN 1 ELSE 0 END,0)			AS IsDebtEnabled,
			ISNULL(C.IsEffortTrackActivityWise,1)									AS IsAcitivityTracked,
			ISNULL(CASE WHEN PM.IsMainspringConfigured='Y' THEN 1 ELSE 0 END,0)	AS IsMainSpringConfigured,
			PM.ProjectID AS ProjectId 
			FROM AVL.Customer C ( NOLOCK ) 
			INNER JOIN AVL.MAS_ProjectMaster PM ( NOLOCK ) 
			ON C.CustomerID=PM.CustomerID
			WHERE C.CustomerID=@CustomerID
	END TRY
	BEGIN CATCH
		SELECT 
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS ErrorSeverity
			,ERROR_STATE() AS ErrorState
			,ERROR_PROCEDURE() AS ErrorProcedure
			,ERROR_LINE() AS ErrorLine
			,ERROR_MESSAGE() AS ErrorMessage;

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
	END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
