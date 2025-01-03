import { createRouter, createWebHistory } from "vue-router";
import CreateView from "./components/CreateView.vue";
import EditView from "./components/EditView.vue";

export const router = createRouter({
  history: createWebHistory("/dev/app"),
  routes: [
    {
      path: "/",
      component: CreateView,
    },
    {
      path: "/:id",
      component: EditView,
    },
  ],
});
