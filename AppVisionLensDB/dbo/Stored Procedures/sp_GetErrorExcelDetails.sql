/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[sp_GetErrorExcelDetails] @pid INT 
AS 
  BEGIN 
      BEGIN try 
          SET nocount ON; 

          SELECT [ticket id] AS ID, 
                 remarks
          FROM   [AVL].[tk_importticketdumpdetails_nullvalue] 
          WHERE  projectid = @pid 
      END try 

      BEGIN catch 
          DECLARE @ErrorMessage VARCHAR(max); 

          SELECT @ErrorMessage = Error_message() 

          EXEC Avl_inserterror 
            '[dbo].[sp_GetErrorExcelDetails] ', 
            @ErrorMessage, 
            0 
      END catch 
  END
