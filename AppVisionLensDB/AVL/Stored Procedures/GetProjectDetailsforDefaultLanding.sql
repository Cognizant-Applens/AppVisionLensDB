-- Author      : Shobana
-- Create date : 12 Feb 2020
-- Description : Procedure to Get Project Details for Default Landing             
-- Test        : [AVL].[GetProjectDetailsforDefaultLanding] 7097,'471742'
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [AVL].[GetProjectDetailsforDefaultLanding]
(
@CustomerID BIGINT,
@EmployeeID NVARCHAR(50)
)
AS
BEGIN
SET NOCOUNT ON
  BEGIN TRY
SELECT DISTINCT PM.ProjectID,PM.ProjectName 
FROM AVL.MAS_ProjectMaster PM With (NOLOCK)
JOIN AVL.CUSTOMER AC (NOLOCK)
ON AC.CustomerID = PM.CustomerID AND AC.IsDeleted = 0
JOIN AVL.MAS_LoginMaster LM (NOLOCK)
ON LM.ProjectID = PM.ProjectID AND LM.CustomerID = AC.CustomerID
WHERE LM.CustomerID = @CustomerID 
AND (LM.EmployeeID = @EmployeeID OR LM.TSApproverID = @EmployeeID OR LM.HcmSupervisorID = @EmployeeID)
AND PM.IsDeleted = 0 AND AC.IsDeleted = 0 AND LM.IsDeleted = 0
ORDER BY PM.ProjectName 
SET NOCOUNT OFF
  END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
-- Log the error message
SELECT @ErrorMessage = ERROR_MESSAGE()
             
   END CATCH

END
