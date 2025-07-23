CREATE PROCEDURE [AVL].[KEDB_GetRoles]--'400437'
@EmployeeID NVARCHAR(50)    
AS    
BEGIN   
SET NOCOUNT ON;  
	BEGIN TRY
		IF EXISTS(select TOP 1 HcmSupervisorID from AVL.MAS_LoginMaster (NOLOCK) 
		WHERE ( TSApproverID=@EmployeeID or HcmSupervisorID=@EmployeeID) AND isdeleted=0 )  
			BEGIN  		
				SELECT DISTINCT C.BusinessUnitID as BuID, C.BusinessUnitName as BuName,
				A.CustomerID, B.CustomerName,A.ProjectID, P.Projectname,
				'Operational' As Role
				FROM AVL.MAS_LoginMaster A
				JOIN AVL.Customer B ON A.CustomerID = B.CustomerId AND B.Isdeleted = 0
				JOIN MAS.BusinessUnits C ON C.BusinessUnitID = B.BusinessUnitID AND C.Isdeleted = 0
				JOIN AVL.MAS_ProjectMaster P ON P.ProjectID=A.ProjectID
				WHERE (A.TSApproverID = @EmployeeID OR A.HcmSupervisorID = @EmployeeID) AND A.isdeleted=0
			END
	END TRY      
	BEGIN CATCH      
    
		DECLARE @ErrorMessage VARCHAR(MAX);    
    
		SELECT @ErrorMessage = ERROR_MESSAGE()    
    
		--INSERT Error        
		EXEC AVL_InsertError '[AVL].[KEDB_GetRoles]', @ErrorMessage, @EmployeeID,0    
      
	END CATCH    
SET NOCOUNT OFF;  
END
