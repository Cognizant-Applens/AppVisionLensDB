/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE   PROCEDURE [RLE].[SyncRHMSRolesQualifiersDetails]
AS
BEGIN
	SET XACT_ABORT ON;  
	DECLARE @Date DateTime = GetDate()
	DECLARE @UserName nvarchar(50) = 'System'
	DECLARE @JobName VARCHAR(100)= 'RHMS Roles and qualifier details Sync';
	DECLARE @JobStatusSuccess VARCHAR(100)='Success';
	DECLARE @JobStatusFail VARCHAR(100)='Failed';
	DECLARE @JobStatusInProgress VARCHAR(100)='InProgress';
	DECLARE @JobId int;
	DECLARE @JobStatusId int;
	SELECT @JobId = JobID FROM MAS.JobMaster WHERE JobName = @JobName;
	DECLARE @DataSource nvarchar(50) = 'RHMS'
	DECLARE @UserRoleMapping Table (RoleMappingID int, EmployeeID nvarchar(50), ApplensRoleID int, GroupID int, QualifierComboID int)
	DECLARE @DescMarket nvarchar(50)
		,@DescMarketUnit nvarchar(50)
		,@DescBusinessUnit nvarchar(50)
		,@DescSubBusinessUnit1 nvarchar(50)
		,@DescSubBusinessUnit2 nvarchar(50)
		,@DescIndustrySegment nvarchar(50)
		,@DescVertical nvarchar(50)
		,@DescSubVertical nvarchar(50)
		,@DescParentCustomer nvarchar(50)
		,@DescCustomer nvarchar(50)
		,@DescPractice nvarchar(50)
		,@DescSubHorizontal nvarchar(50)
		,@DescProject nvarchar(50)
		,@DescAllBusinessUnit nvarchar(50)

	SELECT @DescMarket = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 1
	SELECT @DescMarketUnit = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 2
	SELECT @DescBusinessUnit = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 3
	SELECT @DescSubBusinessUnit1 = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 4
	SELECT @DescSubBusinessUnit2 = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 5
	SELECT @DescVertical = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 6
	SELECT @DescSubVertical = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 7
	SELECT @DescParentCustomer = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 8
	SELECT @DescCustomer = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 9
	SELECT @DescPractice = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 10
	SELECT @DescSubHorizontal = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 11
	SELECT @DescProject = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 12
	SELECT @DescAllBusinessUnit = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 13
	SELECT @DescIndustrySegment = AccessLevelTypeName FROM MAS.RLE_AccessLevelTypes WHERE AccessLevelTypeID = 14

	INSERT INTO MAS.JobStatus (JobId, StartDateTime, EndDateTime, JobStatus, JobRunDate, IsDeleted, CreatedBy, CreatedDate) 
			   VALUES(@JobId, @Date, @Date, @JobStatusInProgress, @Date, 0, @UserName, @Date);
	SET @JobStatusId= SCOPE_IDENTITY();

	BEGIN TRY
		BEGIN TRANSACTION
			/* RHMS Role Name and active records sync*/
			MERGE RLE.RHMSRoles AS T
			USING (SELECT rm.RoleId, rm.RoleName, rm.ActiveFlag
					FROM [$(AVMCOEESADB)].[dbo].[RHMSRoleMaster] rm
				) AS S 
			ON T.RHMSRoleID = S.RoleId
			WHEN MATCHED 
				 AND T.RHMSRoleName <> S.RoleName
				 OR T.IsDeleted <> (CASE WHEN S.ActiveFlag = 0 THEN 1 ELSE 0 END)
			THEN UPDATE
				 SET T.RHMSRoleName = S.RoleName,
					 T.IsDeleted = (CASE WHEN S.ActiveFlag = 0 THEN 1 ELSE 0 END),
					 T.ModifiedBy = @UserName,
					 T.ModifiedDate = @Date;

			/*RHME Role Detail with three qualifiers only active records data set*/
			WITH Role_Qualifiers AS (
             SELECT DISTINCT rd.AssociateID, rqc.ApplensRoleID, rqc.GroupID, rqc.ApplensRHMSRoleID, rqc.QualifierComboID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescMarket THEN ma.MarketID
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescMarket THEN ma.MarketID
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescMarket THEN ma.MarketID
				  ELSE NULL
			END) MarketID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescMarketUnit THEN mu.MarketUnitID
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescMarketUnit THEN mu.MarketUnitID
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescMarketUnit THEN mu.MarketUnitID
				  ELSE NULL
			END) MarketUnitID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescBusinessUnit THEN bu.BusinessUnitID
				  WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescAllBusinessUnit THEN bu.BusinessUnitID
				  WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescBusinessUnit THEN bu.BusinessUnitID
				  WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescAllBusinessUnit THEN bu.BusinessUnitID
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescBusinessUnit THEN bu.BusinessUnitID
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescAllBusinessUnit THEN bu.BusinessUnitID
				  ELSE NULL
			END) BusinessUnitID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescSubBusinessUnit1 THEN sbu1.SBU1ID
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescSubBusinessUnit1 THEN sbu1.SBU1ID
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescSubBusinessUnit1 THEN sbu1.SBU1ID
				  ELSE NULL
			END) SBU1ID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescSubBusinessUnit2 THEN sbu2.SBU2ID
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescSubBusinessUnit2 THEN sbu2.SBU2ID
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescSubBusinessUnit2 THEN sbu2.SBU2ID
				  ELSE NULL
			END) SBU2ID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescIndustrySegment THEN ins.IndustrySegmentId
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescIndustrySegment THEN ins.IndustrySegmentId
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescIndustrySegment THEN ins.IndustrySegmentId
				  ELSE NULL
			END) IndustrySegmentId,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescVertical THEN v.VerticalID
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescVertical THEN v.VerticalID
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescVertical THEN v.VerticalID
				  ELSE NULL
			END) VerticalID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescSubVertical THEN sv.SubVerticalID
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescSubVertical THEN sv.SubVerticalID
			      WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescSubVertical THEN sv.SubVerticalID
				  ELSE NULL
			END) SubVerticalID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescParentCustomer THEN pc.ParentCustomerID
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescParentCustomer THEN pc.ParentCustomerID
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescParentCustomer THEN pc.ParentCustomerID
				  ELSE NULL
			END) ParentCustomerID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescCustomer THEN cu.CustomerID
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescCustomer THEN cu.CustomerID 
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescCustomer THEN cu.CustomerID 
				  ELSE NULL
			END) CustomerID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescPractice THEN p.PracticeID 
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescPractice THEN p.PracticeID
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescPractice THEN p.PracticeID
				  ELSE NULL
			END) PracticeID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescProject THEN pr.ProjectID
			      WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescProject THEN pr.ProjectID
				  WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescProject THEN pr.ProjectID
				  ELSE NULL
			END) ProjectID,
			(CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescMarket AND ma.MarketID IS NOT NULL THEN @DescMarket
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescMarketUnit AND mu.MarketUnitID IS NOT NULL THEN @DescMarketUnit
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescBusinessUnit AND bu.BusinessUnitID IS NOT NULL THEN @DescBusinessUnit
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescAllBusinessUnit AND bu.BusinessUnitID IS NOT NULL THEN @DescAllBusinessUnit
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescSubBusinessUnit1 AND sbu1.SBU1ID IS NOT NULL THEN @DescSubBusinessUnit1
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescSubBusinessUnit2 AND sbu2.SBU2ID IS NOT NULL THEN @DescSubBusinessUnit2
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescIndustrySegment AND ins.IndustrySegmentId IS NOT NULL THEN @DescIndustrySegment
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescVertical AND v.VerticalID IS NOT NULL THEN @DescVertical
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescSubVertical AND sv.SubVerticalID IS NOT NULL THEN @DescSubVertical
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescParentCustomer AND pc.ParentCustomerID IS NOT NULL THEN @DescParentCustomer
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescCustomer AND cu.CustomerID IS NOT NULL THEN @DescCustomer
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescPractice AND p.PracticeID IS NOT NULL THEN @DescPractice
				WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescProject AND pr.ProjectID IS NOT NULL THEN @DescProject
			END) RHMSQualifier1Type, rqc.PrimaryPortfolioType,
		  (CASE WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescMarket AND ma.MarketID IS NOT NULL THEN @DescMarket
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescMarketUnit AND mu.MarketUnitID IS NOT NULL THEN @DescMarketUnit
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescBusinessUnit AND bu.BusinessUnitID IS NOT NULL THEN @DescBusinessUnit
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescAllBusinessUnit AND bu.BusinessUnitID IS NOT NULL THEN @DescAllBusinessUnit
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescSubBusinessUnit1 AND sbu1.SBU1ID IS NOT NULL THEN @DescSubBusinessUnit1
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescSubBusinessUnit2 AND sbu2.SBU2ID IS NOT NULL THEN @DescSubBusinessUnit2
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescIndustrySegment AND ins.IndustrySegmentId IS NOT NULL THEN @DescIndustrySegment
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescVertical AND v.VerticalID IS NOT NULL THEN @DescVertical
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescSubVertical AND sv.SubVerticalID IS NOT NULL THEN @DescSubVertical
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescParentCustomer AND pc.ParentCustomerID IS NOT NULL THEN @DescParentCustomer
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescCustomer AND cu.CustomerID IS NOT NULL THEN @DescCustomer
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescPractice AND p.PracticeID IS NOT NULL THEN @DescPractice
				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescProject AND pr.ProjectID IS NOT NULL THEN @DescProject
			END) RHMSQualifier2Type, rqc.PortfolioQualifier1Type,
		  (CASE WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescMarket AND ma.MarketID IS NOT NULL THEN @DescMarket
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescMarketUnit AND mu.MarketUnitID IS NOT NULL THEN @DescMarketUnit
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescBusinessUnit AND bu.BusinessUnitID IS NOT NULL THEN @DescBusinessUnit
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescAllBusinessUnit AND bu.BusinessUnitID IS NOT NULL THEN @DescAllBusinessUnit
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescSubBusinessUnit1 AND sbu1.SBU1ID IS NOT NULL THEN @DescSubBusinessUnit1
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescSubBusinessUnit2 AND sbu2.SBU2ID IS NOT NULL THEN @DescSubBusinessUnit2
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescIndustrySegment AND ins.IndustrySegmentId IS NOT NULL THEN @DescIndustrySegment
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescVertical AND v.VerticalID IS NOT NULL THEN @DescVertical
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescSubVertical AND sv.SubVerticalID IS NOT NULL THEN @DescSubVertical
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescParentCustomer AND pc.ParentCustomerID IS NOT NULL THEN @DescParentCustomer
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescCustomer AND cu.CustomerID IS NOT NULL THEN @DescCustomer
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescPractice AND p.PracticeID IS NOT NULL THEN @DescPractice
				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescProject AND pr.ProjectID IS NOT NULL THEN @DescProject
			END) RHMSQualifier3Type,  rqc.PortfolioQualifier2Type,
			rd.ActiveFlag
			FROM [$(AVMCOEESADB)].[dbo].[RHMSRoleDetails] rd
			JOIN (
			    SELECT rqc.QualifierComboID, rqc.ApplensRHMSRoleID, rr.RHMSRoleID, rqc.ApplensRoleID, rqc.GroupID, rqc.PrimaryPortfolioTypeID, alt1.AccessLevelTypeName PrimaryPortfolioType, 
				rqc.PortfolioQualifier1TypeID, alt2.AccessLevelTypeName PortfolioQualifier1Type,
				rqc.PortfolioQualifier2TypeID, alt3.AccessLevelTypeName PortfolioQualifier2Type
				FROM RLE.RHMSRoleQualifierCombinations rqc
				JOIN RLE.RHMSRoles rr ON rqc.ApplensRHMSRoleID = rr.ApplensRHMSRoleID
				LEFT JOIN MAS.RLE_AccessLevelTypes alt1 ON rqc.PrimaryPortfolioTypeID = alt1.AccessLevelTypeID AND alt1.IsDeleted = 0
				LEFT JOIN MAS.RLE_AccessLevelTypes alt2 ON rqc.PortfolioQualifier1TypeID = alt2.AccessLevelTypeID AND alt2.IsDeleted = 0
				LEFT JOIN MAS.RLE_AccessLevelTypes alt3 ON rqc.PortfolioQualifier2TypeID = alt3.AccessLevelTypeID AND alt3.IsDeleted = 0
				WHERE rqc.IsDeleted = 0 AND rr.IsDeleted = 0) rqc ON rd.RoleId = rqc.RHMSRoleID AND ISNULL(rd.PrimaryPortfolioType,'') = ISNULL(rqc.PrimaryPortfolioType,'') 
												AND ISNULL(rd.PortfolioQualifier1Type,'') = ISNULL(rqc.PortfolioQualifier1Type,'') 
												AND ISNULL(rd.PortfolioQualifier2Type,'') = ISNULL(rqc.PortfolioQualifier2Type,'')
			LEFT JOIN MAS.Markets ma ON ma.ESAMarketID = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescMarket THEN rd.PrimaryPortfolioId
																WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescMarket THEN rd.PortfolioQualifier1Id
																WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescMarket THEN rd.PortfolioQualifier2Id END) AND ma.IsDeleted = 0
			LEFT JOIN MAS.MarketUnits mu ON mu.ESAMarketUnitID = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescMarketUnit THEN rd.PrimaryPortfolioId
																		WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescMarketUnit THEN rd.PortfolioQualifier1Id
																		WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescMarketUnit THEN rd.PortfolioQualifier2Id END) AND mu.IsDeleted = 0
			LEFT JOIN MAS.BusinessUnits bu ON bu.ESABusinessUnitID = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescBusinessUnit THEN rd.PrimaryPortfolioId
																			WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescBusinessUnit THEN rd.PortfolioQualifier1Id
																			WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescBusinessUnit THEN rd.PortfolioQualifier2Id 
																			WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescAllBusinessUnit  THEN bu.ESABusinessUnitID
																			WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescAllBusinessUnit THEN bu.ESABusinessUnitID 
																			WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescAllBusinessUnit THEN bu.ESABusinessUnitID END) AND bu.IsDeleted = 0
			LEFT JOIN MAS.SubBusinessUnits1 sbu1 ON sbu1.ESASBU1ID = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescSubBusinessUnit1 THEN rd.PrimaryPortfolioId
																			WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescSubBusinessUnit1 THEN rd.PortfolioQualifier1Id
																			WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescSubBusinessUnit1 THEN rd.PortfolioQualifier2Id END) AND sbu1.IsDeleted = 0
			LEFT JOIN MAS.SubBusinessUnits2 sbu2 ON sbu2.ESASBU2ID = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescSubBusinessUnit2 THEN rd.PrimaryPortfolioId
																			WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescSubBusinessUnit2 THEN rd.PortfolioQualifier1Id
																			WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescSubBusinessUnit2 THEN rd.PortfolioQualifier2Id END) AND sbu2.IsDeleted = 0
			LEFT JOIN MAS.IndustrySegments ins ON ins.ESAIndustrySegmentId = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescIndustrySegment THEN rd.PrimaryPortfolioId
																WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescIndustrySegment THEN rd.PortfolioQualifier1Id
																WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescIndustrySegment THEN rd.PortfolioQualifier2Id END) AND ins.IsDeleted = 0
			LEFT JOIN MAS.Verticals v ON v.ESAVerticalID = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescVertical THEN rd.PrimaryPortfolioId
																WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescVertical THEN rd.PortfolioQualifier1Id
																WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescVertical THEN rd.PortfolioQualifier2Id END) AND v.IsDeleted = 0
			LEFT JOIN MAS.SubVerticals sv ON sv.ESASubVerticalID = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescSubVertical THEN rd.PrimaryPortfolioId
																		WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescSubVertical THEN rd.PortfolioQualifier1Id
																		WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescSubVertical THEN rd.PortfolioQualifier2Id END) AND sv.IsDeleted = 0
			LEFT JOIN MAS.ParentCustomers pc ON pc.ESAParentCustomerID = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescParentCustomer THEN rd.PrimaryPortfolioId
																				WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescParentCustomer THEN rd.PortfolioQualifier1Id
																				WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescParentCustomer THEN rd.PortfolioQualifier2Id END) AND pc.IsDeleted = 0
			LEFT JOIN AVL.Customer cu ON cu.ESA_AccountID = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescCustomer THEN rd.PrimaryPortfolioId
																	WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescCustomer THEN rd.PortfolioQualifier1Id
																	WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescCustomer THEN rd.PortfolioQualifier2Id END) AND cu.IsDeleted = 0
			LEFT JOIN MAS.Practices p ON p.ESAHorizontalCode = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescPractice THEN rd.PrimaryPortfolioId
																	WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescPractice THEN rd.PortfolioQualifier1Id
																	WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescPractice THEN rd.PortfolioQualifier2Id END) AND p.IsDeleted = 0
			LEFT JOIN AVL.MAS_projectMaster pr ON pr.ESAProjectID = (CASE WHEN ISNULL(rd.PrimaryPortfolioType,'') = @DescProject THEN rd.PrimaryPortfolioId
																WHEN ISNULL(rd.PortfolioQualifier1Type,'') = @DescProject THEN rd.PortfolioQualifier1Id
																WHEN ISNULL(rd.PortfolioQualifier2Type,'') = @DescProject THEN rd.PortfolioQualifier2Id END) AND pr.IsDeleted = 0
			WHERE rd.ActiveFlag = 1 
		) 
		SELECT AssociateID, ApplensRoleID, GroupID, ApplensRHMSRoleID, QualifierComboID, ActiveFlag 
		,MarketId, MarketUnitId, BusinessUnitID, SBU1ID, SBU2ID, IndustrySegmentId, VerticalID, SubVerticalId, ParentCustomerId, CustomerId, PracticeId, ProjectId, RHMSQualifier1Type, RHMSQualifier2Type, RHMSQualifier3Type
		INTO #UserRoleDataAccess
		FROM Role_Qualifiers
		WHERE ISNULL(RHMSQualifier1Type,'') = ISNULL(PrimaryPortfolioType,'') 
		AND ISNULL(RHMSQualifier2Type,'') = ISNULL(PortfolioQualifier1Type,'') AND ISNULL(RHMSQualifier3Type,'') = ISNULL(PortfolioQualifier2Type,'');

			/* User role mapping sync for RHMS User roles*/
			MERGE RLE.UserRoleMapping AS T
			USING (SELECT DISTINCT AssociateID, ApplensRoleID, GroupID, QualifierComboID FROM #UserRoleDataAccess) AS S 
			ON T.AssociateID = S.AssociateID AND T.ApplensRoleID = S.ApplensRoleID AND T.GroupID = S.GroupID AND T.QualifierComboID = S.QualifierComboID AND T.DataSource = @DataSource
			WHEN NOT MATCHED BY TARGET
			THEN INSERT (AssociateID, ApplensRoleID, GroupID, QualifierComboID, Createdby, CreatedDate, DataSource)
				 VALUES (S.AssociateID, S.ApplensRoleID, S.GroupID, S.QualifierComboID, @UserName, @Date, @DataSource)
			WHEN NOT MATCHED BY SOURCE
				 AND T.DataSource = @DataSource AND T.IsDeleted = 0 
			THEN UPDATE 
				 SET T.IsDeleted = 1,
					 T.ModifiedBy = @UserName,
					 T.ModifiedDate = @Date
			WHEN MATCHED
				 AND T.DataSource = @DataSource AND T.IsDeleted = 1
			THEN UPDATE
				 SET T.IsDeleted = 0,
					 T.ModifiedBy = @UserName,
					 T.ModifiedDate = @Date
			OUTPUT inserted.RoleMappingID, S.AssociateID, S.ApplensRoleID, S.GroupID, S.QualifierComboID
			INTO @UserRoleMapping;

			/*User Role RHMS Qualifier's sync*/
			MERGE RLE.UserRoleDataAccess AS T
			USING (SELECT rm.RoleMappingID, rm.AssociateID, rd.MarketId, rd.MarketUnitId, rd.BusinessUnitID, rd.SBU1ID, rd.SBU2ID,
				   rd.IndustrySegmentId, rd.VerticalID, rd.SubVerticalId, rd.ParentCustomerId, rd.CustomerId, rd.PracticeId, rd.ProjectId 
				   FROM RLE.UserRoleMapping rm 
				   JOIN #UserRoleDataAccess rd ON rm.AssociateID = rd.AssociateID  AND rm.ApplensRoleID = rd.ApplensRoleID AND rm.GroupID = rd.GroupID AND rm.QualifierComboID = rd.QualifierComboID
				   WHERE rm.IsDeleted = 0 AND rm.DataSource = @DataSource
				  ) AS S 
			ON T.RoleMappingID = S.RoleMappingID 
			   AND T.AssociateID = S.AssociateID 
			   AND ISNULL(T.MarketId,'') = ISNULL(S.MarketId,'') 
			   AND ISNULL(T.MarketUnitId,'') = ISNULL(S.MarketUnitId,'') 
			   AND ISNULL(T.BusinessUnitID,'') = ISNULL(S.BusinessUnitID,'') 
			   AND ISNULL(T.SBU1ID,'') = ISNULL(S.SBU1ID,'')
			   AND ISNULL(T.SBU2ID,'') = ISNULL(S.SBU2ID,'') 
			   AND ISNULL(T.IndustrySegmentId,'') = ISNULL(S.IndustrySegmentId,'')
			   AND ISNULL(T.VerticalID,'') = ISNULL(S.VerticalID,'') 
			   AND ISNULL(T.SubVerticalId,'') = ISNULL(S.SubVerticalId,'')
			   AND ISNULL(T.ParentCustomerId,'') = ISNULL(S.ParentCustomerId,'') 
			   AND ISNULL(T.CustomerId,'') = ISNULL(S.CustomerId,'') 
			   AND ISNULL(T.PracticeId,'') = ISNULL(S.PracticeId,'')
			   AND ISNULL(T.ProjectId,'') = ISNULL(S.ProjectId,'') 
			   AND T.DataSource = @DataSource
			WHEN NOT MATCHED BY TARGET
			THEN INSERT (RoleMappingID, AssociateID, MarketId, MarketUnitId, BusinessUnitID, SBU1ID, SBU2ID, 
				        IndustrySegmentId, VerticalID, SubVerticalId, ParentCustomerId, CustomerId, PracticeId, ProjectId, Createdby, CreatedDate, DataSource)
				 VALUES (S.RoleMappingID, S.AssociateID, S.MarketId, S.MarketUnitId, S.BusinessUnitID, S.SBU1ID, S.SBU2ID, 
				        S.IndustrySegmentId, S.VerticalID, S.SubVerticalId, S.ParentCustomerId, S.CustomerId, S.PracticeId, S.ProjectId, @UserName, @Date, @DataSource)
			WHEN NOT MATCHED BY SOURCE
				 AND  T.DataSource = @DataSource AND T.IsDeleted = 0 
			THEN UPDATE 
				 SET T.IsDeleted = 1,
					 T.ModifiedBy = @UserName,
					 T.ModifiedDate = @Date
			WHEN MATCHED
				 AND  T.DataSource = @DataSource AND T.IsDeleted = 1
			THEN UPDATE
				 SET T.IsDeleted = 0,
					 T.ModifiedBy = @UserName,
					 T.ModifiedDate = @Date;
		
			DROP TABLE #UserRoleDataAccess

			TRUNCATE TABLE [RLE].[RHMSRoleDetails]

			INSERT INTO [RLE].[RHMSRoleDetails]
			SELECT * FROM [$(AVMCOEESADB)].[dbo].[RHMSRoleDetails]


		COMMIT TRANSACTION

		UPDATE MAS.JobStatus Set JobStatus = @JobStatusSuccess, EndDateTime = GETDATE() WHERE ID = @JobStatusId
	END TRY
	BEGIN CATCH
		IF (XACT_STATE()) = -1  
		BEGIN  
			ROLLBACK TRANSACTION;  
		END;  
		IF (XACT_STATE()) = 1  
		BEGIN  
			COMMIT TRANSACTION;     
		END;
		UPDATE MAS.JobStatus Set JobStatus = @JobStatusFail, EndDateTime = GETDATE() WHERE ID = @JobStatusId

		DECLARE @HostName NVARCHAR(50);
		DECLARE @Associate NVARCHAR(50);
		DECLARE @ErrorCode	NVARCHAR(50);
		DECLARE @ErrorMessage NVARCHAR(MAX);
		DECLARE @ModuleName VARCHAR(30)='RoleAPI';
		DECLARE @DbName VARCHAR(30)='AppVisionLens';
		DECLARE @getdate  DATETIME=GETDATE();
		DECLARE @DbObjName VARCHAR(50)=(OBJECT_NAME(@@PROCID));
		SET @HostName=(SELECT HOST_NAME());
		SET @Associate=(SELECT SUSER_NAME());
		SET @ErrorCode=(SELECT ERROR_NUMBER());
		SET @ErrorMessage=(SELECT ERROR_MESSAGE());

		EXEC AppVisionLensLogging.[dbo].[InsertLog] 'Critical','ERROR',@HostName,@Associate,@getdate,NULL,'SQL',
													@ModuleName,@JobName,@DbName,@DbObjName,@@SPID,@ErrorCode,@ErrorMessage,
													@JobStatusFail,NULL,NULL;
	END CATCH
END
