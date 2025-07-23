/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		Team sunrays
-- Create date: 10/19/2020
-- Description:	EXEC  RLE.GetAssociateAllocationDetails '101483'
-- =============================================
CREATE PROCEDURE [RLE].[GetAssociateAllocationDetails] 
(
	@AssociateId NVARCHAR(50)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @EsaProjectId NVARCHAR(50);
	DECLARE	@AssociateName NVARCHAR(255) = NULL;
	DECLARE @Email NVARCHAR(255) = NULL;
	DECLARE @Designation NVARCHAR(200) = NULL;
	DECLARE @Grade CHAR(3)=NULL;
	DECLARE @ESAAssociateId CHAR(11) = CONVERT(CHAR(11), @AssociateId);

	IF EXISTS(SELECT top 1 1 FROM ESA.ProjectAssociates WHERE AssociateID = @ESAAssociateId)
	BEGIN
		--- Assigining Associate details ---
		SELECT Top 1  @AssociateName = AssociateName, @Designation = Designation 
				,@Email = Email, @Grade = Grade  
		FROM	ESA.Associates 
		WHERE	AssociateID = @ESAAssociateId AND IsActive=1


		IF(ISNULL(@AssociateName,'') <> '' AND ISNULL(@Email,'') <> '')
		BEGIN

			BEGIN-- Get Associate allocation details --
				SELECT 	projass.AssociateID
						,@AssociateName AS AssociateName ,@Email AS Email
						,@Designation AS Designation ,@Grade AS Grade
						,mh.MarketID ,mh.MarketName
						,mh.MarketUnitID ,mh.MarketUnitName
						,mh.BusinessUnitID ,mh.BusinessUnitName
						,mh.SBU1ID ,mh.SBU1Name
						,mh.SBU2ID ,mh.SBU2Name
						,mh.IndustrySegmentId, mh.IndustrySegmentName
						,mh.VerticalID ,mh.VerticalName
						,mh.SubVerticalID , mh.SubVerticalName
						,mh.CustomerID  ,mh.ESACustomerID ,mh.CustomerName 
						,mh.ParentCustomerID ,mh.ParentCustomerName
						,mh.ProjectID ,mh.ESAProjectID, mh.ProjectName
						,mh.PracticeID ,mh.PracticeName
				FROM	ESA.ProjectAssociates projass
						JOIN RLE.MasterHierarchy mh ON mh.ESAProjectID = CONVERT(NVARCHAR(30),projass.ProjectID)
				WHERE projass.AssociateID = @ESAAssociateId
			END
		END
	END
END
