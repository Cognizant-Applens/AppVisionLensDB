/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[GetAppvisionHierachy]
@UserID int

as




Select BC.BusinessClusterName from AVL.APP_MAP_ApplicationUserMapping AUM join AVL.APP_MAS_ApplicationDetails AD

ON AUM.ApplicationID=AD.ApplicationID join AVL.BusinessClusterMapping BCM on BCM.BusinessClusterMapID=AD.SubBusinessClusterMapID


join AVL.BusinessCluster BC on bc.BusinessClusterID=BCM.BusinessClusterID

WHERE aum.UserID=@UserID
