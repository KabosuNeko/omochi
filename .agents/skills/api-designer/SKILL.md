---
name: api-designer
description: Design pragmatic, consistent, and contract-driven APIs across REST, OpenAPI, and RPC protocols. Focuses on predictable resource structures, standard status codes, deterministic pagination, and input validation. Use for API routing, endpoint design, or contract specifications.
compatibility: opencode
---

# API Designer

Build clean, intuitive, and robust APIs with clear contracts and predictable behavior.

## Principles

1. **Resource-Oriented REST Structure**:
   - Use plural nouns for resource collections (`/api/v1/projects`, `/api/v1/projects/{id}/tasks`).
   - Use standard HTTP methods strictly: `GET` (safe/read), `POST` (create), `PUT` (full replace), `PATCH` (partial update), `DELETE` (remove).
2. **Predictable Status Codes**:
   - `200 OK` for successful reads/updates returning data.
   - `201 Created` with `Location` header for newly created resources.
   - `204 No Content` for successful deletes or updates with empty response.
   - `400 Bad Request` / `422 Unprocessable Entity` for schema validation failures.
   - `401 Unauthorized` for missing/invalid auth; `403 Forbidden` for insufficient permissions.
   - `404 Not Found` for nonexistent resources.
   - `409 Conflict` for state or versioning collisions.
3. **Structured Error Handling**:
   - Use a uniform error response envelope (e.g., RFC 7807 problem details or `{ error: { code: string, message: string, details?: unknown } }`).
   - Never leak internal database stack traces or infrastructure paths in client-facing error bodies.
4. **Boundary Validation & Types**:
   - Validate every incoming payload at the network boundary using a schema validator (Zod, Pydantic, TypeBox).
   - Reject unexpected keys or unvalidated inputs.
5. **Deterministic Pagination & Filtering**:
   - Always bound queries with a strict maximum limit (e.g., max 100 items per request).
   - Prefer cursor-based pagination for high-volume or real-time data feeds; use limit/offset only for bounded admin lists.

## Verification

- Validate schema conformance against sample valid and invalid payloads.
- Verify status codes and error payloads for unauthorized, not-found, and malformed requests.
- Verify pagination parameters prevent unconstrained memory exhaustion.
