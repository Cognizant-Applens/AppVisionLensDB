/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
 
CREATE Procedure [AVL].[Effort_GetTimeZoneInformationByCustomer]  
@CustomerID bigint,  
@EmployeeID NVARCHAR(50)=null  
AS  
BEGIN 
SET NOCOUNT ON;
 BEGIN TRY  
  
  CREATE TABLE #UserTimeZoneIDs  
  (  
   UserTimeZoneId INT NULL,  
   ProjectID BIGINT NULL  
  )  
  CREATE TABLE #ProjectTimeZoneIDs  
  (  
   ProjectTimeZoneId INT NULL  
  )  
  DECLARE @TimeZoneCount INT;  
  DECLARE @UserTimeZoneID NVARCHAR(10);  
  DECLARE @UserTimeZoneName NVARCHAR(1000);  
  DECLARE @ProjectTimeZoneID NVARCHAR(10);  
  DECLARE @ProjectTimeZoneName NVARCHAR(1000);  
  DECLARE @TimeSheetDisplayMessage NVARCHAR(MAX);  
  
  INSERT INTO #UserTimeZoneIDs  
  SELECT DISTINCT TimeZoneId,ProjectID FROM AVL.MAS_LoginMaster(NOLOCK)   
  WHERE CustomerID=@CustomerID AND EmployeeID=@EmployeeID   
  --AND TimeZoneId IS NOT NULL  
  AND IsDeleted=0  
  --SELECT * FROM #UserTimeZoneIDs  
  INSERT INTO #ProjectTimeZoneIDs  
  SELECT DISTINCT TimeZoneId FROM AVL.MAP_ProjectConfig (NOLOCK)   
  WHERE ProjectID IN(SELECT ProjectID FROM #UserTimeZoneIDs (NOLOCK)) AND TimeZoneId IS NOT NULL  
  
  --SELECT * FROM #ProjectTimeZoneIDs  
  SET @TimeZoneCount=(SELECT COUNT(*) FROM #UserTimeZoneIDs (NOLOCK) WHERE UserTimeZoneId IS NOT NULL)  
  --SELECT @TimeZoneCount  
  IF @TimeZoneCount =1  
  BEGIN  
  --SELECT * FROM #UserTimeZoneIDs  
   SET @UserTimeZoneID=(SELECT UserTimeZoneId FROM #UserTimeZoneIDs (NOLOCK) WHERE UserTimeZoneId IS NOT NULL)  
  END  
  ELSE IF @TimeZoneCount >1  
  BEGIN  
   SET @UserTimeZoneID=(SELECT TOP 1 UserTimeZoneId FROM #UserTimeZoneIDs (NOLOCK) WHERE UserTimeZoneId IS NOT NULL)  
  END  
  ELSE   
  BEGIN  
   SET @TimeSheetDisplayMessage='Timezone is not configured.'  
      
  END  
  
  SET @ProjectTimeZoneID=(SELECT TOP 1 ProjectTimeZoneId FROM #ProjectTimeZoneIDs (NOLOCK))  
  
  IF @ProjectTimeZoneID IS NULL  
  BEGIN  
   SET @ProjectTimeZoneID=32  
  END  
  
  SET @UserTimeZoneName=(SELECT TZoneName FROM AVL.MAS_TimeZoneMaster (NOLOCK) WHERE TimeZoneID=@UserTimeZoneID)  
  SET @ProjectTimeZoneName=(SELECT TZoneName FROM AVL.MAS_TimeZoneMaster (NOLOCK) WHERE TimeZoneID=@ProjectTimeZoneID)  
  
  DECLARE @ClientUserIDAvailability INT;  
  SET @ClientUserIDAvailability=(SELECT COUNT(*) FROM AVL.MAS_LoginMaster(NOLOCK)  
          WHERE CustomerID=@CustomerID AND EmployeeID=@EmployeeID  
          AND (ClientUserID ='' OR ClientUserID ='0' OR ClientUserID IS NULL))  
  PRINT @ClientUserIDAvailability  
  --SELECT @ClientUserIDAvailability AS ClientUserIDAvailability  
  IF @ClientUserIDAvailability >=1  
  BEGIN  
  
   SET @TimeSheetDisplayMessage=CONCAT(@TimeSheetDisplayMessage, 'External login ID is not configured.')  
  END  
  IF LEN(@TimeSheetDisplayMessage) >0  
  BEGIN  
  PRINT @TimeSheetDisplayMessage  
   SET @TimeSheetDisplayMessage=CONCAT(@TimeSheetDisplayMessage ,'Please contact Admin.')  
  
  END  
  
  SELECT @UserTimeZoneID AS UserTimeZoneId,@UserTimeZoneName AS UserTimeZoneName,  
  @ProjectTimeZoneID AS ProjectTimeZoneId,@ProjectTimeZoneName AS ProjectTimeZoneName,@TimeSheetDisplayMessage as TimeSheetDisplayMessage  
  
 END TRY    
  
 BEGIN CATCH    
  DECLARE @ErrorMessage VARCHAR(MAX);  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[Effort_GetGetTimeZoneInformationByCustomer]', @ErrorMessage, @EmployeeID,0  
 END CATCH    
 SET NOCOUNT OFF; 
END
