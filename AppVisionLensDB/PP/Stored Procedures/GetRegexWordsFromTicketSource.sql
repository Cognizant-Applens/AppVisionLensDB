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
-- Author	  :	441778
-- Create date: 2020-09-14
-- Description:	To Get Regex Words
-- =============================================
CREATE PROCEDURE [PP].[GetRegexWordsFromTicketSource]
-- Add the parameters for the stored procedure here
@RegexJobStatusID BIGINT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IsDownloaded BIT = 0;
	DECLARE @ProjectID BIGINT;

	--SELECT @ProjectID =  ProjectID FROM [AVL].[Regex_TicketSource] WHERE RegexJobStatusID = @RegexJobStatusID

	SELECT @ProjectID=PR.ProjectID from AVL.RegexJobStatus RJ
    INNER JOIN AVl.PRJ_RegexConfiguration PR on RJ.RegexConfigID=PR.RegexConfigID
    where RJ.ID=@RegexJobStatusID

	SELECT @IsDownloaded = 1 FROM AVL.RegexWords WHERE ProjectID = @ProjectID
	
	IF(@IsDownloaded = 0)
	BEGIN	
	SELECT TS.ID,TS.Projectid,PM.ProjectName,TS.StaticOutput FROM [AVL].[Regex_TicketSource] TS
	JOIN AVL.MAS_ProjectMaster PM ON TS.ProjectID = PM.ProjectID WHERE RegexJobStatusID = @RegexJobStatusID
	END

	ELSE
	BEGIN
	SELECT RW.RegexWordID AS ID,RW.ProjectID,PM.ProjectName,RW.RegexWord AS StaticOutput FROM AVL.RegexWords RW 
	JOIN AVL.MAS_ProjectMaster PM ON RW.ProjectID = PM.ProjectID and RW.ProjectID=@ProjectID AND RW.IsDeleted = 0
	END
	
			
END
