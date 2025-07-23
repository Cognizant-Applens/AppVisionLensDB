/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- author:		
-- create date: 
-- Modified by : 686186
-- Modified For: RHMS CR
-- description: getting customer details using  userID
-- =============================================
--EXEC [dbo].[GetCustomer] 'GetCustomerUser', '548977'

CREATE PROCEDURE [dbo].[GetCustomer]
(
@Mode VARCHAR(50)=NULL,
@UserId VARCHAR(50)=NULL
)
AS  
BEGIN
BEGIN TRY
SET NOCOUNT ON

Select DISTINCT EmployeeID,CustomerID,RoleID INTO #LoginTemp FROM AVL.MAS_LoginMaster(NOLOCK)
WHERE EmployeeID=@UserId AND IsDeleted <>1

IF(@Mode='GetCustomerUser')
BEGIN
select *  into #temp from(

Select DISTINCT CM.CustomerID,CM.CustomerName from 
AVL.Customer(NOLOCK) CM 
JOIN AVL.[VW_EmployeeCustomerProjectRoleBUMapping] VWECM (NOLOCK) ON CM.CustomerID=VWECM.CustomerID 
join AVL.MAS_ProjectMaster pm (NOLOCK) on VWECM.CustomerID=pm.CustomerID and VWECM.ProjectID=pm.ProjectID and pm.IsDeleted <>1
INNER JOIN #LoginTemp LM (NOLOCK) ON  VWECM.EmployeeID =LM.EmployeeID 
WHERE VWECM.EmployeeID=@UserId  AND CM.IsDeleted=0 and pm.IsDeleted <>1 AND VWECM.RoleID IN(6,7)) M

 
 select distinct * from  #temp ORDER BY CustomerName
-- and LM.IsDeleted=0
END

IF(@Mode='GetCustomer')
BEGIN
Select DISTINCT CustomerID,CustomerName from AVL.Customer(NOLOCK)  WHERE IsDeleted <>1 ORDER BY CustomerName
END
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[GetCustomer] ', @ErrorMessage, @UserId,0
		
	END CATCH  

	SET NOCOUNT OFF

END
