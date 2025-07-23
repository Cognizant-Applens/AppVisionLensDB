/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
--[dbo].[AVL_GetTicketCategoryList] '471742',7

CREATE Proc [dbo].[AVL_GetTicketCategoryList]-- '627384',7

@EmployeeID nvarchar(max),

@CustomerID bigint=null

as

begin
SET NOCOUNT ON;


select ID,NonTicketedActivity from [AVL].[MAS_NonDeliveryActivity] (NOLOCK) where IsActive=1





CREATE TABLE #UserProjectDetails

    (

    SNO INT IDENTITY(1,1),

      ProjectID BigINT,

      UserID BigINT,

	  ProjectName nvarchar(max)



     )



;WITH MYCTE AS

      (

      SELECT LM.UserID,PM.ProjectID,PM.ProjectName FROM [AVL].[MAS_LoginMaster](NOLOCK) LM

         INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.ProjectID=LM.ProjectID

          WHERE LM.EmployeeID = @EmployeeID and PM.CustomerID=@CustomerID and LM.IsDeleted=0

      )

      

            INSERT INTO #UserProjectDetails

            SELECT ProjectID,UserID,ProjectName

            FROM    MYCTE 

            OPTION (MAXRECURSION 0)



                     Select UserID,ProjectID,ProjectName FROM #UserProjectDetails (NOLOCK)



                     DROP TABLE #UserProjectDetails



end











 --SELECT *

 ----LM.UserID,PM.CustomerID,PM.ProjectID,PM.ProjectName 

 --FROM [AVL].[MAS_LoginMaster](NOLOCK) LM

 --        --INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.ProjectID=LM.ProjectID

 --         WHERE LM.EmployeeID = '627384' 

		  --and PM.CustomerID=@CustomerID





		  --SELECT * FROM AVL.MAS_LoginMaster WHERE EmployeeID='627384'





		  --update AVL.MAS_LoginMaster set IsDeleted=1 WHERE EmployeeID='627384' AND UserID=2461









		  --select * from AVL.TM_TRN_TimesheetDetail
