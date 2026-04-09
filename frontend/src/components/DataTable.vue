<script setup lang="ts">
defineProps<{
  columns: string[]
  rows: Record<string, unknown>[]
  keys: string[]
}>()

const emit = defineEmits<{
  delete: [id: number]
}>()
</script>

<template>
  <div class="overflow-x-auto">
    <table class="min-w-full divide-y divide-gray-200 text-sm">
      <thead class="bg-gray-50">
        <tr>
          <th
            v-for="col in columns"
            :key="col"
            class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
          >
            {{ col }}
          </th>
          <th class="px-3 py-2"></th>
        </tr>
      </thead>
      <tbody class="bg-white divide-y divide-gray-200">
        <tr v-for="row in rows" :key="(row.id as number)">
          <td v-for="key in keys" :key="key" class="px-3 py-2 text-gray-700 whitespace-pre-wrap">
            {{ row[key] }}
          </td>
          <td class="px-3 py-2">
            <button
              @click="emit('delete', row.id as number)"
              class="text-red-500 hover:text-red-700 text-xs font-medium"
            >
              Delete
            </button>
          </td>
        </tr>
        <tr v-if="rows.length === 0">
          <td :colspan="columns.length + 1" class="px-3 py-4 text-center text-gray-400 text-sm">
            No entries yet.
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
