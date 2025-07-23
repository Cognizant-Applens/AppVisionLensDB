/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



-- ============================================================================ 
-- Author:           441778 
-- Create date:      30/01/2020
-- Description:      SP  for service auto classification
-- Test:             EXEC [AVL].[GetDictionaryValuesForServiceClassification]
-- ============================================================================
CREATE PROCEDURE [AVL].[GetDictionaryValuesForServiceClassification] 
  
AS 
  BEGIN 
      BEGIN TRY 


		OPEN SYMMETRIC KEY symKeyDD DECRYPTION BY CERTIFICATE CertificateDDKey;
		SELECT RULE_ID,[PRIORITY],
		CAST(DecryptByKey([WORK_PATTERN]) as nvarchar(max)) as [WORK_PATTERN],
		CAST(DecryptByKey([CAUSE_CODE]) as nvarchar(max)) as [CAUSE_CODE],
		CAST(DecryptByKey([RESOLUTION_CODE]) as nvarchar(max)) as [RESOLUTION_CODE],
		CAST(DecryptByKey([SERVICE_NAME]) as nvarchar(max)) as [SERVICE_NAME]
		FROM BCS.BidRulesEncrypted order by PRIORITY;
		CLOSE SYMMETRIC KEY symKeyDD;	  
	  
		
   END TRY 

   BEGIN CATCH 
          DECLARE @ErrorMessage1 VARCHAR(MAX); 

          SELECT @ErrorMessage1 = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[AVL].[GetDictionaryValuesForServiceClassification] ', 
            @ErrorMessage1, 
			'',
            0 
      END CATCH 
  END
