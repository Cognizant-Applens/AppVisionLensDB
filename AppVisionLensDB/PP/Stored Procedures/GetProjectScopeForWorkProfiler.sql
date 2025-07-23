/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].GetProjectScopeForWorkProfiler 
(
@ProjectID BIGINT 
)
AS
BEGIN
SET NOCOUNT ON

DECLARE @IsCount int=0  
DECLARE @IsMaintenance int=0  

SET @IsCount=(SELECT COUNT(PAV.AttributeValueID) FROM PP.ProjectAttributeValues PAV
JOIN MAS.PPAttributeValues PV on PAV.AttributeValueID = PV.AttributeValueID 
WHERE PAV.ProjectID=@ProjectID AND PAV.IsDeleted=0 AND PAV.AttributeID=1 
AND PAV.AttributeValueID in(2))

If(@IsCount !=0)
BEGIN
   SET @IsMaintenance =1;
END

IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results  
  
  CREATE TABLE #Results  
  (  
  IsMaintenance BIGINT NULL)  
  insert into #Results  select @IsMaintenance   
  select IsMaintenance from #Results  

END
