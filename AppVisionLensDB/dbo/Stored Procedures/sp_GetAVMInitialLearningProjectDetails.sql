/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[dbo].[sp_GetAVMInitialLearningProjectDetails] 215573,7432

CREATE PROCEDURE [dbo].[sp_GetAVMInitialLearningProjectDetails]
	@EmployeeID varchar(50),

	@CustomerID int

AS

BEGIN

BEGIN TRY
SELECT
			DISTINCT PM.ProjectID,PM.ProjectName,PDD.IsAutoClassified
	FROM 
			AVL.MAS_ProjectMaster PM
	JOIN 
			AVL.MAS_LoginMaster LM
	ON 
			LM.ProjectID=PM.ProjectID

    JOIN AVL.MAS_ProjectDebtDetails PDD

	ON

	       PDD.ProjectID=LM.ProjectID
	WHERE 
			LM.CustomerID=@CustomerID
			
	AND		
			EmployeeID=@EmployeeID
	AND 
			LM.IsDeleted=0 
	AND 
			PM.IsDeleted=0
	AND
			LM.ProjectID IN 
							(
								SELECT
										ProjectID 
								FROM
										AVL.MAS_ProjectDebtDetails PDD
								WHERE
										--PDD.IsDDAutoClassified='Y'
								--AND
								--		PDD.IsMLSignOff=1
								--AND 
										(PDD.IsDeleted=0 or PDD.IsDeleted is NULL)
								)

	--SET NOCOUNT ON;

	--		DECLARE @UserIDs as Table

	--		(UserID INT,

	--		CustomerID INT)



	--		INSERT INTO @UserIDs

	--		Select EmployeeID,CustomerID from [AVL].[MAS_LoginMaster] 

	--		where 
	--		EmployeeID=@EmployeeID and
	--		 isdeleted = 0 and CustomerID = @CustomerID



	--		SELECT DISTINCT A.ProjectID,A.ProjectName,A.UserID,A.EmployeeID FROM 

	--		(

	--		SELECT PM.ProjectID,PM.ProjectName,L.UserID,L.EmployeeID FROM avl.MAS_LoginMaster L 

	--		INNER JOIN @UserIDs U 
	--		ON (U.UserID=L.TSApproverID or U.UserID=L.HcmSupervisorID )  and 
			
	--		 U.CustomerID = L.CustomerID 

	--		INNER JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID=L.ProjectID and PM.CustomerID = U.CustomerID

	--		WHERE l.IsDeleted = 0 
			

	--		) A  WHERE A.EmployeeID = @EmployeeID

		

		

END TRY



BEGIN Catch


			DECLARE @ErrorMessage VARCHAR(MAX);

			SELECT @ErrorMessage = ERROR_MESSAGE()

			--INSERT Error    

			EXEC AVL_InsertError '[dbo].[MAS_LoginMaster] ', @ErrorMessage,@EmployeeID,@CustomerID



End Catch





END
