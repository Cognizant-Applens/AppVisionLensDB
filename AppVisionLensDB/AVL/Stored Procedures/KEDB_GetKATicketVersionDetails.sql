CREATE PROCEDURE [AVL].[KEDB_GetKATicketVersionDetails]-- 'KA68888000042'
(@KAticketID VARCHAR(20))
AS 
-- EXEC [AVL].[KEDB_GetKATicketVersionDetails] 'KA43478000005'
--DECLARE @KAticketID VARCHAR(20) ='KA43478000031'
BEGIN
With [VersionCTE](KAId,KAticketID,ProjectId,CreatedOn,VersionNo,Remarks)
	As
	(
	  SELECT DISTINCT KAVD.KAId, KAVD.KATicketId,KAVD.ProjectId, KAVD.CreatedOn,
	   CAST((ROW_Number() Over(Order By KAVD.CreatedOn) - 0) AS bigint)+.0  AS VersionNo,Remarks  
	  FROM  [AVL].[KEDB_TRN_KATicketVersionDetails] KAVD (NOLOCK)
	  WHERE  KAVD.KAticketID=@KAticketID
	  group by KAVD.KAId, KAVD.KATicketId,KAVD.ProjectId, KAVD.CreatedOn,Remarks
	)
	--select * from [VersionCTE]
	SELECT top 3*,  CAST((ROW_Number() Over(Order By VersionNo desc) - 0) AS bigint) AS Rowno	into #temp
	FROM [VersionCTE] --ORDER BY rowno desc

		select top 3 * from #temp order by Rowno desc

END
