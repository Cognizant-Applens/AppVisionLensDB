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
--	Author: Hemanth Varma CH          
--  Create date:    April 17 2019   
--  EXEC  [AVL].[Infra_InsertOrUpdateHhierarchy]
-- ============================================================================
CREATE Procedure [AVL].[Infra_InsertOrUpdateHhierarchy]

@HierarchyOneDefinition nvarchar(50),
@HierarchyTwoDefinition nvarchar(50),
@HierarchyThreeDefinition nvarchar(50),
@HierarchyFourDefinition nvarchar(50),
@HierarchyFiveDefinition nvarchar(50),
@HierarchySixDefinition nvarchar(50),
@CustomerID bigint,
@EmployeeID nvarchar(50),
@Choice int
AS
BEGIN  
BEGIN TRY 
BEGIN TRAN

IF(@Choice=1)
BEGIN

INSERT INTO AVL.InfraClusterDefinition VALUES(@CustomerID,@HierarchyOneDefinition,@HierarchyTwoDefinition,@HierarchyThreeDefinition,@HierarchyFourDefinition,
@HierarchyFiveDefinition,@HierarchySixDefinition,0,@EmployeeID,GETDATE(),NULL,NULL);

IF NOT EXISTS (select 1 from AVL.PRJ_ConfigurationProgress where CustomerID = @CustomerID and ScreenID = 17)
BEGIN
	EXEC [AVL].[SetInfraprogress] @CustomerID,@EmployeeID,17,25
END 

END

ELSE
BEGIN

  IF(@Choice=2)
  BEGIN
    UPDATE AVL.InfraClusterDefinition
	SET HierarchyFourDefinition=@HierarchyFourDefinition,
	HierarchyFiveDefinition=@HierarchyFiveDefinition,
	HierarchySixDefinition=@HierarchySixDefinition,
	ModifiedBy=@EmployeeID,
	ModifiedDate=GETDATE()
	WHERE CustomerID=@CustomerID AND IsDeleted=0;
  END
END
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Infra_InsertOrUpdateHhierarchy]', @ErrorMessage, 0,@CustomerID
		
	END CATCH  
END
