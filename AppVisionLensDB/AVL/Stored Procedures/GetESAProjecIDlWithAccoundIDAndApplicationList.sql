CREATE PROCEDURE [AVL].[GetESAProjecIDlWithAccoundIDAndApplicationList]
(
@EsaAccountID VARCHAR(10),
@ApplicationList NVARCHAR(MAX),
@Flag INT
)
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	DECLARE @AccountID BIGINT
	DECLARE @UserId VARCHAR(10)
	DECLARE @l_ZERO INT =0

	CREATE TABLE #ApplicationList(ApplicationId INT)
	
	IF(ISNULL(@ApplicationList,'')<>'' AND @ApplicationList<>'null')
	BEGIN
	INSERT INTO #ApplicationList (ApplicationId)
		SELECT * 
	 FROM OPENJSON(@ApplicationList) 
	 WITH (
			ApplicationId BIGINT '$.AppId'
	 );
	END

	IF((@EsaAccountID is not null and @EsaAccountID !='') and @ApplicationList is not null and @ApplicationList !='' and (@Flag is not null))
	BEGIN 
		IF(@Flag =0)
		BEGIN
			SELECT DISTINCT CONCAT(PM.EsaProjectID,'-',PM.ProjectName) AS EsaProjectID
			FROM AVL.Customer(NOLOCK) C
			INNER JOIN AVL.BusinessCluster(NOLOCK) BC ON C.CustomerID=BC.CustomerID
			INNER JOIN AVL.BusinessClusterMapping (NOLOCK) LOB ON BC.BusinessClusterID=LOB.BusinessClusterID
			INNER JOIN AVL.BusinessClusterMapping (NOLOCK) TRK ON TRK.ParentBusinessClusterMapID = LOB.BusinessClusterMapID AND  LOB.ParentBusinessClusterMapID IS NULL 
			INNER JOIN AVL.BusinessClusterMapping (NOLOCK) APPGRP ON APPGRP.ParentBusinessClusterMapID = TRK.BusinessClusterMapID AND APPGRP.IsHavingSubBusinesss = @l_ZERO
			INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON AD.SubBusinessClusterMapID=APPGRP.BusinessClusterMapID 
			INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.CustomerID=C.CustomerID
			INNER JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM ON APM.ApplicationID=AD.ApplicationID AND PM.ProjectID=apm.ProjectID
			INNER JOIN #ApplicationList AL ON AL.ApplicationId=AD.ApplicationID
			WHERE AD.IsActive=1 AND APM.IsDeleted=@l_ZERO AND PM.IsDeleted=@l_ZERO AND APPGRP.IsDeleted=@l_ZERO AND TRK.IsDeleted=@l_ZERO 
			AND BC.isDeleted=@l_ZERO AND C.IsDeleted=@l_ZERO AND C.ESA_AccountID=@EsaAccountID 
		END
	END
	IF(@Flag =1)
	BEGIN
		DECLARE @l_ONE INT =1
		DECLARE @l_TWO INT =2
		DECLARE @l_FOUR INT =4
		
		SELECT DISTINCT C.Esa_AccountID As EsaAccID,C.CustomerName As AccountName ,AD.ApplicationID,AD.ApplicationName,PM.EsaProjectID As EsaProjId,PM.ProjectName,MPP.AttributeValueName AS ProjectScope
		FROM AVL.Customer(NOLOCK) C
		INNER JOIN AVL.BusinessCluster(NOLOCK) BC ON C.CustomerID=BC.CustomerID
		INNER JOIN AVL.BusinessClusterMapping (NOLOCK) LOB ON BC.BusinessClusterID=LOB.BusinessClusterID
		INNER JOIN AVL.BusinessClusterMapping (NOLOCK) TRK ON TRK.ParentBusinessClusterMapID = LOB.BusinessClusterMapID AND  LOB.ParentBusinessClusterMapID IS NULL 
		INNER JOIN AVL.BusinessClusterMapping (NOLOCK) APPGRP ON APPGRP.ParentBusinessClusterMapID = TRK.BusinessClusterMapID AND APPGRP.IsHavingSubBusinesss = @l_ZERO
		INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON AD.SubBusinessClusterMapID=APPGRP.BusinessClusterMapID 
		INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.CustomerID=C.CustomerID
		INNER JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM ON APM.ApplicationID=AD.ApplicationID AND PM.ProjectID=apm.ProjectID
		LEFT JOIN PP.ProjectAttributeValues(NOLOCK) PPP ON PPP.ProjectID = PM.ProjectID
		INNER JOIN Mas.PPAttributeValues(NOLOCK) MPP ON MPP.AttributeValueId=PPP.AttributeValueId AND PPP.AttributeID=1 AND PPP.AttributeValueId in (@l_TWO,@l_ONE,@l_FOUR) AND PPP.isdeleted=@l_ZERO AND MPP.isDeleted=@l_ZERO
		INNER JOIN #ApplicationList AL ON AL.ApplicationId=AD.ApplicationID
		WHERE AD.IsActive=1 AND APM.IsDeleted=@l_ZERO AND PM.IsDeleted=@l_ZERO AND APPGRP.IsDeleted=@l_ZERO AND TRK.IsDeleted=@l_ZERO AND BC.isDeleted=@l_ZERO AND C.IsDeleted=@l_ZERO AND
		C.ESA_AccountID=@EsaAccountID 
	END
	
	SET @AccountID=CAST(@EsaAccountID AS BIGINT)
	DROP TABLE #ApplicationList
	
	SET NOCOUNT OFF;
END TRY  
BEGIN CATCH  
	DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
	SET @UserId='SYSTEM'
	EXEC AVL_InsertError '[AVL].[GetESAProjecIDlWithAccoundIDAndApplicationList]',@ErrorMessage,@UserId,@AccountID
END CATCH  
END
