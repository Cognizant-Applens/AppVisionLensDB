/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetProjectScopeALMKEDB]  
 @ESAProjectid nvarchar(50)  
AS  
BEGIN  
 SET NOCOUNT ON;  
 DECLARE @ProjectID BIGINT,@IsApplensAsALM INT,@IsApplensAsKEDB INT,@TilePercentage INT  
 SET @ProjectID=(select projectid from AVL.MAS_ProjectMaster where ESAprojectid=@ESAProjectid and isdeleted=0)  
    
 if(@ProjectID > 0)  
 BEGIN  
  select * into #temp from  
  (SELECT PAV.AttributeValueName As ScopeDetails FROM PP.ProjectAttributeValues (NOLOCK) AS PA  
  join  Mas.PPAttributeValues  as PAV on PAV.attributevalueid=PA.attributevalueid and PAV.Isdeleted=0  
  WHERE ProjectID =@ProjectID and PA.Attributeid =1 and PA.isdeleted=0)t  
  
  Set @TilePercentage =(Select Top 1 TileProgressPercentage from PP.ProjectProfilingTileProgress where Tileid=1 and Projectid=@ProjectID)  
  
  SET @IsApplensAsALM=(SELECT TOp 1 ALMTOOLID from [PP].[ScopeOfWork] WHERE ProjectID =@ProjectID AND isdeleted=0)    
    
  SET @IsApplensAsKEDB= (SELECT top 1 KEDBOWNEDID from PP.BestPractices where ProjectID =@ProjectID AND isdeleted=0)   
    
  select * from #temp   
  select  (select AttributevalueName from Mas.PPAttributeValues where Attributevalueid = @IsApplensAsALM) As IsApplensAsALM,  
  (select AttributevalueName from Mas.PPAttributeValues where Attributevalueid = @IsApplensAsKEDB) AS IsApplensAsKEDB,  
   @TilePercentage AS TilePercentage     
 END  
END
