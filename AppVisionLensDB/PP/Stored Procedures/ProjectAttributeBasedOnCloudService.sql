/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[ProjectAttributeBasedOnCloudService] 
       @ProjectID BIGINT=NULL,
       @ApplicationID BIGINT=NULL,
	   @EmployeeID nvarchar(50)
       
AS
BEGIN
SET NOCOUNT ON
DECLARE @ApplicationCount BIGINT
DECLARE @AttributeValueCount BIGINT
DECLARE @ApplicationsOnCloud INT =53
DECLARE @Yes INT =290
DECLARE @No INT =291




IF ISNULL(@ProjectID, 0) != 0 

BEGIN
		DECLARE @AppProjMapCount INT

		SELECT  @AppProjMapCount = Count(ProjectApplicationMapID) FROM avl.APP_MAP_ApplicationProjectMapping (NOLOCK) where ProjectID = @ProjectID and IsDeleted=0

		declare @ProjectCloudMapping int

	SET @ProjectCloudMapping =(select  COUNT(ProjectID) from pp.ProjectAttributeValues (NOLOCK) where ProjectID=@ProjectID and AttributeID =53)

	IF (@ProjectCloudMapping =0 AND @AppProjMapCount>0)
	BEGIN
		insert into PP.ProjectAttributeValues VALUES(@ProjectID,291,53,0,@EmployeeID,GETDATE(),NULL,NULL)
	END

       SET @ApplicationCount = (SELECT count(IA.ApplicationID) FROM [AVL].[APP_MAS_InfrastructureApplication] (NOLOCK) IA
       JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APM ON IA.ApplicationID = APM.ApplicationID
       WHERE APM.ProjectID = @ProjectID and IA.HostedEnvironmentID  in (1,2,3) and APM.IsDeleted=0 and IA.IsDeleted=0 )

       SET @AttributeValueCount =(SELECT COUNT(ProjectID) FROM pp.ProjectAttributeValues (NOLOCK) where ProjectID=@ProjectID and AttributeID = @ApplicationsOnCloud)


       IF(@ApplicationCount >=1 and @AttributeValueCount = 1 )
       BEGIN
       UPDATE PP.ProjectAttributeValues SET AttributeValueID=@Yes,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID and
	   AttributeID= @ApplicationsOnCloud AND IsDeleted=0
       END

       ELSE IF(@ApplicationCount =0 and @AttributeValueCount = 1)
       BEGIN
       UPDATE PP.ProjectAttributeValues SET AttributeValueID=@No,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID AND
	   AttributeID=@ApplicationsOnCloud AND IsDeleted=0
       END
END


IF (ISNULL(@ProjectID, 0) = 0  AND ISNULL(@ApplicationID, 0) != 0  )

BEGIN

	CREATE TABLE #TempProject(ID INT IDENTITY(1,1),ProjectID BIGINT,ApplicationID BIGINT)

	INSERT INTO #TempProject SELECT  DISTINCT ProjectID,ApplicationID from AVL.APP_MAP_ApplicationProjectMapping

	WHERE ApplicationID=@ApplicationID


 
	CREATE TABLE #TempAppCount(ID INT IDENTITY(1,1),ProjectID BIGINT,ApplicationCount BIGINT)

	INSERT INTO #TempAppCount
	SELECT DISTINCT TP.ProjectID ,COUNT(IA.ApplicationID) AS ApplicationCount   FROM  #TempProject TP (NOLOCK)
	LEFT JOIN AVL.APP_MAP_ApplicationProjectMapping APM (NOLOCK) ON APM.ProjectID=TP.ProjectID and apm.IsDeleted=0
	LEFT JOIN [AVL].[APP_MAS_InfrastructureApplication] IA (NOLOCK) ON IA.ApplicationID = APM.ApplicationID and IA.IsDeleted=0
	WHERE IA.HostedEnvironmentID  in (1,2,3) GROUP by TP.ProjectID

	CREATE table #TempProjectforAppCount(ID INT IDENTITY(1,1),ProjectID BIGINT,ApplicationCount BIGINT)

	INSERT INTO #TempProjectforAppCount  Select TP.ProjectID,TAC.ApplicationCount   from #TempProject TP (NOLOCK)	
	LEFT JOIN	#TempAppCount TAC (NOLOCK) ON TAC.ProjectID = TP.ProjectID


	CREATE table #TempProjectforAttribute(ID int identity(1,1),ProjectID BIGINT,AttributeIDCount BIGINT)

	INSERT INTO #TempProjectforAttribute SELECT  DISTINCT PAV.ProjectID,COUNT(PAV.AttributeID) as AttributeCount   from pp.ProjectAttributeValues PAV (NOLOCK)
	JOIN AVL.APP_MAP_ApplicationProjectMapping TP (NOLOCK) ON PAV.ProjectID=TP.ProjectID
	where PAV.IsDeleted=0 and PAV.AttributeID=@ApplicationsOnCloud and TP.ApplicationID=@ApplicationID GROUP BY PAV.ProjectID

	UPDATE PP.ProjectAttributeValues 
	SET AttributeValueID=(  
	CASE 
	 WHEN TPA.AttributeIDCount=1 AND TPC.ApplicationCount >=1 THEN @Yes
	WHEN TPC.ApplicationCount IS NULL AND TPA.AttributeIDCount=1 THEN @No
	WHEN TPA.AttributeIDCount=1 AND TPC.ApplicationCount =0 THEN @No
	END),ModifiedBy=@EmployeeID
	,ModifiedDate=GETDATE()
	FROM pp.ProjectAttributeValues PP (NOLOCK)
	LEFT JOIN #TempProjectforAttribute (NOLOCK) TPA ON TPA.ProjectID=PP.ProjectID
	LEFT JOIN #TempProjectforAppCount (NOLOCK) TPC ON TPC.ProjectID=PP.ProjectID 
	WHERE PP.ProjectID IN(Select ProjectID from #TempProject)
    And PP.AttributeID=@ApplicationsOnCloud AND PP.IsDeleted=0

 
END

SET NOCOUNT OFF
END
