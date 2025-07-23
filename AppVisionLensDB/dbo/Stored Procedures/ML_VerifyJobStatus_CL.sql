/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_VerifyJobStatus_CL]
(
@ProjectID NVARCHAR(200)
)
AS 
DECLARE  @REC_COUNT INT = 0,
@HasError INT = 0
IF EXISTS(SELECT TOP 1 * FROM AVL.MAS_ProjectDebtDetails WHERE ProjectID=@ProjectID and IsMLSignOff='1' and IsDeleted=0 and IsAutoClassified='Y')
BEGIN
SET @REC_COUNT = (SELECT count(*) FROM AVL.CL_ProjectJobDetails WHERE PROJECTID=@ProjectID )
SET @HasError = (SELECT count(*) FROM AVL.CL_ProjectJobDetails WHERE PROJECTID=@ProjectID AND HasError = 0 AND StatusForJob = 1)

IF @REC_COUNT = 1
BEGIN
SELECT TOP 1 Jobdate as JobDate,'False' AS StatusForJob,'1' As isCLEnabled FROM AVL.CL_ProjectJobDetails WHERE PROJECTID=@ProjectID  AND IsDeleted = 0
  ORDER BY CREATEDDATE DESC

END
ELSE IF(@HasError = 0)
BEGIN
SELECT TOP 1 Jobdate as JobDate,'False' AS StatusForJob,'1' As isCLEnabled FROM AVL.CL_ProjectJobDetails WHERE PROJECTID=@ProjectID AND IsDeleted = 0
  ORDER BY CREATEDDATE DESC

END

ELSE 
BEGIN
SELECT TOP 1 Jobdate as JobDate,'True' AS StatusForJob ,'1' As isCLEnabled FROM AVL.CL_ProjectJobDetails WHERE PROJECTID=@ProjectID AND IsDeleted = 0
  ORDER BY CREATEDDATE DESC

END
END
ELSE
BEGIN
SELECT NULL AS JobDate,'False' As StatusForJob , '0' As isCLEnabled;
END
