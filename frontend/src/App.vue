<script setup lang="ts">
import { ref } from "vue";

const msg = ref("");

async function greet() {
  // const res = await window.fetch(`${import.meta.env.VITE_API_ENDPOINT}/greet`, {
  const res = await window.fetch(
    `https://x0vimwzyy8.execute-api.ap-southeast-2.amazonaws.com/dev/greet`,
    {
      mode: "cors",
      headers: {
        "Content-Type": "application/json", // or any other required header
      },
    }
  );
  const data = await res.json();
  msg.value = data.foo;
}

greet();
</script>

<template>
  <div>Hello world!</div>
  <div>Message from backend is: {{ msg }}</div>
</template>
