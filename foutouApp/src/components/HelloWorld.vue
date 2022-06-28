<script setup lang="ts">
import { ref } from "vue";
import { ethers } from "ethers";
import { useEtherStore } from "@/store/ethereum";
// const provider = new ethers.providers.Web3Provider(window.ethereum)
// console.log(provider);

// const signer = provider.getSigner()
const etherStore = useEtherStore();



defineProps<{ msg: string }>();

const count = ref(0);
</script>

<template>
	<h1>{{ msg }}</h1>
    <button v-if="!etherStore.account" class="bg-green-300 rounded p-4" @click="etherStore.connectWallet">
      Connect Wallet
    </button>
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
