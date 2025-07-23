/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[SaveTicketUploadTrack] 
@TicketUploadTrackType  AVL.TicketUploadTrackType READONLY,
@TicketUploadTrackID BIGINT,
@Scenario AS INT
AS
BEGIN
SET NOCOUNT ON
	BEGIN	TRY

	    
		IF @TicketUploadTrackID IS NULL OR @TicketUploadTrackID=0
		BEGIN
			INSERT INTO AVL.TicketUploadTrack
			(
			    ProjectID,
			    EmployeeID,
			    Mode,
			    FileName,
			    IsColumnMappingValidated,
			    MndColValBeginTime,
			    MndColValEndTime,
			    NonMndColValBeginTime,
			    NonMndColValEndTime,
			    NullValUpdateBeginTime,
			    NullValUpdateEndTime,
			    MasterValuesUpdateBeginTime,
			    MasterValuesUpdateEndTime,
			    BLErrorMessage,
			    DBErrorMessage,
			    TotalRecordsInExcel,
			    TotalValidRecords,
			    TotalDuplicateRecords,
			    TotalRejectedRecords,
			    IsActive,
			    CreatedBy,
			    CreatedDate,
			    ModifiedBy,
			    ModifiedDate
			)
			SELECT ProjectID,
			    EmployeeID,
			    Mode,
			    FileName,
			    IsColumnMappingValidated,
			    MndColValBeginTime,
			    MndColValEndTime,
			    NonMndColValBeginTime,
			    NonMndColValEndTime,
			    NullValUpdateBeginTime,
			    NullValUpdateEndTime,
			    MasterValuesUpdateBeginTime,
			    MasterValuesUpdateEndTime,
			    BLErrorMessage,
			    DBErrorMessage,
			    TotalRecordsInExcel,
			    TotalValidRecords,
			    TotalDuplicateRecords,
			    TotalRejectedRecords,
			    IsActive,
			    CreatedBy,
			    CreatedDate,
			    ModifiedBy,
			    ModifiedDate
			FROM @TicketUploadTrackType ;
			SELECT SCOPE_IDENTITY() AS Result;

		END
		ELSE
		BEGIN
				--Common Update
				MERGE	AVL.TicketUploadTrack AS TARGET
				USING	@TicketUploadTrackType AS SOURCE
				ON (TARGET.TicketUploadTrackID = @TicketUploadTrackID)
				WHEN MATCHED THEN UPDATE SET 
				TARGET.ModifiedBy=SOURCE.ModifiedBy,
				TARGET.ModifiedDate=SOURCE.ModifiedDate,
				TARGET.IsActive=SOURCE.IsActive,
				TARGET.IsColumnMappingValidated=ISNULL(SOURce.IsColumnMappingValidated,TARGET.IsColumnMappingValidated),
				TARGET.BLErrorMessage=ISNULL(SOURce.BLErrorMessage,TARGET.BLErrorMessage),
				TARGET.DBErrorMessage=ISNULL(SOURce.DBErrorMessage,TARGET.DBErrorMessage),
				TARGET.TotalRecordsInExcel= CASE WHEN SOURce.TotalRecordsInExcel IS NOT NULL AND SOURce.TotalRecordsInExcel>0 THEN SOURCE.TotalRecordsInExcel ELSE TARGET.TotalRecordsInExcel END,
				TARGET.TotalValidRecords= CASE WHEN SOURce.TotalValidRecords IS NOT NULL AND SOURce.TotalValidRecords>0 THEN SOURCE.TotalValidRecords ELSE TARGET.TotalValidRecords END,
				TARGET.TotalDuplicateRecords= CASE WHEN SOURce.TotalDuplicateRecords IS NOT NULL AND SOURce.TotalDuplicateRecords>0 THEN SOURCE.TotalDuplicateRecords ELSE TARGET.TotalDuplicateRecords END,
				TARGET.TotalRejectedRecords= CASE WHEN SOURce.TotalRejectedRecords IS NOT NULL AND SOURce.TotalRejectedRecords>0 THEN SOURCE.TotalRejectedRecords ELSE TARGET.TotalRejectedRecords END,
				TARGET.MndColValBeginTime= CASE WHEN SOURce.MndColValBeginTime IS NOT NULL  THEN SOURCE.MndColValBeginTime ELSE TARGET.MndColValBeginTime END,
				TARGET.NonMndColValBeginTime= CASE WHEN SOURce.NonMndColValBeginTime IS NOT NULL  THEN SOURCE.NonMndColValBeginTime ELSE TARGET.NonMndColValBeginTime END;
				--Scenario Based Update
			IF @Scenario=1
			BEGIN
				MERGE	AVL.TicketUploadTrack AS TARGET
				USING	@TicketUploadTrackType AS SOURCE
				ON (TARGET.TicketUploadTrackID = @TicketUploadTrackID)
				WHEN MATCHED THEN UPDATE SET 
					TARGET.MndColValEndTime=SOURCE.MndColValEndTime;
			END
			IF @Scenario=2
			BEGIN
				MERGE	AVL.TicketUploadTrack AS TARGET
				USING	@TicketUploadTrackType AS SOURCE
				ON (TARGET.TicketUploadTrackID = @TicketUploadTrackID)
				WHEN MATCHED THEN UPDATE SET 
					TARGET.NonMndColValEndTime=SOURCE.NonMndColValEndTime;
			END
			IF @Scenario=3
			BEGIN
				MERGE	AVL.TicketUploadTrack AS TARGET
				USING	@TicketUploadTrackType AS SOURCE
				ON (TARGET.TicketUploadTrackID = @TicketUploadTrackID)
				WHEN MATCHED THEN UPDATE SET 
					TARGET.NullValUpdateBeginTime=SOURCE.NullValUpdateBeginTime,
					TARGET.NullValUpdateEndTime=SOURCE.NullValUpdateEndTime;
			END
			IF @Scenario=4
			BEGIN
				MERGE	AVL.TicketUploadTrack AS TARGET
				USING	@TicketUploadTrackType AS SOURCE
				ON (TARGET.TicketUploadTrackID = @TicketUploadTrackID)
				WHEN MATCHED THEN UPDATE SET 
					TARGET.MasterValuesUpdateBeginTime=SOURCE.MasterValuesUpdateBeginTime,
					TARGET.MasterValuesUpdateEndTime=SOURCE.MasterValuesUpdateEndTime;
			END
			IF @Scenario=5
			BEGIN
				MERGE	AVL.TicketUploadTrack AS TARGET
				USING	@TicketUploadTrackType AS SOURCE
				ON (TARGET.TicketUploadTrackID = @TicketUploadTrackID)
				WHEN MATCHED THEN UPDATE SET 
					TARGET.StoredProcedureStartTime=SOURCE.StoredProcedureStartTime;
			END
			IF @Scenario=6
			BEGIN
				MERGE	AVL.TicketUploadTrack AS TARGET
				USING	@TicketUploadTrackType AS SOURCE
				ON (TARGET.TicketUploadTrackID = @TicketUploadTrackID)
				WHEN MATCHED THEN UPDATE SET 
					TARGET.StoredProcedureEndTime=SOURCE.StoredProcedureEndTime;
			END
			SELECT 1 AS Result;
		END
		SET NOCOUNT OFF
	END		TRY
	BEGIN	CATCH
		SELECT -1 AS Result;
	END		CATCH

END
