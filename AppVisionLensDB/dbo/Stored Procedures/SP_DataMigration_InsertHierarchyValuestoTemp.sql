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
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DataMigration_InsertHierarchyValuestoTemp]
	(
	@HierarchyValues AS [dbo].[TVP_DataMigration_HierarchyValues] READONLY
	)
AS
BEGIN
	
	SET NOCOUNT ON;
TRUNCATE TABLE DataMigration_HierarchyTVPUpload
	INSERT INTO DataMigration_HierarchyTVPUpload
	SELECT 
[LobName],
[TrackName],
[APPGROUPNAME],
[APPLICATIONNAME],
[ESA_AccountID],
NULL
FROM @HierarchyValues


UPDATE T SET T.CustomerId=C.CustomerID
FROM DataMigration_HierarchyTVPUpload T JOIN AVL.Customer C
ON T.[ESA_AccountID]=C.ESA_AccountID 
   
END
