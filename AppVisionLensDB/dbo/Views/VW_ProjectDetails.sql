
CREATE View [dbo].[VW_ProjectDetails]
AS
SELECT bu.BUID AS VerticalBUId
			,bu.BUName AS VerticalBUName
			,INPXL.PracticeOwner AS HorizontalBUName
			,cus.ESA_AccountID AS ESAAccountID
			,cus.CustomerID
			,cus.CustomerName AS AccountName
			,pm.EsaProjectID AS ESAProjectID
			,pm.ProjectID AS ProjectID
			,pm.ProjectName AS ProjectName
			,PRJCP.CreatedDate AS ApplensOnboardedDate
			,CASE 
				WHEN PRJCP.ProjectID IS NOT NULL
					THEN '1'
					ELSE '0'
				END AS ISApplensOnboarded
			,CASE 
				WHEN PROJDEBT.DebtEnablementDate IS NOT NULL
					THEN '1'
					ELSE '0'
				END AS ISDebtOnboarded
			,dbo.GetAllocationForProject(PM.EsaProjectID) AS TotalFTE			
		FROM [AVL].MAS_ProjectMaster pm(NOLOCK)
		INNER JOIN [AVL].[Customer] cus(NOLOCK) ON pm.CustomerID = cus.CustomerID
		INNER JOIN [AVL].[BusinessUnit] bu(NOLOCK) ON cus.BUID = bu.BUID
		INNER JOIN [$(AdoptionReportDB)].[ADPR].[Input_Excel_Associate] INPXL ON PM.EsaProjectID = INPXL.EsaProjectID
		LEFT JOIN AVL.PRJ_ConfigurationProgress PRJCP ON PRJCP.ProjectID = pm.ProjectID AND PRJCP.ScreenID = 2 AND PRJCP.ITSMScreenID = 11 AND PRJCP.CompletionPercentage = 100
		LEFT JOIN AVL.MAS_ProjectDebtDetails PROJDEBT ON PROJDEBT.ProjectID = PM.ProjectID
		WHERE bu.IsDeleted = 0
			AND pm.IsDeleted = 0
			AND cus.IsDeleted = 0
