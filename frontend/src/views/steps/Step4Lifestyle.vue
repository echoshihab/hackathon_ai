<script setup lang="ts">
import TodoList from '@/components/TodoList.vue'
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-6">
    <h2 class="text-xl font-bold text-gray-800 mb-2">Step 4: Lifestyle Goals</h2>
    <p class="text-sm text-gray-500 mb-6">Check off goals as you achieve them. Keep adding new ones!</p>
    <TodoList category="ShortTerm" title="Short Term Goals" />
    <TodoList category="LongTerm" title="Long Term Goals" />
    <TodoList category="Health" title="Health Goals" />
    <TodoList category="Personal" title="Personal Goals" />
  </div>
</template>
