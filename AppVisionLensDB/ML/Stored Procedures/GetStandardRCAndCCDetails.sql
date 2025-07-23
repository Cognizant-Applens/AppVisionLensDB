/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================= 
-- Author:    683989 
-- Create date: 06/02/2020
-- Description:   SP for get all Standard CC and RC Values
-- ML.GetStandardRCAndCCDetails 
-- =============================================  
CREATE PROCEDURE ML.GetStandardRCAndCCDetails
AS
BEGIN
	DECLARE @IsDeleted INT = 0
	SET NOCOUNT ON

	SELECT ClusterID,ClusterName,CategoryID from mas.Cluster(nolock)
	where IsDeleted = 0

	SET NOCOUNT OFF
END
