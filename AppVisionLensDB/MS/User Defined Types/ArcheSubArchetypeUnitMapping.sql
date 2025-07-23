CREATE TYPE [MS].[ArcheSubArchetypeUnitMapping] AS TABLE(
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[UNIT] [varchar](4000) NOT NULL,
	[ArcheType] [varchar](4000) NOT NULL,
	[SubArchetype] [varchar](4000) NOT NULL
)



