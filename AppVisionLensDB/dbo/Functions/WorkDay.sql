Create function WorkDay(@CurrDate datetime, @DaysToAdd int)
returns datetime
as
begin
    declare @WeeksToAdd int;
    declare @dw int;

    set @WeeksToAdd = (@DaysToAdd / 5) * 7
    set @DaysToAdd = @DaysToAdd % 5 

    set @CurrDate = DateAdd(dd,@WeeksToAdd + @DaysToAdd, @CurrDate)
    set @dw = datepart(dw,@CurrDate)

    if sign(@DaysToAdd) < 0 
        begin
        if @dw = 1 set @CurrDate = @CurrDate - 2
        if @dw = 7 set @CurrDate = @CurrDate - 1
        end
    else
        begin
        if @dw = 1 set @CurrDate = @CurrDate + 1
        if @dw = 7 set @CurrDate = @CurrDate + 2
        end

return @CurrDAte
end

--Note: The function assumes that the starting date you specify will be a week day. 


--DECLARE @LastBusinessDay Datetime
--SELECT @LastBusinessDay = dbo.WorkDay(GetDATE(),-30)