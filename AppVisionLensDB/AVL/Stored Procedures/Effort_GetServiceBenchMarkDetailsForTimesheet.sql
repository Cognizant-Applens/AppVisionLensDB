/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


-- ============================================================================------  
-- Author    :    Dhivya Bharathi M    
-- Create date:    Jan 21 2020     
-- ============================================================================  

--[AVL].[Effort_GetServiceBenchMarkDetailsForTimesheet] 7097,'471742'
CREATE PROCEDURE [AVL].[Effort_GetServiceBenchMarkDetailsForTimesheet]
@CustomerID BIGINT,
@EmployeeID NVARCHAR(50)=null
AS 
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	DECLARE @BUId INT;
	SET @BUId=(SELECT BusinessUnitID FROM AVL.Customer(NOLOCK) WHERE CustomerID=@CustomerID AND ISNULL(IsDeleted,0)=0)
	SELECT ServiceID FROM AVL.TK_MAS_Service WHERE IsBenchMarkApplicable=1
	--Org Levels
	SELECT ServiceID,BenchMarkLevel,BenchMarkValue FROM  AVL.BenchMarkValuesByService(NOLOCK) 
	WHERE BenchMarkParameterID=1 AND ISNULL(IsDeleted,0)=0
	--BU Levels
	SELECT ServiceID,BenchMarkLevel,BenchMarkValue FROM  AVL.BenchMarkValuesByService(NOLOCK) 
	WHERE BenchMarkParameterID=2
	AND ParameterValue=@BUId AND ISNULL(IsDeleted,0)=0
END TRY 
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Effort_GetServiceBenchMarkDetailsForTimesheet]', @ErrorMessage, @EmployeeID,0
	END CATCH  
END
