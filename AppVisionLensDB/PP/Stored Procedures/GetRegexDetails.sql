/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetRegexDetails]
@Projectid BIGINT,
@ConfigTypeID INT=0

AS	

	BEGIN
	  BEGIN TRY  
	   BEGIN TRAN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;
	
		DECLARE @StaticConfigID INT,@DynamicConfigID INT,@REGEXCONFIGID BIGINT
		DECLARE @CREATEDDATE Datetime,@MODIFIEDDATE Datetime,@ISDELETED INT


		SELECT @StaticConfigID=ID  FROM [MAS].[Regex_Config] With (Nolock) WHERE IsDeleted=0 AND Category='ConfigType' AND [Key]='Static'
		SELECT @DynamicConfigID=ID FROM [MAS].[Regex_Config] With (Nolock) WHERE IsDeleted=0 AND Category='ConfigType' AND [Key]='Dynamic'
	
	    --To get latest created or updated data----
		IF(@ConfigTypeID=0 )			
		BEGIN
		    Select Top 1 @MODIFIEDDATE=MODIFIEDDATE from AVl.PRJ_RegexConfiguration where ProjectID=@Projectid order by ModifiedDate desc
			SELECT Top 1 @CREATEDDATE=CREATEDDATE  from AVl.PRJ_RegexConfiguration where ProjectID=@Projectid order by CreatedDate desc
			
			IF(@MODIFIEDDATE>@CREATEDDATE)
			BEGIN
				Select Top 1 @ISDELETED=IsDeleted,@ConfigTypeID=ConfigTypeID from AVl.PRJ_RegexConfiguration where ProjectID=@Projectid order by ModifiedDate desc
			END
			ELSE
			BEGIN

				SELECT Top 1 @ISDELETED=IsDeleted,@ConfigTypeID=ConfigTypeID  from AVl.PRJ_RegexConfiguration where ProjectID=@Projectid order by CreatedDate desc
			END
			IF(@ISDELETED=1)
				SET @ConfigTypeID=0
		END
		ELSE
		BEGIN
				SELECT @ISDELETED=IsDeleted from AVl.PRJ_RegexConfiguration where ProjectID=@Projectid and ConfigTypeID=@ConfigTypeID
		END
	
		
		Select @ConfigTypeID 'ConfigTypeID'

		
		--To get Static data--
		IF(@ConfigTypeID=@StaticConfigID)
	
			BEGIN
	
				SELECT Top 1 PR.ConfigTypeID,RC1.Value as ConfigType,RegexFieldID,RC2.Value as RegexField,PR.EffectiveStartDate,PR.EffectiveEndDate
					,Case When RJ.JobMessage IS NULL Then '0' Else RJ.JobMessage END as JobStatus
					,Case When RJ.ID IS NULL Then '0' Else RJ.ID END as JobStatusID,PR.RegexConfigID
			
				 FROM		 AVl.PRJ_RegexConfiguration  PR With (Nolock)
				 INNER JOIN	 MAS.REGEX_CONFIG RC1 With (Nolock)  ON PR.ConfigTypeID=RC1.ID and RC1.CATEGORY='ConfigType'							 	
				 INNER JOIN  MAS.REGEX_CONFIG RC2 With (Nolock)  ON PR.RegexFieldID=RC2.ID and RC2.CATEGORY='Regex Field'							 
				 LEFT  JOIN 	 AVL.RegexJobStatus RJ With (Nolock) ON PR.RegexConfigID=RJ.RegexConfigID
	
				 WHERE ProjectID=@Projectid and PR.ConfigTypeID=@StaticConfigID and PR.IsDeleted=@ISDELETED

				 ORDER BY JobStatusID DESC
	
			END				
		
        --To get dynamic data---		
		IF(@ConfigTypeID=@DynamicConfigID)

			BEGIN	
			
				SELECT @REGEXCONFIGID=RegexConfigID from AVl.PRJ_RegexConfiguration With (Nolock) WHERE ProjectID=@Projectid and ConfigTypeID=@DynamicConfigID
	
				SELECT ConfigTypeID,RC1.Value as ConfigType,RegexFieldID,RC2.Value as RegexField				
				FROM        AVl.PRJ_RegexConfiguration PR With (Nolock)			
				
				INNER JOIN 	MAS.REGEX_CONFIG RC1 With (Nolock) ON  PR.ConfigTypeID=RC1.ID and RC1.CATEGORY='ConfigType'								
				INNER JOIN  MAS.REGEX_CONFIG RC2 With (Nolock) ON  PR.RegexFieldID=RC2.ID and RC2.CATEGORY='Regex Field'								
				
				WHERE ProjectID=@Projectid and ConfigTypeID=@DynamicConfigID and PR.IsDeleted=@ISDELETED

				SELECT RD.ID as DynamicID, RC1.ID as keywordID,RC1.VALUE as Keyword,RC2.ID as conditionID,RC2.VALUE as Condition,Keyvalues				
				
				FROM       [AVL].[MAP_RegexConfigurationDetails] RD With (Nolock)				
				
				INNER JOIN  MAS.REGEX_CONFIG RC1 With (Nolock) ON RD.KeywordID=RC1.ID   
							and   RC1.CATEGORY='Keyword' and RegexConfigID=@REGEXCONFIGID and RD.IsDeleted=0						
				INNER JOIN  MAS.REGEX_CONFIG RC2 With (Nolock) ON RD.ConditionID=RC2.ID 
							and	  RC2.CATEGORY='Condition' and   RegexConfigID=@REGEXCONFIGID and RD.IsDeleted=0
							
	
			END

				
		COMMIT TRAN
	END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error   
		ROLLBACK TRAN
        EXEC AVL_INSERTERROR  '[PP].[GetRegexDetails]', @ErrorMessage,  0, 
        0 
    END CATCH 
			
	END
