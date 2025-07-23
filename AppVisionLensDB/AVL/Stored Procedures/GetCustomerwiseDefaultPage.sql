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
-- Author      : Shobana  
-- Create date : 13 Feb 2020  
-- Description : Procedure to Get Customer Default Page                 
-- Test        : AVL.GetCustomerwiseDefaultPage '674078',7097  
-- Revision    :  
-- Revised By  :  
-- =========================================================================================  
CREATE PROCEDURE [AVL].[GetCustomerwiseDefaultPage]   
(  
@EmployeeID NVARCHAR(50),  
@CustomerID BIGINT  
)  
AS  
BEGIN
SET NOCOUNT ON;
  BEGIN TRY  
  DECLARE @DefaultPrivilegeID BIGINT;  
  SET @DefaultPrivilegeID =  (SELECT PrivilegeID FROM  AVL.MAS_PrivilegeMaster (NOLOCK) WHERE DisplayName = 'Timesheet Entry')  
    IF EXISTS(SELECT TOP 1 HcmSupervisorID from AVL.MAS_LoginMaster (NOLOCK) WHERE ( TSApproverID=@EmployeeID or HcmSupervisorID=@EmployeeID )   
  AND CustomerID=@CustomerId and ISDELETED=0 )   
  BEGIN  
        IF EXISTS (SELECT TOP 1 PrivilegeID FROM AVL.TRN_TicketingModuleDefaultPage (NOLOCK)   
  WHERE AccountID = @CustomerID AND EmployeeID = @EmployeeID AND IsDeleted = 0)  
  BEGIN   
  SELECT PrivilegeID FROM AVL.TRN_TicketingModuleDefaultPage (NOLOCK)   
  WHERE AccountID = @CustomerID AND EmployeeID = @EmployeeID AND IsDeleted = 0  
  END  
  ELSE
		BEGIN
			SELECT @DefaultPrivilegeID  AS PrivilegeID
		END
  END  
  ELSE  
  BEGIN  
  SELECT @DefaultPrivilegeID  AS PrivilegeID  
  END  
  
  END TRY  
 BEGIN CATCH  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  -- Log the error message  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
                  
   END CATCH  
 SET NOCOUNT OFF; 
END
