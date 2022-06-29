<script setup lang="ts">
import { ref } from "vue";
import { useEtherStore } from "@/store/etherStore";
import { Auth, Photo } from "@/api/etherApi";

const etherStore = useEtherStore();
let role = ref("");
let account = ref("");
let res = ref(false);
function getRole(): void {
	Auth.verifyRole(role.value, account.value).then((v) => {
		res.value = v;
		console.log("role: ", res);
		
	});
}
function testGetBuyers(){
	Photo.getBuyers(0).then((v)=>{
		console.log(v);
		
	})
}

defineProps<{ msg: string }>();
const count = ref(0);
</script>

<template>
	<h1>{{ msg }}</h1>
	<button
		v-if="!etherStore.account"
		@click="etherStore.connectWallet"
	>
		Connect Wallet
	</button>
	<input type="text" v-model="role" />
	<input type="text" v-model="account" />
	<button @click="getRole"></button>
	<div class="">{{ res }}</div>
	<button @click="testGetBuyers">getBuyers</button>
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
button {
	width: 100px;
	height: 25px;
}
</style>
