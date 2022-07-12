<template>
	<h1>Follow List</h1>
	<h2>{{ info.follow }}</h2>
</template>
<script setup lang="ts">
import { onMounted } from "vue";
import { Person } from "@/api/etherApi";

const props = defineProps<{ account: string }>();
const info = reactive({ follow: [] as string[] });
onMounted(async () => {
	info.follow = await Person.getPER_follow(props.account);
});
</script>
