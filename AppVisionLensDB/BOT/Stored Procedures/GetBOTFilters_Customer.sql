/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  

CREATE PROCEDURE [BOT].[GetBOTFilters_Customer]  
 @Flag INT,  
 @ID INT  
AS  
BEGIN  
   
 SET NOCOUNT ON;  
  
 IF @Flag = 1 --TargetApplication  
 BEGIN  
 SELECT Id ID,TargetApplicationName [Name] FROM BOT.TargetApplication where IsDeleted=0 order by TargetApplicationName asc  
 END  
 IF @Flag = 2 --Technology  
 BEGIN  
 SELECT PrimaryTechnologyID ID,PrimaryTechnologyName [Name]  FROM avl.APP_MAS_PrimaryTechnology where IsDeleted=0 order by PrimaryTechnologyName asc   
 END  
 IF @Flag = 3 --Category  
 BEGIN  
 SELECT Id ID,CategoryName [Name]  FROM BOT.Category where IsDeleted=0 order by CategoryName asc  
 END  
 IF @Flag = 4 --Nature  
 BEGIN  
 SELECT Id ID,Nature [Name]  FROM BOT.Nature where IsDeleted=0 order by Nature asc  
 END  
 IF @Flag = 5 --BOTType  
 BEGIN  
 SELECT Id ID ,Type [Name]  FROM BOT.BOTType where IsDeleted=0 order by Type asc  
 END  
 IF @Flag = 6 --Reusability  
 BEGIN  
 SELECT Id ID,Reusability [Name]   FROM BOT.Reusability where IsDeleted=0  
 END  
 IF @Flag = 7 -- Buisness PRocess  
  BEGIN  
   SELECT '' AS ID, '' AS [Name] 

  END  
 IF @Flag = 8 -- SUB Buisness PRocess  
  BEGIN  
  --@Id --BUISNESSPROCESSID  
   SELECT '' AS ID, '' AS [Name]
  
  END  
 IF @Flag = 9 --Reusability  
  BEGIN  
   SELECT ServiceID AS ID,  
   ServiceName AS [Name]  
   FROM avl.TK_MAS_Service WHERE IsDeleted=0 AND ServiceID in (7,1,38,5,6,2,8,11,10,3,15,13,14) ORDER BY ServiceName ASC   
  END  
END
