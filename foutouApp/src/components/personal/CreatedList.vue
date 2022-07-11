<template>
	<h1>Created List</h1>
  <h2>{{ info.ownedFT }}</h2>
</template>
<script setup lang="ts">
import { onMounted } from "vue";
import { Person } from "@/api/etherApi";

const props = defineProps<{ account: string }>();
const info = reactive({ ownedFT: [] as number[] });
onMounted(async () => {
  info.ownedFT = await Person.getPER_ownedFT(props.account);
});
</script>
