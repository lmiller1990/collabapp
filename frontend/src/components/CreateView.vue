<script lang="ts" setup>
import { ref } from "vue";
import ShareModal from "./ShareModal.vue";
import Button from "./Button.vue";
import EditDoc from "./EditDoc.vue";

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
const content = ref("<p>Write something...</p>");
</script>

<template>
  Create View
  <EditDoc :content="content" @update:model-value="(html) => (content = html)">
    <ShareModal :content="content" :needs-owner-email="true" v-model="open" />
    <Button @click="open = true">Share</Button>
  </EditDoc>
</template>
