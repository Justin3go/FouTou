<template>
	<div class="custom-bg">
		<div class="avator">
			<el-skeleton
				style="--el-skeleton-circle-size: 10vw"
				animated
				:loading="loading"
			>
				<template #template>
					<el-skeleton-item variant="circle" />
				</template>
			</el-skeleton>
			<img src="/ava.png" v-if="!loading" style="height: 10vw" alt="" />
		</div>
	</div>
	<div class="info">
		<el-row>
			<el-col :span="6">
				<div class="main-info">
					<div class="name">
						{{ info.items.name }}
					</div>
					<div class="discription">
						{{ info.items.description }}
					</div>
				</div>
			</el-col>
			<el-col :span="6" :offset="12">
				<div class="social">twitter:{{ info.items.twitter }}</div>
			</el-col>
		</el-row>
	</div>
	<div class="list">
		<el-menu
			:default-active="activeIndex"
			class="el-menu-demo"
			mode="horizontal"
			@select="handleSelect"
		>
			<el-menu-item index="1">已创建</el-menu-item>
			<el-menu-item index="2">已购买</el-menu-item>
			<el-menu-item index="3">粉丝列表</el-menu-item>
			<el-menu-item index="4">关注列表</el-menu-item>
		</el-menu>
		<div v-if="currentIndex === '1'"><created-list :account="etherStore.account"></created-list></div>
		<div v-if="currentIndex === '2'"><bought-list :account="etherStore.account"></bought-list></div>
		<div v-if="currentIndex === '3'"><fans-list :account="etherStore.account"></fans-list></div>
		<div v-if="currentIndex === '4'"><follow-list :account="etherStore.account"></follow-list></div>
	</div>
</template>
<script setup lang="ts">
// todo 以及加了一定的数据，同时PER_ITEMS也有了对应的解析结构，接下来就是需要请求API然后写写界面了
import { onMounted, ref } from "vue";
import { Auth, Person } from "@/api/etherApi";
import { useEtherStore } from "@/store/etherStore";
import { parsePER_items } from "@/utils/parser";
import CreatedList from "@/components/personal/CreatedList.vue";
import BoughtList from "@/components/personal/BoughtList.vue";
import FansList from "@/components/personal/FansList.vue";
import FollowList from "@/components/personal/FollowList.vue";

// todo 至于后续他人浏览自己的页面就是borwse/address，所以在当前路由下肯定是自己浏览iji
const etherStore = useEtherStore();

let loading = ref(true);
let credit = ref(0);
const isAdmin = ref(false);
const info = reactive({
	items: { name: "", description: "", avator: "", twitter: "" },
	ad: {},
	credit: {},
});
const activeIndex = ref("1");
const currentIndex = ref("1");
const handleSelect = (key: string, keyPath: string[]) => {
	console.log(key, keyPath);
	currentIndex.value = key;
};

onMounted(async () => {
	const account = etherStore.account;
	isAdmin.value = await Auth.verifyRole(
		"0xd980155b32cf66e6af51e0972d64b9d5efe0e6f237dfaa4bdc83f990dd79e9c8",
		account
	);
	const srcItems = await Person.getPER_items(account);
	info.items = parsePER_items(srcItems);

	info.ad = await Person.getPER_ad(account);
	credit.value = await Person.getPER_credit(account);
	loading.value = false;
});
</script>
<style lang="scss" scoped>
.custom-bg {
	height: 20vw;
	width: 100%;
	background-color: $color-primary;
	position: relative;
	.avator {
		height: 10vw;
		border-radius: 5vw;
		position: absolute;
		bottom: -5vw;
		left: 7.5vw;
	}
}
.info {
	margin-top: 6vw;
	height: 6vw;
	.name {
		font-size: 1.5vw;
		font-weight: 900;
	}
	.discription {
		margin-top: 1vw;
	}
}
</style>
