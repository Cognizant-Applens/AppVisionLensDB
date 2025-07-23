/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================ 
-- Author:           Devika 
-- Create date:      11 FEB 2018 
-- Description:      SP for Initial Learning 
-- Test:             EXEC  [dbo].[ML_GetFileNameByJobId]  jobid 
-- ============================================================================ 
CREATE PROCEDURE [dbo].[ML_GetFileNameByJobId] @MLJobId NVARCHAR(MAX) 
AS 
  BEGIN 
      BEGIN TRY 
          DECLARE @FilePath NVARCHAR(MAX); 
          DECLARE @FileName NVARCHAR(MAX); 
          DECLARE @FileNameError NVARCHAR(MAX); 
          DECLARE @ServiceType NVARCHAR(50); 
          DECLARE @FileErrorPath NVARCHAR(MAX); 

          --SELECT * FROM TRN.MLSamplingJobStatus  
          -- to get output file name based on the servicetype(ml,sampling) and @mljobid 
          SET @ServiceType=(SELECT TOP 1 JobType 
                            FROM   AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                            WHERE  JobIdFromML = REPLACE(@MLJobId, '''', '') 
                            ORDER  BY ID DESC) 

          IF @ServiceType = 'Sampling' 
            BEGIN 
                SET @FileName=(SELECT TOP 1 REPLACE([FileName], '_SamplingFile', '_debt_Sample') 
                               FROM   AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                               WHERE  JobIdFromML = REPLACE(@MLJobId, '''', '') 
                               ORDER  BY ID DESC) 
                SET @FileNameError=(SELECT TOP 1 REPLACE([FileName], '_SamplingFile', '_error_debt_Sample') 
                                    FROM   AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                                    WHERE  JobIdFromML = REPLACE(@MLJobId, '''', '') 
                                    ORDER  BY ID DESC) 
            END 

          IF @ServiceType = 'ML' 
            BEGIN 
                SET @FileName=(SELECT TOP 1 REPLACE([FileName], '_InputFile', '_MLFile') 
                               FROM   AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                               WHERE  JobIdFromML = REPLACE(@MLJobId, '''', '') 
                               ORDER  BY ID DESC) 
                SET @FileNameError=(SELECT TOP 1 REPLACE([FileName], '_InputFile', '_error_ML')
                                    FROM   AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                                    WHERE  JobIdFromML = REPLACE(@MLJobId, '''', '') 
                                    ORDER  BY ID DESC) 
            END 

          --SELECT @FileName 
          SET @FilePath=(SELECT TOP 1 CONCAT(DataPath, '/', @FileName) 
                         FROM   AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                         WHERE  JobIdFromML = REPLACE(@MLJobId, '''', '') 
                         ORDER  BY ID DESC) 
          SET @FileErrorPath=(SELECT TOP 1 CONCAT(DataPath, '/', @FileNameError) 
                              FROM   AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                              WHERE  JobIdFromML = REPLACE(@MLJobId, '''', '') 
                              ORDER  BY ID DESC) 

          SELECT @FilePath      AS HiveDataPath, 
                 @FileErrorPath AS FileErrorPath 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_GetFileNameByJobId] ', 
            @ErrorMessage, 
            0, 
            0 
      END CATCH 
  END
