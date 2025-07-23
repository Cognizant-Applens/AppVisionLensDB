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

-- Description:Retrives the open date of the project
-- =============================================

--EXEC [dbo].[Mainspring_ProjectOpenDate] @ProjectID=3259,@ServiceID=4,@StartDate='2012-11-01',@EndDate='2016-12-10',@Priority='',@SupportCategory=''
CREATE PROCEDURE [MS].[Mainspring_ProjectOpenDate]
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
	
	SELECT CONVERT(DATE,MAX(ISNULL(ProjectStartDate,''))) AS ProjectStartDate FROM
	 MS.MAP_ProjectStartDate_Mapping (NOLOCK)
	WHERE ProjectID=@ProjectID

	SET NOCOUNT OFF;  
END

