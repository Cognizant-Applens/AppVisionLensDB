/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [AVL].[SaveInfraProjectMapping]
@ProjectMappingInfraParam AS AVL.TVP_ProjectMappingInfraParam READONLY,
@ProjectID BIGINT
AS
BEGIN


BEGIN TRY

declare @UserID NVARCHAR(MAX)

SET @UserID=(SELECT TOP 1 UserID FROM @ProjectMappingInfraParam)
Update IPT set IPT.IsEnabled=TVP.IsEnabled,
IPT.ModifiedBy=TVP.UserID,
IPT.ModifiedDate=GETDATE()

 FROM
AVL.InfraTowerProjectMapping IPT JOIN 
@ProjectMappingInfraParam TVP ON TVP.ProjectID=IPT.ProjectID
AND IPT.TowerID=TVP.TowerID

IF EXISTS(SELECT TOWERID FROM @ProjectMappingInfraParam WHERE PROJECTID=@ProjectID)
BEGIN
Update IPT set IPT.IsEnabled=0,
IPT.ModifiedBy=@UserID,
IPT.ModifiedDate=GETDATE()
FROM
 AVL.InfraTowerProjectMapping IPT 

where not EXISTS (SELECT * from @ProjectMappingInfraParam TVP WHERE TVP.ProjectID=IPT.ProjectID
AND IPT.TowerID=TVP.TowerID)
and IPT.ProjectID=@ProjectID
END
ELSE
BEGIN
Update IPT set IPT.IsEnabled=0,
IPT.ModifiedBy=@UserID,
IPT.ModifiedDate=GETDATE()
FROM
 AVL.InfraTowerProjectMapping IPT
 WHERE IPT.ProjectID=@ProjectID
END

INSERT INTO AVL.InfraTowerProjectMapping 
(TowerID,ProjectID,IsDeleted,IsEnabled,CreatedBy,CreatedDate)
SELECT TVP.TowerID,TVP.ProjectID,0,TVP.IsEnabled,TVP.UserID,GETDATE()  FROM @ProjectMappingInfraParam TVP LEFT JOIN 
AVL.InfraTowerProjectMapping IPT ON
TVP.ProjectID=IPT.ProjectID
AND IPT.TowerID=TVP.TowerID
WHERE IPT.TowerProjMapId IS NULL

END TRY

BEGIN CATCH

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		  
		EXEC AVL_InsertError '[AVL].[SaveInfraProjectMapping]', @ErrorMessage, 0, 0 
END CATCH

END
