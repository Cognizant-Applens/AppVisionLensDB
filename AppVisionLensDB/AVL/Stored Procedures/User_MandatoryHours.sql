/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [AVL].[User_MandatoryHours] 
(
@CustomerID Bigint,
@EmployeeID varchar(100)
)
AS
BEGIN
select TOP 1 MandatoryHours from AVL.MAS_LoginMaster(NOLOCK) where EmployeeID=@EmployeeID and CustomerID=@CustomerID and IsDeleted=0
END
