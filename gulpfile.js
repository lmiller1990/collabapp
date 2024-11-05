// @ts-check

import { execa } from "execa";
import { parallel } from "gulp";

function frontend() {
  return execa({ cwd: "frontend", stdout: ["pipe", "inherit"] })`pnpm run dev`;
}

function backend() {
  return execa({ stdout: ["pipe", "inherit"] })`fastapi dev collab/app.py`;
}

const dev = parallel(frontend, backend);

export { dev };
