CREATE TABLE [BCS].[MAS_TicketTemplate] (
    [ID]                     INT           IDENTITY (1, 1) NOT NULL,
    [UserID]                 INT           NOT NULL,
    [ESAProjectID]           BIGINT        NOT NULL,
    [ColumnMappingAvailable] NVARCHAR (10) NOT NULL,
    [DataMappingAvailable]   NVARCHAR (10) NOT NULL,
    [IsDeleted]              INT           NOT NULL,
    [UserSessionDateTime]    DATETIME      NOT NULL
);

