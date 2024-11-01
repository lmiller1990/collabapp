<script setup lang="ts">
import {
  Dialog,
  DialogPanel,
  TransitionChild,
  TransitionRoot,
} from "@headlessui/vue";
import { ShareIcon } from "@heroicons/vue/24/solid";
import { XMarkIcon } from "@heroicons/vue/24/solid";
import { onMounted, ref } from "vue";

const open = defineModel<boolean>();

function isInvalid(email: string) {
  const [_name, domain] = email.split("@");
  return !domain || !domain.includes(".");
}

function removeEmail(pos: number) {
  emails.value = emails.value.filter((_, i) => i !== pos);
}

const emails = ref<string[]>([]);
const current = ref("");
const emailInput = ref<HTMLInputElement>();

onMounted(() => {
  emailInput.value?.focus();
});

function handleInput() {
  if (!current.value.endsWith(",")) {
    return;
  }

  const toAdd = current.value.split(",")[0];
  emails.value.push(toAdd);
  current.value = "";
}

async function handleSubmit() {
  try {
    await window.fetch(`${import.meta.env.VITE_API_ENDPOINT}/share`, {
      method: "POST",
      mode: "cors",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(emails.value),
    });
  } catch (e) {
    // Dunno
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
                  <!-- <DialogTitle
                    as="h3"
                    class="text-base font-semibold text-gray-900"
                    >Share</DialogTitle
                  > -->
                  <div class="mt-2">
                    <p class="text-sm text-gray-500" for="email">
                      Enter email(s) to share with, separated by a comma.
                    </p>
                    <div class="flex flex-wrap">
                      <div class="mt-2">
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
                      <input
                        v-model="current"
                        id="email"
                        type="email"
                        ref="emailInput"
                        @input="handleInput"
                        name="email"
                        class="mt-4 px-1 block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm/6"
                        placeholder="you@example.com"
                      />
                    </div>
                  </div>
                </div>
              </div>
              <div class="mt-5 sm:mt-6">
                <button
                  type="submit"
                  class="inline-flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
                >
                  Share
                </button>
              </div>
            </DialogPanel>
          </TransitionChild>
        </form>
      </div>
    </Dialog>
  </TransitionRoot>
</template>
