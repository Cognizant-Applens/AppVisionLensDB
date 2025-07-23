CREATE TYPE [MS].[ProjectAttributes] AS TABLE(
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ProjectId] [bigint] NOT NULL,
	[AttributeValue] [varchar](4000) NOT NULL,
	[Archetype] [varchar](4000) NOT NULL
)



