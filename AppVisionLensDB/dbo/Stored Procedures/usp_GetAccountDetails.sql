/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC usp_GetAccountDetails '548977'
CREATE PROCEDURE [dbo].[usp_GetAccountDetails]
	@AssociateId VARCHAR(MAX) 
AS    
BEGIN    
      SET NOCOUNT ON;         

	  CREATE TABLE #tmpLoginMaster
        (
			 projectid			INT NULL,
			 --gradeid			INT NULL,
			 userid				INT NULL
        )
        
        --INSERT INTO #tmpLoginMaster                        
        --SELECT projectid, gradeid, userid 
        --       FROM   CTSC00832557901.AVMDART.PRJ.LoginMaster WITH(NOLOCK) 
        --       WHERE  cognizantid = @AssociateId AND isdeleted = 'N'
        
		IF EXISTS (SELECT TOP 1 1 
                 FROM   AVL.MAS_LoginMaster  WITH(nolock) 
                 WHERE  EmployeeID = @AssociateId AND isdeleted = 'N') 
        BEGIN 
			INSERT INTO #tmpLoginMaster                        
			SELECT DISTINCT projectid, 
							--gradeid,
							userid 
				   FROM   AVL.MAS_LoginMaster  WITH(NOLOCK) 
				   WHERE  EmployeeID = @AssociateId AND isdeleted = 'N'
        END
		   
		--SELECT DISTINCT B.DepartmentID as BUId, RTRIM(DM.DepartmentName) AS BUName, B.AccountID, B.AccountName, A.ProjectID, A.ProjectName, C.AccountProjectLobID, c.LobName 
		--FROM CTSC00832557901.AVMDART.MAS.ProjectMaster A 
		--INNER JOIN CTSC00832557901.AVMDART.MAP.DeptAcctMapping B ON A.DeptAccountID=B.DeptAccountID AND A.IsDeleted = B.IsDeleted
		--INNER JOIN CTSC00832557901.AVMDART.MAP.AcctProjectLobMapping C ON A.projectID = C.projectID  
		----INNER JOIN CTSC00832557901.[$(AVMCOEESADB)].dbo.GMSPMO_Project GP ON A.EsaProjectid= GP.Project_ID
		--INNER JOIN CTSC00832557901.AVMDART.MAS.departmentmaster DM ON DM.DepartmentID = RTRIM(B.DepartmentID) AND DM.IsDeleted = A.IsDeleted 
		--WHERE A.ProjectID in (SELECT projectid FROM #tmpLoginMaster) AND DM.IsDeleted = 'N' 
		
		DROP TABLE #tmpLoginMaster
      SET NOCOUNT OFF;    

END
