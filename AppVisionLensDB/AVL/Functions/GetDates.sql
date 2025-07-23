
CREATE FUNCTION [AVL].[GetDates]
(	
	-- Add the parameters for the function here
	@MinDate DATE, 
	@MaxDate DATE
)
RETURNS table as 
return(
SELECT * FROM 
(SELECT  TOP (DATEDIFF(DAY, @MinDate, @MaxDate) + 1)
        Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY [a].[object_id]) - 1, @MinDate), 
	DATENAME(WEEKDAY,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY [a].[object_id]) - 1, @MinDate)) AS WeekDay,
	DATEPART(WEEKDAY,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY [a].[object_id]) - 1, @MinDate)) AS WeekDayNumber
FROM    [sys].[all_objects] a 
        CROSS JOIN [sys].[all_objects] b
		WHERE @MinDate<=@MaxDate
		) FinalTable
WHERE FinalTable.WeekDayNumber NOT IN (1,7)
		
)

