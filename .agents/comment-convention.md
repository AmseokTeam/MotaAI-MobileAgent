# Source Comment Convention

Follow the existing project style when adding or editing source comments.

## Language and encoding

- Write source comments in concise Chinese.
- Keep files encoded as UTF-8.
- If comments display as mojibake in a terminal, treat it as a display/encoding issue first. Do not rewrite comments only because the terminal rendered them incorrectly.

## Doxygen style

- Use file headers for C source and header files:

```c
/** @file path/to/file.c
 *  @brief 简短说明该文件职责。
 */
```

- Document public types and functions with `@brief`.
- Add `@param` and `@return` when a public function has parameters or a meaningful return value.
- Keep declarations and their comments together in headers.

## Inline comments

- Use short comments to explain the meaning of variables, structure fields, and structure or initializer table entries.
- Also comment protocol fields, hardware constraints, lifecycle behavior, and non-obvious control flow.
- Prefer the style already used nearby, such as `///<` for brief variable or field notes and `/* ... */` for entries inside initializer tables.
- Do not add comments that merely repeat the code.

## Editing existing comments

- Update comments when changing the behavior, ownership, parameters, return values, or observable protocol details they describe.
- When touching nearby code, it is acceptable to fix stale, malformed, or garbled comments in that same area.
- Do not mass-rewrite unrelated comments as part of a feature or bug fix.
