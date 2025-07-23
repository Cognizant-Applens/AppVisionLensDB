/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ===============================================================
-- Author		: Shobana
-- Create date	: 14-July-2020
-- Description	: Get the Project Details for ADM
-- Revision		: 
-- Revised By	: 
-- Test         : [AVL].[GetADMWorkItemProjects] '674078',7097
-- ===============================================================

CREATE PROCEDURE [AVL].[GetADMWorkItemProjects]
@EmployeeID nvarchar(50)=null,
@CustomerID BIGINT=NULL
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON

	SELECT DISTINCT LM.ProjectID,PM.ProjectName,
	ISNULL(SW.IsApplensAsALM,0) AS IsApplensAsALM,
	0 AS IsAgile,0 AS IsWBS,0 AS IsIterative,0 AS IsOthers,
	0 AS IsMultiple,0 AS IsKanban,0 AS IsEffortBased,CAST(NULL AS NVARCHAR(200)) AS WorkItemMeasurement
	INTO #ADMProjectList
	FROM AVL.MAS_LoginMaster LM With (NOLOCK)
	JOIN AVL.MAS_ProjectMaster(NOLOCK) PM 
		ON PM.ProjectID=LM.ProjectID AND ISNULL(PM.IsDeleted,0)=0
	JOIN AVL.Customer(NOLOCK) Cust 
		ON LM.CustomerID=Cust.CustomerID AND ISNULL(Cust.IsDeleted,0) = 0
	LEFT JOIN PP.ScopeOfWork(NOLOCK) SW 
		ON SW.ProjectID = LM.ProjectID AND ISNULL(SW.IsDeleted,0) = 0
	JOIN AVL.PRJ_ConfigurationProgress (NOLOCK) PTP
	    ON PTP.CustomerID = PM.CustomerID AND 
	   ((ISNULL(CUST.IsCognizant,1) = 1 AND PTP.ProjectID = LM.ProjectID AND PTP.IsDeleted = 0)
	   OR(ISNULL(CUST.IsCognizant,1) = 0  AND PTP.IsDeleted = 0))
	WHERE LM.EmployeeID=@EmployeeID AND ISNull(LM.IsDeleted,0) = 0 
	AND LM.CustomerID=@CustomerID 
	AND PTP.ScreenId = 4 AND PTP.CompletionPercentage = 100

	UPDATE PM 
	SET PM.IsAgile = 1
	 FROM #ADMProjectList PM
	JOIN PP.ProjectAttributeValues(NOLOCK) PAV
		ON PM.ProjectID = PAV.ProjectID AND PAV.IsDeleted = 0 
	WHERE PAV.AttributeID = 3 AND PM.ProjectID = PAV.ProjectID 
	AND (pav.AttributeValueID >= 5 AND pav.AttributeValueID <= 14)
	
	UPDATE PM 
	SET PM.IsOthers = 1
	 FROM #ADMProjectList PM
	JOIN PP.ProjectAttributeValues(NOLOCK) PAV
		ON PM.ProjectID = PAV.ProjectID AND PAV.IsDeleted = 0 
	WHERE PAV.AttributeID = 3 AND PM.ProjectID = PAV.ProjectID 
	AND (pav.AttributeValueID  = 15 OR pav.AttributeValueID > 17)

	UPDATE PM 
	SET PM.IsIterative = 1
	 FROM #ADMProjectList PM
	JOIN PP.ProjectAttributeValues(NOLOCK) PAV
		ON PM.ProjectID = PAV.ProjectID AND PAV.IsDeleted = 0 
	WHERE PAV.AttributeID = 3 AND PM.ProjectID = PAV.ProjectID 
	AND pav.AttributeValueID = 17

	UPDATE PM 
	SET PM.IsWBS = 1
	 FROM #ADMProjectList PM
	JOIN PP.ProjectAttributeValues(NOLOCK) PAV
		ON PM.ProjectID = PAV.ProjectID AND PAV.IsDeleted = 0 
	WHERE PAV.AttributeID = 3 AND PM.ProjectID = PAV.ProjectID 
	AND pav.AttributeValueID = 16

	UPDATE PM 
	SET PM.IsKanban = 1
	 FROM #ADMProjectList PM
	JOIN PP.ProjectAttributeValues(NOLOCK) PAV
		ON PM.ProjectID = PAV.ProjectID AND PAV.IsDeleted = 0 
	WHERE PAV.AttributeID = 3 AND PM.ProjectID = PAV.ProjectID 
	AND pav.AttributeValueID = 6

	UPDATE PM 
	SET PM.IsEffortBased = 1
	 FROM #ADMProjectList PM
	JOIN PP.ProjectAttributeValues(NOLOCK) PAV
		ON PM.ProjectID = PAV.ProjectID AND PAV.IsDeleted = 0 
	WHERE PAV.AttributeID = 26 AND PM.ProjectID = PAV.ProjectID 
	AND pav.AttributeValueID = 279

	UPDATE PM 
	SET PM.WorkItemMeasurement = CASE WHEN PAV.AttributeValueID = 243 THEN  OAV.OtherFieldValue
	ELSE MPA.AttributeValueName END
	FROM #ADMProjectList PM
	JOIN PP.ProjectAttributeValues(NOLOCK) PAV
		ON PM.ProjectID = PAV.ProjectID AND PAV.IsDeleted = 0 
	JOIN MAS.PPAttributeValues (NOLOCK) MPA
		ON PAV.AttributeValueID = MPA.AttributeValueID AND MPA.IsDeleted = 0
	LEFT JOIN PP.OtherAttributeValues(NOLOCK) OAV
		ON OAV.AttributeValueID = PAV.AttributeValueID AND OAV.ProjectID = PAV.ProjectID AND OAV.IsDeleted = 0
	WHERE PAV.AttributeID = 26
	
	SELECT ProjectID,SUM(IsAgile+IsIterative+IsWBS+IsOthers) AS MultipleEM
	INTO #MultipleExecutionProjects
	FROM #ADMProjectList With (NOLOCK)
	GROUP BY ProjectID
	
	UPDATE AD SET IsMultiple = CASE WHEN MultipleEM > 1 THEN 1 ELSE 0 END
	FROM #ADMProjectList AD
	JOIN #MultipleExecutionProjects MEM (NOLOCK)
	ON MEM.ProjectID = AD.ProjectID

	SELECT ProjectID,ProjectName,IsApplensAsALM,IsAgile,
	IsIterative,IsWBS,IsOthers,IsMultiple,IsKanban,IsEffortBased,WorkItemMeasurement
	FROM #ADMProjectList With (NOLOCK)
SET NOCOUNT OFF
END TRY   
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetADMWorkItemProjects]', @ErrorMessage, @EmployeeID,0
		
	END CATCH  
END
