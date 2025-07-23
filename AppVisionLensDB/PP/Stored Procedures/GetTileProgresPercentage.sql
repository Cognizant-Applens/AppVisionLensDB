/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [PP].[GetTileProgresPercentage]
(
@ProjectID int =NULL
)
AS
Begin
SET NOCOUNT ON
	BEGIN try 
		declare @CustomerId int
		declare @TotApplication int
		declare @MapApplication int
		declare @TotTower int
		declare @MapTower int
		declare @IsApp int
		declare @AppScopecount int
		declare @AppScope int
		declare @AttributevalueScope int
		declare @CusDetails table(TotApplication int,MapApplication int,TotTower int,MapTower int,IsApp int)
		set @CustomerId = (select CustomerID from avl.MAS_ProjectMaster WITH(NOLOCK) where ProjectID=@ProjectID)
		
		EXEC [dbo].[GetCompletionPercentage]  @CustomerId, @ProjectID --7097,10569 

		SET @TotApplication =(select  COUNT (DISTINCT AMA.ApplicationID) as TotApplication from avl.APP_MAS_ApplicationDetails as AMA WITH(NOLOCK) inner join AVL.BusinessClusterMapping  AS BCM on 
		AMA.SubBusinessClusterMapID= BCM.BusinessClusterMapID where BCM.CustomerID= @CustomerId and AMA.IsActive=1)

		SET @MapApplication =(SElect COUNT (DISTINCT ApplicationID) as MapApplication from avl.APP_MAP_ApplicationProjectMapping  WITH(NOLOCK) where ProjectID=@ProjectID and IsDeleted=0)

 
		SET @TotTower =(SELECT  COUNT (DISTINCT InfraTowerTransactionID) as TotTower FROM [AVL].[InfraTowerDetailsTransaction]  WITH(NOLOCK) WHERE CustomerID=@CustomerId  and IsDeleted=0)

		SET @MapTower=(select  COUNT (DISTINCT TowerProjMapId) as MapTower from avl.InfraTowerProjectMapping  WITH(NOLOCK) where ProjectID=@ProjectID and IsDeleted=0 And IsEnabled=1)

		--SET @IsApp=(select SupportTypeId from AVL.MAP_ProjectConfig where ProjectID=@ProjectID)

		SET @AppScopecount = (SELECT COUNT( DISTINCT AttributeValueID) FROM PP.ProjectAttributeValues  WITH(NOLOCK) WHERE ProjectID=@ProjectID AND AttributeID=1 and IsDeleted=0 )

	IF(@AppScopecount = 4)
		BEGIN

		SET @IsApp=3;--IF BOTH MAINTANANCE & CIS HAD BEEN SELECTED
		END
		ELSE IF (@AppScopecount = 1)
		BEGIN

					SELECT @IsApp = CASE 
                    WHEN  AttributeValueID = 2 THEN 1
				    WHEN  AttributeValueID = 3 THEN 2
					WHEN AttributeValueID = 1  THEN 1
					WHEN AttributeValueID = 4  THEN 1	
					END
					FROM PP.ProjectAttributeValues  WITH(NOLOCK)  WHERE ProjectID=@ProjectID and AttributeID=1   and IsDeleted=0  
		END		 

		ELSE IF (@AppScopecount = 2 OR @AppScopecount = 3 )
		BEGIN		
		
				IF EXISTS (SELECT TOP 1 1 FROM PP.ProjectAttributeValues WITH(NOLOCK)
                WHERE ProjectID=@ProjectID and AttributeID=1  
                and IsDeleted=0    and AttributeValueID  in (3))
                BEGIN
                    SET @IsApp=3
                END
                ELSE
                BEGIN
                    SET @IsApp=1
                END
					 
		END

		ELSE
		BEGIN
		SET @IsApp = 0 
		END


		

		INSERT INTO @CusDetails (TotApplication,MapApplication,TotTower,MapTower,IsApp) select @TotApplication,@MapApplication,@TotTower,@MapTower,@IsApp
		
		

	    Select TotApplication,MapApplication,TotTower,MapTower,IsApp from @CusDetails NOLOCK
	SET NOCOUNT OFF;
	END TRY
	BEGIN catch   
		DECLARE @ErrorMessage VARCHAR(max);   
  
		SELECT @ErrorMessage = Error_message()   
  
		EXEC Avl_inserterror   
		'[dbo].[GetCompletionPercentage] ',   
		@ErrorMessage,   
		0,   
		@CustomerId   
	END catch   
END
