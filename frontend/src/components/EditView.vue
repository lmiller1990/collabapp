<script lang="ts" setup>
import { useRoute } from "vue-router";
import EditDoc from "./EditDoc.vue";

const route = useRoute();
const content = defineModel<string>();

async function fetchDoc() {
  const res = await window.fetch(
    `${import.meta.env.VITE_API_ENDPOINT}/documents/${route.params.id}`,
    {
      mode: "cors",
      headers: {
        "Content-Type": "application/json", // or any other required header
      },
    },
  );
  const data = (await res.json()) as { doc: string };
  const parsed = JSON.parse(data.doc) as { text: string };
  content.value = parsed.text;
}

fetchDoc();
</script>

<template>
  <EditDoc
    v-if="content"
    :content="content"
    @update:model-value="(html) => (content = html)"
  />
</template>
