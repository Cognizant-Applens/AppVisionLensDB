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
-- Description:   get non delievry data
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- [AVL].[Mini_GetNonDeliveryActivityByEmployeeID] '627384',7
--[AVL].[Mini_GetNonDeliveryActivityByEmployeeID] '471742'
-- ============================================================================ 
CREATE PROCEDURE [AVL].[Mini_GetNonDeliveryActivityByEmployeeID]-- '627384',7

@EmployeeID nvarchar(100)

as

begin

BEGIN TRY
BEGIN TRAN

select ID,NonTicketedActivity from [AVL].[MAS_NonDeliveryActivity]  where IsActive=1





CREATE TABLE #UserProjectDetails

    (

    SNO INT IDENTITY(1,1),

      ProjectID BigINT,

      UserID BigINT,

         ProjectName nvarchar(max),
         UserTimeZoneId INT NULL,
       UserTimeZoneName NVARCHAR(100)



     )



;WITH MYCTE AS

      (

      SELECT LM.UserID,PM.ProjectID,PM.ProjectName,ISNULL(LM.TimeZoneID,32) AS TimeZoneID,
       TM.TZoneName AS UserTimeZoneName
       FROM [AVL].[MAS_LoginMaster](NOLOCK) LM

         INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.ProjectID=LM.ProjectID
              LEFT JOIN AVL.MAS_TimeZoneMaster TM ON ISNULL(LM.TimeZoneId,32) = TM.TimeZoneID
          WHERE LM.EmployeeID = @EmployeeID 
                and ISNULL(LM.IsDeleted,0)=0 AND ISNULL(LM.IsMiniConfigured,1)=1

      )

      

            INSERT INTO #UserProjectDetails

            SELECT ProjectID,UserID,ProjectName,TimeZoneID,UserTimeZoneName

            FROM    MYCTE 

            OPTION (MAXRECURSION 0)
                     UPDATE #UserProjectDetails SET UserTimeZoneId=NULL WHERE UserTimeZoneId=0

                     Select DISTINCT  UserID,ProjectID,ProjectName FROM #UserProjectDetails
                                  ORDER BY ProjectName ASC

       DECLARE @TimeZoneName NVARCHAR(250);
       SET @TimeZoneName=(SELECT TOP 1  UserTimeZoneName FROM #UserProjectDetails where UserTimeZoneName is not null)
       SELECT @TimeZoneName AS UserTimeZoneName


                     DROP TABLE #UserProjectDetails
COMMIT TRAN
END TRY  
BEGIN CATCH  

              DECLARE @ErrorMessage VARCHAR(MAX);

              SELECT @ErrorMessage = ERROR_MESSAGE()
              ROLLBACK TRAN
              --INSERT Error    
              EXEC AVL_InsertError '[AVL].[Mini_GetNonDeliveryActivityByEmployeeID]', @ErrorMessage, 0 ,0
              
       END CATCH  


end
