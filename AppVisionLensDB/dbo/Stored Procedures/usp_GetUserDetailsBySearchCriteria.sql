/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


--=========================================
-- Program Name:[usp_GetUserDetailsBySearchCriteria]
-- Author: 
-- Description: To Get user Details By Search Criteria
--Created Date:
--Modified Date Modified By version Description: Dinesh K on 03-Apr for CAST
--==========================================
CREATE PROCEDURE [dbo].[usp_GetUserDetailsBySearchCriteria]                                      

	 @AssociateIdName CHAR(11)

AS     

   BEGIN                                       

        SET NOCOUNT ON;                                 

        SELECT         

		   U.AssociateId,

		   AM.Associate_Name,   

		   U.UserRoleId,              

           R.UserRoleName,

           U.IsDeleted,

           U.CreatedBy,

           U.CreatedDate,

           U.ModifiedBy,

           U.ModifiedDate

                

    FROM        

     dbo.UserMaster U(NOLOCK)  

    INNER JOIN dbo.UserRole R On U.UserRoleId = R.userRoleId    

    INNER JOIN dbo.AssociateMaster AM  On U.AssociateId = AM.Associate_ID

    WHERE U.AssociateId LIKE @AssociateIdName + '%' OR AM.Associate_Name LIKE @AssociateIdName + '%'  

    ORDER BY U.ModifiedDate DESC  

      

      SET NOCOUNT OFF;   

 END
