/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[sp_IsServiceMappedToTicketType]  
    @ServiceId VARCHAR(MAX) ,        
    @Projectid BIGINT        
AS         
BEGIN
BEGIN TRY   
	DECLARE @IsServiceMappedToTimeSheet BIT ;
	DECLARE @IsDebtEnabledServiceMap BIT ;
	SET NOCOUNT ON;   
	IF EXISTS (SELECT 1 from AVL.TK_MAP_TicketTypeServiceMapping (NOLOCK)  	   
    WHERE ProjectId = @Projectid and IsDeleted=0 and ServiceId IN(select * from dbo.Split(@ServiceId, ','))) 
     BEGIN 
			SET @IsServiceMappedToTimeSheet=1  ; 
	 END
     ELSE 
	 BEGIN
			SET @IsServiceMappedToTimeSheet=0 ; 
     END ; 
	 IF EXISTS (SELECT 1 FROM avl.MAS_ProjectDebtDetails WITH (NOLOCK)	   
     WHERE ProjectId = @Projectid and IsDeleted=0 AND ISNULL(DebtControlFlag,'N')='Y') 
     BEGIN 
		IF EXISTS (SELECT DISTINCT S.ServiceID,S.ServiceName,ProjectID FROM AVL.TK_PRJ_ProjectServiceActivityMapping PSAM 
		JOIN AVL.TK_MAS_ServiceActivityMapping SAM ON PSAM.ServiceMapID =SAM.ServiceMappingID
		JOIN AVL.TK_MAS_Service S ON S.ServiceID=SAM.ServiceID JOIN dbo.Split(@ServiceId, ',') K ON 
		K.Item=S.ServiceID AND S.ServiceID IN (3,11) WHERE ProjectID=@ProjectID
		AND PSAM.IsDeleted=0 AND SAM.IsDeleted=0)
			BEGIN
			SET @IsDebtEnabledServiceMap=1  ; 
			END
			ELSE
			BEGIN
			 SET @IsDebtEnabledServiceMap=0 ; 
			END
	END
	ELSE 
	BEGIN
		SET @IsDebtEnabledServiceMap=0 ; 
	END ; 

	 SELECT @IsServiceMappedToTimeSheet AS 'IsServiceMappedToTimeSheet' , @IsDebtEnabledServiceMap AS 'IsDebtEnabledServiceMap';
  
		SET NOCOUNT OFF;    
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage VARCHAR(MAX);

		SET @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[sp_IsServiceMappedToTicketType]', @ErrorMessage, 0,@Projectid

END CATCH

END
