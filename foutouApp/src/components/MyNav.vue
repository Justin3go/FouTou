<template>
	<el-menu
		:default-active="activeIndex"
		class="el-menu-demo"
		mode="horizontal"
		:ellipsis="false"
		@select="handleSelect"
	>
		<el-menu-item index="0">FouTou</el-menu-item>
		<div class="flex-grow" />
		<el-menu-item index="1">浏览</el-menu-item>
		<el-menu-item index="2">创建</el-menu-item>
		<el-menu-item index="3">主页</el-menu-item>
		<el-sub-menu index="4">
			<template #title>其他</template>
			<el-menu-item index="4-1">排行榜</el-menu-item>
			<el-menu-item index="4-2">item2</el-menu-item>
			<el-menu-item index="4-3">item3</el-menu-item>
		</el-sub-menu>
	</el-menu>
</template>

<script lang="ts" setup>
import { ref } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();
const activeIndex = ref("1");
const handleSelect = (key: string, keyPath: string[]) => {
	console.log("navtab: ", key, "|", keyPath);
	if (key === "0") {
		router.push({ path: "/" });
	} else if (key === "1") {
    router.push({ path: "/browse" });
	} else if (key === "2") {
    router.push({ path: "/create" });
	} else if (key === "3") {
    router.push({ path: "/personal" });
	} else {
		alert("先莫点，暂时还没想好加些什么");
	}
};
</script>

<style>
.flex-grow {
	flex-grow: 1;
}
</style>
