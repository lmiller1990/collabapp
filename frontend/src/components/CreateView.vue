<script lang="ts" setup>
import { ref } from "vue";
import Editor from "./Editor.vue";
import ShareModal from "./ShareModal.vue";
import Button from "./Button.vue";

const msg = ref("");

async function greet() {
  const res = await window.fetch(`${import.meta.env.VITE_API_ENDPOINT}/greet`, {
    mode: "cors",
    headers: {
      "Content-Type": "application/json", // or any other required header
    },
  });
  const data = await res.json();
  msg.value = data.foo;
}

greet();

const open = ref(true);
</script>

<template>
  <div class="grid grid-cols-2 h-full p-2">
    <div class="">
      <Editor />
    </div>
    <div class="flex justify-end">
      <div>
        <ShareModal :needs-owner-email="true" v-model="open" />
        <Button @click="open = true">Share</Button>
      </div>
    </div>
  </div>
</template>
