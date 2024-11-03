<script setup lang="ts">
import {
  Dialog,
  DialogPanel,
  TransitionChild,
  TransitionRoot,
} from "@headlessui/vue";
import { ShareIcon } from "@heroicons/vue/24/solid";
import { XMarkIcon } from "@heroicons/vue/24/solid";
import { ref } from "vue";
import Input from "./Input.vue";
import Button from "./Button.vue";
import { useRouter } from "vue-router";

const props = defineProps<{
  /**
   * Whether we show the "enter your own email" field (new document)
   * or just the "share" field (existing document).
   */
  needsOwnerEmail: boolean;

  /**
   * The content of the editor as HTML.
   */
  content: string;
}>();

const open = defineModel<boolean>();

function isInvalid(email: string) {
  const [_name, domain] = email.split("@");
  return !domain || !domain.includes(".");
}

function removeEmail(pos: number) {
  emails.value = emails.value.filter((_, i) => i !== pos);
}

const emails = ref<string[]>([]);
const ownEmail = ref("");
const current = ref("");

function addEmail(email: string) {
  emails.value.push(email);
  current.value = "";
}

function handleInput() {
  if (!current.value.endsWith(",")) {
    return;
  }
  const toAdd = current.value.split(",")[0];
  addEmail(toAdd);
}

const loading = ref(false);
const router = useRouter();

async function handleSubmit() {
  if (current.value) {
    addEmail(current.value);
  }

  loading.value = true;

  try {
    console.log("Fetching...");
    const res = await window.fetch(
      `${import.meta.env.VITE_API_ENDPOINT}/create`,
      {
        method: "POST",
        mode: "cors",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          shared_with: emails.value,
          email: ownEmail.value,
          text: props.content,
        }),
      },
    );
    const json = (await res.json()) as { uuid: string };
    router.push(`/${json.uuid}`);
  } catch (e) {
    console.log("error", e);
    // Dunno
  } finally {
    console.log("done");
    // loading.value = false;
  }
}
</script>

<template>
  <TransitionRoot as="template" :show="open">
    <Dialog class="relative z-10" @close="open = false">
      <TransitionChild
        as="template"
        enter="ease-out duration-300"
        enter-from="opacity-0"
        enter-to="opacity-100"
        leave="ease-in duration-200"
        leave-from="opacity-100"
        leave-to="opacity-0"
      >
        <div
          class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
        />
      </TransitionChild>

      <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
        <form
          class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0"
          @submit.prevent="handleSubmit"
        >
          <TransitionChild
            as="template"
            enter="ease-out duration-300"
            enter-from="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
            enter-to="opacity-100 translate-y-0 sm:scale-100"
            leave="ease-in duration-200"
            leave-from="opacity-100 translate-y-0 sm:scale-100"
            leave-to="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          >
            <DialogPanel
              class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-sm sm:p-6"
            >
              <div>
                <div
                  class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-green-100"
                >
                  <ShareIcon
                    class="h-6 w-6 text-green-600"
                    aria-hidden="true"
                  />
                </div>
                <div class="mt-3 text-center sm:mt-5">
                  <div class="mt-2">
                    <div class="text-sm text-gray-500">
                      <div class="text-left my-2">Your email:</div>
                      <Input v-model="ownEmail" />
                    </div>
                    <p class="text-sm text-gray-500 text-left my-2">
                      Emails to share with, separated with a comma:
                    </p>
                    <div class="flex flex-wrap mb-2">
                      <span
                        v-for="(email, idx) of emails"
                        @click="() => removeEmail(idx)"
                        class="bg-green-100 p-1 rounded mr-1 inline-flex items-center h-8"
                        :class="{
                          'bg-red-100 hover:bg-red-200 cursor-pointer':
                            isInvalid(email),
                        }"
                      >
                        <XMarkIcon class="size-3 mr-1" />
                        {{ email }}</span
                      >
                    </div>
                    <Input v-model="current" @input="handleInput" />
                  </div>
                </div>
              </div>
              <div class="mt-5 sm:mt-6">
                <Button class="w-full" type="submit" :loading="loading">
                  Share
                </Button>
              </div>
            </DialogPanel>
          </TransitionChild>
        </form>
      </div>
    </Dialog>
  </TransitionRoot>
</template>
