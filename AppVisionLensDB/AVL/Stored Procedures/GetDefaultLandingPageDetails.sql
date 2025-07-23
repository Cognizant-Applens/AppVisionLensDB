-- Author      : Shobana
-- Create date : 11 Feb 2020
-- Description : Procedure to Get Default Landing Page Details              
-- Test        : AVL.GetDefaultLandingPageDetails
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [AVL].[GetDefaultLandingPageDetails]
(
@EmployeeID NVARCHAR(50),
@CustomerID BIGINT
)
AS
BEGIN
  BEGIN TRY
  SET NOCOUNT ON
         IF EXISTS(SELECT TOP 1 HcmSupervisorID from AVL.MAS_LoginMaster With (NOLOCK) WHERE ( TSApproverID=@EmployeeID or HcmSupervisorID=@EmployeeID ) 
AND CustomerID=@CustomerId and ISDELETED=0 ) 
BEGIN
SELECT PrivilegeID,DisplayName FROM avl.MAS_PrivilegeMaster  With (NOLOCK) WHERE IsDefault = 1 AND IsDeleted =0
END
ELSE
BEGIN
SELECT PrivilegeID,DisplayName FROM avl.MAS_PrivilegeMaster  With (NOLOCK) WHERE IsDefault = 1 AND IsDeleted =0 AND PrivilegeID IN(2,10)
END
  SET NOCOUNT OFF
  END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
-- Log the error message
SELECT @ErrorMessage = ERROR_MESSAGE()
             
   END CATCH

END
