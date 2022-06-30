<script setup lang="ts">
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import HelloWorld from "./components/HelloWorld.vue";
import { ElConfigProvider } from "element-plus";
import { ref } from "vue";

const size = ref("small" as any);
const zIndex = ref(3000);
</script>

<template>
	<el-config-provider :size="size" :z-index="zIndex">
		<img alt="Vue logo" src="./assets/logo.png" />
		<HelloWorld msg="Hello Vue 3 + TypeScript + Vite" />
	</el-config-provider>
</template>

<style>
#app {
	font-family: Avenir, Helvetica, Arial, sans-serif;
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
	text-align: center;
	color: #2c3e50;
	margin-top: 60px;
}
</style>
