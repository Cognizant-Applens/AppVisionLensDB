/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [MS].[MAINSPRING_MONTHLYDATA_to_DailyTable]
AS
BEGIN
   SET NOCOUNT ON;
	--To insert monthly basemeasure data to daily table
	truncate table MS.[TRN_ProjectStaging_TillDateBaseMeasure]
	INSERT INTO MS.[TRN_ProjectStaging_TillDateBaseMeasure]
	SELECT * FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure WITH (NOLOCK)
	
	--To insert monthly ticketsummary data to daily table
	TRUNCATE TABLE MS.TRN_ProjectStaging_TillDateBaseMeasure_TicketSummary
	INSERT INTO MS.TRN_ProjectStaging_TillDateBaseMeasure_TicketSummary
	SELECT * FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary WITH (NOLOCK)
	
	-- To update the last month jobstatus to 2 inorder to exceute it the next day
	update MS.TRN_MonthlyJobStatus set JobStatus = 2 where JobID IN
    (SELECT TOP 1 JobID from MS.TRN_MonthlyJobStatus where JobStatus = 4 order by JobID DESC)
	SET NOCOUNT OFF;  

END


