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
-- Create date : Mar 2, 2020
-- Description : Save POD Details
-- Revision    :
-- Revised By  :
-- =========================================================================================

CREATE PROCEDURE [PP].[SavePODDetails]
@ProjectID BIGINT,
@EmployeeID NVARCHAR(50),
@Mode NVARCHAR(20),
@PODDetails as [PP].[PODDetails] READONLY
AS 
  BEGIN 
	BEGIN TRY 
		BEGIN TRAN
		SET NOCOUNT ON;
		DECLARE @Result BIT;
		DECLARE @PODCount INT;
		IF(@Mode = 'Save')
		BEGIN
		
				INSERT INTO PP.Project_PODDetails
				select 
				@ProjectID,PV.PODName,LTRIM(RTRIM(PV.PODSize)),0,@EmployeeID,GetDate(),NULL,NULL
				from @PODDetails PV WHERE  PV.PODDetailID = 0  AND LTRIM(RTRIM(PV.PODName)) NOT IN (SELECT PODName FROM PP.Project_PODDetails(NOLOCK) WHERE ProjectID =@ProjectID AND IsDeleted =0 )

				UPDATE POD  set
				POD.PODName = LTRIM(RTRIM(PV.PODName)),
				POD.PODSize = PV.PODSize,
				POD.ModifiedBy = @EmployeeID,
				POD.ModifiedDate = GetDate()
				from PP.Project_PODDetails POD
				join @PODDetails PV ON  POD.PODDetailID = PV.PODDetailID
				where POD.ProjectId = @ProjectID AND PV.PODDetailID != 0

		END
		IF(@Mode = 'Delete')
		BEGIN
		Declare @PODDetailID BIGINT;
		SET @PODDetailID= (SELECT TOP 1 PODDetailID FROM @PODDetails)
		UPDATE  PP.Project_PODDetails  SET IsDeleted = 1 WHERE PODDetailID = @PodDetailID
		END

		SET @PODCount = (SELECT COUNT(PODDetailID)  FROM PP.Project_PODDetails(NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0)
		UPDATE PP.Extended_ProjectDetails SET  NoOfPODS = @PODCount
		WHERE ProjectID= @ProjectID
		SET @Result = 1
		SELECT @Result AS Result
		COMMIT TRAN
		END TRY
    BEGIN CATCH 
	    SET @Result = 0
		SELECT @Result AS Result
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
		ROLLBACK TRAN
        --INSERT Error     
        EXEC AVL_INSERTERROR  '[PP].[SavePODDetails]', @ErrorMessage,  0, 0 
    END CATCH 
  END
