<template>
	<el-config-provider :size="size" :z-index="zIndex">
		<my-nav></my-nav>
		<router-view></router-view>
		<my-footer></my-footer>
	</el-config-provider>
</template>

<script setup lang="ts">
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import HelloWorld from "./components/HelloWorld.vue";
import MyNav from "@/components/MyNav.vue";
import MyFooter from "@/components/MyFooter.vue";
import { ElConfigProvider } from "element-plus";
import { ref } from "vue";

const size = ref("small" as any);
const zIndex = ref(3000);
</script>

<style>
*{
	margin: 0;
	padding: 0;
}
#app {
	font-family: Avenir, Helvetica, Arial, sans-serif;
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
	text-align: center;
	color: #2c3e50;
}
</style>
