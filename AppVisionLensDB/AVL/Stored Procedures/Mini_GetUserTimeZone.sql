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
-- Author:          Hemanth 
-- Create date:      23 Nov 2018
-- Description:    get user time zone
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- EXEC [AVL].[Mini_GetUserTimeZone] '471742'
-- ============================================================================ 
--[AVL].[Mini_GetUserTimeZone] '471742'
CREATE PROC [AVL].[Mini_GetUserTimeZone]
@EmployeeID VARCHAR(50) 
as
BEGIN
BEGIN TRY
SELECT UserID,ProjectID,EmployeeID,CustomerID,TimeZoneId INTO #MAS_LoginMaster FROM [AVL].[MAS_LoginMaster](NOLOCK) 
       WHERE EmployeeID = @EmployeeID  AND IsDeleted=0 AND ISNULL(ISMINICONFIGURED,1)=1
CREATE TABLE #UserProjectDetails
       (
              SNO INT IDENTITY(1,1),
              UserID BigINT,
              ProjectID BigINT,
              CustomerID BigINT,
              UserTimeZoneId INT NULL,
              UserTimeZoneName NVARCHAR(100)
       )
       INSERT INTO #UserProjectDetails
       SELECT UserID,ProjectID,CustomerID,ISNULL(LM.TimeZoneID,32) AS TimeZoneID,
       TM.TZoneName AS UserTimeZoneName  FROM #MAS_LoginMaster LM
       LEFT JOIN AVL.MAS_TimeZoneMaster TM ON ISNULL(LM.TimeZoneId,32) = TM.TimeZoneID
       WHERE EmployeeID = @EmployeeID 

              DECLARE @Accesslevel INT;
       SET @Accesslevel=( SELECT COUNT(*) FROM [AVL].[MAS_LoginMaster](NOLOCK) 
       WHERE EmployeeID = @EmployeeID  AND IsDeleted=0 )

       DECLARE @TimeZoneName NVARCHAR(250);
       SET @TimeZoneName=(SELECT TOP 1  UserTimeZoneName FROM #UserProjectDetails
                                         WHERE UserTimeZoneName IS NOT NULL AND UserTimeZoneName != '')
       SELECT @TimeZoneName AS UserTimeZoneName,ISNULL(@Accesslevel,0) AS Accesslevel
              END TRY  

BEGIN CATCH  
              DECLARE @ErrorMessage VARCHAR(MAX);
              SELECT @ErrorMessage = ERROR_MESSAGE()
              EXEC AVL_InsertError '[AVL].[Mini_GetUserTimeZone]', @ErrorMessage, @EmployeeID,0
END CATCH  
END
