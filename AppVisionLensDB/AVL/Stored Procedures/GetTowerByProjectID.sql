/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE proc [AVL].[GetTowerByProjectID]
@ProjectID BIGINT,
@CustomerID BIGINT
AS
BEGIN

BEGIN TRY
Declare @SupportTypeId bigint
set @SupportTypeId=(SELECT SupportTypeId from AVL.MAP_ProjectConfig where ProjectID=@ProjectID)
SELECT distinct TD.InfraTowerTransactionID AS TowerID,TD.TowerName FROM AVL.InfraTowerProjectMapping IT 


JOIN AVL.InfraTowerDetailsTransaction TD 
ON IT.TowerID=TD.InfraTowerTransactionID AND IT.IsDeleted=0 AND TD.IsDeleted=0
 AND IT.IsEnabled=1  
 WHERE
  TD.CustomerID=@CustomerID AND IT.ProjectID=@ProjectID
  AND @SupportTypeid<>1
  END TRY

  BEGIN CATCH

  END CATCH
END
