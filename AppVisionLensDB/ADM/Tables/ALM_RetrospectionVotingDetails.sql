CREATE TABLE [ADM].[ALM_RetrospectionVotingDetails] (
    [VotingDetailsId]      BIGINT        IDENTITY (1, 1) NOT NULL,
    [RetrospectionpointId] BIGINT        NOT NULL,
    [VotedBy]              NVARCHAR (50) NOT NULL,
    [Createdon]            DATETIME      NOT NULL,
    [isdeleted]            BIT           NOT NULL,
    [modifiedby]           NVARCHAR (50) NULL,
    [modifiedon]           DATETIME      NULL,
    CONSTRAINT [PK_ALM_RetrospectionVotingDetailsId] PRIMARY KEY CLUSTERED ([VotingDetailsId] ASC),
    FOREIGN KEY ([RetrospectionpointId]) REFERENCES [ADM].[TRN_RetrospectionPoints] ([RetrospectionPointId])
);

