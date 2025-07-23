/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		<Anitha P>
-- Create date: <2019-feb-26>
-- =============================================
CREATE PROCEDURE [AVL].[GetDDSearchFilterValues]
@CustomerID int,
@EmployeeID nvarchar(1000),
@ProjectId BIGINT=NULL 

AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON; 
	--Selecting Project Applications
	SELECT DISTINCT APM.ProjectID,AD.ApplicationName,AD.ApplicationID,AD.SubBusinessClusterMapID INTO #AppTemp
	FROM AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM
	JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD 
	ON APM.ApplicationID=AD.ApplicationID 
	WHERE APM.ProjectID=@ProjectId AND APM.IsDeleted=0 AND AD.IsActive=1

	--Selecting Portfolios
	SELECT DISTINCT AT.ProjectID,BCM.BusinessClusterMapID,BCM.BusinessClusterBaseName INTO #Porfolio 
	FROM #AppTemp AT
	INNER JOIN AVL.BusinessClusterMapping(NOLOCK) BCM ON AT.SubBusinessClusterMapID=BCM.BusinessClusterMapID
	WHERE BCM.IsHavingSubBusinesss=0 AND ISNULL(BCM.IsDeleted,0)=0
	ORDER BY BCM.BusinessClusterBaseName ASC

	SELECT ProjectID,BusinessClusterMapID,BusinessClusterBaseName FROM #Porfolio WHERE ProjectID=@ProjectId
	SELECT ProjectID,ApplicationName,ApplicationID,SubBusinessClusterMapID FROM #AppTemp WHERE ProjectID=@ProjectId

	DROP TABLE #AppTemp
	DROP TABLE #Porfolio
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
	EXEC AVL_InsertError '[AVL].[GetDDSearchFilterValues]',@ErrorMessage,0,0	
END CATCH
END
