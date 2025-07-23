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
-- Author:           627129 
-- Create date:      7 AUG 2019 
-- Description:      To get path of file in hadoop 
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB 
-- EXEC [dbo].[ML_GetNoiseOutPutInfrapath] '0001788-181017122220702-oozie-oozi-W' 
-- ============================================================================ 
CREATE PROCEDURE [dbo].[ML_GetNoiseOutPutInfrapath]-- '0001788-181017122220702-oozie-oozi-W' 
  @NoiseEliminationJobId NVARCHAR(1000) 
AS 
  BEGIN 
      BEGIN TRY 
          --To get the filename for retrival of the data from hivepath 
          DECLARE @FilePathDesc NVARCHAR(1000); 
          DECLARE @FilePathOpt NVARCHAR(1000); 
          DECLARE @FileNameDesc NVARCHAR(1000); 
          DECLARE @FileNameOpt NVARCHAR(1000); 
          DECLARE @FileNameError NVARCHAR(1000); 
          DECLARE @ServiceType NVARCHAR(50); 
          DECLARE @FileErrorPath NVARCHAR(1000); 
          DECLARE @PresenceOfOptField BIT; 
          DECLARE @countforvalidtickets INT; 
          DECLARE @CountforNullOpt INT; 
          DECLARE @OptFieldID INT; 
          DECLARE @ProjectID INT; 

          SET @ProjectID=(SELECT TOP 1 ProjectID 
                          FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK) 
                          WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '') 
                          ORDER  BY ID DESC) 
          SET @countforvalidtickets=(SELECT COUNT(TicketID) 
                                     FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK)  
                                     WHERE  ProjectID = @ProjectID 
                                            AND IsDeleted = 0) 
          SET @CountforNullOpt=(SELECT COUNT(TicketID) 
                                FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK)  
                                WHERE  ProjectID = @ProjectID 
                                       AND IsDeleted = 0 
                                       AND ( OptionalFieldProj = '' 
                                              OR OptionalFieldProj IS NULL )) 
          SET @OptFieldID=(SELECT TOP 1 OptionalFieldID 
                           FROM   AVL.ML_MAP_OptionalProjMappingInfra 
                           WHERE  ProjectId = @ProjectID 
                                  AND IsDeleted = 0
							ORDER BY Id DESC) 

          IF ( ( @OptFieldID <> 4 
                  OR @OptFieldID IS NOT NULL ) 
                OR @OptFieldID = 4 ) 
            BEGIN 
                IF( @CountforNullOpt = @countforvalidtickets ) 
                  BEGIN 
                      --If optional field is not defined or optional field value is null or empty throughout 
                      SET @PresenceOfOptField=0 
                      SET @FileNameDesc=(SELECT TOP 1 REPLACE([FileName], '_NoiseInput', '_Desc_WordList') 
                                         FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK)   
                                         WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '')
                                         ORDER  BY ID DESC) 
                      SET @FileNameError=(SELECT TOP 1 REPLACE([FileName], '_NoiseInput', '_error_Noise_Elimination') 
                                          FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK)   
                                          WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '')
                                          ORDER  BY ID DESC) 
                      SET @FilePathDesc=(SELECT TOP 1 CONCAT(DataPath, '/', @FileNameDesc) 
                                         FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK)   
                                         WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '')
                                         ORDER  BY ID DESC) 
                      SET @FileErrorPath=(SELECT TOP 1 CONCAT(DataPath, '/', @FileNameError) 
                                          FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK)   
                                          WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '')
                                          ORDER  BY ID DESC) 

                      SELECT @FilePathDesc       AS HiveDataPathDesc, 
                             @FileErrorPath      AS FileErrorPath, 
                             @PresenceOfOptField AS PresenceOfOptField 
                  END 
                ELSE 
                  BEGIN 
                      --optional is not empty provided that is defined for the project 
                      SET @PresenceOfOptField=1; 
                      SET @FileNameDesc=(SELECT TOP 1 REPLACE([FileName], '_NoiseInput', '_Desc_WordList') 
                                         FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK)   
                                         WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '')
                                         ORDER  BY ID DESC) 
                      SET @FileNameOpt=(SELECT TOP 1 REPLACE([FileName], '_NoiseInput', '_Res_WordList') 
                                        FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK)   
                                        WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '')
                                        ORDER  BY ID DESC) 
                      SET @FilePathDesc=(SELECT TOP 1 CONCAT(DataPath, '/', @FileNameDesc) 
                                         FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK)   
                                         WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '')
                                         ORDER  BY ID DESC) 
                      SET @FilePathOpt=(SELECT TOP 1 CONCAT(DataPath, '/', @FileNameOpt) 
                                        FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK)   
                                        WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '')
                                        ORDER  BY ID DESC) 
                      SET @FileNameError=(SELECT TOP 1 REPLACE([FileName], '_NoiseInput', '_error_Noise_Elimination') 
                                          FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK)   
                                          WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '')
                                          ORDER  BY ID DESC) 
                      SET @FileErrorPath=(SELECT TOP 1 CONCAT(DataPath, '/', @FileNameError) 
                                          FROM   AVL.ML_TRN_MLSamplingJobStatusInfra(NOLOCK)   
                                          WHERE  JobIdFromML = REPLACE(@NoiseEliminationJobId, '''', '')
                                          ORDER  BY ID DESC) 

                      SELECT @FilePathDesc       AS HiveDataPathDesc, 
                             @FilePathOpt        AS HiveDataPathOpt, 
                             @FileErrorPath      AS FileErrorPath, 
                             @PresenceOfOptField AS PresenceOfOptField 
                  END 
            END 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_GetNoiseOutPutInfrapath]', 
            @ErrorMessage, 
            0, 
            0 
      END CATCH 
  END
