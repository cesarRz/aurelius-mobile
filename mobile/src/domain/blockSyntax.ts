import type { DocumentBlock } from "./entities";

export function interpretBlockSyntax(block: DocumentBlock): DocumentBlock {
  const next = { ...block };
  const text = next.text;

  if (text.startsWith("### ")) {
    next.type = "heading3";
    next.text = text.slice(4);
  } else if (text.startsWith("## ")) {
    next.type = "heading2";
    next.text = text.slice(3);
  } else if (text.startsWith("# ")) {
    next.type = "heading1";
    next.text = text.slice(2);
  } else if (text.startsWith("- [ ] ")) {
    next.type = "checklist";
    next.text = text.slice(6);
  } else if (text.startsWith("[] ")) {
    next.type = "checklist";
    next.text = text.slice(3);
  } else if (text.startsWith("- ")) {
    next.type = "bullet";
    next.text = text.slice(2);
  } else if (text.startsWith("> ")) {
    next.type = "quote";
    next.text = text.slice(2);
  } else if (text.startsWith("` ")) {
    next.type = "code";
    next.text = text.slice(2);
  }

  return next;
}
