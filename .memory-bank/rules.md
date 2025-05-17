# Memory Bank Rules

## Purpose
The memory bank system serves as a persistent knowledge base for the Compass4Success project, storing important decisions, implementations, and progress tracking.

## Directory Structure
```
.memory-bank/
├── rules.md           # This file - defines memory bank usage rules
├── progress.md        # Tracks implementation progress
├── decisions/         # Stores important architectural and design decisions
├── features/          # Documents feature implementations
└── api/              # API documentation and specifications
```

## File Naming Conventions
1. Use lowercase with hyphens for file names
2. Use .md extension for all documentation files
3. Include date prefix for decision documents (YYYY-MM-DD-)
4. Use descriptive names that reflect content

## Documentation Rules

### 1. Progress Tracking
- Update progress.md for each major implementation
- Use checkboxes for pending items
- Include implementation dates
- Document both completed and planned features
- Link to relevant decision documents

### 2. Decision Documentation
- Store in decisions/ directory
- Include date in filename
- Document:
  - Context and problem
  - Considered alternatives
  - Chosen solution
  - Rationale
  - Impact and trade-offs

### 3. Feature Documentation
- Store in features/ directory
- Include:
  - Feature overview
  - Implementation details
  - Usage examples
  - Dependencies
  - Testing requirements

### 4. API Documentation
- Store in api/ directory
- Document:
  - Endpoints
  - Request/response formats
  - Authentication
  - Rate limits
  - Versioning

## Update Rules
1. Always update relevant documentation when:
   - Implementing new features
   - Making architectural decisions
   - Changing existing functionality
   - Adding new APIs
   - Fixing significant bugs

2. Documentation Format:
   - Use Markdown for all documentation
   - Include clear headings and sections
   - Use lists for better readability
   - Include code examples when relevant
   - Link to related documents

3. Review Process:
   - Review documentation with each PR
   - Update progress.md weekly
   - Validate links and references
   - Ensure consistency across documents

## Usage Guidelines
1. Always check existing documentation before:
   - Starting new features
   - Making architectural changes
   - Implementing new APIs
   - Modifying existing functionality

2. When adding new documentation:
   - Follow the directory structure
   - Use appropriate templates
   - Include all required sections
   - Link to related documents

3. When updating documentation:
   - Maintain version history
   - Update related documents
   - Notify team of significant changes
   - Validate all links and references

## Templates

### Decision Document Template
```markdown
# [YYYY-MM-DD] Decision Title

## Context
[Describe the situation and problem]

## Alternatives Considered
1. [Alternative 1]
   - Pros:
   - Cons:

2. [Alternative 2]
   - Pros:
   - Cons:

## Decision
[Describe the chosen solution]

## Rationale
[Explain why this solution was chosen]

## Impact
[Describe the impact and trade-offs]

## Related Documents
- [Link to related documents]
```

### Feature Document Template
```markdown
# Feature Name

## Overview
[Brief description of the feature]

## Implementation
[Detailed implementation notes]

## Usage
[Usage examples and guidelines]

## Dependencies
[List of dependencies]

## Testing
[Testing requirements and examples]

## Related Documents
- [Link to related documents]
```

### API Document Template
```markdown
# API Name

## Overview
[Brief description of the API]

## Endpoints
### [Endpoint Name]
- Method: [HTTP Method]
- Path: [Endpoint Path]
- Description: [Endpoint description]
- Request: [Request format]
- Response: [Response format]
- Authentication: [Auth requirements]
- Rate Limit: [Rate limit info]

## Examples
[Usage examples]

## Error Codes
[List of error codes and meanings]

## Related Documents
- [Link to related documents]
``` 