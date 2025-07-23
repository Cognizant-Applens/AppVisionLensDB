/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[MigrationForProjectAttributeBasedOnCloudService] 
      
AS
BEGIN
SET NOCOUNT ON;
Declare @Applicationcount int
Declare @AttributeValuecount int

CREATE table #TempProject(ID int identity(1,1),ProjectID int )

Insert INTO #TempProject  SELECT DISTINCT PAV.ProjectID
  FROM	 PP.ProjectAttributeValues  PAV 
 LEFT JOIN pp.ProjectProfilingTileProgress PPT ON PPT.ProjectID=PAV.ProjectID
 WHERE PPT.TileID=1 and PPT.TileProgressPercentage=100 AND PAV.AttributeID=1
 AND PAV.IsDeleted=0 and PPT.IsDeleted=0


DECLARE @countTemp  int =0
select @countTemp=count(ProjectID) from #TempProject

WHILE(@countTemp >0)
Begin
declare @Mincount  int 
set @Mincount =(Select top 1 ID from #TempProject ORDER by ID ASC)
declare @ProjectIDList int

SET @ProjectIDList = (select ProjectID FROM #TempProject where id=@Mincount )

    -- insert project attribute value based on Hosted environment in App Inventory 
	DECLARE @ProjectCloudMapping int=0

	SELECT @ProjectCloudMapping= COUNT(ProjectID) FROM pp.ProjectAttributeValues WHERE ProjectID=@ProjectIDList 
	and AttributeID =53

	DECLARE @AppProjMapCount INT

	SELECT  @AppProjMapCount = Count(ProjectApplicationMapID) FROM avl.APP_MAP_ApplicationProjectMapping where ProjectID = @ProjectIDList and IsDeleted=0


	IF (@ProjectCloudMapping =0 AND @AppProjMapCount>0)
	BEGIN
	insert into PP.ProjectAttributeValues VALUES(@ProjectIDList,291,53,0,'SYSTEM',GETDATE(),NULL,NULL)
	END

	   SET @Applicationcount = (SELECT count(IA.ApplicationID) FROM [AVL].[APP_MAS_InfrastructureApplication] IA
       JOIN AVL.APP_MAP_ApplicationProjectMapping APM ON IA.ApplicationID = APM.ApplicationID
       WHERE APM.IsDeleted=0 and IA.IsDeleted=0 and IA.HostedEnvironmentID  in (1,2,3) and APM.ProjectID = @ProjectIDList )

       SET @AttributeValuecount =(SELECT COUNT(ProjectID) FROM pp.ProjectAttributeValues where ProjectID=@ProjectIDList and AttributeID =53)



       IF(@Applicationcount >=1 and @AttributeValuecount = 1 )
       BEGIN
       UPDATE PP.ProjectAttributeValues SET AttributeValueID=290,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectIDList
	   And AttributeID=53 AND IsDeleted=0
       END

       ELSE IF(@Applicationcount =0 and @AttributeValuecount = 1)
       BEGIN
       UPDATE PP.ProjectAttributeValues SET AttributeValueID=291,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectIDList
       And AttributeID=53 AND IsDeleted=0
	   END


	   DELETE FROM #TempProject WHERE id=@Mincount
	    SET @countTemp = @countTemp -1;
END

DROP TABLE #TempProject		

 
END
