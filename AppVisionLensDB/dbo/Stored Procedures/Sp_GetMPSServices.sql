/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Sp_GetMPSServices] --35606
	-- Add the parameters for the stored procedure here
	 @ProjectID INT =0 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT  SAM.ServiceName,SAM.ActivityName,CASE WHEN ISNULL(PSAM.IsHidden,0) = 0 THEN 'Active' ELSE 'Inactive' end  AS Isdeleted FROM AVL.TK_MAS_ServiceActivityMapping SAM
	INNER JOIN avl.TK_PRJ_ProjectServiceActivityMapping PSAM ON  PSAM.ServiceMapID = SAM.ServiceMappingID
	WHERE ProjectID = @ProjectID AND PSAM.IsDeleted = 0 AND SAM.ServiceTypeID IN (4) AND PSAM.IsMainspringData='Y'
END
