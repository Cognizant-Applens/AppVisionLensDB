CREATE  PROCEDURE [dbo].[ShrinkDB]
  
AS
BEGIN
  ALTER DATABASE [AppVisionLens]
SET RECOVERY SIMPLE;



-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (AppVisionLens_log, 1);



-- Reset the database recovery model.
ALTER DATABASE [AppVisionLens]
SET RECOVERY FULL;





END