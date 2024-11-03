<script lang="ts" setup>
import Editor from "./Editor.vue";

const props = defineProps<{
  content: string;
}>();

const emits = defineEmits<{
  (e: "update:modelValue", html: string): void;
}>();

function handleUpdate(html: string) {
  emits("update:modelValue", html);
}
</script>

<template>
  <div class="grid grid-cols-2 h-full p-2">
    <div class="">
      <Editor :model-value="props.content" @update:model-value="handleUpdate" />
    </div>
    <div class="flex justify-end">
      <slot />
    </div>
  </div>
</template>
