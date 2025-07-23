/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =================================================================================  
-- Author: Devika 
-- Create date: 2 July 2018
-- Description: Migration of Login and Project Masters Module
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- Test: [dbo].[SP_DataMigration_Masters] 1201185 ,'1000195935'
-- ================================================================================= 

--- exec SP_DataMigration_Masters '1201125', '1000192711'
CREATE PROCEDURE [dbo].[SP_DataMigration_Masters]
(
	@AccountID BIGINT, -- AVM DART ESA ACCOUNT ID
	@ESAProjectIDs NVARCHAR(MAX) -- ESA Project IDs
)
AS
BEGIN

	BEGIN TRY

		---------- Get all projects or specific project(s) for the Accounts ----------	  
		SELECT Item AS ESAProjectID INTO #ESAProjectIds FROM dbo.Split(@ESAProjectIDs, ',')

        DECLARE @ProjectDetails TABLE 
        ( 
                AccountID INT,
                AccountName NVARCHAR(MAX),
                ProjectID INT,
                EsaProjectID NVARCHAR(MAX),
                ProjectName VARCHAR(MAX)
        )

		INSERT INTO @ProjectDetails
			SELECT	DA.AccountID AS AccountID,
					AccountName,
					PM.ProjectID,
					PM.EsaProjectID,
					PM.ProjectName
			FROM AVMDART.MAS.ProjectMaster (NOLOCK) PM
			JOIN AVMDART.[MAP].[DeptAcctMapping] (NOLOCK) DA
				ON DA.AccountID = @AccountId AND DA.DeptAccountID = PM.DeptAccountID AND DA.IsDeleted = 'N'
			JOIN AVL.Customer (NOLOCK) CUST
				ON CUST.ESA_AccountID = DA.AccountID AND CUST.IsDeleted = 0
			JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APLPM
				ON APLPM.EsaProjectID = PM.EsaProjectID AND APLPM.IsDeleted = 0
			WHERE (@ESAProjectIDs IS NULL OR PM.EsaProjectID IN (SELECT ESAProjectID FROM #ESAProjectIds))
				AND PM.IsDeleted = 'N'

		DROP TABLE #ESAProjectIds 


		-------- Insert User in Login Master those who are present in DART and not in App Lens  -----------------------------

		INSERT INTO AVL.MAS_LoginMaster 
		(
		   EmployeeID,
		   ClientUserID,
		   EmployeeName,
		   EmployeeEmail,
		   ProjectID,
		   CustomerID,
		   HcmSupervisorID,
		   TSApproverID,
		   ManagerID,
		   Remarks,
		   EffectiveDate,
		   TimeZoneId,
		   MandatoryHours,
		   EffectiveEndDate,
		   Billability_type,
		   LocationID,
		   IsDeleted,
		   RoleID,
		   IsAutoassignedTicket,
		   ServiceLevelID,
		   CreatedDate,
		   CreatedBy,
		   ModifiedDate,
		   ModifiedBy,
		   TicketingModuleEnabled,
		   IsDefaultProject,
		   IsEffortTrackingEnabled,
		   Offshore_Onsite,
		   IsNonESAAuthorized
		)
		SELECT	LM.cognizantID,
				LM.cognizantID,
				LM.CognizantName,
				LM.CognizantEmail,
				PM.ProjectID,
				CUST.CustomerID,
				LM.HcmSupervisorID,
				LM.TsSupervisorID,
				LM.ManagerID,
				LM.Remarks,
				LM.EffectiveDate,
				APPTM.TimeZoneID,
				LM.MandatoryHours,
				LM.EffectiveEndDate,
				LM.associate_Billability_type,
				APPLOM.LocationID,
				1,
				NULL,
				LM.IsAutoassignedTicket,
				NULL,
				GETDATE(),
				'Migrated',
				NULL,
				NULL,
				NULL,
				case WHEN lm.IsDefaultProject='Y' then 1 else 0 end,
				NULL,
		        NULL,
				NULL
		 FROM AVMDART.prj.LoginMaster (NOLOCK) LM
		 JOIN AVMDART.MAS.ProjectMaster (NOLOCK) AVMPM 
			ON AVMPM.ProjectID = lm.ProjectID
		 JOIN @ProjectDetails PD ON PD.ProjectID = AVMPM.ProjectID 
		 LEFT JOIN AVMDART.MAS.TimeZoneMaster (NOLOCK) TM
			ON TM.TimeZoneID = LM.TimeZoneId
		 LEFT JOIN AVMDART.MAS.LocationMaster (NOLOCK) LOM
			ON LOM.LocationID = LM.LocationID
		 JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
			ON PM.EsaProjectID = PD.EsaProjectID
		 JOIN AVL.Customer (NOLOCK) CUST 
			ON CUST.ESA_AccountID = PD.AccountID AND PM.CustomerID = CUST.CustomerID
		 LEFT JOIN AVL.MAS_TimeZoneMaster (NOLOCK) APPTM 
			ON APPTM.TimeZoneName = TM.TimeZoneName
		 LEFT JOIN MAS.LocationMaster (NOLOCK) APPLOM 
			ON APPLOM.LocationName = LOM.LocationName
		 LEFT JOIN AVL.MAS_LoginMaster (NOLOCK) APPLM 
			ON APPLM.EmployeeID = LM.cognizantID AND APPLM.ProjectID = PM.ProjectID 
				AND APPLM.CustomerID = CUST.CustomerID
		 WHERE APPLM.UserID IS NULL

		--------------------------------------------------------------------------------

		-- Migrate few fields in Login Master
		UPDATE LL SET	LL.ClientUserID = DARTLM.CLIENTUSERID,
						LL.Billability_type = DARTLM.associate_Billability_type,
						LL.Remarks = DARTLM.Remarks,
						LL.TimeZoneId = TM.TimeZoneId,
						LL.TSApproverID = LL.HcmSupervisorID,
						--LL.TSApproverID = LL1.EmployeeID,
						LL.TicketingModuleEnabled = 1 -- By default, 'Yes'
		FROM AVL.MAS_LoginMaster (NOLOCK) LL
		INNER JOIN AVMDART.PRJ.LoginMaster (NOLOCK) DARTLM
			ON DARTLM.cognizantID = LL.EmployeeID
		INNER JOIN AVL.MAS_ProjectMaster (NOLOCK) LPM 
			ON LPM.ProjectID = LL.ProjectID AND LPM.IsDeleted = 0
		JOIN @ProjectDetails PD
			ON LPM.EsaProjectID = PD.EsaProjectID AND PD.ProjectID = DARTLM.ProjectID
		JOIN AVL.Customer (NOLOCK) Cust 
			ON CUST.ESA_AccountID = PD.AccountID AND Cust.IsDeleted = 0
		LEFT JOIN AVMDART.MAS.TimeZoneMaster (NOLOCK) DARTTZ
				ON DARTTZ.TimeZoneID = DARTLM.TimeZoneId
		LEFT JOIN AVL.MAS_TimeZoneMaster (NOLOCK) TM
				ON TM.TimeZoneName = DARTTZ.TimeZoneName
		LEFT JOIN AVMDART.PRJ.LoginMaster (NOLOCK) DARTLMTS
			ON DARTLMTS.UserID = DARTLM.TsSupervisorID
		LEFT JOIN AVL.MAS_LoginMaster (NOLOCK) LL1 
			ON LL1.EmployeeID = DARTLMTS.CognizantID AND LL1.CustomerID = Cust.CustomerID AND LL1.IsDeleted = 0
			
		-- Migrate few fields in Project Master
		UPDATE APPPrj
		SET IsMainSpringConfigured = DARTPM.IsMainSpringConfigured,
			TicketAttributeIntegartion = 
				CASE WHEN ISNULL(DARTPM.IsMainSpringConfigured, 'N') = 'Y' THEN 2 ELSE 1 END,
			IsDebtEnabled = DARTPM.IsDebtEnabled,
			IsODCRestricted = DARTPM.IsODCRestricted,
			IsCoginzant = 1,
			IsMigratedFromDART = 1
		FROM AVL.MAS_ProjectMaster (NOLOCK) APPPrj 	
		JOIN @ProjectDetails PD
			ON PD.EsaProjectID = APPPrj.EsaProjectID
		JOIN AVMDART.MAS.ProjectMaster (NOLOCK) DARTPM
			ON DARTPM.ProjectID = PD.ProjectID

		--  Migration of Roles for User Management
		EXEC dbo.Sp_DataMigration_UserManagement_ProxyAdmin @ESAProjectIDs = @ESAProjectIDs
				
		-- Log the Login and Project Master migration is successful for the respective account.
		UPDATE DataMigrationLog SET MasterStatus = 'S' WHERE AccountID = @AccountID


	END TRY  
	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage AS ErrorMessage

		-- Log the Error in Data Migration Log Table.   
		UPDATE DataMigrationLog SET MasterStatus = 'F', MasterErrorMessage = @ErrorMessage
		WHERE AccountID = @AccountID
              
    END CATCH  

END
