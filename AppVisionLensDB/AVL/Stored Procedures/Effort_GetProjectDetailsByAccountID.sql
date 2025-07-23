/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Effort_GetProjectDetailsByAccountID] 

	@CustomerID int,
	@EmployeeID nvarchar(50)
AS
BEGIN
BEGIN TRY
 SET NOCOUNT ON;
        SELECT  DISTINCT PM.ProjectID,PM.ProjectName,ISNULL(LM.TimeZoneId,0) AS UserTimeZoneId,
		TZM.TZoneName AS UserTimeZoneName,
		ISNULL(PC.TimeZoneId,32) AS ProjectTimeZoneId,TZM1.TZoneName AS ProjectTimeZoneName,
		ISNULL(PC.SupportTypeId,1) AS SupportTypeId
			FROM [AVL].[MAS_LoginMaster] LM With (NOLOCK)
		INNER JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) PM
			ON LM.ProjectID=PM.ProjectID AND LM.CustomerID=PM.CustomerID AND ISNULL(PM.IsDeleted,0)=0
		INNER JOIN AVL.Customer(NOLOCK) C 
			ON C.CustomerID = PM.CustomerID AND C.IsDeleted = 0
		INNER JOIN AVL.PRJ_ConfigurationProgress(NOLOCK) CP
			ON CP.CustomerID = PM.CustomerID AND CP.ScreenID = 4 AND CP.CompletionPercentage = 100
		AND (( IsNull(C.IsCognizant,1) = 0 AND CP.IsDeleted = 0)
        OR (IsNull(C.IsCognizant,1) = 1 AND CP.ProjectID = PM.ProjectId AND CP.IsDeleted = 0))
		LEFT join AVL.MAS_TimeZoneMaster(NOLOCK) TZM 
			ON ISNULL(LM.TimeZoneId,0)=TZM.TimeZoneID
		LEFT JOIN AVL.MAP_ProjectConfig(NOLOCK)  PC 
			ON PM.ProjectID=PC.ProjectID 
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) TZM1 
			ON   ISNULL(PC.TimeZoneID,32)=TZM1.TimeZoneId
		WHERE PM.CustomerID=@CustomerID AND LM.EmployeeID=@EmployeeID AND LM.IsDeleted=0 
		
 SET NOCOUNT OFF;
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError 'dbo.Effort_GetProjectDetailsByAccountID', @ErrorMessage,@EmployeeID,@CustomerID
		
END CATCH  

END
