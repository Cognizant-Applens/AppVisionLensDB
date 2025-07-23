CREATE TABLE [MAS].[ML_Prerequisite_FieldMapping] (
    [FieldMappingId]        SMALLINT      IDENTITY (1, 1) NOT NULL,
    [ITSMColumn]            VARCHAR (100) NOT NULL,
    [FieldKey]              NVARCHAR (6)  NOT NULL,
    [IsDeleted]             BIT           NOT NULL,
    [CreatedBy]             NVARCHAR (50) NOT NULL,
    [CreatedDate]           DATETIME      NOT NULL,
    [ModifiedBy]            NVARCHAR (50) NULL,
    [ModifiedDate]          DATETIME      NULL,
    [TK_TicketDetailColumn] VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([FieldMappingId] ASC)
);

