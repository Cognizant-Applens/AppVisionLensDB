/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:      Prakash     
-- Create date:      23 Nov 2018
-- Description:   get time zone detai;ls
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- EXEC [AVL].[Mini_GetTimeZoneInfoByEmployee] '471742','10337'

-- ============================================================================ 

-- EXEC [AVL].[Mini_GetTimeZoneInfoByEmployee] '471742','10337'
CREATE PROCEDURE [AVL].[Mini_GetTimeZoneInfoByEmployee]
(
@EmployeeID NVARCHAR(50),

@ProjectID bigint = null

)
AS 
BEGIN
BEGIN TRY  
BEGIN TRAN
SELECT ProjectID,TimeZoneId INTO #MAS_LoginMaster FROM AVL.MAS_LoginMaster
  WHERE EmployeeID=@EmployeeID AND IsDeleted=0 AND ProjectID=@ProjectID

SELECT LM.ProjectID,LM.TimeZoneId,TZM.TZoneName  AS UserTimeZoneName,
TZM1.TZoneName AS ProjectTimeZoneName FROM #MAS_LoginMaster LM
INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
ON LM.ProjectID =PM.ProjectID
LEFT JOIN AVL.MAP_ProjectConfig PC ON PM.ProjectID=PC.ProjectID
LEFT JOIN AVL.MAS_TimeZoneMaster TZM ON LM.TIMEZONEid=TZM.TimeZoneID
LEFT JOIN AVL.MAS_TimeZoneMaster TZM1 ON ISNULL(PC.TimeZoneId,32)=TZM1.TimeZoneID




	SET NOCOUNT OFF;   
	COMMIT TRAN   
	
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		-- INSERT Error    
		EXEC AVL_InsertError '[AVL].[Mini_GetTimeZoneInfoByEmployee]', @ErrorMessage, @EmployeeID,0
		
	END CATCH  



END
