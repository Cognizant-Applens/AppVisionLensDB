/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- Author      : Shobana
-- Create date : 12 Feb 2020
-- Description : Procedure to Save Default Landing Page Details             
-- Test        : [AVL].[SaveDefaultLandingPageDetails] '471742',7097,10
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [AVL].[SaveDefaultLandingPageDetails] 
(
@EmployeeID NVARCHAR(50),
@AccountID BIGINT,
@PrivilegeID BIGINT
)
AS
BEGIN
  BEGIN TRY
      BEGIN TRAN
      SET NOCOUNT ON;
DECLARE @Result BIT;
MERGE AVL.TRN_TicketingModuleDefaultPage  as ILC
USING (VALUES (@EmployeeID,@AccountID,@PrivilegeID))
AS ILCC(EmployeeID,AccountID,PrivilegeID)
ON ILCC.AccountID = ILC.AccountID AND ILCC.EmployeeID = ILC.EmployeeID AND ILC.ISDeleted=0

WHEN MATCHED THEN 
   UPDATE
SET 
ILC.PrivilegeID = ILCC.PrivilegeID,
ILC.ModifiedBy = @EmployeeID,
ILC.ModifiedDate = GetDate()

WHEN NOT MATCHED BY TARGET THEN
 
INSERT 
(    
EmployeeID
,AccountID
,PrivilegeID
,IsDeleted
,CreatedBy
,CreatedDate
,ModifiedBy
,ModifiedDate)
VALUES(
@EmployeeID,
@AccountID,
@PrivilegeID,
0,
@EmployeeID,
GetDate(),
NULL,
NULL
);
  
        SET @Result = 1
SELECT @Result AS Result

   COMMIT TRAN
  END TRY
BEGIN CATCH

   SET @Result =0
SELECT @Result AS Result
DECLARE @ErrorMessage VARCHAR(MAX);
ROLLBACK TRAN
-- Log the error message
SELECT @ErrorMessage = ERROR_MESSAGE()
             
   END CATCH

END
