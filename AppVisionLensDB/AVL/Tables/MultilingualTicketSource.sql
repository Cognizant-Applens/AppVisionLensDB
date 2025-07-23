CREATE TABLE [AVL].[MultilingualTicketSource] (
    [TicketCreatedTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [TicketCreatedType]   VARCHAR (500) NOT NULL,
    [IsDeleted]           BIT           NOT NULL,
    [CreatedBy]           VARCHAR (50)  NOT NULL,
    [CreatedDate]         DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([TicketCreatedTypeID] ASC)
);

