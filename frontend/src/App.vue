<script setup lang="ts">
import { ref } from "vue";

const msg = ref("");

async function greet() {
  const res = await window.fetch(`${import.meta.env.VITE_API_ENDPOINT}/greet`);
  const data = await res.json();
  msg.value = data.foo;
}

greet();
</script>

<template>
  <div>Hello world!</div>
  <div>Message from backend is: {{ msg }}</div>
</template>
