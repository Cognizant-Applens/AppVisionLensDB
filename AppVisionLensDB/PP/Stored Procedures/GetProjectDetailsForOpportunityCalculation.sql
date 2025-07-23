CREATE PROCEDURE [PP].[GetProjectDetailsForOpportunityCalculation]
(
@ESA_AccountId int
)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;



CREATE TABLE #ProjectDetailsTransaction (
		ProjectID BIGINT,
		EsaProjId BIGINT,
		ProjectName VARCHAR(250),
		EsaAcc BIGINT,
		ApplicationID BIGINT,
		FTE DECIMAL(10,2),
		ProjectExecutionMethod VARCHAR(250),
		ApplicationExecutionMethod	 VARCHAR(250),
		DeliveryEngagementModel	VARCHAR(250),
		ProjectArchetype VARCHAR(250))

	INSERT INTO #ProjectDetailsTransaction (ProjectID,EsaProjId,ProjectName,EsaAcc,FTE,ProjectExecutionMethod,
		DeliveryEngagementModel,ProjectArchetype)


	select DISTINCT PM.ProjectID,PM.EsaProjectID  As EsaProjId,PM.ProjectName,C.ESA_AccountID AS EsaAcc,--App.ApplicationID,
	OP.FTE,PPV.AttributeValueName as ProjectExecutionMethod,--PPV2.AttributeValueName as ApplicationExecutionMethod,
	PPV1.AttributeValueName as DeliveryEngagementModel,PPV3.AttributeValueName AS ProjectArchetype
	from AVL.MAS_ProjectMaster(NOLOCK) PM
	INNER JOIN PP.ProjectAttributeValues PPA (NOLOCK) ON PM.ProjectID=PPA.ProjectID AND PPA.IsDeleted=0
	INNER JOIN Mas.PPAttributes pp (NOLOCK) on pp.AttributeID=PPA.AttributeID AND pp.IsDeleted=0
	INNER JOIN Mas.PPAttributeValues PPV (NOLOCK) on PPV.AttributeID=pp.AttributeID and PPA.AttributeValueID=PPV.AttributeValueID and PP.AttributeName='ExecutionMethod' AND PPV.IsDeleted=0
	INNER JOIN PP.ProjectAttributeValues PPA1 on PPA.ProjectID = PPA1.ProjectID AND PPA1.IsDeleted=0
	INNER JOIN Mas.PPAttributes pp1 (NOLOCK) on pp1.AttributeID=PPA1.AttributeID AND pp1.IsDeleted=0
	INNER JOIN Mas.PPAttributeValues PPV1 (NOLOCK) on PPV1.AttributeID=pp1.AttributeID and PPA1.AttributeValueID=PPV1.AttributeValueID and  PP1.AttributeName='DeliveryEngagementModel' AND PPV1.IsDeleted=0
	INNER JOIN PP.ProjectAttributeValues PPS (NOLOCK) ON PM.ProjectID=PPS.ProjectID AND PPS.IsDeleted=0
	INNER JOIN Mas.PPAttributes PPAS (NOLOCK) on PPAS.AttributeID=PPS.AttributeID AND PPAS.IsDeleted=0
	INNER JOIN Mas.PPAttributeValues PPVS (NOLOCK) on PPVS.AttributeID=PPAS.AttributeID and PPS.AttributeValueID=PPVS.AttributeValueID and PPAS.AttributeName='ProjectScope' AND PPVS.IsDeleted=0
	INNER JOIN PP.ScopeOfWork(NOLOCK) soc ON soc.ProjectID=PM.ProjectID AND soc.IsDeleted=0
	INNER JOIN Mas.PPAttributes (NOLOCK) PP3 ON PP3.AttributeName ='TypeofProject' AND PP3.IsDeleted = 0 AND PP3.IsDeleted=0
	INNER JOIN Mas.PPAttributeValues PPV3 (NOLOCK) on PPV3.AttributevalueID=soc.ProjectTypeID AND PPV3.IsDeleted=0
	INNER JOIN PP.OPLESAData(NOLOCK) OP ON OP.ProjectID=PM.ProjectID AND OP.IsDeleted=0
	INNER JOIN AVL.Customer(NOLOCK) C ON C.CustomerID=PM.CustomerID AND C.IsDeleted=0 
	WHERE PPVS.AttributeValueName IN ('Development','Maintenance','Testing')  AND PM.IsDeleted=0 AND C.ESA_AccountID=@ESA_AccountId;


	SELECT DISTINCT PD.ProjectID,PD.EsaProjId,PD.ProjectName,PD.EsaAcc,App.ApplicationID,PD.FTE,PD.ProjectExecutionMethod,PPV2.AttributeValueName as ApplicationExecutionMethod,
		DeliveryEngagementModel,ProjectArchetype FROM #ProjectDetailsTransaction PD (NOLOCK)
	INNER JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM ON  PD.ProjectID=apm.ProjectID AND APM.IsDeleted=0
	INNER JOIN ADM.ALMApplicationDetails(NOLOCK) APP on APM.ApplicationID = APP.ApplicationID AND APP.IsDeleted=0
	INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) APPN ON APPN.ApplicationID=APP.ApplicationID AND APPN.IsActive=1
	INNER JOIN Mas.PPAttributeValues PPV2 on PPV2.AttributeValueID =APP.ExecutionMethod AND PPV2.IsDeleted=0

		DROP TABLE #ProjectDetailsTransaction


END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		EXEC AVL_InsertError '[PP].[GetProjectDetailsForOpportunityCalculation]',@ErrorMessage,0,0
		
	END CATCH  
END
