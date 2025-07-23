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
-- Modified by : 835658                    
-- Modified For: RHMS CR                    
-- description: getting User details using customerID and userID                    
-- =============================================                    
-- EXEC [dbo].[Sp_GetUserDetails_new] 823169,7097                    
CREATE PROC [dbo].[Sp_GetUserDetails] (
	@employeeid VARCHAR(50)
	,@customerid INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @roleslevel INT
			,@ESA_AccountID VARCHAR(max)
			,@RoleCustomerID INT;

		SELECT @RoleCustomerID = nc.CustomerID
		FROM AVL.Customer(NOLOCK) oc
		JOIN [RLE].[VW_Customers](NOLOCK) nc ON nc.ESACustomerID = oc.ESA_AccountID
		WHERE oc.customerid = @customerid
			AND oc.IsDeleted = 0

		SELECT AssociateId
			,ecpm.AssociateName
			,ecpm.Email
			,ApplensRoleID
			,ecpm.RoleName
			,ecpm.priority
		INTO #tempRoleData
		FROM RLE.VW_RoleDataAccessOnCustomerLevel(NOLOCK) ecpm
		WHERE ecpm.CustomerID = @RoleCustomerID

		SELECT @roleslevel = min(ecpm.priority)
		FROM #tempRoleData(NOLOCK) ecpm
		WHERE ecpm.Associateid = @employeeid

		SELECT DISTINCT ecpm.Associateid AS employeeid
		INTO #temppriorityroles
		FROM #tempRoleData(NOLOCK) ecpm
		WHERE ecpm.priority < @roleslevel
			AND ecpm.priority IS NOT NULL

		SELECT DISTINCT ecpm.Associateid AS employeeid
			,ecpm.AssociateName AS employeename
			,ecpm.Email AS employeeemail
			,ecpm.Applensroleid AS roleid
			,ecpm.rolename
		INTO #temp1
		FROM #tempRoleData(NOLOCK) ecpm
		--inner join RLE.VW_GetRoleMaster(nolock) rm on rm.ApplensRoleID=ecpm.Applensroleid                             
		LEFT JOIN #temppriorityroles(NOLOCK) tpr ON tpr.employeeid <> ecpm.Associateid

		SELECT DISTINCT employeeid
			,employeename
			,employeeemail
			,0 roleid
			,rolename = stuff((
					SELECT ', ' + rolename
					FROM #temp1(NOLOCK) b
					WHERE b.employeeid = a.employeeid
						AND b.employeename = a.employeename
						AND b.employeeemail = a.employeeemail
					FOR XML path('')
					), 1, 2, '')
		INTO #temp2
		FROM #temp1(NOLOCK) a
		GROUP BY employeeid
			,employeename
			,employeeemail

		SELECT DISTINCT t.employeeid
			,employeename
			,employeeemail
			,roleid
			,STUFF((
					SELECT DISTINCT ', ' + t1.rolename
					FROM #temp2 t1
					WHERE t.employeeid = t1.employeeid
					FOR XML PATH('')
						,TYPE
					).value('.', 'NVARCHAR(MAX)'), 1, 2, '') rolename
		FROM #temp2 t;

		DROP TABLE #temp1

		DROP TABLE #tempRoleData
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error                        
		EXEC AVL_InsertError 'dbo.Sp_GetUserDetails'
			,@ErrorMessage
			,0
			,@customerid
	END CATCH

	SET NOCOUNT OFF;
END
