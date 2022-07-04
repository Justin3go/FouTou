<template>
	<div>
		<h1>Personal</h1>
    <connect-wallet :visible="true"></connect-wallet>
	</div>
</template>
<script setup lang="ts">
// todo 以及加了一定的数据，同时PER_ITEMS也有了对应的解析结构，接下来就是需要请求API然后写写界面了
import { onMounted } from "vue";
import { Person } from "@/api/etherApi";
import { useEtherStore } from "@/store/etherStore";
import ConnectWallet from "@/components/ConnectWallet.vue";

const etherStore = useEtherStore();

onMounted(() => {});
</script>
