
Create Procedure [AVL].[MONTHS]
AS   

BEGIN 
;with [GetLast6Months](Monthdate) 
AS
(
    SELECT DATEADD(month, DATEDIFF(month, 0, eomonth(getdate(),-6)), 0)   AS Monthdate
    UNION ALL
    SELECT DATEADD(MONTH, 1, Monthdate) 
        FROM [GetLast6Months]
        WHERE ( DATEADD(MONTH, 1, Monthdate) <=  EOMONTH( getdate())   ) 
)
select datename(month,Monthdate) as Month,Monthdate from [GetLast6Months]

END