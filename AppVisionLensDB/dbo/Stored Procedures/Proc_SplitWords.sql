/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--Proc_SplitWords 'Hello all amnt'

CREATE PROCEDURE [dbo].[Proc_SplitWords] 
@ID VARCHAR(MAX),
@Sentence VARCHAR(MAX)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
 SET NOCOUNT ON
    SET XACT_ABORT ON
	CREATE table #split
	(
	TIC_ID  Varchar(MAX) NULL,
	Words Varchar(MAX) NULL
	)

 DECLARE @Words VARCHAR(MAX)
 DECLARE @tmpWord VARCHAR(MAX)
 DECLARE @t VARCHAR(MAX)
    DECLARE @I INT

    SET @Words = @Sentence    
    SELECT @I = 0

    WHILE(@I < LEN(@Words)+1)
    BEGIN
      SELECT @t = SUBSTRING(@words,@I,1)

      IF(@t != ' ')
      BEGIN
 SET @tmpWord = @tmpWord + @t
      END
      ELSE
      BEGIN
	  IF (@tmpWord IS NOT NULL)
	Insert into #split values (@ID, @tmpWord) 

   --PRINT @tmpWord
        SET @tmpWord=''
      END

 SET @I = @I + 1
        SET @t = ''
    END
		  IF (@tmpWord IS NOT NULL)
	Insert into #split values (@ID, @tmpWord) 
   --PRINT @tmpWord

    Select * from #split
	COMMIT TRAN
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[Proc_SplitWords]  ', @ErrorMessage, 0,0
		
	END CATCH  

END
