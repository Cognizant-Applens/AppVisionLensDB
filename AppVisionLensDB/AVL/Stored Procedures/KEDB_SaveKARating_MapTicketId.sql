/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_SaveKARating_MapTicketId]
(
   @RatingAndTicketMap  [AVL].[TVP_KEDB_Rating_TicketMap]  readonly
 
 )
 AS
SET NOCOUNT ON;
  BEGIN
      BEGIN TRY
	   DECLARE @UserId NVarchar(50)='';
	   DECLARE @ProjectId BIGINT=0;
	   DECLARE @TicketId NVarchar(100)=(select top 1 TicketId from @RatingAndTicketMap);


			IF (@TicketId = '' OR @TicketId IS NULL )
				BEGIN
					INSERT INTO [AVL].[KEDB_TRN_KARating_MapTicketId](ProjectID,KAID,TicketId,IsLinked,
					   Rating,ReviewComments,Improvements,CreatedBy,CreatedOn,Isdeleted )
					   Select ProjectId,KAID,TicketId,IsLinked,
					   Rating,ReviewComments,Improvements,CreatedBy,Getdate(),0 from @RatingAndTicketMap
				END
			ELSE 
				BEGIN
					MERGE INTO [AVL].[KEDB_TRN_KARating_MapTicketId] AS target
				  using (SELECT ProjectId,KAID,TicketId,IsLinked,
					   Rating,ReviewComments,Improvements,CreatedBy  FROM   @RatingAndTicketMap) AS source
					   ON source.ProjectId = target.ProjectId AND source.TicketId = target.TicketId  AND
						  source.KAID = target.KAID	AND  source.CreatedBy = target.CreatedBy	

				  WHEN matched THEN
					update SET IsLinked=source.IsLinked,Rating=source.Rating,ReviewComments=source.ReviewComments,
					Improvements=source.Improvements,ModifiedBy=source.CreatedBy,ModifiedOn=getdate(),IsDeleted=0
	
					WHEN NOT MATCHED BY target THEN
					INSERT (ProjectId,KAID,TicketId,IsLinked,
					   Rating,ReviewComments,Improvements,CreatedBy,CreatedOn,Isdeleted )
					VALUES ( source.ProjectId,source.KAID,source.TicketId,source.IsLInked,
						source.Rating,source.ReviewComments,source.Improvements,source.CreatedBy,getdate(),0);
				END
		 End TRY

      BEGIN catch
          DECLARE @ErrorMessage VARCHAR(2000);
          SELECT @ErrorMessage = Error_message()
		  SELECT @UserId=CreatedBy,@ProjectId=ProjectId  from @RatingAndTicketMap
		  EXEC AVL_InsertError '[AVL].[KEDB_SaveKARating_MapTicketId]', @ErrorMessage,0,@ProjectId
      END catch
  END
