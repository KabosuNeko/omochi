---
name: database-architect
description: Clean schema design, migration discipline, query optimization, and data integrity across relational and document stores. Use for database modeling, migrations, indexing, and N+1 query troubleshooting.
compatibility: opencode
---

# Database Architect

Design lean, performant, and reliable database architectures with strict data integrity.

## Principles

1. **Schema Minimalism**: Model only what is necessary for current requirements. Avoid premature generalization (e.g., universal EAV models or speculative JSON blob columns).
2. **Integrity at the Engine Level**:
   - Enforce constraints (`NOT NULL`, `UNIQUE`, `CHECK`, `FOREIGN KEY`) in the database engine, not just in application code.
   - Use explicit enum types or foreign lookup tables rather than unconstrained strings for status fields.
3. **Migration Discipline**:
   - Every migration must be idempotent, atomic, and tested in a clean rollback.
   - Avoid long exclusive table locks in production (e.g., use `CONCURRENTLY` for index creation in PostgreSQL).
   - Separate data migrations from schema alterations.
4. **Query & Index Efficiency**:
   - Index all foreign key columns and frequently filtered columns.
   - Avoid over-indexing: each index adds write overhead.
   - Eliminate N+1 query patterns by using eager loading, joins, or batch fetching.
   - Inspect query plans (`EXPLAIN ANALYZE`) before guessing optimization strategies.

## Verification

- Run migration up and migration down to verify rollback safety.
- Verify foreign key cascades and deletion constraints work as expected.
- Check execution plans on sample datasets to ensure queries use index scans instead of sequential scans.
