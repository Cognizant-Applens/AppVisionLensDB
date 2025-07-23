/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [dbo].[GetEffortUploadConfigDetails]
@ProjectID BIGINT,
@EmployeeId nvarchar(100),
@CustomerId nvarchar(100)
AS

BEGIN
BEGIN try 


           SELECT CASE WHEN EffortUploadType='A' THEN SharePathName ELSE '' END AS SharePathName ,EffortUploadType,IsMailEnabled 
		   FROM AVL.EffortUploadConfiguration where ProjectID=@ProjectID and IsActive=1

END try 



      BEGIN catch 



          DECLARE @ErrorMessage VARCHAR(max); 



          SELECT @ErrorMessage = Error_message() 



          EXEC Avl_inserterror 

            '[dbo].[GetEffortUploadConfigDetails] ', 

            @ErrorMessage, 

            '1' 



      END catch 


END
