/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[TicketUploadSupportTypeMandateColumns]
@ProjectID VARCHAR(30),
@Mode VARCHAR(15)=NULL
AS
BEGIN
BEGIN TRY

DECLARE @ProjectSupportType VARCHAR(10)=NULL
DECLARE @Result INT=0
DECLARE @IsCount INT=0

SET @IsCount= CASE WHEN  LTRIM(RTRIM(@Mode))='ADMINCONSOLE' THEN (SELECT COUNT(SSIScmID) FROM AVL.ITSM_PRJ_SSISColumnMapping WHERE ProjectID=@ProjectID AND IsDeleted = 0) 
			  ELSE 1 
			  END
SET @ProjectSupportType = (SELECT SupportTypeId FROM AVL.MAP_ProjectConfig WHERE  ProjectID=@ProjectID)


IF(@IsCount>=1)
BEGIN

IF(@ProjectSupportType = 1)
BEGIN 

SET @Result = (SELECT COUNT(SSIScmID) FROM AVL.ITSM_PRJ_SSISColumnMapping WHERE ProjectID=@ProjectID AND IsDeleted=0  AND ServiceDartColumn IN ('External Login ID','Assignment Group'))
	
IF(@Result>=1)
BEGIN 
SET @Result = (SELECT CASE WHEN (Count(SSIScmID)=1) THEN 1 ELSE 0 END FROM AVL.ITSM_PRJ_SSISColumnMapping 
			  WHERE ProjectID=@ProjectID AND IsDeleted=0 AND ServiceDartColumn IN ('Application'))
END
	
END
ELSE IF (@ProjectSupportType = 2)
BEGIN 
	
SET @Result = (SELECT CASE WHEN Count(SSIScmID)=3 THEN 1 ELSE 0 END FROM AVL.ITSM_PRJ_SSISColumnMapping 
			   WHERE ProjectID=@ProjectID AND IsDeleted=0 AND 
			   ServiceDartColumn IN ('Tower','Ticket Description','Assignment Group'))
	
END
ELSE IF(@ProjectSupportType = 3)
BEGIN
		
SET @Result = (SELECT CASE WHEN Count(SSIScmID)=4 THEN 1 ELSE 0 END FROM AVL.ITSM_PRJ_SSISColumnMapping 
			  WHERE ProjectID=@ProjectID AND IsDeleted=0 AND 
			  ServiceDartColumn IN ('Application','Assignment Group','Tower','Ticket Description'))
END
ELSE
BEGIN 

SET @Result	=-1
END
END

ELSE
BEGIN
SET  @Result=-1
END

SELECT @Result AS Valid

END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[TicketUploadSupportTypeMandateColumns]', @ErrorMessage, 0,0
END CATCH
END
