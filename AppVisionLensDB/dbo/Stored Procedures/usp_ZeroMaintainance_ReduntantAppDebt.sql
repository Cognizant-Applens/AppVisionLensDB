/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--=========================================
-- Program Name:[usp_ZeroMaintainance_ReduntantAppDebt] 
-- Author: 
-- Description: usp_ZeroMaintainance_ReduntantAppDebt
--Created Date:
--Modified Date Modified By version Description: Dinesh K on 03-Apr for CAST
--==========================================
CREATE PROCEDURE [dbo].[usp_ZeroMaintainance_ReduntantAppDebt]

(

	@BUId VARCHAR(1000),

	@AccountID VARCHAR(MAX),

	@ProjectID VARCHAR(MAX),

	@StartDate DATETIME,

	@EndDate DATETIME,

	@CognizantID INT = 0,

	@Options NVARCHAR(100) ='All',

	@IncludeOthers INT = 1

)

AS 

BEGIN



EXECUTE [CTSC00832557901].[AVMDART].[dbo].[sp_ZeroMaintainance_ReduntantAppDebt] 

@BUId, @AccountID, @ProjectID, @StartDate, @EndDate, @CognizantID, @Options, @IncludeOthers







END
