<script lang="ts" setup>
import { useEditor, EditorContent } from "@tiptap/vue-3";
import StarterKit from "@tiptap/starter-kit";
import { computed, onMounted, ref, watchEffect } from "vue";
import { ItalicIcon } from "@heroicons/vue/24/solid";
import { BoldIcon } from "@heroicons/vue/24/solid";
import { StrikethroughIcon } from "@heroicons/vue/24/solid";
import { CodeBracketIcon } from "@heroicons/vue/24/solid";

const emits = defineEmits<{
  (e: "update:modelValue", html: string): void;
}>();

const props = defineProps<{
  modelValue: string;
}>();

const content = ref<string>(props.modelValue);

const editor = useEditor({
  content: content.value,
  extensions: [StarterKit],
});

watchEffect(() => {
  if (!editor.value) {
    return;
  }
  emits("update:modelValue", editor.value?.getHTML());
});

onMounted(() => {
  editor.value?.commands.focus("end");
});

const controls = computed(() => {
  return [
    {
      title: "Bold",
      onClick: () => editor.value?.chain().focus().toggleBold().run(),
      active: editor.value?.isActive("bold"),
      disabled: !editor.value?.can().chain().focus().toggleBold().run(),
      icon: BoldIcon,
    },
    {
      title: "Italic",
      onClick: () => editor.value?.chain().focus().toggleItalic().run(),
      active: editor.value?.isActive("italic"),
      disabled: !editor.value?.can().chain().focus().toggleItalic().run(),
      icon: ItalicIcon,
    },
    {
      title: "Strike",
      onClick: () => editor.value?.chain().focus().toggleStrike().run(),
      active: editor.value?.isActive("strike"),
      disabled: !editor.value?.can().chain().focus().toggleStrike().run(),
      icon: StrikethroughIcon,
    },
    {
      title: "Code",
      onClick: () => editor.value?.chain().focus().toggleCode().run(),
      active: editor.value?.isActive("toggleCode"),
      disabled: !editor.value?.can().chain().focus().toggleCode().run(),
      icon: CodeBracketIcon,
    },
  ];
});
</script>

<template>
  <div class="h-full flex flex-col">
    <div class="mb-1">
      <button
        v-for="control of controls"
        :disabled="control.disabled"
        class="rounded-full bg-white px-2.5 py-1 text-xs font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 mr-2"
        :class="{ '!bg-gray-200': control.active }"
        @click="control.onClick"
      >
        <component :is="control.icon" class="size-3" />
      </button>
    </div>
    <EditorContent v-model="content" :editor="editor" class="flex-grow" />
  </div>
</template>

<style>
.tiptap {
  @apply w-full h-full rounded-md p-1.5;
  /* @apply text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400; */
  @apply sm:text-sm/6;
}
</style>
