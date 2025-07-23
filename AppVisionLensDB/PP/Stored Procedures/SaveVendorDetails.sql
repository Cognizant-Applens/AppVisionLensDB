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
-- Description : Save Vendor Details
-- Revision    :
-- Revised By  :
-- =========================================================================================

CREATE PROCEDURE [PP].[SaveVendorDetails]
@ProjectID BIGINT,
@EmployeeID NVARCHAR(50),
@Mode NVARCHAR(20),
@VendorDetails as [PP].[VendorDetails] READONLY

AS 
  BEGIN 
	BEGIN TRY 
		BEGIN TRAN
		SET NOCOUNT ON;
		DECLARE @Result BIT;

		IF(@Mode = 'Save')
		BEGIN
						
				INSERT INTO PP.Project_VendorDetails
				select 
				@ProjectID,LTRIM(RTRIM(PV.VendorName)),null,0,@EmployeeID,GetDate(),NULL,NULL
				from @VendorDetails PV 
				WHERE  PV.VendorDetailID = 0  AND LTRIM(RTRIM(PV.VendorName)) NOT IN (SELECT VendorName FROM PP.Project_VendorDetails WHERE ProjectID =@ProjectID AND IsDeleted = 0 )

	
				
				UPDATE VEN  set
				VEN.VendorName = PV.VendorName,
				VEN.ModifiedBy = @EmployeeID,
				VEN.ModifiedDate = GetDate()
				from PP.Project_VendorDetails VEN
				join @VendorDetails PV ON  VEN.VendorDetailID = LTRIM(RTRIM(PV.VendorDetailID))
				where VEN.ProjectId = @ProjectID AND PV.VendorDetailID != 0
		
		END
		IF(@Mode = 'Delete')
		BEGIN
		Declare @VendorDetailID BIGINT;
		SET @VendorDetailID = (SELECT TOP 1 VendorDetailID FROM @VendorDetails)
		UPDATE PP.Project_VendorDetails SET IsDeleted = 1 WHERE VendorDetailID = @VendorDetailID
		END

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
        EXEC AVL_INSERTERROR  '[PP].[SaveVendorDetails]', @ErrorMessage,  0, 0 
    END CATCH 
  END
