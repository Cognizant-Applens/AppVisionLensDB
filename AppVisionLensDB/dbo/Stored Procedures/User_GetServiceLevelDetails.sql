/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--exec [dbo].[User_GetServiceLevelDetails]
CREATE PROCEDURE [dbo].[User_GetServiceLevelDetails]
AS
BEGIN
 select  distinct S.ServiceLevelID as ServiceLevelID,SM.ServiceLevelName  as ServiceLevelName
 from avl.TK_MAS_Service S join [AVL].[MAS_ServiceLevel]  SM on S.ServiceLevelID=SM.ServiceLevelID
 where isnull(S.IsDeleted,0)=0 and ISNULL(SM.IsDeleted,0)=0 and S.ServiceLevelID!=5
END
