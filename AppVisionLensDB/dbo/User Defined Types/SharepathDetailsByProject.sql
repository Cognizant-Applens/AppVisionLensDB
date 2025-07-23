CREATE TYPE [dbo].[SharepathDetailsByProject] AS TABLE (
    [TicketUploadPrjConfigID] BIGINT         NULL,
    [SharePath]               NVARCHAR (200) NULL,
    [TicketSharepathUsers]    VARCHAR (100)  NULL);

