/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetServiceProjectDetails]  --19100, 10, 8    
@ProjectID INT     
AS     
BEGIN       
 SET NOCOUNT ON;
 
 IF EXISTS(SELECT 1 from [AVL].[TK_PRJ_ProjectServiceActivityMapping] PPS INNER JOIN AVL.TK_MAS_ServiceActivityMapping 
 MSM ON MSM.ServiceMappingID = PPS.servicemapID WHERE PPS.ProjectID = @ProjectID and MSM.ServiceID NOT IN (59))
	SELECT 1 as Result;	
 ELSE 
	SELECT 0 AS Result;
	
 SET NOCOUNT OFF;    
END
