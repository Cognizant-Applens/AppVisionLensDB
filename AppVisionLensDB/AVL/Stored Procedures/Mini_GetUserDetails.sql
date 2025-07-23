/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:      Prakash     
-- Create date:      23 Nov 2018
-- Description:   get user details
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
--  [AVL].[Mini_GetUserDetails] '471742'

-- ============================================================================ 
CREATE PROCEDURE [AVL].[Mini_GetUserDetails] --'686186'
(
@CognizantID varchar(15)
)
AS
BEGIN
BEGIN TRY
	SELECT UserID,EmployeeID,EmployeeName,EmployeeEmail,MandatoryHours INTO #Temp
	FROM AVL.MAS_LoginMaster WHERE EmployeeID=@CognizantID AND ISNULL(IsDeleted,0)=0
	AND ISNULL(IsMiniConfigured,1)=1
	DECLARE @MandatoryHours DECIMAL(6,2);
	SET @MandatoryHours=(SELECT AVG(MandatoryHours) AS AveragePrice FROM #Temp);

	UPDATE #Temp  SET MandatoryHours=@MandatoryHours  

	SELECT UserID,EmployeeID,EmployeeName,EmployeeEmail,MandatoryHours FROM #Temp
END TRY
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Mini_GetUserDetails]', @ErrorMessage, @CognizantID,0
END CATCH 
END
