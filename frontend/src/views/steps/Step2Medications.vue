<script setup lang="ts">
import { ref, onMounted } from "vue";
import api from "@/services/api";
import DataTable from "@/components/DataTable.vue";
import FormInput from "@/components/FormInput.vue";

interface Medication {
  id: number;
  name: string;
  reason: string;
  dosageInstructions: string;
}

const medications = ref<Medication[]>([]);
const name = ref("");
const reason = ref("");
const dosageInstructions = ref("");

async function load() {
  const { data } = await api.get("/medications");
  medications.value = data;
}

async function add() {
  if (!name.value.trim()) return;
  const { data } = await api.post("/medications", {
    name: name.value,
    reason: reason.value,
    dosageInstructions: dosageInstructions.value,
  });
  medications.value.push(data);
  name.value = "";
  reason.value = "";
  dosageInstructions.value = "";
}

async function remove(id: number) {
  await api.delete(`/medications/${id}`);
  medications.value = medications.value.filter((m) => m.id !== id);
}

onMounted(load);
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-6">
    <h2 class="text-xl font-bold text-gray-800 mb-4">Step 2: Medications</h2>
    <div class="bg-white rounded-lg border border-gray-200 p-4 mb-6">
      <h3 class="font-semibold text-gray-700 mb-3">Add Medication</h3>
      <FormInput
        label="Medication Name"
        v-model="name"
        placeholder="e.g., Aspirin"
      />
      <FormInput
        label="Reason for Taking"
        v-model="reason"
        placeholder="e.g., Prevent blood clots"
      />
      <FormInput
        label="Dosage / Instructions"
        v-model="dosageInstructions"
        placeholder="e.g., 81mg once daily with food"
      />
      <button
        @click="add"
        class="w-full py-2 px-4 bg-red-600 text-white font-medium rounded-md hover:bg-red-700"
      >
        Add Medication
      </button>
    </div>
    <DataTable
      :columns="['Name', 'Reason', 'Dosage/Instructions']"
      :keys="['name', 'reason', 'dosageInstructions']"
      :rows="medications as Record<string, unknown>[]"
      @delete="remove"
    />
  </div>
</template>
