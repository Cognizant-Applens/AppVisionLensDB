/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[GetErrorLog]

 @ProjectID  VARCHAR(50), 

 @CustomerID INT, 

 @EmployeeID NVARCHAR(50) 

AS 

  BEGIN 

      BEGIN try 



          SET nocount ON; 



          BEGIN 

              SELECT TOP 7 pm.EsaProjectID AS ProjectID, 

                           TD.errorfilename       AS [FileName], 

                           TD.uploadendtime       AS UploadDate, 

                           TD.uploadmode, 

                           TD.[status], 

                           TD.TotalTicketCount AS UpdatedticketCount, 

                           TD.failedticketcount, 

                           TD.reuploadticketcount AS ReUploadedTicketCount 

              FROM   avl.ticketdumpuploadstatus (NOLOCK) AS TD

			  Inner Join AVL.MAS_ProjectMaster (NOLOCK) AS PM on pm.ProjectID = TD.ProjectID

              WHERE  TD.projectid = @ProjectID 

              ORDER  BY TD.uploadendtime DESC 

          END 



      END try 



      BEGIN catch 



          DECLARE @ErrorMessage VARCHAR(max); 



          SELECT @ErrorMessage = Error_message() 



          EXEC Avl_inserterror 

            '[dbo].[GetErrorLog] ', 

            @ErrorMessage, 

            @EmployeeID 



      END catch 
	  SET nocount OFF; 
  END
