/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[SaveApplicationQualityAttributes]
(
@ApplicationID BIGINT,
@TVPFrameWorkList [PP].[TvpFrameWorkList] READONLY,
@NFRCaptured VARCHAR(10),
@IsUnitTestAutomated BIT = NULL,
@TestingCoverage DECIMAL(5,2),
@IsRegressionTest BIT = NULL,
@RegressionTestCoverage DECIMAL(5,2),
@EmployeeID VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON
		/* ----- Automation Unit Test Framework  */
		IF EXISTS( SELECT TOP 1 1 FROM @TVPFrameWorkList)
		BEGIN
			
			MERGE PP.MAP_UnitTestingFramework AS UTF
			USING @TVPFrameWorkList FW ON UTF.ApplicationID=@ApplicationID
									AND UTF.UnitTestFrameworkID=FW.UnitTestFrameworkID
			WHEN MATCHED THEN 
			UPDATE SET UTF.OtherUnitTestFramework=FW.OtherUnitTestFramework,
			UTF.IsDeleted=0,
			UTF.ModifiedBy=@EmployeeID,
			UTF.ModifiedOn=GETDATE()
			WHEN NOT MATCHED THEN			
			INSERT --PP.MAP_UnitTestingFramework
					(ApplicationID,UnitTestFrameworkID,OtherUnitTestFramework,IsDeleted,CreatedBy,CreatedOn)
				VALUES( @ApplicationID,FW.UnitTestFrameworkID,FW.OtherUnitTestFramework,0,@EmployeeID,GETDATE() );
			
			SELECT UTF.ApplicationID,UTF.UnitTestFrameworkID INTO #DELETEITEMS FROM PP.MAP_UnitTestingFramework UTF (NOLOCK)
			WHERE NOT EXISTS (
			SELECT @ApplicationID AS ApplicationID,tt.UnitTestFrameworkID FROM @TVPFrameWorkList TT WHERE UTF.UnitTestFrameworkID=TT.UnitTestFrameworkID
			AND UTF.ApplicationID=@ApplicationID)
			
			UPDATE uft set uft.isdeleted=1 ,
			uft.ModifiedOn=GETDATE(),
			uft.ModifiedBy=@EmployeeID
			FROM PP.MAP_UnitTestingFramework uft 
			JOIN #DELETEITEMS DT on uft.ApplicationID = dt.ApplicationID 
				and uft.UnitTestFrameworkID=dt.UnitTestFrameworkID
				and uft.ApplicationID=@ApplicationID
							
		END

		/*====== ApplicationQualityAttributes ====== */
		
		IF EXISTS ( SELECT TOP 1 1 FROM PP.ApplicationQualityAttributes (NOLOCK) WHERE ApplicationID=@ApplicationID)
		BEGIN 
				UPDATE PP.ApplicationQualityAttributes 
					SET NFRCaptured=@NFRCaptured,IsUnitTestAutomated=@IsUnitTestAutomated,
					TestingCoverage=@TestingCoverage,IsRegressionTest=@IsRegressionTest,
					RegressionTestCoverage=@RegressionTestCoverage,
					ModifiedBy=@EmployeeID,ModifiedOn=GETDATE()
					WHERE ApplicationID=@ApplicationID
		END
		ELSE
		BEGIN

				INSERT INTO PP.ApplicationQualityAttributes
				(ApplicationID,NFRCaptured,IsUnitTestAutomated,TestingCoverage,IsRegressionTest,RegressionTestCoverage,
					IsDeleted,CreatedBy,CreatedOn)
					SELECT @ApplicationID,@NFRCaptured,@IsUnitTestAutomated,@TestingCoverage,@IsRegressionTest,@RegressionTestCoverage,
					0,@EmployeeID,GETDATE()
		END
    set nocount off
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError 'PP.SaveApplicationQualityAttributes', @ErrorMessage, 0 ,@EmployeeID
	END CATCH
END
