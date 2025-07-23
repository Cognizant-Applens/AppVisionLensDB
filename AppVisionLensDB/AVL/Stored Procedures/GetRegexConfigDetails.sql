/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetRegexConfigDetails] 
@ProjectId BIGINT
AS
BEGIN
	DECLARE @ConfigTypeId INT,@StaticConfigId INT,@DynamicConfigId INT,@CreatedDate Datetime,@ModifiedDate Datetime

	SELECT @StaticConfigId=ID  FROM [MAS].[Regex_Config] WITH (NOLOCK) WHERE IsDeleted=0 AND Category='ConfigType' AND [Key]='Static'
	SELECT @DynamicConfigId=ID FROM [MAS].[Regex_Config] WITH (NOLOCK) WHERE IsDeleted=0 AND Category='ConfigType' AND [Key]='Dynamic'	
			
	BEGIN
		SELECT TOP 1 @ModifiedDate=ModifiedDate FROM AVl.PRJ_RegexConfiguration WITH (NOLOCK) WHERE ProjectID=@ProjectId ORDER BY ModifiedDate DESC
		SELECT TOP 1 @CreatedDate=CreatedDate  FROM AVl.PRJ_RegexConfiguration WITH (NOLOCK) WHERE ProjectID=@ProjectId ORDER BY CreatedDate DESC
			
		IF(@ModifiedDate>@CreatedDate)
		BEGIN
			SELECT TOP 1 @ConfigTypeId=ConfigTypeID FROM AVl.PRJ_RegexConfiguration WITH (NOLOCK) WHERE ProjectID=@ProjectId ORDER BY ModifiedDate DESC
		END
		ELSE
		BEGIN
			SELECT TOP 1 @ConfigTypeId=ConfigTypeID  FROM AVl.PRJ_RegexConfiguration WITH (NOLOCK) WHERE ProjectID=@ProjectId ORDER BY CreatedDate DESC
		END

		IF(@ConfigTypeId=@StaticConfigId)
		BEGIN 		    
			SELECT  PR.ProjectId,PR.ConfigTypeId,RG.[Value] AS RegexField,RW.RegexWord,PR.IsDeleted 
			FROM [AVL].[PRJ_RegexConfiguration] PR WITH (NOLOCK)
			LEFT JOIN [AVL].[RegexWords] RW WITH (NOLOCK) ON PR.ProjectID=RW.ProjectID
			JOIN [MAS].[Regex_Config] RG WITH (NOLOCK) ON PR.RegexFieldID=RG.ID
			WHERE PR.ProjectID=@ProjectId AND PR.ConfigTypeID=@ConfigTypeId AND RW.IsDeleted=0 AND PR.IsDeleted=0 AND RG.IsDeleted=0 		
		END	
		
		IF(@ConfigTypeId=@DynamicConfigId)
		BEGIN 
			SELECT PR.ProjectId,PR.ConfigTypeId,RG.[Value] AS RegexField,RD.KeywordId,RD.ConditionId,RC.[Value] AS Condition,RD.KeyValues,PR.IsDeleted 
			FROM [AVL].[PRJ_RegexConfiguration] PR WITH (NOLOCK)
			LEFT JOIN [AVL].[MAP_RegexConfigurationDetails] RD WITH (NOLOCK) ON PR.RegexConfigID=RD.RegexConfigID
			JOIN [MAS].[Regex_Config] RC WITH (NOLOCK) ON RD.ConditionID=RC.ID
			JOIN [MAS].[Regex_Config] RG WITH (NOLOCK) ON PR.RegexFieldID=RG.ID
			WHERE PR.ProjectID=@ProjectId AND PR.ConfigTypeID=@ConfigTypeId AND RD.IsDeleted=0 AND PR.IsDeleted=0 AND RG.IsDeleted=0
		END
	END
END
