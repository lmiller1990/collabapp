import { createRouter, createWebHistory } from "vue-router";
import CreateView from "./components/CreateView.vue";
import EditView from "./components/EditView.vue";

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/",
      component: CreateView,
    },
    {
      path: "/:uuid",
      component: EditView,
    },
  ],
});
