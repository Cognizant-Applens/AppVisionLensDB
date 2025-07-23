/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Shobana
-- Create date : 17.05.2019 
-- Description : Procedure used to get Language details from MAS_LanguageMaster      
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [AVL].[GetLanguage] 
(@ModuleName varchar(5) = NULL)
AS
BEGIN
IF @ModuleName='TM'
BEGIN
		SELECT [LanguageName] AS LanguageNameInEnglish,
			   [Language] AS LanguageName,
			   [LanguageValue] AS LanguageCode
		FROM MAS.MAS_LanguageMaster(NOLOCK) 
		WHERE IsDeleted=0 AND LanguageID in(1,2,3) 
END		
	ELSE
	BEGIN
		SELECT [LanguageName] AS LanguageNameInEnglish,
			   [Language] AS LanguageName,
			   [LanguageValue] AS LanguageCode
		FROM MAS.MAS_LanguageMaster(NOLOCK) 
		WHERE IsDeleted = 0 
		AND LanguageID = 1
	END
END
