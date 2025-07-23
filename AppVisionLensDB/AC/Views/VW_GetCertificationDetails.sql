
CREATE VIEW [AC].[VW_GetCertificationDetails]
AS
		 select distinct 
		 ALC.CertificationId,
		 PPAC.AttributeValueName AS CategoryName,
		 CategoryId,
		 PPA.AttributeValueName AS AwardName,
		 AwardId,
		 ALC.EmployeeId,
		 LM.EmployeeName,
		 LM.EmployeeEmail,
		 ALC.AccountId,
		 CM.CustomerName,
		 ALC.ProjectID, 
		 PM.ProjectName   ,
        DATENAME(mm,CONCAT('1900',FORMAT(CAST(ALC.CertificationMonth AS INT),'00'),'01')) AS [Month],
		CertificationMonth = ALC.CertificationMonth,
		ALC.CertificationYear AS [Year],
		PM.EsaProjectID,NoOfATicketsClosed,
		NoOfHTicketsClosed
		,IncReductionMonth,
		EffortReductionMonth,
		SolutionIdentified,
		NoOfKEDBCreatedApproved,
		NoOfCodeAssetContributed,
		ALC.Isdeleted,
		IsRated,
        BuId = CM.BusinessUnitId
        from [AC].[TRN_Associate_Lens_Certification] (NOLOCK) AS ALC  
        JOIN avl.customer (NOLOCK) CM ON cm.CustomerID = ALC.AccountId    
        left JOIN [AVL].[MAS_LoginMaster] LM on LM.UserId = 
		(SELECT TOP 1 UserId from [AVL].[MAS_LoginMaster] LM WHERE LM.EmployeeID = ALC.EmployeeId)  
        JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) PM ON PM.ProjectID = ALC.ProjectID    
        JOIN [MAS].[PPAttributeValues] (NOLOCK) PPAC ON PPAC.AttributeValueID = ALC.CategoryId and PPAC.ParentID = ALC.AwardId     
        JOIN [MAS].[PPAttributeValues] (NOLOCK) PPA ON PPA.AttributeValueID = ALC.AwardId  
		WHERE ALC.isdeleted =0 			
			AND CM.isdeleted=0
			AND PM.isdeleted = 0 
			AND PPAC.isdeleted = 0 
			AND PPA.isdeleted = 0
