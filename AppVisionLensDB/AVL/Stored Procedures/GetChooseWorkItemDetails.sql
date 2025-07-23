/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ========================================================================================================
-- Author      : Shobana
-- Create date : 20 May 2020
-- Description : Procedure to Choose Work Item Details           
-- Test        : [AVL].[GetChooseWorkItemDetails] '10337','','','','2020-05-01','2020-06-06','','1',10
-- Revision    :
-- Revised By  :
-- ========================================================================================================
CREATE PROCEDURE [AVL].[GetChooseWorkItemDetails]

     @ProjectID INT,  
	 @WorkItemId NVARCHAR(MAX)=NULL,
	 @AssignedTo NVARCHAR(MAX)=NULL,           
	 @ApplicationIDs NVARCHAR(MAX)=NULL, 
	 @CreatedDateFrom DATETIME =NULL,      
	 @CreatedDateTo DATETIME =NULL, 
	 @StatusIDs NVARCHAR(MAX) =NULL,
	 @PageNo int,
     @PageSize int=NULL
	 
AS
BEGIN
BEGIN TRY

SET NOCOUNT ON;
    DECLARE @BeginDate DATETIME;      
    DECLARE @EndDate DATETIME;        
    DECLARE @Dateflag INT;
	SET @PageSize=10;
	IF @PageNo =0 
	BEGIN
		SET @PageNo=1;
	END
	IF ( @CreatedDateFrom <> '' AND @CreatedDateTo <> '')       
      BEGIN        
		SET @BeginDate = CONVERT(DATETIME, @CreatedDateFrom) + '00:00:00'            
		SET @EndDate = CONVERT(DATETIME, @CreatedDateTo) + '23:59:59'        
		SET @Dateflag = 1        
       END        
      
    ELSE IF ( @CreatedDateFrom = '' AND @CreatedDateTo = '')       
      BEGIN        
		SET @BeginDate = NULL;        
		SET @EndDate = NULL;        
		SET @Dateflag = 4        
      END   
	  create table #ChooseWorkItemDetails(
	  WorkItemID nvarchar(100),
	  [Description] nvarchar(MAX),
	  [Application] nvarchar(1000),
	  Assignee nvarchar(250),
	  [Status] nvarchar(50),
	  [CreatedDate] nvarchar(50) )

	  create table #TempApplication(
	  WorkItem_Id nvarchar(100),
	  ApplicationId bigint,
	  ApplicationName nvarchar(1000)
	  )

	  Insert into #ChooseWorkItemDetails
	SELECT 
	 AWD.WorkItem_Id AS WorkItemID
	,AWD.WorkItem_Title AS [Description]
	,null AS [Application]
	,LM.EmployeeName AS Assignee
	,AMS.StatusName AS [Status]
	,AWD.CreatedDate
	FROM [ADM].[ALM_TRN_WorkItem_Details](NOLOCK) AWD
	JOIN [PP].[ALM_MAP_Status](NOLOCK) APS
	ON APS.StatusMapId = AWD.StatusMapId AND APS.IsDeleted = 0 
	JOIN [PP].[ALM_MAS_Status](NOLOCK) AMS
	ON AMS.StatusId = APS.StatusId AND AMS.IsDeleted = 0	
	JOIN PP.ALM_MAP_WorkType(NOLOCK) WT
	ON WT.WorkTypeMapId = AWD.WorkTypeMapId AND WT.IsDeleted = 0
	LEFT JOIN AVL.MAS_LoginMaster(NOLOCK) LM
	ON LM.EmployeeID = AWD.Assignee AND AWD.Project_Id = LM.ProjectID AND  LM.IsDeleted = 0 
	LEFT JOIN PP.ScopeOfWork(NOLOCK) SW
	ON SW.ProjectId = AWD.Project_Id AND SW.Isdeleted = 0
	WHERE AWD.Project_Id =@ProjectID 
	AND ((ISNULL(SW.IsApplensAsALM,0) = 0 AND ISNULL(WT.IsEffortTracking,0) = 1) OR (ISNULL(SW.IsApplensAsALM,0)  = 1)) 
	AND (AWD.WorkItem_Id LIKE '%' + @WorkItemID + '%' OR @WorkItemID = '' OR @WorkItemID IS NULL)
	AND (AWD.Assignee LIKE '%' + @AssignedTo + '%'OR @AssignedTo = '' OR @AssignedTo IS NULL) 
    AND ((ISNULL(@StatusIDs,'')= '' AND AWD.StatusMapId=AWD.StatusMapId) OR (AWD.StatusMapId IN(SELECT Item  FROM dbo.Split(@StatusIDs,','))))  
    AND ((@Dateflag=1 AND (AWD.CreatedDate BETWEEN @BeginDate AND @EndDate)) OR (@Dateflag=4 AND (1=1)))       
	AND AWD.IsDeleted = 0 
	order by WorkItemID

	SELECT WD.WorkItemDetailsId,WT.WorkTypeMapId,WD.WorkItem_Id,WT.WorkTypeId,WD.Linked_ParentID AS Parent1,
	ISNULL(WD.WorkItemDetailsId,0) AS Parent1ID,
	WD1.Linked_ParentID AS Parent2,
	ISNULL(WD1.WorkItemDetailsId,0)  AS Parent2ID,
	WD2.Linked_ParentID AS Parent3,
	ISNULL(WD2.WorkItemDetailsId,0)  AS Parent3ID,
	NULL AS IDsWithApplication,NULL AS IsAppAvailable,
	WD.Project_Id
	INTO #Temp
	FROM ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD
	LEFT JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD1 ON WD.Linked_ParentID=WD1.WorkItem_Id AND WD.Project_Id = WD1.Project_Id AND WD.IsDeleted = 0 AND WD1.IsDeleted = 0
	LEFT JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD2 ON WD1.Linked_ParentID=WD2.WorkItem_Id AND WD1.Project_Id = WD2.Project_Id AND WD2.IsDeleted = 0
	INNER JOIN [PP].[ALM_MAP_WorkType](NOLOCK) WT ON WD.WorkTypeMapId=WT.WorkTypeMapId AND WT.IsDeleted = 0
	INNER JOIN #ChooseWorkItemDetails(NOLOCK) CT ON CT.WorkItemID = WD.WorkItem_Id
	WHERE WD.Project_Id = @ProjectID
	ORDER BY WorkTypeId ASC

	
	
	UPDATE #Temp SET IDsWithApplication=WorkItemDetailsId,IsAppAvailable=1 WHERE WorkTypeId=1
	UPDATE #Temp SET IDsWithApplication=Parent1ID,IsAppAvailable=1 WHERE WorkTypeId=2

	UPDATE WT SET WT.IsAppAvailable=1,IDsWithApplication=WT.Parent1ID
	FROM #Temp WT
	INNER JOIN ADM.ALM_TRN_WorkItem_ApplicationMapping(NOLOCK) WA ON WT.Parent1ID=WA.WorkItemDetailsId
	WHERE WT.WorkTypeId NOT IN(1,2) AND ISNULL(WT.IsAppAvailable,0) !=1
	
	UPDATE WT SET WT.IsAppAvailable=1,IDsWithApplication=WT.Parent2ID
	FROM #Temp WT
	INNER JOIN ADM.ALM_TRN_WorkItem_ApplicationMapping(NOLOCK) WA ON WT.Parent2ID=WA.WorkItemDetailsId
	WHERE WT.WorkTypeId NOT IN(1,2) AND ISNULL(WT.IsAppAvailable,0) !=1
	IF(IsNull(@ApplicationIDs,'') <>'')
	begin
	Insert INTO #TempApplication
	SELECT distinct T.WorkItem_Id,AD.ApplicationID,AD.ApplicationName 
	FROM #Temp(NOLOCK) T
	INNER JOIN ADM.ALM_TRN_WorkItem_ApplicationMapping(NOLOCK) WI ON T.IDsWithApplication=WI.WorkItemDetailsId
	INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON WI.Application_Id=AD.ApplicationID
	where AD.IsActive = 1 AND
	EXISTS (SELECT 1 FROM dbo.Split(@ApplicationIDs,',') WHERE WI.Application_Id = Item)
	end
	else
	begin
	Insert INTO #TempApplication
	SELECT distinct T.WorkItem_Id,AD.ApplicationID,AD.ApplicationName 
	FROM #Temp(NOLOCK)  T
	INNER JOIN ADM.ALM_TRN_WorkItem_ApplicationMapping(NOLOCK) WI ON T.IDsWithApplication=WI.WorkItemDetailsId
	INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON WI.Application_Id=AD.ApplicationID
	where AD.IsActive = 1
	end

	SELECT  E.WorkItem_Id,
	STUFF((SELECT  ',' + ApplicationName
            FROM #TempApplication(NOLOCK) EE
            WHERE  EE.WorkItem_Id=E.WorkItem_Id
            ORDER BY WorkItem_Id
        FOR XML PATH('')), 1, 1, '') AS ApplicationName
		INTO #ApplicationTemp
	FROM #TempApplication(NOLOCK) E
	GROUP BY E.WorkItem_Id

	UPDATE CT SET CT.[Application]=ATT.ApplicationName
	FROM
	#ChooseWorkItemDetails CT 
	JOIN #ApplicationTemp(NOLOCK) ATT 
	ON ATT.WorkItem_Id = CT.WorkItemID
	

	DECLARE @isapplensasALM  AS BIT;
	SET  @isapplensasALM = (SELECT ISNULL(IsApplensAsALM,1) from PP.ScopeOfWork(NOLOCK) WHERE ProjectID = @Projectid AND Isdeleted = 0)    
    IF (@isapplensasALM = 1)
	BEGIN
	SELECT  DISTINCT GW.ProjectId,TP.WorkItemDetailsId,TP.WorkItem_Id,WorkTypeId,AMAP.Application_Id as ApplicationID,GW.IsEffortTracking
	INTO #TempWorkItem
	from #temp TP (NOLOCK)
	join ADM.ALM_TRN_WorkItem_ApplicationMapping AMAP (NOLOCK) ON
	AMAP.WorkItemDetailsId = TP.IDsWithApplication
	JOIN ADM.ALMApplicationDetails(NOLOCK) AAD ON
	AAD.ApplicationID = AMAP.Application_Id AND AAD.Isdeleted = 0
	join [PP].[ALM_MAP_GenericWorkItemConfig] (NOLOCK) GW 
	ON GW.ProjectId = TP.Project_Id AND AAD.ExecutionMethod = GW.ExecutionId AND TP.WorkTypeId = GW.WorkItemTypeId
	AND GW.Isdeleted = 0 
	WHERE GW.IsEffortTracking = 0

	IF EXISTS (SELECT  1 FROM #TempWorkItem)
	BEGIN
	DELETE CT  FROM #ChooseWorkItemDetails CT
	JOIN #TempWorkItem TW ON
	TW.WorkItem_Id = CT.WorkItemId
	END

	END

	DECLARE @Count INT;

	DECLARE @PageCountQuery nvarchar(max);
	DECLARE @DataQuerywithApplication nvarchar(max);
		DECLARE @DataQueryWithoutApplication nvarchar(max);
	DECLARE @ColumnList nvarchar(max) = '*';
	DECLARE @TableName nvarchar(128)= '#ChooseWorkItemDetails';
	DECLARE @FilterColumn nvarchar(max) = 'WorkItemID';
	DECLARE @FilterColumn1 nvarchar(max) = 'Application';
	

	SET @PageCountQuery = 'SELECT PageCount = (count(*)/'+CONVERT(nvarchar, @PageSize)+') + (CASE WHEN CEILING(count(*)%'+CONVERT(nvarchar, @PageSize)+') > 0 THEN 1 ELSE 0 END)
						   FROM '+ @TableName

	SET @DataQuerywithApplication = 'SELECT '+@ColumnList+' FROM '+ @TableName +' WHERE ' + @FilterColumn1  + ' IS NOT NULL '+
				     ' ORDER BY '+@FilterColumn+' ASC' 
				     --OFFSET '+ CONVERT(nvarchar, @PageNo - 1 ) +' * '+ CONVERT(nvarchar, @PageSize) +' ROWS
				     --FETCH NEXT '+ CONVERT(nvarchar, @PageSize) +' ROWS ONLY'
				
	SET @DataQueryWithoutApplication = 'SELECT '+@ColumnList+' FROM '+ @TableName +
				     ' ORDER BY '+@FilterColumn+' ASC'
				     --OFFSET '+ CONVERT(nvarchar, @PageNo - 1 ) +' * '+ CONVERT(nvarchar, @PageSize) +' ROWS
				     --FETCH NEXT '+ CONVERT(nvarchar, @PageSize) +' ROWS ONLY'

		EXECUTE sp_executesql @PageCountQuery
		
		If(IsNUll(@ApplicationIds,'') = '')
			BEGIN
				EXECUTE sp_executesql @DataQueryWithoutApplication;
				SET @Count=(SELECT COUNT(1) FROM #ChooseWorkItemDetails(NOLOCK))
				SELECT @Count AS TotalCount
			END
		Else
			BEGIN
				EXECUTE sp_executesql @DataQuerywithApplication;
				SET @Count=(SELECT COUNT(1) FROM #ChooseWorkItemDetails(NOLOCK) WHERE Application IS NOT NULL )
				SELECT @Count AS TotalCount
			END

			IF OBJECT_ID('tempdb..#ChooseWorkItemDetails', 'U') IS NOT NULL
		    BEGIN
			DROP TABLE #ChooseWorkItemDetails
		    END
			IF OBJECT_ID('tempdb..#Temp', 'U') IS NOT NULL
		    BEGIN
			DROP TABLE #Temp
		    END
			IF OBJECT_ID('tempdb..#TempApplication', 'U') IS NOT NULL
		    BEGIN
			DROP TABLE #TempApplication
		    END
		    IF OBJECT_ID('tempdb..#ApplicationTemp', 'U') IS NOT NULL
		    BEGIN
			DROP TABLE #ApplicationTemp
		    END

SET NOCOUNT OFF;
END TRY
	BEGIN CATCH

			DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
	EXEC AVL_InsertError '[AVL].[GetChooseWorkItemDetails]', @ErrorMessage, 0,0
		
	END CATCH;
END
