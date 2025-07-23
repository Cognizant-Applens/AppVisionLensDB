/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [AVL].[Effort_GetTicketIdByAccount] 

	@CustomerID BIGINT

AS

BEGIN

	BEGIN TRY
	SET NOCOUNT ON

		DECLARE @TicketFormat nvarchar(50);

		DECLARE @CurrentId nvarchar(50);

		DECLARE @CurrentTicketID nvarchar(50);

		DECLARE @ticketNo nvarchar(50);;

		DECLARE @InsertedID BIGINT;


		SELECT  TOP 1 @TicketFormat=SDTicketFormat FROM [AVL].[Customer] WHERE CustomerID=@CustomerID    

		IF EXISTS(SELECT NEXTID FROM [AVL].[TK_MAP_IDGeneration] With (NOLOCK) WHERE CustomerID=@CustomerID )    

		BEGIN             

			SELECT @CurrentId=NEXTID FROM [AVL].[TK_MAP_IDGeneration] With (NOLOCK) WHERE CustomerID=@CustomerID

		END    

		ELSE    

		BEGIN   

			INSERT INTO  [AVL].[TK_MAP_IDGeneration] (CustomerID,NextID,[CreatedDate])

				VALUES(@CustomerID,0000001,GETDATE())  

			SET @InsertedID=(SELECT SCOPE_IDENTITY())

			SELECT @CurrentId= (SELECT cast(NEXTID as nvarchar(10))FROM [AVL].[TK_MAP_IDGeneration] With (NOLOCK) WHERE ID=@InsertedID)  

		END    

		IF (@CurrentId between 1 and 9)  OR (@CurrentId = 1)  

		begin    

			set @CurrentTicketID='000000'+cast(@CurrentId as varchar(10))    

		end    

		ELSE IF @CurrentId between 10 and 99    

		begin    

			set @CurrentTicketID='00000'+cast(@CurrentId as varchar(10))    

		end    

		ELSE IF @CurrentId between 100and 999    

		begin    

			set @CurrentTicketID='0000'+cast(@CurrentId as varchar(10))    

		end    

		ELSE IF @CurrentId between 1000 and 9999    

		begin    

			set @CurrentTicketID='000'+cast(@CurrentId as varchar(10))    

		end    

		ELSE IF @CurrentId between 10000 and 99999    

		begin    

			set @CurrentTicketID='00'+cast(@CurrentId as varchar(10))    

		end    

		ELSE IF @CurrentId between 1000000and 9999999   

		begin    

			set @CurrentTicketID='0'+cast(@CurrentId as varchar(10))    

		end   

		ELSE IF @CurrentId between 10000000and 99999999   

		begin    

			set @CurrentTicketID='0'+cast(@CurrentId as varchar(10))    

		end  

		IF LTRIM(RTRIM(@TicketFormat))='' OR @TicketFormat IS NULL
			BEGIN
				SET @TicketFormat='AppLens'
			END

		SET @ticketNo=cast((ISNULL(@TicketFormat,'AppLens')+ISNULL(@CurrentTicketID,0))as varchar(100))  

		select   @ticketNo as TicketID

   SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    

		EXEC AVL_InsertError '[AVL].[Effort_GetTicketIdByAccount] ', @ErrorMessage, @CustomerID,0

	END CATCH  


END
