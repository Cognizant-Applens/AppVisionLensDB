/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC [AVL].[TK_GetTicketUploadDetails] 'GetColumnByTicketID',174
CREATE PROCEDURE [AVL].[TK_GetTicketUploadDetails]
@mode varchar(50)=NULL, 
@ProjectID INT=null
AS
BEGIN
	
	SET NOCOUNT ON;

   IF @mode='GetColumns'
   BEGIN

   IF EXISTS(SELECT TOP 1 ID FROM [ML].[ConfigurationProgress] WHERE IsTicketDescriptionOpted=0 AND ProjectID=@ProjectID AND IsDeleted=0)
	  BEGIN
	    SELECT ProjectColumn,ServiceDartColumn FROM [AVL].[ITSM_PRJ_SSISColumnMapping] With (NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0
	    UNION 
		SELECT ProjectColumn, ProjectColumn as ServiceDartColumn
	    FROM
           (
              SELECT
                   t.TicketDescriptionBasePattern,
                   t.TicketDescriptionSubPattern,
                   t.ResolutionRemarksBasePattern,
	               t.ResolutionRemarksSubPattern
              FROM
           ML.WorkPatternConfiguration AS t With (NOLOCK) WHERE t.ProjectID=@ProjectID
           ) AS SourceTables
           UNPIVOT
           (
            ProjectColumn FOR projects1 in 
			(TicketDescriptionBasePattern, TicketDescriptionSubPattern,ResolutionRemarksBasePattern,ResolutionRemarksSubPattern)) AS unpvt
	    END 
		ELSE 
		BEGIN
			SELECT ServiceDartColumn, ProjectColumn 
			FROM [AVL].[ITSM_PRJ_SSISColumnMapping] With (NOLOCK) WHERE IsDeleted =0 
			AND ProjectID =@ProjectID
		END
   END

   Else if @mode='GetColumnByTicketID'
   BEGIN
 --  SELECT ServiceDartColumn 
	--FROM  [AVL].[ITSM_PRJ_SSISColumnMapping] 
	--WHERE ProjectColumn='TicketID' and ProjectID = @ProjectID
	  SELECT ProjectColumn 
	FROM  [AVL].[ITSM_PRJ_SSISColumnMapping] 
	WHERE ServiceDartColumn='Ticket ID' and ProjectID = @ProjectID AND IsDeleted = 0
   END

END
