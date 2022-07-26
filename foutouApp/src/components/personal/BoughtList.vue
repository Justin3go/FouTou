<template>
<h1>Bought List</h1>
<h2>{{info.boughtFT}}</h2>
</template>
<script setup lang="ts">
import { onMounted } from "vue";
import { Person } from "@/api/ether.api";

const props = defineProps<{ account: string }>();
const info = reactive({ boughtFT: [] as number[] });
onMounted(async () => {
  info.boughtFT = await Person.getPER_boughtFT(props.account);
});
</script>