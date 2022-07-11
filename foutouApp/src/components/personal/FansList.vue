<template>
	<h1>Fans List</h1>
	<h2>{{ info.fans }}</h2>
</template>
<script setup lang="ts">
import { onMounted } from "vue";
import { Person } from "@/api/etherApi";

const props = defineProps<{ account: string }>();
const info = reactive({ fans: [] as string[] });
onMounted(async () => {
	info.fans = await Person.getPER_fans(props.account);
});
</script>
