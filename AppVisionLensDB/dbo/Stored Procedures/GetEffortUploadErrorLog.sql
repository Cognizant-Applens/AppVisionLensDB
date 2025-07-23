/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE  PROC [dbo].[GetEffortUploadErrorLog]


@ProjectID BIGINT
AS
BEGIN
SET NOCOUNT ON;
 BEGIN try 


 SELECT TOP 7 PM.EsaProjectID AS 'ProjectID',EU.ErrorFileName,EU.TotalRecords,EU.FailedCount,EU.UploadedEndDate,EU.Status,EU.EffortUploadDumpName 
 FROM AVL.EffortUploadErrorLog EU (NOLOCK) JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
 ON PM.ProjectID=EU.PROJECTID AND PM.IsDeleted=0 AND PM.ProjectID=@ProjectID
 ORDER BY EU.UploadedEndDate DESC


 END try 



      BEGIN catch 



          DECLARE @ErrorMessage VARCHAR(max); 



          SELECT @ErrorMessage = Error_message() 



          EXEC Avl_inserterror 

            '[dbo].[GetEffortUploadErrorLog] ', 

            @ErrorMessage, 

            '1' 



      END catch 
SET NOCOUNT OFF;
END
