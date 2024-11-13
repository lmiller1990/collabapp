import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

// https://vite.dev/config/
export default defineConfig((config) => {
  return {
    base:
      config.mode === "production"
        ? `https://lachlan-collab-${process.env.TF_VAR_environment}.s3.ap-southeast-2.amazonaws.com/`
        : "",
    plugins: [vue()],
    server: {
      proxy: {
        "/api": {
          target: "http://localhost:8000",
          changeOrigin: true,
          rewrite: (path) => {
            return path.replace(/^\/api/, "");
          },
        },
      },
    },
  };
});
