/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ================================================
-- Strore Procedure to insert Error and log informations
-- ================================================
CREATE PROCEDURE [dbo].[InsertErrorLogDetails] 
@LogSeverity        VARCHAR(50),
@LogLevel			VARCHAR(50),
@HostName			NVARCHAR(200),
@AssociateId        NVARCHAR(50),
@CreatedDate        datetime,
@ProjectId			NVARCHAR(50),
@ModuleName			NVARCHAR(250),
@FeatureName        NVARCHAR(250),
@ClassName			NVARCHAR(250),
@MethodName			NVARCHAR(250),
@ProcessId			bigint,
@ErrorCode			VARCHAR(50),
@ErrorMessage       NVARCHAR(MAX),
@StackTrace			NVARCHAR(MAX),
@AdditionalField_1  NVARCHAR(MAX),
@AdditionalField_2  NVARCHAR(MAX)
AS
BEGIN
 
		SET NOCOUNT ON;
		BEGIN TRY
			INSERT INTO [dbo].[ErrorLogDetails]
					   ([LogSeverity]
					   ,[LogLevel]
					   ,[HostName]
					   ,[AssociateId]
					   ,[CreatedDate]
					   ,[ProjectId]
					   ,[ModuleName]
					   ,[FeatureName]
					   ,[ClassName]
					   ,[MethodName]
					   ,[ProcessId]
					   ,[ErrorCode]
					   ,[ErrorMessage]
					   ,[StackTrace]
					   ,[AdditionalField_1]
					   ,[AdditionalField_2])
				 VALUES
					   (@LogSeverity
					   ,@LogLevel
					   ,@HostName
					   ,@AssociateId
					   ,@CreatedDate
					   ,@ProjectId
					   ,@ModuleName
					   ,@FeatureName
					   ,@ClassName
					   ,@MethodName
			           ,@ProcessId
					   ,@ErrorCode
					   ,@ErrorMessage
					   ,@StackTrace
					   ,@AdditionalField_1
					   ,@AdditionalField_2);
 
	END TRY
	BEGIN CATCH
					SELECT
					ERROR_NUMBER() AS ErrorNumber,
					ERROR_STATE() AS ErrorState,
					ERROR_SEVERITY() AS ErrorSeverity,
					ERROR_PROCEDURE() AS ErrorProcedure,
					ERROR_LINE() AS ErrorLine,
					ERROR_MESSAGE() AS ErrorMessage;
	END CATCH;
END
