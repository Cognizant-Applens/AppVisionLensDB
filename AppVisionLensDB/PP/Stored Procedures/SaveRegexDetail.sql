/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [PP].[SaveRegexDetail]
@ProjectID BIGINT,
@UserID NVARCHAR(20),
@ConfigTypeID INT,
@Regexfieldid INT,
@EffectiveStartDate Datetime= null,
@EffectiveEndDate Datetime= null,
@DynamicJSONData NVARCHAR(MAX)
 AS
 BEGIN
	BEGIN TRY  
	   BEGIN TRAN
		SET NOCOUNT ON;
			
			DECLARE @Result BIT;
			DECLARE @RegexConfigID BIGINT;
			DECLARE @StaticConfigTypeID INT;
			DECLARE @DynamicConfigTypeID INT;
			DECLARE @ISDELETED INT;
			

			SELECT @StaticConfigTypeID=ID FROM [MAS].[Regex_Config] With (Nolock) WHERE  IsDeleted=0 AND Category='ConfigType' AND [Key]='Static'
			SELECT @DynamicConfigTypeID=ID FROM [MAS].[Regex_Config] With (Nolock) WHERE IsDeleted=0 AND Category='ConfigType' AND [Key]='Dynamic' 


			CREATE TABLE #TEMPDYNAMICDETAILS
			(
				ID			INT,
				KEYWORDID	INT,
				CONDITIONID INT,
				KEYVALUES	NVARCHAR(max)

			)

		IF NOT EXISTS(SELECT Top 1 RD.ConfigTypeID FROM [AVL].[PRJ_RegexConfiguration] RD WITH (NOLOCK)
			WHERE RD.ProjectID=@ProjectID and RD.ConfigTypeID=@ConfigTypeID) and (@ConfigTypeID!=0)
			BEGIN
			
					INSERT INTO [AVL].[PRJ_RegexConfiguration](
					 [ProjectID] 				
					,[ConfigTypeID] 
					,[EffectiveStartDate] 
					,[EffectiveEndDate]
					,RegexFieldID
					,[IsDeleted] 
					,[CreatedBy] 
					,[CreatedDate] 
					)
					VALUES ( 
					 @ProjectID
					,@ConfigTypeID     
					,@EffectiveStartDate
					,@EffectiveEndDate 
					,@Regexfieldid
					,0
					,@UserID
					,getdate()
					)
			END
			
		IF EXISTS(SELECT Top 1 RD.ConfigTypeID FROM [AVL].[PRJ_RegexConfiguration] RD WITH (NOLOCK) WHERE RD.ProjectID=@ProjectID 
					and ConfigTypeID=@ConfigTypeID)OR(@ConfigTypeID=0)	
			BEGIN		
												
                IF(@ConfigTypeID=@StaticConfigTypeID) 
					BEGIN
						
						SELECT @ISDELETED=ISDELETED FROM  [AVL].[PRJ_RegexConfiguration] WHERE PROJECTID=@ProjectID and ConfigTypeID=@ConfigTypeID
						
						UPDATE RD SET
						RD.[EffectiveStartDate] = @EffectiveStartDate	,
						RD.[EffectiveEndDate]   = @EffectiveEndDate		,
						RD.[RegexFieldID]		= @Regexfieldid			,
						RD.[ISDELETED]          = 0						,
						RD.MODIFIEDBY			= @UserID				,
						RD.MODIFIEDDATE			= getdate()			
							FROM [AVL].[PRJ_RegexConfiguration] RD WHERE  RD.ProjectID=@ProjectID and 
							RD.ConfigTypeID=@StaticConfigTypeID and RD.IsDeleted=@ISDELETED
					END
					  
				IF(@ConfigTypeID=@DynamicConfigTypeID)

					BEGIN
						
						SELECT @ISDELETED=ISDELETED FROM  [AVL].[PRJ_RegexConfiguration] WHERE PROJECTID=@ProjectID and ConfigTypeID=@ConfigTypeID
					
						UPDATE RD SET 
						RD.[RegexFieldID]		= @Regexfieldid			,
						RD.[ISDELETED]          = 0						,
						RD.MODIFIEDBY			= @UserID				,
						RD.MODIFIEDDATE			= getdate()			
						FROM [AVL].[PRJ_RegexConfiguration] RD WHERE  RD.ProjectID=@ProjectID and 
						ConfigTypeID=@DynamicConfigTypeID and RD.IsDeleted=@ISDELETED
					END		
				
				IF(@ConfigTypeID=0)
					BEGIN
				
						UPDATE RD SET 				
						RD.[ISDELETED]          = 1						,
						RD.MODIFIEDBY			= @UserID				,
						RD.MODIFIEDDATE			= getdate()			
						FROM [AVL].[PRJ_RegexConfiguration] RD WHERE  RD.ProjectID=@ProjectID and RD.IsDeleted=0

					END

			END
								
						
		IF EXISTS (SELECT TOP 1 RD.ConfigTypeID FROM [AVL].[PRJ_RegexConfiguration] RD WITH (NOLOCK)
			WHERE RD.ProjectID=@ProjectID and RD.ConfigTypeID=@DynamicConfigTypeID and IsDeleted=0)and(@ConfigTypeID=@DynamicConfigTypeID)

		BEGIN
		
					SELECT @RegexConfigID=RegexConfigID From [AVL].[PRJ_RegexConfiguration] WITH (NOLOCK)
							where  [ProjectID]=@ProjectID and ConfigTypeID=@DynamicConfigTypeID and IsDeleted=0  order by RegexConfigID DESC				
		
					INSERT INTO #TEMPDYNAMICDETAILS					
					SELECT ID,KeywordID,ConditionID,KeyValues FROM OPENJSON(@DynamicJSONData)
					WITH(
						   ID INT '$.DynamicID',
						   KeywordID INT '$.KeywordID',	     
						   ConditionID INT '$.ConditionID',
						   KeyValues NVARCHAR(max) '$.KeyValues'
						) AS JSONVALUES
			
				    

					MERGE [AVL].[MAP_RegexConfigurationDetails]  AS TARGET
					USING #TEMPDYNAMICDETAILS AS SOURCE
					ON TARGET.ID=SOURCE.ID and TARGET.ISDELETED=0
			        AND (TARGET.KeywordID = SOURCE.KeywordID OR TARGET.ConditionID=SOURCE.ConditionID OR TARGET.KEYVALUES=SOURCE.KEYVALUES)
					When Matched AND (TARGET.RegexConfigID=@RegexConfigID) THEN

					UPDATE SET  TARGET.KeywordID	=	SOURCE.KeywordID		,
								TARGET.ConditionID	=	SOURCE.ConditionID		,
								TARGET.KeyValues	=	SOURCE.KeyValues		,
								TARGET.MODIFIEDBY	=	@USERID				    ,
								TARGET.MODIFIEDDATE	=	getdate()				
					
					WHEN NOT MATCHED BY TARGET AND (SOURCE.ID IS NULL AND SOURCE.KEYWORDID IS NOT NULL AND 
					SOURCE.ConditionID IS NOT NULL AND SOURCE.KeyValues IS NOT NULL)  THEN
					
					INSERT (
					 [RegexConfigID]
					,[KeywordID]
					,[ConditionID] 
					,[KeyValues] 
					,[IsDeleted] 
					,[CreatedBy] 
					,[CreatedDate] )
					VALUES (
					 @RegexConfigID
					,SOURCE.KeywordID
					,SOURCE.ConditionID
					,SOURCE.KeyValues 
					,0
					,@USERID
					,getdate()
					 );
					
					UPDATE RD SET 
					RD.ISDELETED	=	1				,
					RD.MODIFIEDBY	=	@USERID			,
					RD.MODIFIEDDATE	=	getdate()		
					FROM [AVL].[MAP_RegexConfigurationDetails] RD
					WHERE NOT EXISTS
					(SELECT RD.ID FROM #TEMPDYNAMICDETAILS TEMP WHERE 
					RD.KeywordID = TEMP.KeywordID and RD.ConditionID=TEMP.ConditionID ) and RegexConfigID=@RegexConfigID
						
	    END


		IF EXISTS(SELECT Top 1 RegexConfigID From [AVL].[PRJ_RegexConfiguration] WITH (NOLOCK)
							where  [ProjectID]=@ProjectID and ConfigTypeID=@StaticConfigTypeID and IsDeleted=0)
		BEGIN

					SELECT RegexConfigID From [AVL].[PRJ_RegexConfiguration] WITH (NOLOCK)
							where  [ProjectID]=@ProjectID and ConfigTypeID=@StaticConfigTypeID and IsDeleted=0

        END

		ELSE
		BEGIN
		
					SELECT '0'
			
        END
					
		COMMIT TRAN
	END TRY 

    BEGIN CATCH 
		SET @Result = 0
		Select @Result as Result
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error   
		ROLLBACK TRAN
        EXEC AVL_INSERTERROR  '[PP].[SaveRegexDetail]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
