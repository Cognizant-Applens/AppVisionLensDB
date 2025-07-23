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

-- Description:Retrives the END date of the project
-- =============================================

--EXEC [MS].[Mainspring_ProjectReportingEndDate] @ProjectID=19100,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-13',@Priority='',@SupportCategory=''
CREATE PROCEDURE [MS].[Mainspring_ProjectReportingEndDate]
	@ProjectID BIGINT,
	@ServiceID INT,
	@StartDate VARCHAR(50),
	@EndDate VARCHAR(50),
	@Priority INT=NULL,
	@SupportCategory INT=NULL,
	@Technology VARCHAR(20)=NULL
	 

AS
BEGIN

	SET NOCOUNT ON;
	
	SELECT CONVERT(DATE,@EndDate) AS ReportingEndDate

	SET NOCOUNT OFF;  
END


