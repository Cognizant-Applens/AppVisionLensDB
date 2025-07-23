/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--Exec AVL.TKT_DownloadTicketDumpDetails '383323','GetfinalcolumnMapping',147
CREATE PROCEDURE [AVL].[TKT_DownloadTicketDumpDetails] 
	@employeeid NVARCHAR(100) = NULL,
	@mode VARCHAR(100) = NULL,
	@projectid VARCHAR(100) = NULL
AS
BEGIN
	
			SET NOCOUNT ON;
			--Declare @CustomerID bigint
			--SET @CustomerID=(select CustomerID from AVL.MAS_LoginMaster where EmployeeID=@employeeid and IsDeleted=0)
			--Print @CustomerID
			--Declare @projectid bigint
			--SET @projectid= (select top 1 ProjectID from AVL.MAS_ProjectMaster where CustomerID=@CustomerID and IsDeleted=0)
			--Print @projectid
			
		IF @mode='GetfinalcolumnMapping'
			BEGIN
			   IF EXISTS(SELECT 1 FROM AVL.MAS_LoginMaster WHERE EmployeeID=@employeeid AND ProjectID=@projectid AND IsDeleted=0)
			    BEGIN
			      IF EXISTS(SELECT TOP 1 ID FROM [ML].[ConfigurationProgress] WHERE IsTicketDescriptionOpted=0 AND ProjectID=@projectid AND IsDeleted=0)
			       BEGIN
				     SELECT SSIScmID,ProjectColumn into #ITSM_PRJ_SSISColumnMapping FROM [AVL].[ITSM_PRJ_SSISColumnMapping] WHERE ProjectID=@projectid AND IsDeleted=0  AND  ProjectColumn <>'' ORDER BY SSIScmID asc
				     
		
				     SELECT VALUE As [ProjectColumn] into #WorkPattern FROM
                     (
                        SELECT
                             t.TicketDescriptionBasePattern,
                             t.TicketDescriptionSubPattern,
                             t.ResolutionRemarksBasePattern,
		                     t.ResolutionRemarksSubPattern
                        FROM
                     ML.WorkPatternConfiguration AS t WHERE t.ProjectID=@projectid
                     ) AS SourceTable
                     UNPIVOT
                     (
                     VALUE FOR ProjectColumn IN
                     (TicketDescriptionBasePattern, TicketDescriptionSubPattern,ResolutionRemarksBasePattern,ResolutionRemarksSubPattern)) AS unpvt
                 
				 INSERT INTO #ITSM_PRJ_SSISColumnMapping SELECT ProjectColumn FROM #WorkPattern

				   SELECT ProjectColumn FROM #ITSM_PRJ_SSISColumnMapping ORDER BY SSIScmID asc
				 
				 END 
		         ELSE
			      BEGIN
				   SELECT ProjectColumn FROM [AVL].[ITSM_PRJ_SSISColumnMapping] WHERE ProjectID=@projectid AND IsDeleted=0  AND  ProjectColumn <>'' ORDER BY SSIScmID asc
 
		          END
             END
			END
		ELSE
		    BEGIN
				SELECT ServiceDartColumn,ProjectColumn FROM [AVL].[ITSM_PRJ_SSISColumnMapping] WHERE ProjectID=@projectid AND IsDeleted=0  AND  ProjectColumn <>'' ORDER BY SSIScmID asc
 
			END
END
