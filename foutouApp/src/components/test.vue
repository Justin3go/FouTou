<script setup lang="ts">
import { ref } from "vue";
import { useEtherStore } from "@/store/ethereum";
import { Auth } from "@/api/ethereum";

const etherStore = useEtherStore();
let role = ref("");
let account = ref("");
let res = ref(false);
function getRole(): void {
	Auth.verifyRole(role.value, account.value).then((v) => {
		res.value = v;
	});
}

defineProps<{ msg: string }>();
const count = ref(0);
</script>

<template>
	<h1>{{ msg }}</h1>
	<button
		v-if="!etherStore.account"
		class="bg-green-300 rounded p-4"
		@click="etherStore.connectWallet"
	>
		Connect Wallet
	</button>
	<input type="text" v-model="role" />
	<input type="text" v-model="account" />
	<button @click="getRole"></button>
	<div class="role-result">{{ res }}</div>
</template>

<style scoped>
a {
	color: #42b983;
}

label {
	margin: 0 0.5em;
	font-weight: bold;
}

code {
	background-color: #eee;
	padding: 2px 4px;
	border-radius: 4px;
	color: #304455;
}
</style>
