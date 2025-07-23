/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [BCS].[GetVersionDetails]

@UtilityName nvarchar(50)

AS
BEGIN

SET NOCOUNT ON;
BEGIN TRY

SELECT B.SolutionName as UtilityName ,VersionNumber,LastUpdatedDate=convert(varchar,LastUpdatedDate,107) FROM BCS.BCS_Version A join [BCS].[SolutionMaster] B on A.UtilityId = B.Id  WHERE B.SolutionName=@UtilityName
 and A.IsDeleted=0 
--declare @LastUpdatedDate date
--Set @LastUpdatedDate=GETDATE()
--Select CONVERT(varchar,@LastUpdatedDate,107) as [LastUpdatedDate]
END TRY
BEGIN CATCH
DECLARE @errorMessage VARCHAR(MAX);

		SELECT @errorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[BCS].[BCS_Version]',@errorMessage,'',0
END CATCH
END
