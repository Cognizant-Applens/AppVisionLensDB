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
-- author:	Shankar Ganesh V	
-- create date: 06/08/2020
-- Modified by : 
-- Modified For: 
-- description: To check whether the project configuration is completed   or not
-- =============================================

-- EXEC [dbo].[CheckProjectConfiguration] 
CREATE procedure [dbo].[CheckProjectConfiguration] --10569
(
@ProjectId bigint
)
as 
  begin
begin try


--To get Adpaters Complete Percentage -- Start
DECLARE @ShowALMConfig BIT =0
DECLARE @ShowITSMConfig BIT=0
DECLARE @ALMPerc int=0
DECLARE @ITSMPerc int=0
DECLARE @TotMPerc int =0
DECLARE @IsApplens int =0
DECLARE @TileId int=5

select @IsApplens = IsApplensAsALM from pp.ScopeOfWork where ProjectID=@ProjectId

if(@IsApplens  =0)
BEGIN
/* AttributeID =1 = ProjectScope*/
SELECT PAV.AttributeValueID as 'AttributeValueID', ppav.AttributeValueName as 'AttributeValueName'
INTO #ScopeDetails
FROM PP.ProjectAttributeValues PAV
JOIN MAS.PPAttributeValues ppav on pav.AttributeID=ppav.AttributeID 
and PAV.AttributeValueID=ppav.AttributeValueID and ppav.IsDeleted=0 and ppav.AttributeID=1
WHERE PAV.AttributeID=1 and PAV.ProjectID=@ProjectId AND PAV.IsDeleted=0

IF EXISTS ( SELECT TOP 1 AttributeValueID FROM #ScopeDetails)
BEGIN

IF EXISTS(SELECT TOP 1 AttributeValueID FROM #ScopeDetails WHERE AttributeValueID in (1,4))
BEGIN 
SET @ShowALMConfig=1

END
IF EXISTS(SELECT TOP 1 AttributeValueID FROM #ScopeDetails WHERE AttributeValueID in (2,3))
BEGIN
SET @ShowITSMConfig=1
END

END

If (@ShowALMConfig=1)
BEGIN
 IF EXISTS (SELECT top 1  TileProgressPercentage  FROM PP.ProjectProfilingTileProgress WHERE 
			 IsDeleted=0 AND TileID=@TileId AND ProjectID=@ProjectId)
  BEGIN

	SET @ALMPerc=(SELECT top 1   TileProgressPercentage  FROM PP.ProjectProfilingTileProgress WHERE 
			 IsDeleted=0 AND TileID=@TileId AND ProjectID=@ProjectId)
  END
  ELSE
  BEGIN
	SET @ALMPerc=0
  END
SET @TotMPerc =@ALMPerc
END

IF (@ShowITSMConfig=1)
BEGIN 

 		SET @ITSMPerc = dbo.GetItsmPercentage(@ProjectID)
		SET @ITSMPerc = CASE WHEN Isnull(@ITSMPerc, CAST(0 AS INT))>100 THEN 100 ELSE  Isnull(@ITSMPerc, CAST(0 AS INT)) END

SET @TotMPerc +=@ITSMPerc

END

IF (@ShowITSMConfig=1 AND @ShowALMConfig=1)
BEGIN
SET @TotMPerc= @TotMPerc/2
END
END
ELSE
BEGIN
SET @TotMPerc=100
END
--To get Adpaters Complete Percentage -- End

 IF EXISTS (
select ProjectID from  pp.ProjectProfilingTileProgress where   TileProgressPercentage=100 and TileID=1 and ProjectID=@ProjectId
and ProjectID IN (select ProjectID from  pp.ProjectProfilingTileProgress where  TileID =4 and  TileProgressPercentage=100 and ProjectID=@ProjectId)
and  @TotMPerc=100)
BEGIN 

select 3 as ProjectConfiguration --Both Project Details , Service Catalog & ALM completed 100%

END
 ELSE IF EXISTS (
select ProjectID from  pp.ProjectProfilingTileProgress where   TileProgressPercentage=100 and TileID=1 and ProjectID=@ProjectId
and ProjectID IN (select ProjectID from  pp.ProjectProfilingTileProgress where  TileID =4 and  TileProgressPercentage=100 and ProjectID=@ProjectId))
BEGIN 

select 2 as ProjectConfiguration --Both Project Details & Service Catalog completed 100%

END

ELSE IF EXISTS(Select ProjectID from  pp.ProjectProfilingTileProgress where ProjectID=@ProjectId and TileProgressPercentage=100 and TileID=1)
 BEGIN 
 select 1 ProjectConfiguration--Only Project Details completed 100%
 END

ELSE
 BEGIN 
 select 0 ProjectConfiguration--Incomplete
 END
			
end try
begin catch

	DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'dbo.CheckProjectConfiguration',@ErrorMessage,0,@ProjectId
			
end catch
end
