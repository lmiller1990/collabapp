<script setup lang="ts">
import { ref } from "vue";
import Editor from "./components/Editor.vue";

const msg = ref("");

async function greet() {
  // const res = await window.fetch(`${import.meta.env.VITE_API_ENDPOINT}/greet`, {
  const res = await window.fetch(`/api/greet`, {
    mode: "cors",
    headers: {
      "Content-Type": "application/json", // or any other required header
    },
  });
  const data = await res.json();
  msg.value = data.foo;
}

greet();
</script>

<template>
  <div class="grid grid-cols-2 h-full p-2">
    <div class="">
      <Editor />
    </div>
    <!-- <div class="">other</div> -->
  </div>
</template>

<style>
html,
body,
#app {
  height: 100vh;
}
</style>
